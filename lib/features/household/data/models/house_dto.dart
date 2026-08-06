import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/format/api_date_time.dart';
import 'ledger_dto.dart';

part 'house_dto.freezed.dart';
part 'house_dto.g.dart';

/// Where somebody physically is. **Not connection presence**: the existing
/// online/offline dot means "their app is connected", this means "they're in
/// the flat". They have to stay visually distinct or both become useless.
enum HomeStatusKind {
  @JsonValue('Home')
  home,
  @JsonValue('Out')
  out,
  @JsonValue('Asleep')
  asleep,
  @JsonValue('DoNotDisturb')
  doNotDisturb,
  @JsonValue('OnMyWay')
  onMyWay,
}

extension HomeStatusKindX on HomeStatusKind {
  String get wireValue => switch (this) {
    HomeStatusKind.home => 'Home',
    HomeStatusKind.out => 'Out',
    HomeStatusKind.asleep => 'Asleep',
    HomeStatusKind.doNotDisturb => 'DoNotDisturb',
    HomeStatusKind.onMyWay => 'OnMyWay',
  };

  String get label => switch (this) {
    HomeStatusKind.home => 'Home',
    HomeStatusKind.out => 'Out',
    HomeStatusKind.asleep => 'Asleep',
    HomeStatusKind.doNotDisturb => 'Do not disturb',
    HomeStatusKind.onMyWay => 'On my way',
  };

  IconData get icon => switch (this) {
    HomeStatusKind.home => Icons.home_rounded,
    HomeStatusKind.out => Icons.directions_walk_rounded,
    HomeStatusKind.asleep => Icons.bedtime_rounded,
    HomeStatusKind.doNotDisturb => Icons.do_not_disturb_on_rounded,
    HomeStatusKind.onMyWay => Icons.directions_run_rounded,
  };
}

/// Somebody's asserted whereabouts, with an expiry.
///
/// It decays on purpose: a status nobody clears stops being asserted rather
/// than claiming someone is asleep three days later. A member with no live
/// status is simply absent from the list - the server never returns expired
/// entries.
///
/// You can only ever set your own. There's no permission for it and no way to
/// set someone else's; "Anna is asleep" is only Anna's to assert.
@freezed
sealed class HomeStatusDto with _$HomeStatusDto {
  @ApiDateTimeConverter()
  const factory HomeStatusDto({
    @Default('') String userId,
    @Default(HomeStatusKind.home)
    @JsonKey(unknownEnumValue: HomeStatusKind.home)
    HomeStatusKind kind,

    /// <= 100 chars.
    String? note,
    DateTime? expiresAt,
  }) = _HomeStatusDto;

  factory HomeStatusDto.fromJson(Map<String, dynamic> json) =>
      _$HomeStatusDtoFromJson(json);
}

/// The house's quiet window, in minutes past local midnight.
///
/// It **wraps midnight** whenever `start > end` - 22:00 -> 07:00 is the normal
/// case, not an edge case. Chore reminders that would fire inside the window
/// are deferred to its end.
@freezed
sealed class QuietHoursDto with _$QuietHoursDto {
  const factory QuietHoursDto({
    @Default(false) bool enabled,

    /// 0-1439.
    @Default(1320) int startMinuteLocal,
    @Default(420) int endMinuteLocal,

    /// IANA id, e.g. `Europe/Zurich`.
    @Default('Europe/Zurich') String timeZoneId,
  }) = _QuietHoursDto;

  factory QuietHoursDto.fromJson(Map<String, dynamic> json) =>
      _$QuietHoursDtoFromJson(json);
}

extension QuietHoursX on QuietHoursDto {
  /// True when the window crosses midnight, which is the normal shape.
  bool get wrapsMidnight => startMinuteLocal > endMinuteLocal;

  /// Whether [minuteOfDay] falls inside the window, handling the wrap.
  ///
  /// Evaluated against the *device's* local clock rather than
  /// [timeZoneId] - resolving an IANA id needs a timezone database this app
  /// doesn't ship, and for a household everyone is in the same place anyway.
  /// A member travelling sees a window that's an hour off, which is a better
  /// failure than not showing it at all.
  bool containsMinute(int minuteOfDay) {
    if (!enabled) return false;
    if (startMinuteLocal == endMinuteLocal) return false;
    return wrapsMidnight
        ? minuteOfDay >= startMinuteLocal || minuteOfDay < endMinuteLocal
        : minuteOfDay >= startMinuteLocal && minuteOfDay < endMinuteLocal;
  }

  bool isActiveNow({DateTime? now}) {
    final local = (now ?? DateTime.now()).toLocal();
    return containsMinute(local.hour * 60 + local.minute);
  }
}

/// A ledger channel a departing member isn't square in.
///
/// A move-out is **refused** while any of these exist, and that refusal is the
/// point: a leaver whose balance is never resolved makes every future
/// settle-suggestion wrong for everybody staying. Render it as a decision
/// ("Ben owes 240 CHF - settle up first, or write it off"), not an error.
@freezed
sealed class OutstandingBalanceDto with _$OutstandingBalanceDto {
  const factory OutstandingBalanceDto({
    @Default('') String channelId,
    @Default('CHF') String currency,

    /// Minor units, signed the same way [LedgerBalanceDto.netMinor] is:
    /// negative means they owe the house.
    @Default(0) int netMinor,
  }) = _OutstandingBalanceDto;

  factory OutstandingBalanceDto.fromJson(Map<String, dynamic> json) =>
      _$OutstandingBalanceDtoFromJson(json);
}

/// What a departing member left behind, and what became of it.
///
/// Their **completed** chore history is deliberately untouched - rewriting it
/// would move everyone else's fairness balance on the day a flatmate leaves.
/// Chores that named them personally are paused rather than reassigned, so the
/// house decides who picks them up; those are worth surfacing as something to
/// resolve rather than burying in a count.
@freezed
sealed class MoveOutSummaryDto with _$MoveOutSummaryDto {
  const factory MoveOutSummaryDto({
    @Default('') String userId,

    /// Unfinished turns handed to the next lightest-loaded member.
    @Default(0) int choresReassigned,

    /// Unfinished turns deleted because the rota had nobody left.
    @Default(0) int choresDropped,

    /// Chores that named them as the fixed assignee, now paused.
    @Default(0) int choresPaused,
    @Default(0) int listItemsUnassigned,

    /// The settlements recorded to zero them. Empty unless the house asked for
    /// a write-off - and a write-off doesn't pretend money moved, it's the
    /// house agreeing to stop counting the debt.
    @Default(<TransferSuggestionDto>[])
    List<TransferSuggestionDto> balancesWrittenOff,
  }) = _MoveOutSummaryDto;

  factory MoveOutSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$MoveOutSummaryDtoFromJson(json);
}

/// `1320` -> `22:00`. 24-hour, because a quiet-hours window is a schedule
/// rather than a moment and reads more precisely that way.
String formatMinuteOfDay(int minuteOfDay) {
  final hour = (minuteOfDay ~/ 60) % 24;
  final minute = minuteOfDay % 60;
  return '${hour.toString().padLeft(2, '0')}:'
      '${minute.toString().padLeft(2, '0')}';
}
