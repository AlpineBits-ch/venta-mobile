import 'package:freezed_annotation/freezed_annotation.dart';

import 'track_naming.dart';

part 'voice_subscription_set.freezed.dart';
part 'voice_subscription_set.g.dart';

/// How the server is ranking audio in this room.
class VoiceSubscriptionMode {
  const VoiceSubscriptionMode._();

  /// Everyone publishing is in the set. **This does not mean the set can be
  /// ignored**: it is only ever sent when something is being withheld, so an
  /// `all` set still says less than "pull everybody" would.
  static const String all = 'all';

  /// The room is above the ranking threshold, so audio is the people actually
  /// talking rather than all forty-nine other participants.
  static const String activeSpeaker = 'activeSpeaker';
}

/// The simulcast layer the server has decided this viewer should be served for
/// one video track.
///
/// **A ranking vocabulary, not a rid and not a resolution.** `a` is the top
/// encoding, `b` the middle, `c` the bottom, and the mapping onto whatever the
/// local SDK calls its own layers is this client's job - see
/// `videoQualityForLayer`. The server never sees a rid, never sends one, and
/// never matches one, which is exactly why the value is opaque: a name that
/// looked like a resolution would invite a client to act on the number instead
/// of the ranking.
class VoiceVideoLayer {
  const VoiceVideoLayer._();

  static const String full = 'a';
  static const String medium = 'b';
  static const String low = 'c';
}

/// One track this client should be pulling, as the server sees it.
@freezed
sealed class VoiceSubscriptionTrackDto with _$VoiceSubscriptionTrackDto {
  /// [mediaSessionId] may be null for a share published before the server
  /// recorded its session - the handle is in the `TrackPublished` already
  /// received. It is never null for audio.
  ///
  /// [layer] is null for audio, and for video it is what this viewer will
  /// actually be served rather than a request to make.
  const factory VoiceSubscriptionTrackDto({
    required String userId,
    String? mediaSessionId,
    required String trackName,
    @Default('video') String kind,
    String? shareId,
    String? layer,
  }) = _VoiceSubscriptionTrackDto;

  const VoiceSubscriptionTrackDto._();

  factory VoiceSubscriptionTrackDto.fromJson(Map<String, dynamic> json) =>
      _$VoiceSubscriptionTrackDtoFromJson(json);

  TrackKind get trackKind => trackKindFromWire(kind);

  /// The key this track is tracked under locally. Shares carry their id so one
  /// participant running two of them does not collide with themselves.
  String get key => shareId == null
      ? '$userId|$trackName'
      : '$userId|$trackName|$shareId';
}

/// What this client should be pulling, complete.
///
/// Arrives three ways with the same inner fields, but not the same reach: the
/// snapshot **nests** it under `subscriptions` (and omits that key entirely
/// when there is no set), while the `SubscriptionsChanged` event and the reply
/// to `POST .../voice/subscriptions` **flatten** it onto their own envelope. One
/// parser handles the inner object; the caller decides where to point it.
///
/// **It only ever removes.** A set never asks for something the all-to-all
/// behaviour would not also have asked for, so applying one can never break a
/// subscription that was valid.
@freezed
sealed class VoiceSubscriptionSetDto with _$VoiceSubscriptionSetDto {
  /// [tracks] is **nullable, and the null is the whole point**:
  ///
  /// | value | meaning |
  /// |---|---|
  /// | absent / `null` | no set in force - pull everyone `Publishing` |
  /// | `[]` | a real set that is empty - pull *nobody* |
  /// | `[...]` | pull exactly these |
  ///
  /// Defaulting it to `[]` reads the first row as the second, which is the
  /// difference between an ordinary small room and a client that unsubscribes
  /// from every participant. Nothing about that failure is loud: the payload is
  /// well-formed, no request is refused, and the room simply goes quiet.
  ///
  /// The null arm is also the *revocation* signal - it is what a room dropping
  /// back below the ranking threshold sends, and the only direct notice of it
  /// there is.
  const factory VoiceSubscriptionSetDto({
    @Default(VoiceSubscriptionMode.all) String mode,
    @Default(0) int revision,
    @Default(<String>[]) List<String> activeSpeakers,
    List<VoiceSubscriptionTrackDto>? tracks,
  }) = _VoiceSubscriptionSetDto;

  const VoiceSubscriptionSetDto._();

  factory VoiceSubscriptionSetDto.fromJson(Map<String, dynamic> json) =>
      _$VoiceSubscriptionSetDtoFromJson(json);

  bool get isRanked => mode == VoiceSubscriptionMode.activeSpeaker;

  /// Whether this says anything at all about what to pull. False is a
  /// revocation, not an empty set.
  bool get isInForce => tracks != null;
}

/// Reads the `subscriptions` field, which is **absent or null in the ordinary
/// small room** and means "pull everyone who is `Publishing`" when it is.
///
/// Written by hand rather than left to the generator because the difference
/// between "no set" and "an empty set" is the difference between pulling
/// everybody and pulling nobody, and a `@Default` on the field would quietly
/// turn the first into the second.
VoiceSubscriptionSetDto? voiceSubscriptionSetFromJson(Object? json) =>
    json is Map<String, dynamic>
    ? VoiceSubscriptionSetDto.fromJson(json)
    : null;

Object? voiceSubscriptionSetToJson(VoiceSubscriptionSetDto? set) =>
    set?.toJson();

/// Holds the subscription set currently in force and decides whether an
/// incoming one may replace it.
///
/// The guard is `revision`, and it is unrelated to the room `version` the event
/// envelope carries. Two server instances can interleave, so a payload whose
/// revision is *lower* than one already applied is a late arrival describing a
/// set that has since moved on - applying it would resubscribe to whoever was
/// talking a moment ago and then wait for the next change to correct itself.
///
/// A set arriving from a snapshot is taken wholesale exactly like the roster,
/// including its revision.
class VoiceSubscriptionPlan {
  /// Only ever holds a set that is **in force** - one whose `tracks` is
  /// non-null. A revocation clears this rather than being stored, so
  /// `_current != null` implies there is a real list to consult.
  VoiceSubscriptionSetDto? _current;

  /// The highest revision seen, kept **across a revocation**.
  ///
  /// Without it, a revocation would forget the ordering and the next stale
  /// payload from a second server instance would be adopted as though it were
  /// new - narrowing subscriptions back down to whoever was talking a moment
  /// before the room went unplanned.
  int? _lastRevision;

  /// The set in force, or null when the server has not sent one - which is the
  /// ordinary small room, and means "everyone who is `Publishing`".
  VoiceSubscriptionSetDto? get current => _current;

  /// Whether the server is managing this client's subscriptions at all.
  bool get isManaged => _current != null;

  /// Everyone the server has ranked as talking, for ordering. Empty when
  /// nothing is ranked.
  List<String> get activeSpeakers => _current?.activeSpeakers ?? const [];

  /// Adopts [set] unless it is older than what has already been applied.
  ///
  /// Three inputs, three meanings, and they are not interchangeable:
  ///
  ///  * **null** - the surface carried no set object at all, which is what a
  ///    snapshot with no `subscriptions` key means. Authoritative and taken
  ///    wholesale like the rest of a snapshot, so it clears unconditionally and
  ///    forgets the revision with it.
  ///  * **a set whose `tracks` is null** - an explicit revocation: the room
  ///    dropped below the ranking threshold, or stopped withholding anything.
  ///    Revision-ordered, because it is a point in the same sequence as the
  ///    sets around it.
  ///  * **a set with tracks** - what to pull, complete.
  ///
  /// Returns true when what is held actually changed, so a caller can skip the
  /// diff-and-apply pass on a duplicate - which is most of them, since every
  /// snapshot carries the current set whether or not it moved.
  bool adopt(VoiceSubscriptionSetDto? set) {
    if (set == null) {
      _lastRevision = null;
      if (_current == null) return false;
      _current = null;
      return true;
    }

    final lastRevision = _lastRevision;
    if (lastRevision != null && set.revision < lastRevision) return false;
    _lastRevision = set.revision;

    if (!set.isInForce) {
      // A revocation. Falling back to "pull everyone publishing" is what it
      // means, and it is the caller's reconcile pass that acts on it.
      if (_current == null) return false;
      _current = null;
      return true;
    }

    if (_current == set) return false;
    _current = set;
    return true;
  }

  void reset() {
    _current = null;
    _lastRevision = null;
  }

  /// Whether this client should be pulling [trackName] from [userId].
  ///
  /// True when no set is in force, because the absence of a set is the
  /// instruction to pull everyone who is publishing. An *empty* set in force is
  /// the opposite instruction and correctly answers false for everybody.
  bool allows({
    required String userId,
    required String trackName,
    String? shareId,
  }) {
    final tracks = _current?.tracks;
    if (tracks == null) return true;
    return tracks.any(
      (t) =>
          t.userId == userId &&
          t.trackName == trackName &&
          (shareId == null || t.shareId == null || t.shareId == shareId),
    );
  }

  /// The layer the server has chosen for one video track, or null when it has
  /// said nothing - no set in force, or a track it is not managing.
  String? layerFor({required String userId, required String trackName}) {
    for (final track in _current?.tracks ?? const <VoiceSubscriptionTrackDto>[]) {
      if (track.userId == userId && track.trackName == trackName) {
        return track.layer;
      }
    }
    return null;
  }
}
