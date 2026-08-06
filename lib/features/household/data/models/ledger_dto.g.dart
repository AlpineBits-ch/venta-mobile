// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ledger_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExpenseShareDto _$ExpenseShareDtoFromJson(Map<String, dynamic> json) =>
    _ExpenseShareDto(
      userId: json['userId'] as String? ?? '',
      shareValue: (json['shareValue'] as num?)?.toInt() ?? 0,
      amountMinor: (json['amountMinor'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ExpenseShareDtoToJson(_ExpenseShareDto instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'shareValue': instance.shareValue,
      'amountMinor': instance.amountMinor,
    };

_ExpenseDto _$ExpenseDtoFromJson(Map<String, dynamic> json) => _ExpenseDto(
  id: json['id'] as String,
  channelId: json['channelId'] as String,
  payerUserId: json['payerUserId'] as String? ?? '',
  description: json['description'] as String? ?? '',
  amountMinor: (json['amountMinor'] as num?)?.toInt() ?? 0,
  currency: json['currency'] as String? ?? 'CHF',
  occurredAt: _$JsonConverterFromJson<String, DateTime>(
    json['occurredAt'],
    const ApiDateTimeConverter().fromJson,
  ),
  splitKind:
      $enumDecodeNullable(
        _$SplitKindEnumMap,
        json['splitKind'],
        unknownValue: SplitKind.equal,
      ) ??
      SplitKind.equal,
  createdByUserId: json['createdByUserId'] as String? ?? '',
  shares:
      (json['shares'] as List<dynamic>?)
          ?.map((e) => ExpenseShareDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ExpenseShareDto>[],
);

Map<String, dynamic> _$ExpenseDtoToJson(_ExpenseDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'channelId': instance.channelId,
      'payerUserId': instance.payerUserId,
      'description': instance.description,
      'amountMinor': instance.amountMinor,
      'currency': instance.currency,
      'occurredAt': _$JsonConverterToJson<String, DateTime>(
        instance.occurredAt,
        const ApiDateTimeConverter().toJson,
      ),
      'splitKind': _$SplitKindEnumMap[instance.splitKind]!,
      'createdByUserId': instance.createdByUserId,
      'shares': instance.shares,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

const _$SplitKindEnumMap = {
  SplitKind.equal: 'Equal',
  SplitKind.shares: 'Shares',
  SplitKind.exact: 'Exact',
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

_ExpensePageDto _$ExpensePageDtoFromJson(Map<String, dynamic> json) =>
    _ExpensePageDto(
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => ExpenseDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ExpenseDto>[],
      nextCursor: json['nextCursor'] as String?,
    );

Map<String, dynamic> _$ExpensePageDtoToJson(_ExpensePageDto instance) =>
    <String, dynamic>{
      'items': instance.items,
      'nextCursor': instance.nextCursor,
    };

_LedgerBalanceDto _$LedgerBalanceDtoFromJson(Map<String, dynamic> json) =>
    _LedgerBalanceDto(
      userId: json['userId'] as String? ?? '',
      netMinor: (json['netMinor'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$LedgerBalanceDtoToJson(_LedgerBalanceDto instance) =>
    <String, dynamic>{'userId': instance.userId, 'netMinor': instance.netMinor};

_TransferSuggestionDto _$TransferSuggestionDtoFromJson(
  Map<String, dynamic> json,
) => _TransferSuggestionDto(
  fromUserId: json['fromUserId'] as String? ?? '',
  toUserId: json['toUserId'] as String? ?? '',
  amountMinor: (json['amountMinor'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$TransferSuggestionDtoToJson(
  _TransferSuggestionDto instance,
) => <String, dynamic>{
  'fromUserId': instance.fromUserId,
  'toUserId': instance.toUserId,
  'amountMinor': instance.amountMinor,
};

_LedgerConfigDto _$LedgerConfigDtoFromJson(Map<String, dynamic> json) =>
    _LedgerConfigDto(
      channelId: json['channelId'] as String? ?? '',
      currency: json['currency'] as String? ?? 'CHF',
    );

Map<String, dynamic> _$LedgerConfigDtoToJson(_LedgerConfigDto instance) =>
    <String, dynamic>{
      'channelId': instance.channelId,
      'currency': instance.currency,
    };
