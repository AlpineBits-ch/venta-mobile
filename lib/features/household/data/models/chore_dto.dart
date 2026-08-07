import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/format/api_date_time.dart';

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
  @ApiDateTimeConverter()
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
  @ApiDateTimeConverter()
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

    /// When somebody last nudged about this, or null if nobody has.
    ///
    /// **It never says who**, here or anywhere downstream, and that is the
    /// design rather than an omission: the whole value of a nudge is that the
    /// app does the asking so nobody in the house has to be the one who nags.
    /// Attributing it puts the social cost straight back.
    ///
    /// Read it to grey the button. A second nudge inside 12 hours is a `409`,
    /// and offering an action that cannot work is worse than not offering it.
    DateTime? nudgedAt,
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

  /// Whether a nudge would be accepted, as far as this client can tell.
  ///
  /// The server owns the real answer and refuses for reasons no board can see -
  /// the guild's quiet hours, chiefly, which reject rather than defer. This
  /// only hides the button in the cases that are certain: it is your own chore,
  /// it is settled, it is not late yet, or the cooldown is still running.
  bool canNudge(String viewerUserId, {DateTime? now, int graceHours = 0}) {
    if (!isOpen) return false;
    if (viewerUserId.isEmpty || viewerUserId == assignedUserId) return false;
    final at = now ?? DateTime.now();
    if (!dueAt.toUtc().add(Duration(hours: graceHours)).isBefore(at.toUtc())) {
      return false;
    }
    return nextNudgeAt == null || !nextNudgeAt!.isAfter(at.toUtc());
  }

  /// The 12-hour cooldown is per occurrence, not per sender - so somebody else
  /// having nudged an hour ago is exactly as blocking as having nudged
  /// yourself.
  static const nudgeCooldown = Duration(hours: 12);

  DateTime? get nextNudgeAt => nudgedAt?.toUtc().add(nudgeCooldown);
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

    /// How many days of the window this member was actually here for.
    ///
    /// The balance is weighted by it, so being away no longer reads as being
    /// behind. Worth surfacing rather than hiding, because it lets the board
    /// *explain* the number: "40 minutes light over the 16 days you were here"
    /// is a sentence people accept, where the bare number is the thing they
    /// argue with.
    @Default(0) int presentDays,
  }) = _ChoreBalanceEntryDto;

  factory ChoreBalanceEntryDto.fromJson(Map<String, dynamic> json) =>
      _$ChoreBalanceEntryDtoFromJson(json);
}
