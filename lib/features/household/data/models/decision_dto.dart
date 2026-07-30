import 'package:freezed_annotation/freezed_annotation.dart';

part 'decision_dto.freezed.dart';
part 'decision_dto.g.dart';

enum DecisionStatus {
  @JsonValue('Open')
  open,
  @JsonValue('Decided')
  decided,

  /// Every option was vetoed. Deliberately *not* "the least-hated option
  /// wins" - "we couldn't agree" is a result, and the UI should say so.
  @JsonValue('Blocked')
  blocked,
  @JsonValue('Cancelled')
  cancelled,

  /// Quorum was never reached. Abstentions don't count toward it.
  @JsonValue('Expired')
  expired,
}

extension DecisionStatusX on DecisionStatus {
  bool get isOpen => this == DecisionStatus.open;

  String get label => switch (this) {
    DecisionStatus.open => 'Open',
    DecisionStatus.decided => 'Decided',
    DecisionStatus.blocked => 'No agreement',
    DecisionStatus.cancelled => 'Cancelled',
    DecisionStatus.expired => 'Expired',
  };
}

enum VoteKind {
  @JsonValue('Support')
  support,
  @JsonValue('Abstain')
  abstain,

  /// A veto, not a downvote. It requires a reason and it beats any amount of
  /// support - see [DecisionDto].
  @JsonValue('Block')
  block,
}

extension VoteKindX on VoteKind {
  String get wireValue => switch (this) {
    VoteKind.support => 'Support',
    VoteKind.abstain => 'Abstain',
    VoteKind.block => 'Block',
  };
}

@freezed
sealed class DecisionOptionDto with _$DecisionOptionDto {
  const factory DecisionOptionDto({
    required String id,
    @Default('') String title,
    @Default(0) int position,
    @Default(0) int supportCount,

    /// Somebody vetoed this option. It cannot win no matter what
    /// [supportCount] says.
    @Default(false) bool isBlocked,
  }) = _DecisionOptionDto;

  factory DecisionOptionDto.fromJson(Map<String, dynamic> json) =>
      _$DecisionOptionDtoFromJson(json);
}

/// A standing objection. [optionId] null means the objection is to the whole
/// decision rather than one option.
@freezed
sealed class DecisionBlockDto with _$DecisionBlockDto {
  const factory DecisionBlockDto({
    @Default('') String userId,
    String? optionId,
    @Default('') String reason,
  }) = _DecisionBlockDto;

  factory DecisionBlockDto.fromJson(Map<String, dynamic> json) =>
      _$DecisionBlockDtoFromJson(json);
}

/// A house decision. **This is not a poll.**
///
/// An option carries when quorum is met and nobody has blocked it. One
/// reasoned block beats any amount of support, because the person who has to
/// live with the downside should be able to stop it - and everyone else
/// should be able to read why. Render [blocks] as objections to resolve, not
/// as a tally row.
@freezed
sealed class DecisionDto with _$DecisionDto {
  const factory DecisionDto({
    required String id,
    required String channelId,
    @Default('') String title,
    String? description,
    @Default('') String createdByUserId,
    DateTime? closesAt,

    /// Non-abstain votes needed before anything can carry.
    int? quorum,
    @Default(DecisionStatus.open)
    @JsonKey(unknownEnumValue: DecisionStatus.open)
    DecisionStatus status,
    String? outcomeOptionId,
    @Default(<DecisionOptionDto>[]) List<DecisionOptionDto> options,
    @Default(<DecisionBlockDto>[]) List<DecisionBlockDto> blocks,
    String? myVoteOptionId,
    // Absent *and* unrecognised both mean "no vote from me on record" here -
    // a client that doesn't know a future vote kind should read as not having
    // voted rather than throwing on decode.
    @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
    VoteKind? myVoteKind,
  }) = _DecisionDto;

  factory DecisionDto.fromJson(Map<String, dynamic> json) =>
      _$DecisionDtoFromJson(json);
}

extension DecisionX on DecisionDto {
  List<DecisionOptionDto> get sortedOptions =>
      [...options]..sort((a, b) => a.position.compareTo(b.position));

  /// Objections aimed at the decision as a whole rather than one option.
  List<DecisionBlockDto> get wholeDecisionBlocks =>
      blocks.where((b) => b.optionId == null).toList();

  List<DecisionBlockDto> blocksForOption(String optionId) =>
      blocks.where((b) => b.optionId == optionId).toList();

  /// Everything that has to be resolved before this can carry.
  bool get hasObjections => blocks.isNotEmpty;
}
