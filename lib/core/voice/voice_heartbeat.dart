import 'dart:async';

import 'package:flutter/foundation.dart';

/// What this client asserts about itself on each heartbeat.
///
/// Reported honestly, including the nulls: if this device stopped publishing,
/// saying so is what makes the server correct its record and tell peers to
/// drop it. Claiming a session that carries nothing is the failure the
/// reconcile pass exists to catch.
class VoiceHeartbeatState {
  const VoiceHeartbeatState({
    required this.knownInstanceId,
    required this.knownVersion,
    this.mediaSessionId,
    this.audioTrackName,
  });

  final String? knownInstanceId;
  final int knownVersion;
  final String? mediaSessionId;
  final String? audioTrackName;

  Map<String, dynamic> toJson() => {
    'knownInstanceId': knownInstanceId,
    'knownVersion': knownVersion,
    'mediaSessionId': mediaSessionId,
    'audioTrackName': audioTrackName,
  };
}

/// The ~30 second `voice.Heartbeat` loop, for a channel or a call alike.
///
/// This is not just a keepalive, and treating it as one is why guild voice
/// previously had no recovery at all. Each tick asserts this client's own
/// state, and the server reconciles in both directions: a client that is
/// behind gets a `Snapshot`, a server record that disagrees with the client's
/// media is corrected and peers are told, and a room that is gone answers
/// `Resync(roomGone)`. Stop sending it and the participant is swept from the
/// roster after 90 seconds.
class VoiceHeartbeat {
  VoiceHeartbeat({
    required this.send,
    this.interval = const Duration(seconds: 30),
  });

  /// Invokes `voice.Heartbeat` with the state produced for this tick.
  final Future<void> Function() send;

  final Duration interval;

  Timer? _timer;

  bool get isRunning => _timer != null;

  /// Starts the loop. The first tick fires immediately rather than after a
  /// full interval - a client that joined mid-gap should not spend 30 seconds
  /// out of date before the repair channel opens.
  void start() {
    stop();
    _tick();
    _timer = Timer.periodic(interval, (_) => _tick());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void _tick() {
    unawaited(
      send().catchError((Object e) {
        // A dropped heartbeat is recoverable - the next tick asserts the same
        // state, and the 90 second sweep is far longer than one interval.
        debugPrint('[Voice] heartbeat failed: $e');
      }),
    );
  }
}
