import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/format/api_date_time.dart';
import '../../../privacy/data/models/legal_document_dto.dart';

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
  @ApiDateTimeConverter()
  const factory UserDto({
    required String id,
    required UserStatus status,
    DateTime? deletionRequestedAt,
    DateTime? purgeScheduledAt,
    // Not documented in the MFA guide's endpoint list - defaults to `false`
    // (shows the "set up 2FA" entry point) if the server omits this field
    // rather than assuming it's enabled.
    @Default(false) bool mfaEnabled,

    /// Legal documents whose current version this account has not accepted,
    /// each with the version, when it takes effect and where to read it.
    ///
    /// Always present and never null server-side; `[]` is the normal case and
    /// means nothing to prompt for - as does the absent field on a backend that
    /// predates versioned consent. Registration records consent for the
    /// then-current versions, so a non-empty list only happens on a version
    /// bump. See `LegalDocumentsScreen`.
    @Default(<ConsentRequirementDto>[])
    List<ConsentRequirementDto> consentRequired,
  }) = _UserDto;

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);
}
