import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../diagnostics/secure_storage_fault.dart';
import '../storage/shared_container.dart';

/// Forwards what iOS's notification service extension recorded about pushes it
/// could not decrypt.
///
/// The extension is a separate process with no Sentry SDK - `sentry-cocoa` is a
/// CocoaPod on the `Runner` target and there is no NotificationService target in
/// the `Podfile` - so it leaves breadcrumbs in the App Group container and this
/// picks them up on the next launch or resume. See `NseDiagnostics` in
/// `ios/NotificationService/`.
///
/// Without this the extension is undiagnosable in production by construction:
/// it runs when the app does not, `NSLog` goes to a console nobody is attached
/// to, and its only visible behaviour is a notification that says
/// "You have a new encrypted message" - which is also what it says when it is
/// working exactly as intended and the device genuinely cannot read the
/// message.
///
/// Telling those two apart is the entire point, so the outcomes are split into
/// [_expected] and everything else rather than reported as one undifferentiated
/// failure.
class NseDiagnosticsReporter {
  NseDiagnosticsReporter({
    Future<Directory?> Function()? container,
    void Function(
      String context,
      Object error, [
      StackTrace?,
      Map<String, String>?,
    ])?
    report,
  }) : _container = container ?? SharedContainer.directory,
       _report = report ?? reportSwallowed;

  final Future<Directory?> Function() _container;
  final void Function(String, Object, [StackTrace?, Map<String, String>?])
  _report;

  /// Must match the file `NseDiagnostics.record` writes.
  static const fileName = 'nse-diagnostics.json';

  /// Every outcome `NseOutcome` can write, mirrored here so the two sides can
  /// be asserted equal.
  ///
  /// The extension is a separate target in another language and its codes
  /// arrive as bare strings, so a case added on one side and forgotten on the
  /// other produces reports tagged `unknown` from a build nobody can re-run.
  /// `nse_diagnostics_test.dart` reads the Swift source and compares.
  static const knownOutcomes = {
    'decrypted',
    'servedFromCache',
    'notEncrypted',
    'noAppGroupContainer',
    'stateKeyUnavailable',
    'stateKeyInAnotherGroup',
    'sealedFileUnreadable',
    'noCiphertext',
    'noGeneration',
    'noGroupForGeneration',
    'registryAbsent',
    'registryEmpty',
    'initStorageFailed',
    'processMessageFailed',
    'notApplicationMessage',
    'senderUnnamed',
    'senderMismatch',
    'senderNotInRoster',
    'undecodablePlaintext',
  };

  /// Outcomes where the placeholder is the *correct* answer and nothing is
  /// broken: this device was never admitted to the group the message belongs
  /// to, or the ciphertext did not fit in the 4KB FCM budget and the server
  /// deliberately did not send it.
  ///
  /// Still reported - a run of `noGroupForGeneration` on a conversation the
  /// user can read in the app means a Welcome was never processed, which is a
  /// real bug wearing an expected outcome's clothes - but at a level that does
  /// not drown the ones that are always wrong.
  ///
  /// `registryAbsent` and `registryEmpty` are deliberately **not** here, even
  /// though the placeholder is equally correct for them. They say this device
  /// holds no MLS state at all rather than that it is outside one group, which
  /// is a different and larger fault: a directory the app never populated, a
  /// user id in the push that resolves somewhere else, or an install where MLS
  /// never initialised. Filing them as expected is precisely what hid them
  /// inside `noGroupForGeneration`.
  static const _expected = {'noGroupForGeneration', 'noCiphertext'};

  /// Reads, reports and clears. Safe to call on every resume: the file is
  /// deleted once drained, so a quiet period costs one `exists` check.
  /// No platform check: [SharedContainer.directory] already answers null
  /// everywhere that is not iOS, which is the same "nothing to do" this needs
  /// and the only one a host test can reach.
  Future<int> drain() async {
    try {
      final container = await _container();
      if (container == null) return 0;

      final file = File('${container.path}/$fileName');
      if (!await file.exists()) return 0;

      final raw = await file.readAsString();
      // Deleted before the entries are reported, not after. Reporting is the
      // part that can throw, and a file that survives a failed drain is read
      // again on the next resume - which turns one extension failure into an
      // unbounded stream of identical Sentry issues.
      await file.delete();

      final decoded = jsonDecode(raw);
      if (decoded is! List) return 0;

      for (final entry in decoded) {
        if (entry is Map) _reportOne(Map<String, Object?>.from(entry));
      }
      return decoded.length;
    } catch (e) {
      // The reporter for the undiagnosable path must not itself become one.
      debugPrint(
        'NseDiagnosticsReporter: could not drain the extension log: $e',
      );
      return 0;
    }
  }

  void _reportOne(Map<String, Object?> entry) {
    final outcome = entry['outcome'] as String? ?? 'unknown';
    final detail = entry['detail'] as String?;

    _report(
      // One stable context per outcome, so the issue list groups by cause
      // rather than by handset.
      'NotificationServiceExtension/$outcome',
      NseDecryptFailure(outcome: outcome, detail: detail),
      null,
      {
        'nse_outcome': outcome,
        'nse_expected': '${_expected.contains(outcome)}',
        if (detail case final String it) 'nse_detail': it,
        if (entry['messageId'] case final String id) 'nse_message_id': id,
        if (entry['contextId'] case final String id) 'nse_context_id': id,
        if (entry['at'] case final String at) 'nse_at': at,
      },
    );
  }
}

/// A push the extension could not turn into readable text.
///
/// A named type rather than a bare string so Sentry groups these by class and
/// the message reads as a sentence in the issue title.
class NseDecryptFailure implements Exception {
  const NseDecryptFailure({required this.outcome, this.detail});

  final String outcome;
  final String? detail;

  @override
  String toString() => detail == null
      ? 'the notification extension could not decrypt a push: $outcome'
      : 'the notification extension could not decrypt a push: $outcome ($detail)';
}
