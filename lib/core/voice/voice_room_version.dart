/// What a client should do with a voice event, once its `instanceId`/`version`
/// have been checked against what the client already holds.
enum VoiceEventVerdict {
  /// The event is exactly the next one. Apply it and advance the held version.
  apply,

  /// A duplicate, or an older event from a second server instance arriving
  /// late. Dropping it is what stops it overwriting newer state.
  ignore,

  /// Either the room was rebuilt under a new `instanceId`, or a version was
  /// skipped. Either way this client cannot know what it missed - refetch the
  /// snapshot.
  refetch,
}

/// Tracks `(instanceId, version)` for one voice room and decides what to do
/// with each incoming event.
///
/// This is the mechanism that makes voice recoverable, and the one thing a
/// client cannot skip: without the gap branch, a single dropped event leaves
/// the roster wrong until the session ends, and no later event ever repairs
/// it. The branches, in this order:
///
///  * **`instanceId` mismatch** - the room was destroyed and rebuilt (a Redis
///    loss). Versions restart from zero, so they collide with numbers already
///    seen behind a completely different roster. Compared *first*, because it
///    is the only signal a rebuild gives.
///  * **relay events** - `SpeakingChanged`, `CameraChanged` and
///    `SubscriptionsChanged` are not stored server-side and do not bump the
///    version, so they arrive carrying the version already held. They are
///    applied without advancing anything: advancing on a relay would let it
///    stand in for a state change actually missed, and the next real event would
///    then look contiguous when it is not.
///
///    `SubscriptionsChanged` is in that list for a second reason on top of the
///    first. The subscription set moves at *conversational* frequency - every
///    time the ranked speaker changes - so versioning it would make every
///    sentence anybody says look like a missed roster change to every client in
///    the room, and answer each one with a snapshot refetch. It carries its own
///    `revision` instead, which is unrelated to the version and is guarded
///    separately in `VoiceSubscriptionPlan`.
///  * **`version < held`** - *strictly* older. Events from two server
///    instances can interleave, and one arriving late must not overwrite newer
///    state.
///  * **`version == held`** - applied, not dropped. One mutation can produce
///    several events: publishing a screen share with audio bumps the version
///    once and then emits one `TrackPublished` per track, all at that version.
///    Treating equal versions as duplicates would drop every track after the
///    first, so a share with audio would arrive silent and a share published
///    alongside a camera would lose one of them. Handlers must therefore be
///    idempotent - they are, since each sets a value or adds a track by name
///    rather than incrementing anything.
///  * **`version > held + 1`** - an event was dropped. One refetch and the
///    client is correct again.
///
/// `Snapshot` and `Resync` never reach this at all - they are full state and
/// an instruction respectively, not deltas on a version. See `VoiceRoomGate`.
class VoiceRoomVersionTracker {
  String? _instanceId;
  int _version = 0;

  String? get instanceId => _instanceId;
  int get version => _version;

  /// Whether anything has been held yet. A tracker that has never seen a
  /// snapshot treats its first event as a gap, which is correct: it has no
  /// baseline to apply a delta to.
  bool get hasBaseline => _instanceId != null;

  /// Adopts a snapshot wholesale. Snapshots are authoritative and are never
  /// merged - see the spec's "Applying a snapshot: take it wholesale".
  void adoptSnapshot({required String instanceId, required int version}) {
    _instanceId = instanceId;
    _version = version;
  }

  /// Forgets everything, so the next event forces a refetch. Used when leaving
  /// a room, and on `Resync(reason: roomGone)`.
  void reset() {
    _instanceId = null;
    _version = 0;
  }

  /// The decision for one incoming event. Advances the held version only where
  /// the event actually represents one, so a caller that forgets to act on the
  /// verdict cannot silently desync.
  ///
  /// [isRelay] marks `SpeakingChanged`, `CameraChanged` and
  /// `SubscriptionsChanged`, which carry the current version without being a
  /// change to it.
  VoiceEventVerdict evaluate({
    required String? instanceId,
    required int? version,
    bool isRelay = false,
  }) {
    // An event with no envelope at all cannot be ordered against anything, so
    // it is applied rather than dropped.
    if (instanceId == null || version == null) return VoiceEventVerdict.apply;

    if (!hasBaseline) return VoiceEventVerdict.refetch;
    if (instanceId != _instanceId) return VoiceEventVerdict.refetch;

    // Checked after the instance, before the version: a relay from a rebuilt
    // room is still about a roster this client does not have.
    if (isRelay) return VoiceEventVerdict.apply;

    if (version < _version) return VoiceEventVerdict.ignore;
    if (version > _version + 1) return VoiceEventVerdict.refetch;

    _version = version;
    return VoiceEventVerdict.apply;
  }
}
