import 'dart:async';

import 'package:flutter/foundation.dart';

/// Turns a raw "am I making noise" signal into the `SpeakingChanged` reports the
/// server ranks active speakers from.
///
/// # Why this is not just a passthrough
///
/// `SpeakingChanged` is the **sole** input to active-speaker ranking, and the
/// server admits a speaker the instant it is told - deliberately, because
/// gating entry on duration would make the first person to talk in a quiet room
/// inaudible for seconds. The cost of that design lands here: an
/// un-hysteresised cough is a subscription-set change for every other client in
/// the room, each of which is a renegotiation.
///
/// So the asymmetry is the whole point.
///
///  * **Onset is immediate.** Latency here is audible - it is the front of
///    somebody's first word - and the server is built to accept it.
///  * **Release is held.** [releaseDelay] rides out the gaps between words and
///    the pauses inside a sentence, which are the overwhelming majority of the
///    transitions a raw signal produces. Somebody who has genuinely stopped
///    talking is dropped from the ranking a beat later, and nothing about that
///    is perceptible.
///
/// A room whose clients never report speech has no basis for ranking and
/// correctly stays `mode: "all"` - nothing looks broken, and nothing is saved.
/// That is what every guild channel did before this existed.
class VoiceSpeakingDetector {
  VoiceSpeakingDetector({
    required this.report,
    this.releaseDelay = const Duration(milliseconds: 1200),
  });

  /// Invokes the room's `SpeakingChanged` with the debounced value. Only ever
  /// called on an actual transition - never twice with the same state.
  final Future<void> Function(bool isSpeaking) report;

  /// How long silence must hold before "stopped talking" is reported.
  ///
  /// Long enough to cover the pause between words and a breath mid-sentence,
  /// short enough that the ranking still follows a conversation rather than
  /// lagging a turn behind it.
  final Duration releaseDelay;

  /// What was last reported to the server, which is not the same as what the
  /// microphone is doing right now - the difference between them is this class.
  bool _reported = false;

  Timer? _release;
  bool _disposed = false;

  /// What the server currently believes.
  @visibleForTesting
  bool get reportedState => _reported;

  /// Whether a stop is being held down waiting for [releaseDelay].
  @visibleForTesting
  bool get isReleasePending => _release != null;

  /// Feeds one raw observation in. Safe to call at whatever rate the source
  /// produces - that is what this exists to absorb.
  void update({required bool isSpeaking}) {
    if (_disposed) return;

    if (isSpeaking) {
      // Any speech cancels a pending stop, which is the common case by a wide
      // margin: it is the gap between two words rather than the end of a turn.
      _release?.cancel();
      _release = null;
      if (!_reported) _emit(true);
      return;
    }

    if (!_reported || _release != null) return;
    _release = Timer(releaseDelay, () {
      _release = null;
      if (!_disposed && _reported) _emit(false);
    });
  }

  /// Reports silence now, without waiting out [releaseDelay].
  ///
  /// For the transitions that are not a pause in speech and must not be treated
  /// as one: muting, and leaving the room. Holding a stale `true` through either
  /// leaves this client ranked as talking while its microphone is off, which
  /// costs every other client in the room a subscription to silence.
  void silenceNow() {
    _release?.cancel();
    _release = null;
    if (_reported) _emit(false);
  }

  void dispose() {
    _disposed = true;
    _release?.cancel();
    _release = null;
  }

  void _emit(bool isSpeaking) {
    _reported = isSpeaking;
    unawaited(
      report(isSpeaking).catchError((Object e) {
        // A dropped report costs ranking accuracy for one transition and
        // nothing else. Retrying would stack requests behind a hub that is
        // already struggling, and the next transition asserts the truth anyway.
        debugPrint('[Voice] speaking report failed: $e');
      }),
    );
  }
}
