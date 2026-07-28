import 'package:freezed_annotation/freezed_annotation.dart';

import 'guild_dto.dart';

part 'invite_dto.freezed.dart';
part 'invite_dto.g.dart';

enum InviteType {
  @JsonValue('OneTime')
  oneTime,
  @JsonValue('Permanent')
  permanent,
}

enum InviteState {
  @JsonValue('Active')
  active,
  @JsonValue('Expired')
  expired,
}

@freezed
sealed class InviteDto with _$InviteDto {
  const factory InviteDto({
    required String id,
    required InviteType type,
    required InviteState state,
    required String guildId,
    GuildDto? guild,
    required String code,
    String? expiresAt,
    int? maxUses,
    @Default(0) int useCount,
  }) = _InviteDto;

  factory InviteDto.fromJson(Map<String, dynamic> json) => _$InviteDtoFromJson(json);
}
