import 'dart:async';

import 'package:signalr_netcore/signalr_client.dart';

import 'exponential_retry_policy.dart';
import 'realtime_transport.dart';

class SignalrNetcoreTransport implements RealtimeTransport {
  HubConnection? _connection;
  final _statusController = StreamController<RealtimeConnectionStatus>.broadcast();

  @override
  Stream<RealtimeConnectionStatus> get connectionStatus => _statusController.stream;

  @override
  void configure({
    required String hubUrl,
    required Future<String> Function() accessTokenFactory,
  }) {
    final connection = HubConnectionBuilder()
        .withUrl(hubUrl, options: HttpConnectionOptions(accessTokenFactory: accessTokenFactory))
        .withAutomaticReconnect(reconnectPolicy: ExponentialRetryPolicy())
        .build();

    connection.onclose(({error}) => _statusController.add(RealtimeConnectionStatus.disconnected));
    connection.onreconnecting(({error}) => _statusController.add(RealtimeConnectionStatus.connecting));
    connection.onreconnected(({connectionId}) => _statusController.add(RealtimeConnectionStatus.connected));

    _connection = connection;
  }

  @override
  void on(String method, void Function(List<Object?>? args) handler) {
    _connection?.on(method, handler);
  }

  @override
  Future<void> start() async {
    final connection = _connection;
    if (connection == null) return;
    _statusController.add(RealtimeConnectionStatus.connecting);
    await connection.start();
    _statusController.add(RealtimeConnectionStatus.connected);
  }

  @override
  Future<void> stop() async {
    await _connection?.stop();
  }

  @override
  Future<void> invoke(String method, {List<Object>? args}) async {
    final connection = _connection;
    if (connection == null || connection.state != HubConnectionState.Connected) return;
    try {
      await connection.invoke(method, args: args);
    } catch (_) {
      // Fire-and-forget, matches Alpine's RealtimeConnectionService.invoke.
    }
  }
}
