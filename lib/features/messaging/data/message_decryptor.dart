import 'package:venta_mls/venta_mls.dart';

import '../../../core/mls/mls_failure_log.dart';
import '../../../core/mls/mls_service.dart';
import 'message_content_codec.dart';
import 'models/message_dto.dart';

/// Turns stored ciphertext back into readable content where it can. Port of
/// Alpine's `decryptMessages`.
///
/// The plaintext cache is not an optimisation, it is the only way most of this
/// succeeds. MLS ratchets forward and never backward, so a message can be
/// decrypted from the wire exactly once, on the device that was in the group at
/// the time. Paging back through history therefore reads from the cache or not
/// at all - [MessageDto.isUndecryptable] is set so the UI can say so plainly.
///
/// ## The envelope
///
/// `content` off the REST page or the realtime socket is `base64(utf8(what the
/// sender POSTed))`, because the server stores `Message.Content` as a `byte[]`
/// and serializes it back as base64. For an encrypted message the sender POSTed
/// a base64 MLS `PrivateMessage`, so the value here is base64 of base64 and the
/// outer layer has to come off before the engine sees it - the engine decodes
/// exactly once.
///
/// The push path is **not** the same shape: `MessagePushService` unwraps
/// server-side (`Encoding.UTF8.GetString(payload.Content)`), so
/// `MessagePushPayload.ciphertext` is already single-encoded and stripping it
/// again there would break the one path that used to work. That asymmetry is
/// why this bug looked intermittent rather than total.
class MessageDecryptor {
  MessageDecryptor(this.mls, {MlsFailureLog? failures})
    : failures = failures ?? MlsFailureLog.shared;

  final MlsService mls;

  /// Where failures are counted so a device that simply cannot read a context
  /// can say so, instead of rendering a wall of base64.
  final MlsFailureLog failures;

  Future<List<MessageDto>> decryptAll(List<MessageDto> messages) async {
    // Overwhelmingly the common case, and worth not allocating for: an
    // unencrypted context never has a single encrypted message in it.
    if (!messages.any(_needsDecryption)) return messages;

    final result = <MessageDto>[];
    for (final message in messages) {
      result.add(await decrypt(message));
    }
    return result;
  }

  Future<MessageDto> decrypt(MessageDto message) async {
    if (!_needsDecryption(message)) return message;

    final contextId = message.conversationId ?? message.channelId;
    if (contextId == null) return message;

    final cached = mls.cachedMessage(message.id);
    if (cached != null) return message.copyWith(content: cached);

    if (!mls.isUnlocked) return message.copyWith(isUndecryptable: true);

    // The message names the era it was sealed under. Falling back to whichever
    // group we currently hold would decrypt against the wrong keys once a
    // context has been toggled off and on, producing silent garbage instead of
    // an honest failure.
    final generation = message.mlsGeneration ?? mls.knownGeneration(contextId);
    final groupId = generation == null
        ? null
        : mls.groupId(contextId, generation);

    if (groupId == null) {
      // Not counted as a decrypt failure: this device holds no group for the
      // generation, which the join-request affordance already covers, and
      // counting it would report every message of a context we were never in.
      return message.copyWith(isUndecryptable: true);
    }

    try {
      final processed = await mls.processMessage(
        groupIdB64: groupId,
        // Strict, not lenient: passing the raw wire value through on a decode
        // failure hands the engine ASCII where it expects TLS bytes, and the
        // resulting error names the wrong problem.
        messageB64: MessageContentCodec.decodeStrict(message.content),
      );
      final plaintext = processed.plaintext;
      if (processed.kind == MlsMessageKind.application && plaintext != null) {
        // Guards against a compromised server replaying a valid ciphertext under
        // a credential that is not in the group. Cheap - the roster is already
        // in memory - and the alternative is attributing a message to someone
        // who never sent it.
        final sender = processed.senderIdentity;
        if (sender != null &&
            !await mls.verifySenderInRoster(
              senderIdentity: sender,
              groupIdB64: groupId,
            )) {
          // Deliberately not counted either. This is a rejection, not an
          // inability to read - the keys worked. Telling the user to re-link
          // the device would be exactly the wrong advice.
          failures.recordSuccess(contextId);
          return message.copyWith(isUndecryptable: true);
        }

        mls.cacheMessage(message.id, plaintext);
        failures.recordSuccess(contextId);
        return message.copyWith(content: plaintext);
      }

      // An application message is the only kind that reaches here; a commit or
      // proposal arriving on the message timeline means the two sides disagree
      // about what this context is.
      failures.recordDecryptFailure(
        contextId: contextId,
        messageId: message.id,
        reason: 'expected an application message, got ${processed.kind.name}',
      );
    } catch (e) {
      // Legitimately expected when paging past the ratchet's reach - which is
      // why this used to be swallowed entirely. Counting it instead is what
      // separates "that one is old" from "this device is not in the group",
      // since MLS reports both identically.
      failures.recordDecryptFailure(
        contextId: contextId,
        messageId: message.id,
        reason: e,
      );
    }

    return message.copyWith(isUndecryptable: true);
  }

  /// System messages are server-generated and never encrypted, even in an
  /// encrypted context - the server has no group key to seal them with.
  static bool _needsDecryption(MessageDto message) =>
      message.encryptionState == MessageEncryptionState.encrypted &&
      message.type != MessageType.system &&
      !message.isPending;
}
