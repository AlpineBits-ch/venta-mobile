import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:venta_mobile/core/push/nse_diagnostics_reporter.dart';

/// What these cover: the only channel by which iOS's notification service
/// extension can say anything at all.
///
/// The extension runs in its own process, when the app does not, with no Sentry
/// SDK and no console attached. Its entire observable behaviour was "the
/// notification says *You have a new encrypted message*" - which is also what
/// it says when it is working perfectly and the device genuinely cannot read
/// the message. A dozen distinct causes shared one symptom, which is why a real
/// report could not be narrowed down from it.
///
/// So the contract asserted here is: every entry the extension wrote reaches
/// the reporter with its reason code intact, expected outcomes are marked as
/// expected rather than being dropped, and the file is cleared exactly once so
/// one bad night does not become an unbounded stream of identical issues.
void main() {
  late Directory container;
  late List<(String context, Object error, Map<String, String>? tags)> reported;
  late NseDiagnosticsReporter reporter;

  setUp(() async {
    container = await Directory.systemTemp.createTemp('nse-diagnostics');
    reported = [];
    reporter = NseDiagnosticsReporter(
      container: () async => container,
      report: (context, error, [stack, extra]) =>
          reported.add((context, error, extra)),
    );
  });

  tearDown(() async {
    if (await container.exists()) await container.delete(recursive: true);
  });

  File file() => File('${container.path}/${NseDiagnosticsReporter.fileName}');

  Future<void> write(List<Map<String, Object?>> entries) =>
      file().writeAsString(jsonEncode(entries));

  test('reports nothing when the extension has not run', () async {
    expect(await reporter.drain(), 0);
    expect(reported, isEmpty);
  });

  test('forwards a failure with its reason code and ids', () async {
    await write([
      {
        'outcome': 'stateKeyUnavailable',
        'at': '2026-08-02T10:00:00Z',
        'messageId': 'message_1',
        'contextId': 'conversation_1',
        'detail': 'OSStatus -34018 (errSecMissingEntitlement)',
      },
    ]);

    expect(await reporter.drain(), 1);
    expect(reported, hasLength(1));

    final (context, error, tags) = reported.single;
    // Grouped by cause, so the issue list separates a keychain refusal from a
    // group this device was never in.
    expect(context, 'NotificationServiceExtension/stateKeyUnavailable');
    expect(tags!['nse_outcome'], 'stateKeyUnavailable');
    expect(tags['nse_detail'], 'OSStatus -34018 (errSecMissingEntitlement)');
    expect(tags['nse_message_id'], 'message_1');
    expect(tags['nse_context_id'], 'conversation_1');
    // The number is the diagnosis, so it has to survive into the report.
    expect('$error', contains('errSecMissingEntitlement'));
  });

  test(
    'marks the outcomes where the placeholder is the correct answer',
    () async {
      await write([
        {'outcome': 'noGroupForGeneration'},
        {'outcome': 'senderMismatch'},
      ]);

      await reporter.drain();

      final byOutcome = {
        for (final (_, _, tags) in reported) tags!['nse_outcome']: tags,
      };
      // A device that was never admitted to the group cannot read the message,
      // and saying so is right - but it is still reported, because a run of
      // them on a conversation the app can read means a Welcome was dropped.
      expect(byOutcome['noGroupForGeneration']!['nse_expected'], 'true');
      // Nothing legitimately produces this one.
      expect(byOutcome['senderMismatch']!['nse_expected'], 'false');
    },
  );

  test('clears the log so one bad night is reported once', () async {
    await write([
      {'outcome': 'initStorageFailed'},
      {'outcome': 'processMessageFailed'},
    ]);

    expect(await reporter.drain(), 2);
    expect(await file().exists(), isFalse);

    expect(await reporter.drain(), 0);
    expect(reported, hasLength(2));
  });

  test('a corrupt log is dropped rather than retried forever', () async {
    await file().writeAsString('{not json');

    expect(await reporter.drain(), 0);
    expect(reported, isEmpty);
    expect(await file().exists(), isFalse);
  });
}
