// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_handles_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaymentHandlesDto _$PaymentHandlesDtoFromJson(Map<String, dynamic> json) =>
    _PaymentHandlesDto(
      sharingPhoneNumber: json['sharingPhoneNumber'] as bool? ?? false,
      phoneNumbers:
          (json['phoneNumbers'] as List<dynamic>?)
              ?.map(
                (e) => SharedPhoneNumberDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <SharedPhoneNumberDto>[],
    );

Map<String, dynamic> _$PaymentHandlesDtoToJson(_PaymentHandlesDto instance) =>
    <String, dynamic>{
      'sharingPhoneNumber': instance.sharingPhoneNumber,
      'phoneNumbers': instance.phoneNumbers,
    };

_SharedPhoneNumberDto _$SharedPhoneNumberDtoFromJson(
  Map<String, dynamic> json,
) => _SharedPhoneNumberDto(
  userId: json['userId'] as String,
  phoneNumber: json['phoneNumber'] as String,
  updatedAt: _$JsonConverterFromJson<String, DateTime>(
    json['updatedAt'],
    const ApiDateTimeConverter().fromJson,
  ),
);

Map<String, dynamic> _$SharedPhoneNumberDtoToJson(
  _SharedPhoneNumberDto instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'phoneNumber': instance.phoneNumber,
  'updatedAt': _$JsonConverterToJson<String, DateTime>(
    instance.updatedAt,
    const ApiDateTimeConverter().toJson,
  ),
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
