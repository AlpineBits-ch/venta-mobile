import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

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

/// `1320` -> `22:00`. 24-hour, because a quiet-hours window is a schedule
/// rather than a moment and reads more precisely that way.
String formatMinuteOfDay(int minuteOfDay) {
  final hour = (minuteOfDay ~/ 60) % 24;
  final minute = minuteOfDay % 60;
  return '${hour.toString().padLeft(2, '0')}:'
      '${minute.toString().padLeft(2, '0')}';
}
