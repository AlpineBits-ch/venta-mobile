import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../diagnostics/secure_storage_fault.dart';
import 'message_push_payload.dart';
import 'push_decrypt_outcome.dart';

/// Records why an Android message push did not become readable text, and
/// forwards it on the next launch.
///
/// The Android counterpart to `NseDiagnosticsReporter`, and the same shape for
/// the same reason: the FCM background isolate is a fresh Dart isolate with no
/// `getIt`, no session and - the part that matters here - **no Sentry**. Sentry
/// is initialised in `main()`, which the background entrypoint does not run. So
/// a `debugPrint` in the isolate goes to a console nobody is attached to and
/// reporting straight to Sentry from there quietly does nothing.
///
/// Hence a file. Written by whichever isolate decrypted (or failed to), drained
/// by the app on its next launch or resume. Exactly what iOS's extension already
/// does with `nse-diagnostics.json`, minus the App Group container - Android has
/// one process, so Application Support is shared by construction.
///
/// Why this is worth a file at all: every failure path in [MessagePushDecryptor]
/// returns null by design, and the caller then shows the server's placeholder.
/// "You have a new encrypted message" is therefore the visible behaviour of a
/// dozen distinct causes *and* of a client working exactly as intended against a
/// message this device genuinely cannot read. Telling those apart from a bug
/// report was not possible before this.
class PushDecryptDiagnostics {
  PushDecryptDiagnostics({
    Future<Directory> Function()? directory,
    void Function(
      String context,
      Object error, [
      StackTrace?,
      Map<String, String>?,
    ])?
    report,
  }) : _directory = directory ?? getApplicationSupportDirectory,
       _report = report ?? reportSwallowed;

  final Future<Directory> Function() _directory;
  final void Function(String, Object, [StackTrace?, Map<String, String>?])
  _report;

  static const fileName = 'push-decrypt-diagnostics.json';

  /// Beyond this the oldest entries are dropped. A handset that has been failing
  /// for a week must not hand the reporter ten thousand identical entries on the
  /// morning somebody finally opens the app, and the first few of a run say
  /// everything the last few would.
  static const maxEntries = 50;

  /// Appends one outcome. Never throws: this runs on the path whose entire
  /// purpose is that nothing there is allowed to cost the notification.
  ///
  /// Successes are recorded too. Without them a report reads as "decryption
  /// never works" when the truth may be "it works for DMs and not for channels",
  /// and that difference is the diagnosis.
  Future<void> record(
    MessagePushPayload payload,
    PushDecryptResult result,
  ) async {
    try {
      final file = File('${(await _directory()).path}/$fileName');
      final entries = await _read(file);

      entries.add({
        'outcome': result.outcome.name,
        'expected': result.outcome.isExpected,
        // Ids, never content: this file is unencrypted, and a diagnostic for a
        // decryption failure must not be the way plaintext reaches the disk.
        'messageId': payload.messageId,
        'contextId': payload.contextId,
        'isChannel': payload.isChannel,
        'hadCiphertext': payload.ciphertext != null,
        'generation': payload.mlsGeneration,
        'at': DateTime.now().toUtc().toIso8601String(),
        if (result.detail case final String it) 'detail': it,
      });

      final kept = entries.length <= maxEntries
          ? entries
          : entries.sublist(entries.length - maxEntries);

      await file.writeAsString(jsonEncode(kept), flush: true);
    } catch (e) {
      debugPrint('PushDecryptDiagnostics: could not record an outcome: $e');
    }
  }

  /// Reads, reports and clears. Safe to call on every resume.
  ///
  /// Returns how many entries were drained, so a caller can tell "nothing to
  /// report" from "the file could not be read".
  Future<int> drain() async {
    try {
      final file = File('${(await _directory()).path}/$fileName');
      if (!await file.exists()) return 0;

      final raw = await file.readAsString();
      // Deleted before the entries are reported, not after. Reporting is the
      // part that can throw, and a file that survives a failed drain is read
      // again on the next resume - which turns one bad night into an unbounded
      // stream of identical issues.
      await file.delete();

      final decoded = jsonDecode(raw);
      if (decoded is! List) return 0;

      var reported = 0;
      for (final entry in decoded) {
        if (entry is! Map) continue;
        if (_reportOne(Map<String, Object?>.from(entry))) reported++;
      }
      return reported;
    } catch (e) {
      // The reporter for the undiagnosable path must not itself become one.
      debugPrint('PushDecryptDiagnostics: could not drain the log: $e');
      return 0;
    }
  }

  /// False for an entry not worth a report - a push that decrypted. Those are
  /// written so the file shows the ratio, and the ratio is read by whoever is
  /// looking at a run of failures around them, not by Sentry.
  bool _reportOne(Map<String, Object?> entry) {
    final name = entry['outcome'] as String? ?? 'unknown';
    final outcome = PushDecryptOutcome.values
        .where((o) => o.name == name)
        .firstOrNull;

    if (outcome?.isSuccess ?? false) return false;

    _report(
      // One stable context per outcome, so the issue list groups by cause
      // rather than by handset - the same grouping the iOS reporter uses.
      'MessagePushDecryptor/$name',
      PushDecryptFailure(outcome: name, detail: entry['detail'] as String?),
      null,
      {
        'push_outcome': name,
        'push_expected': '${entry['expected'] ?? false}',
        if (entry['detail'] case final String it) 'push_detail': it,
        if (entry['messageId'] case final String id) 'push_message_id': id,
        if (entry['contextId'] case final String id) 'push_context_id': id,
        if (entry['isChannel'] case final bool it) 'push_is_channel': '$it',
        if (entry['hadCiphertext'] case final bool it)
          'push_had_ciphertext': '$it',
        if (entry['generation'] case final int it) 'push_generation': '$it',
        if (entry['at'] case final String at) 'push_at': at,
      },
    );

    return true;
  }

  Future<List<Map<String, Object?>>> _read(File file) async {
    if (!await file.exists()) return [];
    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map(Map<String, Object?>.from)
          .toList();
    } on FormatException {
      // A half-written file from a killed isolate. Starting over loses a few
      // breadcrumbs; refusing to write loses every one from here on.
      return [];
    }
  }
}

/// A push this device could not turn into readable text.
///
/// A named type rather than a bare string so Sentry groups these by class and
/// the message reads as a sentence in the issue title - matching
/// `NseDecryptFailure` on the iOS side.
class PushDecryptFailure implements Exception {
  const PushDecryptFailure({required this.outcome, this.detail});

  final String outcome;
  final String? detail;

  @override
  String toString() => detail == null
      ? 'a message push could not be decrypted: $outcome'
      : 'a message push could not be decrypted: $outcome ($detail)';
}
