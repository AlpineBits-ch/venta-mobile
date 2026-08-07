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
  bills: json['bills'] == null
      ? null
      : HouseholdBillsDigestDto.fromJson(json['bills'] as Map<String, dynamic>),
  meals: json['meals'] == null
      ? null
      : HouseholdMealsDigestDto.fromJson(json['meals'] as Map<String, dynamic>),
  maintenance: json['maintenance'] == null
      ? null
      : HouseholdMaintenanceDigestDto.fromJson(
          json['maintenance'] as Map<String, dynamic>,
        ),
  away: (json['away'] as List<dynamic>?)
      ?.map(
        (e) => HouseholdAbsenceDigestDto.fromJson(e as Map<String, dynamic>),
      )
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
      'bills': instance.bills,
      'meals': instance.meals,
      'maintenance': instance.maintenance,
      'away': instance.away,
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

_HouseholdBillsDigestDto _$HouseholdBillsDigestDtoFromJson(
  Map<String, dynamic> json,
) => _HouseholdBillsDigestDto(
  dueSoon:
      (json['dueSoon'] as List<dynamic>?)
          ?.map(
            (e) =>
                HouseholdBillDigestEntryDto.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <HouseholdBillDigestEntryDto>[],
  overdueCount: (json['overdueCount'] as num?)?.toInt() ?? 0,
  needsAmountCount: (json['needsAmountCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$HouseholdBillsDigestDtoToJson(
  _HouseholdBillsDigestDto instance,
) => <String, dynamic>{
  'dueSoon': instance.dueSoon,
  'overdueCount': instance.overdueCount,
  'needsAmountCount': instance.needsAmountCount,
};

_HouseholdBillDigestEntryDto _$HouseholdBillDigestEntryDtoFromJson(
  Map<String, dynamic> json,
) => _HouseholdBillDigestEntryDto(
  id: json['id'] as String? ?? '',
  channelId: json['channelId'] as String? ?? '',
  description: json['description'] as String? ?? '',
  dueAt: _$JsonConverterFromJson<String, DateTime>(
    json['dueAt'],
    const ApiDateTimeConverter().fromJson,
  ),
  amountMinor: (json['amountMinor'] as num?)?.toInt(),
  currency: json['currency'] as String? ?? 'CHF',
  myShareMinor: (json['myShareMinor'] as num?)?.toInt(),
  status:
      $enumDecodeNullable(
        _$BillStatusEnumMap,
        json['status'],
        unknownValue: BillStatus.pending,
      ) ??
      BillStatus.pending,
);

Map<String, dynamic> _$HouseholdBillDigestEntryDtoToJson(
  _HouseholdBillDigestEntryDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'channelId': instance.channelId,
  'description': instance.description,
  'dueAt': _$JsonConverterToJson<String, DateTime>(
    instance.dueAt,
    const ApiDateTimeConverter().toJson,
  ),
  'amountMinor': instance.amountMinor,
  'currency': instance.currency,
  'myShareMinor': instance.myShareMinor,
  'status': _$BillStatusEnumMap[instance.status]!,
};

const _$BillStatusEnumMap = {
  BillStatus.pending: 'Pending',
  BillStatus.posted: 'Posted',
  BillStatus.skipped: 'Skipped',
};

_HouseholdMealsDigestDto _$HouseholdMealsDigestDtoFromJson(
  Map<String, dynamic> json,
) => _HouseholdMealsDigestDto(
  today:
      (json['today'] as List<dynamic>?)
          ?.map(
            (e) =>
                HouseholdMealDigestEntryDto.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <HouseholdMealDigestEntryDto>[],
  imCookingToday: json['imCookingToday'] as bool? ?? false,
);

Map<String, dynamic> _$HouseholdMealsDigestDtoToJson(
  _HouseholdMealsDigestDto instance,
) => <String, dynamic>{
  'today': instance.today,
  'imCookingToday': instance.imCookingToday,
};

_HouseholdMealDigestEntryDto _$HouseholdMealDigestEntryDtoFromJson(
  Map<String, dynamic> json,
) => _HouseholdMealDigestEntryDto(
  id: json['id'] as String? ?? '',
  channelId: json['channelId'] as String? ?? '',
  slot:
      $enumDecodeNullable(
        _$MealSlotEnumMap,
        json['slot'],
        unknownValue: MealSlot.dinner,
      ) ??
      MealSlot.dinner,
  title: json['title'] as String? ?? '',
  cookUserId: json['cookUserId'] as String?,
);

Map<String, dynamic> _$HouseholdMealDigestEntryDtoToJson(
  _HouseholdMealDigestEntryDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'channelId': instance.channelId,
  'slot': _$MealSlotEnumMap[instance.slot]!,
  'title': instance.title,
  'cookUserId': instance.cookUserId,
};

const _$MealSlotEnumMap = {
  MealSlot.breakfast: 'Breakfast',
  MealSlot.lunch: 'Lunch',
  MealSlot.dinner: 'Dinner',
  MealSlot.other: 'Other',
};

_HouseholdMaintenanceDigestDto _$HouseholdMaintenanceDigestDtoFromJson(
  Map<String, dynamic> json,
) => _HouseholdMaintenanceDigestDto(
  brokenCount: (json['brokenCount'] as num?)?.toInt() ?? 0,
  serviceOverdueCount: (json['serviceOverdueCount'] as num?)?.toInt() ?? 0,
  warrantyExpiringCount: (json['warrantyExpiringCount'] as num?)?.toInt() ?? 0,
  attention:
      (json['attention'] as List<dynamic>?)
          ?.map(
            (e) => HouseholdAssetDigestEntryDto.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList() ??
      const <HouseholdAssetDigestEntryDto>[],
);

Map<String, dynamic> _$HouseholdMaintenanceDigestDtoToJson(
  _HouseholdMaintenanceDigestDto instance,
) => <String, dynamic>{
  'brokenCount': instance.brokenCount,
  'serviceOverdueCount': instance.serviceOverdueCount,
  'warrantyExpiringCount': instance.warrantyExpiringCount,
  'attention': instance.attention,
};

_HouseholdAssetDigestEntryDto _$HouseholdAssetDigestEntryDtoFromJson(
  Map<String, dynamic> json,
) => _HouseholdAssetDigestEntryDto(
  id: json['id'] as String? ?? '',
  channelId: json['channelId'] as String? ?? '',
  name: json['name'] as String? ?? '',
  status:
      $enumDecodeNullable(
        _$AssetStatusEnumMap,
        json['status'],
        unknownValue: AssetStatus.ok,
      ) ??
      AssetStatus.ok,
  reason: json['reason'] as String? ?? '',
);

Map<String, dynamic> _$HouseholdAssetDigestEntryDtoToJson(
  _HouseholdAssetDigestEntryDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'channelId': instance.channelId,
  'name': instance.name,
  'status': _$AssetStatusEnumMap[instance.status]!,
  'reason': instance.reason,
};

const _$AssetStatusEnumMap = {
  AssetStatus.ok: 'Ok',
  AssetStatus.needsAttention: 'NeedsAttention',
  AssetStatus.broken: 'Broken',
  AssetStatus.outOfService: 'OutOfService',
};

_HouseholdAbsenceDigestDto _$HouseholdAbsenceDigestDtoFromJson(
  Map<String, dynamic> json,
) => _HouseholdAbsenceDigestDto(
  userId: json['userId'] as String? ?? '',
  startAt: _$JsonConverterFromJson<String, DateTime>(
    json['startAt'],
    const ApiDateTimeConverter().fromJson,
  ),
  endAt: _$JsonConverterFromJson<String, DateTime>(
    json['endAt'],
    const ApiDateTimeConverter().fromJson,
  ),
  note: json['note'] as String?,
);

Map<String, dynamic> _$HouseholdAbsenceDigestDtoToJson(
  _HouseholdAbsenceDigestDto instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'startAt': _$JsonConverterToJson<String, DateTime>(
    instance.startAt,
    const ApiDateTimeConverter().toJson,
  ),
  'endAt': _$JsonConverterToJson<String, DateTime>(
    instance.endAt,
    const ApiDateTimeConverter().toJson,
  ),
  'note': instance.note,
};
