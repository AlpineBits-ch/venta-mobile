// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'legal_document_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LegalDocumentDto _$LegalDocumentDtoFromJson(Map<String, dynamic> json) =>
    _LegalDocumentDto(
      documentType: $enumDecode(
        _$LegalDocumentTypeEnumMap,
        json['documentType'],
        unknownValue: LegalDocumentType.terms,
      ),
      version: json['version'] as String,
      url: json['url'] as String?,
      contentHash: json['contentHash'] as String?,
      effectiveAt: _$JsonConverterFromJson<String, DateTime>(
        json['effectiveAt'],
        const ApiDateTimeConverter().fromJson,
      ),
    );

Map<String, dynamic> _$LegalDocumentDtoToJson(_LegalDocumentDto instance) =>
    <String, dynamic>{
      'documentType': _$LegalDocumentTypeEnumMap[instance.documentType]!,
      'version': instance.version,
      'url': instance.url,
      'contentHash': instance.contentHash,
      'effectiveAt': _$JsonConverterToJson<String, DateTime>(
        instance.effectiveAt,
        const ApiDateTimeConverter().toJson,
      ),
    };

const _$LegalDocumentTypeEnumMap = {
  LegalDocumentType.terms: 'Terms',
  LegalDocumentType.privacy: 'Privacy',
  LegalDocumentType.cookies: 'Cookies',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

_ConsentRequirementDto _$ConsentRequirementDtoFromJson(
  Map<String, dynamic> json,
) => _ConsentRequirementDto(
  documentType: json['documentType'] as String,
  version: json['version'] as String,
  effectiveAt: _$JsonConverterFromJson<String, DateTime>(
    json['effectiveAt'],
    const ApiDateTimeConverter().fromJson,
  ),
  url: json['url'] as String?,
);

Map<String, dynamic> _$ConsentRequirementDtoToJson(
  _ConsentRequirementDto instance,
) => <String, dynamic>{
  'documentType': instance.documentType,
  'version': instance.version,
  'effectiveAt': _$JsonConverterToJson<String, DateTime>(
    instance.effectiveAt,
    const ApiDateTimeConverter().toJson,
  ),
  'url': instance.url,
};

_UserConsentDto _$UserConsentDtoFromJson(Map<String, dynamic> json) =>
    _UserConsentDto(
      documentType: $enumDecode(
        _$LegalDocumentTypeEnumMap,
        json['documentType'],
        unknownValue: LegalDocumentType.terms,
      ),
      version: json['version'] as String,
      acceptedAt: _$JsonConverterFromJson<String, DateTime>(
        json['acceptedAt'],
        const ApiDateTimeConverter().fromJson,
      ),
    );

Map<String, dynamic> _$UserConsentDtoToJson(_UserConsentDto instance) =>
    <String, dynamic>{
      'documentType': _$LegalDocumentTypeEnumMap[instance.documentType]!,
      'version': instance.version,
      'acceptedAt': _$JsonConverterToJson<String, DateTime>(
        instance.acceptedAt,
        const ApiDateTimeConverter().toJson,
      ),
    };
