import 'route_paths.dart';

/// What kind of row a household deep link is pointing at.
///
/// A household channel holds structured rows rather than messages, so there is
/// no per-row URL to link to the way `/messages/{id}` would be. A board is
/// opened and then told which of its rows brought somebody there, which is what
/// these tokens name.
///
/// They are this client's own vocabulary, not the server's alert slugs: three
/// different `chore.*` alerts all point at an occurrence, and `ledger.expense`
/// and `ledger.bill_posted` both point at an expense despite living in
/// different halves of the ledger. Collapsing them here means a board switches
/// on one token instead of on the growing list of kinds that can reach it.
abstract final class HouseholdFocusKind {
  static const choreOccurrence = 'chore-occurrence';
  static const listItem = 'list-item';
  static const expense = 'expense';

  /// A generated instance of a recurring bill, not the schedule behind it.
  static const bill = 'bill';
  static const decision = 'decision';
  static const pantryItem = 'pantry-item';
  static const mealPlanEntry = 'meal-plan-entry';
  static const maintenanceAsset = 'maintenance-asset';
}

/// The row a household board was opened at, as parsed off the route.
class HouseholdFocus {
  const HouseholdFocus({required this.kind, required this.id});

  /// One of [HouseholdFocusKind]. Not an enum: a link minted by a newer build
  /// and opened by an older one carries a token this one has never seen, and
  /// the correct response is to open the board and highlight nothing, which a
  /// plain string does for free.
  final String kind;
  final String id;

  bool matches(String kind, String? id) =>
      id != null && id.isNotEmpty && this.kind == kind && this.id == id;

  /// Null unless both halves are present - half a reference points nowhere.
  static HouseholdFocus? tryParse(String? kind, String? id) {
    if (kind == null || kind.isEmpty || id == null || id.isEmpty) return null;
    return HouseholdFocus(kind: kind, id: id);
  }

  @override
  bool operator ==(Object other) =>
      other is HouseholdFocus && other.kind == kind && other.id == id;

  @override
  int get hashCode => Object.hash(kind, id);

  @override
  String toString() => 'HouseholdFocus($kind, $id)';
}

/// Which row a household alert is about, from its `kind` and `targetId`.
///
/// Null for the kinds whose target is not a row a board can point at: a
/// settlement, and the two alerts whose `targetId` is a channel id
/// (`list.completed`, `pantry.expiring`). Those open the board and stop there,
/// which is already the right answer - the board *is* the subject.
///
/// **Unrecognised kinds return null and that is not an error.** Kinds keep
/// being added, and the contract for every surface here is that an unknown one
/// still renders its title and body and still lands on the channel it came
/// from.
HouseholdFocus? householdFocusFor(String kind, String? targetId) {
  if (targetId == null || targetId.isEmpty) return null;
  final focusKind = switch (kind) {
    'chore.due' ||
    'chore.nudge' ||
    'chore.reassigned' => HouseholdFocusKind.choreOccurrence,

    'ledger.expense' => HouseholdFocusKind.expense,

    // The one trap in the table: every other `ledger.bill_*` kind names the
    // occurrence, but a bill that posted itself names the **expense** it
    // became. Pointing this at the bills board would highlight nothing, since
    // the occurrence it came from is no longer pending.
    'ledger.bill_posted' => HouseholdFocusKind.expense,

    'ledger.bill_due' ||
    'ledger.bill_due_soon' ||
    'ledger.bill_needs_amount' => HouseholdFocusKind.bill,

    'decision.opened' || 'decision.blocked' => HouseholdFocusKind.decision,

    'list.item_added' || 'pantry.restock' => HouseholdFocusKind.listItem,
    'pantry.low' => HouseholdFocusKind.pantryItem,

    'meals.cooking_today' => HouseholdFocusKind.mealPlanEntry,

    // Every `maintenance.*` kind points at the asset - a service is not a row
    // with a life of its own, it is something that happened to a machine.
    'maintenance.due' ||
    'maintenance.warranty' ||
    'maintenance.broken' => HouseholdFocusKind.maintenanceAsset,

    _ => null,
  };
  return focusKind == null
      ? null
      : HouseholdFocus(kind: focusKind, id: targetId);
}

/// Where tapping a household alert should land.
///
/// The row where the kind names one, the board otherwise, and the house itself
/// when the module has no channel at all. Shared by the realtime envelope and
/// the push payload so the same alert cannot open two different places
/// depending on whether the app happened to be running.
String householdAlertRoute({
  required String guildId,
  required String kind,
  String? channelId,
  String? targetId,
}) {
  if (channelId == null || channelId.isEmpty) {
    return RoutePaths.serverPath(guildId);
  }
  final focus = householdFocusFor(kind, targetId);
  return focus == null
      ? RoutePaths.serverChannelPath(guildId, channelId)
      : RoutePaths.serverChannelFocusPath(
          guildId,
          channelId,
          focusKind: focus.kind,
          focusId: focus.id,
        );
}
