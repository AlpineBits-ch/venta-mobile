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
///
/// ## Who the message says it is from
///
/// Every field this class trusts has to come from the ciphertext, not from the
/// envelope around it. `authorId` and `encryptionState` are plain server fields
/// on a wire shape the server composes, so:
///
/// * the author of a decrypted message is replaced with the credential openmls
///   authenticated, and a mismatch is refused outright rather than shown;
/// * a message that arrives marked `Plain` in a context this device holds a live
///   MLS group for is flagged, because the alternative is that flipping one
///   string turns an E2EE thread into a channel the server can type into.
class MessageDecryptor {
  MessageDecryptor(this.mls, {MlsFailureLog? failures})
    : failures = failures ?? MlsFailureLog.shared;

  final MlsService mls;

  /// Where failures are counted so a device that simply cannot read a context
  /// can say so, instead of rendering a wall of base64.
  final MlsFailureLog failures;

  Future<List<MessageDto>> decryptAll(List<MessageDto> messages) async {
    final result = <MessageDto>[];
    for (final message in messages) {
      result.add(await decrypt(message));
    }
    return result;
  }

  Future<MessageDto> decrypt(MessageDto message) async {
    final contextId = message.conversationId ?? message.channelId;
    if (contextId == null) return message;

    if (!_needsDecryption(message)) return _checkedPlaintext(message, contextId);

    // The message names the era it was sealed under. Falling back to whichever
    // group we currently hold would decrypt against the wrong keys once a
    // context has been toggled off and on, producing silent garbage instead of
    // an honest failure.
    final generation = message.mlsGeneration ?? mls.knownGeneration(contextId);

    final cached = mls.cachedMessage(
      contextId: contextId,
      generation: generation,
      messageId: message.id,
    );
    if (cached != null) return message.copyWith(content: cached);

    if (!mls.isUnlocked) return message.copyWith(isUndecryptable: true);

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
        // So the engine can match this row back if the message turns out to be
        // from an epoch we have not reached and gets buffered.
        messageId: message.id,
      );
      final plaintext = processed.plaintext;

      // From an epoch this device has not caught up to. Held by the engine, not
      // lost, and replayed by `MlsSyncService` once the missing commits are
      // applied - so it is neither a failure nor a success, and counting it as
      // either would be wrong. Three "failures" is what puts "Re-link this
      // device" on screen, and that destroys history.
      if (processed.kind == MlsMessageKind.buffered) {
        return message.copyWith(isUndecryptable: true);
      }

      if (processed.kind == MlsMessageKind.application && plaintext != null) {
        final sender = processed.senderIdentity;

        // Fail closed on a message whose sender openmls could not name. It
        // should not be possible for an application message, and "we could not
        // tell who sent this" must never render as "sent by whoever the server
        // said".
        if (sender == null) {
          failures.recordSuccess(contextId);
          return message.copyWith(isUndecryptable: true);
        }

        if (!await _senderIsTheStatedAuthor(
          sender: sender,
          message: message,
          groupId: groupId,
          contextId: contextId,
        )) {
          return message.copyWith(isUndecryptable: true);
        }

        mls.cacheMessage(
          contextId: contextId,
          generation: generation,
          messageId: message.id,
          plaintextB64: plaintext,
        );
        failures.recordSuccess(contextId);

        // `authorId` is replaced, not merely checked. Everything downstream -
        // the avatar, the name, the "you" test, the mention resolution - reads
        // this field, and the authenticated identity is the only value that
        // means anything here.
        return message.copyWith(content: plaintext, authorId: sender);
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

  /// Opens the replacement content on a `MessageUpdated`.
  ///
  /// Separate from [decrypt] for one reason: an edit reuses the message id, so
  /// the plaintext cache holds the text this edit replaces. Serving that would
  /// show the pre-edit content forever, so this path decrypts unconditionally
  /// and then overwrites the entry.
  ///
  /// The event itself carries no author, no generation and no encryption state -
  /// it is `{ messageId, content }` and nothing else - so the context's own view
  /// is what decides how to read it. That is deliberate: taking the shape of the
  /// content from the server is exactly how the verbatim render happened.
  Future<DecryptedEdit> decryptEdit({
    required String contextId,
    required String messageId,
    required String wireContent,
  }) async {
    final generation = mls.knownGeneration(contextId);
    final groupId = generation == null
        ? null
        : mls.groupId(contextId, generation);

    if (groupId == null) {
      // Not an encrypted context as far as this device knows. Cleartext edits
      // are the ordinary case here.
      return DecryptedEdit(content: wireContent);
    }

    if (!mls.isUnlocked) {
      return DecryptedEdit(content: wireContent, isUndecryptable: true);
    }

    try {
      final processed = await mls.processMessage(
        groupIdB64: groupId,
        messageB64: MessageContentCodec.decodeStrict(wireContent),
        messageId: messageId,
      );
      final plaintext = processed.plaintext;
      final sender = processed.senderIdentity;

      if (processed.kind != MlsMessageKind.application ||
          plaintext == null ||
          sender == null) {
        return DecryptedEdit(content: wireContent, isUndecryptable: true);
      }

      if (!await mls.verifySenderInRoster(
        senderIdentity: sender,
        groupIdB64: groupId,
      )) {
        return DecryptedEdit(content: wireContent, isUndecryptable: true);
      }

      mls.cacheMessage(
        contextId: contextId,
        generation: generation,
        messageId: messageId,
        plaintextB64: plaintext,
      );
      failures.recordSuccess(contextId);
      return DecryptedEdit(content: plaintext);
    } catch (e) {
      // Includes the case this exists to close: cleartext arriving on the edit
      // channel of an encrypted thread, which fails to deserialize as an MLS
      // message. It is shown as unreadable rather than rendered, because the one
      // thing it certainly is not is something a member of this group wrote.
      failures.recordDecryptFailure(
        contextId: contextId,
        messageId: messageId,
        reason: e,
      );
      return DecryptedEdit(
        content: wireContent,
        isUndecryptable: true,
        isUnverifiedPlaintext: true,
      );
    }
  }

  /// The one check on this path that a hostile server cannot satisfy.
  ///
  /// `authorId` is a plain field on a shape the server composes; `sender` is the
  /// credential openmls authenticated against a leaf in the ratchet tree. The
  /// two disagreeing means the server attributed somebody else's ciphertext to a
  /// name of its choosing, which is the whole of C9 and is not a decrypt
  /// failure - the keys worked. Counting it would eventually tell the user to
  /// re-link the device, which is both wrong and destructive, so this records a
  /// *success* and refuses to render.
  ///
  /// The roster call afterwards is nearly a tautology (openmls has already tied
  /// the credential to an in-tree leaf) and is kept only for the narrow case it
  /// still covers: a message decrypted under an epoch the sender has since been
  /// removed in.
  Future<bool> _senderIsTheStatedAuthor({
    required String sender,
    required MessageDto message,
    required String groupId,
    required String contextId,
  }) async {
    if (message.authorId.isNotEmpty && message.authorId != sender) {
      failures.recordSuccess(contextId);
      return false;
    }

    if (!await mls.verifySenderInRoster(
      senderIdentity: sender,
      groupIdB64: groupId,
    )) {
      failures.recordSuccess(contextId);
      return false;
    }

    return true;
  }

  /// A message the server says is cleartext, in a context this device believes
  /// is encrypted.
  ///
  /// Not refused: a context that had encryption switched on has genuine
  /// cleartext history above the switch, and hiding it would be a bigger lie
  /// than showing it. Flagged instead, so the timeline can say this one line was
  /// not sealed by anybody - which is the difference between an injection that
  /// is invisible and one that is obvious.
  ///
  /// System messages are exempt: they are server-generated and never encrypted
  /// even in an encrypted context, because the server holds no group key to seal
  /// them with.
  MessageDto _checkedPlaintext(MessageDto message, String contextId) {
    if (message.isPending) return message;
    if (message.type == MessageType.system) return message;
    if (message.encryptionState != MessageEncryptionState.plain) return message;
    if (!mls.isEncrypted(contextId)) return message;
    return message.copyWith(isUnverifiedPlaintext: true);
  }

  /// System messages are server-generated and never encrypted, even in an
  /// encrypted context - the server has no group key to seal them with.
  static bool _needsDecryption(MessageDto message) =>
      message.encryptionState == MessageEncryptionState.encrypted &&
      message.type != MessageType.system &&
      !message.isPending;
}

/// The outcome of opening a `MessageUpdated`.
class DecryptedEdit {
  const DecryptedEdit({
    required this.content,
    this.isUndecryptable = false,
    this.isUnverifiedPlaintext = false,
  });

  /// Base64 plaintext when it opened, the untouched wire value otherwise - the
  /// UI branches on the flags, never on this.
  final String content;
  final bool isUndecryptable;
  final bool isUnverifiedPlaintext;
}
