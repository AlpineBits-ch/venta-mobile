import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import 'models/user_dto.dart';

/// Thrown by [IdentityApi.cancelDeletion] on a 409 - the purge has already
/// started (`PurgeInProgress`), so cancellation is no longer possible.
class DeletionNotCancellableException implements Exception {
  DeletionNotCancellableException(this.message);

  final String message;
}

/// Thrown by [IdentityApi.enableMfa]/[disableMfa]/[regenerateRecoveryCodes]
/// on a `400 Bad Request` - wrong TOTP code or wrong account password,
/// depending on which call. [message] is already user-facing.
class MfaActionFailedException implements Exception {
  MfaActionFailedException(this.message);

  final String message;
}

class MfaEnrollment {
  const MfaEnrollment({required this.secret, required this.otpAuthUri});

  factory MfaEnrollment.fromJson(Map<String, dynamic> json) => MfaEnrollment(
    secret: json['secret'] as String,
    otpAuthUri: json['otpAuthUri'] as String,
  );

  final String secret;
  final String otpAuthUri;
}

class IdentityApi {
  IdentityApi({required this.client});

  final ApiClient client;

  String get _base => client.url('/api/v1/identity/users/self');

  /// Deliberately `/user/` (singular), not `/users/self/` like [_base] -
  /// matches the MFA guide's endpoints exactly, one of this API's several
  /// pre-existing singular/plural routing quirks.
  String get _mfaBase => client.url('/api/v1/identity/user/mfa');

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

  /// Re-callable before [enableMfa] succeeds - the server just re-returns
  /// the same pending secret rather than generating a new one.
  Future<MfaEnrollment> enrollMfa() async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '$_mfaBase/enroll',
    );
    return MfaEnrollment.fromJson(response.data!);
  }

  /// Returns the eight one-time recovery codes - shown exactly once, the
  /// server has no "view again" endpoint.
  Future<List<String>> enableMfa(String code) async {
    try {
      final response = await client.dio.post<Map<String, dynamic>>(
        '$_mfaBase/enable',
        data: {'code': code},
      );
      return (response.data!['recoveryCodes'] as List).cast<String>();
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw MfaActionFailedException('Invalid code.');
      }
      rethrow;
    }
  }

  Future<void> disableMfa(String password) async {
    try {
      await client.dio.post<void>(
        '$_mfaBase/disable',
        data: {'password': password},
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw MfaActionFailedException('Incorrect password.');
      }
      rethrow;
    }
  }

  /// Invalidates every previously issued code the moment this succeeds.
  Future<List<String>> regenerateRecoveryCodes(String password) async {
    try {
      final response = await client.dio.post<Map<String, dynamic>>(
        '$_mfaBase/recovery-codes',
        data: {'password': password},
      );
      return (response.data!['recoveryCodes'] as List).cast<String>();
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw MfaActionFailedException('Incorrect password.');
      }
      rethrow;
    }
  }
}
