import 'package:flutter/foundation.dart';
import 'package:venta_mls/venta_mls.dart';

import '../../../core/mls/mls_service.dart';
import 'models/message_dto.dart';

/// Turns stored ciphertext back into readable content where it can. Port of
/// Alpine's `decryptMessages`.
///
/// The plaintext cache is not an optimisation, it is the only way most of this
/// succeeds. MLS ratchets forward and never backward, so a message can be
/// decrypted from the wire exactly once, on the device that was in the group at
/// the time. Paging back through history therefore reads from the cache or not
/// at all - [MessageDto.isUndecryptable] is set so the UI can say so plainly.
class MessageDecryptor {
  const MessageDecryptor(this.mls);

  final MlsService mls;

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

    if (groupId == null) return message.copyWith(isUndecryptable: true);

    try {
      final processed = await mls.processMessage(
        groupIdB64: groupId,
        messageB64: message.content,
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
          debugPrint(
            'MLS: message ${message.id} claims a sender who is not in the '
            'roster - refusing to show it as decrypted',
          );
          return message.copyWith(isUndecryptable: true);
        }

        mls.cacheMessage(message.id, plaintext);
        return message.copyWith(content: plaintext);
      }
    } catch (_) {
      // Expected when paging past the ratchet's reach - not an error worth
      // logging once per message.
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
