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
  }) = _UserDto;

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);
}
