import 'package:freezed_annotation/freezed_annotation.dart';

part 'inbox_summary_dto.freezed.dart';
part 'inbox_summary_dto.g.dart';

/// What the header badge renders from.
@freezed
sealed class InboxSummaryDto with _$InboxSummaryDto {
  const factory InboxSummaryDto({
    @Default(0) int unreadChannelCount,
    @Default(0) int mentionCount,

    /// The real numbers are higher than reported. Counting further would be an
    /// unbounded scan for a number that renders as `99+` either way.
    @Default(false) bool capped,
  }) = _InboxSummaryDto;

  factory InboxSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$InboxSummaryDtoFromJson(json);
}

extension InboxSummaryDtoX on InboxSummaryDto {
  bool get hasMentions => mentionCount > 0;

  bool get hasAnything => mentionCount > 0 || unreadChannelCount > 0;

  /// Everything waiting, as one number.
  ///
  /// The two counts are different units - mentions are messages, the other is
  /// channels - so this is a "how much is in there" total rather than a count
  /// of any single thing, and a channel holding one mention contributes to
  /// both. That's the deliberate trade: a badge that only counted mentions
  /// showed nothing at all for an inbox full of unread channels, which is no
  /// use as the answer to "is there anything in there". [badgeBreakdown] is
  /// what says which is which.
  int get badgeCount => mentionCount + unreadChannelCount;

  /// The badge's text. `99+` once [InboxSummaryDto.capped] - meaning the real
  /// numbers are higher than reported and counting further would be an
  /// unbounded scan - or past two digits, where a third one no longer fits the
  /// badge anyway.
  String get badgeLabel => capped || badgeCount > 99 ? '99+' : '$badgeCount';

  /// The tooltip, which is where the two counts get to be themselves again.
  String get badgeBreakdown {
    if (!hasAnything) return 'Inbox';
    final parts = [
      if (mentionCount > 0)
        '$mentionCount mention${mentionCount == 1 ? '' : 's'}',
      if (unreadChannelCount > 0)
        '$unreadChannelCount unread channel'
            '${unreadChannelCount == 1 ? '' : 's'}',
    ];
    return 'Inbox - ${parts.join(', ')}${capped ? ' or more' : ''}';
  }
}
