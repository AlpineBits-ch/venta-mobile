import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/format/api_date_time.dart';

part 'ledger_dto.freezed.dart';
part 'ledger_dto.g.dart';

/// What an expense was for.
///
/// Coarse on purpose: the question it answers is "what does this flat cost per
/// month, roughly", and a taxonomy fine enough to argue about is a taxonomy
/// nobody fills in. [uncategorized] is a real bucket rather than a synonym for
/// [other] - a rollup that hides the size of its own gap is worse than none.
enum ExpenseCategory {
  @JsonValue('Uncategorized')
  uncategorized,
  @JsonValue('Groceries')
  groceries,
  @JsonValue('Rent')
  rent,
  @JsonValue('Utilities')
  utilities,
  @JsonValue('Internet')
  internet,
  @JsonValue('Household')
  household,
  @JsonValue('Transport')
  transport,
  @JsonValue('EatingOut')
  eatingOut,
  @JsonValue('Entertainment')
  entertainment,
  @JsonValue('Health')
  health,
  @JsonValue('Pets')
  pets,
  @JsonValue('Repairs')
  repairs,
  @JsonValue('Other')
  other,
}

extension ExpenseCategoryX on ExpenseCategory {
  String get wireValue => switch (this) {
    ExpenseCategory.uncategorized => 'Uncategorized',
    ExpenseCategory.groceries => 'Groceries',
    ExpenseCategory.rent => 'Rent',
    ExpenseCategory.utilities => 'Utilities',
    ExpenseCategory.internet => 'Internet',
    ExpenseCategory.household => 'Household',
    ExpenseCategory.transport => 'Transport',
    ExpenseCategory.eatingOut => 'EatingOut',
    ExpenseCategory.entertainment => 'Entertainment',
    ExpenseCategory.health => 'Health',
    ExpenseCategory.pets => 'Pets',
    ExpenseCategory.repairs => 'Repairs',
    ExpenseCategory.other => 'Other',
  };

  String get label => switch (this) {
    // Names the gap plainly rather than dressing it as a category somebody
    // chose.
    ExpenseCategory.uncategorized => 'Not sorted',
    ExpenseCategory.groceries => 'Groceries',
    ExpenseCategory.rent => 'Rent',
    ExpenseCategory.utilities => 'Utilities',
    ExpenseCategory.internet => 'Internet',
    ExpenseCategory.household => 'Household',
    ExpenseCategory.transport => 'Transport',
    ExpenseCategory.eatingOut => 'Eating out',
    ExpenseCategory.entertainment => 'Entertainment',
    ExpenseCategory.health => 'Health',
    ExpenseCategory.pets => 'Pets',
    ExpenseCategory.repairs => 'Repairs',
    ExpenseCategory.other => 'Other',
  };

  IconData get icon => switch (this) {
    ExpenseCategory.uncategorized => Icons.help_outline_rounded,
    ExpenseCategory.groceries => Icons.shopping_basket_outlined,
    ExpenseCategory.rent => Icons.home_outlined,
    ExpenseCategory.utilities => Icons.bolt_outlined,
    ExpenseCategory.internet => Icons.wifi_rounded,
    ExpenseCategory.household => Icons.chair_outlined,
    ExpenseCategory.transport => Icons.directions_bus_outlined,
    ExpenseCategory.eatingOut => Icons.restaurant_outlined,
    ExpenseCategory.entertainment => Icons.movie_outlined,
    ExpenseCategory.health => Icons.medical_services_outlined,
    ExpenseCategory.pets => Icons.pets_outlined,
    ExpenseCategory.repairs => Icons.build_outlined,
    ExpenseCategory.other => Icons.more_horiz_rounded,
  };
}

/// How an expense is divided.
enum SplitKind {
  /// `shareValue` is ignored. An **empty** share list means everyone in the
  /// guild - the common case (rent, internet).
  @JsonValue('Equal')
  equal,

  /// `shareValue` is a weight: "Anna counts double, she has the big room".
  @JsonValue('Shares')
  shares,

  /// `shareValue` is that person's exact minor-unit amount, and the shares
  /// must sum to the total.
  @JsonValue('Exact')
  exact,
}

extension SplitKindX on SplitKind {
  String get wireValue => switch (this) {
    SplitKind.equal => 'Equal',
    SplitKind.shares => 'Shares',
    SplitKind.exact => 'Exact',
  };

  String get label => switch (this) {
    SplitKind.equal => 'Equally',
    SplitKind.shares => 'By shares',
    SplitKind.exact => 'Exact amounts',
  };

  String get description => switch (this) {
    SplitKind.equal => 'Split down the middle between everyone included',
    SplitKind.shares => 'Weights - someone with the big room can count double',
    SplitKind.exact => 'Type each person\'s amount; they have to add up',
  };
}

@freezed
sealed class ExpenseShareDto with _$ExpenseShareDto {
  const factory ExpenseShareDto({
    @Default('') String userId,

    /// Weight or exact minor amount, depending on the expense's
    /// [ExpenseDto.splitKind]; ignored entirely for [SplitKind.equal].
    @Default(0) int shareValue,

    /// What this person actually owes, in minor units - computed server-side,
    /// including the remainder distribution.
    @Default(0) int amountMinor,
  }) = _ExpenseShareDto;

  factory ExpenseShareDto.fromJson(Map<String, dynamic> json) =>
      _$ExpenseShareDtoFromJson(json);
}

/// One entry in a `Ledger` channel.
///
/// Money is **integer minor units** everywhere - rappen, cents. Every split
/// and balance is integer arithmetic, which is what guarantees shares sum to
/// the total and balances sum to exactly zero. Never send a decimal, and
/// never compute shares client-side and pass them off as [SplitKind.exact] -
/// you'll disagree with the server on rounding.
@freezed
sealed class ExpenseDto with _$ExpenseDto {
  @ApiDateTimeConverter()
  const factory ExpenseDto({
    required String id,
    required String channelId,

    /// Who actually paid - often not [createdByUserId], who merely typed it in.
    @Default('') String payerUserId,
    @Default('') String description,
    @Default(0) int amountMinor,
    @Default('CHF') String currency,
    DateTime? occurredAt,
    @Default(SplitKind.equal)
    @JsonKey(unknownEnumValue: SplitKind.equal)
    SplitKind splitKind,
    @Default('') String createdByUserId,
    @Default(<ExpenseShareDto>[]) List<ExpenseShareDto> shares,

    /// What it was for. Coarse on purpose - see [ExpenseCategory]. Expenses
    /// that predate the field arrive as `Uncategorized`, which is a real
    /// bucket in the rollup rather than a synonym for "Other".
    @Default(ExpenseCategory.uncategorized)
    @JsonKey(unknownEnumValue: ExpenseCategory.uncategorized)
    ExpenseCategory category,
  }) = _ExpenseDto;

  factory ExpenseDto.fromJson(Map<String, dynamic> json) =>
      _$ExpenseDtoFromJson(json);
}

/// One page of a ledger's history, newest first.
///
/// `GET /expenses` used to answer with a bare array capped at 200, which
/// quietly stopped showing history at an arbitrary point - a house that has
/// been running for three years has more than that. Pass [nextCursor] back as
/// `cursor` for the next page; null means you've reached the end.
@freezed
sealed class ExpensePageDto with _$ExpensePageDto {
  const factory ExpensePageDto({
    @Default(<ExpenseDto>[]) List<ExpenseDto> items,
    String? nextCursor,
  }) = _ExpensePageDto;

  factory ExpensePageDto.fromJson(Map<String, dynamic> json) =>
      _$ExpensePageDtoFromJson(json);
}

/// A member's net position. Positive means the house owes *them*.
///
/// Balances always sum to zero, and members sitting at zero are omitted
/// entirely - so an empty list means the house is settled, not that nothing
/// has been spent.
@freezed
sealed class LedgerBalanceDto with _$LedgerBalanceDto {
  const factory LedgerBalanceDto({
    @Default('') String userId,
    @Default(0) int netMinor,
  }) = _LedgerBalanceDto;

  factory LedgerBalanceDto.fromJson(Map<String, dynamic> json) =>
      _$LedgerBalanceDtoFromJson(json);
}

/// One leg of the minimal set of payments that settles the house - at most
/// n-1 of them, so four flatmates settle with two payments, not six.
@freezed
sealed class TransferSuggestionDto with _$TransferSuggestionDto {
  const factory TransferSuggestionDto({
    @Default('') String fromUserId,
    @Default('') String toUserId,
    @Default(0) int amountMinor,
  }) = _TransferSuggestionDto;

  factory TransferSuggestionDto.fromJson(Map<String, dynamic> json) =>
      _$TransferSuggestionDtoFromJson(json);
}

/// What the house spent over a window, and how much of it was the caller's.
///
/// This answers "what does this flat cost per month", which is the first thing
/// anybody asks and about the only number that changes behaviour. Everything is
/// whole minor units, so the buckets sum back to [totalMinor] exactly.
@freezed
sealed class LedgerSummaryDto with _$LedgerSummaryDto {
  @ApiDateTimeConverter()
  const factory LedgerSummaryDto({
    @Default('') String channelId,
    @Default('CHF') String currency,
    DateTime? from,
    DateTime? to,
    @Default(0) int totalMinor,

    /// The caller's own share of everything in the window - their half of the
    /// shop, not what they happened to pay for. This is the number people
    /// actually want.
    @Default(0) int myShareMinor,
    @Default(<LedgerCategoryTotalDto>[]) List<LedgerCategoryTotalDto> byCategory,

    /// **Not zero-filled.** A month with no spending is absent rather than
    /// present as a zero, so a chart must not draw the gap as a data point.
    @Default(<LedgerPeriodTotalDto>[]) List<LedgerPeriodTotalDto> byPeriod,
    @Default(<LedgerPayerTotalDto>[]) List<LedgerPayerTotalDto> byPayer,

    /// The requested window was longer than the cap and was shortened. Shown
    /// rather than silently applied: a total that quietly covers less than what
    /// was asked for is a number somebody will act on and be wrong about.
    @Default(false) bool clamped,
  }) = _LedgerSummaryDto;

  factory LedgerSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$LedgerSummaryDtoFromJson(json);
}

@freezed
sealed class LedgerCategoryTotalDto with _$LedgerCategoryTotalDto {
  const factory LedgerCategoryTotalDto({
    @Default(ExpenseCategory.uncategorized)
    @JsonKey(unknownEnumValue: ExpenseCategory.uncategorized)
    ExpenseCategory category,
    @Default(0) int totalMinor,
    @Default(0) int myShareMinor,
    @Default(0) int count,
  }) = _LedgerCategoryTotalDto;

  factory LedgerCategoryTotalDto.fromJson(Map<String, dynamic> json) =>
      _$LedgerCategoryTotalDtoFromJson(json);
}

@freezed
sealed class LedgerPeriodTotalDto with _$LedgerPeriodTotalDto {
  const factory LedgerPeriodTotalDto({
    /// `2026-07`. A month, because that is the unit rent, salaries and every
    /// other household comparison already run on.
    @Default('') String period,
    @Default(0) int totalMinor,
    @Default(0) int myShareMinor,
    @Default(0) int count,
  }) = _LedgerPeriodTotalDto;

  factory LedgerPeriodTotalDto.fromJson(Map<String, dynamic> json) =>
      _$LedgerPeriodTotalDtoFromJson(json);
}

/// What each member fronted over the window.
///
/// Deliberately **not** a balance: it says who has been carrying the cash flow,
/// which is a different question from who owes whom.
@freezed
sealed class LedgerPayerTotalDto with _$LedgerPayerTotalDto {
  const factory LedgerPayerTotalDto({
    @Default('') String userId,
    @Default(0) int paidMinor,
  }) = _LedgerPayerTotalDto;

  factory LedgerPayerTotalDto.fromJson(Map<String, dynamic> json) =>
      _$LedgerPayerTotalDtoFromJson(json);
}

/// A receipt photo attached to an expense. Max 4 per expense, images and PDF.
///
/// [url] is **presigned and minted per request**, which is why it must never be
/// cached: persisting the URL persists its expiry, and the first symptom of
/// that is a receipt that renders for ten minutes after upload and then 403s
/// forever.
@freezed
sealed class ExpenseReceiptDto with _$ExpenseReceiptDto {
  @ApiDateTimeConverter()
  const factory ExpenseReceiptDto({
    required String id,
    @Default('') String expenseId,
    @Default('') String fileName,
    @Default('') String contentType,
    @Default(0) int sizeBytes,
    @Default('') String uploadedByUserId,
    DateTime? uploadedAt,
    String? url,
  }) = _ExpenseReceiptDto;

  factory ExpenseReceiptDto.fromJson(Map<String, dynamic> json) =>
      _$ExpenseReceiptDtoFromJson(json);
}

/// One currency per ledger channel. Changing it **relabels** existing
/// amounts, it doesn't convert them.
@freezed
sealed class LedgerConfigDto with _$LedgerConfigDto {
  const factory LedgerConfigDto({
    @Default('') String channelId,
    @Default('CHF') String currency,
  }) = _LedgerConfigDto;

  factory LedgerConfigDto.fromJson(Map<String, dynamic> json) =>
      _$LedgerConfigDtoFromJson(json);
}
