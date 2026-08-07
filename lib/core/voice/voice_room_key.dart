import 'voice_snapshot_dto.dart';

/// Identifies one voice room, in either of the two ways the server addresses
/// them.
///
/// A guild voice channel and a direct call are the same system: the server
/// runs one implementation for both, and the only wire-level differences are
/// the event prefix and the name of the field carrying the room id. Keeping
/// that pair in one type is what stops "works in channels, not in calls" from
/// being expressible on this client either.
class VoiceRoomKey {
  const VoiceRoomKey._(this.kind, this.id);

  const VoiceRoomKey.channel(String channelId)
    : this._(VoiceRoomKind.channel, channelId);

  const VoiceRoomKey.call(String callId) : this._(VoiceRoomKind.call, callId);

  /// `"channel"` or `"call"` - the `roomKind` argument of `voice.Heartbeat`.
  final String kind;
  final String id;

  bool get isCall => kind == VoiceRoomKind.call;

  /// The SignalR event-name prefix for this room kind.
  String get eventPrefix => isCall ? 'call.' : 'guild.voice.';

  /// The payload field every event of this kind carries its room id in.
  String get roomIdField => isCall ? 'callId' : 'channelId';

  /// Reads this room's id out of an event payload, or null when the payload is
  /// about a different kind of room.
  String? roomIdOf(Map<String, dynamic> payload) =>
      payload[roomIdField] as String?;

  @override
  bool operator ==(Object other) =>
      other is VoiceRoomKey && other.kind == kind && other.id == id;

  @override
  int get hashCode => Object.hash(kind, id);

  @override
  String toString() => '$kind:$id';
}
