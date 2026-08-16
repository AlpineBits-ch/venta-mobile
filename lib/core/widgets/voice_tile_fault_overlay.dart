import 'dart:async';

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../diagnostics/video_diagnostics_prefs.dart';
import '../diagnostics/voice_diagnostics.dart';
import '../voice/voice_video_feed.dart';
import 'adaptive_progress_indicator.dart';
import 'voice_diagnostics_sheet.dart';

/// Says, on the picture itself, why there is no picture.
///
/// **The one diagnostic that has to work in a release build.** A tile that is
/// black is the whole of what the person watching can observe, and every
/// mechanism behind it - a subscription the server never granted, a publisher
/// who muted, a link carrying nothing, a decoder that refused the codec, a
/// renderer that never took the stream - looks identical from the outside. They
/// are five different investigations. Before this, all five were an indefinite
/// spinner over black with nothing written down anywhere.
///
/// Deliberately **not** gated on the diagnostics preference, unlike
/// [ReceivedResolutionBadge]. The badge answers a question somebody chose to
/// ask; this answers one they are already asking, on a screen they cannot use.
/// What the preference adds here is the detail line - the codec, the byte and
/// frame counts - underneath the sentence.
///
/// Everything it shows is also recorded, once per fault per tile, so a
/// screenshot and a session log say the same thing and the reference in the
/// corner is what joins them.
class VoiceTileFaultOverlay extends StatefulWidget {
  const VoiceTileFaultOverlay({
    super.key,
    required this.renderer,
    required this.health,
    this.awaitingSince,
    this.attachError,
    this.compact = false,
    this.label,
  });

  /// Read for one thing only: whether a frame with a real size has ever
  /// arrived. That is the difference between "the delivery is broken" and
  /// "delivery is fine and something else is".
  final RTCVideoRenderer renderer;

  /// Live readings for an incoming track, or null for a local preview or a tile
  /// with no track at all.
  final ValueListenable<VoiceTrackHealth>? health;

  /// When this tile started expecting a picture; null when it is not owed one.
  final DateTime? awaitingSince;

  /// Set when the renderer refused the stream.
  final Object? attachError;

  /// Drops the explanation line and shrinks the type, for a grid thumbnail
  /// there is no room to write a sentence on.
  final bool compact;

  /// What this tile is showing, for the fault log. See
  /// `VideoParticipantTile.label`.
  final String? label;

  @override
  State<VoiceTileFaultOverlay> createState() => _VoiceTileFaultOverlayState();
}

class _VoiceTileFaultOverlayState extends State<VoiceTileFaultOverlay> {
  /// Re-evaluates on a timer as well as on every reading, because two of the
  /// arms are *elapsed time* conditions - nothing arrived, and nothing arrived
  /// any more - and neither produces an event of its own.
  Timer? _tick;

  /// The fault last recorded, so a tile that cannot decode for a minute writes
  /// one entry rather than sixty.
  VoiceTileFault? _recorded;
  String? _reference;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  void _record(VoiceTileFault? fault, VoiceTrackHealth? health) {
    if (fault == _recorded) return;
    _recorded = fault;
    if (fault == null) {
      _reference = null;
      return;
    }
    _reference = VoiceDiagnostics.shared.record(
      fault.code,
      subject: widget.label ?? 'tile',
      detail: [
        fault.explanation,
        if (health != null) health.describe(),
        if (widget.attachError != null) '${widget.attachError}',
      ].join(' | '),
      // A paused camera is the sender's choice, not a failure - reporting it
      // would put a warning in Sentry every time somebody covers their camera.
      isError: fault != VoiceTileFault.senderPaused,
    );
  }

  @override
  Widget build(BuildContext context) {
    final health = widget.health;
    return ValueListenableBuilder<RTCVideoValue>(
      valueListenable: widget.renderer,
      builder: (context, video, _) {
        final hasFrame = video.width > 0 && video.height > 0;
        if (health == null) return _build(null, hasFrame);
        return ValueListenableBuilder<VoiceTrackHealth>(
          valueListenable: health,
          builder: (context, reading, _) => _build(reading, hasFrame),
        );
      },
    );
  }

  Widget _build(VoiceTrackHealth? health, bool hasFrame) {
    final fault = voiceTileFaultFor(
      health: health,
      hasFrame: hasFrame,
      now: DateTime.now(),
      attachFailed: widget.attachError != null,
      awaitingSince: widget.awaitingSince,
    );
    // Recorded outside the build's own frame: this writes to a notifier several
    // widgets listen to, and a notifier written during a build is a rebuild
    // inside a build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _record(fault, health);
    });

    if (fault == null) {
      // Still legitimately waiting: no track, nothing drawn, nothing to accuse.
      final waiting = !hasFrame && widget.awaitingSince != null;
      return IgnorePointer(
        child: waiting
            ? const Center(
                child: AdaptiveProgressIndicator(
                  size: 20,
                  strokeWidth: 2,
                  color: Colors.white54,
                ),
              )
            : const SizedBox.shrink(),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: _FaultCard(
          fault: fault,
          reference: _reference,
          health: health,
          compact: widget.compact,
          onTap: () => showVoiceDiagnosticsSheet(context),
        ),
      ),
    );
  }
}

class _FaultCard extends StatelessWidget {
  const _FaultCard({
    required this.fault,
    required this.reference,
    required this.health,
    required this.compact,
    required this.onTap,
  });

  final VoiceTileFault fault;
  final String? reference;
  final VoiceTrackHealth? health;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isPaused = fault == VoiceTileFault.senderPaused;
    return Material(
      color: Colors.black.withValues(alpha: 0.72),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                isPaused ? Icons.videocam_off_rounded : Icons.error_outline,
                size: compact ? 16 : 22,
                color: isPaused ? Colors.white70 : Colors.orangeAccent,
              ),
              const SizedBox(height: 4),
              Text(
                fault.message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 11 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (!compact) ...[
                const SizedBox(height: 4),
                Text(
                  fault.explanation,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
              // The reference, always - it is the whole point of the overlay
              // being a diagnostic rather than an apology. Short enough to
              // read off a screenshot into a support reply.
              if (reference != null) ...[
                const SizedBox(height: 4),
                Text(
                  reference!,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: compact ? 9 : 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
              // The measurements behind the sentence, for somebody who has
              // already turned the readout on and wants the numbers rather than
              // the conclusion.
              if (health != null)
                ValueListenableBuilder<bool>(
                  valueListenable: VideoDiagnosticsPrefs.enabled,
                  builder: (context, showing, _) => !showing
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            health!.describe(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 9,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
