import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:venta_mobile/core/config/site_hosts.dart';
import 'package:venta_mobile/features/auth/data/auth_api.dart';
import 'package:venta_mobile/features/support/data/models/report_dto.dart';
import 'package:venta_mobile/features/support/data/models/report_evidence.dart';

void main() {
  group('siteHost', () {
    // The bug the server side shipped once: prepending instead of replacing
    // gives `support.api.venta.gg`, a name with no DNS behind it, and every
    // link in the client goes nowhere.
    test('replaces the first label of a subdomained API host', () {
      expect(
        siteHost('https://api.venta.gg', SiteLabel.support),
        'https://support.venta.gg',
      );
    });

    test('prefixes a bare domain, which has no label to spend', () {
      expect(
        siteHost('https://venta.gg', SiteLabel.support),
        'https://support.venta.gg',
      );
    });

    test('replaces only the first label of a deeper host', () {
      expect(
        siteHost('https://api.eu.venta.gg', SiteLabel.support),
        'https://support.eu.venta.gg',
      );
    });

    test('prefixes a bare IP rather than eating an octet', () {
      expect(
        siteHost('http://127.0.0.1:5000', SiteLabel.support),
        'http://support.127.0.0.1:5000',
      );
    });

    test('carries the scheme and port over', () {
      expect(
        siteHost('http://api.dev.local:8080', SiteLabel.docs),
        'http://docs.dev.local:8080',
      );
    });

    // Two labels is "bare domain" by the shared rule, so `api.localhost`
    // prefixes rather than replacing. It reads wrong for a dev host, and it is
    // still the right answer: the server derives its own URL the same way, and
    // a client that is cleverer than the server links somewhere the server has
    // never heard of. The fix for a deployment where this is wrong is a
    // configuration field, not a divergent rule here.
    test('follows the shared rule even where it reads oddly', () {
      expect(
        siteHost('http://api.localhost:8080', SiteLabel.support),
        'http://support.api.localhost:8080',
      );
    });

    test('answers null-ish for something unparseable, so no dead link', () {
      expect(supportUrlOrNull(''), isNull);
    });
  });

  group('blocked sign-in', () {
    /// Every `403` from the token endpoint that isn't the email-verification
    /// one is `IsSigninAllowed()` refusing. Falling through to "incorrect
    /// username or password" is the one message that is definitely a lie.
    Future<Object?> grantError(int status, Object? body) async {
      final dio = Dio()
        ..httpClientAdapter = _StubAdapter(status: status, body: body);
      try {
        await AuthApi(dio: dio).passwordGrant(
          baseUrl: 'https://api.venta.gg',
          username: 'someone',
          password: 'hunter2',
        );
        return null;
      } catch (e) {
        return e;
      }
    }

    test('turns the restriction 403 into a typed refusal with a support URL',
        () async {
      final error = await grantError(403, 'User is not allowed to sign in');
      expect(error, isA<SigninNotAllowedException>());
      expect(
        (error! as SigninNotAllowedException).supportUrl,
        'https://support.venta.gg',
      );
    });

    test('still tells the email-verification 403 apart', () async {
      expect(
        await grantError(403, 'Email not verified.'),
        isA<EmailNotVerifiedException>(),
      );
    });

    test('an unrecognised 403 body is still a restriction, not a bad password',
        () async {
      expect(await grantError(403, ''), isA<SigninNotAllowedException>());
    });

    test('a 401 is left alone', () async {
      final error = await grantError(401, {'error': 'invalid_grant'});
      expect(error, isA<DioException>());
    });
  });

  group('ReportEvidence.window', () {
    List<EvidenceMessage> conversation(int count) => [
      for (var i = 0; i < count; i++)
        EvidenceMessage(
          id: 'm$i',
          authorId: 'user_a',
          content: 'message $i',
          sentAt: DateTime.utc(2026, 8, 5, 10, i),
        ),
    ];

    test('takes 10 before and 3 after the reported message', () {
      final window = ReportEvidence.window(conversation(40), 'm20');
      expect(window.length, 14);
      expect(window.first.id, 'm10');
      expect(window.last.id, 'm23');
    });

    test('clamps at the start of the conversation', () {
      final window = ReportEvidence.window(conversation(40), 'm2');
      expect(window.first.id, 'm0');
      expect(window.last.id, 'm5');
    });

    test('clamps at the end', () {
      final window = ReportEvidence.window(conversation(5), 'm4');
      expect(window.last.id, 'm4');
      expect(window.length, 5);
    });

    test('is empty when the reported message is not in the list', () {
      expect(ReportEvidence.window(conversation(5), 'nope'), isEmpty);
    });
  });

  group('ReportEvidence.build', () {
    EvidenceMessage message(String id, String content, {bool reported = false}) =>
        EvidenceMessage(
          id: id,
          authorId: 'user_a',
          content: content,
          sentAt: DateTime.utc(2026, 8, 5, 10),
          reported: reported,
        );

    Map<String, dynamic>? build(List<EvidenceMessage> messages) =>
        ReportEvidence.build(
          conversationId: 'conv_1',
          encrypted: true,
          capturedAt: DateTime.utc(2026, 8, 5, 10, 14, 22),
          messages: messages,
        );

    test('carries the encryption flag honestly and stamps a Z', () {
      final blob = build([message('m1', 'hello', reported: true)])!;
      expect(blob['encrypted'], isTrue);
      expect(blob['capturedAt'], endsWith('Z'));
      expect(blob['conversationId'], 'conv_1');
    });

    test('marks exactly the reported message', () {
      final blob = build([
        message('m0', 'context'),
        message('m1', 'the bad one', reported: true),
      ])!;
      final rows = blob['messages']! as List<dynamic>;
      expect((rows[0] as Map)['reported'], isNull);
      expect((rows[1] as Map)['reported'], isTrue);
    });

    test('sends null rather than ciphertext for an unreadable message', () {
      final blob = build([
        EvidenceMessage(id: 'm0', authorId: 'user_a', content: null),
        message('m1', 'readable', reported: true),
      ])!;
      final first = (blob['messages']! as List<dynamic>).first as Map;
      expect(first['content'], isNull);
      expect(first['unreadable'], isTrue);
    });

    test('trims from the oldest end until it fits 16 KB', () {
      final messages = [
        for (var i = 0; i < 12; i++) message('m$i', 'x' * 2000),
        message('reported', 'the bad one', reported: true),
      ];
      final blob = build(messages)!;
      final size = utf8.encode(jsonEncode(blob)).length;
      expect(size, lessThanOrEqualTo(ReportEvidence.maxBytes));
      final rows = blob['messages']! as List<dynamic>;
      // The reported message survives; the oldest context is what went.
      expect((rows.last as Map)['id'], 'reported');
      expect(rows.length, lessThan(13));
    });

    test('truncates the reported message itself rather than giving up', () {
      final blob = build([message('m0', 'y' * 40000, reported: true)])!;
      expect(
        utf8.encode(jsonEncode(blob)).length,
        lessThanOrEqualTo(ReportEvidence.maxBytes),
      );
      final only = (blob['messages']! as List<dynamic>).single as Map;
      expect(only['content'], endsWith('…'));
    });

    test('is null when there is nothing to attach', () {
      expect(build(const []), isNull);
    });
  });

  group('report wire values', () {
    test('reasons send the enum name, never the label', () {
      expect(ReportReason.hateSpeech.wireValue, 'HateSpeech');
      expect(ReportReason.hateSpeech.label, 'Hateful conduct');
    });

    test('an unknown status reads as under review rather than throwing', () {
      final report = FiledReportDto.fromJson(const {
        'id': 'rprt_1',
        'subjectKind': 'Message',
        'reason': 'Harassment',
        'status': 'SomethingNewServerSide',
      });
      expect(report.status, ReportStatus.underReview);
      expect(report.reason, ReportReason.harassment);
      expect(report.subjectKind, ReportSubjectKind.message);
    });

    test('a null `resolved` leaves the timestamp unset', () {
      final report = FiledReportDto.fromJson(const {
        'id': 'rprt_1',
        'status': 'UnderReview',
        'resolved': null,
      });
      expect(report.resolvedAt, isNull);
    });

    test('merged is read off the submission response', () {
      final merged = ReportSubmissionDto.fromJson(const {
        'id': 'rprt_1',
        'status': 'UnderReview',
        'merged': true,
      });
      expect(merged.merged, isTrue);
      expect(merged.status, ReportStatus.underReview);
    });
  });
}

/// Answers every request with one canned response, so the token endpoint's
/// refusal branches can be exercised without a server.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter({required this.status, required this.body});

  final int status;
  final Object? body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      body is String ? body! as String : jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [
          body is String ? Headers.textPlainContentType : Headers.jsonContentType,
        ],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
