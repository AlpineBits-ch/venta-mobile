import 'package:flutter/foundation.dart';

import '../network/api_client.dart';

/// How strictly this client acts on a leaf whose device certificate is missing
/// or does not verify. Contract §I.1.
///
/// Three states rather than a boolean because §H.4 as written is catastrophic to
/// ship: **no device in the field has a certificate**, so a client that started
/// proposing the removal of every uncertified leaf would begin removing every
/// other device in every group it is in - including its owner's.
enum CertificateEnforcement {
  /// Allow. Count it. No UI. The initial state, and the state anything
  /// unexpected falls back to.
  observe,

  /// Allow, but show an unverified-device indicator.
  warn,

  /// Propose removing the leaf.
  enforce,
}

/// Fetches the server-supplied enforcement phase.
///
/// The phase is **never** inferred from the client's own version. A single early
/// client must not be able to start removing leaves, and a version check is
/// exactly the mechanism that would let one - it needs no server co-operation
/// and cannot be rolled back.
///
/// Everything here fails to [CertificateEnforcement.observe]: an unreachable
/// server, a malformed body, an enum value from the future. The failure mode of
/// guessing too strict is destroying groups; of guessing too lenient, a longer
/// rollout.
class MlsPolicyService {
  MlsPolicyService({required this.client});

  final ApiClient client;

  /// Short enough that flipping the phase reaches clients within a session, long
  /// enough that it is not a request per commit.
  static const _ttl = Duration(minutes: 15);

  CertificateEnforcement _cached = CertificateEnforcement.observe;
  DateTime? _fetchedAt;

  /// The last known phase, without a round trip. Safe to call per leaf.
  CertificateEnforcement get current => _cached;

  Future<CertificateEnforcement> resolve() async {
    final at = _fetchedAt;
    if (at != null && DateTime.now().difference(at) < _ttl) return _cached;

    // Stamped before the request, so a server that is down does not mean one
    // fetch attempt per observed leaf.
    _fetchedAt = DateTime.now();

    try {
      final response = await client.dio.get<Map<String, dynamic>>(
        client.url('/api/v1/identity/mls-policy'),
      );
      _cached = _parse(response.data?['certificateEnforcement']);
    } catch (e) {
      debugPrint(
        'MlsPolicyService: no policy available, staying in observe: $e',
      );
      _cached = CertificateEnforcement.observe;
    }
    return _cached;
  }

  /// Anything unrecognised is [CertificateEnforcement.observe] - including a
  /// value a later server might introduce. Treating an unknown string as the
  /// strictest option would make adding one a group-destroying change.
  static CertificateEnforcement _parse(Object? raw) {
    return switch (raw) {
      'Warn' || 'warn' => CertificateEnforcement.warn,
      'Enforce' || 'enforce' => CertificateEnforcement.enforce,
      _ => CertificateEnforcement.observe,
    };
  }

  @visibleForTesting
  void seed(CertificateEnforcement phase) {
    _cached = phase;
    _fetchedAt = DateTime.now();
  }
}
