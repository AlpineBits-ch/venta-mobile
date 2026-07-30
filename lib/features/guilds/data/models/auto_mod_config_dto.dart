import 'package:freezed_annotation/freezed_annotation.dart';

part 'auto_mod_config_dto.freezed.dart';
part 'auto_mod_config_dto.g.dart';

/// A guild's blocked-word filter + message-rate limit. `PUT` fully replaces
/// this (not a partial patch) - always send the complete object back, same
/// convention the backend guide calls out explicitly.
@freezed
sealed class AutoModConfigDto with _$AutoModConfigDto {
  const factory AutoModConfigDto({
    @Default(false) bool enabled,
    @Default([]) List<String> blockedWords,
    int? maxMessagesPerInterval,
    int? intervalSeconds,
  }) = _AutoModConfigDto;

  factory AutoModConfigDto.fromJson(Map<String, dynamic> json) =>
      _$AutoModConfigDtoFromJson(json);
}
