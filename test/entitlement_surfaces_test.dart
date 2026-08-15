import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mobile/core/device/device_id_service.dart';
import 'package:venta_mobile/core/network/api_client.dart';
import 'package:venta_mobile/core/theme/app_theme.dart';
import 'package:venta_mobile/core/voice/video_layers.dart';
import 'package:venta_mobile/core/voice/voice_media_api.dart';
import 'package:venta_mobile/core/voice/voice_media_dto.dart';
import 'package:venta_mobile/core/voice/voice_snapshot_dto.dart';
import 'package:venta_mobile/core/widgets/call_action_button.dart';
import 'package:venta_mobile/core/widgets/voice_limits_bar.dart';
import 'package:venta_mobile/features/auth/data/auth_repository.dart';
import 'package:venta_mobile/features/billing/data/entitlement_api.dart';
import 'package:venta_mobile/features/billing/data/entitlement_reader.dart';
import 'package:venta_mobile/features/billing/data/models/entitlement_degradation_dto.dart';
import 'package:venta_mobile/features/billing/data/models/entitlement_ladder.dart';
import 'package:venta_mobile/features/billing/data/models/entitlement_snapshot_dto.dart';
import 'package:venta_mobile/features/billing/data/models/entitlement_denial.dart';
import 'package:venta_mobile/features/billing/data/models/entitlement_value.dart';
import 'package:venta_mobile/features/billing/data/upload_preflight.dart';
import 'package:venta_mobile/features/billing/presentation/widgets/entitlement_notice.dart';
import 'package:venta_mobile/features/guild_voice/data/guild_voice_api.dart';

/// The surfaces that learn about a limit in the moment, rather than in Settings
/// some time afterwards.
///
/// Four things are being pinned here, and each one fails silently if it breaks:
///
/// 1. **A reduction is a success.** A clamped publish is a `200` with the whole
///    normal body in it. Nothing may roll back on one, and the sentence has to
///    reach the room that caused it while somebody is still looking at it.
/// 2. **A refusal is a decision, not a failure.** A `403` in the entitlement
///    vocabulary carries its own explanation, and letting one fall into a
///    generic error path throws that explanation away and invites a retry loop
///    against something already decided.
/// 3. **A pre-flight check may never be the enforcement.** Every way of not
///    knowing the ceiling has to let the file through, because the alternative
///    is a composer that refuses uploads whenever a lookup fails.
/// 4. **`none` is a real rung.** It means audio-only, and reading it as an
///    absence draws a camera button on a room that will refuse it.
///
/// And one thing that is not a behaviour at all: none of these surfaces says
/// what would lift the limit. That is asserted at the bottom, over the copy
/// every one of them can produce.

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockDeviceIdService extends Mock implements DeviceIdService {}

const _base = 'https://api.venta.test';

Map<String, dynamic> _numeric(int? value, {bool unlimited = false}) => {
  'kind': 'numeric',
  'value': value,
  'unlimited': unlimited,
};

Map<String, dynamic> _ladder(String rung, int rank) => {
  'kind': 'ladder',
  'rung': rung,
  'rank': rank,
  'ladder': 'video_quality',
};

/// The guide's own §8 example.
Map<String, dynamic> _limitsJson({
  Map<String, dynamic>? videoCeiling,
  Map<String, dynamic>? maxPublishers,
  int publisherCount = 2,
}) => {
  'maxParticipants': _numeric(10),
  'videoCeiling': videoCeiling ?? _ladder('720p30', 2),
  'maxPublishers': maxPublishers ?? _numeric(2),
  'publisherCount': publisherCount,
};

Map<String, dynamic> _snapshotJson({Map<String, dynamic>? limits}) => {
  'roomId': 'channel-123',
  'kind': 'channel',
  'instanceId': 'inst-1',
  'version': 43,
  'participants': <dynamic>[],
  'limits': ?limits,
};

Map<String, dynamic> _degradationJson({
  String key = 'voice.video_ceiling',
  String reason = 'guild_plan_limit',
  String? boundBy = 'guild',
}) => {
  'key': key,
  'requested': _ladder('1080p60', 4),
  'granted': _ladder('720p30', 2),
  'reason': reason,
  'boundBy': ?boundBy,
  'remedy': 'upgrade_guild',
  'actorCanRemedy': false,
  'subject': {'kind': 'guild', 'id': 'guild-1'},
};

/// The §4 denial body, in full.
Map<String, dynamic> _denialJson({
  String code = 'guild_plan_limit',
  String key = 'storage.upload_max_bytes',
  String? boundBy = 'guild',
}) => {
  'code': code,
  'key': key,
  'requested': _numeric(94371840),
  'granted': _numeric(26214400),
  'reason': code,
  'boundBy': ?boundBy,
  'remedy': 'upgrade_guild',
  'actorCanRemedy': true,
  'subject': {'kind': 'guild', 'id': 'guild-1'},
  'retryable': false,
};

DioException _dioError(int status, Object? body) => DioException(
  requestOptions: RequestOptions(path: '/api/v1/messaging/attachments'),
  response: Response<dynamic>(
    requestOptions: RequestOptions(path: '/api/v1/messaging/attachments'),
    statusCode: status,
    data: body,
  ),
);

/// Answers by path. A null body is a `404`.
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this.handler);

  final List<RequestOptions> requests = [];
  final Object? Function(String path) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final body = handler(options.path);
    return ResponseBody.fromString(
      body == null ? '' : jsonEncode(body),
      body == null ? 404 : 200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

ApiClient _client(_ScriptedAdapter adapter) {
  final auth = _MockAuthRepository();
  when(() => auth.baseUrl).thenReturn(_base);
  when(() => auth.ensureValidToken()).thenAnswer((_) async => 'token');
  final client = ApiClient(authRepository: auth);
  client.dio.httpClientAdapter = adapter;
  return client;
}

Map<String, dynamic> _meJson({
  int uploadBytes = 104857600,
  int guildPairedBytes = 104857600,
  int ttlSeconds = 60,
  int version = 1,
  String subjectId = 'user-1',
}) => {
  'subject': {'kind': 'user', 'id': subjectId},
  'ttlSeconds': ttlSeconds,
  'version': version,
  'entitlements': {
    'user.upload_max_bytes': _numeric(uploadBytes),
    'storage.upload_max_bytes': _numeric(guildPairedBytes),
  },
};

Map<String, dynamic> _guildJson({int uploadBytes = 26214400}) => {
  'subject': {'kind': 'guild', 'id': 'guild-1'},
  'ttlSeconds': 60,
  'version': 1,
  'entitlements': {'storage.upload_max_bytes': _numeric(uploadBytes)},
};

void main() {
  group('voice limits ride the snapshot', () {
    test('the documented block parses into denominators and a rung', () {
      final snapshot = VoiceRoomSnapshotDto.fromJson(
        _snapshotJson(limits: _limitsJson()),
      );
      final limits = snapshot.limits!;

      expect(limits.participantCeiling, 10);
      expect(limits.publisherCeiling, 2);
      expect(limits.publisherCount, 2);
      expect(limits.videoRung, '720p30');
      expect(limits.occupancyLabel(6), '6 of 10');
      expect(limits.publisherLabel, '2 of 2 sharing');
    });

    // Absent is "no limit information", not "no limits". A client that filled
    // the gap with a permissive default would draw a camera button on a room
    // that refuses it.
    test('an absent limits block is null, not an empty one', () {
      final snapshot = VoiceRoomSnapshotDto.fromJson(_snapshotJson());

      expect(snapshot.limits, isNull);
    });

    test('a full room reports no free publisher slot, and says so', () {
      final limits = VoiceRoomLimitsDto.fromJson(_limitsJson());

      expect(limits.publishersFull, isTrue);
      expect(limits.canPublishVideo, isFalse);
      expect(limits.videoBlockedSentence, contains('2 of 2'));
    });

    test('one free slot leaves video publishable', () {
      final limits = VoiceRoomLimitsDto.fromJson(
        _limitsJson(publisherCount: 1),
      );

      expect(limits.publishersFull, isFalse);
      expect(limits.canPublishVideo, isTrue);
      expect(limits.videoBlockedSentence, isNull);
    });

    // A room with one slot is not "1 of 1 people are sharing", which reads as
    // arithmetic rather than as an answer.
    test('a single-publisher room gets its own sentence', () {
      final limits = VoiceRoomLimitsDto.fromJson(
        _limitsJson(maxPublishers: _numeric(1), publisherCount: 1),
      );

      expect(limits.videoBlockedSentence, 'Someone else is already sharing '
          'video here.');
    });

    test('an unlimited publisher ceiling is no ceiling at all', () {
      final limits = VoiceRoomLimitsDto.fromJson(
        _limitsJson(
          maxPublishers: _numeric(null, unlimited: true),
          publisherCount: 40,
        ),
      );

      expect(limits.publisherCeiling, isNull);
      expect(limits.publishersFull, isFalse);
      expect(limits.publisherLabel, isNull);
      expect(limits.canPublishVideo, isTrue);
    });

    // The whole point of the bottom rung: it is how "this server is over its
    // video budget" is said without refusing the call.
    test('the none rung is audio-only, which is a state and not an absence', () {
      final limits = VoiceRoomLimitsDto.fromJson(
        _limitsJson(videoCeiling: _ladder('none', 0)),
      );

      expect(limits.isAudioOnly, isTrue);
      expect(limits.canPublishVideo, isFalse);
      expect(limits.videoBlockedSentence, contains('audio-only'));
    });

    // A rung added after this build shipped is a tier *above* the ones here.
    // Reading an unknown name as the bottom would turn a new tier into a
    // downgrade, and would silently disable the camera for everyone on it.
    test('a rung this build has never heard of is not audio-only', () {
      final limits = VoiceRoomLimitsDto.fromJson(
        _limitsJson(videoCeiling: _ladder('2160p120', 7), publisherCount: 0),
      );

      expect(limits.isAudioOnly, isFalse);
      expect(limits.canPublishVideo, isTrue);
      expect(limits.videoRung, '2160p120');
    });

    // A value kind added server-side must not become a false ceiling. Zero is a
    // real answer meaning "none of this", and handing one out for a payload
    // that could not be parsed would disable controls for no reason.
    test('an unreadable value yields no ceiling rather than zero', () {
      final limits = VoiceRoomLimitsDto.fromJson({
        'maxParticipants': {'kind': 'colour', 'hue': 'blue'},
        'videoCeiling': {'kind': 'colour', 'hue': 'blue'},
        'maxPublishers': {'kind': 'colour', 'hue': 'blue'},
        'publisherCount': 3,
      });

      expect(limits.participantCeiling, isNull);
      expect(limits.publisherCeiling, isNull);
      expect(limits.videoRung, isNull);
      expect(limits.isAudioOnly, isFalse);
      expect(limits.canPublishVideo, isTrue);
      expect(limits.occupancyLabel(3), isNull);
    });

    // Held in cubit state, which is Equatable - two equal snapshots must not
    // emit, and a changed ceiling must.
    test('limits compare by value, so an unchanged room does not emit', () {
      expect(
        VoiceRoomLimitsDto.fromJson(_limitsJson()),
        VoiceRoomLimitsDto.fromJson(_limitsJson()),
      );
      expect(
        VoiceRoomLimitsDto.fromJson(_limitsJson()),
        isNot(VoiceRoomLimitsDto.fromJson(_limitsJson(publisherCount: 1))),
      );
    });
  });

  group('a clamped publish is a 200', () {
    test('the reduction rides the normal negotiate body', () {
      final response = VoiceNegotiateResponseDto.fromJson({
        'sessionDescription': {'type': 'answer', 'sdp': 'v=0'},
        'tracks': <dynamic>[],
        'degradations': [_degradationJson()],
      });

      // The body the caller already parses, unchanged. Nothing rolls back.
      expect(response.sessionDescription['sdp'], 'v=0');
      expect(response.degradations, hasLength(1));
      expect(response.degradations.single.key, 'voice.video_ceiling');
    });

    test('an absent degradations array is the normal case', () {
      final response = VoiceNegotiateResponseDto.fromJson({
        'sessionDescription': {'type': 'answer', 'sdp': 'v=0'},
        'tracks': <dynamic>[],
      });

      expect(response.degradations, isEmpty);
    });

    // The sentence the room renders. Present tense and about what is being
    // sent now, unlike the session log's past-tense "was reduced to".
    test('the in-the-moment sentence names the grant and attributes it', () {
      final degradation = EntitlementDegradationDto.fromJson(
        _degradationJson(),
      );

      expect(
        degradation.notice,
        "Video quality: 720p30. Limited by this server's plan.",
      );
    });

    test('a reduction with no grant still attributes the limit', () {
      final degradation = EntitlementDegradationDto.fromJson({
        ..._degradationJson(),
      }..remove('granted'));

      expect(degradation.notice, "Limited by this server's plan.");
      expect(degradation.notice, isNot(contains('null')));
    });

    test('an unknown reason never renders the raw code', () {
      final degradation = EntitlementDegradationDto.fromJson(
        _degradationJson(reason: 'sunspots', boundBy: null),
      );

      expect(degradation.notice, contains('A limit applied.'));
      expect(degradation.notice, isNot(contains('sunspots')));
    });
  });

  group('what a negotiation declares', () {
    late _ScriptedAdapter adapter;
    late GuildVoiceApi api;

    setUp(() {
      adapter = _ScriptedAdapter(
        (_) => {
          'sessionDescription': <String, dynamic>{'type': 'answer', 'sdp': ''},
          'tracks': <dynamic>[],
        },
      );
      final deviceIdService = _MockDeviceIdService();
      when(() => deviceIdService.deviceId).thenReturn('device-1');
      api = GuildVoiceApi(
        client: _client(adapter),
        deviceIdService: deviceIdService,
      );
    });

    Map<String, dynamic> lastBody() =>
        adapter.requests.last.data as Map<String, dynamic>;

    test('a camera publish states the picture it intends to send', () async {
      await api.negotiate(
        guildId: 'g1',
        channelId: 'c1',
        mediaSessionId: 'media-1',
        sessionDescription: const {},
        tracks: const [],
        video: VideoPublishIntent.conservative.toJson(),
      );

      expect(lastBody()['video'], {'height': 720, 'framerate': 30});
    });

    // An audio-only publish is never affected by a video ceiling, and declaring
    // a height on the microphone's own negotiation invites an answer to a
    // question nobody asked.
    test('an audio-only publish declares nothing', () async {
      await api.negotiate(
        guildId: 'g1',
        channelId: 'c1',
        mediaSessionId: 'media-1',
        sessionDescription: const {},
        tracks: const [],
      );

      expect(lastBody().containsKey('video'), isFalse);
    });

    // The capture constraints and the target move together, whatever the rung
    // resolved to. A frame rate left idealised but uncapped is how a camera
    // opens at 60 on a rung that permits 30.
    test('the camera is asked for exactly what the rung permits', () {
      final capture = VideoLayers.captureFor(
        const VideoPublishIntent(height: 1080, framerate: 60),
      );

      expect((capture['height'] as Map)['ideal'], 1080);
      expect((capture['width'] as Map)['ideal'], 1920);
      expect((capture['frameRate'] as Map)['ideal'], 60);
      expect((capture['frameRate'] as Map)['max'], 60);
    });

    // `ideal` and not `exact` on purpose: a handset that cannot reach the rung
    // should give its best rather than fail capture outright, and what it gave
    // is read back off the track before anything is declared.
    test('the capture constraints stay ideal rather than exact', () {
      final capture = VideoLayers.captureFor(VideoPublishIntent.conservative);

      expect((capture['height'] as Map).containsKey('exact'), isFalse);
      expect((capture['width'] as Map).containsKey('exact'), isFalse);
    });

    // The cap is computed from the declaration, so one made at publish time
    // stops describing this client the moment the encoding changes.
    test('a renegotiation that changes the picture states it', () async {
      await api.renegotiate(
        guildId: 'g1',
        channelId: 'c1',
        mediaSessionId: 'media-1',
        sessionDescription: const {},
        video: VideoPublishIntent.conservative.toJson(),
      );

      expect(lastBody()['video'], {'height': 720, 'framerate': 30});
    });

    // Absent leaves the last declaration in force in both directions: an ICE
    // restart or a reconnect must not lift a cap, and must not apply one.
    test('a renegotiation that is not about video declares nothing', () async {
      await api.renegotiate(
        guildId: 'g1',
        channelId: 'c1',
        mediaSessionId: 'media-1',
        sessionDescription: const {},
      );

      expect(lastBody().containsKey('video'), isFalse);
    });
  });

  /// The rung is a name. What it permits is on the wire beside it, and the one
  /// thing this client must never do is decide locally what `1080p30` means -
  /// that is a pricing decision, and one compiled into a release is one nobody
  /// can change without another release.
  group('the rung decides what the camera captures', () {
    List<EntitlementLadderRungDto> ladder() => entitlementLaddersFromJson({
      'video_quality': [
        {'rung': 'none', 'rank': 0, 'maxHeight': 0, 'maxFramerate': 0},
        {'rung': '480p30', 'rank': 1, 'maxHeight': 480, 'maxFramerate': 30},
        {'rung': '720p30', 'rank': 2, 'maxHeight': 720, 'maxFramerate': 30},
        {'rung': '1080p30', 'rank': 3, 'maxHeight': 1080, 'maxFramerate': 30},
        {'rung': '1080p60', 'rank': 4, 'maxHeight': 1080, 'maxFramerate': 60},
      ],
    })['video_quality']!;

    test('the granted rung is captured at its own maximum', () {
      expect(
        cameraTargetFor(rung: '1080p60', ladder: ladder()),
        const VideoPublishIntent(height: 1080, framerate: 60),
      );
      expect(
        cameraTargetFor(rung: '480p30', ladder: ladder()),
        const VideoPublishIntent(height: 480, framerate: 30),
      );
    });

    // A rung added after this build shipped is one this build has no metrics
    // for. Guessing upward from the name would be the invented mapping again.
    test('a rung the ladder does not list falls back rather than guesses', () {
      expect(
        cameraTargetFor(rung: '2160p120', ladder: ladder()),
        VideoPublishIntent.conservative,
      );
    });

    test('no ladder at all is the same answer', () {
      expect(
        cameraTargetFor(rung: '1080p60'),
        VideoPublishIntent.conservative,
      );
      expect(cameraTargetFor(ladder: ladder()), VideoPublishIntent.conservative);
    });

    // `none` is a real rung and means audio-only. There is no picture to
    // capture, which is not the same as "capture the default".
    test('the bottom rung is nothing to capture', () {
      expect(cameraTargetFor(rung: 'none', ladder: ladder()), isNull);
    });

    test('a rung listed without metrics is not read as zero', () {
      final partial = entitlementLaddersFromJson({
        'video_quality': [
          {'rung': '720p30', 'rank': 2},
        ],
      })['video_quality'];

      // Zero would be indistinguishable from `none`, which would silently turn
      // a perfectly good rung into audio-only.
      expect(
        cameraTargetFor(rung: '720p30', ladder: partial),
        VideoPublishIntent.conservative,
      );
    });

    test('the ladder rides the snapshot and survives an unreadable rung', () {
      final snapshot = EntitlementSnapshotDto.fromJson({
        'subject': {'kind': 'user', 'id': 'user-1'},
        'entitlements': <String, dynamic>{},
        'ladders': {
          'video_quality': [
            {'rung': '720p30', 'rank': 2, 'maxHeight': 720, 'maxFramerate': 30},
            {'colour': 'blue'},
          ],
        },
      });

      final rungs = snapshot.ladders['video_quality']!;
      expect(rungs.first.maxHeight, 720);
      // One unreadable entry must not take the ladder - or the snapshot it
      // rides on, and every ceiling on that - offline.
      expect(rungs, hasLength(2));
      expect(rungs.last.maxHeight, isNull);
    });

    test('a snapshot with no ladders block reads as none rather than throwing', () {
      final snapshot = EntitlementSnapshotDto.fromJson({
        'subject': {'kind': 'user', 'id': 'user-1'},
        'entitlements': <String, dynamic>{},
      });

      expect(snapshot.ladders, isEmpty);
    });
  });

  group('a refused publish is a 403 with an explanation', () {
    test('the documented denial body parses into a sentence', () {
      final denial = entitlementDenialOf(_dioError(403, _denialJson()))!;

      expect(denial.key, 'storage.upload_max_bytes');
      expect(denial.reason, DegradationReason.guildPlanLimit);
      expect(denial.boundBy, DegradationBoundBy.guild);
      expect(denial.ceiling, '25 MB');
      expect(denial.sentence, "Limited by this server's plan.");
    });

    // Same rule as a degradation: generic sentence, never the raw code.
    test('a code added after this build shipped still gets a sentence', () {
      final denial = entitlementDenialOf(
        _dioError(403, _denialJson(code: 'sunspots', boundBy: null)),
      )!;

      expect(denial.reason, DegradationReason.unknown);
      expect(denial.sentence, 'A limit applied.');
      expect(denial.sentence, isNot(contains('sunspots')));
    });

    // Without `boundBy` a paired ceiling eventually tells a member paying for
    // their own plan that it limited them.
    test('a paired ceiling names the side that bound', () {
      final user = entitlementDenialOf(
        _dioError(
          403,
          _denialJson(code: 'paired_ceiling', boundBy: 'user'),
        ),
      )!;

      expect(user.sentence, 'Limited by your plan.');
    });

    test('an ordinary permission refusal is not an entitlement denial', () {
      expect(
        entitlementDenialOf(_dioError(403, {'code': 'forbidden'})),
        isNull,
      );
      expect(entitlementDenialOf(_dioError(403, 'nope')), isNull);
      expect(entitlementDenialOf(_dioError(404, _denialJson())), isNull);
      expect(entitlementDenialOf(_dioError(500, _denialJson())), isNull);
      expect(entitlementDenialOf(StateError('not a request')), isNull);
    });

    // The contract forbids both statuses precisely because the logout and
    // retry interceptors eat them, so neither may ever be read as a refusal.
    test('a 401 and a 429 are never read as refusals', () {
      expect(entitlementDenialOf(_dioError(401, _denialJson())), isNull);
      expect(entitlementDenialOf(_dioError(429, _denialJson())), isNull);
    });

    test('the media layer raises it instead of a generic fatal error',
        () async {
      await expectLater(
        mapMediaErrors<void>(
          'tracks',
          () async => throw _dioError(403, _denialJson()),
        ),
        throwsA(isA<EntitlementDenialException>()),
      );
    });

    test('and leaves an ordinary 403 alone', () async {
      await expectLater(
        mapMediaErrors<void>(
          'tracks',
          () async => throw _dioError(403, {'error': 'forbidden'}),
        ),
        throwsA(
          isA<VoiceMediaException>().having((e) => e.isFatal, 'isFatal', isTrue),
        ),
      );
    });
  });

  group('upload pre-flight', () {
    const ceiling = EntitlementValueDto.numeric(value: 26214400);

    test('an oversized file is named, with both numbers', () {
      final oversized = checkUploadSize(
        fileName: 'holiday.mov',
        sizeBytes: 94371840,
        ceiling: ceiling,
      )!;

      expect(oversized.sentence, contains('holiday.mov'));
      expect(oversized.sentence, contains('90 MB'));
      expect(oversized.sentence, contains('25 MB'));
    });

    // `>=` on a whole number of bytes server-side, so exactly at the ceiling
    // fits. Off by one here is a file the app refuses and the server accepts.
    test('a file exactly at the ceiling fits', () {
      expect(
        checkUploadSize(
          fileName: 'exact.bin',
          sizeBytes: 26214400,
          ceiling: ceiling,
        ),
        isNull,
      );
      expect(
        checkUploadSize(
          fileName: 'over.bin',
          sizeBytes: 26214401,
          ceiling: ceiling,
        ),
        isNotNull,
      );
    });

    // Every way of not knowing has to let the file through. The server is the
    // enforcement; this only avoids spending the transfer.
    test('nothing is refused on a ceiling this build cannot use', () {
      for (final unusable in <EntitlementValueDto?>[
        null,
        const EntitlementValueDto.numeric(unlimited: true),
        const EntitlementValueDto.numeric(value: 0),
        const EntitlementValueDto.flag(granted: false),
        const EntitlementValueDto(kind: EntitlementValueKind.unknown),
      ]) {
        expect(
          checkUploadSize(
            fileName: 'huge.bin',
            sizeBytes: 1 << 40,
            ceiling: unusable,
          ),
          isNull,
          reason: 'a ceiling of $unusable must never refuse an upload',
        );
      }
    });

    test('the up-front line states a number or says nothing', () {
      expect(uploadCeilingLine(ceiling), 'Files here are capped at 25 MB.');
      expect(uploadCeilingLine(null), isNull);
      expect(
        uploadCeilingLine(const EntitlementValueDto.numeric(unlimited: true)),
        isNull,
      );
    });
  });

  group('reading ceilings', () {
    EntitlementReader readerFor(_ScriptedAdapter adapter) =>
        EntitlementReader(api: EntitlementApi(client: _client(adapter)));

    test('outside a server it is the account key', () async {
      final adapter = _ScriptedAdapter((_) => _meJson());
      final ceiling = await readerFor(adapter).uploadCeiling();

      expect(ceiling?.value, 104857600);
      expect(adapter.requests.single.path, endsWith('/entitlements/me'));
    });

    // Paired: the effective ceiling is the lower of the two sides, and the
    // guild is the smaller one here.
    test('inside a server it is the lower of the paired pair', () async {
      final adapter = _ScriptedAdapter(
        (path) => path.contains('/guilds/') ? _guildJson() : _meJson(),
      );
      final ceiling = await readerFor(adapter).uploadCeiling(guildId: 'guild-1');

      expect(ceiling?.value, 26214400);
    });

    test('and the account side wins when it is the smaller one', () async {
      final adapter = _ScriptedAdapter(
        (path) => path.contains('/guilds/')
            ? _guildJson(uploadBytes: 5368709120)
            : _meJson(guildPairedBytes: 52428800),
      );
      final ceiling = await readerFor(adapter).uploadCeiling(guildId: 'guild-1');

      expect(ceiling?.value, 52428800);
    });

    test('a second read inside the TTL costs no request', () async {
      final adapter = _ScriptedAdapter((_) => _meJson());
      final reader = readerFor(adapter);

      await reader.uploadCeiling();
      await reader.uploadCeiling();

      expect(adapter.requests, hasLength(1));
    });

    test('a ttl of zero is honoured rather than rounded up', () async {
      final adapter = _ScriptedAdapter((_) => _meJson(ttlSeconds: 0));
      final reader = readerFor(adapter);

      await reader.uploadCeiling();
      await reader.uploadCeiling();

      expect(adapter.requests, hasLength(2));
    });

    // A failed lookup must not become a refused upload.
    test('a failed read answers null and never throws', () async {
      final adapter = _ScriptedAdapter((_) => null);

      await expectLater(readerFor(adapter).uploadCeiling(), completion(isNull));
    });

    // Without this a response that outlived the screen that asked for it gets
    // filed against whatever the app has since switched to.
    test('a response about the wrong subject is discarded', () async {
      final adapter = _ScriptedAdapter(
        (path) => path.contains('/guilds/')
            ? {..._guildJson(), 'subject': {'kind': 'guild', 'id': 'other'}}
            : _meJson(),
      );
      final reader = readerFor(adapter);

      expect(await reader.forGuild('guild-1'), isNull);
      // And the paired read falls back to the side that did answer rather than
      // to no ceiling at all.
      expect(
        (await reader.uploadCeiling(guildId: 'guild-1'))?.value,
        104857600,
      );
    });

    test('clearing empties it, for the next account to sign in', () async {
      final adapter = _ScriptedAdapter((_) => _meJson());
      final reader = readerFor(adapter);

      await reader.uploadCeiling();
      reader.clear();
      await reader.uploadCeiling();

      expect(adapter.requests, hasLength(2));
    });
  });

  group('what the surfaces draw', () {
    Widget wrap(Widget child) =>
        MaterialApp(theme: AppTheme.light, home: Scaffold(body: child));

    testWidgets('a notice is a sentence with nothing to press', (tester) async {
      await tester.pumpWidget(
        wrap(const EntitlementNotice(message: 'Limited by this plan.')),
      );

      expect(find.text('Limited by this plan.'), findsOneWidget);
      expect(find.byType(FilledButton), findsNothing);
      expect(find.byType(TextButton), findsNothing);
      expect(find.byType(ElevatedButton), findsNothing);
      expect(find.byType(OutlinedButton), findsNothing);
      expect(find.byType(InkWell), findsNothing);
      expect(find.byType(GestureDetector), findsNothing);
      expect(find.byIcon(Icons.chevron_right), findsNothing);
      expect(find.byIcon(Icons.open_in_new), findsNothing);
    });

    testWidgets('the limits bar draws the counts and the rung', (tester) async {
      await tester.pumpWidget(
        wrap(
          VoiceLimitsBar(
            limits: VoiceRoomLimitsDto.fromJson(
              _limitsJson(publisherCount: 1),
            ),
            participantCount: 6,
          ),
        ),
      );

      expect(find.text('6 of 10'), findsOneWidget);
      expect(find.text('1 of 2 sharing'), findsOneWidget);
      expect(find.text('720p30'), findsOneWidget);
    });

    // The literal "none" beside two counts reads as a missing value, which is
    // the opposite of what the bottom rung means.
    testWidgets('the bottom rung is named, not printed', (tester) async {
      await tester.pumpWidget(
        wrap(
          VoiceLimitsBar(
            limits: VoiceRoomLimitsDto.fromJson(
              _limitsJson(videoCeiling: _ladder('none', 0)),
            ),
            participantCount: 3,
          ),
        ),
      );

      expect(find.text('Audio only'), findsOneWidget);
      expect(find.text('none'), findsNothing);
    });

    // Drawing "- of -" would claim to know something this client does not.
    testWidgets('a room that reported no limits draws nothing', (tester) async {
      await tester.pumpWidget(
        wrap(const VoiceLimitsBar(limits: null, participantCount: 4)),
      );

      expect(find.byType(Text), findsNothing);
    });

    testWidgets('a disabled control stays visible and inert', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        wrap(
          CallActionButton(
            icon: Icons.videocam,
            label: 'Camera',
            background: Colors.white24,
            enabled: false,
            onTap: () => taps++,
          ),
        ),
      );

      // Visible, because a control that vanishes takes its explanation with it.
      expect(find.text('Camera'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.videocam));
      expect(taps, 0);
    });
  });

  /// Every sentence these surfaces can produce, checked against the vocabulary
  /// that would turn an explanation into an offer.
  ///
  /// The plan screen has its own version of this over the billing feature's
  /// sources. This one is over the copy that reaches a *voice room* and a
  /// *composer*, which that scan does not cover and which are now the two
  /// places most people will ever read one of these sentences.
  group('nothing here says how to lift a limit', () {
    const forbidden = <String>[
      'upgrade',
      'buy',
      'purchase',
      'subscribe',
      'price',
      'unlock',
      'available',
      'you could',
      'you can have',
      'get more',
      'more than',
      'better',
      'higher',
      'premium',
      'instead',
      'switch',
      'change plan',
      'ask an',
      'ask the',
      'ask your',
      'admin can',
      'owner can',
      'contact',
      'learn more',
      'http',
      'venta.gg',
    ];

    void check(String sentence, String where) {
      expect(sentence, isNotEmpty, reason: '$where produced nothing');
      for (final word in forbidden) {
        expect(
          sentence.toLowerCase().contains(word),
          isFalse,
          reason: '$where produced "$sentence", which contains "$word"',
        );
      }
    }

    test('every voice sentence explains and stops', () {
      final sentences = <String, String>{
        'audio-only': VoiceRoomLimitsDto.fromJson(
          _limitsJson(videoCeiling: _ladder('none', 0)),
        ).videoBlockedSentence!,
        'publishers full': VoiceRoomLimitsDto.fromJson(
          _limitsJson(),
        ).videoBlockedSentence!,
        'single publisher': VoiceRoomLimitsDto.fromJson(
          _limitsJson(maxPublishers: _numeric(1), publisherCount: 1),
        ).videoBlockedSentence!,
      };

      sentences.forEach((where, sentence) => check(sentence, where));
    });

    test('every reduction notice explains and stops', () {
      for (final reason in const [
        'guild_plan_limit',
        'user_plan_limit',
        'paired_ceiling',
        'operator_ceiling',
        'something_new',
      ]) {
        for (final side in const [null, 'guild', 'user', 'sideways']) {
          check(
            EntitlementDegradationDto.fromJson(
              _degradationJson(reason: reason, boundBy: side),
            ).notice,
            'notice for $reason/$side',
          );
        }
      }
    });

    test('every refusal sentence explains and stops', () {
      for (final code in const [
        'guild_plan_limit',
        'user_plan_limit',
        'paired_ceiling',
        'operator_ceiling',
        'something_new',
      ]) {
        check(
          entitlementDenialOf(_dioError(403, _denialJson(code: code)))!.sentence,
          'denial for $code',
        );
      }
    });

    test('the upload sentences explain and stop', () {
      check(
        checkUploadSize(
          fileName: 'holiday.mov',
          sizeBytes: 94371840,
          ceiling: const EntitlementValueDto.numeric(value: 26214400),
        )!.sentence,
        'oversized upload',
      );
      check(
        uploadCeilingLine(const EntitlementValueDto.numeric(value: 26214400))!,
        'upload ceiling line',
      );
    });

    // The two fields that answer "what would fix this, and can you do it". They
    // are on every payload above and neither is modelled anywhere - a field
    // read by nothing is how a control arrives later by accident.
    test('the remedy fields are never read off any of these payloads', () {
      final degradation = EntitlementDegradationDto.fromJson(
        _degradationJson(),
      );
      final denial = entitlementDenialOf(_dioError(403, _denialJson()))!;

      expect(() => (degradation as dynamic).remedy, throwsNoSuchMethodError);
      expect(
        () => (degradation as dynamic).actorCanRemedy,
        throwsNoSuchMethodError,
      );
      expect(() => (denial as dynamic).remedy, throwsNoSuchMethodError);
      expect(() => (denial as dynamic).actorCanRemedy, throwsNoSuchMethodError);
      expect(degradation.toJson().containsKey('remedy'), isFalse);
    });
  });
}
