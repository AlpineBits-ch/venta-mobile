import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;

import '../diagnostics/voice_diagnostics.dart';

/// One live picture, as the UI receives it: the **stream the media SDK already
/// owns**, the track inside it, and a live reading of whether anything is
/// actually arriving on it.
///
/// **The stream is the point.** `RTCVideoRenderer.srcObject` takes a
/// `MediaStream`, not a track, and this used to be satisfied by wrapping each
/// track in a throwaway stream built with `createLocalMediaStream` +
/// `addTrack`. That is a platform round trip, and it fails - reported from a
/// real handset as `PlatformException(mediaStreamAddTrack: Track is nil)` -
/// whenever the native track is released between the moment the Dart reference
/// was read and the moment the call lands. A camera flip does exactly that:
/// `LocalVideoTrack.restartTrack` stops the old track and disposes its stream
/// before creating the replacement. The failed attach left the renderer holding
/// nothing, the future was never awaited, and the tile stayed black for the rest
/// of the session with no error anywhere.
///
/// Both SDK tracks - local and remote - already carry the real stream the track
/// lives in. Handing that up costs no platform call and cannot fail.
@immutable
class VoiceVideoFeed {
  const VoiceVideoFeed({
    required this.stream,
    required this.track,
    this.health,
  });

  /// The stream to give a renderer. Owned by the media SDK; never disposed from
  /// the UI, which does not know when the track behind it is being replaced.
  final rtc.MediaStream stream;

  final rtc.MediaStreamTrack track;

  /// Live health for an *incoming* picture, or null for one this device is
  /// producing. Nothing subscribes to its own camera, so there are no receiver
  /// statistics for it and a local tile that is black is a capture problem
  /// rather than a delivery one.
  final ValueListenable<VoiceTrackHealth>? health;

  /// Identifies the picture rather than the object, so a widget can tell "the
  /// same feed rebuilt" from "a different feed" without holding the previous
  /// one.
  String get id => '${stream.id}|${track.id}';

  @override
  bool operator ==(Object other) =>
      other is VoiceVideoFeed &&
      other.stream.id == stream.id &&
      other.track.id == track.id;

  @override
  int get hashCode => Object.hash(stream.id, track.id);

  @override
  String toString() => 'VoiceVideoFeed($id)';
}

/// What is known about one incoming track, from the SFU's own receiver
/// statistics plus the publication state around them.
///
/// Read rather than acted on: nothing here changes a subscription. It exists so
/// a black tile can say *which* black it is, which is the difference between a
/// subscription that was never granted, a publisher who muted, a link carrying
/// nothing, and a decoder that refused what arrived.
@immutable
class VoiceTrackHealth {
  const VoiceTrackHealth({
    this.subscribed = false,
    this.senderMuted = false,
    this.bytesReceived = 0,
    this.packetsReceived = 0,
    this.framesDecoded = 0,
    this.framesReceived = 0,
    this.frameWidth = 0,
    this.frameHeight = 0,
    this.mimeType,
    this.decoder,
    this.trackName,
    this.subscribedAt,
    this.updatedAt,
    this.lastFrameAt,
  });

  /// Whether the SDK holds a live subscription to the publication.
  final bool subscribed;

  /// Whether the *publisher* has muted the track. A black tile here is correct
  /// and must not be reported as a fault.
  final bool senderMuted;

  final int bytesReceived;

  /// Packets, separately from bytes. The pair separates "the SFU is forwarding
  /// nothing at all" from "packets are arriving and being discarded", which are
  /// a routing question and a payload question respectively.
  final int packetsReceived;

  final int framesDecoded;
  final int framesReceived;
  final int frameWidth;
  final int frameHeight;

  /// e.g. `video/VP8`, `video/H264`. The single most useful field when frames
  /// arrive and none decode.
  final String? mimeType;

  /// What the platform selected to decode with, e.g. `HWDecoder`. Empty or
  /// absent where the platform does not report one.
  final String? decoder;

  /// The publication's name as the SFU carries it. Recorded because the whole
  /// roster keys off this string, and a publisher that names a track differently
  /// - the SDK's own default rather than this app's convention - is
  /// indistinguishable from a delivery failure without it.
  final String? trackName;

  /// When this client last asked for the track. The clock every grace period
  /// below is measured from - a tile is not accused of anything for the first
  /// few seconds, because a subscription that has not produced a frame yet is
  /// the ordinary state of one that is about to.
  final DateTime? subscribedAt;

  /// When statistics were last read. Null means none have been, which is itself
  /// meaningful: the SDK only monitors a track it considers active.
  final DateTime? updatedAt;

  /// When [framesDecoded] last moved, so a picture that arrived and then
  /// stopped is distinguishable from one that never started.
  final DateTime? lastFrameAt;

  VoiceTrackHealth copyWith({
    bool? subscribed,
    bool? senderMuted,
    int? bytesReceived,
    int? packetsReceived,
    int? framesDecoded,
    int? framesReceived,
    int? frameWidth,
    int? frameHeight,
    String? mimeType,
    String? decoder,
    String? trackName,
    DateTime? subscribedAt,
    DateTime? updatedAt,
    DateTime? lastFrameAt,
  }) => VoiceTrackHealth(
    subscribed: subscribed ?? this.subscribed,
    senderMuted: senderMuted ?? this.senderMuted,
    bytesReceived: bytesReceived ?? this.bytesReceived,
    packetsReceived: packetsReceived ?? this.packetsReceived,
    framesDecoded: framesDecoded ?? this.framesDecoded,
    framesReceived: framesReceived ?? this.framesReceived,
    frameWidth: frameWidth ?? this.frameWidth,
    frameHeight: frameHeight ?? this.frameHeight,
    mimeType: mimeType ?? this.mimeType,
    decoder: decoder ?? this.decoder,
    trackName: trackName ?? this.trackName,
    subscribedAt: subscribedAt ?? this.subscribedAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastFrameAt: lastFrameAt ?? this.lastFrameAt,
  );

  /// One line, for the diagnostics readout and for a fault's detail.
  String describe() =>
      '${trackName ?? '?'} ${mimeType ?? 'codec?'} ${decoder ?? ''} '
              'rx=${bytesReceived}B/${packetsReceived}p '
              'frames=$framesReceived/$framesDecoded '
              '${frameWidth}x$frameHeight '
              'sub=$subscribed muted=$senderMuted '
              '${updatedAt == null ? 'nostats' : 'stats'}'
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
}

/// Why a tile is not showing a picture.
///
/// Ordered by how far down the path the failure is, and each arm is a different
/// investigation - which is the whole reason the enum exists rather than one
/// "no video" state.
enum VoiceTileFault {
  /// The renderer never took the stream.
  attachFailed(
    VoiceFaultCodes.attach,
    'Video could not be attached',
    'The picture arrived but this device could not bind it to a view.',
  ),

  /// The roster says there is a picture and no track has reached this device
  /// at all - so there is nothing to measure and nothing to render.
  noTrack(
    VoiceFaultCodes.notSubscribed,
    'No video received',
    'The room says this camera is on and no track has arrived on this device.',
  ),

  /// The publication exists and this client is not subscribed to it.
  notSubscribed(
    VoiceFaultCodes.notSubscribed,
    'Not subscribed',
    'The server has not included this camera in what this device may pull.',
  ),

  /// The publisher muted the track. Not a failure.
  senderPaused(
    VoiceFaultCodes.senderPaused,
    'Camera paused',
    'The other side has paused their camera.',
  ),

  /// Subscribed, nothing arriving.
  noData(
    VoiceFaultCodes.noData,
    'No video arriving',
    'Subscribed, and not one byte has been received.',
  ),

  /// Arriving, nothing decoding. On a handset this is nearly always the
  /// publisher's codec or H.264 profile, not the network.
  notDecoding(
    VoiceFaultCodes.noDecode,
    'Cannot decode this video',
    "Video is arriving and this device's decoder produced no frames from it.",
  ),

  /// Decoding, nothing drawn.
  notRendering(
    VoiceFaultCodes.noFrames,
    'Video not drawing',
    'Frames are being decoded and the view has never been given one.',
  ),

  /// It worked and stopped.
  stalled(
    VoiceFaultCodes.stalled,
    'Video stopped',
    'Frames were arriving and have stopped.',
  );

  const VoiceTileFault(this.code, this.message, this.explanation);

  /// The trace code, shared with [VoiceFaultCodes].
  final String code;

  /// The short line drawn on the tile.
  final String message;

  /// The sentence behind it, for the diagnostics panel.
  final String explanation;
}

/// How long a tile is given before it is allowed to accuse anything.
///
/// A subscription that has not produced a frame in its first seconds is the
/// ordinary state of one that is about to: the SFU has to be told, the keyframe
/// has to be requested, and the decoder has to start. An overlay that appeared
/// in that window would be on screen for every tile in every room, which is the
/// fastest way to teach somebody to ignore it.
const Duration voiceTileGrace = Duration(seconds: 5);

/// How long a picture must be absent after having worked before it is called
/// stalled rather than merely between keyframes.
const Duration voiceTileStallAfter = Duration(seconds: 6);

/// Why this tile is black, or null if it is not black or nothing can be said
/// yet.
///
/// A pure function of what is observable so it can be tested without a room:
/// the mechanisms this exists to tell apart are all racy against a real SFU, and
/// a classifier that could only be exercised live would be checked once.
///
/// [hasFrame] is the renderer's own answer - it has been handed a frame with a
/// real size - and is the only input that is not from the wire. It is what
/// separates "the picture is fine and something else is wrong" from every arm
/// below.
///
/// [awaitingSince] is when the tile was first drawn *expecting* a picture. It is
/// the only way to name the case where nothing arrived at all: there is no
/// track, so there is no health, so every other arm has nothing to read. Null
/// for a tile that is not owed one.
VoiceTileFault? voiceTileFaultFor({
  required VoiceTrackHealth? health,
  required bool hasFrame,
  required DateTime now,
  bool attachFailed = false,
  DateTime? awaitingSince,
}) {
  if (attachFailed) return VoiceTileFault.attachFailed;
  if (health == null) {
    // No track ever arrived. A local preview passes no [awaitingSince] and is
    // correctly left alone - there is nothing to diagnose from this side of a
    // capture this device opened.
    if (awaitingSince == null || hasFrame) return null;
    return now.difference(awaitingSince) < voiceTileGrace
        ? null
        : VoiceTileFault.noTrack;
  }
  if (health.senderMuted) return VoiceTileFault.senderPaused;

  if (hasFrame) {
    final last = health.lastFrameAt;
    if (last != null && now.difference(last) > voiceTileStallAfter) {
      return VoiceTileFault.stalled;
    }
    return null;
  }

  // Nothing drawn yet. Everything below is only allowed to speak once the
  // subscription has had time to produce something.
  final since = health.subscribedAt;
  if (since == null || now.difference(since) < voiceTileGrace) return null;

  if (!health.subscribed) return VoiceTileFault.notSubscribed;
  if (health.bytesReceived <= 0) return VoiceTileFault.noData;
  if (health.framesDecoded <= 0) return VoiceTileFault.notDecoding;
  return VoiceTileFault.notRendering;
}
