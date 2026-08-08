import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mobile/core/config/site_hosts.dart';
import 'package:venta_mobile/core/network/status_probe_interceptor.dart';
import 'package:venta_mobile/core/realtime/realtime_event.dart';
import 'package:venta_mobile/core/realtime/realtime_service.dart';
import 'package:venta_mobile/core/realtime/realtime_transport.dart';
import 'package:venta_mobile/features/auth/data/auth_repository.dart';
import 'package:venta_mobile/features/status/data/models/platform_status_dto.dart';
import 'package:venta_mobile/features/status/data/status_api.dart';
import 'package:venta_mobile/features/status/data/status_repository.dart';

/// The platform-status client, concentrating on the places where being wrong is
/// silent: an enum value the server added after this build shipped, a banner
/// dismissal that outlives the update it was about, and a hub payload that
/// parses "successfully" into an all-defaults object and takes a live outage
/// banner down with it.

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockRealtimeService extends Mock implements RealtimeService {}

/// Answers each request from [handler]; a null body is a `503`, which is what
/// a status endpoint that is itself unwell actually does.
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this.handler);

  final List<RequestOptions> requests = [];
  final Map<String, dynamic>? Function(int callIndex) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final index = requests.length;
    requests.add(options);
    final body = handler(index);
    return ResponseBody.fromString(
      body == null ? '' : jsonEncode(body),
      body == null ? 503 : 200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

const _base = 'https://api.venta.test';

/// Lets a fire-and-forget refetch reach the adapter.
///
/// `Duration.zero` is not enough: a Dio round-trip crosses the interceptor
/// chain and several microtask boundaries, and the probe paths deliberately
/// don't hand back a future to await.
Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 50));

/// The document's own example response, verbatim.
Map<String, dynamic> _summaryJson({
  String indicator = 'degraded',
  List<Map<String, dynamic>>? updates,
  bool withIncident = true,
}) => {
  'indicator': indicator,
  'updatedAt': '2026-08-05T12:04:20Z',
  'banner': {
    'title': 'Elevated error rates affecting Sign-in and accounts',
    'body':
        'Some people may not be able to sign in or create an account. We are '
        'investigating.',
    'severity': 'warning',
    'incidentReference': 'VNT-4KQ7M2XB',
    'url': 'https://status.venta.gg/incident?ref=VNT-4KQ7M2XB',
    'template': 'elevated_errors',
    'componentKey': 'accounts',
  },
  'components': [
    {
      'key': 'accounts',
      'name': 'Sign-in and accounts',
      'description': 'Signing in, registration, sessions',
      'status': 'degraded_performance',
      'statusSince': '2026-08-05T11:58:00Z',
      'uptime90d': 0.9987,
    },
  ],
  'incidents': [
    if (withIncident)
      {
        'reference': 'VNT-4KQ7M2XB',
        'kind': 'incident',
        'title': 'Elevated error rates affecting Sign-in and accounts',
        'impact': 'minor',
        'status': 'investigating',
        'components': ['accounts'],
        'startedAt': '2026-08-05T11:58:00Z',
        'resolvedAt': null,
        'template': 'elevated_errors',
        'url': 'https://status.venta.gg/incident?ref=VNT-4KQ7M2XB',
        'updates':
            updates ??
            [
              {
                'status': 'investigating',
                'body':
                    'Some people may not be able to sign in or create an '
                    'account. We are investigating.',
                'template': 'elevated_errors',
                'postedAt': '2026-08-05T11:58:00Z',
              },
            ],
      },
  ],
  'maintenance': [
    {
      'reference': 'VNT-9PD3RA7C',
      'kind': 'maintenance',
      'title': 'Database upgrade',
      'status': 'scheduled',
      'components': ['messages', 'servers'],
      'scheduledFor': '2026-08-09T02:00:00Z',
      'scheduledUntil': '2026-08-09T04:00:00Z',
      'impact': 'minor',
      'template': null,
      'url': 'https://status.venta.gg/incident?ref=VNT-9PD3RA7C',
      'updates': <Map<String, dynamic>>[],
    },
  ],
  'recent': <Map<String, dynamic>>[],
};

/// A [StatusRepository] over a scripted transport, with the hub controllers the
/// test drives by hand.
({
  StatusRepository repository,
  _ScriptedAdapter adapter,
  StreamController<RealtimeEvent> events,
  StreamController<RealtimeConnectionStatus> connection,
})
_build(Map<String, dynamic>? Function(int callIndex) handler) {
  final auth = _MockAuthRepository();
  when(() => auth.baseUrl).thenReturn(_base);

  final adapter = _ScriptedAdapter(handler);
  final dio = Dio()..httpClientAdapter = adapter;
  final api = StatusApi(authRepository: auth, dio: dio);

  final events = StreamController<RealtimeEvent>.broadcast();
  final connection = StreamController<RealtimeConnectionStatus>.broadcast();
  final realtime = _MockRealtimeService();
  when(() => realtime.events).thenAnswer((_) => events.stream);
  when(() => realtime.connectionStatus).thenAnswer((_) => connection.stream);

  return (
    repository: StatusRepository(
      api: api,
      authRepository: auth,
      realtimeService: realtime,
    ),
    adapter: adapter,
    events: events,
    connection: connection,
  );
}

void main() {
  group('parsing', () {
    test('reads the documented summary payload', () {
      final summary = PlatformStatusDto.fromJson(_summaryJson());

      expect(summary.indicator, StatusIndicator.degraded);
      expect(summary.banner!.severity, StatusSeverity.warning);
      expect(summary.banner!.incidentReference, 'VNT-4KQ7M2XB');
      expect(summary.banner!.template, 'elevated_errors');
      expect(summary.components.single.key, 'accounts');
      expect(
        summary.components.single.status,
        ComponentStatus.degradedPerformance,
      );
      expect(summary.components.single.uptime90d, 0.9987);
      expect(summary.incidents.single.status, IncidentStatus.investigating);
      expect(summary.maintenance.single.kind, IncidentKind.maintenance);
      expect(summary.maintenance.single.status, IncidentStatus.scheduled);
      expect(summary.hasBanner, isTrue);
      expect(summary.bannerIncident?.reference, 'VNT-4KQ7M2XB');
    });

    // "Treat every one as open ... never to a crash and never to major outage."
    // Without the `unknown` member on each enum this throws, and one new server
    // value takes the whole feature offline on every shipped client.
    test('degrades an unrecognised enum value instead of throwing', () {
      final json = _summaryJson(indicator: 'cosmic_ray');
      (json['components'] as List).first['status'] = 'on_fire';
      (json['incidents'] as List).first['impact'] = 'apocalyptic';
      (json['incidents'] as List).first['status'] = 'ruminating';

      final summary = PlatformStatusDto.fromJson(json);

      expect(summary.indicator, StatusIndicator.unknown);
      expect(summary.components.single.status, ComponentStatus.unknown);
      expect(summary.incidents.single.impact, IncidentImpact.unknown);
      expect(summary.incidents.single.status, IncidentStatus.unknown);
      // And specifically not the alarming end of any of them.
      expect(summary.indicator, isNot(StatusIndicator.majorOutage));
      expect(
        summary.components.single.status,
        isNot(ComponentStatus.majorOutage),
      );
    });

    test('reads a timestamp that arrives without a Z as UTC', () {
      final json = _summaryJson();
      json['updatedAt'] = '2026-08-05T12:04:20.481';

      final summary = PlatformStatusDto.fromJson(json);

      expect(summary.updatedAt!.isUtc, isTrue);
      expect(summary.updatedAt!.hour, 12);
    });

    // The dismissal key depends on this, and the spec only promises "newest
    // first" - so it is computed rather than read off position.
    test('newestUpdateAt is a maximum, not the first element', () {
      final summary = PlatformStatusDto.fromJson(
        _summaryJson(
          updates: [
            {'status': 'investigating', 'postedAt': '2026-08-05T11:58:00Z'},
            {'status': 'identified', 'postedAt': '2026-08-05T12:30:00Z'},
          ],
        ),
      );

      expect(
        summary.incidents.single.newestUpdateAt,
        DateTime.utc(2026, 8, 5, 12, 30),
      );
      expect(
        summary.incidents.single.latestUpdate?.status,
        IncidentStatus.identified,
      );
    });
  });

  group('reading', () {
    test('fetches anonymously - no bearer token', () async {
      final harness = _build((_) => _summaryJson());
      await harness.repository.refresh();

      final request = harness.adapter.requests.single;
      expect(request.path, '$_base/api/v1/status/summary');
      expect(request.headers.containsKey('Authorization'), isFalse);
    });

    test('a failed read keeps the last good summary and flags it', () async {
      final harness = _build((index) => index == 0 ? _summaryJson() : null);

      await harness.repository.refresh();
      expect(harness.repository.snapshot.value.unverified, isFalse);

      await harness.repository.refresh();
      final snapshot = harness.repository.snapshot.value;
      // The banner keeps rendering the last thing the server actually said -
      // blanking it because one poll timed out would remove the answer at the
      // moment the user went looking for it.
      expect(snapshot.summary, isNotNull);
      expect(snapshot.visibleBanner, isNotNull);
      expect(snapshot.unverified, isTrue);
    });

    test(
      'a first read that fails reports nothing at all, not "operational"',
      () async {
        final harness = _build((_) => null);
        await harness.repository.refresh();

        final snapshot = harness.repository.snapshot.value;
        expect(snapshot.summary, isNull);
        expect(snapshot.visibleBanner, isNull);
        expect(snapshot.unverified, isTrue);
      },
    );

    test('probeAfterFailure is throttled so an outage costs one check', () async {
      final harness = _build((_) => _summaryJson());
      await harness.repository.refresh();

      // What an outage looks like from the interceptor: every request in flight
      // fails at once.
      for (var i = 0; i < 40; i++) {
        harness.repository.probeAfterFailure();
      }
      await _settle();

      expect(harness.adapter.requests, hasLength(1));
    });

    test('a dropped hub connection fires one probe', () async {
      final harness = _build((_) => _summaryJson());

      harness.connection.add(RealtimeConnectionStatus.disconnected);
      await _settle();

      expect(harness.adapter.requests, hasLength(1));
    });
  });

  group('dismissal', () {
    test('hides the banner for the update it was dismissed on', () async {
      final harness = _build((_) => _summaryJson());
      await harness.repository.refresh();
      expect(harness.repository.snapshot.value.visibleBanner, isNotNull);

      harness.repository.dismissBanner();
      expect(harness.repository.snapshot.value.visibleBanner, isNull);

      // Same incident, nothing new said - stays dismissed across a poll.
      await harness.repository.refresh();
      expect(harness.repository.snapshot.value.visibleBanner, isNull);
    });

    test('re-raises the banner when the incident posts a new update', () async {
      var posted = 1;
      final harness = _build(
        (_) => _summaryJson(
          updates: [
            for (var i = 0; i < posted; i++)
              {
                'status': 'investigating',
                'body': 'update $i',
                'postedAt': '2026-08-05T1${i + 1}:58:00Z',
              },
          ],
        ),
      );

      await harness.repository.refresh();
      harness.repository.dismissBanner();
      expect(harness.repository.snapshot.value.visibleBanner, isNull);

      posted = 2;
      await harness.repository.refresh();
      // "A new update on the same incident is new information the user asked to
      // be told about when they opened the app."
      expect(harness.repository.snapshot.value.visibleBanner, isNotNull);
    });

    test(
      'forgets the dismissal once the incident leaves the response',
      () async {
        var open = true;
        final harness = _build(
          (_) => open
              ? _summaryJson()
              : {'indicator': 'operational', 'components': <dynamic>[]},
        );

        await harness.repository.refresh();
        harness.repository.dismissBanner();

        open = false;
        await harness.repository.refresh();
        expect(harness.repository.snapshot.value.visibleBanner, isNull);

        // The same reference coming back is a new incident as far as the user is
        // concerned, and inherits nothing.
        open = true;
        await harness.repository.refresh();
        expect(harness.repository.snapshot.value.visibleBanner, isNotNull);
      },
    );
  });

  group('realtime', () {
    test('applies a SummaryChanged payload without a refetch', () async {
      final harness = _build((_) => _summaryJson());
      await harness.repository.refresh();

      harness.events.add(
        RealtimeEvent('status.SummaryChanged', [
          _summaryJson(indicator: 'major_outage'),
        ]),
      );
      await _settle();

      expect(
        harness.repository.snapshot.value.summary!.indicator,
        StatusIndicator.majorOutage,
      );
      expect(harness.adapter.requests, hasLength(1));
    });

    test('understands a PascalCase payload', () async {
      final harness = _build((_) => _summaryJson());

      harness.events.add(
        RealtimeEvent('status.SummaryChanged', [
          {
            'Indicator': 'major_outage',
            'Banner': {
              'Title': 'Everything is on fire',
              'Severity': 'critical',
            },
            'Components': <dynamic>[],
          },
        ]),
      );
      await _settle();

      final snapshot = harness.repository.snapshot.value;
      expect(snapshot.summary!.indicator, StatusIndicator.majorOutage);
      expect(snapshot.visibleBanner?.title, 'Everything is on fire');
      expect(snapshot.visibleBanner?.severity, StatusSeverity.critical);
    });

    // The failure this guards is silent: a payload whose keys don't match
    // parses *successfully* into a DTO of all defaults - `operational`, no
    // banner - which would take a live outage banner down instead of updating
    // it. Anything unrecognised has to become a refetch.
    test(
      'refetches rather than blanking on a payload it cannot read',
      () async {
        final harness = _build((_) => _summaryJson());
        await harness.repository.refresh();

        harness.events.add(
          RealtimeEvent('status.SummaryChanged', [
            {'somethingElseEntirely': true},
          ]),
        );
        await _settle();

        expect(harness.adapter.requests, hasLength(2));
        expect(harness.repository.snapshot.value.visibleBanner, isNotNull);
      },
    );

    test('IncidentUpdated refetches instead of merging client-side', () async {
      final harness = _build((_) => _summaryJson());
      await harness.repository.refresh();

      harness.events.add(
        RealtimeEvent('status.IncidentUpdated', [
          {
            'incident': {'reference': 'VNT-4KQ7M2XB', 'status': 'monitoring'},
          },
        ]),
      );
      await _settle();

      expect(harness.adapter.requests, hasLength(2));
    });
  });

  group('status page URL', () {
    test('derives the instance status host', () {
      expect(
        statusUrlOrNull('https://api.venta.gg'),
        'https://status.venta.gg',
      );
      expect(
        statusUrlOrNull('https://api.eu.example.org'),
        'https://status.eu.example.org',
      );
    });

    test(
      'falls back to the status page when a banner carries no url',
      () async {
        final json = _summaryJson();
        (json['banner'] as Map).remove('url');
        final harness = _build((_) => json);
        await harness.repository.refresh();

        final banner = harness.repository.snapshot.value.visibleBanner!;
        expect(harness.repository.urlFor(banner), 'https://status.venta.test');
      },
    );
  });

  group('failure probe', () {
    // A 404 or a 401 says something about one request, not about the platform.
    // Probing on those turns every mistyped invite code into a status fetch.
    // Driven through a real Dio rather than by calling `onError` directly, so
    // the interceptor is exercised where it actually sits - and so a change
    // that swallowed the error instead of passing it on would show up here.
    test('fires only for gateway-level failures', () async {
      var probes = 0;
      final adapter = _ProbeAdapter();
      final dio = Dio()
        ..httpClientAdapter = adapter
        ..interceptors.add(StatusProbeInterceptor(() => probes++));

      Future<void> hit() async {
        try {
          await dio.get<void>('https://api.venta.test/x');
          fail('expected a failure');
        } on DioException {
          // Passed through untouched, which is the interceptor's contract.
        }
      }

      for (final type in [
        DioExceptionType.connectionError,
        DioExceptionType.connectionTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        adapter.throwType = type;
        await hit();
      }
      adapter.throwType = null;
      for (final status in [502, 503, 504]) {
        adapter.status = status;
        await hit();
      }
      expect(probes, 6);

      probes = 0;
      for (final status in [400, 401, 403, 404, 409, 429, 500]) {
        adapter.status = status;
        await hit();
      }
      expect(probes, 0);
    });
  });
}

/// Fails on demand: either as a transport-level [DioException] or with a chosen
/// HTTP status.
class _ProbeAdapter implements HttpClientAdapter {
  int status = 500;
  DioExceptionType? throwType;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final type = throwType;
    if (type != null) {
      throw DioException(requestOptions: options, type: type);
    }
    return ResponseBody.fromString('', status);
  }

  @override
  void close({bool force = false}) {}
}
