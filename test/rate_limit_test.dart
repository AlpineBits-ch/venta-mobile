import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:venta_mobile/core/network/rate_limit_interceptor.dart';

/// What these cover: the gateway's rate limit went from documented to
/// *enforced*, and its `429` body is shaped in two ways a naive client gets
/// wrong - `retry_after` is fractional (`0.42`, not `1`), and `global` is true,
/// meaning one bucket spans every route rather than the one that was rejected.
///
/// The negative cases are the point. An int parser on `retry_after` throws on
/// the ordinary response; a client that retries only the rejected call spends
/// the recovered budget on whatever else was already in flight.
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this.responses);

  final List<ResponseBody Function()> responses;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final index = requests.length - 1;
    return responses[index < responses.length ? index : responses.length - 1]();
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _tooMany(Object? body, {String? retryAfterHeader}) =>
    ResponseBody.fromString(
      body == null ? '' : jsonEncode(body),
      429,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
        if (retryAfterHeader != null) 'retry-after': [retryAfterHeader],
      },
    );

ResponseBody _ok() => ResponseBody.fromString(
  '{"ok":true}',
  200,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

({Dio dio, _ScriptedAdapter adapter, List<Duration> waits}) _client(
  List<ResponseBody Function()> responses, {
  int maxAttempts = 3,
  Future<void> Function()? gate,
}) {
  final adapter = _ScriptedAdapter(responses);
  final waits = <Duration>[];
  final dio = Dio()
    ..httpClientAdapter = adapter
    ..interceptors.add(
      RateLimitInterceptor(
        // Shares the adapter so the retry reads the next scripted response.
        retryClient: () => Dio()..httpClientAdapter = adapter,
        delay: (d) {
          waits.add(d);
          // No real sleeping. [gate] lets a test hold every wait open at once,
          // which is the only way to observe a window that is still in force.
          return gate?.call() ?? Future<void>.value();
        },
        jitter: () => 0,
        maxAttempts: maxAttempts,
      ),
    );
  return (dio: dio, adapter: adapter, waits: waits);
}

/// Lets the pending microtasks run. Several turns, because a request crosses
/// the interceptor chain, the adapter and the response chain before it lands.
Future<void> _settle() async {
  for (var i = 0; i < 10; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  group('RateLimitInterceptor', () {
    test('honours a fractional retry_after and retries', () async {
      final c = _client([
        () => _tooMany({'retry_after': 0.42, 'global': true}),
        _ok,
      ]);

      final response = await c.dio.get<dynamic>('https://example.test/a');

      expect(response.statusCode, 200);
      expect(c.adapter.requests, hasLength(2));
      // 420ms, not 1s and not a crash - the whole point of the fractional value.
      expect(c.waits.first, const Duration(milliseconds: 420));
    });

    test('a string retry_after is read as a number', () async {
      final c = _client([
        () => _tooMany({'retry_after': '0.5'}),
        _ok,
      ]);
      await c.dio.get<dynamic>('https://example.test/a');
      expect(c.waits.first, const Duration(milliseconds: 500));
    });

    test(
      'falls back to the Retry-After header when the body has none',
      () async {
        final c = _client([
          () => _tooMany(const <String, dynamic>{}, retryAfterHeader: '2'),
          _ok,
        ]);
        await c.dio.get<dynamic>('https://example.test/a');
        expect(c.waits.first, const Duration(seconds: 2));
      },
    );

    test('a global 429 holds back a later request on another route', () async {
      final open = Completer<void>();
      final c = _client([
        () => _tooMany({'retry_after': 1.0, 'global': true}),
        _ok,
        _ok,
      ], gate: () => open.future);

      final rejected = c.dio.get<dynamic>('https://example.test/a');
      await _settle();
      // The window is open and the retry is waiting inside it.
      expect(c.adapter.requests, hasLength(1));

      final other = c.dio.get<dynamic>('https://example.test/somewhere-else');
      await _settle();

      // This one was never rejected and has still not gone out. One bucket
      // spans every route, so letting it through would just spend the budget
      // the rejected call is waiting for.
      expect(c.adapter.requests, hasLength(1));

      open.complete();
      await Future.wait([rejected, other]);
      expect(c.adapter.requests, hasLength(3));
    });

    test('a body that does not mention global is treated as global', () async {
      final open = Completer<void>();
      final c = _client([
        () => _tooMany({'retry_after': 1.0}),
        _ok,
        _ok,
      ], gate: () => open.future);

      final rejected = c.dio.get<dynamic>('https://example.test/a');
      await _settle();
      final other = c.dio.get<dynamic>('https://example.test/b');
      await _settle();

      // Absent is read as global. The gateway runs one bucket per subject; a
      // client that reads a missing flag as per-route hammers straight through
      // the window.
      expect(c.adapter.requests, hasLength(1));
      open.complete();
      await Future.wait([rejected, other]);
    });

    test('gives up after maxAttempts rather than retrying forever', () async {
      final c = _client([
        () => _tooMany({'retry_after': 0.1}),
      ], maxAttempts: 3);

      await expectLater(
        c.dio.get<dynamic>('https://example.test/a'),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'status',
            429,
          ),
        ),
      );
      expect(c.adapter.requests, hasLength(3));
      // Doubling per attempt: the server's 100ms, then 200ms.
      expect(c.waits.first, const Duration(milliseconds: 100));
      expect(c.waits, contains(const Duration(milliseconds: 200)));
    });

    test('anything that is not a 429 passes straight through', () async {
      final c = _client([() => ResponseBody.fromString('nope', 500)]);

      await expectLater(
        c.dio.get<dynamic>('https://example.test/a'),
        throwsA(isA<DioException>()),
      );
      expect(c.adapter.requests, hasLength(1));
      expect(c.waits, isEmpty);
    });
  });
}
