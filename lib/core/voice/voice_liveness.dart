import 'dart:async';

import 'package:flutter/foundation.dart';

/// What one liveness assertion turned out to mean.
///
/// Three answers rather than success-or-throw, because all three are expected
/// and the loop below acts on each differently. A `404`/`409` is not a fault to
/// be retried, it is the server's verdict on this device's membership; a
/// timeout is not a verdict at all and says nothing either way.
enum VoiceLivenessOutcome {
  /// `204`. Membership is asserted for another [VoiceLiveness.interval].
  alive,

  /// `404` - not a participant of that room - or `409` - a participant, but
  /// from a device the roster has since superseded. No amount of retrying
  /// repairs either, and this device is out of the room whichever it is.
  notOurRoom,

  /// A timeout, a `5xx`, a refused connection, an expired token. The next tick
  /// covers it.
  transport,
}

/// Classifies a liveness response, given the status code that came back.
///
/// The pairing of `404` and `409` under one verdict is the server's, not this
/// client's: both mean "the server does not place you in this room", and a
/// client that tried to tell them apart would be acting on a distinction it
/// cannot do anything with.
VoiceLivenessOutcome voiceLivenessOutcomeFor(int? statusCode) =>
    statusCode == 404 || statusCode == 409
    ? VoiceLivenessOutcome.notOurRoom
    : VoiceLivenessOutcome.transport;

/// The 30 second `POST .../alive` loop - "I am still here", over HTTP.
///
/// # Why this exists alongside `VoiceHeartbeat`
///
/// Both assert the same fact to the same server, and that redundancy is the
/// entire point: they do not share a failure mode. `voice.Heartbeat` rides the
/// SignalR connection, so it asserts nothing during precisely the window the
/// server has already shortened this participant's liveness key to its 45s
/// disconnect grace. A hub that is down or midway through its reconnect ladder
/// is a hub that cannot say "still here", and one sweep of the server's
/// cleanup pass later the participant is evicted from a room they are sitting
/// in, with their audio still flowing.
///
/// Desktop has had this second channel for a while, pinged from a separate
/// process the OS cannot freeze. Mobile had only the hub, which made it the
/// first client out of any room during a partial outage.
///
/// # The interval is not arbitrary
///
/// The server's liveness TTL is 90s and its post-disconnect grace is 45s. 30s
/// survives one lost request inside even the *shorter* of the two, which is the
/// case that matters: the short window is the one in force right after a hub
/// blip, and a hub blip is exactly when a request is most likely to be lost.
///
/// # An eviction is reported, never repaired
///
/// [onRoomGone] fires at most once per [start], and the loop stops with it.
/// Re-asserting membership on this client's own say-so is what the server
/// refuses to do - it would readmit anyone who had been kicked, banned or
/// moved - so rejoining goes back through the authorised join path, which means
/// the user asking for it.
///
/// Nothing else here can end a call. A transport failure is logged and waited
/// out, because turning a backend hiccup into a dropped call is strictly worse
/// than the bug this closes.
class VoiceLiveness {
  VoiceLiveness({
    required this.assertAlive,
    required this.onRoomGone,
    this.interval = const Duration(seconds: 30),
  });

  /// Posts one assertion. Returns null for "nothing to assert this tick",
  /// which is what a caller whose room went away mid-flight answers - it is not
  /// evidence of anything and must not be read as an eviction.
  final Future<VoiceLivenessOutcome?> Function() assertAlive;

  /// The server does not place this device in the room. Called at most once per
  /// [start], after the loop has already stopped.
  final void Function() onRoomGone;

  final Duration interval;

  Timer? _timer;

  /// Guards the at-most-once promise against a tick that was already in flight
  /// when the verdict arrived. Cancelling the timer stops future ticks but not
  /// the awaited request inside the current one.
  bool _roomGoneReported = false;

  bool get isRunning => _timer != null;

  /// Starts the loop, with the first tick fired immediately rather than after a
  /// full interval - membership is asserted as soon as the room is joined,
  /// rather than 30 seconds into it, and a rejoin lands inside the previous
  /// session's grace window.
  void start() {
    stop();
    _roomGoneReported = false;
    unawaited(_tick());
    _timer = Timer.periodic(interval, (_) => unawaited(_tick()));
  }

  /// Stops now. The one thing this must never do is tell the server we are in a
  /// room we have left, so every teardown path calls it.
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _tick() async {
    VoiceLivenessOutcome? outcome;
    try {
      outcome = await assertAlive();
    } catch (e) {
      // Defensive rather than expected: the API layer classifies its own
      // failures. Anything that still escapes is treated as transport, because
      // the alternative is an unhandled error on a timer that runs for the
      // whole call.
      debugPrint('[Voice] liveness ping threw: $e');
      return;
    }

    switch (outcome) {
      case null:
      case VoiceLivenessOutcome.alive:
        return;
      case VoiceLivenessOutcome.transport:
        debugPrint('[Voice] liveness ping failed, retrying next tick');
        return;
      case VoiceLivenessOutcome.notOurRoom:
        if (_roomGoneReported) return;
        _roomGoneReported = true;
        stop();
        onRoomGone();
    }
  }
}
