import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mls/venta_mls.dart';
import 'package:venta_mobile/core/mls/mls_service.dart';
import 'package:venta_mobile/features/messaging/data/message_decryptor.dart';
import 'package:venta_mobile/features/messaging/data/models/message_dto.dart';

/// What these cover: the read side of encryption, where every failure mode is
/// silent.
///
/// MLS ratchets forward and never backward, so a message decrypts from the wire
/// exactly once. Everything else has to come from the plaintext cache, and
/// anything that comes from neither has to be *said* - rendering the base64 is
/// how a user learns their history is gone by squinting at it.
///
/// The generation lookup is the subtle one: a context toggled off and on has two
/// distinct groups whose epochs both start at zero, so decrypting an old message
/// against the current group is not an error, it is silent garbage.

class _MockMls extends Mock implements MlsService {}

const _context = 'conv_1';
const _group = 'Z3JvdXA=';

MessageDto _encrypted({
  String id = 'msg_1',
  String content = 'ciphertext',
  int? generation,
  MessageType type = MessageType.message,
}) => MessageDto(
  id: id,
  content: content,
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
  late MessageDecryptor decryptor;

  final helloB64 = base64Encode(utf8.encode('hello'));

  setUp(() {
    mls = _MockMls();
    decryptor = MessageDecryptor(mls);

    when(() => mls.isUnlocked).thenReturn(true);
    when(() => mls.cachedMessage(any())).thenReturn(null);
    when(() => mls.cacheMessage(any(), any())).thenReturn(null);
    when(() => mls.knownGeneration(_context)).thenReturn(2);
    when(() => mls.groupId(_context, any())).thenReturn(_group);
    when(
      () => mls.verifySenderInRoster(
        senderIdentity: any(named: 'senderIdentity'),
        groupIdB64: any(named: 'groupIdB64'),
      ),
    ).thenAnswer((_) async => true);
  });

  test('plaintext messages are passed straight through', () async {
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
      ),
    );
  });

  test('decrypts and caches, so the next read never touches the ratchet', () async {
    when(
      () => mls.processMessage(
        groupIdB64: _group,
        messageB64: 'ciphertext',
      ),
    ).thenAnswer((_) async => _decrypted(helloB64));

    final result = await decryptor.decrypt(_encrypted());

    expect(result.content, helloB64);
    expect(result.isUndecryptable, isFalse);
    verify(() => mls.cacheMessage('msg_1', helloB64)).called(1);
  });

  test('serves a cached plaintext without decrypting again', () async {
    when(() => mls.cachedMessage('msg_1')).thenReturn(helloB64);

    final result = await decryptor.decrypt(_encrypted());

    expect(result.content, helloB64);
    verifyNever(
      () => mls.processMessage(
        groupIdB64: any(named: 'groupIdB64'),
        messageB64: any(named: 'messageB64'),
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
      'ciphertext',
      reason: 'content is left alone - the UI branches on the flag, not on it',
    );
  });

  test('flags rather than throws when the ratchet has moved past it', () async {
    when(
      () => mls.processMessage(
        groupIdB64: any(named: 'groupIdB64'),
        messageB64: any(named: 'messageB64'),
      ),
    ).thenThrow(const MlsException(MlsErrorKind.wrongEpoch, 'too old'));

    final result = await decryptor.decrypt(_encrypted());

    expect(result.isUndecryptable, isTrue);
  });

  test('refuses a sender who is not in the group roster', () async {
    // A compromised server replaying valid ciphertext under a spoofed
    // credential looks exactly like this. Showing it decrypted would attribute
    // a message to someone who never sent it.
    when(
      () => mls.processMessage(
        groupIdB64: any(named: 'groupIdB64'),
        messageB64: any(named: 'messageB64'),
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
    verifyNever(() => mls.cacheMessage(any(), any()));
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
