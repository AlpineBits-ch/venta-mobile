import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mls/venta_mls.dart';
import 'package:venta_mobile/core/mls/mls_failure_log.dart';
import 'package:venta_mobile/core/mls/mls_service.dart';
import 'package:venta_mobile/features/messaging/data/message_content_codec.dart';
import 'package:venta_mobile/features/messaging/data/message_decryptor.dart';
import 'package:venta_mobile/features/messaging/data/models/message_dto.dart';

/// What these cover: the read side of encryption, where every failure mode is
/// silent.
///
/// The first group is the one that matters. `Message.Content` is a `byte[]`
/// server-side but `CreateMessageDto.Content` is a `string`, so the server
/// stores `Encoding.UTF8.GetBytes(dto.Content)` and `System.Text.Json` base64s
/// it on the way out. Whatever was POSTed therefore comes back as
/// `base64(utf8(posted))` - and for an encrypted message what was POSTed is
/// already a base64 MLS `PrivateMessage`, so the reader gets base64 of base64.
/// The desktop client strips the outer layer; this one did not, so **every**
/// encrypted message read over REST or the socket failed to decrypt. The engine
/// base64-decoded once, got ASCII, and `tls_deserialize_exact_bytes` refused it
/// - into a bare `catch (_)` that logged nothing.
///
/// The push path is deliberately the other shape: `MessagePushService` unwraps
/// server-side, so its `ciphertext` is single-encoded and must **not** be
/// stripped again. That asymmetry is why the bug read as intermittent rather
/// than total - when a notification landed and decrypted, the plaintext went
/// into the cache and the conversation rendered; when it was dropped, throttled
/// or beaten by the socket, the message was unreadable forever.
///
/// The rest cover what was already true: MLS ratchets forward and never
/// backward, so a message decrypts from the wire exactly once. Everything else
/// comes from the plaintext cache, and anything that comes from neither has to
/// be *said* - rendering base64 is how a user learns their history is gone by
/// squinting at it.

class _MockMls extends Mock implements MlsService {}

const _context = 'conv_1';
const _group = 'Z3JvdXA=';

/// A realistic MLS ciphertext: base64, and long enough that it is not
/// accidentally also valid base64 of something meaningful.
const _mlsCiphertext = 'AAEAAhBKduzb5gwNUj51Y+/mkX6WAAAAAAAAAAIBABxDzoxZ';

/// What the server hands back for it - the extra layer this client has to strip.
final _wireContent = base64Encode(utf8.encode(_mlsCiphertext));

MessageDto _encrypted({
  String id = 'msg_1',
  String? content,
  int? generation,
  MessageType type = MessageType.message,
}) => MessageDto(
  id: id,
  content: content ?? _wireContent,
  conversationId: _context,
  authorId: 'user_other',
  encryptionState: MessageEncryptionState.encrypted,
  mlsGeneration: generation,
  type: type,
);

MlsProcessedMessage _decrypted(String plaintextB64) => MlsProcessedMessage(
  kind: MlsMessageKind.application,
  plaintext: plaintextB64,
  selfRemoved: false,
  addedMembers: const [],
  removedLeafIndices: const [],
  senderIdentity: 'user_other',
  epoch: null,
);

void main() {
  late _MockMls mls;
  late MlsFailureLog failures;
  late MessageDecryptor decryptor;

  final helloB64 = base64Encode(utf8.encode('hello'));

  setUp(() {
    mls = _MockMls();
    failures = MlsFailureLog();
    decryptor = MessageDecryptor(mls, failures: failures);

    when(() => mls.isUnlocked).thenReturn(true);
    when(() => mls.isEncrypted(any())).thenReturn(true);
    when(
      () => mls.cachedMessage(
        contextId: any(named: 'contextId'),
        generation: any(named: 'generation'),
        messageId: any(named: 'messageId'),
      ),
    ).thenReturn(null);
    when(
      () => mls.cacheMessage(
        contextId: any(named: 'contextId'),
        generation: any(named: 'generation'),
        messageId: any(named: 'messageId'),
        plaintextB64: any(named: 'plaintextB64'),
      ),
    ).thenReturn(null);
    when(() => mls.knownGeneration(_context)).thenReturn(2);
    when(() => mls.groupId(_context, any())).thenReturn(_group);
    when(
      () => mls.verifySenderInRoster(
        senderIdentity: any(named: 'senderIdentity'),
        groupIdB64: any(named: 'groupIdB64'),
      ),
    ).thenAnswer((_) async => true);
  });

  group('wire encoding', () {
    test('hands the engine exactly what was posted, not the server\'s wrapper', () async {
      // The regression guard for the headline bug. Given `content ==
      // base64(utf8(posted))`, what reaches `processMessage` must be byte-identical
      // to `posted` - the engine decodes base64 exactly once, so an undecoded
      // value arrives as ASCII where TLS bytes are expected.
      final captured = <String>[];
      when(
        () => mls.processMessage(
          groupIdB64: any(named: 'groupIdB64'),
          messageB64: any(named: 'messageB64'),
          messageId: any(named: 'messageId'),
        ),
      ).thenAnswer((invocation) async {
        captured.add(invocation.namedArguments[#messageB64] as String);
        return _decrypted(helloB64);
      });

      await decryptor.decrypt(_encrypted());

      expect(captured.single, _mlsCiphertext);
      expect(
        captured.single,
        isNot(_wireContent),
        reason: 'the raw wire value is what used to be passed through',
      );
    });

    test('what _sendEncrypted posts survives the server\'s round trip', () async {
      // Written from the sender's side rather than with a literal, so the two
      // halves of the envelope cannot drift apart without this failing: the
      // sender posts `sealed.ciphertext`, the server stores
      // `Encoding.UTF8.GetBytes(...)` of it, and serializes that back as base64.
      const posted = _mlsCiphertext;
      final asStoredAndSerialized = base64Encode(utf8.encode(posted));

      expect(
        MessageContentCodec.decodeStrict(asStoredAndSerialized),
        posted,
        reason: 'decode(base64(utf8(encrypt(x)))) == encrypt(x)',
      );
    });

    test('the push envelope is a different shape and must not be stripped', () async {
      // `MessagePushService.cs` does `Encoding.UTF8.GetString(payload.Content)`
      // before putting the ciphertext on the notification, so the push payload
      // is already single-encoded. Decoding it again here would break the one
      // path that always worked.
      const posted = _mlsCiphertext;
      final restWire = base64Encode(utf8.encode(posted));
      final pushWire = utf8.decode(utf8.encode(posted));

      expect(pushWire, posted, reason: 'decode(utf8(encrypt(x))) == encrypt(x)');
      expect(
        restWire,
        isNot(pushWire),
        reason: 'the two transports must not be treated identically',
      );
    });

    test('flags rather than throws when the envelope is malformed', () async {
      // A value that is not base64 at all. It must fall through to
      // `isUndecryptable` rather than escaping as an exception, and must never
      // reach the engine - a raw pass-through is exactly the bug.
      final result = await decryptor.decrypt(
        _encrypted(content: 'not base64 at all!'),
      );

      expect(result.isUndecryptable, isTrue);
      verifyNever(
        () => mls.processMessage(
          groupIdB64: any(named: 'groupIdB64'),
          messageB64: any(named: 'messageB64'),
          messageId: any(named: 'messageId'),
        ),
      );
      expect(failures.decryptFailures(_context), 1);
    });
  });

  test('plaintext messages are passed straight through', () async {
    // A context that is not encrypted. In one that *is*, a message the server
    // marks `Plain` is flagged instead - see the "cleartext in an encrypted
    // thread" group.
    when(() => mls.isEncrypted(_context)).thenReturn(false);
    const plain = MessageDto(
      id: 'msg_1',
      content: 'aGk=',
      conversationId: _context,
      authorId: 'user_other',
    );

    final result = await decryptor.decryptAll([plain]);

    expect(result.single, same(plain));
    verifyNever(
      () => mls.processMessage(
        groupIdB64: any(named: 'groupIdB64'),
        messageB64: any(named: 'messageB64'),
          messageId: any(named: 'messageId'),
      ),
    );
  });

  test('decrypts and caches, so the next read never touches the ratchet', () async {
    when(
      () => mls.processMessage(groupIdB64: _group, messageB64: _mlsCiphertext, messageId: any(named: 'messageId')),
    ).thenAnswer((_) async => _decrypted(helloB64));

    final result = await decryptor.decrypt(_encrypted());

    expect(result.content, helloB64);
    expect(result.isUndecryptable, isFalse);
    verify(
      () => mls.cacheMessage(
        contextId: _context,
        generation: 2,
        messageId: 'msg_1',
        plaintextB64: helloB64,
      ),
    ).called(1);
  });

  test('serves a cached plaintext without decrypting again', () async {
    when(
      () => mls.cachedMessage(
        contextId: _context,
        generation: 2,
        messageId: 'msg_1',
      ),
    ).thenReturn(helloB64);

    final result = await decryptor.decrypt(_encrypted());

    expect(result.content, helloB64);
    verifyNever(
      () => mls.processMessage(
        groupIdB64: any(named: 'groupIdB64'),
        messageB64: any(named: 'messageB64'),
          messageId: any(named: 'messageId'),
      ),
    );
  });

  test('decrypts against the generation the message names, not the live one', () async {
    // The context is on generation 2; this message was sealed under 1. Using the
    // current group would decrypt with the wrong keys.
    when(() => mls.groupId(_context, 1)).thenReturn('b2xkZ3JvdXA=');
    when(
      () => mls.processMessage(
        groupIdB64: 'b2xkZ3JvdXA=',
        messageB64: any(named: 'messageB64'),
          messageId: any(named: 'messageId'),
      ),
    ).thenAnswer((_) async => _decrypted(helloB64));

    final result = await decryptor.decrypt(_encrypted(generation: 1));

    expect(result.content, helloB64);
    verify(() => mls.groupId(_context, 1)).called(1);
  });

  test('flags a message from a generation this device never joined', () async {
    when(() => mls.groupId(_context, 7)).thenReturn(null);

    final result = await decryptor.decrypt(_encrypted(generation: 7));

    expect(result.isUndecryptable, isTrue);
    expect(
      result.content,
      _wireContent,
      reason: 'content is left alone - the UI branches on the flag, not on it',
    );
    expect(
      failures.decryptFailures(_context),
      0,
      reason: 'holding no group for a generation is not a decrypt failure - the '
          'join-request affordance covers it, and counting it would report '
          'every message of a context we were never in',
    );
  });

  test('flags rather than throws when the ratchet has moved past it', () async {
    when(
      () => mls.processMessage(
        groupIdB64: any(named: 'groupIdB64'),
        messageB64: any(named: 'messageB64'),
          messageId: any(named: 'messageId'),
      ),
    ).thenThrow(const MlsException(MlsErrorKind.wrongEpoch, 'too old'));

    final result = await decryptor.decrypt(_encrypted());

    expect(result.isUndecryptable, isTrue);
  });

  group('surfacing failures', () {
    test('counts them, so a broken device can be told apart from old history', () async {
      when(
        () => mls.processMessage(
          groupIdB64: any(named: 'groupIdB64'),
          messageB64: any(named: 'messageB64'),
          messageId: any(named: 'messageId'),
        ),
      ).thenThrow(const MlsException(MlsErrorKind.wrongEpoch, 'too old'));

      for (var i = 0; i < MlsFailureLog.unreadableThreshold; i++) {
        await decryptor.decrypt(_encrypted(id: 'msg_$i'));
      }

      expect(failures.decryptFailures(_context), MlsFailureLog.unreadableThreshold);
      expect(
        failures.cannotRead(_context),
        isTrue,
        reason: 'this is what puts the "re-link this device" affordance on screen',
      );
      expect(failures.lastReason(_context), contains('too old'));
    });

    test('one success clears the streak', () async {
      var fail = true;
      when(
        () => mls.processMessage(
          groupIdB64: any(named: 'groupIdB64'),
          messageB64: any(named: 'messageB64'),
          messageId: any(named: 'messageId'),
        ),
      ).thenAnswer((_) async {
        if (fail) throw const MlsException(MlsErrorKind.wrongEpoch, 'too old');
        return _decrypted(helloB64);
      });

      await decryptor.decrypt(_encrypted(id: 'a'));
      await decryptor.decrypt(_encrypted(id: 'b'));
      expect(failures.decryptFailures(_context), 2);

      // Paging back past the ratchet is normal; a device that then reads a
      // current message is plainly still in the group.
      fail = false;
      await decryptor.decrypt(_encrypted(id: 'c'));

      expect(failures.decryptFailures(_context), 0);
      expect(failures.cannotRead(_context), isFalse);
    });

    test('a spoofed sender is a rejection, not an inability to read', () async {
      // A compromised server replaying valid ciphertext under a spoofed
      // credential looks exactly like this. Showing it decrypted would attribute
      // a message to someone who never sent it - but the keys worked, so telling
      // the user to re-link the device would be exactly the wrong advice.
      when(
        () => mls.processMessage(
          groupIdB64: any(named: 'groupIdB64'),
          messageB64: any(named: 'messageB64'),
          messageId: any(named: 'messageId'),
        ),
      ).thenAnswer((_) async => _decrypted(helloB64));
      when(
        () => mls.verifySenderInRoster(
          senderIdentity: any(named: 'senderIdentity'),
          groupIdB64: any(named: 'groupIdB64'),
        ),
      ).thenAnswer((_) async => false);

      final result = await decryptor.decrypt(_encrypted());

      expect(result.isUndecryptable, isTrue);
      verifyNever(
        () => mls.cacheMessage(
          contextId: any(named: 'contextId'),
          generation: any(named: 'generation'),
          messageId: any(named: 'messageId'),
          plaintextB64: any(named: 'plaintextB64'),
        ),
      );
      expect(failures.cannotRead(_context), isFalse);
    });
  });

  // C9. `authorId` is a plain field on a wire shape the server composes;
  // `senderIdentity` is the credential openmls authenticated against a leaf in
  // the ratchet tree. Nothing compared them, so a server could take any member's
  // ciphertext and attribute it to anybody. The check already existed in
  // `MessagePushDecryptor` and had never been applied in-app.
  group('who the message says it is from', () {
    void decryptsAs(String? senderIdentity) => when(
      () => mls.processMessage(
        groupIdB64: any(named: 'groupIdB64'),
        messageB64: any(named: 'messageB64'),
        messageId: any(named: 'messageId'),
      ),
    ).thenAnswer(
      (_) async => MlsProcessedMessage(
        kind: MlsMessageKind.application,
        plaintext: helloB64,
        selfRemoved: false,
        addedMembers: const [],
        removedLeafIndices: const [],
        senderIdentity: senderIdentity,
        epoch: null,
      ),
    );

    test('refuses a message attributed to someone who did not seal it', () async {
      decryptsAs('user_mallory');

      // `_encrypted` says `authorId: 'user_other'`.
      final result = await decryptor.decrypt(_encrypted());

      expect(
        result.isUndecryptable,
        isTrue,
        reason: 'the keys worked, but the server named the wrong author - '
            'showing the text would put words in somebody\'s mouth',
      );
      expect(result.content, isNot(helloB64));
      verifyNever(
        () => mls.cacheMessage(
          contextId: any(named: 'contextId'),
          generation: any(named: 'generation'),
          messageId: any(named: 'messageId'),
          plaintextB64: any(named: 'plaintextB64'),
        ),
      );
      expect(
        failures.cannotRead(_context),
        isFalse,
        reason: 'a rejection is not an inability to read, and counting it '
            'would eventually advise a re-link, which destroys history',
      );
    });

    test('shows the authenticated sender, not the server\'s authorId', () async {
      decryptsAs('user_other');

      final result = await decryptor.decrypt(_encrypted());

      expect(result.content, helloB64);
      expect(
        result.authorId,
        'user_other',
        reason: 'the avatar, the name and the "is this me" test all read this '
            'field, so it has to be the credential and not the envelope',
      );
    });

    test('refuses a message whose sender the engine could not name', () async {
      decryptsAs(null);

      final result = await decryptor.decrypt(_encrypted());

      expect(
        result.isUndecryptable,
        isTrue,
        reason: '"we could not tell who sent this" must never render as '
            '"sent by whoever the server said"',
      );
    });
  });

  // The other half of C9: encryption state is a server field too, so flipping it
  // to `Plain` used to put server-chosen text into an E2EE thread with no
  // decrypt, no check and no indicator.
  group('cleartext in an encrypted thread', () {
    MessageDto plain({MessageType type = MessageType.message}) => MessageDto(
      id: 'msg_plain',
      content: base64Encode(utf8.encode('transfer the money')),
      conversationId: _context,
      authorId: 'user_other',
      type: type,
    );

    test('is flagged when this device holds a live group for the context', () async {
      when(() => mls.isEncrypted(_context)).thenReturn(true);

      final result = await decryptor.decrypt(plain());

      expect(result.isUnverifiedPlaintext, isTrue);
    });

    test('is left alone in a context that is not encrypted', () async {
      when(() => mls.isEncrypted(_context)).thenReturn(false);

      final result = await decryptor.decrypt(plain());

      expect(result.isUnverifiedPlaintext, isFalse);
    });

    test('exempts system messages, which the server genuinely cannot seal', () async {
      when(() => mls.isEncrypted(_context)).thenReturn(true);

      final result = await decryptor.decrypt(plain(type: MessageType.system));

      expect(result.isUnverifiedPlaintext, isFalse);
    });
  });

  // An early message is held by the engine and replayed once the missing commits
  // land. It is neither a success nor a failure, and counting it as a failure
  // three times puts "Re-link this device" on screen - which destroys history,
  // for a device that was a few seconds behind.
  test('a buffered message is not counted as a decrypt failure', () async {
    when(
      () => mls.processMessage(
        groupIdB64: any(named: 'groupIdB64'),
        messageB64: any(named: 'messageB64'),
        messageId: any(named: 'messageId'),
      ),
    ).thenAnswer(
      (_) async => const MlsProcessedMessage(
        kind: MlsMessageKind.buffered,
        plaintext: null,
        selfRemoved: false,
        addedMembers: [],
        removedLeafIndices: [],
        senderIdentity: null,
        epoch: 7,
      ),
    );

    for (var i = 0; i < MlsFailureLog.unreadableThreshold + 1; i++) {
      final result = await decryptor.decrypt(_encrypted(id: 'msg_$i'));
      expect(result.isUndecryptable, isTrue);
    }

    expect(failures.decryptFailures(_context), 0);
    expect(failures.cannotRead(_context), isFalse);
  });

  test('flags everything while the session is locked', () async {
    when(() => mls.isUnlocked).thenReturn(false);

    final result = await decryptor.decrypt(_encrypted());

    expect(result.isUndecryptable, isTrue);
  });

  test('leaves system messages alone - the server cannot seal them', () async {
    final system = _encrypted(type: MessageType.system);

    final result = await decryptor.decrypt(system);

    expect(result, same(system));
  });
}
