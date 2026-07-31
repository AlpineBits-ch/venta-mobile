import 'package:dio/dio.dart';

import '../../../core/format/api_date_time.dart';
import '../../../core/network/api_client.dart';
import 'models/login_session_dto.dart';
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

/// The device waiting behind a scanned QR login code - what the confirmation
/// screen names so the user can recognise (or fail to recognise) it.
class QrLoginTarget {
  const QrLoginTarget({required this.deviceName, required this.deviceType});

  factory QrLoginTarget.fromJson(Map<String, dynamic> json) => QrLoginTarget(
    deviceName: json['deviceName'] as String? ?? 'Unknown device',
    deviceType: json['deviceType'] as String? ?? '',
  );

  /// e.g. `Chrome on Windows`.
  final String deviceName;

  /// e.g. `Web`, `Desktop`, `Mobile` - only used to pick an icon.
  final String deviceType;
}

/// Thrown by [IdentityApi.scanQrLogin] and [IdentityApi.respondToQrLogin] on a
/// `404`. Expired, never existed, and already-decided-by-someone-else all come
/// back the same way, and are deliberately shown the same way - distinguishing
/// them would report on codes the scanner doesn't own.
class QrLoginCodeInvalidException implements Exception {
  const QrLoginCodeInvalidException();
}

/// Thrown by [IdentityApi.respondToQrLogin] on a `403` - only the session that
/// called `/scan` may decide that code, so this means the account changed
/// between scanning and tapping Approve.
class QrLoginNotYoursException implements Exception {
  const QrLoginNotYoursException();
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

  String get _qrLoginBase => client.url('/api/v1/identity/qr-login');

  String get _sessionsBase => client.url('/api/v1/identity/sessions');

  Future<UserDto> getSelf() async {
    final response = await client.dio.get<Map<String, dynamic>>(_base);
    return UserDto.fromJson(response.data!);
  }

  /// Requests deletion of the current account. Returns the purge date -
  /// deletion is cancellable via [cancelDeletion] until that point.
  Future<DateTime> requestDeletion() async {
    final response = await client.dio.delete<Map<String, dynamic>>(_base);
    return parseApiDateTime(response.data!['purgeScheduledAt'] as String);
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
      '$_sessionsBase/revoke-others',
      data: {'withinSeconds': 3600},
    );
  }

  /// Every login on this account, one entry per session, including this app's
  /// own (`isCurrent`).
  Future<List<LoginSessionDto>> listSessions() async {
    final response = await client.dio.get<List<dynamic>>(_sessionsBase);
    return (response.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(LoginSessionDto.fromJson)
        .toList();
  }

  /// Stops [id] from refreshing its access token.
  ///
  /// Not instantaneous for the revoked device: whatever access token it
  /// already holds keeps working until it expires on its own (up to ~an hour).
  /// That's inherent to stateless access tokens, so the UI has to say so
  /// rather than claim the device was signed out on the spot.
  Future<void> revokeSession(String id) async {
    await client.dio.delete<void>('$_sessionsBase/$id');
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

  /// Claims a QR login code shown on another device and returns which device
  /// it belongs to. Claiming is not approving - nothing happens to that device
  /// until [respondToQrLogin] says so.
  ///
  /// [code] is the QR payload verbatim: an opaque string, not a URI or JSON.
  Future<QrLoginTarget> scanQrLogin(String code) async {
    try {
      final response = await client.dio.post<Map<String, dynamic>>(
        '$_qrLoginBase/scan',
        data: {'code': code},
      );
      return QrLoginTarget.fromJson(response.data ?? const {});
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const QrLoginCodeInvalidException();
      }
      rethrow;
    }
  }

  /// Approves or denies a code already claimed via [scanQrLogin]. The other
  /// device redeems its own tokens afterwards - nothing about this phone's
  /// session travels through here, and this phone stays signed in either way.
  ///
  /// Must land inside the ~3-minute window the code was generated in; past
  /// that the desktop side treats it as expired whatever this returns.
  Future<void> respondToQrLogin({
    required String code,
    required bool approve,
  }) async {
    try {
      await client.dio.post<void>(
        '$_qrLoginBase/approve',
        data: {'code': code, 'approve': approve},
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const QrLoginCodeInvalidException();
      }
      if (e.response?.statusCode == 403) {
        throw const QrLoginNotYoursException();
      }
      rethrow;
    }
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
