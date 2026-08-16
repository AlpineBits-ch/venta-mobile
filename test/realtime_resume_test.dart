import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mobile/core/device/device_id_service.dart';
import 'package:venta_mobile/core/realtime/realtime_service.dart';
import 'package:venta_mobile/core/realtime/realtime_transport.dart';
import 'package:venta_mobile/features/auth/data/auth_repository.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockDeviceIdService extends Mock implements DeviceIdService {}

/// A transport whose connection state is set by the test rather than by a
/// socket, so `resume()` can be held against each of the three states it
/// distinguishes.
class _FakeTransport implements RealtimeTransport {
  final _statusController =
      StreamController<RealtimeConnectionStatus>.broadcast();

  /// One of `connected`, `disconnected`, or neither - the middle state being
  /// "mid-handshake or mid-reconnect", which is neither of the two getters.
  var connected = false;
  var down = true;

  var startCount = 0;
  var configureCount = 0;

  @override
  Stream<RealtimeConnectionStatus> get connectionStatus =>
      _statusController.stream;

  @override
  bool get isConnected => connected;

  @override
  bool get isDisconnected => down;

  @override
  void configure({
    required String hubUrl,
    required Future<String> Function() accessTokenFactory,
  }) {
    configureCount++;
  }

  @override
  void on(String method, void Function(List<Object?>? args) handler) {}

  @override
  Future<void> start() async {
    startCount++;
    connected = true;
    down = false;
    _statusController.add(RealtimeConnectionStatus.connected);
  }

  @override
  Future<void> stop() async {
    connected = false;
    down = true;
  }

  @override
  Future<void> invoke(String method, {List<Object>? args}) async {}
}

void main() {
  late _FakeTransport transport;
  late RealtimeService service;

  setUp(() {
    final auth = _MockAuthRepository();
    when(() => auth.baseUrl).thenReturn('https://example.test');
    when(() => auth.ensureValidToken()).thenAnswer((_) async => 'token');
    final devices = _MockDeviceIdService();
    when(() => devices.deviceId).thenReturn('device-1');

    transport = _FakeTransport();
    service = RealtimeService(
      transport: transport,
      authRepository: auth,
      deviceIdService: devices,
    );
  });

  test('a resume before the session ever started does nothing', () async {
    await service.resume();
    expect(transport.startCount, 0);
    expect(transport.configureCount, 0);
  });

  test('a resume onto a dead socket starts it', () async {
    await service.start();
    await transport.stop();

    final seen = <RealtimeConnectionStatus>[];
    final sub = service.connectionStatus.listen(seen.add);
    await service.resume();
    await Future<void>.delayed(Duration.zero);

    expect(transport.startCount, 2);
    // The reconnect announces itself, which is what every cubit resyncs on.
    expect(seen, [RealtimeConnectionStatus.connected]);
    await sub.cancel();
  });

  test('a resume onto a live socket re-announces connected', () async {
    await service.start();

    final seen = <RealtimeConnectionStatus>[];
    final sub = service.connectionStatus.listen(seen.add);
    await service.resume();
    await Future<void>.delayed(Duration.zero);

    // The socket is genuinely up, so it is not restarted - but the app was
    // away and holds a stale picture, so the resync signal still goes out.
    expect(transport.startCount, 1);
    expect(seen, [RealtimeConnectionStatus.connected]);
    await sub.cancel();
  });

  test('a resume mid-reconnect leaves the retry ladder alone', () async {
    await service.start();
    transport
      ..connected = false
      ..down = false;

    final seen = <RealtimeConnectionStatus>[];
    final sub = service.connectionStatus.listen(seen.add);
    await service.resume();
    await Future<void>.delayed(Duration.zero);

    // Starting again would throw, and the client's own ladder is already the
    // faster path back.
    expect(transport.startCount, 1);
    expect(seen, isEmpty);
    await sub.cancel();
  });

  test('transport status still reaches subscribers', () async {
    final seen = <RealtimeConnectionStatus>[];
    final sub = service.connectionStatus.listen(seen.add);
    transport._statusController.add(RealtimeConnectionStatus.connecting);
    transport._statusController.add(RealtimeConnectionStatus.disconnected);
    await Future<void>.delayed(Duration.zero);

    expect(seen, [
      RealtimeConnectionStatus.connecting,
      RealtimeConnectionStatus.disconnected,
    ]);
    await sub.cancel();
  });
}
