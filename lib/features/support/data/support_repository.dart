import '../../../core/config/site_hosts.dart';
import '../../auth/data/auth_repository.dart';
import 'models/report_dto.dart';
import 'support_api.dart';

/// Reporting, and where the support desk lives.
///
/// Nothing is cached. A report is a write the user watches happen, and the
/// filed-reports list is a low-traffic screen whose entire purpose is to be
/// current - a cached answer to "did anything happen to that thing I reported"
/// is worse than a spinner.
class SupportRepository {
  SupportRepository({required this.api, required this.authRepository});

  final SupportApi api;
  final AuthRepository authRepository;

  /// This instance's support desk, or null when it couldn't be derived from
  /// the API host. Callers render no link at all on null.
  ///
  /// Read through [AuthRepository.baseUrl] on every call rather than captured
  /// once: a self-hosted sign-in re-points the client mid-session, and a URL
  /// resolved at construction would keep pointing at the default instance.
  String? get supportUrl => supportUrlOrNull(authRepository.baseUrl);

  Future<ReportSubmissionDto> submitReport({
    required String targetUserId,
    required ReportSubjectKind subjectKind,
    required ReportReason reason,
    String? subjectId,
    String? details,
    Map<String, dynamic>? evidence,
  }) => api.submitReport(
    targetUserId: targetUserId,
    subjectKind: subjectKind,
    reason: reason,
    subjectId: subjectId,
    details: details,
    evidence: evidence,
  );

  Future<List<FiledReportDto>> myReports({int limit = 25}) =>
      api.myReports(limit: limit);
}
