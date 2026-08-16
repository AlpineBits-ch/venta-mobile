import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../diagnostics/video_diagnostics_prefs.dart';
import '../voice/voice_video_feed.dart';

/// The decoded size of the picture actually arriving on this track, next to the
/// tile height this client asked the server for.
///
/// Exists to make server-side simulcast selection observable. A publisher sends
/// one track at several sizes at once, the SFU forwards exactly one of them per
/// viewer, and it chooses using the height `VoiceTileHeights` reports - none of
/// which is visible from here. A share that *looks* soft is indistinguishable
/// from a share that is being served a low layer, so both numbers are shown
/// together: the pair is evidence, either one alone is an anecdote.
///
/// **Read off the frame, never off the request.** [renderer] publishes what the
/// decoder handed the sink - the frame buffer's own dimensions on Android, and
/// `RTCVideoFrame.width`/`.height` on darwin. The obvious-looking alternative,
/// `MediaStreamTrack.getSettings()`, returns an empty map on a *remote* track:
/// the platform fills that in only for a capture this device opened. That is
/// why `VideoPublishIntent.fromTrack` may use it and this may not - there it
/// describes our own camera, here it would quietly print a fallback constant
/// and read as confirmation. A readout that lies is worse than no readout.
///
/// **Deliberately not labelled `a`/`b`/`c`.** Which rid a given size corresponds
/// to is a property of the *publisher's* ladder, and a viewer cannot know it:
/// our own screen ladder is two rungs where the desktop's is three, so the same
/// 960x540 is `b` from one publisher and could be something else from another.
/// An inferred label is the same class of lie this widget exists to catch.
class ReceivedResolutionBadge extends StatelessWidget {
  const ReceivedResolutionBadge({
    super.key,
    required this.renderer,
    this.reportedDevicePixels,
    this.health,
  });

  final RTCVideoRenderer renderer;

  /// The receiver's own readings, when there are any. Adds the codec and the
  /// decoder to the line - which is what turns "the picture is soft" into
  /// "H.264 on a software decoder", and is the pair that answers a black tile
  /// that has bytes arriving. Null for a local preview.
  final ValueListenable<VoiceTrackHealth>? health;

  /// What this tile last told the server, or null for a tile that tells it
  /// nothing - the local self-preview, since nobody subscribes to their own
  /// picture.
  ///
  /// Per *tile*, not per publisher: `VoiceTileHeights` posts the largest across
  /// a publisher's tiles, so with a full-screen view open over a grid tile the
  /// grid badge shows its own smaller number while the server is acting on the
  /// larger one. Compare the full-screen badge when checking server behaviour.
  final int? reportedDevicePixels;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: VideoDiagnosticsPrefs.enabled,
      builder: (context, showing, _) {
        if (!showing) return const SizedBox.shrink();
        return ValueListenableBuilder<RTCVideoValue>(
          valueListenable: renderer,
          builder: (context, value, _) {
            // Gated on a real width rather than on `renderVideo`, which
            // `RTCVideoValue.copyWith` derives from the *previous* width and so
            // reads false on the first size event - the one moment the number
            // is most wanted.
            if (value.width <= 0) return const SizedBox.shrink();
            final rotation = value.rotation != 0 ? ' ${value.rotation}deg' : '';
            final asked = reportedDevicePixels?.toString() ?? '-';
            final line =
                '${value.width.toInt()}x${value.height.toInt()}$rotation'
                '  asked ${asked}px';
            return DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                child: _Readout(line: line, health: health),
              ),
            );
          },
        );
      },
    );
  }
}

/// The resolution line, with the receiver's own reading under it when there is
/// one.
///
/// Two lines rather than one long one: the top line is the pair the badge was
/// built for - what arrived against what was asked for - and putting the codec
/// on the same line would push that pair off the side of a grid tile.
class _Readout extends StatelessWidget {
  const _Readout({required this.line, required this.health});

  final String line;
  final ValueListenable<VoiceTrackHealth>? health;

  static const _style = TextStyle(
    color: Colors.white,
    fontSize: 11,
    fontFamily: 'monospace',
  );

  @override
  Widget build(BuildContext context) {
    final health = this.health;
    if (health == null) return Text(line, style: _style);
    return ValueListenableBuilder<VoiceTrackHealth>(
      valueListenable: health,
      builder: (context, reading, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(line, style: _style),
          Text(
            reading.describe(),
            style: _style.copyWith(fontSize: 9, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
