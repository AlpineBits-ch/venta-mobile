import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/format/api_date_time.dart';
import 'inbox_breadcrumb_dto.dart';
import 'inbox_message_dto.dart';

part 'inbox_mention_dto.freezed.dart';
part 'inbox_mention_dto.g.dart';

/// How the caller was reached. Always the *most specific* one that applies:
/// somebody named directly inside an `@everyone` message gets [direct], and the
/// message appears once rather than twice.
enum InboxMentionKind {
  @JsonValue('Direct')
  direct,
  @JsonValue('Here')
  here,
  @JsonValue('Everyone')
  everyone,
  @JsonValue('Role')
  role,
}

extension InboxMentionKindX on InboxMentionKind {
  /// Whether the ✕ does anything.
  ///
  /// Only [direct] and [here] have a per-user index row to delete.
  /// `@everyone`/`@role` pings are computed from membership, so the server
  /// accepts a dismissal of one and deletes nothing - showing the affordance
  /// would be promising an action that silently doesn't happen.
  bool get isDismissible =>
      this == InboxMentionKind.direct || this == InboxMentionKind.here;

  String get label => switch (this) {
    InboxMentionKind.direct => 'Mentioned you',
    // Reached only the people who were *online* when it was sent - an idle,
    // invisible or offline user never gets one, which is worth the row saying.
    InboxMentionKind.here => '@here',
    InboxMentionKind.everyone => '@everyone',
    InboxMentionKind.role => '@role',
  };
}

/// How far back the Mentions tab looks. Capped at the index's 31-day retention
/// window regardless of what is asked for, and anything the server doesn't
/// recognise falls back to [week].
enum InboxMentionSince {
  day('24h', 'Last 24 hours'),
  week('7d', 'Last 7 days'),
  month('30d', 'Last 30 days');

  const InboxMentionSince(this.wireValue, this.label);
  final String wireValue;
  final String label;
}

/// One message that mentioned the caller.
@freezed
sealed class InboxMentionDto with _$InboxMentionDto {
  const factory InboxMentionDto({
    @Default('') String messageId,

    /// Deliberately the raw wire string rather than a `DateTime`.
    ///
    /// The mention index is keyed on this exact value and the dismiss endpoint
    /// requires it back verbatim - a re-serialised timestamp that differs by a
    /// trailing `Z` or a dropped millisecond matches no row, and the `DELETE`
    /// then succeeds while deleting nothing. Parse it for display via
    /// [InboxMentionDtoX.createdAt]; send [createdAtRaw].
    @JsonKey(name: 'createdAt') @Default('') String createdAtRaw,
    @Default(InboxMentionKind.direct)
    @JsonKey(unknownEnumValue: InboxMentionKind.direct)
    InboxMentionKind kind,

    /// Set when [kind] is [InboxMentionKind.role].
    String? roleId,
    String? roleName,
    @Default('') String authorId,

    /// Null for a DM mention, where [conversationId] is set instead.
    InboxBreadcrumbDto? breadcrumb,
    String? conversationId,
    InboxMessageDto? message,
  }) = _InboxMentionDto;

  factory InboxMentionDto.fromJson(Map<String, dynamic> json) =>
      _$InboxMentionDtoFromJson(json);
}

extension InboxMentionDtoX on InboxMentionDto {
  DateTime? get createdAt => tryParseApiDateTime(createdAtRaw);

  /// A DM mention has no guild, category or channel to render.
  bool get isDirectMessage => breadcrumb == null && conversationId != null;

  /// The MLS context the [InboxMentionDto.message] was sealed under, when it
  /// was encrypted at all.
  String? get contextId => breadcrumb?.channelId ?? conversationId;

  /// [InboxMentionKindX.label], with the role's own name where there is one.
  String get kindLabel => kind == InboxMentionKind.role && roleName != null
      ? '@$roleName'
      : kind.label;
}

/// One keyset page of [InboxMentionDto]s, newest first.
///
/// Messages deleted since being indexed are skipped rather than rendered as a
/// hole, so a page can be shorter than the requested limit while more pages
/// exist - page until [nextCursor] is null, never until a page looks short.
@freezed
sealed class InboxMentionPageDto with _$InboxMentionPageDto {
  const factory InboxMentionPageDto({
    @Default(<InboxMentionDto>[]) List<InboxMentionDto> mentions,
    String? nextCursor,
  }) = _InboxMentionPageDto;

  factory InboxMentionPageDto.fromJson(Map<String, dynamic> json) =>
      _$InboxMentionPageDtoFromJson(json);
}
