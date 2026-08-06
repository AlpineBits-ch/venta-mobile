import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/format/api_date_time.dart';
import 'chore_dto.dart';
import 'house_dto.dart';
import 'list_item_dto.dart';
import 'pantry_dto.dart';

part 'digest_dto.freezed.dart';
part 'digest_dto.g.dart';

/// Everything a home tab or a widget needs about a house, in one request
/// instead of six.
///
/// **A null section means "render nothing".** It covers both "the module is
/// off" and "you can see no channel of that type", and the server deliberately
/// doesn't distinguish them - telling an outsider there is a ledger they can't
/// see is a disclosure for no gain. So nothing here treats null as an error or
/// as "still loading".
///
/// Everything is capped: this is a glance, and the module endpoints remain the
/// way to read a whole board.
@freezed
sealed class HouseholdDigestDto with _$HouseholdDigestDto {
  const factory HouseholdDigestDto({
    @Default('') String guildId,
    HouseholdChoresDigestDto? chores,
    List<HouseholdListDigestDto>? lists,
    HouseholdPantryDigestDto? pantry,
    List<HouseholdLedgerDigestDto>? ledger,
    HouseholdDecisionsDigestDto? decisions,

    /// The same rows `GET /home-status` returns. `HomeStatusBoard` fetches its
    /// own rather than reading these - it also needs quiet hours, and it is an
    /// editor rather than a glance - so the digest card ignores this section.
    List<HomeStatusDto>? homeStatus,
  }) = _HouseholdDigestDto;

  factory HouseholdDigestDto.fromJson(Map<String, dynamic> json) =>
      _$HouseholdDigestDtoFromJson(json);
}

@freezed
sealed class HouseholdChoresDigestDto with _$HouseholdChoresDigestDto {
  const factory HouseholdChoresDigestDto({
    /// Yours, due within a day or already past due. At most ten.
    @Default(<ChoreOccurrenceDto>[]) List<ChoreOccurrenceDto> mine,
    @Default(0) int mineOverdueCount,

    /// Everyone's, not just yours - a house that is behind is worth seeing.
    @Default(0) int houseOverdueCount,
  }) = _HouseholdChoresDigestDto;

  factory HouseholdChoresDigestDto.fromJson(Map<String, dynamic> json) =>
      _$HouseholdChoresDigestDtoFromJson(json);
}

@freezed
sealed class HouseholdListDigestDto with _$HouseholdListDigestDto {
  const factory HouseholdListDigestDto({
    @Default('') String channelId,
    @Default('') String channelName,
    @Default(0) int openCount,
    @Default(<ListItemDto>[]) List<ListItemDto> preview,
  }) = _HouseholdListDigestDto;

  factory HouseholdListDigestDto.fromJson(Map<String, dynamic> json) =>
      _$HouseholdListDigestDtoFromJson(json);
}

@freezed
sealed class HouseholdPantryDigestDto with _$HouseholdPantryDigestDto {
  const factory HouseholdPantryDigestDto({
    @Default(0) int expiringCount,
    @Default(<PantryItemDto>[]) List<PantryItemDto> soonest,
  }) = _HouseholdPantryDigestDto;

  factory HouseholdPantryDigestDto.fromJson(Map<String, dynamic> json) =>
      _$HouseholdPantryDigestDtoFromJson(json);
}

@freezed
sealed class HouseholdLedgerDigestDto with _$HouseholdLedgerDigestDto {
  const factory HouseholdLedgerDigestDto({
    @Default('') String channelId,
    @Default('') String channelName,
    @Default('CHF') String currency,

    /// **Your own position only**, in minor units. Positive means the house
    /// owes you.
    @Default(0) int myNetMinor,
  }) = _HouseholdLedgerDigestDto;

  factory HouseholdLedgerDigestDto.fromJson(Map<String, dynamic> json) =>
      _$HouseholdLedgerDigestDtoFromJson(json);
}

@freezed
sealed class HouseholdDecisionsDigestDto with _$HouseholdDecisionsDigestDto {
  const factory HouseholdDecisionsDigestDto({
    @Default(0) int openCount,
    @Default(<HouseholdDecisionDigestEntryDto>[])
    List<HouseholdDecisionDigestEntryDto> awaitingMyVote,
  }) = _HouseholdDecisionsDigestDto;

  factory HouseholdDecisionsDigestDto.fromJson(Map<String, dynamic> json) =>
      _$HouseholdDecisionsDigestDtoFromJson(json);
}

@freezed
sealed class HouseholdDecisionDigestEntryDto
    with _$HouseholdDecisionDigestEntryDto {
  @ApiDateTimeConverter()
  const factory HouseholdDecisionDigestEntryDto({
    @Default('') String id,
    @Default('') String channelId,
    @Default('') String title,
    DateTime? closesAt,
  }) = _HouseholdDecisionDigestEntryDto;

  factory HouseholdDecisionDigestEntryDto.fromJson(Map<String, dynamic> json) =>
      _$HouseholdDecisionDigestEntryDtoFromJson(json);
}

extension HouseholdDigestDtoX on HouseholdDigestDto {
  /// Whether there is anything at all to draw. Every section being null or
  /// empty is the ordinary state of a house that is on top of things, and the
  /// card renders nothing rather than an empty frame.
  bool get isEmpty =>
      (chores?.mine.isEmpty ?? true) &&
      (chores?.houseOverdueCount ?? 0) == 0 &&
      (lists?.every((l) => l.openCount == 0) ?? true) &&
      (pantry?.expiringCount ?? 0) == 0 &&
      (ledger?.every((l) => l.myNetMinor == 0) ?? true) &&
      (decisions?.awaitingMyVote.isEmpty ?? true) &&
      (decisions?.openCount ?? 0) == 0;
}
