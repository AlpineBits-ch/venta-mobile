import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/config/site_hosts.dart';
import '../../../core/realtime/realtime_event.dart';
import '../../../core/realtime/realtime_service.dart';
import '../../../core/realtime/realtime_transport.dart';
import '../../auth/data/auth_repository.dart';
import 'models/platform_status_dto.dart';
import 'status_api.dart';

/// What every status-aware widget reads.
@immutable
class PlatformStatusSnapshot {
  const PlatformStatusSnapshot({
    this.summary,
    this.visibleBanner,
    this.unverified = false,
    this.checking = false,
  });

  /// The last summary that was read successfully, or null if none ever has
  /// been. Deliberately kept across a failed poll: a status page that was
  /// reporting an incident 60 seconds ago is still the best thing known about
  /// the platform, and blanking it because one request timed out would remove
  /// the answer at exactly the moment the user went looking for it.
  final PlatformStatusDto? summary;

  /// [PlatformStatusDto.banner] with the dismissal rule already applied - null
  /// when there is nothing to show *or* when the user dismissed this exact
  /// incident-and-update. The banner widget renders this and nothing else.
  final StatusBannerDto? visibleBanner;

  /// The last attempt to read the summary failed.
  ///
  /// **Never drives the app-wide banner.** A failed status check is not
  /// evidence of an incident, and "could not load status" over every screen is
  /// noise on top of whatever error the user is already looking at. It is read
  /// only by the Platform status screen, which was opened by someone asking
  /// this exact question and is owed an answer either way.
  final bool unverified;

  /// A read is in flight. Only distinguishable from [unverified] on the first
  /// one, which is the only time it matters.
  final bool checking;

  bool get hasEverLoaded => summary != null;
}

/// Owns the app's copy of platform status: the 60-second foreground poll, the
/// one-shot checks fired when something else fails, the hub events that make
/// both faster, and the banner-dismissal rule.
///
/// Anonymous throughout. Nothing here waits for, or is invalidated by, a
/// session - a signed-out user staring at a login screen that will not accept
/// their password is the single most important reader of this, and §5's hub
/// events never reach them.
class StatusRepository {
  StatusRepository({
    required this.api,
    required this.authRepository,
    required RealtimeService realtimeService,
  }) {
    _realtimeSub = realtimeService.events
        .where(
          (e) => const {
            'status.SummaryChanged',
            'status.IncidentUpdated',
          }.contains(e.name),
        )
        .listen(_handleRealtimeEvent);

    // §3's third one-shot trigger: "the websocket drops and the first reconnect
    // attempt fails". `disconnected` is the closest thing the transport
    // publishes - `signalr_netcore` reports per-attempt failures only through
    // its retry policy, and surfacing those would mean plumbing a second
    // channel through `RealtimeTransport` for a signal this already covers.
    // Throttled like every other probe, so a flapping connection is one check
    // per 30 seconds rather than one per drop.
    _connectionSub = realtimeService.connectionStatus.listen((status) {
      if (status == RealtimeConnectionStatus.disconnected) probeAfterFailure();
    });
  }

  final StatusApi api;
  final AuthRepository authRepository;

  /// §3: "Poll every 60 seconds while the app is in the foreground."
  static const _pollInterval = Duration(seconds: 60);

  /// The floor between *any* two reads, which is what makes
  /// [probeAfterFailure] safe to call from an interceptor. An outage typically
  /// fails every request in flight at once, and each one of them calls this.
  static const _probeThrottle = Duration(seconds: 30);

  final _snapshot = ValueNotifier<PlatformStatusSnapshot>(
    const PlatformStatusSnapshot(),
  );

  late final StreamSubscription<RealtimeEvent> _realtimeSub;
  late final StreamSubscription<RealtimeConnectionStatus> _connectionSub;

  Timer? _timer;
  Future<void>? _inFlight;
  DateTime? _lastAttemptAt;

  /// The dismissal key: an incident reference plus the timestamp of its newest
  /// update at the moment it was dismissed.
  ///
  /// Held in memory only. A relaunch re-raises the banner once, which is the
  /// safe direction for the mistake to go - the alternative is a user who
  /// dismissed a banner on Monday never being told the platform is still down
  /// on Tuesday, and there is nothing on disk worth that.
  String? _dismissedKey;
  DateTime? _dismissedUpdateAt;

  ValueListenable<PlatformStatusSnapshot> get snapshot => _snapshot;

  /// Where the public status page lives for whatever instance this client is
  /// pointed at - `api.venta.gg` → `status.venta.gg`. Null when it can't be
  /// derived, which is the signal to render no link rather than a dead one.
  String? get statusPageUrl => statusUrlOrNull(authRepository.baseUrl);

  /// Where a banner tap goes: the server's own link, or the instance status
  /// page if it sent none.
  String? urlFor(StatusBannerDto banner) {
    final url = banner.url;
    if (url != null && url.isNotEmpty) return url;
    return statusPageUrl;
  }

  /// The same, for an incident row on the status screen.
  String? urlForIncident(StatusIncidentDto incident) {
    final url = incident.url;
    if (url != null && url.isNotEmpty) return url;
    return statusPageUrl;
  }

  // ------------------------------------------------------------- lifecycle

  /// Starts the foreground poll. Idempotent - safe on launch and on every
  /// resume.
  void resume() {
    _timer ??= Timer.periodic(_pollInterval, (_) => unawaited(refresh()));
    // Immediately, not on the first tick: §3 wants a fresh answer the moment
    // the app comes back, and a minute of stale banner after a resume is a
    // minute of the app claiming an incident that ended while it was away.
    unawaited(refresh());
  }

  /// Stops it. Called when the app is backgrounded - "do not poll on a timer
  /// that survives backgrounding; a million idle clients polling a status
  /// endpoint is its own outage".
  void pause() {
    _timer?.cancel();
    _timer = null;
  }

  // --------------------------------------------------------------- reading

  /// Reads the summary now, coalescing with any read already in flight.
  ///
  /// Never throws: a failed status check is recorded in the snapshot and
  /// nowhere else.
  Future<void> refresh() {
    final inFlight = _inFlight;
    if (inFlight != null) return inFlight;
    final future = _fetch();
    _inFlight = future;
    return future.whenComplete(() => _inFlight = null);
  }

  /// The one-shot from §3: the API was unreachable, a sign-in failed with a
  /// 5xx, or the hub gave up reconnecting.
  ///
  /// Fire-and-forget and throttled. Callers are error paths - an interceptor, a
  /// bloc's catch - and none of them should be made to await a status check or
  /// to think about how many siblings just failed alongside them.
  void probeAfterFailure() {
    final last = _lastAttemptAt;
    if (last != null && DateTime.now().difference(last) < _probeThrottle) {
      return;
    }
    unawaited(refresh());
  }

  Future<void> _fetch() async {
    _lastAttemptAt = DateTime.now();
    _emit(checking: true);
    try {
      _apply(await api.getSummary());
    } catch (e) {
      debugPrint('status summary unavailable: $e');
      _emit(checking: false, unverified: true);
    }
  }

  /// Installs a summary, whether it came from the poll or from the hub.
  void _apply(PlatformStatusDto summary) {
    _forgetDismissalIfResolved(summary);
    _snapshot.value = PlatformStatusSnapshot(
      summary: summary,
      visibleBanner: _bannerToShow(summary),
    );
  }

  void _emit({required bool checking, bool unverified = false}) {
    final current = _snapshot.value;
    _snapshot.value = PlatformStatusSnapshot(
      summary: current.summary,
      visibleBanner: current.visibleBanner,
      unverified: unverified,
      checking: checking,
    );
  }

  // ------------------------------------------------------------ dismissal

  /// Hides the current banner until the incident posts a new update.
  ///
  /// §4: "Re-show the banner when either changes - a new update on the same
  /// incident is new information the user asked to be told about when they
  /// opened the app."
  void dismissBanner() {
    final summary = _snapshot.value.summary;
    final banner = summary?.banner;
    if (summary == null || banner == null) return;
    _dismissedKey = _keyOf(banner);
    _dismissedUpdateAt = summary.bannerIncident?.newestUpdateAt;
    _snapshot.value = PlatformStatusSnapshot(
      summary: summary,
      visibleBanner: null,
      unverified: _snapshot.value.unverified,
    );
  }

  StatusBannerDto? _bannerToShow(PlatformStatusDto summary) {
    if (!summary.hasBanner) return null;
    final banner = summary.banner!;
    if (_dismissedKey != _keyOf(banner)) return banner;
    // Same incident. Only still dismissed if it hasn't said anything since.
    if (_dismissedUpdateAt != summary.bannerIncident?.newestUpdateAt) {
      return banner;
    }
    return null;
  }

  /// §4: "Clear the memory when the incident leaves the response."
  ///
  /// Without this, a dismissal outlives its incident and the *next* one to
  /// reuse the reference - or, more realistically, the next banner that arrives
  /// with no reference at all - inherits a dismissal it never earned.
  void _forgetDismissalIfResolved(PlatformStatusDto summary) {
    final dismissed = _dismissedKey;
    if (dismissed == null) return;
    final stillOpen =
        summary.open.any((incident) => incident.reference == dismissed) ||
        (summary.banner != null && _keyOf(summary.banner!) == dismissed);
    if (stillOpen) return;
    _dismissedKey = null;
    _dismissedUpdateAt = null;
  }

  /// The reference, falling back to the title for a banner that spans several
  /// incidents and carries none. Dismissing something unidentifiable still has
  /// to stick for as long as it says the same thing.
  String _keyOf(StatusBannerDto banner) {
    final reference = banner.incidentReference;
    if (reference != null && reference.isNotEmpty) return reference;
    return banner.title;
  }

  // ------------------------------------------------------------- realtime

  /// §5: the hub is a latency improvement over the poll, never a replacement.
  void _handleRealtimeEvent(RealtimeEvent event) {
    if (event.name == 'status.SummaryChanged') {
      final summary = _summaryFromPayload(event.objectPayload);
      if (summary != null) {
        _apply(summary);
        return;
      }
    }
    // `status.IncidentUpdated` carries one incident, and merging it by
    // reference into a cached summary would mean re-deriving `indicator` and
    // the banner copy client-side - the one thing §1 forbids. Refetching costs
    // a single GET the server already caches for 15 seconds and comes back with
    // the server's own composition. The same path catches a `SummaryChanged`
    // whose payload didn't parse.
    unawaited(refresh());
  }

  /// Parses a hub payload into a summary, or null if it isn't one.
  ///
  /// Keys are normalised to lower-camel first because the hub is not consistent
  /// about casing (see `RealtimeEvent.field` for the same problem on the
  /// id-carrying events). Silent failure would be worse here than anywhere
  /// else: a PascalCase payload parses *successfully* into a DTO of all
  /// defaults - `indicator: operational`, `banner: null` - which would take a
  /// live outage banner down instead of updating it. Hence the explicit
  /// `indicator` check, and the refetch when it isn't there.
  PlatformStatusDto? _summaryFromPayload(Map<String, dynamic> payload) {
    if (payload.isEmpty) return null;
    try {
      final normalised = _lowerCamelKeys(payload) as Map<String, dynamic>;
      if (!normalised.containsKey('indicator')) return null;
      return PlatformStatusDto.fromJson(normalised);
    } catch (e) {
      debugPrint('status.SummaryChanged payload not understood: $e');
      return null;
    }
  }

  static Object? _lowerCamelKeys(Object? value) {
    if (value is Map) {
      return <String, dynamic>{
        for (final entry in value.entries)
          _lowerFirst('${entry.key}'): _lowerCamelKeys(entry.value),
      };
    }
    if (value is List) return value.map(_lowerCamelKeys).toList();
    return value;
  }

  static String _lowerFirst(String value) =>
      value.isEmpty ? value : value[0].toLowerCase() + value.substring(1);

  /// App-lifetime singleton; this exists for tests and for symmetry, not
  /// because anything in the app tears it down.
  Future<void> dispose() async {
    pause();
    await _realtimeSub.cancel();
    await _connectionSub.cancel();
    _snapshot.dispose();
  }
}
