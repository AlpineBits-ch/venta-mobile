import '../routing/route_paths.dart';

/// A household-module push, as the backend's `HouseholdPushService` builds it.
///
/// Deliberately not a [MessagePushPayload]: there is no message, nothing here
/// is end-to-end encrypted, and the useful title is "Bins" rather than a
/// person's name. The two are told apart on the first key either parser reads,
/// `type`.
///
/// The push half of a household alert - the same `kind`, `targetId`, title and
/// body the `guild.HouseholdAlert` hub event carries (see `HouseholdAlert`).
/// A chore falling due, an expense you have a share in, a decision opened or
/// blocked, a restock, a pantry about to go off: [kind] is a stable slug and
/// the list keeps growing, so nothing branches on it to decide whether to show
/// the notification - an unrecognised kind still has a title, a body and
/// somewhere to land.
class HouseholdPushPayload {
  const HouseholdPushPayload({
    required this.kind,
    required this.guildId,
    required this.title,
    this.body = '',
    this.channelId,
    this.targetId,
    this.recipientUserId,
    this.hidden = false,
  });

  static const type = 'household';

  /// `chore.due`, and whatever the server adds later.
  final String kind;

  final String guildId;

  /// The module channel this came from, so tapping opens the right board.
  /// Absent for the guild-scoped modules, which have no channel of their own.
  final String? channelId;

  /// The row it's about - an occurrence id, an expense id. Also what the
  /// server collapses on, so a second notification about one chore replaces
  /// the first rather than stacking.
  final String? targetId;

  final String title;
  final String body;

  final String? recipientUserId;

  /// The recipient has "hide push content" on, so [title] and [body] are
  /// already the server's neutral stand-ins. Nothing extra to do - it's here
  /// because a client that renders its own richer copy must not.
  final bool hidden;

  /// Where tapping this should land: the board it happened on, or the house
  /// itself when the module isn't a channel.
  String get route => channelId == null
      ? RoutePaths.serverPath(guildId)
      : RoutePaths.serverChannelPath(guildId, channelId!);

  static bool matches(Map<String, dynamic> data) => data['type'] == type;

  static HouseholdPushPayload? tryParse(Map<String, dynamic> data) {
    if (!matches(data)) return null;
    final guildId = _string(data['guildId']);
    final kind = _string(data['kind']);
    if (guildId == null || kind == null) return null;

    return HouseholdPushPayload(
      kind: kind,
      guildId: guildId,
      channelId: _string(data['channelId']),
      targetId: _string(data['targetId']),
      title: _string(data['title']) ?? 'Home',
      body: _string(data['body']) ?? '',
      recipientUserId: _string(data['recipientUserId']),
      hidden: data['hidden'] == '1' || data['hidden'] == true,
    );
  }

  static String? _string(Object? value) {
    if (value == null) return null;
    final text = value.toString();
    return text.isEmpty ? null : text;
  }
}
