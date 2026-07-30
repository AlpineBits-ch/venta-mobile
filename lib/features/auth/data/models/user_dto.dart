import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_dto.freezed.dart';
part 'user_dto.g.dart';

enum UserStatus {
  @JsonValue('Active')
  active,
  @JsonValue('PendingDeletion')
  pendingDeletion,
  @JsonValue('PurgeInProgress')
  purgeInProgress,
  @JsonValue('Deleted')
  deleted,
  @JsonValue('Inactive')
  inactive,
  @JsonValue('Banned')
  banned,
}

@freezed
sealed class UserDto with _$UserDto {
  const factory UserDto({
    required String id,
    required UserStatus status,
    DateTime? deletionRequestedAt,
    DateTime? purgeScheduledAt,
    // Not documented in the MFA guide's endpoint list - defaults to `false`
    // (shows the "set up 2FA" entry point) if the server omits this field
    // rather than assuming it's enabled.
    @Default(false) bool mfaEnabled,
  }) = _UserDto;

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);
}
