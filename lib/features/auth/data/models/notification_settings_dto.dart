import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_settings_dto.freezed.dart';
part 'notification_settings_dto.g.dart';

/// The `notifications` object inside the opaque `users/self/settings` JSON
/// blob (`GET/PUT /api/v1/identity/users/self/settings`). The blob also
/// carries an `autostart` flag on desktop - mobile never reads or writes
/// that key, and [AccountRepository.updateNotificationSettings] re-fetches
/// and merges before saving so it's never clobbered.
@freezed
sealed class NotificationSettingsDto with _$NotificationSettingsDto {
  const factory NotificationSettingsDto({
    @Default(true) bool enabled,
    @Default(true) bool dm,
    @Default(true) bool mentions,
    @Default(true) bool sounds,
    @Default(true) bool cooldownEnabled,
    @Default(10) int cooldownSeconds,
  }) = _NotificationSettingsDto;

  factory NotificationSettingsDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationSettingsDtoFromJson(json);
}
