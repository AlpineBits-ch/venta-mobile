import 'package:freezed_annotation/freezed_annotation.dart';

part 'guild_emoji_dto.freezed.dart';
part 'guild_emoji_dto.g.dart';

/// A guild's custom emoji, usable as a message reaction in that guild's
/// channels (not DMs - custom emoji are guild-owned data with no meaning
/// outside their guild). No inline `:name:` rendering in message content in
/// this pass, reactions only.
@freezed
sealed class GuildEmojiDto with _$GuildEmojiDto {
  const factory GuildEmojiDto({
    required String id,
    required String guildId,
    required String name,
    @Default(false) bool animated,
    required String createdByUserId,
    DateTime? createdAt,

    /// Presigned, expires ~1h - refetch the list rather than caching this
    /// URL long-term.
    required String imageUrl,
  }) = _GuildEmojiDto;

  factory GuildEmojiDto.fromJson(Map<String, dynamic> json) =>
      _$GuildEmojiDtoFromJson(json);
}
