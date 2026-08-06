import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/format/api_date_time.dart';

part 'ledger_dto.freezed.dart';
part 'ledger_dto.g.dart';

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
