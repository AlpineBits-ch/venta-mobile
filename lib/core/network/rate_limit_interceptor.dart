import 'dart:math';

import 'package:dio/dio.dart';

/// Backs off and retries when the gateway answers `429`.
///
/// The bucket is **per subject, across every route** - the body says
/// `"global": true` and means it. So a `429` on one call is a statement about
/// the whole client, and the only correct response is to hold *every* request
/// for the window, not just the one that was rejected. That is what
/// [_globalUntil] and the [onRequest] wait are for; retrying only the rejected
/// call would spend the recovered budget on whatever else was already in
/// flight and stay rejected.
///
/// The realistic way to hit this is not a hot loop: it is a cold app start
/// fanning out across a dozen guilds at once. That burst is absorbed by the
/// reserve when the client is polite about the overflow and turns into a wall
/// of failed screens when it isn't.
class RateLimitInterceptor extends Interceptor {
  RateLimitInterceptor({
    Dio Function()? retryClient,
    Future<void> Function(Duration)? delay,
    double Function()? jitter,
    this.maxAttempts = 3,
  }) : _retryClient = retryClient ?? Dio.new,
       _delay = delay ?? Future<void>.delayed,
       _jitter = jitter ?? Random().nextDouble;

  /// Builds the client the retry goes out on - a bare [Dio], matching
  /// `AuthInterceptor` and `DeviceIdInterceptor`: going back through the owning
  /// client would re-enter this chain and could nest waits.
  final Dio Function() _retryClient;

  /// Injected so tests don't spend real seconds asleep.
  final Future<void> Function(Duration) _delay;

  /// `[0,1)`. A cold start rejects several requests within the same few
  /// milliseconds, and retrying them all at the same instant reproduces the
  /// burst that caused the rejection.
  final double Function() _jitter;

  /// Attempts *including* the original. Three is enough to ride out a burst
  /// and few enough that a genuinely exhausted budget surfaces as an error the
  /// user can act on rather than a screen that hangs.
  final int maxAttempts;

  /// Longest a single wait may be. The server never asks for more than about a
  /// second today, but the value is server-controlled and an app that sleeps
  /// for whatever it is told can be parked indefinitely by one bad response.
  static const _maxWait = Duration(seconds: 30);

  /// When the shared budget is expected to have recovered. Null when there is
  /// no backoff in force.
  DateTime? _globalUntil;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    await _awaitGlobalWindow();
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 429) {
      handler.next(err);
      return;
    }

    // The retry goes out on a bare client, so it never re-enters this
    // interceptor - the attempts are counted here rather than carried on the
    // request. Retrying *through* the owning client instead would re-run the
    // whole chain and nest a wait inside a wait.
    var current = err;
    for (var attempt = 1; attempt < maxAttempts; attempt++) {
      final response = current.response!;
      final wait = _waitFor(response, attempt);
      if (_isGlobal(response.data)) {
        final until = DateTime.now().add(wait);
        // Never shorten a window already in force: two rejections arriving
        // together would otherwise have the second release the first early.
        if (_globalUntil == null || until.isAfter(_globalUntil!)) {
          _globalUntil = until;
        }
      }

      try {
        await _delay(wait);
        await _awaitGlobalWindow();
        handler.resolve(
          await _retryClient().fetch<dynamic>(current.requestOptions),
        );
        return;
      } on DioException catch (retryError) {
        if (retryError.response?.statusCode != 429) {
          // A different failure is the more recent truth about this request.
          handler.next(retryError);
          return;
        }
        // Another rejection carries a fresher `retry_after`; go round again.
        current = retryError;
      } catch (_) {
        handler.next(current);
        return;
      }
    }
    handler.next(current);
  }

  Future<void> _awaitGlobalWindow() async {
    final until = _globalUntil;
    if (until == null) return;
    final remaining = until.difference(DateTime.now());
    if (remaining <= Duration.zero) {
      _globalUntil = null;
      return;
    }
    await _delay(remaining);
    if (_globalUntil == until) _globalUntil = null;
  }

  /// How long to hold off, from the body's `retry_after` or the `Retry-After`
  /// header, doubled per attempt already made and jittered.
  Duration _waitFor(Response<dynamic> response, int attempt) {
    final seconds = _retryAfterSeconds(response) ?? 1.0;
    final backoff = seconds * (1 << (attempt - 1));
    final jittered = backoff * (1 + _jitter() * 0.25);
    final wait = Duration(microseconds: (jittered * 1000000).round());
    return wait > _maxWait ? _maxWait : wait;
  }

  /// `retry_after` is **fractional** - `0.42` is a real value the gateway
  /// sends. Read as a `num`, never as an `int`: an int parse throws on the
  /// common case and turns a one-off backoff into a hard failure.
  static double? _retryAfterSeconds(Response<dynamic> response) {
    final data = response.data;
    if (data is Map) {
      final value = data['retry_after'] ?? data['retryAfter'];
      if (value is num) return value.toDouble();
      final parsed = double.tryParse('$value');
      if (parsed != null) return parsed;
    }
    // The header is whole seconds by definition, and is the fallback rather
    // than the source: it rounds 0.42 up to 1 and would triple a short wait.
    final header = response.headers.value('retry-after');
    if (header != null) {
      final parsed = double.tryParse(header.trim());
      if (parsed != null) return parsed;
    }
    return null;
  }

  /// Absent means global - the gateway runs one bucket per subject and only a
  /// future per-route limit would say otherwise, so the safe reading of a body
  /// that doesn't mention it is the one that holds everything back.
  static bool _isGlobal(Object? data) {
    if (data is Map) {
      final value = data['global'];
      if (value is bool) return value;
      if (value is String) return value.toLowerCase() != 'false';
    }
    return true;
  }
}
