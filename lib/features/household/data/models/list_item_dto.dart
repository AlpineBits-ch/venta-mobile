import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/format/api_date_time.dart';

part 'list_item_dto.freezed.dart';
part 'list_item_dto.g.dart';

/// One line on a `List` channel - the shopping list, the todo list, whatever
/// the house has pinned in the sidebar.
///
/// [quantity] is deliberately free text, not a number+unit pair: nothing
/// computes on it, and "a bunch" / "2 packs" is how people actually write a
/// shopping list. Forcing structure there makes the common case slower to
/// type for no gain.
@freezed
sealed class ListItemDto with _$ListItemDto {
  @ApiDateTimeConverter()
  const factory ListItemDto({
    required String id,
    required String channelId,
    required String text,
    String? quantity,
    String? note,

    /// Free-text grouping ("Dairy") - not an entity, just a string the client
    /// groups on.
    String? section,
    String? assigneeUserId,
    @Default('') String addedByUserId,
    @Default(false) bool isChecked,
    DateTime? checkedAt,
    String? checkedByUserId,
    @Default(0) int position,

    /// Set when the pantry's restock loop put this line here rather than a
    /// person - badged in the UI so nobody has to wonder why milk appeared.
    String? sourcePantryItemId,
    DateTime? createdAt,
  }) = _ListItemDto;

  factory ListItemDto.fromJson(Map<String, dynamic> json) =>
      _$ListItemDtoFromJson(json);
}

/// Server-enforced ceilings, mirrored client-side so the field stops you at
/// the limit instead of the request coming back `400`.
abstract final class ListLimits {
  static const maxTextLength = 200;
  static const maxItemsPerList = 500;
}
