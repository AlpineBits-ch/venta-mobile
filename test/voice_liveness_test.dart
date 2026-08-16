import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mobile/core/device/device_id_service.dart';
import 'package:venta_mobile/core/network/api_client.dart';
import 'package:venta_mobile/core/voice/voice_liveness.dart';
import 'package:venta_mobile/features/auth/data/auth_repository.dart';
import 'package:venta_mobile/features/guild_voice/data/guild_voice_api.dart';
import 'package:venta_mobile/features/voice/data/voice_api.dart';

/// The HTTP liveness ping, and the loop that drives it.
///
/// The gap being closed: this client's only assertion of room membership used
/// to be `voice.Heartbeat`, which rides the SignalR connection. That asserts
/// nothing during precisely the window the server has already shortened the
/// liveness key to its 45s disconnect grace, so a hub outage of any length ends
/// with the participant swept out of a room their audio is still flowing into.
/// Desktop has had a second, hub-independent channel for a while; this is
/// mobile's.
///
/// Three things are worth pinning and are pinned below: the ping reaches the
/// route it is supposed to (a path missing its gateway service segment 404s
/// silently, and a silent 404 here is indistinguishable from an eviction), a
/// transport failure never ends a call, and a genuine eviction is reported
/// exactly once rather than swallowed.
class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockDeviceIdService extends Mock implements DeviceIdService {}

/// Answers every request with a chosen status, recording what was asked. A
/// status outside 2xx makes Dio throw, which is the path the API under test
/// actually takes.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.status);

  int status;

  /// When set, the adapter fails the way a dead network does - a `DioException`
  /// with no response at all, rather than one carrying a status.
  bool offline = false;

  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (offline) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'no route to host',
      );
    }
    return ResponseBody.fromString('', status);
  }

  @override
  void close({bool force = false}) {}
}

const _kDeviceId = 'abc123deviceid';

/// Short enough to keep the suite fast, long enough that a tick and its
/// assertion cannot interleave by accident.
const _interval = Duration(milliseconds: 20);

/// Long enough for several [_interval] ticks to have fired.
Future<void> _letItTick() => Future<void>.delayed(_interval * 5);

void main() {
  group('voiceLivenessOutcomeFor', () {
    test('404 and 409 are both "not our room"', () {
      // The server's own pairing: 404 is "not a participant", 409 is "a
      // participant, but on a device the roster has superseded". Both mean this
      // device is out, and no retry repairs either.
      expect(voiceLivenessOutcomeFor(404), VoiceLivenessOutcome.notOurRoom);
      expect(voiceLivenessOutcomeFor(409), VoiceLivenessOutcome.notOurRoom);
    });

    test('everything else is transport', () {
      // Including the no-status case. A dead network is not the server saying
      // anything about membership, and reading it as one would hang up a call
      // over a lost packet.
      for (final status in [null, 0, 401, 500, 502, 503]) {
        expect(
          voiceLivenessOutcomeFor(status),
          VoiceLivenessOutcome.transport,
          reason: 'status $status',
        );
      }
    });
  });

  group('VoiceLiveness', () {
    late List<VoiceLivenessOutcome?> answers;
    late int calls;
    late int roomGoneCount;
    late VoiceLiveness liveness;

    /// Answers with [answers] in order, repeating the last one forever.
    Future<VoiceLivenessOutcome?> next() async {
      final answer = answers[calls.clamp(0, answers.length - 1)];
      calls++;
      return answer;
    }

    void build({Future<VoiceLivenessOutcome?> Function()? assertAlive}) {
      liveness = VoiceLiveness(
        assertAlive: assertAlive ?? next,
        onRoomGone: () => roomGoneCount++,
        interval: _interval,
      );
    }

    setUp(() {
      answers = [VoiceLivenessOutcome.alive];
      calls = 0;
      roomGoneCount = 0;
      build();
    });

    tearDown(() => liveness.stop());

    test('the first tick fires immediately rather than after an interval', () {
      // A rejoin lands inside the previous session's grace window, so the
      // opening 30 seconds are exactly the ones that must not go unasserted.
      build();
      liveness.start();
      expect(calls, 1);
    });

    test('a healthy ping keeps the loop running', () async {
      liveness.start();
      await _letItTick();

      expect(calls, greaterThan(2));
      expect(liveness.isRunning, isTrue);
      expect(roomGoneCount, 0);
    });

    test('a transport failure is swallowed and the loop continues', () async {
      // The whole point of the classification: a 5xx or a timeout says nothing
      // about membership, and turning a backend hiccup into a dropped call is
      // strictly worse than the bug this exists to fix.
      answers = [VoiceLivenessOutcome.transport];
      build();
      liveness.start();
      await _letItTick();

      expect(calls, greaterThan(2), reason: 'the loop stopped on a hiccup');
      expect(liveness.isRunning, isTrue);
      expect(roomGoneCount, 0);
    });

    test('a thrown error is swallowed and the loop continues', () async {
      // Defensive: the API layer classifies its own failures, so nothing should
      // reach here. An unhandled error on a timer that runs for the whole call
      // is not an acceptable way to find out otherwise.
      var thrown = 0;
      build(
        assertAlive: () async {
          thrown++;
          throw StateError('boom');
        },
      );
      liveness.start();
      await _letItTick();

      expect(thrown, greaterThan(2));
      expect(liveness.isRunning, isTrue);
      expect(roomGoneCount, 0);
    });

    test('a null outcome asserts nothing and is not an eviction', () async {
      // What a caller answers when the room went away mid-flight. Reading it as
      // a verdict would tear down a call the user themselves just left, and
      // report it to them as though the server had done it.
      answers = [null];
      build();
      liveness.start();
      await _letItTick();

      expect(liveness.isRunning, isTrue);
      expect(roomGoneCount, 0);
    });

    test('a 404 verdict reports the eviction once and stops', () async {
      answers = [VoiceLivenessOutcome.notOurRoom];
      build();
      liveness.start();
      await _letItTick();

      expect(roomGoneCount, 1);
      expect(liveness.isRunning, isFalse);
      expect(calls, 1, reason: 'the loop went on pinging a room it is not in');
    });

    test('a 409 verdict is treated identically', () async {
      // Same enum arm by construction, asserted anyway: the two statuses reach
      // it down different paths and the loop must not learn to tell them apart.
      answers = [VoiceLivenessOutcome.notOurRoom];
      build();
      liveness.start();
      await _letItTick();

      expect(roomGoneCount, 1);
      expect(liveness.isRunning, isFalse);
    });

    test('a verdict arriving on an overlapping tick still reports once', () async {
      // Cancelling the timer stops future ticks but not the request awaiting
      // inside the current one, so two in-flight pings can both come back
      // "not our room". The user must not be torn down twice for it.
      final gate = Completer<void>();
      build(
        assertAlive: () async {
          await gate.future;
          return VoiceLivenessOutcome.notOurRoom;
        },
      );
      liveness.start();
      await _letItTick();
      gate.complete();
      await _letItTick();

      expect(roomGoneCount, 1);
      expect(liveness.isRunning, isFalse);
    });

    test('restarting clears the eviction latch', () async {
      // A cubit reuses one instance across joins. A latch that survived would
      // leave the next room with no liveness reporting at all.
      answers = [VoiceLivenessOutcome.notOurRoom];
      build();
      liveness.start();
      await _letItTick();
      expect(roomGoneCount, 1);

      liveness.start();
      await _letItTick();
      expect(roomGoneCount, 2);
    });

    test('stopping stops the pings', () async {
      liveness.start();
      await _letItTick();
      liveness.stop();
      final afterStop = calls;

      await _letItTick();
      expect(
        calls,
        afterStop,
        reason: 'a stopped loop went on asserting a room the user has left',
      );
      expect(liveness.isRunning, isFalse);
    });
  });

  group('assertAlive over HTTP', () {
    late _StubAdapter adapter;
    late GuildVoiceApi guildApi;
    late VoiceApi callApi;

    setUp(() {
      final auth = _MockAuthRepository();
      when(() => auth.baseUrl).thenReturn('https://example.test');
      when(() => auth.ensureValidToken()).thenAnswer((_) async => 'token');

      final client = ApiClient(authRepository: auth);
      adapter = _StubAdapter(204);
      client.dio.httpClientAdapter = adapter;

      final deviceIdService = _MockDeviceIdService();
      when(() => deviceIdService.deviceId).thenReturn(_kDeviceId);

      guildApi = GuildVoiceApi(client: client, deviceIdService: deviceIdService);
      callApi = VoiceApi(client: client, deviceIdService: deviceIdService);
    });

    test('the guild ping carries the gateway service segment', () async {
      // `/api/v1/guild` in front, then the controller's own route. Without the
      // segment YARP matches nothing and answers 404 - which this client would
      // read as an eviction and hang up on, which is worse than not pinging at
      // all. The desktop call route shipped with exactly this bug once.
      await guildApi.assertAlive('g1', 'c1');

      expect(
        adapter.requests.single.uri.toString(),
        'https://example.test/api/v1/guild/guilds/g1/channels/c1/voice/alive',
      );
    });

    test('the call ping uses the plural voice-room segment', () async {
      // `voice/calls/{id}` (plural), not the `voice/call/{id}` the lifecycle
      // routes use. Both shapes are live on the same service, so picking the
      // wrong one 404s against a real prefix.
      await callApi.assertAlive('call-1');

      expect(
        adapter.requests.single.uri.toString(),
        'https://example.test/api/v1/messaging/voice/calls/call-1/alive',
      );
    });

    test('both pings send X-Device-Id', () async {
      // Load-bearing rather than incidental: liveness keys are per user, so the
      // server compares this against the roster and answers 409 for a device it
      // has superseded. A missing header reads as the literal "default", which
      // is a device the roster has never heard of.
      await guildApi.assertAlive('g1', 'c1');
      await callApi.assertAlive('call-1');

      for (final request in adapter.requests) {
        expect(
          request.headers['X-Device-Id'],
          _kDeviceId,
          reason: '${request.method} ${request.path} sent no device id',
        );
      }
    });

    test('204 is alive', () async {
      adapter.status = 204;

      expect(await guildApi.assertAlive('g1', 'c1'), VoiceLivenessOutcome.alive);
      expect(await callApi.assertAlive('call-1'), VoiceLivenessOutcome.alive);
    });

    test('404 is a verdict, not a fault', () async {
      adapter.status = 404;

      expect(
        await guildApi.assertAlive('g1', 'c1'),
        VoiceLivenessOutcome.notOurRoom,
      );
      expect(
        await callApi.assertAlive('call-1'),
        VoiceLivenessOutcome.notOurRoom,
      );
    });

    test('409 is the same verdict', () async {
      adapter.status = 409;

      expect(
        await guildApi.assertAlive('g1', 'c1'),
        VoiceLivenessOutcome.notOurRoom,
      );
      expect(
        await callApi.assertAlive('call-1'),
        VoiceLivenessOutcome.notOurRoom,
      );
    });

    test('a 5xx is transport, so the next tick retries', () async {
      adapter.status = 503;

      expect(
        await guildApi.assertAlive('g1', 'c1'),
        VoiceLivenessOutcome.transport,
      );
      expect(
        await callApi.assertAlive('call-1'),
        VoiceLivenessOutcome.transport,
      );
    });

    test('a dead network is transport rather than an eviction', () async {
      // The case that actually matters during an outage: no response at all.
      // Classifying this as "not our room" would have every client in the room
      // hang up the moment connectivity blinked.
      adapter.offline = true;

      expect(
        await guildApi.assertAlive('g1', 'c1'),
        VoiceLivenessOutcome.transport,
      );
      expect(
        await callApi.assertAlive('call-1'),
        VoiceLivenessOutcome.transport,
      );
    });
  });
}
