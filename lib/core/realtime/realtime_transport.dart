enum RealtimeConnectionStatus { connected, connecting, disconnected }

/// Seam around the SignalR client so `RealtimeService` (and everything built
/// on it) never sees `signalr_netcore` directly. If that package turns out
/// unreliable, only an implementation of this interface needs replacing —
/// see the Android/architecture notes for the fallback plan (a hand-rolled
/// client over `web_socket_channel`).
abstract class RealtimeTransport {
  Stream<RealtimeConnectionStatus> get connectionStatus;

  /// Builds the underlying connection object against [hubUrl]. Must be
  /// called once, before [on] or [start].
  void configure({required String hubUrl, required Future<String> Function() accessTokenFactory});

  /// Registers a handler for a server → client hub method. Safe to call any
  /// time after [configure].
  void on(String method, void Function(List<Object?>? args) handler);

  Future<void> start();
  Future<void> stop();

  /// Fire-and-forget client → server invocation; no-ops when disconnected.
  Future<void> invoke(String method, {List<Object>? args});
}
