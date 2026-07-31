import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:venta_mobile/core/mls/mls_store.dart';
import 'package:venta_mobile/core/push/message_push_payload.dart';

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

    MlsStore open() => MlsStore(directory: () async => root);

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
      app.cacheMessage('msg_app', base64Encode(utf8.encode('from the app')));
      await app.flush();

      // A push notification decrypted in a second process, which loaded the file
      // and added to it.
      final extension = open();
      await extension.init('usr_1');
      extension.cacheMessage('msg_push', base64Encode(utf8.encode('from the push')));
      await extension.flush();

      // The app saves again, still holding only its own entry in memory. Before
      // the merge this wrote a file with msg_push missing.
      app.cacheMessage('msg_app2', base64Encode(utf8.encode('later')));
      await app.flush();

      final reloaded = open();
      await reloaded.init('usr_1');
      expect(reloaded.cachedMessage('msg_push'), isNotNull);
      expect(reloaded.cachedMessage('msg_app'), isNotNull);
      expect(reloaded.cachedMessage('msg_app2'), isNotNull);
    });

    test('picks up a background decrypt without a restart', () async {
      final app = open();
      await app.init('usr_1');
      expect(app.cachedMessage('msg_push'), isNull);

      final extension = open();
      await extension.init('usr_1');
      extension.cacheMessage('msg_push', base64Encode(utf8.encode('tapped')));
      await extension.flush();

      // What the app does on resume. Without it, opening the conversation the
      // notification came from shows "cannot decrypt" for that exact message.
      await app.reloadMessageCache();

      expect(
        utf8.decode(base64Decode(app.cachedMessage('msg_push')!)),
        'tapped',
      );
    });

    test('a reload never overwrites what this process just decrypted', () async {
      final app = open();
      await app.init('usr_1');
      app.cacheMessage('msg_1', base64Encode(utf8.encode('mine')));

      final other = open();
      await other.init('usr_1');
      other.cacheMessage('msg_1', base64Encode(utf8.encode('theirs')));
      await other.flush();

      await app.reloadMessageCache();

      expect(utf8.decode(base64Decode(app.cachedMessage('msg_1')!)), 'mine');
    });

    test('clearing really clears, merge or not', () async {
      final app = open();
      await app.init('usr_1');
      app.cacheMessage('msg_1', base64Encode(utf8.encode('secret')));
      await app.flush();

      await app.clearMessageCache();

      final reloaded = open();
      await reloaded.init('usr_1');
      expect(reloaded.cachedMessage('msg_1'), isNull);
    });
  });
}
