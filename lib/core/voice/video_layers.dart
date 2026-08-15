import 'package:flutter_webrtc/flutter_webrtc.dart';

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

  /// The camera ladder: three layers, so a viewer rendering a 120px tile can be
  /// served roughly a tenth of the bitrate the publisher's own preview costs.
  ///
  /// The uplink cost of the extra two encodings is the publisher's, and it is
  /// the trade this whole mechanism is: ~1.7 Mbps out of one phone against
  /// full quality times every viewer in the room.
  static List<RTCRtpEncoding> get camera => [
    RTCRtpEncoding(
      rid: high,
      scaleResolutionDownBy: 1,
      maxBitrate: 1200 * 1000,
    ),
    RTCRtpEncoding(
      rid: medium,
      scaleResolutionDownBy: 2,
      maxBitrate: 350 * 1000,
    ),
    RTCRtpEncoding(rid: low, scaleResolutionDownBy: 4, maxBitrate: 120 * 1000),
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
}
