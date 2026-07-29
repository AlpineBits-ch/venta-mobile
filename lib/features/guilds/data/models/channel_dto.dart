import 'package:freezed_annotation/freezed_annotation.dart';

import 'guild_permissions.dart';

part 'channel_dto.freezed.dart';
part 'channel_dto.g.dart';

enum ChannelType {
  @JsonValue('Text')
  text,
  @JsonValue('Voice')
  voice,
  @JsonValue('Thread')
  thread,
  @JsonValue('Announcement')
  announcement,
}

@freezed
sealed class ChannelPermissionDto with _$ChannelPermissionDto {
  const factory ChannelPermissionDto({
    required String id,
    String? channelId,
    String? roleId,
    String? memberId,
    String? categoryId,
    required String allowPermissions,
    required String denyPermissions,
  }) = _ChannelPermissionDto;

  factory ChannelPermissionDto.fromJson(Map<String, dynamic> json) =>
      _$ChannelPermissionDtoFromJson(json);
}

extension ChannelPermissionDtoX on ChannelPermissionDto {
  GuildPermissions get allow => GuildPermissions.parse(allowPermissions);
  GuildPermissions get deny => GuildPermissions.parse(denyPermissions);
}

@freezed
sealed class ChannelDto with _$ChannelDto {
  const factory ChannelDto({
    required String id,
    required String name,
    String? description,
    @JsonKey(unknownEnumValue: ChannelType.text) required ChannelType type,
    required String guildId,
    @Default(false) bool isAgeRestricted,
    @Default(false) bool isPrivate,
    String? categoryId,
    @Default(<ChannelPermissionDto>[]) List<ChannelPermissionDto> permissions,
    @Default(0) int position,
    @Default(0) int slowModeSeconds,
    String? parentChannelId,
  }) = _ChannelDto;

  factory ChannelDto.fromJson(Map<String, dynamic> json) =>
      _$ChannelDtoFromJson(json);
}
