import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/format/api_date_time.dart';
import 'inbox_breadcrumb_dto.dart';
import 'inbox_message_dto.dart';

part 'inbox_unread_dto.freezed.dart';
part 'inbox_unread_dto.g.dart';

/// One channel with messages newer than the caller's read cursor.
///
/// The two counts are different qualities and are rendered differently:
/// [mentionCount] is exact and gets the red badge, [unreadCount] is derived
/// from denormalised counters that drift under message loss and is display-only
/// (it is clamped at zero server-side, so it is never negative - just
/// occasionally optimistic).
@freezed
sealed class InboxUnreadGroupDto with _$InboxUnreadGroupDto {
  @ApiDateTimeConverter()
  const factory InboxUnreadGroupDto({
    @Default(InboxBreadcrumbDto()) InboxBreadcrumbDto breadcrumb,

    /// What the list is ordered by. Ids are not - they only sort by creation
    /// time if they were minted after the ULID change, so nothing anywhere in
    /// this feature compares two ids to work out which is newer.
    DateTime? lastActivityAt,

    /// Best-effort. See the class comment.
    @Default(0) int unreadCount,

    /// Exact.
    @Default(0) int mentionCount,

    /// Oldest first, at most five.
    @Default(<InboxMessageDto>[]) List<InboxMessageDto> previews,

    /// Whether there are unread messages above [previews]' oldest entry.
    @Default(false) bool previewsTruncated,
  }) = _InboxUnreadGroupDto;

  factory InboxUnreadGroupDto.fromJson(Map<String, dynamic> json) =>
      _$InboxUnreadGroupDtoFromJson(json);
}

/// One keyset page of [InboxUnreadGroupDto]s.
///
/// [nextCursor] is opaque - pass it back verbatim, never parse or persist it.
/// A cursor the server doesn't recognise is treated as the first page rather
/// than rejected, so a stale one degrades instead of breaking.
@freezed
sealed class InboxUnreadPageDto with _$InboxUnreadPageDto {
  const factory InboxUnreadPageDto({
    @Default(<InboxUnreadGroupDto>[]) List<InboxUnreadGroupDto> groups,
    String? nextCursor,

    /// The message service could not be reached. **The groups, counts and
    /// breadcrumbs are still correct** - they come from a different service -
    /// so this is a `200` to render without bodies, not an error. Retrying the
    /// same request is reasonable, and `InboxCubit` does exactly that in the
    /// background.
    @Default(false) bool previewsUnavailable,
  }) = _InboxUnreadPageDto;

  factory InboxUnreadPageDto.fromJson(Map<String, dynamic> json) =>
      _$InboxUnreadPageDtoFromJson(json);
}
