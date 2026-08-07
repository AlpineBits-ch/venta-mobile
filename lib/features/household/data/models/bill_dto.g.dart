// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RecurringExpenseShareDto _$RecurringExpenseShareDtoFromJson(
  Map<String, dynamic> json,
) => _RecurringExpenseShareDto(
  userId: json['userId'] as String? ?? '',
  shareValue: (json['shareValue'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$RecurringExpenseShareDtoToJson(
  _RecurringExpenseShareDto instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'shareValue': instance.shareValue,
};

_RecurringExpenseDto _$RecurringExpenseDtoFromJson(Map<String, dynamic> json) =>
    _RecurringExpenseDto(
      id: json['id'] as String,
      channelId: json['channelId'] as String,
      description: json['description'] as String? ?? '',
      amountMinor: (json['amountMinor'] as num?)?.toInt(),
      currency: json['currency'] as String? ?? 'CHF',
      payerUserId: json['payerUserId'] as String? ?? '',
      splitKind:
          $enumDecodeNullable(
            _$SplitKindEnumMap,
            json['splitKind'],
            unknownValue: SplitKind.equal,
          ) ??
          SplitKind.equal,
      category:
          $enumDecodeNullable(
            _$ExpenseCategoryEnumMap,
            json['category'],
            unknownValue: ExpenseCategory.uncategorized,
          ) ??
          ExpenseCategory.uncategorized,
      recurrenceUnit:
          $enumDecodeNullable(
            _$RecurrenceUnitEnumMap,
            json['recurrenceUnit'],
            unknownValue: RecurrenceUnit.month,
          ) ??
          RecurrenceUnit.month,
      recurrenceInterval: (json['recurrenceInterval'] as num?)?.toInt() ?? 1,
      anchorAt: _$JsonConverterFromJson<String, DateTime>(
        json['anchorAt'],
        const ApiDateTimeConverter().fromJson,
      ),
      nextDueAt: _$JsonConverterFromJson<String, DateTime>(
        json['nextDueAt'],
        const ApiDateTimeConverter().fromJson,
      ),
      leadDays: (json['leadDays'] as num?)?.toInt() ?? 0,
      autoPost: json['autoPost'] as bool? ?? false,
      isPaused: json['isPaused'] as bool? ?? false,
      createdByUserId: json['createdByUserId'] as String? ?? '',
      shares:
          (json['shares'] as List<dynamic>?)
              ?.map(
                (e) => RecurringExpenseShareDto.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const <RecurringExpenseShareDto>[],
    );

Map<String, dynamic> _$RecurringExpenseDtoToJson(
  _RecurringExpenseDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'channelId': instance.channelId,
  'description': instance.description,
  'amountMinor': instance.amountMinor,
  'currency': instance.currency,
  'payerUserId': instance.payerUserId,
  'splitKind': _$SplitKindEnumMap[instance.splitKind]!,
  'category': _$ExpenseCategoryEnumMap[instance.category]!,
  'recurrenceUnit': _$RecurrenceUnitEnumMap[instance.recurrenceUnit]!,
  'recurrenceInterval': instance.recurrenceInterval,
  'anchorAt': _$JsonConverterToJson<String, DateTime>(
    instance.anchorAt,
    const ApiDateTimeConverter().toJson,
  ),
  'nextDueAt': _$JsonConverterToJson<String, DateTime>(
    instance.nextDueAt,
    const ApiDateTimeConverter().toJson,
  ),
  'leadDays': instance.leadDays,
  'autoPost': instance.autoPost,
  'isPaused': instance.isPaused,
  'createdByUserId': instance.createdByUserId,
  'shares': instance.shares,
};

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

const _$RecurrenceUnitEnumMap = {
  RecurrenceUnit.day: 'Day',
  RecurrenceUnit.week: 'Week',
  RecurrenceUnit.month: 'Month',
  RecurrenceUnit.year: 'Year',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

_BillOccurrenceDto _$BillOccurrenceDtoFromJson(Map<String, dynamic> json) =>
    _BillOccurrenceDto(
      id: json['id'] as String,
      recurringExpenseId: json['recurringExpenseId'] as String? ?? '',
      channelId: json['channelId'] as String,
      description: json['description'] as String? ?? '',
      dueAt: const ApiDateTimeConverter().fromJson(json['dueAt'] as String),
      amountMinor: (json['amountMinor'] as num?)?.toInt(),
      currency: json['currency'] as String? ?? 'CHF',
      status:
          $enumDecodeNullable(
            _$BillStatusEnumMap,
            json['status'],
            unknownValue: BillStatus.pending,
          ) ??
          BillStatus.pending,
      expenseId: json['expenseId'] as String?,
      postedByUserId: json['postedByUserId'] as String?,
      skippedByUserId: json['skippedByUserId'] as String?,
      skipReason: json['skipReason'] as String?,
      needsAmount: json['needsAmount'] as bool? ?? false,
      isOverdue: json['isOverdue'] as bool? ?? false,
    );

Map<String, dynamic> _$BillOccurrenceDtoToJson(_BillOccurrenceDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'recurringExpenseId': instance.recurringExpenseId,
      'channelId': instance.channelId,
      'description': instance.description,
      'dueAt': const ApiDateTimeConverter().toJson(instance.dueAt),
      'amountMinor': instance.amountMinor,
      'currency': instance.currency,
      'status': _$BillStatusEnumMap[instance.status]!,
      'expenseId': instance.expenseId,
      'postedByUserId': instance.postedByUserId,
      'skippedByUserId': instance.skippedByUserId,
      'skipReason': instance.skipReason,
      'needsAmount': instance.needsAmount,
      'isOverdue': instance.isOverdue,
    };

const _$BillStatusEnumMap = {
  BillStatus.pending: 'Pending',
  BillStatus.posted: 'Posted',
  BillStatus.skipped: 'Skipped',
};
