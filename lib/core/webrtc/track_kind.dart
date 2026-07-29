/// Which kind of media a WebRTC track carries — mirrors the `kind` string
/// the backend infers purely from the track *name* (exactly `"audio"`,
/// `"screen-"`-prefixed, or anything else counts as video — see
/// `Echo`'s `EmitTrackPublished`). Naming a local track accordingly is what
/// makes the backend classify and broadcast it correctly as
/// `guild.voice.TrackPublished`/`call.TrackPublished` — no separate "kind"
/// field is ever sent by the client.
enum TrackKind { audio, video, screen }

/// Parses the wire `kind` string carried by a `TrackPublished` event.
/// Returns `null` for `"screenAudio"` (system-audio capture isn't
/// implemented) or any other unrecognized value — callers should ignore it.
TrackKind? trackKindFromWire(String kind) => switch (kind) {
  'video' => TrackKind.video,
  'screen' => TrackKind.screen,
  _ => null,
};
