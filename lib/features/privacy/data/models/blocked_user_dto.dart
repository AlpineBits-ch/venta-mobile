import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/format/api_date_time.dart';

part 'blocked_user_dto.freezed.dart';
part 'blocked_user_dto.g.dart';

/// One entry on `GET /relationships/blocked`.
///
/// Only ever the *blocker's* own list. Blocking is one-directional and
/// asymmetric by design - the blocked party is never told, and sees the same
/// thing they would see if you had simply never been friends - so there is no
/// "who blocked me" counterpart to this and there must never be one.
@freezed
sealed class BlockedUserDto with _$BlockedUserDto {
  @ApiDateTimeConverter()
  const factory BlockedUserDto({
    /// The **Identity** user id - the one `POST /relationships/{userId}/block`
    /// and `/profiles/by-user/{id}` take, not the Social profile id below.
    required String userId,
    required String userName,

    /// The block's own row id, and the blocked account's Social profile id.
    /// Neither is needed to unblock (that is keyed by [userId]); carried
    /// because the server sends them and a screen that wants to link to the
    /// profile shouldn't have to look one up.
    String? relationshipId,
    String? profileId,

    /// 404s when the account never uploaded one - render through `AvatarImage`,
    /// which handles that, rather than branching on null.
    String? avatarUrl,
    DateTime? blockedAt,
  }) = _BlockedUserDto;

  factory BlockedUserDto.fromJson(Map<String, dynamic> json) =>
      _$BlockedUserDtoFromJson(json);
}

/// One keyset page of the block list.
///
/// Paged, unlike every other relationship list - and the paging is real, not
/// decorative: a client that reads only the first page and treats it as the
/// whole list will tell someone with 60 blocks that the 51st isn't blocked.
class BlockedUsersPage {
  const BlockedUsersPage({required this.blocked, this.nextCursor});

  final List<BlockedUserDto> blocked;

  /// Opaque. Null or empty means this was the last page.
  final String? nextCursor;

  bool get hasMore => nextCursor != null && nextCursor!.isNotEmpty;
}
