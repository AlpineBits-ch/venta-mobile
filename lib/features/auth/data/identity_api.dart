import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import 'models/user_dto.dart';

/// Thrown by [IdentityApi.cancelDeletion] on a 409 - the purge has already
/// started (`PurgeInProgress`), so cancellation is no longer possible.
class DeletionNotCancellableException implements Exception {
  DeletionNotCancellableException(this.message);

  final String message;
}

class IdentityApi {
  IdentityApi({required this.client});

  final ApiClient client;

  String get _base => client.url('/api/v1/identity/users/self');

  Future<UserDto> getSelf() async {
    final response = await client.dio.get<Map<String, dynamic>>(_base);
    return UserDto.fromJson(response.data!);
  }

  /// Requests deletion of the current account. Returns the purge date -
  /// deletion is cancellable via [cancelDeletion] until that point.
  Future<DateTime> requestDeletion() async {
    final response = await client.dio.delete<Map<String, dynamic>>(_base);
    return DateTime.parse(response.data!['purgeScheduledAt'] as String);
  }

  Future<void> cancelDeletion() async {
    try {
      await client.dio.post<void>('$_base/cancel-deletion');
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw DeletionNotCancellableException(
          e.response?.data is String
              ? e.response!.data as String
              : 'Account is not pending deletion, or the purge has already started.',
        );
      }
      rethrow;
    }
  }

  /// Returns the HTTP status code rather than throwing on 4xx - the caller
  /// turns the code into a message (401 wrong password, 422/400 too weak,
  /// 429 rate-limited), matching Alpine's `{code}` contract exactly.
  Future<int> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await client.dio.put<void>(
        '$_base/password',
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );
      return response.statusCode ?? 200;
    } on DioException catch (e) {
      return e.response?.statusCode ?? 500;
    }
  }

  Future<void> signOutOtherDevices() async {
    await client.dio.post<void>(
      client.url('/api/v1/identity/sessions/revoke-others'),
      data: {'withinSeconds': 3600},
    );
  }

  /// The opaque user-settings JSON blob (`{notifications: {...}, autostart}`
  /// on desktop) - mobile only ever reads/writes the `notifications` key,
  /// see [AccountRepository.updateNotificationSettings].
  Future<Map<String, dynamic>> getSettings() async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '$_base/settings',
    );
    return response.data ?? <String, dynamic>{};
  }

  Future<void> updateSettings(Map<String, dynamic> settings) async {
    await client.dio.put<void>('$_base/settings', data: settings);
  }
}
