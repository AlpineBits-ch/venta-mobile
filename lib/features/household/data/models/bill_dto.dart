import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/format/api_date_time.dart';
import 'ledger_dto.dart';

part 'bill_dto.freezed.dart';
part 'bill_dto.g.dart';

/// The step a recurring bill takes between due dates.
///
/// Not the chore module's plain `intervalDays`, and the difference is the
/// point: rent is due on the first of the month, not every thirty days. A day
/// count drifts a day earlier every February; a calendar month stays anchored
/// to its day for good.
enum RecurrenceUnit {
  @JsonValue('Day')
  day,
  @JsonValue('Week')
  week,
  @JsonValue('Month')
  month,
  @JsonValue('Year')
  year,
}

extension RecurrenceUnitX on RecurrenceUnit {
  String get wireValue => switch (this) {
    RecurrenceUnit.day => 'Day',
    RecurrenceUnit.week => 'Week',
    RecurrenceUnit.month => 'Month',
    RecurrenceUnit.year => 'Year',
  };

  /// How the cadence reads in a sentence: "every month", "every 2 weeks".
  String cadenceLabel(int interval) {
    final noun = switch (this) {
      RecurrenceUnit.day => interval == 1 ? 'day' : 'days',
      RecurrenceUnit.week => interval == 1 ? 'week' : 'weeks',
      RecurrenceUnit.month => interval == 1 ? 'month' : 'months',
      RecurrenceUnit.year => interval == 1 ? 'year' : 'years',
    };
    return interval == 1 ? 'Every $noun' : 'Every $interval $noun';
  }
}

/// Where one generated instance of a bill has got to.
enum BillStatus {
  /// Generated and waiting. For a variable bill this also means nobody has
  /// said what it cost yet, which is the normal state of an electricity bill
  /// until it arrives.
  @JsonValue('Pending')
  pending,

  /// Turned into a real expense; `expenseId` points at it.
  @JsonValue('Posted')
  posted,

  /// Deliberately not charged this period - the flat was empty in August, the
  /// landlord waived it. Distinct from deleting the schedule, which would lose
  /// every future period too.
  @JsonValue('Skipped')
  skipped,
}

extension BillStatusX on BillStatus {
  String get wireValue => switch (this) {
    BillStatus.pending => 'Pending',
    BillStatus.posted => 'Posted',
    BillStatus.skipped => 'Skipped',
  };
}

@freezed
sealed class RecurringExpenseShareDto with _$RecurringExpenseShareDto {
  const factory RecurringExpenseShareDto({
    @Default('') String userId,
    @Default(0) double shareValue,
  }) = _RecurringExpenseShareDto;

  factory RecurringExpenseShareDto.fromJson(Map<String, dynamic> json) =>
      _$RecurringExpenseShareDtoFromJson(json);
}

/// The schedule behind a bill: what recurs, how often, split how.
///
/// [amountMinor] is **nullable**, and that nullability is the whole design of
/// the variable half of this feature. Rent is a number somebody types once;
/// electricity is a number that arrives on paper every quarter, and pretending
/// otherwise means either a made-up figure in the ledger or no bill at all.
@freezed
sealed class RecurringExpenseDto with _$RecurringExpenseDto {
  @ApiDateTimeConverter()
  const factory RecurringExpenseDto({
    required String id,
    required String channelId,
    @Default('') String description,

    /// Null means the amount varies and each period waits for a figure.
    /// [autoPost] is only legal alongside a fixed amount.
    int? amountMinor,
    @Default('CHF') String currency,
    @Default('') String payerUserId,
    @Default(SplitKind.equal)
    @JsonKey(unknownEnumValue: SplitKind.equal)
    SplitKind splitKind,
    @Default(ExpenseCategory.uncategorized)
    @JsonKey(unknownEnumValue: ExpenseCategory.uncategorized)
    ExpenseCategory category,
    @Default(RecurrenceUnit.month)
    @JsonKey(unknownEnumValue: RecurrenceUnit.month)
    RecurrenceUnit recurrenceUnit,
    @Default(1) int recurrenceInterval,
    DateTime? anchorAt,
    DateTime? nextDueAt,

    /// 0-30. How far ahead the house is told a period is coming, which is the
    /// difference between a warning and a receipt.
    @Default(0) int leadDays,
    @Default(false) bool autoPost,
    @Default(false) bool isPaused,
    @Default('') String createdByUserId,
    @Default(<RecurringExpenseShareDto>[])
    List<RecurringExpenseShareDto> shares,
  }) = _RecurringExpenseDto;

  factory RecurringExpenseDto.fromJson(Map<String, dynamic> json) =>
      _$RecurringExpenseDtoFromJson(json);
}

extension RecurringExpenseX on RecurringExpenseDto {
  /// Whether each period has to be given a figure before it can be posted.
  bool get isVariable => amountMinor == null;

  String get cadenceLabel => recurrenceUnit.cadenceLabel(recurrenceInterval);
}

/// One generated instance of a [RecurringExpenseDto]: this month's rent.
///
/// It is an **obligation before it is an expense**, which is why it is not in
/// the ledger's history until somebody posts it. "Rent is due Friday and you
/// owe 850" and "Anna paid rent, you owe her 850" are different sentences about
/// different moments, and only the second one belongs in a list of what has
/// been spent.
@freezed
sealed class BillOccurrenceDto with _$BillOccurrenceDto {
  @ApiDateTimeConverter()
  const factory BillOccurrenceDto({
    required String id,
    @Default('') String recurringExpenseId,
    required String channelId,
    @Default('') String description,
    required DateTime dueAt,

    /// Null until somebody reads the figure off the letter.
    int? amountMinor,
    @Default('CHF') String currency,
    @Default(BillStatus.pending)
    @JsonKey(unknownEnumValue: BillStatus.pending)
    BillStatus status,

    /// The expense this became, once posted.
    String? expenseId,
    String? postedByUserId,
    String? skippedByUserId,
    String? skipReason,

    /// Pending with nobody having said what it cost - the cue to ask for a
    /// figure rather than to offer a "post" button that cannot work.
    @Default(false) bool needsAmount,

    /// Pending and past due. Computed server-side so every surface agrees on
    /// what late means.
    @Default(false) bool isOverdue,
  }) = _BillOccurrenceDto;

  factory BillOccurrenceDto.fromJson(Map<String, dynamic> json) =>
      _$BillOccurrenceDtoFromJson(json);
}

extension BillOccurrenceX on BillOccurrenceDto {
  bool get isPending => status == BillStatus.pending;

  /// Whether "post it" can succeed as things stand. A variable bill with no
  /// figure needs one first, and offering the action anyway buys a `400`.
  bool get isPostable => isPending && amountMinor != null;
}
