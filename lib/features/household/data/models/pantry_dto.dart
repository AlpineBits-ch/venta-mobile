import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/format/api_date_time.dart';

part 'pantry_dto.freezed.dart';
part 'pantry_dto.g.dart';

/// Stock in one pantry location (a `Pantry` channel is a fridge, a freezer, a
/// cellar - one channel per place).
///
/// [quantity] is decimal here, unlike a list item's free-text quantity: it's
/// compared against [lowThreshold] to drive the restock loop.
@freezed
sealed class PantryItemDto with _$PantryItemDto {
  @ApiDateTimeConverter()
  const factory PantryItemDto({
    required String id,
    required String channelId,
    required String name,
    @Default(0) double quantity,
    String? unit,

    /// `null` turns restock tracking off for this item specifically.
    double? lowThreshold,
    DateTime? expiresAt,
    @Default(false) bool isLow,

    /// Non-null while this item is sitting on the shopping list. It's the
    /// idempotency guard for the restock loop, not a timestamp anyone needs
    /// to read - released when the quantity climbs back above the threshold
    /// or the list line is bought/cleared.
    DateTime? restockedAt,
    @Default('') String addedByUserId,
  }) = _PantryItemDto;

  factory PantryItemDto.fromJson(Map<String, dynamic> json) =>
      _$PantryItemDtoFromJson(json);
}

extension PantryItemX on PantryItemDto {
  /// On the shopping list right now, because the pantry put it there.
  bool get isAwaitingRestock => restockedAt != null;

  /// Expiring within [days], or already gone off.
  bool isExpiringWithin(int days, {DateTime? now}) {
    final expiry = expiresAt;
    if (expiry == null) return false;
    final reference = now ?? DateTime.now();
    return expiry.toLocal().isBefore(reference.add(Duration(days: days)));
  }

  bool isExpired({DateTime? now}) =>
      expiresAt != null && expiresAt!.toLocal().isBefore(now ?? DateTime.now());
}

/// Per-channel pantry settings.
///
/// With [restockListChannelId] null the whole restock loop is off, whatever
/// individual item thresholds say - worth saying out loud in the UI, because
/// setting a threshold and seeing nothing happen is otherwise a mystery.
@freezed
sealed class PantryConfigDto with _$PantryConfigDto {
  const factory PantryConfigDto({
    @Default('') String channelId,

    /// Must be a `List` channel in the same guild.
    String? restockListChannelId,

    /// 1-90.
    @Default(3) int expiryWarningDays,
  }) = _PantryConfigDto;

  factory PantryConfigDto.fromJson(Map<String, dynamic> json) =>
      _$PantryConfigDtoFromJson(json);
}
