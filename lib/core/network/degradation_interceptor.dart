import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../features/billing/data/degradation_log.dart';
import '../../features/billing/data/models/entitlement_degradation_dto.dart';

/// Notices when a request succeeded with less than it asked for.
///
/// A degradation rides the `200` of the operation that caused it, as a
/// `degradations` array beside the body the caller already parses. There is no
/// endpoint that lists them, which leaves two ways to collect them: at every
/// call site that could ever be reduced, or once, here.
///
/// Here, for the same reason `StatusProbeInterceptor` is here: this is the only
/// place that sees every response. A per-call-site version would have to be
/// added to the voice join, the voice publish, every upload path and every
/// enforcement site the server grows next quarter, and the ones nobody
/// remembered would be silently invisible - which is indistinguishable from a
/// server that stopped sending them.
///
/// **Observes only.** It never resolves, rejects, retries or edits a response,
/// and it must not start: a reduction is a success, and a client that treats
/// one as anything else has turned "degrade, do not deny" back into a denial
/// with extra steps.
class DegradationInterceptor extends Interceptor {
  DegradationInterceptor(this.log);

  final DegradationLog log;

  /// The property name the server attaches. Absent whenever nothing was
  /// reduced, which is the overwhelmingly normal case and the reason this is
  /// cheap enough to run on every response: one map lookup that usually misses.
  static const propertyName = 'degradations';

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    try {
      _read(response);
    } catch (e) {
      // Never fails a request. A malformed degradation is a reduction we could
      // not name, and losing the whole response over it would break an
      // operation that succeeded.
      debugPrint('degradations could not be read: $e');
    }
    handler.next(response);
  }

  void _read(Response<dynamic> response) {
    final data = response.data;
    if (data is! Map) return;

    final raw = data[propertyName];
    // An empty array and an absent one mean the same thing, and the server
    // writes neither when nothing was reduced.
    if (raw is! List || raw.isEmpty) return;

    final surface = surfaceForPath(response.requestOptions.path);

    for (final entry in raw.whereType<Map>()) {
      log.record(
        EntitlementDegradationDto.fromJson(
          entry.map((key, value) => MapEntry('$key', value)),
        ),
        surface: surface,
      );
    }
  }
}
