import 'package:freezed_annotation/freezed_annotation.dart';

import 'category_dto.dart';
import 'channel_dto.dart';
import 'role_dto.dart';

part 'guild_dto.freezed.dart';
part 'guild_dto.g.dart';

@freezed
sealed class GuildDto with _$GuildDto {
  const factory GuildDto({
    required String id,
    required String name,
    String? description,
    required String ownerId,
    @Default(<CategoryDto>[]) List<CategoryDto> categories,
    @Default(<ChannelDto>[]) List<ChannelDto> channels,
    @Default(<RoleDto>[]) List<RoleDto> roles,
    String? bannerUrl,
    String? systemChannelId,
  }) = _GuildDto;

  factory GuildDto.fromJson(Map<String, dynamic> json) => _$GuildDtoFromJson(json);
}
