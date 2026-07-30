import 'identity_api.dart';
import 'models/login_session_dto.dart';
import 'models/notification_settings_dto.dart';
import 'models/user_dto.dart';

/// Account-lifecycle operations (status, deletion request/cancel) for the
/// signed-in user. Separate from [AuthRepository], which owns tokens/session
/// and never needs a bearer-authenticated [ApiClient] call.
class AccountRepository {
  AccountRepository({required this.api});

  final IdentityApi api;

  Future<UserDto> getSelf() => api.getSelf();

  Future<DateTime> requestDeletion() => api.requestDeletion();

  Future<void> cancelDeletion() => api.cancelDeletion();

  Future<int> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => api.changePassword(
    currentPassword: currentPassword,
    newPassword: newPassword,
  );

  Future<void> signOutOtherDevices() => api.signOutOtherDevices();

  Future<List<LoginSessionDto>> listSessions() => api.listSessions();

  Future<void> revokeSession(String id) => api.revokeSession(id);

  Future<NotificationSettingsDto> getNotificationSettings() async {
    final raw = await api.getSettings();
    final notifications = raw['notifications'];
    return NotificationSettingsDto.fromJson(
      notifications is Map<String, dynamic> ? notifications : const {},
    );
  }

  /// Re-fetches the full settings blob and only replaces the `notifications`
  /// key before saving, so an `autostart` flag set from desktop (or any
  /// other key mobile doesn't know about) is never clobbered.
  Future<void> updateNotificationSettings(
    NotificationSettingsDto settings,
  ) async {
    final raw = await api.getSettings();
    raw['notifications'] = settings.toJson();
    await api.updateSettings(raw);
  }
}
