import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/format/api_date_time.dart';

part 'absence_dto.freezed.dart';
part 'absence_dto.g.dart';

/// A dated plan to be away.
///
/// **Not home status**, and the two must stay visually distinct. Home status is
/// a decaying assertion about this minute - somebody who never clears "Out"
/// stops claiming to be out by Thursday, on purpose. An absence is a plan with
/// a start and an end that the rota reads to decide whose turn it is, and it is
/// still true while nobody is looking at it.
///
/// You can only ever create your own. `ManageGuild` can amend or delete
/// somebody else's but **cannot invent one**: declaring an absence moves that
/// person's chores off them, and doing that on their behalf without their
/// knowing is how somebody comes home to a rota they never agreed to.
@freezed
sealed class AbsenceDto with _$AbsenceDto {
  @ApiDateTimeConverter()
  const factory AbsenceDto({
    required String id,
    @Default('') String guildId,
    @Default('') String userId,
    required DateTime startAt,
    required DateTime endAt,

    /// Optional, and usually where it is: "Lisbon", "at my parents'".
    String? note,
    @Default('') String createdByUserId,
    DateTime? createdAt,
  }) = _AbsenceDto;

  factory AbsenceDto.fromJson(Map<String, dynamic> json) =>
      _$AbsenceDtoFromJson(json);
}

extension AbsenceX on AbsenceDto {
  bool isLive({DateTime? now}) {
    final at = (now ?? DateTime.now()).toUtc();
    return !startAt.toUtc().isAfter(at) && endAt.toUtc().isAfter(at);
  }

  bool isPast({DateTime? now}) =>
      !endAt.toUtc().isAfter((now ?? DateTime.now()).toUtc());

  /// Inclusive of both ends, the way a person counts nights away.
  int get days {
    final start = startAt.toLocal();
    final end = endAt.toLocal();
    final whole = DateTime(
      end.year,
      end.month,
      end.day,
    ).difference(DateTime(start.year, start.month, start.day)).inDays;
    return whole + 1;
  }
}

/// What declaring or amending an absence actually did to everyone else's board.
///
/// [choresReassigned] is reported because the write has a side effect on other
/// people: turns inside the window are handed to whoever is lightest-loaded and
/// still here. Saying "3 chores were handed over" turns a silent consequence
/// into something the member can check before they get on the plane.
///
/// Shortening or deleting an absence does **not** claw those turns back, and
/// the confirm copy has to say so, because everybody expects otherwise.
@freezed
sealed class AbsenceSavedDto with _$AbsenceSavedDto {
  const factory AbsenceSavedDto({
    required AbsenceDto absence,
    @Default(0) int choresReassigned,
  }) = _AbsenceSavedDto;

  factory AbsenceSavedDto.fromJson(Map<String, dynamic> json) =>
      _$AbsenceSavedDtoFromJson(json);
}
