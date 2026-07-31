import '../routing/route_paths.dart';

/// A new-message push, as the backend's `MessagePushService` builds it.
///
/// FCM data values are all strings, so the parsing is deliberately forgiving:
/// an older backend that has not been redeployed yet sends a subset of these
/// fields, and the result of that should be the plain notification it always
/// produced - never a crash in a background isolate nobody can see.
class MessagePushPayload {
  const MessagePushPayload({
    required this.messageId,
    required this.contextId,
    required this.senderName,
    required this.placeholderBody,
    this.conversationId,
    this.channelId,
    this.guildId,
    this.authorId,
    this.senderAvatarUrl,
    this.recipientUserId,
    this.isEncrypted = false,
    this.ciphertext,
    this.mlsGeneration,
  });

  static const type = 'message';

  final String messageId;

  /// Conversation id or channel id - whichever names the MLS group.
  final String contextId;

  final String senderName;

  /// What to show when the ciphertext cannot be turned back into text: the
  /// server's placeholder for an encrypted message, or the real body for a
  /// plaintext one.
  final String placeholderBody;

  final String? conversationId;
  final String? channelId;
  final String? guildId;
  final String? authorId;
  final String? senderAvatarUrl;

  /// The account on this device the push was addressed to. MLS state is stored
  /// per user id, so without it nothing outside the running app can find the
  /// group this message belongs to.
  final String? recipientUserId;

  final bool isEncrypted;

  /// Base64 MLS message. Null when the message is plaintext, and also when the
  /// ciphertext was too large for FCM's 4KB data budget - in which case the
  /// placeholder is all there is.
  final String? ciphertext;

  final int? mlsGeneration;

  bool get isChannel => channelId != null;

  /// Where tapping this notification should land.
  String? get route {
    final conversation = conversationId;
    if (conversation != null) return RoutePaths.conversationPath(conversation);
    final channel = channelId;
    final guild = guildId;
    if (channel != null && guild != null) {
      return RoutePaths.serverChannelPath(guild, channel);
    }
    return null;
  }

  static bool matches(Map<String, dynamic> data) => data['type'] == type;

  /// Null when the payload is not a message push or is missing the fields every
  /// branch below needs.
  static MessagePushPayload? tryParse(Map<String, dynamic> data) {
    if (!matches(data)) return null;

    final messageId = _string(data['messageId']);
    final conversationId = _string(data['conversationId']);
    final channelId = _string(data['channelId']);
    final contextId = _string(data['contextId']) ?? conversationId ?? channelId;
    if (messageId == null || contextId == null) return null;

    return MessagePushPayload(
      messageId: messageId,
      contextId: contextId,
      senderName: _string(data['senderName']) ?? 'New message',
      placeholderBody: _string(data['body']) ?? '',
      conversationId: conversationId,
      channelId: channelId,
      guildId: _string(data['guildId']),
      authorId: _string(data['authorId']),
      senderAvatarUrl: _string(data['senderAvatarUrl']),
      recipientUserId: _string(data['recipientUserId']),
      isEncrypted: data['encrypted'] == '1' || data['encrypted'] == true,
      ciphertext: _string(data['ciphertext']),
      mlsGeneration: int.tryParse(_string(data['mlsGeneration']) ?? ''),
    );
  }

  static String? _string(Object? value) {
    if (value == null) return null;
    final text = value.toString();
    return text.isEmpty ? null : text;
  }
}
