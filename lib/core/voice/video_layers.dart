import 'dart:ui' show PlatformDispatcher;

import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../features/billing/data/models/entitlement_ladder.dart';

/// The simulcast layers this client publishes video in, and the names the
/// server chooses between when it decides what each viewer is served.
///
/// **The names are a ranking, not an abbreviation, and their alphabetical order
/// is load-bearing.** The SFU's only ordering vocabulary is `asciibetical` -
/// a-z, "a most desirable, z least" - and it governs both what a congested
/// viewer is dropped to and what an unavailable layer falls back to. Neither
/// rule is told what the names mean, so the alphabet *is* the quality order.
/// The WebRTC convention `q`/`h`/`f` sorts backwards against quality and would
/// quietly ask the SFU to degrade a struggling viewer *up* to full resolution;
/// these match the server's `VoiceVideoLayers`, which is the contract these
/// rids have to answer.
///
/// Publishing them is the half that makes server-side layer selection real. The
/// server already picks a layer per viewer from the tile size they report, but
/// a publisher that sends a single encoding has no layers to pick between, so
/// every viewer is served full quality whatever size they draw it - which is
/// the entire bill the choice exists to reduce.
class VideoLayers {
  const VideoLayers._();

  /// Full resolution.
  static const String high = 'a';

  /// Half resolution.
  static const String medium = 'b';

  /// Quarter resolution.
  static const String low = 'c';

  /// The height the bitrates below are quoted at. Everything scales from here
  /// by pixel area, so raising the capture size raises the ladder with it
  /// instead of sending 1080 lines through a budget tuned for 720.
  static const int _bitrateAnchorHeight = 720;

  /// The camera ladder: three layers, so a viewer rendering a 120px tile can be
  /// served roughly a tenth of the bitrate the publisher's own preview costs.
  ///
  /// **The 1:2:4 relationship is a contract, not a preference.** The server's
  /// layer ceiling arithmetic assumes exactly it - `b` is half the top encode
  /// and `c` a quarter of it - so the ladder is generated from whatever the top
  /// encode actually is rather than written down against one size. A ladder
  /// whose rungs did not line up would have the server serving viewers a layer
  /// it had mis-measured.
  ///
  /// The uplink cost of the extra two encodings is the publisher's, and it is
  /// the trade this whole mechanism is: the top layer's bitrate out of one
  /// phone against full quality times every viewer in the room. `maxBitrate` is
  /// a ceiling rather than a target, so congestion control still settles below
  /// it on a link that cannot carry it.
  static List<RTCRtpEncoding> cameraFor(int topHeight) => [
    RTCRtpEncoding(
      rid: high,
      scaleResolutionDownBy: 1,
      maxBitrate: _scaledBitrate(1200 * 1000, topHeight),
    ),
    RTCRtpEncoding(
      rid: medium,
      scaleResolutionDownBy: 2,
      maxBitrate: _scaledBitrate(350 * 1000, topHeight),
    ),
    RTCRtpEncoding(
      rid: low,
      scaleResolutionDownBy: 4,
      maxBitrate: _scaledBitrate(120 * 1000, topHeight),
    ),
  ];

  /// The screen ladder, deliberately two layers rather than three.
  ///
  /// A shared screen is mostly text, and text at quarter resolution is not a
  /// cheaper picture but an unreadable one - a share nobody can read is a
  /// broken feature rather than an economical one. Both layers therefore carry
  /// more bitrate than the camera equivalents at the same scale.
  ///
  /// A viewer the server decides should get [low] simply has no such layer to
  /// pull, which is a case the transport already handles: the subscribe asks
  /// the SFU to fall back to a layer the publisher actually sends rather than
  /// to send nothing. That costs the saving on that one tile and nothing else.
  ///
  /// Fixed rather than scaled from the capture size, unlike the camera: nothing
  /// here chooses how large a display is, and a legible number of bits for text
  /// is a property of the text rather than of the panel it was rendered on.
  static List<RTCRtpEncoding> get screen => [
    RTCRtpEncoding(
      rid: high,
      scaleResolutionDownBy: 1,
      maxBitrate: 2500 * 1000,
    ),
    RTCRtpEncoding(
      rid: medium,
      scaleResolutionDownBy: 2,
      maxBitrate: 900 * 1000,
    ),
  ];

  /// What the camera is asked to capture for [target].
  ///
  /// `ideal` and not `exact`: a handset that cannot reach the target should
  /// give its best rather than fail capture outright. What it actually gave is
  /// read back off the track afterwards, so the declaration on the publish body
  /// describes the picture rather than the request - see
  /// [VideoPublishIntent.fromTrack].
  ///
  /// The frame rate is capped as well as idealised. A camera left to itself
  /// will happily open at 60 on a rung that permits 30, and the cost of that
  /// lands on every viewer rather than on whoever chose it.
  static Map<String, dynamic> captureFor(VideoPublishIntent target) => {
    'width': {'ideal': widthFor(target.height)},
    'height': {'ideal': target.height},
    'frameRate': {'ideal': target.framerate, 'max': target.framerate},
  };

  /// The 16:9 width for [height]. Stated because the constraint takes both, and
  /// a height on its own lets a device pick its own aspect ratio.
  static int widthFor(int height) => (height * 16 / 9).round();

  static int _scaledBitrate(int atAnchor, int topHeight) {
    if (topHeight <= 0) return atAnchor;
    final ratio = topHeight / _bitrateAnchorHeight;
    return (atAnchor * ratio * ratio).round();
  }
}

/// What this client tells the server it is about to send, so the server can
/// clamp against a stated number instead of guessing from an SDP.
///
/// **A statement of intent, not a request for a rung.** It says "this is the
/// picture I am publishing"; the server answers by publishing it, or by
/// publishing less and saying so with a `voice.video_ceiling` degradation.
/// Deciding locally that a given capture size maps to a given rung would be a
/// pricing decision written in Dart, which is the one thing the ladder being on
/// the wire exists to prevent.
///
/// Every value that reaches the wire is measured or asked for, never invented.
/// The one direction it is safe to be wrong in is upward: a declaration above
/// what is really encoded earns a cap that was not needed, while one below it
/// leaves the publisher uncapped at the simulcast layer - which is the bug, and
/// on a screen share it is the expensive one.
class VideoPublishIntent {
  const VideoPublishIntent({required this.height, required this.framerate});

  final int height;
  final int framerate;

  /// What to capture at when the granted rung or the ladder cannot be read.
  ///
  /// The size this client published at before any of it was gated, kept as the
  /// fallback rather than the top of the ladder on purpose: not knowing the
  /// rung is not a reason to spend a phone's uplink as though the best one had
  /// been granted.
  static const conservative = VideoPublishIntent(height: 720, framerate: 30);

  /// Neither axis stated.
  ///
  /// A non-positive number reads as "unstated for that axis" on the wire, which
  /// makes this the honest fallback for a capture whose size nothing here chose
  /// and the platform did not report. Kept as a value rather than a null so a
  /// half-measured capture can state the axis it does know.
  static const unstated = VideoPublishIntent(height: 0, framerate: 0);

  /// Whether this says anything at all. A fully unstated intent is not sent:
  /// omitting the field and sending two zeroes mean the same thing, and one of
  /// them looks like a bug in a log.
  bool get isStated => height > 0 || framerate > 0;

  /// The picture [track] is actually producing, or [fallback] when the platform
  /// reports no readable size.
  ///
  /// Settings are the honest source: a capture opened with `ideal` constraints
  /// can land anywhere, and both ends of that - a handset that could not reach
  /// the target, and a display share whose size nothing here chose - are cases
  /// where the request is not the picture.
  ///
  /// A missing frame rate falls back rather than defaulting to zero, because a
  /// non-positive number reads as "unstated" on the wire and would silently
  /// drop that axis of the declaration.
  factory VideoPublishIntent.fromTrack(
    MediaStreamTrack track, {
    required VideoPublishIntent fallback,
  }) {
    final Map<String, dynamic> settings;
    try {
      settings = track.getSettings();
    } catch (_) {
      return fallback;
    }
    return VideoPublishIntent(
      height: _positive(settings['height']) ?? fallback.height,
      framerate:
          _positive(settings['frameRate']) ??
          _positive(settings['framerate']) ??
          fallback.framerate,
    );
  }

  Map<String, dynamic> toJson() => {'height': height, 'framerate': framerate};

  /// The number in [raw], or null when it is absent, unreadable or not a real
  /// size. Platforms report these as ints, doubles or decimal strings.
  static int? _positive(Object? raw) {
    final value = raw is num
        ? raw.toDouble()
        : raw is String
        ? double.tryParse(raw)
        : null;
    if (value == null || value <= 0) return null;
    return value.round();
  }

  @override
  bool operator ==(Object other) =>
      other is VideoPublishIntent &&
      other.height == height &&
      other.framerate == framerate;

  @override
  int get hashCode => Object.hash(height, framerate);

  @override
  String toString() => 'VideoPublishIntent(${height}p$framerate)';
}

/// What to capture the camera at in a room whose ceiling is [rung], given the
/// ladder the server published.
///
/// Null for a rung that permits no picture at all, which is `none` - a real
/// rung rather than a missing one, and one the camera controls are already
/// disabled for.
///
/// Falls back to [VideoPublishIntent.conservative] whenever the rung is not
/// named, the ladder was not published, or the ladder lists the rung without
/// usable metrics. All three mean the same thing: nothing said what this room
/// permits.
VideoPublishIntent? cameraTargetFor({
  String? rung,
  List<EntitlementLadderRungDto>? ladder,
}) {
  final entry = findLadderRung(ladder, rung);
  final height = entry?.maxHeight;
  final framerate = entry?.maxFramerate;
  if (height == null || framerate == null) {
    return VideoPublishIntent.conservative;
  }
  if (height <= 0 || framerate <= 0) return null;
  return VideoPublishIntent(height: height, framerate: framerate);
}

/// This device's own display, in physical pixels, or null when there is no view
/// to measure.
///
/// The fallback declaration for a screen share on a platform that reports no
/// track settings. A mobile share captures the display it is running on, so
/// this is not a guess at the capture size - it is the same number read from
/// the other side. Rotation needs no special case: the view reports the current
/// orientation, and a share started in either one declares what it is.
///
/// The frame rate is left unstated rather than assumed. Nothing here asks a
/// display for one, and a share's rate is whatever the platform's capturer
/// settled on.
VideoPublishIntent? displayCaptureIntent() {
  final size = PlatformDispatcher.instance.implicitView?.physicalSize;
  if (size == null || size.height <= 0 || size.width <= 0) return null;
  return VideoPublishIntent(height: size.height.round(), framerate: 0);
}
