import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'adaptive_progress_indicator.dart';
import 'camera_switch_button.dart';
import 'video_participant_tile.dart';

/// The self-preview in a voice grid: this device's own camera, with the two
/// controls that only ever apply to it.
///
/// Everything here is deliberately absent from the remote tiles. Nobody flips
/// somebody else's camera, and nobody's own picture is mirrored except their
/// own - so rather than growing flags on `VideoParticipantTile`, the local case
/// is its own widget wrapped around the same renderer.
///
/// **No size is reported.** Which simulcast layer a publisher is served at is a
/// question about what this client *pulls*, and nobody pulls their own picture:
/// the preview renders the capture directly off the local track. That is also
/// why opening it full-screen needs nothing negotiated - full screen is simply
/// the same frames drawn larger, at whatever the camera was opened at.
class LocalCameraTile extends StatefulWidget {
  const LocalCameraTile({
    super.key,
    required this.track,
    required this.isFrontCamera,
    required this.onSwitchCamera,
    required this.onTap,
    this.width = 160,
    this.height = 120,
  });

  /// See `VideoParticipantTile.track` - re-read by the caller on every cubit
  /// emission, since a `MediaStreamTrack` cannot live in cubit state. A camera
  /// flip replaces it, so this changing is normal rather than exceptional.
  final MediaStreamTrack? track;

  /// Drives the mirroring. A front camera is mirrored because that is what
  /// every camera app and every mirror does; a back camera must not be, or the
  /// world reads backwards - text on a whiteboard being the giveaway.
  final bool isFrontCamera;

  final Future<void> Function() onSwitchCamera;

  /// Opens this preview full-screen.
  final VoidCallback onTap;

  final double width;
  final double height;

  @override
  State<LocalCameraTile> createState() => _LocalCameraTileState();
}

class _LocalCameraTileState extends State<LocalCameraTile> {
  /// True from the moment the flip is pressed until the other camera is live.
  /// The capture stops for that whole stretch, so without saying so the tile
  /// just freezes - and a frozen self-preview is the thing people tap twice.
  bool _switching = false;

  void _open() {
    unawaited(HapticFeedback.selectionClick());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          // Under the controls, so the flip button gets the taps that land on
          // it and the rest of the tile still opens full-screen.
          Positioned.fill(
            child: VideoParticipantTile(
              track: widget.track,
              width: widget.width,
              height: widget.height,
              mirror: widget.isFrontCamera,
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: _switching ? 1 : 0,
                duration: const Duration(milliseconds: 180),
                child: const ColoredBox(
                  color: Colors.black45,
                  child: Center(
                    child: AdaptiveProgressIndicator(
                      size: 20,
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // An `InkWell` rather than a bare gesture: this is a 160-pixel tile
          // with two overlays on it, and a press that lights up is the only
          // thing telling you which of them you actually hit.
          //
          // Labelled here rather than around the whole tile, so the flip button
          // above it keeps its own label instead of being swallowed into one
          // unreadable node.
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: Semantics(
                button: true,
                label: 'Your camera. Opens full screen',
                child: InkWell(
                  onTap: _open,
                  borderRadius: BorderRadius.circular(12),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          // Top left: the top right of the tile is the diagnostics badge's, and
          // an affordance that moves when a developer preference is flipped is
          // worse than one in a slightly less conventional corner.
          Positioned(
            top: 6,
            left: 6,
            child: IgnorePointer(
              child: _Glyph(
                child: Icon(
                  Icons.fullscreen_rounded,
                  size: 16,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 6,
            left: 6,
            child: IgnorePointer(
              child: _Glyph(
                child: Text(
                  'You',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 6,
            right: 6,
            child: CameraSwitchButton(
              onSwitch: widget.onSwitchCamera,
              onBusyChanged: (busy) {
                if (mounted) setState(() => _switching = busy);
              },
              compact: true,
            ),
          ),
        ],
      ),
    );
  }
}

/// A scrim behind a small overlay, so a label stays readable over a bright
/// frame without dimming the picture as a whole.
class _Glyph extends StatelessWidget {
  const _Glyph({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        child: child,
      ),
    );
  }
}
