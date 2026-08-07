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
  category:
      $enumDecodeNullable(
        _$ExpenseCategoryEnumMap,
        json['category'],
        unknownValue: ExpenseCategory.uncategorized,
      ) ??
      ExpenseCategory.uncategorized,
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
      'category': _$ExpenseCategoryEnumMap[instance.category]!,
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

const _$ExpenseCategoryEnumMap = {
  ExpenseCategory.uncategorized: 'Uncategorized',
  ExpenseCategory.groceries: 'Groceries',
  ExpenseCategory.rent: 'Rent',
  ExpenseCategory.utilities: 'Utilities',
  ExpenseCategory.internet: 'Internet',
  ExpenseCategory.household: 'Household',
  ExpenseCategory.transport: 'Transport',
  ExpenseCategory.eatingOut: 'EatingOut',
  ExpenseCategory.entertainment: 'Entertainment',
  ExpenseCategory.health: 'Health',
  ExpenseCategory.pets: 'Pets',
  ExpenseCategory.repairs: 'Repairs',
  ExpenseCategory.other: 'Other',
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

_LedgerSummaryDto _$LedgerSummaryDtoFromJson(
  Map<String, dynamic> json,
) => _LedgerSummaryDto(
  channelId: json['channelId'] as String? ?? '',
  currency: json['currency'] as String? ?? 'CHF',
  from: _$JsonConverterFromJson<String, DateTime>(
    json['from'],
    const ApiDateTimeConverter().fromJson,
  ),
  to: _$JsonConverterFromJson<String, DateTime>(
    json['to'],
    const ApiDateTimeConverter().fromJson,
  ),
  totalMinor: (json['totalMinor'] as num?)?.toInt() ?? 0,
  myShareMinor: (json['myShareMinor'] as num?)?.toInt() ?? 0,
  byCategory:
      (json['byCategory'] as List<dynamic>?)
          ?.map(
            (e) => LedgerCategoryTotalDto.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <LedgerCategoryTotalDto>[],
  byPeriod:
      (json['byPeriod'] as List<dynamic>?)
          ?.map((e) => LedgerPeriodTotalDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <LedgerPeriodTotalDto>[],
  byPayer:
      (json['byPayer'] as List<dynamic>?)
          ?.map((e) => LedgerPayerTotalDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <LedgerPayerTotalDto>[],
  clamped: json['clamped'] as bool? ?? false,
);

Map<String, dynamic> _$LedgerSummaryDtoToJson(_LedgerSummaryDto instance) =>
    <String, dynamic>{
      'channelId': instance.channelId,
      'currency': instance.currency,
      'from': _$JsonConverterToJson<String, DateTime>(
        instance.from,
        const ApiDateTimeConverter().toJson,
      ),
      'to': _$JsonConverterToJson<String, DateTime>(
        instance.to,
        const ApiDateTimeConverter().toJson,
      ),
      'totalMinor': instance.totalMinor,
      'myShareMinor': instance.myShareMinor,
      'byCategory': instance.byCategory,
      'byPeriod': instance.byPeriod,
      'byPayer': instance.byPayer,
      'clamped': instance.clamped,
    };

_LedgerCategoryTotalDto _$LedgerCategoryTotalDtoFromJson(
  Map<String, dynamic> json,
) => _LedgerCategoryTotalDto(
  category:
      $enumDecodeNullable(
        _$ExpenseCategoryEnumMap,
        json['category'],
        unknownValue: ExpenseCategory.uncategorized,
      ) ??
      ExpenseCategory.uncategorized,
  totalMinor: (json['totalMinor'] as num?)?.toInt() ?? 0,
  myShareMinor: (json['myShareMinor'] as num?)?.toInt() ?? 0,
  count: (json['count'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$LedgerCategoryTotalDtoToJson(
  _LedgerCategoryTotalDto instance,
) => <String, dynamic>{
  'category': _$ExpenseCategoryEnumMap[instance.category]!,
  'totalMinor': instance.totalMinor,
  'myShareMinor': instance.myShareMinor,
  'count': instance.count,
};

_LedgerPeriodTotalDto _$LedgerPeriodTotalDtoFromJson(
  Map<String, dynamic> json,
) => _LedgerPeriodTotalDto(
  period: json['period'] as String? ?? '',
  totalMinor: (json['totalMinor'] as num?)?.toInt() ?? 0,
  myShareMinor: (json['myShareMinor'] as num?)?.toInt() ?? 0,
  count: (json['count'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$LedgerPeriodTotalDtoToJson(
  _LedgerPeriodTotalDto instance,
) => <String, dynamic>{
  'period': instance.period,
  'totalMinor': instance.totalMinor,
  'myShareMinor': instance.myShareMinor,
  'count': instance.count,
};

_LedgerPayerTotalDto _$LedgerPayerTotalDtoFromJson(Map<String, dynamic> json) =>
    _LedgerPayerTotalDto(
      userId: json['userId'] as String? ?? '',
      paidMinor: (json['paidMinor'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$LedgerPayerTotalDtoToJson(
  _LedgerPayerTotalDto instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'paidMinor': instance.paidMinor,
};

_ExpenseReceiptDto _$ExpenseReceiptDtoFromJson(Map<String, dynamic> json) =>
    _ExpenseReceiptDto(
      id: json['id'] as String,
      expenseId: json['expenseId'] as String? ?? '',
      fileName: json['fileName'] as String? ?? '',
      contentType: json['contentType'] as String? ?? '',
      sizeBytes: (json['sizeBytes'] as num?)?.toInt() ?? 0,
      uploadedByUserId: json['uploadedByUserId'] as String? ?? '',
      uploadedAt: _$JsonConverterFromJson<String, DateTime>(
        json['uploadedAt'],
        const ApiDateTimeConverter().fromJson,
      ),
      url: json['url'] as String?,
    );

Map<String, dynamic> _$ExpenseReceiptDtoToJson(_ExpenseReceiptDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'expenseId': instance.expenseId,
      'fileName': instance.fileName,
      'contentType': instance.contentType,
      'sizeBytes': instance.sizeBytes,
      'uploadedByUserId': instance.uploadedByUserId,
      'uploadedAt': _$JsonConverterToJson<String, DateTime>(
        instance.uploadedAt,
        const ApiDateTimeConverter().toJson,
      ),
      'url': instance.url,
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
