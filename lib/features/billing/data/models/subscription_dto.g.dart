// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SubscriptionDto _$SubscriptionDtoFromJson(Map<String, dynamic> json) =>
    _SubscriptionDto(
      id: json['id'] as String? ?? '',
      subjectKind: json['subjectKind'] as String? ?? '',
      subjectId: json['subjectId'] as String? ?? '',
      planName: json['planName'] as String? ?? '',
      planDisplayName: json['planDisplayName'] as String? ?? '',
      versionNumber: (json['versionNumber'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? '',
      currentPeriodEnd: _$JsonConverterFromJson<String, DateTime>(
        json['currentPeriodEnd'],
        const ApiDateTimeConverter().fromJson,
      ),
      cancelAtPeriodEnd: json['cancelAtPeriodEnd'] as bool? ?? false,
      gracePeriodEndsAt: _$JsonConverterFromJson<String, DateTime>(
        json['gracePeriodEndsAt'],
        const ApiDateTimeConverter().fromJson,
      ),
      interval: json['interval'] as String?,
      isPayer: json['isPayer'] as bool? ?? false,
    );

Map<String, dynamic> _$SubscriptionDtoToJson(_SubscriptionDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'subjectKind': instance.subjectKind,
      'subjectId': instance.subjectId,
      'planName': instance.planName,
      'planDisplayName': instance.planDisplayName,
      'versionNumber': instance.versionNumber,
      'status': instance.status,
      'currentPeriodEnd': _$JsonConverterToJson<String, DateTime>(
        instance.currentPeriodEnd,
        const ApiDateTimeConverter().toJson,
      ),
      'cancelAtPeriodEnd': instance.cancelAtPeriodEnd,
      'gracePeriodEndsAt': _$JsonConverterToJson<String, DateTime>(
        instance.gracePeriodEndsAt,
        const ApiDateTimeConverter().toJson,
      ),
      'interval': instance.interval,
      'isPayer': instance.isPayer,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
