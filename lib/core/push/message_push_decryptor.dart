import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:venta_mls/venta_mls.dart';

import '../mls/mls_store.dart';
import 'message_push_payload.dart';

/// Turns the ciphertext riding on a push notification into the text to show in
/// the tray, without the app running.
///
/// This executes in Android's FCM background isolate - a fresh Dart isolate with
/// no `getIt`, no session and no `MlsService`. It therefore opens its own view of
/// the MLS state rather than reaching for the app's; on Android that is the same
/// process and so literally the same engine, which is what makes it safe to
/// advance the ratchet here. (iOS decrypts in a notification service extension
/// instead - see `ios/NotificationService/`.)
///
/// Everything that goes wrong ends the same way: null, and the caller shows the
/// server's placeholder. A notification that says "new encrypted message" is a
/// mild disappointment; one that crashes the isolate is a notification that
/// never arrives at all.
class MessagePushDecryptor {
  const MessagePushDecryptor._();

  /// The readable body, or null when this device cannot produce one.
  ///
  /// [store] is the running app's own store when there is one. Passing it
  /// matters more than it looks: decrypting through a second [MlsStore]
  /// instance would write the plaintext to disk but leave the app's in-memory
  /// cache without it, and since MLS only allows one read off the wire, the
  /// conversation would then show "cannot decrypt" for the very message the
  /// notification just displayed in full.
  static Future<String?> decrypt(
    MessagePushPayload payload, {
    MlsStore? store,
  }) async {
    if (!payload.isEncrypted) {
      return payload.placeholderBody.isEmpty ? null : payload.placeholderBody;
    }

    // `recipientUserId` is a **server field on a push payload**, and everything
    // below keys off it: the state directory, the engine's storage, the group
    // registry. So the same-account guard has to come first.
    //
    // It used to come thirty lines later, after `store.init(userId)` had already
    // repointed the DI singleton - the app's own `MlsStore`, passed in as
    // [store] - at whatever directory an attacker-chosen id resolved to. Two
    // consequences, both for the rest of the session rather than just this
    // notification: the app's registry and plaintext cache were replaced with
    // that directory's, and the flush at the end wrote the loaded account's
    // decrypted messages into it.
    final userId = payload.recipientUserId;
    if (userId == null) return null;

    final loaded = store?.loadedUserId;
    if (loaded != null && loaded != userId) {
      debugPrint(
        'MessagePushDecryptor: ${payload.messageId} names $userId but this '
        'process holds $loaded - leaving the store alone',
      );
      return null;
    }

    try {
      final engine = VentaMls();

      // The same rule one layer down, and it has to be checked before `init`
      // for the same reason. On Android this runs in a background *isolate*,
      // not a background process, so `initStorage` here is the same
      // process-global engine the app is using: pointing it somewhere else
      // clears the loaded account's groups and signers - which it must, or two
      // accounts' key material ends up in one store - leaving the foreground
      // session holding a signing handle the engine no longer knows.
      //
      // A notification for an account that is not the loaded one is therefore
      // shown as the server's placeholder rather than decrypted. Losing one
      // notification body beats tearing down a live session to read it.
      final loadedDirectory = await engine.currentStateDirectory();
      if (loadedDirectory != null) {
        final probe = store ?? MlsStore();
        final directory = await probe.stateDirectory(userId);
        if (loadedDirectory != directory.path) {
          debugPrint(
            'MessagePushDecryptor: ${payload.messageId} is for another account '
            'than the one this process has loaded - leaving the engine alone',
          );
          return null;
        }
      }

      // Already initialized when it came from the app; `init` is a no-op the
      // second time, so this is safe either way.
      store ??= MlsStore();
      await store.init(userId);

      final generation =
          payload.mlsGeneration ?? store.knownGeneration(payload.contextId);

      // The app may have decrypted this already over the realtime socket - the
      // websocket and the push race, and the socket usually wins when the app is
      // merely backgrounded. Reading the cache first also keeps a redelivered
      // push from being the thing that discovers the ratchet has moved on.
      final cached = store.cachedMessage(
        contextId: payload.contextId,
        generation: generation,
        messageId: payload.messageId,
      );
      if (cached != null) return _decode(cached);

      final ciphertext = payload.ciphertext;
      if (ciphertext == null) return null;

      final groupId = generation == null
          ? null
          : store.groupId(payload.contextId, generation);
      if (groupId == null) return null;

      final directory = await store.stateDirectory(userId);
      await engine.initStorage(
        directory.path,
        stateKeyB64: store.stateKeyB64,
      );

      final processed = await engine.processMessage(
        groupIdB64: groupId,
        messageB64: ciphertext,
        messageId: payload.messageId,
      );

      final plaintext = processed.plaintext;
      if (processed.kind != MlsMessageKind.application || plaintext == null) {
        return null;
      }

      if (!await _senderIsWhoTheServerSaid(engine, groupId, processed, payload)) {
        return null;
      }

      // MLS reads a message off the wire exactly once. If this is not written
      // down now, the conversation the notification came from will show "cannot
      // decrypt" for the very message the user just read in the tray.
      store.cacheMessage(
        contextId: payload.contextId,
        generation: generation,
        messageId: payload.messageId,
        plaintextB64: plaintext,
      );
      await store.flush();

      return _decode(plaintext);
    } catch (e) {
      debugPrint('MessagePushDecryptor: could not decrypt ${payload.messageId}: $e');
      // Losing the race against the app's own decrypt attempt looks exactly like
      // a failure from here, and the winner leaves the plaintext behind.
      return _recheckCache(store, payload);
    }
  }

  /// Both that the sender is in the group, and that they are the account the
  /// server named as the author.
  ///
  /// The author check is the one that matters, and it is specific to
  /// notifications only in how visible getting it wrong would be: this is the
  /// one place the app asserts "X sent you this" on a lock screen, where nobody
  /// is going to open the conversation and notice it was someone else. (The
  /// in-app decryptor now makes the same comparison.)
  ///
  /// The roster call is close to a tautology - openmls has already tied the
  /// credential to a leaf in the tree - and is kept for the narrow case it does
  /// cover: a message decrypted under an epoch its sender has since been removed
  /// in.
  static Future<bool> _senderIsWhoTheServerSaid(
    VentaMls engine,
    String groupId,
    MlsProcessedMessage processed,
    MessagePushPayload payload,
  ) async {
    final sender = processed.senderIdentity;

    // Fail closed. A message whose sender openmls could not name must not be
    // shown as "X said this" on a lock screen; there is nothing to check the
    // server's claim against, and the server supplied the claim.
    if (sender == null) {
      debugPrint(
        'MessagePushDecryptor: ${payload.messageId} decrypted with no sender '
        'credential - refusing to attribute it',
      );
      return false;
    }

    final authorId = payload.authorId;
    if (authorId != null && sender != authorId) {
      debugPrint(
        'MessagePushDecryptor: ${payload.messageId} was sealed by $sender but '
        'attributed to $authorId - refusing to show it',
      );
      return false;
    }

    return engine.verifySenderInRoster(
      senderIdentity: sender,
      groupIdB64: groupId,
    );
  }

  static Future<String?> _recheckCache(
    MlsStore? store,
    MessagePushPayload payload,
  ) async {
    if (store == null) return null;
    try {
      await store.reloadMessageCache();
      final cached = store.cachedMessage(
        contextId: payload.contextId,
        generation:
            payload.mlsGeneration ?? store.knownGeneration(payload.contextId),
        messageId: payload.messageId,
      );
      return cached == null ? null : _decode(cached);
    } catch (_) {
      return null;
    }
  }

  /// The cache and the engine both speak base64 of the UTF-8 bytes - that is
  /// what the sending client sealed, so it is what comes back out.
  static String? _decode(String plaintextB64) {
    try {
      final text = utf8.decode(base64Decode(plaintextB64));
      return text.isEmpty ? null : text;
    } catch (_) {
      return null;
    }
  }
}
