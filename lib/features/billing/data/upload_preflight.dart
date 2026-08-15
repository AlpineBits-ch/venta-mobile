import 'models/entitlement_value.dart';

/// One file that will not fit, named before the transfer is spent on it.
class OversizedUpload {
  const OversizedUpload({
    required this.fileName,
    required this.sizeBytes,
    required this.ceilingBytes,
  });

  final String fileName;
  final int sizeBytes;
  final int ceilingBytes;

  /// What to put in front of the user, in two facts and no advice.
  ///
  /// Both numbers, because either alone leaves the obvious question unanswered:
  /// "too large" does not say how much too large, and "files are capped at 25
  /// MB" does not say how big this one is. Together they are the whole
  /// explanation, and there is nothing to add - what would raise the ceiling is
  /// the sentence this client does not write.
  String get sentence =>
      '$fileName is ${formatByteCeiling(sizeBytes)}. '
      'Files here are capped at ${formatByteCeiling(ceilingBytes)}.';
}

/// Whether [sizeBytes] will be refused for its size, or null when it will not
/// be - and null whenever that cannot be answered.
///
/// Four ways this declines to answer, and all four have to let the file
/// through:
///
///  * no ceiling was read, because the lookup failed or has not landed,
///  * the ceiling is unlimited,
///  * the ceiling arrived in a shape this build cannot read,
///  * or the ceiling is zero or negative, which is not a real ceiling and is
///    more likely a decode than a server that forbids every upload.
///
/// Refusing on any of those would turn a failed lookup into a broken composer,
/// which is a far worse outcome than the round trip this saves. **The server
/// enforces; this only avoids spending the transfer to be told so.**
OversizedUpload? checkUploadSize({
  required String fileName,
  required int sizeBytes,
  required EntitlementValueDto? ceiling,
}) {
  if (ceiling == null) return null;
  if (ceiling.kind != EntitlementValueKind.numeric) return null;
  if (ceiling.unlimited) return null;

  final limit = ceiling.value;
  if (limit == null || limit <= 0) return null;
  if (sizeBytes <= limit) return null;

  return OversizedUpload(
    fileName: fileName,
    sizeBytes: sizeBytes,
    ceilingBytes: limit,
  );
}

/// "Files here are capped at 25 MB", for a composer to state up front, or null
/// when there is no number to state.
///
/// Present tense and about the place rather than about the reader: it is a
/// property of where the file is going, and phrasing it as something the reader
/// has would make the next question be how to have more of it.
String? uploadCeilingLine(EntitlementValueDto? ceiling) {
  if (ceiling == null) return null;
  if (ceiling.kind != EntitlementValueKind.numeric) return null;
  if (ceiling.unlimited) return null;
  final limit = ceiling.value;
  if (limit == null || limit <= 0) return null;
  return 'Files here are capped at ${formatByteCeiling(limit)}.';
}
