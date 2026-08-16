import 'package:flutter_test/flutter_test.dart';
import 'package:venta_mobile/core/diagnostics/voice_diagnostics.dart';
import 'package:venta_mobile/core/voice/voice_video_feed.dart';

/// What these cover: the two halves of "why is this tile black", both of which
/// exist because every one of those failures used to look identical from the
/// outside - an indefinite spinner over black, with nothing recorded anywhere.
///
/// The classifier is a pure function precisely so it can be exercised here. Its
/// arms are all races against a live SFU - a subscription the server withheld, a
/// publisher who muted, a decoder that refused an H.264 profile it never
/// advertised - and a classifier that could only be checked against a real room
/// would be checked once and then trusted forever.
///
/// The `attach` arm is the one with a real incident behind it: a handset
/// reported `PlatformException(mediaStreamAddTrack: Track is nil)` from
/// `video_participant_tile.dart:130` while its camera was being flipped. The
/// tile wrapped each track in a stream of its own, `LocalVideoTrack.restartTrack`
/// had disposed the native track underneath it, and the throw landed in an
/// unawaited future before `srcObject` was ever assigned.
void main() {
  final now = DateTime(2026, 8, 16, 12);
  final settled = now.subtract(const Duration(seconds: 30));

  VoiceTrackHealth health({
    bool subscribed = true,
    bool senderMuted = false,
    int bytesReceived = 0,
    int framesDecoded = 0,
    DateTime? subscribedAt,
    DateTime? lastFrameAt,
  }) => VoiceTrackHealth(
    subscribed: subscribed,
    senderMuted: senderMuted,
    bytesReceived: bytesReceived,
    framesDecoded: framesDecoded,
    subscribedAt: subscribedAt ?? settled,
    lastFrameAt: lastFrameAt,
  );

  group('voiceTileFaultFor', () {
    test('a picture that is drawing is not a fault', () {
      expect(
        voiceTileFaultFor(
          health: health(bytesReceived: 9000, framesDecoded: 90),
          hasFrame: true,
          now: now,
        ),
        isNull,
      );
    });

    test('nothing is accused during the grace period', () {
      // The ordinary state of a subscription that is about to work. An overlay
      // here would be on screen for every tile in every room, which is the
      // fastest way to teach somebody to ignore it.
      expect(
        voiceTileFaultFor(
          health: health(subscribedAt: now.subtract(const Duration(seconds: 1))),
          hasFrame: false,
          now: now,
        ),
        isNull,
      );
    });

    test('a muted publisher is named as such rather than as a failure', () {
      expect(
        voiceTileFaultFor(
          health: health(senderMuted: true),
          hasFrame: false,
          now: now,
        ),
        VoiceTileFault.senderPaused,
      );
    });

    test('a publisher who mutes mid-picture is still not a failure', () {
      // Distinct from the case above only in that a frame has already been
      // drawn - and it is the arm a naive "hasFrame first" ordering gets wrong,
      // reporting a stall for somebody who simply covered their camera.
      expect(
        voiceTileFaultFor(
          health: health(
            senderMuted: true,
            bytesReceived: 9000,
            framesDecoded: 90,
            lastFrameAt: settled,
          ),
          hasFrame: true,
          now: now,
        ),
        VoiceTileFault.senderPaused,
      );
    });

    test('subscribed with nothing arriving is a delivery fault', () {
      expect(
        voiceTileFaultFor(health: health(), hasFrame: false, now: now),
        VoiceTileFault.noData,
      );
    });

    test('an unsubscribed publication is named before the byte count', () {
      // Zero bytes is true of both, and only one of them is a network question.
      expect(
        voiceTileFaultFor(
          health: health(subscribed: false),
          hasFrame: false,
          now: now,
        ),
        VoiceTileFault.notSubscribed,
      );
    });

    /// The one this whole mechanism was worth building for. `video_layers.dart`
    /// records that a stream published above its negotiated H.264 level "fails
    /// as a black tile rather than a soft one", and the desktop client publishes
    /// H.264 High while an Android Codec2 device advertises Constrained Baseline
    /// and nothing else. From the outside that is indistinguishable from a dead
    /// network; the byte counter is what tells them apart.
    test('bytes arriving with nothing decoded is a codec fault', () {
      expect(
        voiceTileFaultFor(
          health: health(bytesReceived: 48000),
          hasFrame: false,
          now: now,
        ),
        VoiceTileFault.notDecoding,
      );
    });

    test('frames decoded with nothing drawn is a renderer fault', () {
      expect(
        voiceTileFaultFor(
          health: health(bytesReceived: 48000, framesDecoded: 120),
          hasFrame: false,
          now: now,
        ),
        VoiceTileFault.notRendering,
      );
    });

    test('a picture that arrived and stopped is a stall', () {
      expect(
        voiceTileFaultFor(
          health: health(
            bytesReceived: 48000,
            framesDecoded: 120,
            lastFrameAt: now.subtract(const Duration(seconds: 20)),
          ),
          hasFrame: true,
          now: now,
        ),
        VoiceTileFault.stalled,
      );
    });

    test('a brief gap between keyframes is not a stall', () {
      expect(
        voiceTileFaultFor(
          health: health(
            bytesReceived: 48000,
            framesDecoded: 120,
            lastFrameAt: now.subtract(const Duration(seconds: 2)),
          ),
          hasFrame: true,
          now: now,
        ),
        isNull,
      );
    });

    test('a failed attach outranks everything, including a healthy read', () {
      // Because it is the only fault the readings cannot see: the media is
      // arriving and decoding perfectly and the view was never given it.
      expect(
        voiceTileFaultFor(
          health: health(bytesReceived: 48000, framesDecoded: 120),
          hasFrame: true,
          now: now,
          attachFailed: true,
        ),
        VoiceTileFault.attachFailed,
      );
    });

    test('a local preview with no health is never accused', () {
      // Nobody subscribes to their own camera, so there are no receiver
      // statistics and nothing about delivery to report. `awaitingSince` is
      // omitted for exactly this case.
      expect(
        voiceTileFaultFor(health: null, hasFrame: false, now: now),
        isNull,
      );
    });

    test('a tile owed a picture that never got one says so', () {
      // No track at all, so no health to read - the arm that covers a camera
      // that was already on when this device joined, which nothing subscribes
      // to because the snapshot never names a camera track.
      expect(
        voiceTileFaultFor(
          health: null,
          hasFrame: false,
          now: now,
          awaitingSince: settled,
        ),
        VoiceTileFault.noTrack,
      );
    });

    test('a tile owed a picture is given the same grace as any other', () {
      expect(
        voiceTileFaultFor(
          health: null,
          hasFrame: false,
          now: now,
          awaitingSince: now.subtract(const Duration(seconds: 1)),
        ),
        isNull,
      );
    });
  });

  group('VoiceDiagnostics', () {
    test('a reference is unique within a session and short enough to read', () {
      final log = VoiceDiagnostics();
      final first = log.record(VoiceFaultCodes.connect, isError: false);
      final second = log.record(VoiceFaultCodes.join, isError: false);

      expect(first, 'V-CONN#1');
      expect(second, 'V-JOIN#2');
      expect(first.length, lessThan(12));
    });

    test('the reference is what the message carries', () {
      expect(
        withVoiceTrace('Could not connect audio.', 'V-CONN#3'),
        'Could not connect audio. [V-CONN#3]',
      );
    });

    test('a repeat of the same fault replaces rather than stacks', () {
      // A tile that cannot decode reports on every statistics tick. Sixty
      // identical rows would push out the connect failure that explains them.
      final log = VoiceDiagnostics();
      log.record(VoiceFaultCodes.join, subject: 'chan-1', isError: false);
      log.record(VoiceFaultCodes.noDecode, subject: 'tile', isError: false);
      log.record(VoiceFaultCodes.noDecode, subject: 'tile', isError: false);

      expect(log.entries.value.length, 2);
      expect(log.entries.value.first.code, VoiceFaultCodes.noDecode);
      expect(log.entries.value.last.code, VoiceFaultCodes.join);
    });

    test('the same code about different subjects is two facts', () {
      final log = VoiceDiagnostics();
      log.record(VoiceFaultCodes.noDecode, subject: 'user-a', isError: false);
      log.record(VoiceFaultCodes.noDecode, subject: 'user-b', isError: false);

      expect(log.entries.value.length, 2);
    });

    test('the log is capped and keeps the newest', () {
      final log = VoiceDiagnostics();
      for (var i = 0; i < VoiceDiagnostics.maxEntries + 10; i++) {
        log.record(VoiceFaultCodes.connect, subject: 'r$i', isError: false);
      }

      expect(log.entries.value.length, VoiceDiagnostics.maxEntries);
      expect(log.entries.value.first.subject, 'r${VoiceDiagnostics.maxEntries + 9}');
    });

    test('the detail carries the cause without holding the exception', () {
      final log = VoiceDiagnostics();
      log.record(
        VoiceFaultCodes.connect,
        detail: 'connection failed',
        error: StateError('boom'),
        isError: false,
      );

      final entry = log.entries.value.single;
      expect(entry.detail, contains('connection failed'));
      expect(entry.detail, contains('boom'));
      expect(entry.detail, isA<String>());
    });
  });
}
