/// The refusals that cannot degrade, and the one rule that makes them safe to
/// render: they use the *same* vocabulary as a reduction.
///
/// Most of the platform degrades rather than refuses - the eleventh person into
/// a full room gets an audio-only seat, the publisher who asked for too much
/// publishes less. A small reserved set cannot: an upload past the byte
/// ceiling, the 51st emoji, the 6th bot. Those answer `403` with a body whose
/// `code` is the same string a degradation puts in `reason`, so one lookup
/// table serves both and a client that can name a reduction can name a refusal.
///
/// **`remedy` and `actorCanRemedy` are on the wire and are not read here**, the
/// same omission and for the same reason as on a degradation: they are the
/// server's answer to which purchasing control to draw, and this client draws
/// none. What is rendered is why the request could not be carried out, and
/// nothing about what would change that.
library;

import 'package:dio/dio.dart';

import 'entitlement_degradation_dto.dart';
import 'entitlement_snapshot_dto.dart';
import 'entitlement_value.dart';

/// One refusal, as the client reads it.
class EntitlementDenial {
  const EntitlementDenial({
    required this.key,
    required this.reason,
    this.boundBy,
    this.requested,
    this.granted,
    this.feature,
    this.subject = const EntitlementSubjectDto(),
  });

  /// The catalogue key that refused, e.g. `storage.upload_max_bytes`.
  final String key;

  final DegradationReason reason;
  final DegradationBoundBy? boundBy;

  /// What was asked for and what the ceiling is. **Both absent** when what was
  /// refused has no countable ceiling, which today is only an out-of-plan
  /// module - those carry [feature] instead.
  final EntitlementValueDto? requested;
  final EntitlementValueDto? granted;

  /// The module named by an out-of-plan refusal.
  final String? feature;

  final EntitlementSubjectDto subject;

  /// What applied the limit, in one clause. The same sentence a reduction gets,
  /// which is the point of the two sharing a vocabulary.
  String get sentence => reason.sentence(boundBy);

  /// The ceiling as a person reads it, or null when this refusal has none.
  String? get ceiling {
    final limit = granted;
    if (limit == null) return null;
    return describeEntitlementValue(key, limit);
  }
}

/// Thrown by a call site that would otherwise hand a `403` to a generic error
/// path.
///
/// A refusal is a decision with a plain explanation behind it, and letting one
/// arrive as "something went wrong" throws that explanation away - which is the
/// difference between a user who knows why their file was not sent and one who
/// tries again three times.
class EntitlementDenialException implements Exception {
  const EntitlementDenialException(this.denial);

  final EntitlementDenial denial;

  @override
  String toString() =>
      'EntitlementDenialException(${denial.key}: ${denial.reason.name})';
}

/// Reads the refusal off a failed request, or null when it is not one.
///
/// Three conditions, and the middle one is what keeps this from swallowing
/// every other `403` in the app:
///
///  * the status is `403` - never `401` or `429`, which the contract forbids
///    precisely because the logout and retry interceptors eat both,
///  * the body names a catalogue `key`, which a permission refusal never does,
///  * and it carries a code.
///
/// An unrecognised code is still a refusal and still returns one, with
/// [DegradationReason.unknown] behind the generic sentence. A code this build
/// has never heard of is a reduction somebody is owed a plain account of, not a
/// reason to fall back to "something went wrong".
EntitlementDenial? entitlementDenialOf(Object error) {
  if (error is! DioException) return null;
  if (error.response?.statusCode != 403) return null;
  final data = error.response?.data;
  if (data is! Map) return null;

  final key = data['key'];
  if (key is! String || key.isEmpty) return null;

  final code = data['code'] ?? data['reason'];
  if (code is! String || code.isEmpty) return null;

  final subject = data['subject'];

  return EntitlementDenial(
    key: key,
    reason: degradationReasonOf(code),
    boundBy: degradationBoundByOf(data['boundBy']),
    requested: _value(data['requested']),
    granted: _value(data['granted']),
    feature: data['feature'] is String ? data['feature'] as String : null,
    subject: subject is Map
        ? EntitlementSubjectDto(
            kind: '${subject['kind'] ?? ''}',
            id: '${subject['id'] ?? ''}',
          )
        : const EntitlementSubjectDto(),
  );
}

EntitlementValueDto? _value(Object? raw) => raw is Map
    ? EntitlementValueDto.fromJson(
        raw.map((key, value) => MapEntry('$key', value)),
      )
    : null;
