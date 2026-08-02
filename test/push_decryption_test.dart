import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:venta_mobile/core/mls/mls_store.dart';
import 'package:venta_mobile/core/push/message_push_payload.dart';
import 'package:venta_mobile/core/storage/state_file_cipher.dart';

import 'fake_state_cipher.dart';

/// What these cover: the two things that make a decrypted push notification
/// either work or quietly destroy message history.
///
/// The payload parsing is the boring half - but it runs in a background isolate
/// where a thrown exception produces no notification and no log anyone will see,
/// so "an older backend sent fewer fields" has to degrade rather than throw.
///
/// The plaintext cache is the dangerous half. Two *processes* write it: the app,
/// and whatever decrypted the last notification (Android's FCM background
/// isolate, or the iOS notification service extension). Each writes the file
/// whole. A plain overwrite therefore deletes the other's decrypted messages -
/// and MLS ratchets forward only, so those messages can never be read again from
/// the ciphertext. That is unrecoverable data loss caused purely by two writers,
/// which is why the merge below is tested rather than assumed.

Map<String, dynamic> _push({
  String? encrypted = '1',
  String? ciphertext = 'Y2lwaGVy',
  String? conversationId = 'conv_1',
  String? channelId,
  String? guildId,
  String? mlsGeneration = '2',
}) => <String, dynamic>{
  'type': 'message',
  'messageId': 'msg_1',
  'contextId': conversationId ?? channelId ?? 'ctx_1',
  'authorId': 'usr_sender',
  'senderName': 'Ada',
  'senderAvatarUrl': 'https://api.venta.gg/api/v1/social/profiles/p1/avatar',
  'recipientUserId': 'usr_me',
  'body': 'You have a new encrypted message',
  if (encrypted != null) 'encrypted': encrypted,
  if (ciphertext != null) 'ciphertext': ciphertext,
  if (conversationId != null) 'conversationId': conversationId,
  if (channelId != null) 'channelId': channelId,
  if (guildId != null) 'guildId': guildId,
  if (mlsGeneration != null) 'mlsGeneration': mlsGeneration,
};

void main() {
  group('MessagePushPayload', () {
    test('reads everything the decryptor needs off a full payload', () {
      final payload = MessagePushPayload.tryParse(_push())!;

      expect(payload.messageId, 'msg_1');
      expect(payload.contextId, 'conv_1');
      expect(payload.recipientUserId, 'usr_me');
      expect(payload.authorId, 'usr_sender');
      expect(payload.isEncrypted, isTrue);
      expect(payload.ciphertext, 'Y2lwaGVy');
      expect(payload.mlsGeneration, 2);
    });

    test('ignores anything that is not a message push', () {
      expect(MessagePushPayload.tryParse({'type': 'call', 'callId': 'c1'}), isNull);
      expect(MessagePushPayload.tryParse(const {}), isNull);
    });

    test('a plaintext message carries its body and no ciphertext', () {
      final payload = MessagePushPayload.tryParse(
        _push(encrypted: '0', ciphertext: null),
      )!;

      expect(payload.isEncrypted, isFalse);
      expect(payload.ciphertext, isNull);
      expect(payload.placeholderBody, 'You have a new encrypted message');
    });

    // The server drops the ciphertext when it would blow FCM's 4KB data budget.
    // The rest of the payload still has to parse - the notification falls back to
    // the placeholder rather than not arriving.
    test('survives a payload whose ciphertext was dropped for size', () {
      final payload = MessagePushPayload.tryParse(
        <String, dynamic>{..._push(ciphertext: null), 'truncated': '1'},
      )!;

      expect(payload.isEncrypted, isTrue);
      expect(payload.ciphertext, isNull);
    });

    test('routes a DM to the conversation and a channel to the guild', () {
      expect(
        MessagePushPayload.tryParse(_push())!.route,
        '/home/conversation/conv_1',
      );
      expect(
        MessagePushPayload.tryParse(
          _push(conversationId: null, channelId: 'chan_1', guildId: 'gld_1'),
        )!.route,
        '/server/gld_1/channel/chan_1',
      );
    });

    // Guild id and channel id both name part of the route; one without the other
    // cannot be navigated to, and a notification that opens the wrong screen is
    // worse than one that opens none.
    test('has no route for a channel message missing its guild', () {
      final payload = MessagePushPayload.tryParse(
        _push(conversationId: null, channelId: 'chan_1'),
      )!;

      expect(payload.route, isNull);
      expect(payload.isChannel, isTrue);
    });

    test('tolerates a backend that has not been redeployed yet', () {
      final payload = MessagePushPayload.tryParse(<String, dynamic>{
        'type': 'message',
        'messageId': 'msg_1',
        'conversationId': 'conv_1',
      })!;

      expect(payload.contextId, 'conv_1');
      expect(payload.isEncrypted, isFalse);
      expect(payload.mlsGeneration, isNull);
      expect(payload.senderName, 'New message');
    });
  });

  group('MlsStore plaintext cache', () {
    late Directory root;
    const context = 'conv_1';

    MlsStore open({String key = 'test-key-1'}) => MlsStore(
      directory: () async => root,
      stateKey: (_) async => key,
      cipher: FakeStateCipher.new,
    );

    void cache(MlsStore store, String messageId, String text) =>
        store.cacheMessage(
          contextId: context,
          generation: 2,
          messageId: messageId,
          plaintextB64: base64Encode(utf8.encode(text)),
        );

    String? read(MlsStore store, String messageId) => store.cachedMessage(
      contextId: context,
      generation: 2,
      messageId: messageId,
    );

    setUp(() async {
      root = await Directory.systemTemp.createTemp('venta_mls_cache_test');
    });

    tearDown(() async {
      if (await root.exists()) await root.delete(recursive: true);
    });

    test('keeps what another process decrypted while this one was open', () async {
      // The app, holding one message.
      final app = open();
      await app.init('usr_1');
      cache(app, 'msg_app', 'from the app');
      await app.flush();

      // A push notification decrypted in a second process, which loaded the file
      // and added to it.
      final extension = open();
      await extension.init('usr_1');
      cache(extension, 'msg_push', 'from the push');
      await extension.flush();

      // The app saves again, still holding only its own entry in memory. Before
      // the merge this wrote a file with msg_push missing.
      cache(app, 'msg_app2', 'later');
      await app.flush();

      final reloaded = open();
      await reloaded.init('usr_1');
      expect(read(reloaded, 'msg_push'), isNotNull);
      expect(read(reloaded, 'msg_app'), isNotNull);
      expect(read(reloaded, 'msg_app2'), isNotNull);
    });

    test('picks up a background decrypt without a restart', () async {
      final app = open();
      await app.init('usr_1');
      expect(read(app, 'msg_push'), isNull);

      final extension = open();
      await extension.init('usr_1');
      cache(extension, 'msg_push', 'tapped');
      await extension.flush();

      // What the app does on resume. Without it, opening the conversation the
      // notification came from shows "cannot decrypt" for that exact message.
      await app.reloadMessageCache();

      expect(utf8.decode(base64Decode(read(app, 'msg_push')!)), 'tapped');
    });

    test('a reload never overwrites what this process just decrypted', () async {
      final app = open();
      await app.init('usr_1');
      cache(app, 'msg_1', 'mine');

      final other = open();
      await other.init('usr_1');
      cache(other, 'msg_1', 'theirs');
      await other.flush();

      await app.reloadMessageCache();

      expect(utf8.decode(base64Decode(read(app, 'msg_1')!)), 'mine');
    });

    test('clearing really clears, merge or not', () async {
      final app = open();
      await app.init('usr_1');
      cache(app, 'msg_1', 'secret');
      await app.flush();

      await app.clearMessageCache();

      final reloaded = open();
      await reloaded.init('usr_1');
      expect(read(reloaded, 'msg_1'), isNull);
    });

    // C8. The cache is the plaintext of every message this device has ever
    // decrypted. It used to be plain JSON in a directory Android's auto-backup
    // includes by default, so a restore onto an attacker's handset handed over
    // the complete readable history with no keychain access and no unlock.
    group('at rest', () {
      File cacheFile(String userId) =>
          File('${root.path}/mls/$userId/mls_message_cache.json');

      test('holds no readable plaintext and no readable message ids', () async {
        final app = open();
        await app.init('usr_1');
        cache(app, 'msg_secret', 'the quick brown fox');
        await app.flush();

        final bytes = await cacheFile('usr_1').readAsBytes();
        expect(
          StateFileCipher.isSealed(bytes),
          isTrue,
          reason: 'the file must be recognisable as sealed',
        );

        final asText = String.fromCharCodes(bytes);
        expect(asText, isNot(contains('msg_secret')));
        expect(asText, isNot(contains(context)));
        expect(
          asText,
          isNot(contains(base64Encode(utf8.encode('the quick brown fox')))),
        );
        expect(
          () => jsonDecode(asText),
          throwsA(anything),
          reason: 'the cache must not parse as JSON any more',
        );
      });

      test('the group registry is sealed too', () async {
        final app = open();
        await app.init('usr_1');
        await app.registerGroup(
          contextId: context,
          generation: 2,
          mlsGroupId: 'Z3JvdXAtaWQ=',
        );

        final bytes = await File(
          '${root.path}/mls/usr_1/mls_group_registry.json',
        ).readAsBytes();
        expect(StateFileCipher.isSealed(bytes), isTrue);
        expect(String.fromCharCodes(bytes), isNot(contains('Z3JvdXAtaWQ=')));
      });

      test('does not open under another device\'s key', () async {
        final app = open();
        await app.init('usr_1');
        cache(app, 'msg_1', 'restored onto the wrong handset');
        await app.flush();

        // Exactly what a device backup restored elsewhere looks like: the files
        // come back, the keychain entry does not.
        final elsewhere = open(key: 'a-different-devices-key');
        await elsewhere.init('usr_1');

        expect(read(elsewhere, 'msg_1'), isNull);
      });

      test('a sealed file with no key at all is left alone, not replaced', () async {
        final app = open();
        await app.init('usr_1');
        cache(app, 'msg_1', 'still the only copy');
        await app.flush();
        final before = await cacheFile('usr_1').readAsBytes();

        // The keychain refused this launch. Starting from empty here would be
        // permanent loss - MLS hands the plaintext over exactly once - so the
        // file must survive untouched.
        final keyless = MlsStore(
          directory: () async => root,
          stateKey: (_) async => null,
          cipher: FakeStateCipher.new,
        );
        await keyless.init('usr_1');
        expect(read(keyless, 'msg_1'), isNull);
        await keyless.flush();

        expect(await cacheFile('usr_1').readAsBytes(), before);

        // And the next launch that does have the key still reads it.
        final recovered = open();
        await recovered.init('usr_1');
        expect(
          utf8.decode(base64Decode(read(recovered, 'msg_1')!)),
          'still the only copy',
        );
      });

      test('an unsealed file written by an older build is sealed on load', () async {
        // Every install in the field has one of these.
        final file = cacheFile('usr_1');
        await file.parent.create(recursive: true);
        await file.writeAsString(
          jsonEncode({'msg_legacy': base64Encode(utf8.encode('from before'))}),
        );

        final upgraded = open();
        await upgraded.init('usr_1');

        expect(
          utf8.decode(
            base64Decode(
              upgraded.cachedMessage(
                contextId: context,
                generation: 2,
                messageId: 'msg_legacy',
              )!,
            ),
          ),
          'from before',
          reason: 'the migration must not cost the history it is protecting',
        );
        expect(
          StateFileCipher.isSealed(await file.readAsBytes()),
          isTrue,
          reason: 'sealed on that load, not on some later incidental write - '
              'the plaintext copy is what a backup would carry away',
        );
      });

      // `_write` used to end `cipher == null ? plaintext : seal(plaintext)`:
      // the same open branch the engine had at `write_state_file`, on the file
      // that is the single largest at-rest exposure in the app. Availability was
      // the argument for it, and it is the wrong one - history that stops being
      // written down while the keychain is unavailable comes back, and history
      // written out in the clear does not.
      MlsStore keyless() => MlsStore(
        directory: () async => root,
        stateKey: (_) async => null,
        cipher: FakeStateCipher.new,
      );

      test('a launch with no key writes nothing rather than writing it bare', () async {
        final store = keyless();
        await store.init('usr_1');
        cache(store, 'msg_1', 'the quick brown fox');
        await store.flush();

        expect(
          await cacheFile('usr_1').exists(),
          isFalse,
          reason: 'the plaintext of a message went to disk unsealed',
        );
        await store.registerGroup(
          contextId: context,
          generation: 2,
          mlsGroupId: 'Z3JvdXAtaWQ=',
        );
        expect(
          await File('${root.path}/mls/usr_1/mls_group_registry.json').exists(),
          isFalse,
        );
      });

      test('a restore fails outright instead of living in memory', () async {
        // Reporting success here is the worst of the options: the user is told
        // their history is back, and finds out it is not when they relaunch.
        final store = keyless();
        await store.init('usr_1');

        expect(
          () => store.restoreMessageCache({
            'msg_1': base64Encode(utf8.encode('from the backup')),
          }),
          throwsA(isA<MlsStateNotSealable>()),
        );
        expect(
          () => store.restoreRegistry({'$context#2': 'Z3JvdXAtaWQ='}),
          throwsA(isA<MlsStateNotSealable>()),
        );

        // And the refusal came before the merge, so nothing was half-applied.
        expect(read(store, 'msg_1'), isNull);
        expect(store.groupId(context, 2), isNull);
      });

      test('clearing still clears when there is no key to rewrite with', () async {
        // `clear` used to write an empty map, which `_write` now refuses - so
        // the in-memory copy would empty while the real contents stayed on disk,
        // and the next launch with a working keychain would read them back.
        final app = open();
        await app.init('usr_1');
        cache(app, 'msg_1', 'forget this');
        await app.flush();
        expect(await cacheFile('usr_1').exists(), isTrue);

        await app.clearMessageCache();
        expect(await cacheFile('usr_1').exists(), isFalse);

        final relaunched = open();
        await relaunched.init('usr_1');
        expect(read(relaunched, 'msg_1'), isNull);
      });
    });

    // The cache key is `(contextId, generation, messageId)`. `messageId` alone
    // is a value the **server** chooses, so a server that reuses one it has seen
    // in another conversation gets this device to render that conversation's
    // plaintext here - with nothing decrypted, so no MLS property is violated.
    test('plaintext does not leak across contexts on a reused message id', () async {
      final app = open();
      await app.init('usr_1');
      app.cacheMessage(
        contextId: 'conv_private',
        generation: 1,
        messageId: 'msg_1',
        plaintextB64: base64Encode(utf8.encode('board meeting is at four')),
      );

      expect(
        app.cachedMessage(
          contextId: 'conv_attacker',
          generation: 1,
          messageId: 'msg_1',
        ),
        isNull,
        reason: 'a message id the server picked must not address another '
            'conversation\'s plaintext',
      );
      expect(
        app.cachedMessage(
          contextId: 'conv_private',
          generation: 2,
          messageId: 'msg_1',
        ),
        isNull,
        reason: 'nor another generation, whose group is a different group',
      );
      expect(
        app.cachedMessage(
          contextId: 'conv_private',
          generation: 1,
          messageId: 'msg_1',
        ),
        isNotNull,
      );
    });

    test('prunes down to the cap, keeping what was read most recently', () async {
      final app = open();
      await app.init('usr_1');

      // One over, so exactly one entry has to go.
      for (var i = 0; i <= MlsStore.maxCachedMessages; i++) {
        cache(app, 'msg_$i', 'body $i');
      }
      // Reading it is what makes msg_0 recent rather than oldest - paging back
      // through history inserts *old* messages last, so insertion order alone
      // would evict what the user is looking at.
      expect(read(app, 'msg_0'), isNotNull);
      await app.flush();

      expect(app.messageCacheSnapshot.length, MlsStore.maxCachedMessages);
      expect(read(app, 'msg_0'), isNotNull);
      expect(read(app, 'msg_1'), isNull, reason: 'the least recently read goes');
    });
  });

  group('MlsStore.sanitize', () {
    // The comment on this said it kept a path separator out of a user id, and
    // then allowed `.`, so `..` survived intact. Every caller of
    // `stateDirectory` takes its user id from somewhere the server controls -
    // `MessagePushPayload.recipientUserId` most directly.
    test('cannot be talked into leaving the account directory', () {
      expect(MlsStore.sanitize('..'), isNot(contains('.')));
      expect(MlsStore.sanitize('../usr_other'), isNot(contains('..')));
      expect(MlsStore.sanitize('.'), '_');
      expect(MlsStore.sanitize('a/../b'), 'a____b');
    });

    test('leaves an ordinary id alone', () {
      expect(MlsStore.sanitize('usr_01HX7Q-abc'), 'usr_01HX7Q-abc');
    });
  });
}
