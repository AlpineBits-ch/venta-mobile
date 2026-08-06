import '../../../../core/realtime/realtime_event.dart';
import '../../../../core/routing/route_paths.dart';

/// One `guild.HouseholdAlert` - a household thing that somebody needs to know
/// about **with the app closed**.
///
/// Not to be confused with the module broadcasts (`guild.ListItemChecked` and
/// friends). Those are state replication: they go to whoever currently has the
/// channel open, they are frequent, and they must never buzz a phone -
/// somebody ticking milk off the list is not worth waking anybody for. An
/// alert is the opposite: few recipients, each of whom is being told something,
/// and it arrives as a push as well as on the hub.
///
/// **One event carries every kind, deliberately.** Kinds keep being added, and
/// a client that had to subscribe to `guild.SomethingNewAlert` would silently
/// stop being told about whatever shipped next. So nothing here branches on
/// [kind] to decide *whether* to show an alert - only on where tapping it
/// should land. [title] and [body] are written server-side precisely so a
/// client needs no per-kind copy.
///
/// This replaces `guild.ChoreReminder`, whose `occurrenceId` is now [targetId]
/// and whose `choreId`/`dueAt` moved into [data].
class HouseholdAlert {
  const HouseholdAlert({
    required this.guildId,
    required this.kind,
    required this.title,
    this.channelId,
    this.targetId,
    this.body = '',
    this.data = const {},
  });

  /// The assignee's turn came round. [targetId] is the occurrence.
  ///
  /// Held back inside the guild's quiet hours and never sent for a chore more
  /// than 12 hours overdue - so its *absence* is ordinary and never means
  /// "still pending", which is why nothing renders a waiting state for it.
  static const choreDue = 'chore.due';

  /// Somebody added an expense you have a share in. Create only - correcting a
  /// split repeatedly would otherwise send one push per attempt.
  static const ledgerExpense = 'ledger.expense';
  static const ledgerSettlement = 'ledger.settlement';
  static const decisionOpened = 'decision.opened';

  /// A decision picked up its first block. Fires on the *transition* into a
  /// block, so rewording a reason can't buzz the house at will.
  static const decisionBlocked = 'decision.blocked';

  /// Something dropped below its threshold and went onto the shopping list.
  /// Only members whose home status is `Out` or `OnMyWay` get it.
  static const pantryRestock = 'pantry.restock';

  /// Batched per pantry, not per item - [targetId] is the **channel**, and the
  /// full item list is in `data['items']`.
  static const pantryExpiring = 'pantry.expiring';

  final String guildId;

  /// The module channel it happened on. Absent for the guild-scoped modules,
  /// which have no channel of their own.
  final String? channelId;

  /// A stable slug. Unrecognised ones are shown exactly like known ones.
  final String kind;

  /// The row it is about - an occurrence, an expense, a decision. For
  /// [pantryExpiring] it is a channel id instead; see that constant.
  final String? targetId;

  final String title;
  final String body;

  /// Whatever else the kind carries (`items` for [pantryExpiring], `choreId`
  /// and `dueAt` for [choreDue]). Read defensively - it is per-kind and grows.
  final Map<String, dynamic> data;

  /// What to say in one line when this arrives while the app is open.
  String get message => body.isEmpty ? title : body;

  /// Where tapping it should land: the board it happened on, or the house
  /// itself when the module isn't a channel.
  String get route => channelId == null
      ? RoutePaths.serverPath(guildId)
      : RoutePaths.serverChannelPath(guildId, channelId!);

  /// Null when the event isn't one, or is missing the guild it belongs to -
  /// there is nowhere to send somebody without it.
  static HouseholdAlert? tryParse(RealtimeEvent event) {
    final guildId = _string(event.field('guildId'));
    final kind = _string(event.field('kind'));
    if (guildId == null || kind == null) return null;
    final data = event.field('data');
    return HouseholdAlert(
      guildId: guildId,
      channelId: _string(event.field('channelId')),
      kind: kind,
      targetId: _string(event.field('targetId')),
      title: _string(event.field('title')) ?? 'Home',
      body: _string(event.field('body')) ?? '',
      data: data is Map ? data.cast<String, dynamic>() : const {},
    );
  }

  static String? _string(Object? value) {
    if (value == null) return null;
    final text = value.toString();
    return text.isEmpty ? null : text;
  }
}
