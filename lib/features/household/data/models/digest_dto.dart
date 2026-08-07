import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/format/api_date_time.dart';
import 'bill_dto.dart';
import 'chore_dto.dart';
import 'house_dto.dart';
import 'list_item_dto.dart';
import 'maintenance_dto.dart';
import 'meal_dto.dart';
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

    /// What the house owes and when, from the ledger channels the caller can
    /// see.
    HouseholdBillsDigestDto? bills,
    HouseholdMealsDigestDto? meals,
    HouseholdMaintenanceDigestDto? maintenance,

    /// Who is away right now, and until when.
    ///
    /// Beside [homeStatus] and deliberately not folded into it. Home status is
    /// a decaying assertion about this minute; an absence is a dated plan the
    /// rota reads. Merging them would give a fortnight in Lisbon an expiry it
    /// does not have, or "back in an hour" a permanence it must not have.
    List<HouseholdAbsenceDigestDto>? away,
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

/// Bills the house owes, from every ledger channel the caller can see.
@freezed
sealed class HouseholdBillsDigestDto with _$HouseholdBillsDigestDto {
  const factory HouseholdBillsDigestDto({
    /// Pending bills due inside the next fortnight, soonest first, with
    /// anything already late at the top - an overdue bill is still a bill that
    /// is due, and pulling it out to count separately would leave the most
    /// urgent row off the glance.
    @Default(<HouseholdBillDigestEntryDto>[])
    List<HouseholdBillDigestEntryDto> dueSoon,
    @Default(0) int overdueCount,

    /// Variable bills that came due with nobody having said what they cost.
    /// Counted apart from [overdueCount] because the action is different: one
    /// needs money moved, the other needs somebody to open the post.
    @Default(0) int needsAmountCount,
  }) = _HouseholdBillsDigestDto;

  factory HouseholdBillsDigestDto.fromJson(Map<String, dynamic> json) =>
      _$HouseholdBillsDigestDtoFromJson(json);
}

@freezed
sealed class HouseholdBillDigestEntryDto with _$HouseholdBillDigestEntryDto {
  @ApiDateTimeConverter()
  const factory HouseholdBillDigestEntryDto({
    @Default('') String id,
    @Default('') String channelId,
    @Default('') String description,
    DateTime? dueAt,
    int? amountMinor,
    @Default('CHF') String currency,

    /// What this period costs the caller specifically. Null when there is no
    /// total to divide yet, and also when the split no longer resolves - a
    /// wrong share is worse than a missing one, because it is the number
    /// somebody transfers.
    int? myShareMinor,
    @Default(BillStatus.pending)
    @JsonKey(unknownEnumValue: BillStatus.pending)
    BillStatus status,
  }) = _HouseholdBillDigestEntryDto;

  factory HouseholdBillDigestEntryDto.fromJson(Map<String, dynamic> json) =>
      _$HouseholdBillDigestEntryDtoFromJson(json);
}

@freezed
sealed class HouseholdMealsDigestDto with _$HouseholdMealsDigestDto {
  const factory HouseholdMealsDigestDto({
    @Default(<HouseholdMealDigestEntryDto>[])
    List<HouseholdMealDigestEntryDto> today,

    /// Computed over the whole day rather than over the capped [today] list, so
    /// a busy day cannot quietly answer "no" for somebody who is in fact
    /// cooking.
    @Default(false) bool imCookingToday,
  }) = _HouseholdMealsDigestDto;

  factory HouseholdMealsDigestDto.fromJson(Map<String, dynamic> json) =>
      _$HouseholdMealsDigestDtoFromJson(json);
}

@freezed
sealed class HouseholdMealDigestEntryDto with _$HouseholdMealDigestEntryDto {
  const factory HouseholdMealDigestEntryDto({
    @Default('') String id,
    @Default('') String channelId,
    @Default(MealSlot.dinner)
    @JsonKey(unknownEnumValue: MealSlot.dinner)
    MealSlot slot,

    /// The recipe's title or the entry's free text, flattened - a glance
    /// renders one line either way, and most of a real week is "leftovers".
    @Default('') String title,
    String? cookUserId,
  }) = _HouseholdMealDigestEntryDto;

  factory HouseholdMealDigestEntryDto.fromJson(Map<String, dynamic> json) =>
      _$HouseholdMealDigestEntryDtoFromJson(json);
}

@freezed
sealed class HouseholdMaintenanceDigestDto
    with _$HouseholdMaintenanceDigestDto {
  const factory HouseholdMaintenanceDigestDto({
    @Default(0) int brokenCount,
    @Default(0) int serviceOverdueCount,

    /// Warranties lapsing soon. Already-lapsed ones are not counted - there is
    /// nothing left to do about them.
    @Default(0) int warrantyExpiringCount,
    @Default(<HouseholdAssetDigestEntryDto>[])
    List<HouseholdAssetDigestEntryDto> attention,
  }) = _HouseholdMaintenanceDigestDto;

  factory HouseholdMaintenanceDigestDto.fromJson(Map<String, dynamic> json) =>
      _$HouseholdMaintenanceDigestDtoFromJson(json);
}

@freezed
sealed class HouseholdAssetDigestEntryDto with _$HouseholdAssetDigestEntryDto {
  const factory HouseholdAssetDigestEntryDto({
    @Default('') String id,
    @Default('') String channelId,
    @Default('') String name,
    @Default(AssetStatus.ok)
    @JsonKey(unknownEnumValue: AssetStatus.ok)
    AssetStatus status,

    /// The single most urgent of the attention board's tokens. One where the
    /// board carries all of them: a board has room to say a machine is both
    /// broken and out of warranty, a glance has room for the word that decides
    /// whether anybody gets up.
    @Default('') String reason,
  }) = _HouseholdAssetDigestEntryDto;

  factory HouseholdAssetDigestEntryDto.fromJson(Map<String, dynamic> json) =>
      _$HouseholdAssetDigestEntryDtoFromJson(json);
}

@freezed
sealed class HouseholdAbsenceDigestDto with _$HouseholdAbsenceDigestDto {
  @ApiDateTimeConverter()
  const factory HouseholdAbsenceDigestDto({
    @Default('') String userId,
    DateTime? startAt,
    DateTime? endAt,
    String? note,
  }) = _HouseholdAbsenceDigestDto;

  factory HouseholdAbsenceDigestDto.fromJson(Map<String, dynamic> json) =>
      _$HouseholdAbsenceDigestDtoFromJson(json);
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
      (decisions?.openCount ?? 0) == 0 &&
      (bills?.dueSoon.isEmpty ?? true) &&
      (bills?.needsAmountCount ?? 0) == 0 &&
      (meals?.today.isEmpty ?? true) &&
      (maintenance?.attention.isEmpty ?? true) &&
      (away?.isEmpty ?? true);
}
