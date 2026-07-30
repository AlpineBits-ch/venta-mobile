import 'package:freezed_annotation/freezed_annotation.dart';

part 'chore_dto.freezed.dart';
part 'chore_dto.g.dart';

/// A recurring chore definition. Occurrences are generated from it by the
/// server - clients never create those.
///
/// Exactly one of [rotationRoleId] and [fixedAssigneeUserId] is set: a chore
/// either rotates through a role's membership or belongs to one person. The
/// rotation is **not** round-robin - the next turn goes to whoever in the pool
/// has completed the fewest weighted minutes lately, which is why
/// [effortMinutes] matters and why skipping doesn't get you off the hook.
@freezed
sealed class ChoreDto with _$ChoreDto {
  const factory ChoreDto({
    required String id,
    required String channelId,
    required String title,
    String? description,

    /// 1-365. The cadence steps from [anchorAt].
    @Default(7) int intervalDays,
    DateTime? anchorAt,

    /// 1-600. The fairness weight - taking the bins out doesn't count the
    /// same as cleaning the bathroom.
    @Default(15) int effortMinutes,

    /// The rotation pool is just this role's membership, so adding someone to
    /// the rota means giving them the role.
    String? rotationRoleId,
    String? fixedAssigneeUserId,

    /// How long past [ChoreOccurrenceDto.dueAt] before it counts as overdue.
    @Default(0) int graceHours,
    @Default(false) bool isPaused,
    DateTime? nextDueAt,
  }) = _ChoreDto;

  factory ChoreDto.fromJson(Map<String, dynamic> json) =>
      _$ChoreDtoFromJson(json);
}

/// One generated turn at a [ChoreDto].
///
/// [completedByUserId] can differ from [assignedUserId] - the balance credits
/// the *assignee* either way, deliberately, so nobody can farm the ledger by
/// doing everyone's easy chores. Both are worth showing ("Ben did Anna's
/// washing-up").
@freezed
sealed class ChoreOccurrenceDto with _$ChoreOccurrenceDto {
  const factory ChoreOccurrenceDto({
    required String id,
    required String choreId,
    required String channelId,

    /// Denormalized off the chore so a board can render without joining.
    @Default('') String title,
    required DateTime dueAt,
    @Default('') String assignedUserId,

    /// Snapshot at generation time - editing the chore's weight doesn't
    /// retroactively repay past turns.
    @Default(0) int effortMinutes,
    DateTime? completedAt,
    String? completedByUserId,
    DateTime? skippedAt,
    @Default(false) bool isOverdue,
  }) = _ChoreOccurrenceDto;

  factory ChoreOccurrenceDto.fromJson(Map<String, dynamic> json) =>
      _$ChoreOccurrenceDtoFromJson(json);
}

extension ChoreOccurrenceX on ChoreOccurrenceDto {
  bool get isCompleted => completedAt != null;

  /// Skipped is **not** done: it credits nothing, which is exactly what makes
  /// the rotation land back on the same person.
  bool get isSkipped => skippedAt != null && completedAt == null;

  bool get isOpen => completedAt == null && skippedAt == null;

  /// Someone covered for the assignee.
  bool get wasDoneBySomeoneElse =>
      completedByUserId != null &&
      completedByUserId!.isNotEmpty &&
      completedByUserId != assignedUserId;
}

/// One member's standing in the fairness ledger.
///
/// [balanceMinutes] is relative to the household *average*, not an absolute
/// total, so it reads as "behind/ahead of your share" - negative is behind.
@freezed
sealed class ChoreBalanceEntryDto with _$ChoreBalanceEntryDto {
  const factory ChoreBalanceEntryDto({
    @Default('') String userId,
    @Default(0) int completedMinutes,
    @Default(0) int completedCount,
    @Default(0) int balanceMinutes,
  }) = _ChoreBalanceEntryDto;

  factory ChoreBalanceEntryDto.fromJson(Map<String, dynamic> json) =>
      _$ChoreBalanceEntryDtoFromJson(json);
}
