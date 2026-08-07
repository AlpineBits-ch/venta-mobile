import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:venta_mobile/core/push/message_push_payload.dart';
import 'package:venta_mobile/core/push/nse_diagnostics_reporter.dart';
import 'package:venta_mobile/core/push/push_decrypt_diagnostics.dart';
import 'package:venta_mobile/core/push/push_decrypt_outcome.dart';

/// What these cover: the only channel by which Android can say why a push
/// showed the placeholder.
///
/// Same problem the iOS extension had, and the same shape of answer. Every
/// failure path in `MessagePushDecryptor` returns null on purpose - a
/// notification that says the wrong thing beats one that never arrives - so
/// "You have a new encrypted message" is the visible behaviour of a dozen
/// distinct causes *and* of a client working exactly as intended against a
/// message this device genuinely cannot read. The FCM background isolate has no
/// Sentry and its `debugPrint` reaches nobody in production, so the outcome goes
/// to disk and the app forwards it on the next launch.
void main() {
  late Directory support;
  late List<(String context, Object error, Map<String, String>? tags)> reported;
  late PushDecryptDiagnostics diagnostics;

  setUp(() async {
    support = await Directory.systemTemp.createTemp('push-diagnostics');
    reported = [];
    diagnostics = PushDecryptDiagnostics(
      directory: () async => support,
      report: (context, error, [stack, extra]) =>
          reported.add((context, error, extra)),
    );
  });

  tearDown(() async {
    if (await support.exists()) await support.delete(recursive: true);
  });

  File file() => File('${support.path}/${PushDecryptDiagnostics.fileName}');

  MessagePushPayload payload({
    String messageId = 'msg-1',
    String? ciphertext = 'Y2lwaGVy',
    int? generation = 3,
    bool isChannel = false,
  }) => MessagePushPayload(
    messageId: messageId,
    contextId: isChannel ? 'chan-1' : 'conv-1',
    channelId: isChannel ? 'chan-1' : null,
    conversationId: isChannel ? null : 'conv-1',
    senderName: 'Ben',
    placeholderBody: 'You have a new encrypted message',
    recipientUserId: 'anna',
    isEncrypted: true,
    ciphertext: ciphertext,
    mlsGeneration: generation,
  );

  Future<List<Map<String, Object?>>> onDisk() async =>
      (jsonDecode(await file().readAsString()) as List)
          .cast<Map<String, dynamic>>();

  group('the outcome vocabulary is shared with iOS', () {
    /// The two platforms run different code in different languages against the
    /// same MLS state. A report is only useful if "this device was never in the
    /// group" reads the same whichever handset it came from, so where a name
    /// exists on both sides it has to be the same name.
    test('every shared name is spelled identically', () {
      final dart = PushDecryptOutcome.values.map((o) => o.name).toSet();
      final swift = NseDiagnosticsReporter.knownOutcomes;

      // Not equality: each platform can fail in ways the other cannot. iOS has
      // `noAppGroupContainer` (Android has one process and no container);
      // Android has `noRecipient` and `otherAccountLoaded` (the extension opens
      // the engine read-only and never repoints it).
      expect(
        dart.intersection(swift),
        isNotEmpty,
        reason: 'the two sides should share most of their vocabulary',
      );

      for (final name in const [
        'decrypted',
        'servedFromCache',
        'notEncrypted',
        'noCiphertext',
        'noGeneration',
        'noGroupForGeneration',
        'initStorageFailed',
        'processMessageFailed',
        'notApplicationMessage',
        'senderUnnamed',
        'senderMismatch',
        'senderNotInRoster',
        'undecodablePlaintext',
        'stateKeyUnavailable',
      ]) {
        expect(dart, contains(name), reason: 'missing from the Dart enum');
        expect(swift, contains(name), reason: 'missing from the iOS set');
      }
    });

    /// The distinction the iOS reporter had to learn the hard way: a device that
    /// was never admitted to a group is not a bug, and filing it alongside the
    /// ones that are always wrong is what hid the real faults.
    test('expected outcomes match the ones iOS treats as expected', () {
      expect(
        PushDecryptOutcome.noGroupForGeneration.isExpected,
        isTrue,
        reason: 'never admitted to the group - the placeholder is correct',
      );
      expect(PushDecryptOutcome.noCiphertext.isExpected, isTrue);
      expect(
        PushDecryptOutcome.threw.isExpected,
        isFalse,
        reason: 'an exception is never the correct answer',
      );
      expect(PushDecryptOutcome.senderMismatch.isExpected, isFalse);
    });
  });

  group('record', () {
    test('writes the outcome and the ids, and no content', () async {
      await diagnostics.record(
        payload(),
        const PushDecryptResult.failed(
          PushDecryptOutcome.noGroupForGeneration,
          detail: 'generation 3',
        ),
      );

      final entries = await onDisk();

      expect(entries, hasLength(1));
      expect(entries.single['outcome'], 'noGroupForGeneration');
      expect(entries.single['expected'], isTrue);
      expect(entries.single['messageId'], 'msg-1');
      expect(entries.single['contextId'], 'conv-1');
      expect(entries.single['generation'], 3);
      expect(entries.single['detail'], 'generation 3');
    });

    /// Without these a report reads as "decryption never works" when the truth
    /// may be "it works for DMs and not for channels" - and that difference is
    /// the diagnosis.
    test('records successes too, so the ratio is visible', () async {
      await diagnostics.record(
        payload(),
        const PushDecryptResult('hello', PushDecryptOutcome.decrypted),
      );
      await diagnostics.record(
        payload(messageId: 'msg-2', isChannel: true),
        const PushDecryptResult.failed(PushDecryptOutcome.noGroupForGeneration),
      );

      final entries = await onDisk();

      expect(entries.map((e) => e['outcome']), [
        'decrypted',
        'noGroupForGeneration',
      ]);
      expect(entries.last['isChannel'], isTrue);
    });

    test('says whether the server sent a ciphertext at all', () async {
      await diagnostics.record(
        payload(ciphertext: null),
        const PushDecryptResult.failed(PushDecryptOutcome.noCiphertext),
      );

      expect((await onDisk()).single['hadCiphertext'], isFalse);
    });

    /// A handset failing for a week must not hand the reporter ten thousand
    /// identical entries the morning somebody finally opens the app.
    test('keeps the newest entries and drops the oldest', () async {
      for (var i = 0; i < PushDecryptDiagnostics.maxEntries + 10; i++) {
        await diagnostics.record(
          payload(messageId: 'msg-$i'),
          const PushDecryptResult.failed(PushDecryptOutcome.threw),
        );
      }

      final entries = await onDisk();

      expect(entries, hasLength(PushDecryptDiagnostics.maxEntries));
      expect(entries.last['messageId'], 'msg-59');
      expect(entries.first['messageId'], 'msg-10');
    });

    /// This runs on the path whose entire purpose is that nothing there is
    /// allowed to cost the notification.
    test('a half-written file starts over rather than throwing', () async {
      await file().writeAsString('{ not json');

      await diagnostics.record(
        payload(),
        const PushDecryptResult.failed(PushDecryptOutcome.threw),
      );

      expect((await onDisk()), hasLength(1));
    });

    test('an unwritable directory is swallowed', () async {
      final broken = PushDecryptDiagnostics(
        directory: () async => Directory('${support.path}/nope/deeper'),
        report: (context, error, [stack, extra]) {},
      );

      await expectLater(
        broken.record(
          payload(),
          const PushDecryptResult.failed(PushDecryptOutcome.threw),
        ),
        completes,
      );
    });
  });

  group('drain', () {
    test('reports each failure with its cause as the grouping key', () async {
      await diagnostics.record(
        payload(),
        const PushDecryptResult.failed(PushDecryptOutcome.senderMismatch),
      );

      final count = await diagnostics.drain();

      expect(count, 1);
      expect(reported.single.$1, 'MessagePushDecryptor/senderMismatch');
      expect(reported.single.$3?['push_outcome'], 'senderMismatch');
      expect(reported.single.$3?['push_expected'], 'false');
      expect(reported.single.$3?['push_message_id'], 'msg-1');
      expect(
        reported.single.$2.toString(),
        contains('could not be decrypted: senderMismatch'),
      );
    });

    test('does not report a push that decrypted', () async {
      await diagnostics.record(
        payload(),
        const PushDecryptResult('hello', PushDecryptOutcome.decrypted),
      );
      await diagnostics.record(
        payload(messageId: 'msg-2'),
        const PushDecryptResult('hi', PushDecryptOutcome.servedFromCache),
      );

      expect(await diagnostics.drain(), 0);
      expect(reported, isEmpty);
    });

    test('marks the expected outcomes so they do not drown the rest', () async {
      await diagnostics.record(
        payload(),
        const PushDecryptResult.failed(PushDecryptOutcome.noGroupForGeneration),
      );

      await diagnostics.drain();

      expect(reported.single.$3?['push_expected'], 'true');
    });

    /// A file that survives a failed drain is read again on the next resume,
    /// which turns one bad night into an unbounded stream of identical issues.
    test('clears the file even when reporting throws', () async {
      await diagnostics.record(
        payload(),
        const PushDecryptResult.failed(PushDecryptOutcome.threw),
      );

      final exploding = PushDecryptDiagnostics(
        directory: () async => support,
        report: (context, error, [stack, extra]) => throw StateError('nope'),
      );

      expect(await exploding.drain(), 0);
      expect(await file().exists(), isFalse);
    });

    test('an absent file is nothing to do, not an error', () async {
      expect(await diagnostics.drain(), 0);
      expect(reported, isEmpty);
    });

    test('draining twice reports once', () async {
      await diagnostics.record(
        payload(),
        const PushDecryptResult.failed(PushDecryptOutcome.threw),
      );

      expect(await diagnostics.drain(), 1);
      expect(await diagnostics.drain(), 0);
      expect(reported, hasLength(1));
    });

    /// A build that recorded an outcome this one has since renamed. Reported
    /// under its raw name rather than dropped - the entry is still evidence.
    test('an unrecognised outcome is still reported', () async {
      await file().writeAsString(
        jsonEncode([
          {'outcome': 'somethingNew', 'messageId': 'msg-9'},
        ]),
      );

      expect(await diagnostics.drain(), 1);
      expect(reported.single.$1, 'MessagePushDecryptor/somethingNew');
    });
  });
}
