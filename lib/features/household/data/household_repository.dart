import 'dart:async';

import '../../../core/realtime/realtime_event.dart';
import '../../../core/realtime/realtime_service.dart';

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
  };

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
    ...decisions,
    ...homeStatus,
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
  HouseholdRepository({required RealtimeService realtimeService}) {
    _subscription = realtimeService.events
        .where((e) => HouseholdEvents.all.contains(e.name))
        .listen(_controller.add);
  }

  late final StreamSubscription<RealtimeEvent> _subscription;
  final _controller = StreamController<RealtimeEvent>.broadcast();

  /// Every household event, unfiltered.
  Stream<RealtimeEvent> get events => _controller.stream;

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

  void dispose() {
    unawaited(_subscription.cancel());
    unawaited(_controller.close());
  }
}
