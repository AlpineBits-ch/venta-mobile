// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'digest_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HouseholdDigestDto _$HouseholdDigestDtoFromJson(
  Map<String, dynamic> json,
) => _HouseholdDigestDto(
  guildId: json['guildId'] as String? ?? '',
  chores: json['chores'] == null
      ? null
      : HouseholdChoresDigestDto.fromJson(
          json['chores'] as Map<String, dynamic>,
        ),
  lists: (json['lists'] as List<dynamic>?)
      ?.map((e) => HouseholdListDigestDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  pantry: json['pantry'] == null
      ? null
      : HouseholdPantryDigestDto.fromJson(
          json['pantry'] as Map<String, dynamic>,
        ),
  ledger: (json['ledger'] as List<dynamic>?)
      ?.map((e) => HouseholdLedgerDigestDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  decisions: json['decisions'] == null
      ? null
      : HouseholdDecisionsDigestDto.fromJson(
          json['decisions'] as Map<String, dynamic>,
        ),
  homeStatus: (json['homeStatus'] as List<dynamic>?)
      ?.map((e) => HomeStatusDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$HouseholdDigestDtoToJson(_HouseholdDigestDto instance) =>
    <String, dynamic>{
      'guildId': instance.guildId,
      'chores': instance.chores,
      'lists': instance.lists,
      'pantry': instance.pantry,
      'ledger': instance.ledger,
      'decisions': instance.decisions,
      'homeStatus': instance.homeStatus,
    };

_HouseholdChoresDigestDto _$HouseholdChoresDigestDtoFromJson(
  Map<String, dynamic> json,
) => _HouseholdChoresDigestDto(
  mine:
      (json['mine'] as List<dynamic>?)
          ?.map((e) => ChoreOccurrenceDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ChoreOccurrenceDto>[],
  mineOverdueCount: (json['mineOverdueCount'] as num?)?.toInt() ?? 0,
  houseOverdueCount: (json['houseOverdueCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$HouseholdChoresDigestDtoToJson(
  _HouseholdChoresDigestDto instance,
) => <String, dynamic>{
  'mine': instance.mine,
  'mineOverdueCount': instance.mineOverdueCount,
  'houseOverdueCount': instance.houseOverdueCount,
};

_HouseholdListDigestDto _$HouseholdListDigestDtoFromJson(
  Map<String, dynamic> json,
) => _HouseholdListDigestDto(
  channelId: json['channelId'] as String? ?? '',
  channelName: json['channelName'] as String? ?? '',
  openCount: (json['openCount'] as num?)?.toInt() ?? 0,
  preview:
      (json['preview'] as List<dynamic>?)
          ?.map((e) => ListItemDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ListItemDto>[],
);

Map<String, dynamic> _$HouseholdListDigestDtoToJson(
  _HouseholdListDigestDto instance,
) => <String, dynamic>{
  'channelId': instance.channelId,
  'channelName': instance.channelName,
  'openCount': instance.openCount,
  'preview': instance.preview,
};

_HouseholdPantryDigestDto _$HouseholdPantryDigestDtoFromJson(
  Map<String, dynamic> json,
) => _HouseholdPantryDigestDto(
  expiringCount: (json['expiringCount'] as num?)?.toInt() ?? 0,
  soonest:
      (json['soonest'] as List<dynamic>?)
          ?.map((e) => PantryItemDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <PantryItemDto>[],
);

Map<String, dynamic> _$HouseholdPantryDigestDtoToJson(
  _HouseholdPantryDigestDto instance,
) => <String, dynamic>{
  'expiringCount': instance.expiringCount,
  'soonest': instance.soonest,
};

_HouseholdLedgerDigestDto _$HouseholdLedgerDigestDtoFromJson(
  Map<String, dynamic> json,
) => _HouseholdLedgerDigestDto(
  channelId: json['channelId'] as String? ?? '',
  channelName: json['channelName'] as String? ?? '',
  currency: json['currency'] as String? ?? 'CHF',
  myNetMinor: (json['myNetMinor'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$HouseholdLedgerDigestDtoToJson(
  _HouseholdLedgerDigestDto instance,
) => <String, dynamic>{
  'channelId': instance.channelId,
  'channelName': instance.channelName,
  'currency': instance.currency,
  'myNetMinor': instance.myNetMinor,
};

_HouseholdDecisionsDigestDto _$HouseholdDecisionsDigestDtoFromJson(
  Map<String, dynamic> json,
) => _HouseholdDecisionsDigestDto(
  openCount: (json['openCount'] as num?)?.toInt() ?? 0,
  awaitingMyVote:
      (json['awaitingMyVote'] as List<dynamic>?)
          ?.map(
            (e) => HouseholdDecisionDigestEntryDto.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList() ??
      const <HouseholdDecisionDigestEntryDto>[],
);

Map<String, dynamic> _$HouseholdDecisionsDigestDtoToJson(
  _HouseholdDecisionsDigestDto instance,
) => <String, dynamic>{
  'openCount': instance.openCount,
  'awaitingMyVote': instance.awaitingMyVote,
};

_HouseholdDecisionDigestEntryDto _$HouseholdDecisionDigestEntryDtoFromJson(
  Map<String, dynamic> json,
) => _HouseholdDecisionDigestEntryDto(
  id: json['id'] as String? ?? '',
  channelId: json['channelId'] as String? ?? '',
  title: json['title'] as String? ?? '',
  closesAt: _$JsonConverterFromJson<String, DateTime>(
    json['closesAt'],
    const ApiDateTimeConverter().fromJson,
  ),
);

Map<String, dynamic> _$HouseholdDecisionDigestEntryDtoToJson(
  _HouseholdDecisionDigestEntryDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'channelId': instance.channelId,
  'title': instance.title,
  'closesAt': _$JsonConverterToJson<String, DateTime>(
    instance.closesAt,
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
