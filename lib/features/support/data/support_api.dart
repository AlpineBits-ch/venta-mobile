import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import 'models/report_dto.dart';

/// Why the server refused a report, where the reason is one the client can act
/// on. Anything else is a generic failure and is left as a [DioException].
enum ReportRefusal {
  /// Reporting yourself. Shouldn't be reachable - the entry points are hidden
  /// on your own content - but it is the one refusal that is entirely the
  /// client's fault, so it says so plainly rather than blaming the network.
  selfReport('self_report', 'You can\'t report yourself.'),

  /// A `subjectId` was required and wasn't sent. A bug in this client; the
  /// user can't fix it and shouldn't be told to try again.
  subjectIdRequired(
    'subject_id_required',
    'Something went wrong sending that report. Please try again.',
  ),

  /// The snapshot was over 16 KB. `ReportEvidence.build` trims to fit, so this
  /// should not happen - if it does, the report is worth sending without it.
  evidenceTooLarge(
    'evidence_too_large',
    'The messages attached to this report were too large to send.',
  ),

  reasonInvalid('reason_invalid', 'Pick a different reason and try again.');

  const ReportRefusal(this.code, this.message);

  final String code;
  final String message;
}

/// Thrown by [SupportApi.submitReport] on a refusal it recognises.
class ReportRefusedException implements Exception {
  const ReportRefusedException(this.refusal);

  final ReportRefusal refusal;

  String get message => refusal.message;

  @override
  String toString() => 'ReportRefusedException(${refusal.code})';
}

/// Filing reports and reading back what happened to them.
///
/// Deliberately the whole of the client's moderation surface. There is no
/// appeal call here and no staff anything: an appeal is filed once, on the
/// support site, which is a separate anonymous host reachable while signed out
/// - and the moderation console is a separate host with its own auth. Adding
/// either to the product client is the thing the spec says not to build.
class SupportApi {
  SupportApi({required this.client});

  final ApiClient client;

  String get _base => client.url('/api/v1/reports');

  /// Files one report.
  ///
  /// [targetUserId] is always the account being reported, whatever
  /// [subjectKind] points at - a report on a message is still a report on its
  /// author. [subjectId] is required for everything except a plain user report.
  ///
  /// [evidence] is the snapshot from `ReportEvidence.build`, already trimmed to
  /// the 16 KB the server accepts, or null.
  ///
  /// Throws [ReportRefusedException] on a refusal with a code this client knows.
  Future<ReportSubmissionDto> submitReport({
    required String targetUserId,
    required ReportSubjectKind subjectKind,
    required ReportReason reason,
    String? subjectId,
    String? details,
    Map<String, dynamic>? evidence,
  }) async {
    try {
      final response = await client.dio.post<Map<String, dynamic>>(
        _base,
        data: {
          'targetUserId': targetUserId,
          'subjectKind': subjectKind.wireValue,
          'subjectId': ?subjectId,
          'reason': reason.wireValue,
          if (details != null && details.isNotEmpty) 'details': details,
          'evidence': ?evidence,
        },
      );
      return ReportSubmissionDto.fromJson(response.data ?? const {});
    } on DioException catch (e) {
      final refusal = _refusalOf(e.response?.data);
      if (refusal != null) throw ReportRefusedException(refusal);
      rethrow;
    }
  }

  /// The reports this account filed, newest first as the server orders them.
  Future<List<FiledReportDto>> myReports({int limit = 25}) async {
    final response = await client.dio.get<List<dynamic>>(
      '$_base/mine',
      queryParameters: {'limit': limit},
    );
    return (response.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(FiledReportDto.fromJson)
        .toList(growable: false);
  }

  /// The refusal code, read from whichever key this endpoint uses.
  ///
  /// Both are tried because the refusal bodies elsewhere in this API are not
  /// consistent about it - the privacy routes answer `{"error": "<code>"}` -
  /// and a code read from the wrong key degrades into a flat "couldn't send
  /// that", which is exactly the case these codes exist to avoid.
  static ReportRefusal? _refusalOf(Object? body) {
    if (body is! Map) return null;
    final code = (body['code'] ?? body['error'])?.toString();
    if (code == null) return null;
    for (final refusal in ReportRefusal.values) {
      if (refusal.code == code) return refusal;
    }
    return null;
  }
}
