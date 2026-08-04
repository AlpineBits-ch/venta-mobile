import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/format/api_date_time.dart';

part 'data_export_dto.freezed.dart';
part 'data_export_dto.g.dart';

enum DataExportStatus {
  @JsonValue('Pending')
  pending,
  @JsonValue('Running')
  running,
  @JsonValue('Ready')
  ready,

  /// Some services didn't return their data, and the archive was built without
  /// them. **Downloadable** - see [isDownloadable].
  @JsonValue('Partial')
  partial,
  @JsonValue('Failed')
  failed,
  @JsonValue('Expired')
  expired,
}

extension DataExportStatusX on DataExportStatus {
  String get label => switch (this) {
    DataExportStatus.pending => 'Queued',
    DataExportStatus.running => 'Preparing',
    DataExportStatus.ready => 'Ready to download',
    DataExportStatus.partial => 'Ready, with some data missing',
    DataExportStatus.failed => 'Failed',
    DataExportStatus.expired => 'Expired',
  };

  /// Whether the archive is still being assembled - the two states that resolve
  /// on their own, and so the two the screen keeps polling for.
  bool get isInProgress =>
      this == DataExportStatus.pending || this == DataExportStatus.running;

  /// Whether the server will serve this one.
  ///
  /// `Partial` counts. Gating the button on `Ready` alone hides a download the
  /// server would happily hand over - the archive exists and is the user's
  /// data; what's missing is named in `missingServices`, and withholding the
  /// rest of it because of that is the client deciding a data-access request
  /// on the user's behalf.
  bool get isDownloadable =>
      this == DataExportStatus.ready || this == DataExportStatus.partial;
}

/// One request for a copy of everything the instance holds about the account
/// (GDPR Art. 15/20). Assembled asynchronously by a saga that fans out across
/// every service, so a fresh request is `Pending` and becomes downloadable some
/// minutes later - there is no synchronous form of this.
@freezed
sealed class DataExportDto with _$DataExportDto {
  @ApiDateTimeConverter()
  const factory DataExportDto({
    required String exportId,
    @JsonKey(unknownEnumValue: DataExportStatus.pending)
    required DataExportStatus status,
    DateTime? requestedAt,
    DateTime? completedAt,

    /// The archive is deleted at this point, not merely hidden. Shown on the
    /// row because a download put off for a week is a download that fails.
    DateTime? expiresAt,

    /// Why a `Failed` export failed, and on a `Partial` one, the same thing
    /// [missingServices] says but in a sentence - which is what a build of this
    /// client that predates `Partial` would end up showing, and it stays true
    /// there.
    String? failureReason,

    /// Services that didn't return their data on a `Partial` export. Empty
    /// otherwise, never null.
    @Default(<String>[]) List<String> missingServices,
  }) = _DataExportDto;

  factory DataExportDto.fromJson(Map<String, dynamic> json) =>
      _$DataExportDtoFromJson(json);
}

/// Thrown by `PrivacyApi.requestDataExport` on a `429` - one export per account
/// per 24 hours. Assembling one is a fan-out across every service, so this is a
/// real limit rather than a courtesy one.
///
/// Failed and partial exports do **not** count against the limit, so meeting
/// this always means a real one succeeded within the day.
class DataExportRateLimitedException implements Exception {
  const DataExportRateLimitedException({this.retryAfter});

  /// How long until another request is allowed, when the server said.
  final Duration? retryAfter;
}

/// Thrown when a download is asked for and there is nothing to serve:
/// `409` on a failed export, `410` once the artifact has been deleted.
class DataExportUnavailableException implements Exception {
  const DataExportUnavailableException({required this.expired});

  /// True for the `410`. The difference is worth keeping: an expired export can
  /// be requested again and a failed one has a reason to show.
  final bool expired;
}
