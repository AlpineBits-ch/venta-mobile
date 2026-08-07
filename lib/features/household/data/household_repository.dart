import 'dart:async';

import '../../../core/realtime/realtime_event.dart';
import '../../../core/realtime/realtime_service.dart';
import 'household_api.dart';
import 'models/digest_dto.dart';
import 'models/household_alert.dart';

/// The hub method names each household module broadcasts.
///
/// Every one of them carries `{ guildId, channelId, ... }` (home status
/// carries only `guildId` - it's guild-scoped, not a channel). Grouped by
/// module so a screen subscribes to its own module's events and nothing else.
abstract final class HouseholdEvents {
  static const list = <String>{
    'guild.ListItemCreated',
    'guild.ListItemUpdated',
    'guild.ListItemChecked',
    'guild.ListItemDeleted',
    'guild.ListItemsReordered',
    'guild.ListCleared',
  };

  static const chores = <String>{
    'guild.ChoreCreated',
    'guild.ChoreUpdated',
    'guild.ChoreDeleted',
    'guild.ChoreOccurrenceCreated',
    'guild.ChoreOccurrenceUpdated',
    // `{ guildId, channelId, occurrenceId, nudgedAt }`. Carries no sender, and
    // there is nothing downstream that could reconstruct one - see
    // `HouseholdApiWave2.nudgeOccurrence`.
    'guild.ChoreOccurrenceNudged',
  };

  /// `{ guildId, channelId, kind, targetId, title, body, data }` - the one
  /// envelope every household *alert* arrives in, whatever it is about.
  ///
  /// Replaces `guild.ChoreReminder`, which only ever carried one kind. New
  /// kinds keep being added, and a per-kind event name would mean a client
  /// silently stopped being told about each one - see [HouseholdAlert].
  static const householdAlert = 'guild.HouseholdAlert';

  /// `{ guildId, userId, choresReassigned, choresDropped, choresPaused }` -
  /// guild-wide, because a member leaving changes the rota and the ledger for
  /// everyone, not just for whoever pressed the button.
  static const memberMovedOut = 'guild.MemberMovedOut';

  static const pantry = <String>{
    'guild.PantryItemCreated',
    'guild.PantryItemUpdated',
    'guild.PantryItemDeleted',
  };

  static const ledger = <String>{
    'guild.ExpenseCreated',
    'guild.ExpenseUpdated',
    'guild.ExpenseDeleted',
    'guild.SettlementRecorded',
    'guild.ExpenseReceiptAdded',
    'guild.ExpenseReceiptDeleted',
  };

  /// The bills half of a ledger channel: the schedules and the obligations they
  /// generate. Grouped apart from [ledger] because the two boards are separate
  /// tabs - a bill falling due changes nothing about what has been spent.
  static const bills = <String>{
    'guild.RecurringExpenseCreated',
    'guild.RecurringExpenseUpdated',
    'guild.RecurringExpenseDeleted',
    'guild.BillOccurrenceCreated',
    'guild.BillOccurrenceUpdated',
  };

  static const meals = <String>{
    'guild.RecipeCreated',
    'guild.RecipeUpdated',
    'guild.RecipeDeleted',
    'guild.MealPlanEntryCreated',
    'guild.MealPlanEntryUpdated',
    'guild.MealPlanEntryDeleted',
  };

  static const maintenance = <String>{
    'guild.MaintenanceAssetCreated',
    'guild.MaintenanceAssetUpdated',
    'guild.MaintenanceAssetDeleted',
    'guild.MaintenanceRecordCreated',
    'guild.MaintenanceRecordUpdated',
    'guild.MaintenanceRecordDeleted',
  };

  /// Guild-scoped, like home status - an absence belongs to a person, not to a
  /// channel.
  static const absences = <String>{
    'guild.AbsenceCreated',
    'guild.AbsenceUpdated',
    'guild.AbsenceDeleted',
  };

  static const decisions = <String>{
    'guild.DecisionCreated',
    'guild.DecisionUpdated',
    'guild.DecisionClosed',
    'guild.DecisionCancelled',
  };

  static const homeStatus = <String>{'guild.HomeStatusChanged'};

  static const all = <String>{
    ...list,
    ...chores,
    ...pantry,
    ...ledger,
    ...bills,
    ...decisions,
    ...meals,
    ...maintenance,
    ...absences,
    ...homeStatus,
    memberMovedOut,
    householdAlert,
  };
}

/// Turns the household hub events into per-channel / per-guild invalidation
/// signals. Deliberately holds no cache of its own - the same choice
/// [WikiRepository] made, and for the same reason: one household screen is
/// open at a time, it fetches fresh on open, and a refetch per event is
/// simpler and more obviously correct than hand-patching rows.
///
/// Every module here is realtime by design, not as a nicety: two people in
/// the same shop with the same list open is the *normal* case, and a tick has
/// to strike through on the other phone within the second or the milk gets
/// bought twice.
class HouseholdRepository {
  HouseholdRepository({
    required this.api,
    required RealtimeService realtimeService,
  }) {
    _subscription = realtimeService.events
        .where((e) => HouseholdEvents.all.contains(e.name))
        .listen(_controller.add);
  }

  final HouseholdApi api;

  late final StreamSubscription<RealtimeEvent> _subscription;
  final _controller = StreamController<RealtimeEvent>.broadcast();

  /// The last digest per guild, with the `ETag` it came back with.
  ///
  /// Session-scoped, so [clear] is wired into `resetSessionScopedCaches()` -
  /// `myNetMinor` and "your turn" are per-account, and the next account's house
  /// card must not open showing this one's.
  final _digests = <String, ({HouseholdDigestDto digest, String? etag})>{};

  /// Every household event, unfiltered.
  Stream<RealtimeEvent> get events => _controller.stream;

  /// Household alerts, parsed. Malformed ones are dropped rather than passed
  /// on as an alert with nowhere to go.
  Stream<HouseholdAlert> get alerts => _controller.stream
      .where((e) => e.name == HouseholdEvents.householdAlert)
      .map(HouseholdAlert.tryParse)
      .where((alert) => alert != null)
      .cast<HouseholdAlert>();

  /// Alerts about one module channel - what a board that is already open
  /// shows inline, since a tray entry for the screen in front of you is easy
  /// to miss.
  Stream<HouseholdAlert> channelAlerts(String channelId) =>
      alerts.where((alert) => alert.channelId == channelId);

  /// Events for one channel's module - what a `List`/`Chores`/`Ledger`/
  /// `Pantry`/`Decisions` screen listens to.
  Stream<RealtimeEvent> channelEvents(String channelId, Set<String> names) =>
      _controller.stream.where(
        (e) =>
            names.contains(e.name) && e.stringField('channelId') == channelId,
      );

  /// Guild-scoped events (home status), plus the module events when a screen
  /// cares about the whole house rather than one channel - the pantry's
  /// "expiring" view spans every pantry, so it can't filter by channel.
  Stream<RealtimeEvent> guildEvents(String guildId, Set<String> names) =>
      _controller.stream.where(
        (e) => names.contains(e.name) && e.stringField('guildId') == guildId,
      );

  /// The house at a glance, revalidated against its `ETag`.
  ///
  /// The digest is assembled server-side either way - there is no single
  /// timestamp that moves when any of six modules changes - so `If-None-Match`
  /// saves the transfer, not the work. What it buys here is a card that
  /// re-renders instantly from the last copy when the guild is reopened, and
  /// that costs nothing to keep current after a module event.
  ///
  /// [cachedDigest] is what to draw immediately; this future is what replaces
  /// it. A failure keeps the cached copy rather than blanking the card.
  Future<HouseholdDigestDto> homeDigest(String guildId) async {
    final cached = _digests[guildId];
    final result = await api.getHomeDigest(guildId, etag: cached?.etag);
    final digest = result.digest;
    if (digest == null) {
      // 304 - nothing changed. There is no body to parse and the cache is by
      // definition still right.
      return cached?.digest ?? const HouseholdDigestDto();
    }
    _digests[guildId] = (digest: digest, etag: result.etag ?? cached?.etag);
    return digest;
  }

  HouseholdDigestDto? cachedDigest(String guildId) => _digests[guildId]?.digest;

  /// Drops per-account state on a session change - see
  /// `resetSessionScopedCaches()`.
  void clear() => _digests.clear();

  void dispose() {
    unawaited(_subscription.cancel());
    unawaited(_controller.close());
  }
}
