/// One reduction, as the client reads it.
///
/// **A degradation rides a `200`.** It is a sibling of the normal response
/// body on the request that caused it, and it means the action succeeded and
/// succeeded smaller: the eleventh person into a full voice room gets an
/// audio-only seat, and the publisher who asked for 1080p60 in a 720p30 server
/// publishes 720p30. Nothing rolls back on one, and an absent `degradations`
/// array is the normal case rather than an error path.
///
/// Because it rides the causing response, the plan screen cannot ask for one.
/// `DegradationInterceptor` reads them off responses as they arrive and
/// `DegradationLog` holds them for the session, which is what lets a screen
/// opened later say that a request was limited to 720p30.
///
/// **`remedy` and `actorCanRemedy` are deliberately not modelled.** They are on
/// the wire, and they are the server's answer to "what would lift this limit,
/// and can this caller do it". This client answers neither question, in copy or
/// in any other form. A field read by nothing is how a control arrives later by
/// accident, so the two are not read at all.
///
/// **The copy below states what happened and attributes it, and stops.** It
/// does not say what would change the limit, does not measure it against
/// anything, and does not characterise it as temporary or liftable. "Limited by
/// your plan" is a fact about a request that already completed. An earlier draft
/// of this file said a paired ceiling was "the lower of the two", which reads as
/// an invitation to raise one of them - that is an offer with the verb left out,
/// and it is the exact shape this file must not have.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

import 'entitlement_snapshot_dto.dart';
import 'entitlement_value.dart';

part 'entitlement_degradation_dto.freezed.dart';
part 'entitlement_degradation_dto.g.dart';

/// Which side bound.
///
/// Closed and versioned server-side, which is why an `unknown` member is
/// mandatory rather than defensive: this build will eventually receive a code
/// added after it shipped, and the rule for that is the generic sentence.
enum DegradationReason {
  @JsonValue('guild_plan_limit')
  guildPlanLimit,
  @JsonValue('user_plan_limit')
  userPlanLimit,
  @JsonValue('paired_ceiling')
  pairedCeiling,

  /// The instance operator's own cap, which is not a plan limit at all. Worth
  /// telling apart from the other three: on a self-hosted instance it is the
  /// only reason that can occur, and attributing one of those to "your plan"
  /// would be simply false.
  @JsonValue('operator_ceiling')
  operatorCeiling,

  unknown,
}

/// Which side of a pair actually bound. Two values and no third: an operator
/// ceiling belongs to no subject, so it carries no `boundBy` at all rather than
/// a third value clients would have to learn.
enum DegradationBoundBy {
  @JsonValue('guild')
  guild,
  @JsonValue('user')
  user,
  unknown,
}

/// The reason vocabulary, read from a wire code.
///
/// A separate lookup from the generated enum map because a hard denial (§4)
/// carries the same vocabulary under a different field name and arrives on an
/// error response, where there is no generated decoder to reach for. One table
/// serves both, which is the whole reason the server made the two vocabularies
/// the same.
DegradationReason degradationReasonOf(Object? code) => switch (code) {
  'guild_plan_limit' => DegradationReason.guildPlanLimit,
  'user_plan_limit' => DegradationReason.userPlanLimit,
  'paired_ceiling' => DegradationReason.pairedCeiling,
  'operator_ceiling' => DegradationReason.operatorCeiling,
  _ => DegradationReason.unknown,
};

/// Which side bound, or null when the payload named no side at all.
///
/// Absent and unreadable are different: an operator ceiling carries no side
/// because there is no party behind it, and a value this build cannot read is
/// one it must not guess at. Both end up in the same sentence, but only because
/// that sentence names neither side.
DegradationBoundBy? degradationBoundByOf(Object? code) => switch (code) {
  null => null,
  'guild' => DegradationBoundBy.guild,
  'user' => DegradationBoundBy.user,
  _ => DegradationBoundBy.unknown,
};

extension DegradationReasonX on DegradationReason {
  /// What applied the limit, in one clause. Attribution and nothing else.
  ///
  /// Every arm is of the form "limited by X". None of them says what X would
  /// have to be for the limit not to apply, because that sentence is the offer
  /// this platform does not make - and the difference between the two is only a
  /// few words, which is why the whole vocabulary is written out here in one
  /// place rather than assembled per call site.
  ///
  /// `paired_ceiling` still splits in two, driven by `boundBy`. That split is
  /// the whole reason the field exists: without it a member paying for their
  /// own plan is eventually told that plan limited them, which is both wrong
  /// and the exact error the paired rule was built to prevent. A paired ceiling
  /// with no side, or a side this build cannot read, attributes the limit to a
  /// plan without naming whose rather than guessing between "you" and "this
  /// server".
  String sentence(DegradationBoundBy? boundBy) => switch (this) {
    DegradationReason.guildPlanLimit => "Limited by this server's plan.",
    DegradationReason.userPlanLimit => 'Limited by your plan.',
    DegradationReason.pairedCeiling => switch (boundBy) {
      DegradationBoundBy.guild => "Limited by this server's plan.",
      DegradationBoundBy.user => 'Limited by your plan.',
      _ => 'Limited by a plan.',
    },
    DegradationReason.operatorCeiling => 'Limited by this instance.',
    // Never the raw code. A reason this build has no copy for is still a
    // reduction the user is owed a plain account of.
    DegradationReason.unknown => 'A limit applied.',
  };
}

/// A request that succeeded with less than it asked for.
@freezed
sealed class EntitlementDegradationDto with _$EntitlementDegradationDto {
  const factory EntitlementDegradationDto({
    /// The catalogue key that bound. The display-name lookup is keyed on it -
    /// see [entitlementKeyLabel].
    @Default('') String key,

    /// What was asked for and what was given. Always the same shape as each
    /// other and as the key's declared kind, which is what lets the sentence
    /// name both numbers.
    EntitlementValueDto? requested,
    EntitlementValueDto? granted,

    @JsonKey(unknownEnumValue: DegradationReason.unknown)
    @Default(DegradationReason.unknown)
    DegradationReason reason,

    @JsonKey(unknownEnumValue: DegradationBoundBy.unknown)
    DegradationBoundBy? boundBy,

    /// Whose limit this was. For a paired ceiling it is the side named by
    /// [boundBy].
    @Default(EntitlementSubjectDto()) EntitlementSubjectDto subject,
  }) = _EntitlementDegradationDto;

  const EntitlementDegradationDto._();

  factory EntitlementDegradationDto.fromJson(Map<String, dynamic> json) =>
      _$EntitlementDegradationDtoFromJson(json);

  /// "1080p60 was reduced to 720p30", or null when the payload carried only one
  /// side of it.
  ///
  /// Both halves or neither. Half of it reads as a statement about the limit
  /// when it is actually a statement about the request, and telling those two
  /// apart is the only thing a person wants from this line.
  ///
  /// Past tense throughout, and about this one request. It says what the server
  /// did, not what the ceiling is - a standing ceiling stated next to a plan
  /// list is a comparison, and a comparison is the thing being avoided.
  String? get change {
    final from = requested;
    final to = granted;
    if (from == null || to == null) return null;
    if (from == to) return null;
    return '${describeEntitlementValue(key, from)} was reduced to '
        '${describeEntitlementValue(key, to)}';
  }

  /// The one line to put in front of somebody at the surface that caused this,
  /// while they are still looking at it.
  ///
  /// Shorter than the session log's three lines, and in the present tense,
  /// because it describes what the user is looking at rather than something
  /// that happened earlier: "Video quality: 720p30. Limited by this server's
  /// plan." The log says what changed; this says what they have got.
  ///
  /// Falls back to the attribution alone when the payload named no grant. A
  /// half-sentence about a number that is not there reads as a bug, and the
  /// attribution on its own is still true.
  String get notice {
    final applied = granted;
    if (applied == null) return reason.sentence(boundBy);
    return '${entitlementKeyLabel(key)}: '
        '${describeEntitlementValue(key, applied)}. '
        '${reason.sentence(boundBy)}';
  }
}
