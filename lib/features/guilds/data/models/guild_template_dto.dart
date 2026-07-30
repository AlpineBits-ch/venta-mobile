import 'package:freezed_annotation/freezed_annotation.dart';

part 'guild_template_dto.freezed.dart';
part 'guild_template_dto.g.dart';

/// Returned by `POST .../templates` (create) - the lightweight shape, no
/// snapshot payload.
@freezed
sealed class GuildTemplateDto with _$GuildTemplateDto {
  const factory GuildTemplateDto({
    required String id,
    required String name,
    String? description,
    required DateTime createdAt,
  }) = _GuildTemplateDto;

  factory GuildTemplateDto.fromJson(Map<String, dynamic> json) =>
      _$GuildTemplateDtoFromJson(json);
}

@freezed
sealed class TemplateChannelDto with _$TemplateChannelDto {
  const factory TemplateChannelDto({
    required String name,
    required String type,
    String? description,
    @Default(0) int position,
  }) = _TemplateChannelDto;

  factory TemplateChannelDto.fromJson(Map<String, dynamic> json) =>
      _$TemplateChannelDtoFromJson(json);
}

@freezed
sealed class TemplateCategoryDto with _$TemplateCategoryDto {
  const factory TemplateCategoryDto({
    required String name,
    @Default(0) int position,
    @Default([]) List<TemplateChannelDto> channels,
  }) = _TemplateCategoryDto;

  factory TemplateCategoryDto.fromJson(Map<String, dynamic> json) =>
      _$TemplateCategoryDtoFromJson(json);
}

/// `permissions` travels as a raw numeric bitmask here - unlike the rest of
/// the API's comma-separated `[Flags]` string format, per the template
/// guide's own shape (`GuildTemplate.snapshot.roles[].permissions: number`).
/// Not parsed through [GuildPermissions.parse] for that reason.
@freezed
sealed class TemplateRoleDto with _$TemplateRoleDto {
  const factory TemplateRoleDto({
    required String name,
    required String color,
    @Default(0) int position,
    @Default(0) int permissions,
  }) = _TemplateRoleDto;

  factory TemplateRoleDto.fromJson(Map<String, dynamic> json) =>
      _$TemplateRoleDtoFromJson(json);
}

@freezed
sealed class TemplateSnapshotDto with _$TemplateSnapshotDto {
  const factory TemplateSnapshotDto({
    @Default([]) List<TemplateRoleDto> roles,
    @Default([]) List<TemplateCategoryDto> categories,
    @Default([]) List<TemplateChannelDto> uncategorizedChannels,
  }) = _TemplateSnapshotDto;

  factory TemplateSnapshotDto.fromJson(Map<String, dynamic> json) =>
      _$TemplateSnapshotDtoFromJson(json);
}

/// Full `GET /templates/{id}` response - structure only, no permission
/// overwrites/member data/messages captured (matches Discord's own template
/// scope).
@freezed
sealed class GuildTemplateDetailDto with _$GuildTemplateDetailDto {
  const factory GuildTemplateDetailDto({
    required String id,
    required String name,
    String? description,
    required String creatorUserId,
    required DateTime createdAt,
    @Default(0) int usageCount,
    required TemplateSnapshotDto snapshot,
  }) = _GuildTemplateDetailDto;

  factory GuildTemplateDetailDto.fromJson(Map<String, dynamic> json) =>
      _$GuildTemplateDetailDtoFromJson(json);
}
