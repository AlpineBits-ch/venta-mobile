import '../../features/billing/data/models/entitlement_value.dart';

/// What this room may carry, as it rides the room snapshot.
///
/// **Not an event, and there must never be one.** A room's limits can change
/// mid-call - a grant expires, a plan lapses at period end - and the room is
/// the one surface somebody is looking at while it happens. A second unordered
/// channel into the same room would race the snapshot stream with no way to
/// order the two, which is the exact bug the snapshot's version counter exists
/// to prevent. So limits ride the snapshot, are version-gated with everything
/// else on it, and a change to them advances the version.
///
/// **Absent means "no limit information", never "no limits".** A room whose
/// limits have never been computed sends none, and a client that read that as
/// "unlimited" would draw a camera button on a room that will refuse it.
///
/// [publisherCount] is room state rather than entitlement state, and is here
/// for the reason any slot count is anywhere: "2 of 2 people are sharing" is a
/// sentence, and "you cannot share" is a mystery.
class VoiceRoomLimitsDto {
  const VoiceRoomLimitsDto({
    this.maxParticipants,
    this.videoCeiling,
    this.maxPublishers,
    this.publisherCount,
  });

  final EntitlementValueDto? maxParticipants;

  /// A ladder value. Its rung is the name to render; nothing here maps a rung
  /// to a pixel count, because that mapping is the server's and inventing one
  /// puts a pricing decision in a Dart file.
  final EntitlementValueDto? videoCeiling;

  final EntitlementValueDto? maxPublishers;
  final int? publisherCount;

  factory VoiceRoomLimitsDto.fromJson(Map<String, dynamic> json) {
    final count = json['publisherCount'];
    return VoiceRoomLimitsDto(
      maxParticipants: _value(json['maxParticipants']),
      videoCeiling: _value(json['videoCeiling']),
      maxPublishers: _value(json['maxPublishers']),
      publisherCount: count is num ? count.toInt() : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'maxParticipants': ?maxParticipants?.toJson(),
    'videoCeiling': ?videoCeiling?.toJson(),
    'maxPublishers': ?maxPublishers?.toJson(),
    'publisherCount': ?publisherCount,
  };

  /// The rung this room distributes video at, e.g. `720p30`, or null when the
  /// ceiling is absent or arrived in a shape this build cannot read.
  String? get videoRung => videoCeiling?.kind == EntitlementValueKind.ladder
      ? videoCeiling?.rung
      : null;

  /// **`none` is a real rung, not an absence.** It means audio-only, and it is
  /// how "this server is over its video budget" is said without refusing the
  /// call - which is the whole point of a ladder that has a bottom instead of a
  /// flag that has an off.
  ///
  /// A rung this build has never heard of is deliberately not audio-only: a
  /// name added after this release is a rung *above* the ones here, and reading
  /// an unknown as the bottom would turn a new tier into a downgrade.
  bool get isAudioOnly => videoRung?.trim().toLowerCase() == 'none';

  /// How many people may publish video at once, or null for no countable
  /// ceiling.
  int? get publisherCeiling {
    final value = maxPublishers;
    if (value == null) return null;
    if (value.kind != EntitlementValueKind.numeric) return null;
    if (value.unlimited) return null;
    final ceiling = value.value;
    return ceiling == null || ceiling < 0 ? null : ceiling;
  }

  /// How many people may be in the room, or null for no countable ceiling.
  int? get participantCeiling {
    final value = maxParticipants;
    if (value == null) return null;
    if (value.kind != EntitlementValueKind.numeric) return null;
    if (value.unlimited) return null;
    final ceiling = value.value;
    return ceiling == null || ceiling <= 0 ? null : ceiling;
  }

  /// Whether every video slot in this room is taken.
  bool get publishersFull {
    final ceiling = publisherCeiling;
    return ceiling != null && (publisherCount ?? 0) >= ceiling;
  }

  /// Whether asking to publish video here would only be refused.
  ///
  /// Read by the camera and share controls so they are disabled rather than
  /// pressed into a refusal. This is a *pre-emption* and not the decision: the
  /// server decides at publish time against state that can have moved since
  /// this snapshot, so the refusal path stays wired either way.
  bool get canPublishVideo => !isAudioOnly && !publishersFull;

  /// Why video cannot be published right now, or null when it can.
  ///
  /// States what is true and stops. It does not say what the ceiling would have
  /// to be, and it attributes nothing: the limits block carries no reason code,
  /// so naming a plan here would be a guess between the server's and the
  /// member's own - the exact mistake the `boundBy` field exists to prevent
  /// where a reason *is* available.
  String? get videoBlockedSentence {
    if (isAudioOnly) {
      return 'This room is audio-only. Cameras and screen sharing are off for '
          'everyone here.';
    }
    if (publishersFull) {
      final ceiling = publisherCeiling;
      return ceiling == 1
          ? 'Someone else is already sharing video here.'
          : '${publisherCount ?? ceiling} of $ceiling people here are already '
                'sharing video.';
    }
    return null;
  }

  /// "3 of 10", for the roster header, or null when the room has no countable
  /// ceiling to be a denominator.
  String? occupancyLabel(int present) {
    final ceiling = participantCeiling;
    return ceiling == null ? null : '$present of $ceiling';
  }

  /// "1 of 2 sharing", or null when there is no ceiling on publishers.
  String? get publisherLabel {
    final ceiling = publisherCeiling;
    return ceiling == null ? null : '${publisherCount ?? 0} of $ceiling sharing';
  }

  @override
  bool operator ==(Object other) =>
      other is VoiceRoomLimitsDto &&
      other.maxParticipants == maxParticipants &&
      other.videoCeiling == videoCeiling &&
      other.maxPublishers == maxPublishers &&
      other.publisherCount == publisherCount;

  @override
  int get hashCode =>
      Object.hash(maxParticipants, videoCeiling, maxPublishers, publisherCount);

  static EntitlementValueDto? _value(Object? raw) => raw is Map
      ? EntitlementValueDto.fromJson(
          raw.map((key, value) => MapEntry('$key', value)),
        )
      : null;
}

/// Decoders for the snapshot's optional `limits` object.
///
/// Top-level rather than a converter class because the value is hand-rolled -
/// an entitlement value is discriminated on `kind` and an unrecognised one has
/// to decode to a neutral "unknown" rather than throw, which is not something a
/// generated union does.
VoiceRoomLimitsDto? voiceRoomLimitsFromJson(Map<String, dynamic>? json) =>
    json == null ? null : VoiceRoomLimitsDto.fromJson(json);

Map<String, dynamic>? voiceRoomLimitsToJson(VoiceRoomLimitsDto? limits) =>
    limits?.toJson();
