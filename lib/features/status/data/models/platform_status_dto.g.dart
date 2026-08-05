// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_status_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlatformStatusDto _$PlatformStatusDtoFromJson(
  Map<String, dynamic> json,
) => _PlatformStatusDto(
  indicator:
      $enumDecodeNullable(
        _$StatusIndicatorEnumMap,
        json['indicator'],
        unknownValue: StatusIndicator.unknown,
      ) ??
      StatusIndicator.operational,
  updatedAt: _$JsonConverterFromJson<String, DateTime>(
    json['updatedAt'],
    const ApiDateTimeConverter().fromJson,
  ),
  banner: json['banner'] == null
      ? null
      : StatusBannerDto.fromJson(json['banner'] as Map<String, dynamic>),
  components:
      (json['components'] as List<dynamic>?)
          ?.map((e) => StatusComponentDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <StatusComponentDto>[],
  incidents:
      (json['incidents'] as List<dynamic>?)
          ?.map((e) => StatusIncidentDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <StatusIncidentDto>[],
  maintenance:
      (json['maintenance'] as List<dynamic>?)
          ?.map((e) => StatusIncidentDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <StatusIncidentDto>[],
  recent:
      (json['recent'] as List<dynamic>?)
          ?.map((e) => StatusIncidentDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <StatusIncidentDto>[],
);

Map<String, dynamic> _$PlatformStatusDtoToJson(_PlatformStatusDto instance) =>
    <String, dynamic>{
      'indicator': _$StatusIndicatorEnumMap[instance.indicator]!,
      'updatedAt': _$JsonConverterToJson<String, DateTime>(
        instance.updatedAt,
        const ApiDateTimeConverter().toJson,
      ),
      'banner': instance.banner,
      'components': instance.components,
      'incidents': instance.incidents,
      'maintenance': instance.maintenance,
      'recent': instance.recent,
    };

const _$StatusIndicatorEnumMap = {
  StatusIndicator.operational: 'operational',
  StatusIndicator.degraded: 'degraded',
  StatusIndicator.partialOutage: 'partial_outage',
  StatusIndicator.majorOutage: 'major_outage',
  StatusIndicator.maintenance: 'maintenance',
  StatusIndicator.unknown: 'unknown',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

_StatusBannerDto _$StatusBannerDtoFromJson(Map<String, dynamic> json) =>
    _StatusBannerDto(
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      severity:
          $enumDecodeNullable(
            _$StatusSeverityEnumMap,
            json['severity'],
            unknownValue: StatusSeverity.unknown,
          ) ??
          StatusSeverity.info,
      incidentReference: json['incidentReference'] as String?,
      url: json['url'] as String?,
      template: json['template'] as String?,
      componentKey: json['componentKey'] as String?,
    );

Map<String, dynamic> _$StatusBannerDtoToJson(_StatusBannerDto instance) =>
    <String, dynamic>{
      'title': instance.title,
      'body': instance.body,
      'severity': _$StatusSeverityEnumMap[instance.severity]!,
      'incidentReference': instance.incidentReference,
      'url': instance.url,
      'template': instance.template,
      'componentKey': instance.componentKey,
    };

const _$StatusSeverityEnumMap = {
  StatusSeverity.info: 'info',
  StatusSeverity.warning: 'warning',
  StatusSeverity.critical: 'critical',
  StatusSeverity.unknown: 'unknown',
};

_StatusComponentDto _$StatusComponentDtoFromJson(Map<String, dynamic> json) =>
    _StatusComponentDto(
      key: json['key'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      status:
          $enumDecodeNullable(
            _$ComponentStatusEnumMap,
            json['status'],
            unknownValue: ComponentStatus.unknown,
          ) ??
          ComponentStatus.operational,
      statusSince: _$JsonConverterFromJson<String, DateTime>(
        json['statusSince'],
        const ApiDateTimeConverter().fromJson,
      ),
      uptime90d: (json['uptime90d'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$StatusComponentDtoToJson(_StatusComponentDto instance) =>
    <String, dynamic>{
      'key': instance.key,
      'name': instance.name,
      'description': instance.description,
      'status': _$ComponentStatusEnumMap[instance.status]!,
      'statusSince': _$JsonConverterToJson<String, DateTime>(
        instance.statusSince,
        const ApiDateTimeConverter().toJson,
      ),
      'uptime90d': instance.uptime90d,
    };

const _$ComponentStatusEnumMap = {
  ComponentStatus.operational: 'operational',
  ComponentStatus.degradedPerformance: 'degraded_performance',
  ComponentStatus.partialOutage: 'partial_outage',
  ComponentStatus.majorOutage: 'major_outage',
  ComponentStatus.underMaintenance: 'under_maintenance',
  ComponentStatus.unknown: 'unknown',
};

_StatusIncidentDto _$StatusIncidentDtoFromJson(Map<String, dynamic> json) =>
    _StatusIncidentDto(
      reference: json['reference'] as String? ?? '',
      kind:
          $enumDecodeNullable(
            _$IncidentKindEnumMap,
            json['kind'],
            unknownValue: IncidentKind.unknown,
          ) ??
          IncidentKind.incident,
      title: json['title'] as String? ?? '',
      impact:
          $enumDecodeNullable(
            _$IncidentImpactEnumMap,
            json['impact'],
            unknownValue: IncidentImpact.unknown,
          ) ??
          IncidentImpact.none,
      status:
          $enumDecodeNullable(
            _$IncidentStatusEnumMap,
            json['status'],
            unknownValue: IncidentStatus.unknown,
          ) ??
          IncidentStatus.unknown,
      components:
          (json['components'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      startedAt: _$JsonConverterFromJson<String, DateTime>(
        json['startedAt'],
        const ApiDateTimeConverter().fromJson,
      ),
      resolvedAt: _$JsonConverterFromJson<String, DateTime>(
        json['resolvedAt'],
        const ApiDateTimeConverter().fromJson,
      ),
      scheduledFor: _$JsonConverterFromJson<String, DateTime>(
        json['scheduledFor'],
        const ApiDateTimeConverter().fromJson,
      ),
      scheduledUntil: _$JsonConverterFromJson<String, DateTime>(
        json['scheduledUntil'],
        const ApiDateTimeConverter().fromJson,
      ),
      template: json['template'] as String?,
      url: json['url'] as String?,
      updates:
          (json['updates'] as List<dynamic>?)
              ?.map(
                (e) =>
                    StatusIncidentUpdateDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <StatusIncidentUpdateDto>[],
    );

Map<String, dynamic> _$StatusIncidentDtoToJson(_StatusIncidentDto instance) =>
    <String, dynamic>{
      'reference': instance.reference,
      'kind': _$IncidentKindEnumMap[instance.kind]!,
      'title': instance.title,
      'impact': _$IncidentImpactEnumMap[instance.impact]!,
      'status': _$IncidentStatusEnumMap[instance.status]!,
      'components': instance.components,
      'startedAt': _$JsonConverterToJson<String, DateTime>(
        instance.startedAt,
        const ApiDateTimeConverter().toJson,
      ),
      'resolvedAt': _$JsonConverterToJson<String, DateTime>(
        instance.resolvedAt,
        const ApiDateTimeConverter().toJson,
      ),
      'scheduledFor': _$JsonConverterToJson<String, DateTime>(
        instance.scheduledFor,
        const ApiDateTimeConverter().toJson,
      ),
      'scheduledUntil': _$JsonConverterToJson<String, DateTime>(
        instance.scheduledUntil,
        const ApiDateTimeConverter().toJson,
      ),
      'template': instance.template,
      'url': instance.url,
      'updates': instance.updates,
    };

const _$IncidentKindEnumMap = {
  IncidentKind.incident: 'incident',
  IncidentKind.maintenance: 'maintenance',
  IncidentKind.unknown: 'unknown',
};

const _$IncidentImpactEnumMap = {
  IncidentImpact.none: 'none',
  IncidentImpact.minor: 'minor',
  IncidentImpact.major: 'major',
  IncidentImpact.critical: 'critical',
  IncidentImpact.unknown: 'unknown',
};

const _$IncidentStatusEnumMap = {
  IncidentStatus.investigating: 'investigating',
  IncidentStatus.identified: 'identified',
  IncidentStatus.monitoring: 'monitoring',
  IncidentStatus.resolved: 'resolved',
  IncidentStatus.scheduled: 'scheduled',
  IncidentStatus.inProgress: 'in_progress',
  IncidentStatus.completed: 'completed',
  IncidentStatus.cancelled: 'cancelled',
  IncidentStatus.unknown: 'unknown',
};

_StatusIncidentUpdateDto _$StatusIncidentUpdateDtoFromJson(
  Map<String, dynamic> json,
) => _StatusIncidentUpdateDto(
  status:
      $enumDecodeNullable(
        _$IncidentStatusEnumMap,
        json['status'],
        unknownValue: IncidentStatus.unknown,
      ) ??
      IncidentStatus.unknown,
  body: json['body'] as String? ?? '',
  template: json['template'] as String?,
  postedAt: _$JsonConverterFromJson<String, DateTime>(
    json['postedAt'],
    const ApiDateTimeConverter().fromJson,
  ),
);

Map<String, dynamic> _$StatusIncidentUpdateDtoToJson(
  _StatusIncidentUpdateDto instance,
) => <String, dynamic>{
  'status': _$IncidentStatusEnumMap[instance.status]!,
  'body': instance.body,
  'template': instance.template,
  'postedAt': _$JsonConverterToJson<String, DateTime>(
    instance.postedAt,
    const ApiDateTimeConverter().toJson,
  ),
};
