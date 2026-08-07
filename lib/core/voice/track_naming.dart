/// Which kind of media a WebRTC track carries.
///
/// These four values are the backend's `kind` strings (`Echo.Voice`'s
/// `TrackNaming`), which it derives purely from the *track name* - Cloudflare
/// stores a name and nothing else, so the naming convention in [TrackNaming]
/// is the whole contract. Naming a local track correctly is what makes the
/// server classify and broadcast it; no client ever sends a `kind` field.
enum TrackKind {
  audio,
  video,
  screen,

  /// The shared tab/application's own sound, published alongside a screen
  /// share's video as a *separate* track. Distinct from [audio], which is
  /// always the publisher's microphone.
  screenAudio,
}

/// What one track name means: the media it carries, and the screen share it
/// belongs to when it is part of one.
class TrackDescriptor {
  const TrackDescriptor({
    required this.trackName,
    required this.kind,
    this.shareId,
  });

  final String trackName;
  final TrackKind kind;

  /// The screen share this track belongs to; null for microphone and camera.
  final String? shareId;

  bool get isScreenShare =>
      kind == TrackKind.screen || kind == TrackKind.screenAudio;
}

/// The one place on the client that knows how a track name is built and taken
/// apart - the mirror of `Echo.Voice.Tracks.TrackNaming`.
///
/// The ordering trap it exists to contain: `screen-audio-{shareId}` also
/// satisfies `startsWith("screen-")`, so the screen-audio test *must* come
/// first. Backwards, a share's audio is read as the video track of a share
/// whose id is literally `audio-{shareId}` - a track that does not exist, so
/// the subscribe returns a mid nothing ever arrives on.
class TrackNaming {
  const TrackNaming._();

  /// The microphone. Exactly one per participant, always this exact name -
  /// participant announcements key off it, so it is a wire constant.
  static const String audio = 'audio';

  /// The camera. Any non-`audio`, non-`screen-`-prefixed name classifies as
  /// video server-side; this is the name this client uses.
  static const String camera = 'camera';

  static const String screenPrefix = 'screen-';
  static const String screenAudioPrefix = 'screen-audio-';

  static String screenTrack(String shareId) => '$screenPrefix$shareId';

  static String screenAudioTrack(String shareId) =>
      '$screenAudioPrefix$shareId';

  /// Classifies a track name. Anything unrecognised is a camera track rather
  /// than an error - an unknown name still has to be relayed, and refusing to
  /// describe it would drop the publish silently.
  static TrackDescriptor describe(String trackName) {
    // Order matters - see the class comment.
    if (trackName.startsWith(screenAudioPrefix)) {
      return TrackDescriptor(
        trackName: trackName,
        kind: TrackKind.screenAudio,
        shareId: trackName.substring(screenAudioPrefix.length),
      );
    }
    if (trackName.startsWith(screenPrefix)) {
      return TrackDescriptor(
        trackName: trackName,
        kind: TrackKind.screen,
        shareId: trackName.substring(screenPrefix.length),
      );
    }
    if (trackName == audio) {
      return const TrackDescriptor(trackName: audio, kind: TrackKind.audio);
    }
    return TrackDescriptor(trackName: trackName, kind: TrackKind.video);
  }

  static bool isMicrophone(String? trackName) => trackName == audio;

  static bool isScreenShare(String trackName) =>
      trackName.startsWith(screenPrefix);
}

/// Parses the wire `kind` string carried by a `TrackPublished` event.
///
/// Falls back to [TrackKind.video] for an unrecognised value, matching the
/// server's own fallback in `TrackNaming.Describe` - a kind this build does
/// not know about must not silently drop the track.
TrackKind trackKindFromWire(String kind) => switch (kind) {
  'audio' => TrackKind.audio,
  'screen' => TrackKind.screen,
  'screenAudio' => TrackKind.screenAudio,
  _ => TrackKind.video,
};
