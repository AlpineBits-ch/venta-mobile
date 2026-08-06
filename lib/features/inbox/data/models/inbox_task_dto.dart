import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/format/api_date_time.dart';
import 'inbox_breadcrumb_dto.dart';

part 'inbox_task_dto.freezed.dart';
part 'inbox_task_dto.g.dart';

/// What kind of household row is waiting.
///
/// [unknown] is this client's own sentinel, not a server value: more kinds are
/// being added, and an unrecognised one still has a title, a subtitle and
/// somewhere to land. Nothing gates *rendering* on this - it only picks an
/// icon and the deep link.
enum InboxTaskKind {
  @JsonValue('ChoreDue')
  choreDue,
  @JsonValue('DecisionVote')
  decisionVote,
  @JsonValue('ListAssignment')
  listAssignment,
  unknown,
}

extension InboxTaskKindX on InboxTaskKind {
  IconData get icon => switch (this) {
    InboxTaskKind.choreDue => Icons.cleaning_services_outlined,
    InboxTaskKind.decisionVote => Icons.how_to_vote_outlined,
    InboxTaskKind.listAssignment => Icons.checklist_outlined,
    // Deliberately generic rather than absent: a kind this build has never
    // heard of is still a thing somebody has to do.
    InboxTaskKind.unknown => Icons.push_pin_outlined,
  };
}

/// One household row waiting on the caller: a chore due, a decision unvoted, a
/// list item assigned to them.
///
/// Separate from the Unread tab because it answers a different question. A list
/// channel holds no messages, so it can never *be* unread - which left the
/// modules people most want reminding about with no inbox presence at all.
@freezed
sealed class InboxTaskDto with _$InboxTaskDto {
  @ApiDateTimeConverter()
  const factory InboxTaskDto({
    @Default(InboxTaskKind.unknown)
    @JsonKey(unknownEnumValue: InboxTaskKind.unknown)
    InboxTaskKind kind,

    /// The occurrence, decision or list item. What to deep-link on.
    @Default('') String targetId,
    @Default(InboxBreadcrumbDto()) InboxBreadcrumbDto breadcrumb,
    @Default('') String title,
    @Default('') String subtitle,

    /// Null for a list assignment, which has no deadline.
    DateTime? dueAt,

    /// **Respects the chore's grace period** - two hours late inside a 24-hour
    /// grace is not overdue, so this is never re-derived from [dueAt] here. A
    /// decision is overdue the moment it closes.
    @Default(false) bool isOverdue,
  }) = _InboxTaskDto;

  factory InboxTaskDto.fromJson(Map<String, dynamic> json) =>
      _$InboxTaskDtoFromJson(json);
}

/// Everything waiting, in one shot.
///
/// **No cursor** - it is a to-do list, not a feed. [truncated] says more were
/// waiting than the limit allowed, and the module boards remain the way to read
/// a whole one.
@freezed
sealed class InboxTaskPageDto with _$InboxTaskPageDto {
  const factory InboxTaskPageDto({
    @Default(<InboxTaskDto>[]) List<InboxTaskDto> tasks,
    @Default(false) bool truncated,
  }) = _InboxTaskPageDto;

  factory InboxTaskPageDto.fromJson(Map<String, dynamic> json) =>
      _$InboxTaskPageDtoFromJson(json);
}
