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

  /// The badge's text: mentions are what gets a number, because they're the
  /// exact count. `99+` once [InboxSummaryDto.capped] or past two digits.
  String get badgeLabel =>
      capped || mentionCount > 99 ? '99+' : '$mentionCount';
}
