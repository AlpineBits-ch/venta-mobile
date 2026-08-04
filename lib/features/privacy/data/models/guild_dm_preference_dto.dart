import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/format/api_date_time.dart';

part 'guild_dm_preference_dto.freezed.dart';
part 'guild_dm_preference_dto.g.dart';

/// A per-guild override of the account's DM policy.
///
/// Only meaningful while the global policy is
/// `DirectMessagePolicy.friendsAndServerMembers` - that is the one branch that
/// consults shared servers at all. Under `Friends` or `Nobody` nothing here can
/// widen anything, and under `Everyone` nothing here can narrow anything;
/// `GuildDmPrivacyScreen` says so rather than rendering switches that quietly
/// do nothing.
///
/// The server only stores rows that differ from the global default, so a guild
/// missing from `GET /users/me/guild-privacy` is not an error - it is a guild
/// with no override.
@freezed
sealed class GuildDmPreferenceDto with _$GuildDmPreferenceDto {
  @ApiDateTimeConverter()
  const factory GuildDmPreferenceDto({
    required String guildId,
    required bool allowDirectMessages,

    /// True for every row the endpoint returns - it only returns overrides.
    /// Carried rather than assumed so a future shape that also lists inherited
    /// guilds doesn't silently turn them all into overrides here.
    @Default(true) bool isOverride,
    DateTime? updatedAt,
  }) = _GuildDmPreferenceDto;

  factory GuildDmPreferenceDto.fromJson(Map<String, dynamic> json) =>
      _$GuildDmPreferenceDtoFromJson(json);
}

/// Thrown by `PrivacyApi.setGuildDmPreference` on the `404` that means the
/// account is not in that guild any more - the switch was rendered from a
/// cached guild list that has since gone stale.
class GuildMembershipGoneException implements Exception {
  const GuildMembershipGoneException();
}
