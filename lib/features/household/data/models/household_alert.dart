import '../../../../core/realtime/realtime_event.dart';
import '../../../../core/routing/household_deep_link.dart';

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

  /// A chore that came due and stayed undone. [targetId] is the occurrence, so
  /// it lands on the same board [choreDue] does.
  static const choreNudge = 'chore.nudge';

  /// A chore that moved to whoever is actually home while its assignee is away.
  /// [targetId] is the occurrence. Sent to the new assignee, so the handover is
  /// not a silent surprise.
  static const choreReassigned = 'chore.reassigned';

  /// Somebody added an expense you have a share in. Create only - correcting a
  /// split repeatedly would otherwise send one push per attempt.
  static const ledgerExpense = 'ledger.expense';
  static const ledgerSettlement = 'ledger.settlement';

  /// A recurring bill falling due today. [targetId] is the bill *occurrence*,
  /// not the bill.
  static const ledgerBillDue = 'ledger.bill_due';

  /// The advance warning for the same occurrence, far enough ahead that the
  /// money can still be moved.
  static const ledgerBillDueSoon = 'ledger.bill_due_soon';

  /// A fixed-amount bill that posted itself into the ledger. [targetId] is the
  /// resulting **expense**, unlike every other `ledger.bill_*` kind.
  static const ledgerBillPosted = 'ledger.bill_posted';

  /// A variable bill came due with nobody having entered what it actually was.
  /// [targetId] is the occurrence.
  static const ledgerBillNeedsAmount = 'ledger.bill_needs_amount';

  /// Whoever the meal plan has cooking today. [targetId] is the plan entry.
  static const mealsCookingToday = 'meals.cooking_today';

  /// An asset due for a service. [targetId] is the asset, as it is for every
  /// `maintenance.*` kind - there is no occurrence row to point at.
  static const maintenanceDue = 'maintenance.due';
  static const maintenanceWarranty = 'maintenance.warranty';
  static const maintenanceBroken = 'maintenance.broken';

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

  /// Where tapping it should land: the row named by [targetId], the board it
  /// happened on when the kind names no row, or the house itself when the
  /// module isn't a channel.
  ///
  /// The per-kind mapping lives in `household_deep_link.dart` so the push
  /// payload resolves the identical destination - see [HouseholdPushPayload].
  String get route => householdAlertRoute(
    guildId: guildId,
    kind: kind,
    channelId: channelId,
    targetId: targetId,
  );

  /// The row this is about, or null when the kind names none. What a board
  /// already on screen uses to scroll to and mark the row rather than only
  /// flashing the server's sentence.
  HouseholdFocus? get focus => householdFocusFor(kind, targetId);

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
