import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/format/api_date_time.dart';

part 'legal_document_dto.freezed.dart';
part 'legal_document_dto.g.dart';

enum LegalDocumentType {
  @JsonValue('Terms')
  terms,
  @JsonValue('Privacy')
  privacy,
  @JsonValue('Cookies')
  cookies,
}

extension LegalDocumentTypeX on LegalDocumentType {
  String get label => switch (this) {
    LegalDocumentType.terms => 'Terms of Service',
    LegalDocumentType.privacy => 'Privacy Policy',
    LegalDocumentType.cookies => 'Cookie Policy',
  };

  /// The wire form, for `POST /legal/consents`.
  String get wireValue => switch (this) {
    LegalDocumentType.terms => 'Terms',
    LegalDocumentType.privacy => 'Privacy',
    LegalDocumentType.cookies => 'Cookies',
  };
}

/// A published version of one legal document. [url] is where the rendered text
/// lives; this client opens it externally rather than embedding it, so what the
/// user reads is the same artifact [contentHash] covers.
@freezed
sealed class LegalDocumentDto with _$LegalDocumentDto {
  @ApiDateTimeConverter()
  const factory LegalDocumentDto({
    @JsonKey(unknownEnumValue: LegalDocumentType.terms)
    required LegalDocumentType documentType,
    required String version,
    String? url,
    String? contentHash,
    DateTime? effectiveAt,
  }) = _LegalDocumentDto;

  factory LegalDocumentDto.fromJson(Map<String, dynamic> json) =>
      _$LegalDocumentDtoFromJson(json);
}

/// One entry of `consentRequired` on `GET /users/self`: a document whose
/// current version this account has not accepted.
///
/// [documentType] is the raw wire string rather than a [LegalDocumentType]. A
/// type this build has never heard of is still something the user is being
/// asked to accept, and parsing it into the nearest known enum member would
/// label it as the wrong document; dropping it would hide it entirely. See
/// [knownType] for the mapping where one exists.
@freezed
sealed class ConsentRequirementDto with _$ConsentRequirementDto {
  @ApiDateTimeConverter()
  const factory ConsentRequirementDto({
    required String documentType,
    required String version,
    DateTime? effectiveAt,
    String? url,
  }) = _ConsentRequirementDto;

  factory ConsentRequirementDto.fromJson(Map<String, dynamic> json) =>
      _$ConsentRequirementDtoFromJson(json);
}

extension ConsentRequirementDtoX on ConsentRequirementDto {
  LegalDocumentType? get knownType => switch (documentType) {
    'Terms' => LegalDocumentType.terms,
    'Privacy' => LegalDocumentType.privacy,
    'Cookies' => LegalDocumentType.cookies,
    _ => null,
  };

  /// The document's name for display, falling back to whatever the server
  /// called it.
  String get label => knownType?.label ?? documentType;
}

/// What the caller has accepted, and when. Absence of an entry is meaningful -
/// it is the difference between "accepted an older version" and "never
/// accepted anything", and the two are shown differently.
@freezed
sealed class UserConsentDto with _$UserConsentDto {
  @ApiDateTimeConverter()
  const factory UserConsentDto({
    @JsonKey(unknownEnumValue: LegalDocumentType.terms)
    required LegalDocumentType documentType,
    required String version,
    DateTime? acceptedAt,
  }) = _UserConsentDto;

  factory UserConsentDto.fromJson(Map<String, dynamic> json) =>
      _$UserConsentDtoFromJson(json);
}
