import '../../../../core/format/api_date_time.dart';

/// What a report is *about*. The account being reported is always carried
/// separately as `targetUserId`; this says which of that account's things the
/// reporter is pointing at.
enum ReportSubjectKind {
  user('User'),
  message('Message'),
  channel('Channel'),
  guild('Guild');

  const ReportSubjectKind(this.wireValue);

  final String wireValue;

  static ReportSubjectKind? fromWire(String? value) {
    for (final kind in values) {
      if (kind.wireValue.toLowerCase() == value?.toLowerCase()) return kind;
    }
    return null;
  }

  /// How the "Reports you've filed" list names one. Not shown anywhere the
  /// enum name would be - see [ReportReason.label] for why.
  String get label => switch (this) {
    ReportSubjectKind.user => 'User',
    ReportSubjectKind.message => 'Message',
    ReportSubjectKind.channel => 'Channel',
    ReportSubjectKind.guild => 'Server',
  };
}

/// The reasons a report may carry.
///
/// The order here is the order they are offered in, and it is deliberate.
/// `childSafety`, `selfHarm` and `violentThreats` are triaged Critical
/// server-side and sit in the body of the list where they are easy to find,
/// rather than being buried under "Something else" - but nothing in the client
/// says so. Promising a response time is not the client's to do.
enum ReportReason {
  spam('Spam', 'Spam or unsolicited advertising'),
  harassment('Harassment', 'Harassment or targeted abuse'),
  hateSpeech('HateSpeech', 'Hateful conduct'),
  violentThreats('ViolentThreats', 'Threats of violence'),
  selfHarm('SelfHarm', 'Content promoting self-harm'),
  sexualContent('SexualContent', 'Unwanted sexual content'),
  childSafety('ChildSafety', 'Content endangering a minor'),
  impersonation('Impersonation', 'Impersonation'),
  malware('Malware', 'Malware or malicious links'),
  illegalContent('IllegalContent', 'Illegal content'),
  other('Other', 'Something else');

  const ReportReason(this.wireValue, this.label);

  /// What goes on the wire. Never rendered.
  final String wireValue;

  /// What the user reads. The enum names are the server's vocabulary and mean
  /// nothing to a person picking a reason under duress.
  final String label;

  static ReportReason? fromWire(String? value) {
    for (final reason in values) {
      if (reason.wireValue.toLowerCase() == value?.toLowerCase()) return reason;
    }
    return null;
  }
}

/// The three outcomes a reporter is ever shown.
///
/// The server collapses its internal states into exactly these, and it never
/// returns the moderator's note or who handled it. That is not an omission to
/// work around: in a harassment case, telling the reporter what was decided is
/// a channel straight back to the person they reported.
enum ReportStatus {
  underReview('UnderReview', 'Being reviewed'),
  actionTaken('ActionTaken', 'We took action'),
  closed('Closed', 'Reviewed - no action taken');

  const ReportStatus(this.wireValue, this.label);

  final String wireValue;
  final String label;

  static ReportStatus? fromWire(String? value) {
    for (final status in values) {
      if (status.wireValue.toLowerCase() == value?.toLowerCase()) return status;
    }
    return null;
  }
}

/// What `POST /api/v1/reports` answers with.
class ReportSubmissionDto {
  const ReportSubmissionDto({
    required this.id,
    this.status,
    this.merged = false,
  });

  factory ReportSubmissionDto.fromJson(Map<String, dynamic> json) =>
      ReportSubmissionDto(
        id: json['id']?.toString() ?? '',
        status: ReportStatus.fromWire(json['status']?.toString()),
        merged: json['merged'] == true,
      );

  final String id;

  /// Null when the server sent a status this client doesn't know. Nothing
  /// depends on it at submission time - it exists so a future status can be
  /// added server-side without this parse throwing.
  final ReportStatus? status;

  /// The report folded into one this account already filed against the same
  /// subject within 24 hours. The confirmation has to say so: a second "Report
  /// submitted" for something that was merged tells the user a second report
  /// exists, and it does not.
  final bool merged;
}

/// One row of `GET /api/v1/reports/mine`.
class FiledReportDto {
  const FiledReportDto({
    required this.id,
    required this.subjectKind,
    required this.reason,
    required this.status,
    this.createdAt,
    this.resolvedAt,
  });

  /// Lenient on purpose. This screen's whole job is to answer "did anything
  /// happen to that thing I reported six weeks ago", and a row the client
  /// can't fully parse should still render what it does know rather than take
  /// the list down with it - so unknown enum values fall back rather than
  /// throw, and `resolved` is read as a timestamp *if* it is one.
  factory FiledReportDto.fromJson(Map<String, dynamic> json) => FiledReportDto(
    id: json['id']?.toString() ?? '',
    subjectKind: ReportSubjectKind.fromWire(json['subjectKind']?.toString()),
    reason: ReportReason.fromWire(json['reason']?.toString()),
    // Unknown means "the server knows something this build doesn't", which is
    // closest to still being looked at - and it is the one of the three that
    // claims nothing about an outcome.
    status:
        ReportStatus.fromWire(json['status']?.toString()) ??
        ReportStatus.underReview,
    createdAt: tryParseApiDateTime(json['createdAt']),
    resolvedAt: tryParseApiDateTime(json['resolved'] ?? json['resolvedAt']),
  );

  final String id;
  final ReportSubjectKind? subjectKind;
  final ReportReason? reason;
  final ReportStatus status;
  final DateTime? createdAt;

  /// When it stopped being open, when the server says. `resolved` arrives null
  /// on an open report and its exact shape isn't pinned down, so a value that
  /// isn't a timestamp simply leaves this null - [status] is what the screen
  /// actually renders.
  final DateTime? resolvedAt;
}
