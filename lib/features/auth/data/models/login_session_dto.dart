import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/format/api_date_time.dart';

part 'login_session_dto.freezed.dart';
part 'login_session_dto.g.dart';

/// One row of `GET /api/v1/identity/sessions` - a login on this account,
/// whatever created it (password, Steam, or a QR pairing approved from a
/// phone).
///
/// Everything but [id] is nullable on purpose: these strings are recorded from
/// whatever the client sent at login time, and a session created by an older
/// or third-party client can be missing any of them. The list renders
/// fallbacks rather than failing to parse the whole page over one blank field.
@freezed
sealed class LoginSessionDto with _$LoginSessionDto {
  @ApiDateTimeConverter()
  const factory LoginSessionDto({
    required String id,
    String? deviceName,

    /// `Desktop`, `Mobile` or `Web` - only used to pick an icon.
    String? deviceType,
    String? ipAddress,
    DateTime? createdAt,
    DateTime? lastUsedAt,

    /// The session this app is signed in with. It has no revoke button - use
    /// Log Out for that.
    @Default(false) bool isCurrent,
  }) = _LoginSessionDto;

  factory LoginSessionDto.fromJson(Map<String, dynamic> json) =>
      _$LoginSessionDtoFromJson(json);
}
