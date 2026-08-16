enum RealtimeConnectionStatus { connected, connecting, disconnected }

/// Seam around the SignalR client so `RealtimeService` (and everything built
/// on it) never sees `signalr_netcore` directly. If that package turns out
/// unreliable, only an implementation of this interface needs replacing -
/// see the Android/architecture notes for the fallback plan (a hand-rolled
/// client over `web_socket_channel`).
abstract class RealtimeTransport {
  Stream<RealtimeConnectionStatus> get connectionStatus;

  /// The connection is fully established right now.
  ///
  /// Read on resume, where the *current* state is the question and the status
  /// stream - which only reports transitions - cannot answer it: an app that
  /// was away for an hour has no live subscriber holding the last value.
  bool get isConnected;

  /// The connection is down and is not trying to come back on its own, so
  /// [start] is both safe and necessary. False while it is mid-handshake or
  /// mid-reconnect, where starting again would throw and the client's own
  /// retry ladder is already the faster path.
  bool get isDisconnected;

  /// Builds the underlying connection object against [hubUrl]. Must be
  /// called once, before [on] or [start].
  void configure({
    required String hubUrl,
    required Future<String> Function() accessTokenFactory,
  });

  /// Registers a handler for a server → client hub method. Safe to call any
  /// time after [configure].
  void on(String method, void Function(List<Object?>? args) handler);

  Future<void> start();
  Future<void> stop();

  /// Fire-and-forget client → server invocation; no-ops when disconnected.
  Future<void> invoke(String method, {List<Object>? args});
}
