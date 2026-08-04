import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:venta_mobile/core/diagnostics/telemetry_consent.dart';
import 'package:venta_mobile/core/network/privacy_refusal.dart';
import 'package:venta_mobile/core/realtime/realtime_event.dart';
import 'package:venta_mobile/core/realtime/realtime_service.dart';
import 'package:venta_mobile/core/storage/secure_storage_service.dart';
import 'package:venta_mobile/features/auth/data/models/user_dto.dart';
import 'package:venta_mobile/features/friends/data/relationship_api.dart';
import 'package:venta_mobile/features/friends/data/relationship_repository.dart';
import 'package:venta_mobile/features/privacy/data/models/blocked_user_dto.dart';
import 'package:venta_mobile/features/privacy/data/models/data_export_dto.dart';
import 'package:venta_mobile/features/privacy/data/models/legal_document_dto.dart';
import 'package:venta_mobile/features/privacy/data/models/privacy_settings_dto.dart';
import 'package:venta_mobile/features/privacy/data/privacy_api.dart';
import 'package:venta_mobile/features/privacy/data/privacy_repository.dart';
import 'package:venta_mobile/features/profile/data/models/profile_dto.dart';

/// The negative cases are the point here. Every test below that matters is one
/// asserting a refusal is recognised, a default is restrictive, or an
/// identifier does not leave the device - the happy paths are the cheap half.
class _MockPrivacyApi extends Mock implements PrivacyApi {}

class _MockSecureStorage extends Mock implements SecureStorageService {}

class _MockRelationshipApi extends Mock implements RelationshipApi {}

class _MockRealtimeService extends Mock implements RealtimeService {}

DioException _refusal(int status, Object? body) => DioException(
  requestOptions: RequestOptions(path: '/api/v1/messaging/conversations'),
  response: Response<dynamic>(
    requestOptions: RequestOptions(path: '/api/v1/messaging/conversations'),
    statusCode: status,
    data: body,
  ),
);

const _settings = PrivacySettingsDto(
  directMessagePolicy: DirectMessagePolicy.everyone,
  sendTypingIndicators: true,
  version: 2,
);

void main() {
  group('privacyRefusalOf', () {
    test('reads a code out of each shape the services answer with', () {
      expect(
        privacyRefusalOf(
          _refusal(403, {'code': 'recipient_dm_policy'}),
        )?.refusal,
        PrivacyRefusal.recipientDmPolicy,
      );
      expect(
        privacyRefusalOf(_refusal(403, {'error': 'blocked'}))?.refusal,
        PrivacyRefusal.blocked,
      );
      expect(
        privacyRefusalOf(_refusal(403, 'friend_request_policy'))?.refusal,
        PrivacyRefusal.friendRequestPolicy,
      );
    });

    test('carries the field a minor restriction names', () {
      final refusal = privacyRefusalOf(
        _refusal(403, {
          'code': 'minor_restriction',
          'field': 'allowPersonalization',
        }),
      );
      expect(refusal?.refusal, PrivacyRefusal.minorRestriction);
      expect(refusal?.field, 'allowPersonalization');
    });

    test('a blocked refusal is worded exactly like a policy refusal', () {
      // Cross-cutting rule 5. If these two ever diverge, the client has become
      // the enumeration oracle the server refuses to be.
      expect(
        const PrivacyRefusalException(PrivacyRefusal.blocked).message,
        const PrivacyRefusalException(PrivacyRefusal.recipientDmPolicy).message,
      );
    });

    test('is null for anything that is not a recognised 403', () {
      expect(privacyRefusalOf(_refusal(400, {'code': 'blocked'})), isNull);
      expect(privacyRefusalOf(_refusal(403, {'code': 'teapot'})), isNull);
      expect(privacyRefusalOf(_refusal(403, null)), isNull);
      expect(privacyRefusalOf(Exception('not a dio error')), isNull);
    });

    test('an attachment refused by a content filter is its own code', () {
      expect(
        privacyRefusalOf(
          _refusal(403, {'error': 'explicit_content_filtered'}),
        )?.refusal,
        PrivacyRefusal.explicitContentFiltered,
      );
    });

    test('a 503 lookup failure is not a refusal and says to try again', () {
      final refusal = privacyRefusalOf(
        _refusal(503, {'error': 'privacy_lookup_unavailable'}),
      );
      expect(refusal?.refusal, PrivacyRefusal.lookupUnavailable);
      // The whole reason it has its own status code. Rendering it as "you
      // can't message this person" tells the user a decision was made about
      // them when the server never reached one.
      expect(refusal?.isRetryable, isTrue);
      expect(
        const PrivacyRefusalException(PrivacyRefusal.blocked).isRetryable,
        isFalse,
      );
    });

    test('a code on the wrong status is ignored', () {
      // Guards both directions: a decision must not be read out of a 503, and
      // a 403 must not be turned into "try again".
      expect(privacyRefusalOf(_refusal(503, {'error': 'blocked'})), isNull);
      expect(
        privacyRefusalOf(
          _refusal(403, {'error': 'privacy_lookup_unavailable'}),
        ),
        isNull,
      );
    });
  });

  group('PrivacySettingsDto', () {
    test('every default is the restrictive one', () {
      const defaults = PrivacySettingsDto();
      expect(defaults.allowDataCollection, isFalse);
      expect(defaults.allowPersonalization, isFalse);
      expect(defaults.allowVoiceRecordingInClips, isFalse);
      expect(defaults.directMessagePolicy, DirectMessagePolicy.friends);
      expect(defaults.friendRequestPolicy, FriendRequestPolicy.nobody);
      expect(defaults.discoverableByEmail, isFalse);
      expect(defaults.discoverableByPhone, isFalse);
      expect(defaults.mutualServersVisibility, ProfileVisibility.nobody);
      expect(defaults.birthdayVisibility, ProfileVisibility.nobody);
      expect(defaults.shareActivity, isFalse);
    });

    test(
      'an unrecognised policy falls back restrictively, not permissively',
      () {
        // A newer server adding a wider policy this build has never heard of
        // must not be read as "no policy" and therefore "everyone".
        final parsed = PrivacySettingsDto.fromJson(const {
          'directMessagePolicy': 'SomethingNewAndWide',
          'friendRequestPolicy': 'AlsoNew',
          'birthdayVisibility': 'Whoever',
        });
        expect(parsed.directMessagePolicy, DirectMessagePolicy.friends);
        expect(parsed.friendRequestPolicy, FriendRequestPolicy.nobody);
        expect(parsed.birthdayVisibility, ProfileVisibility.nobody);
      },
    );

    test('minor floors are reported per field, and only for a minor', () {
      const adult = PrivacySettingsDto();
      const minor = PrivacySettingsDto(isMinor: true);
      expect(adult.lockedForMinor('allowPersonalization'), isFalse);
      expect(minor.lockedForMinor('allowPersonalization'), isTrue);
      expect(minor.lockedForMinor('discoverableByEmail'), isTrue);
      expect(minor.lockedForMinor('shareActivity'), isFalse);
    });
  });

  group('PrivacyRepository', () {
    late _MockPrivacyApi api;
    late PrivacyRepository repository;

    setUp(() {
      api = _MockPrivacyApi();
      repository = PrivacyRepository(api: api);
    });

    test('the typing gate is permissive until the record is known', () {
      // The server is the enforcement point for this one, so an unknown answer
      // costs nothing and failing closed would disable the indicator for every
      // user during any Identity blip. See the class comment.
      expect(repository.cached, isNull);
      expect(repository.shouldSendTypingIndicators, isTrue);
    });

    test('render and send stay reciprocal', () async {
      when(() => api.getSettings()).thenAnswer(
        (_) async => const PrivacySettingsDto(sendTypingIndicators: false),
      );
      await repository.fetch();
      expect(repository.shouldSendTypingIndicators, isFalse);
      expect(repository.shouldRenderTypingIndicators, isFalse);
    });

    test('two callers racing a cold read share one request', () async {
      var calls = 0;
      when(() => api.getSettings()).thenAnswer((_) async {
        calls++;
        return _settings;
      });
      await Future.wait([repository.fetch(), repository.ensureLoaded()]);
      expect(calls, 1);
    });

    test(
      'a response that lost the race does not roll the cache back',
      () async {
        when(() => api.getSettings()).thenAnswer((_) async => _settings);
        await repository.fetch();

        // Version 1 is older than the version 2 already held - a write that
        // landed later returning first would otherwise undo it on screen.
        when(() => api.updateSettings(any())).thenAnswer(
          (_) async => const PrivacySettingsDto(
            directMessagePolicy: DirectMessagePolicy.nobody,
            version: 1,
          ),
        );
        final result = await repository.update({
          'directMessagePolicy': 'Nobody',
        });
        expect(result.directMessagePolicy, DirectMessagePolicy.everyone);
        expect(repository.cached?.version, 2);
      },
    );

    test('clear drops the record without publishing a synthetic one', () async {
      when(() => api.getSettings()).thenAnswer((_) async => _settings);
      await repository.fetch();
      expect(repository.cached, isNotNull);

      repository.clear();
      expect(repository.cached, isNull);
      // Not "the restrictive defaults" - the next account's settings are
      // unknown, and every gate must treat them as unknown.
      expect(repository.shouldSendTypingIndicators, isTrue);
    });
  });

  group('data exports', () {
    test('a partial export is downloadable', () {
      // A client gating the button on `Ready` hides a download the server will
      // serve. The archive exists; what is missing is named on the row.
      expect(DataExportStatus.partial.isDownloadable, isTrue);
      expect(DataExportStatus.ready.isDownloadable, isTrue);
      expect(DataExportStatus.failed.isDownloadable, isFalse);
      expect(DataExportStatus.expired.isDownloadable, isFalse);
      expect(DataExportStatus.pending.isDownloadable, isFalse);
    });

    test('partial carries what was left out', () {
      final export = DataExportDto.fromJson(const {
        'exportId': 'exp_1',
        'status': 'Partial',
        'missingServices': ['Guild', 'Isle'],
        'failureReason': 'Two services did not respond.',
      });
      expect(export.status, DataExportStatus.partial);
      expect(export.missingServices, ['Guild', 'Isle']);
      expect(export.failureReason, isNotNull);
    });

    test('a status this build has never heard of does not look ready', () {
      final export = DataExportDto.fromJson(const {
        'exportId': 'exp_1',
        'status': 'SomethingNew',
      });
      expect(export.status, DataExportStatus.pending);
      expect(export.status.isDownloadable, isFalse);
    });

    test('missingServices is empty, never null', () {
      final export = DataExportDto.fromJson(const {
        'exportId': 'exp_1',
        'status': 'Ready',
      });
      expect(export.missingServices, isEmpty);
    });
  });

  group('blocking', () {
    late _MockRelationshipApi api;
    late RelationshipRepository repository;
    late StreamController<RealtimeEvent> events;

    setUp(() {
      api = _MockRelationshipApi();
      events = StreamController<RealtimeEvent>.broadcast();
      final realtime = _MockRealtimeService();
      when(() => realtime.events).thenAnswer((_) => events.stream);
      when(() => api.getRelationships()).thenAnswer((_) async => const []);
      repository = RelationshipRepository(api: api, realtimeService: realtime);
    });

    tearDown(() async {
      repository.dispose();
      await events.close();
    });

    BlockedUsersPage page(List<String> ids, {String? next}) => BlockedUsersPage(
      blocked: [for (final id in ids) BlockedUserDto(userId: id, userName: id)],
      nextCursor: next,
    );

    test('isBlocked walks every page, not just the first', () async {
      when(
        () => api.getBlocked(limit: any(named: 'limit'), cursor: null),
      ).thenAnswer((_) async => page(['u1'], next: 'c2'));
      when(
        () => api.getBlocked(
          limit: any(named: 'limit'),
          cursor: 'c2',
        ),
      ).thenAnswer((_) async => page(['u2']));

      // The negative case is the one that matters: a first-page-only scan
      // answers "not blocked" for u2 and puts an Add Friend button in front of
      // someone the user deliberately blocked.
      expect(await repository.isBlocked('u2'), isTrue);
      expect(await repository.isBlocked('u3'), isFalse);
    });

    test('the walk happens once and block/unblock keep it current', () async {
      when(
        () => api.getBlocked(limit: any(named: 'limit'), cursor: null),
      ).thenAnswer((_) async => page(['u1']));
      when(() => api.block(any())).thenAnswer((_) async {});
      when(() => api.unblock(any())).thenAnswer((_) async {});

      expect(await repository.isBlocked('u1'), isTrue);
      await repository.block('u9');
      expect(await repository.isBlocked('u9'), isTrue);
      await repository.unblock('u1');
      expect(await repository.isBlocked('u1'), isFalse);

      verify(
        () => api.getBlocked(limit: any(named: 'limit'), cursor: null),
      ).called(1);
    });

    test(
      'a session change drops the block list with everything else',
      () async {
        when(
          () => api.getBlocked(limit: any(named: 'limit'), cursor: null),
        ).thenAnswer((_) async => page(['u1']));
        expect(await repository.isBlocked('u1'), isTrue);

        repository.clear();
        when(
          () => api.getBlocked(limit: any(named: 'limit'), cursor: null),
        ).thenAnswer((_) async => page(const []));
        // The next account's blocks are not this one's.
        expect(await repository.isBlocked('u1'), isFalse);
      },
    );
  });

  group('consent requirements', () {
    test('a document type this build does not know is still named', () {
      final unknown = ConsentRequirementDto.fromJson(const {
        'documentType': 'DataProcessingAddendum',
        'version': '1.0.0',
      });
      expect(unknown.knownType, isNull);
      // Dropping it would hide something the user is being asked to accept.
      expect(unknown.label, 'DataProcessingAddendum');

      final known = ConsentRequirementDto.fromJson(const {
        'documentType': 'Privacy',
        'version': '0.2.0',
      });
      expect(known.knownType, LegalDocumentType.privacy);
      expect(known.label, 'Privacy Policy');
    });

    test('an account with nothing outstanding parses to an empty list', () {
      final absent = UserDto.fromJson(const {'id': 'u1', 'status': 'Active'});
      expect(absent.consentRequired, isEmpty);

      final present = UserDto.fromJson(const {
        'id': 'u1',
        'status': 'Active',
        'consentRequired': [
          {'documentType': 'Terms', 'version': '0.2.0', 'url': 'https://x/t'},
        ],
      });
      expect(present.consentRequired.single.version, '0.2.0');
    });
  });

  group('gated profile fields', () {
    test('a field the viewer may not see is absent, not empty', () {
      final hidden = ProfileDto.fromJson(const {
        'id': 'p1',
        'userId': 'u1',
        'userName': 'someone',
      });
      // Null and empty mean different things here: empty is "no servers in
      // common", null is "that isn't yours to know". Rendering the second as
      // the first states something the server refused to state.
      expect(hidden.mutualServers, isNull);
      expect(hidden.mutualFriends, isNull);
      expect(hidden.connections, isNull);
      expect(hidden.birthday, isNull);
      expect(hidden.activity, isNull);

      final visible = ProfileDto.fromJson(const {
        'id': 'p1',
        'userId': 'u1',
        'userName': 'someone',
        'mutualServers': <Map<String, dynamic>>[],
      });
      expect(visible.mutualServers, isEmpty);
    });

    test('connections keep the server\'s own verified flag', () {
      final profile = ProfileDto.fromJson(const {
        'id': 'p1',
        'userId': 'u1',
        'userName': 'someone',
        'connections': [
          {'type': 'Steam', 'externalId': '76561', 'verified': true},
          {'type': 'Steam', 'externalId': '76562', 'displayName': 'claimed'},
        ],
      });
      expect(profile.connections, hasLength(2));
      expect(profile.connections!.first.verified, isTrue);
      expect(profile.connections!.first.label, '76561');
      // Unverified is a name the account typed, and must not read as confirmed.
      expect(profile.connections!.last.verified, isFalse);
      expect(profile.connections!.last.label, 'claimed');
    });
  });

  group('TelemetryConsent', () {
    late _MockSecureStorage storage;

    setUp(() {
      storage = _MockSecureStorage();
      registerFallbackValue('');
    });

    test('mints an install id once and reuses the stored one', () async {
      when(
        () => storage.readTelemetryInstallId(),
      ).thenAnswer((_) async => null);
      when(
        () => storage.writeTelemetryInstallId(any()),
      ).thenAnswer((_) async {});

      final consent = TelemetryConsent(secureStorage: storage);
      await consent.init();
      final minted = consent.installId;
      expect(minted, isNotNull);
      expect(minted, hasLength(32));

      when(
        () => storage.readTelemetryInstallId(),
      ).thenAnswer((_) async => minted);
      final second = TelemetryConsent(secureStorage: storage);
      await second.init();
      expect(second.installId, minted);
      verify(() => storage.writeTelemetryInstallId(any())).called(1);
    });

    test(
      'a keychain failure leaves reports unattributed, not unsent',
      () async {
        when(
          () => storage.readTelemetryInstallId(),
        ).thenThrow(Exception('errSecMissingEntitlement'));

        final consent = TelemetryConsent(secureStorage: storage);
        await consent.init();
        expect(consent.installId, isNull);
      },
    );

    test('scrubEvent strips the identifiers Sentry collects by default', () {
      final event = SentryEvent(
        user: SentryUser(
          id: 'user_1',
          email: 'someone@example.com',
          username: 'someone',
          ipAddress: '203.0.113.4',
        ),
        request: SentryRequest(
          url: 'https://venta.example/api/v1/social/relationships',
          method: 'POST',
          queryString: 'token=secret',
          cookies: 'session=abc',
          data: '{"username":"someone"}',
          headers: const {'Authorization': 'Bearer abc'},
        ),
      );

      final scrubbed = TelemetryConsent.scrubEvent(event, Hint())!;
      expect(scrubbed.user?.id, 'user_1');
      expect(scrubbed.user?.email, isNull);
      expect(scrubbed.user?.username, isNull);
      expect(scrubbed.user?.ipAddress, isNull);
      expect(scrubbed.request?.url, contains('/relationships'));
      expect(scrubbed.request?.method, 'POST');
      expect(scrubbed.request?.data, isNull);
      expect(scrubbed.request?.headers, isEmpty);
      expect(scrubbed.request?.cookies, isNull);
      expect(scrubbed.request?.queryString, isNull);
    });

    test('an event whose user carries no id loses the user entirely', () {
      // Otherwise it would go out as a bag of exactly the attributes just
      // stripped, which is a user object that only ever held PII.
      final event = SentryEvent(user: SentryUser(email: 'someone@example.com'));
      expect(TelemetryConsent.scrubEvent(event, Hint())!.user, isNull);
    });

    test('breadcrumbs keep the path and lose the query and the body', () {
      final event = SentryEvent(
        breadcrumbs: [
          Breadcrumb(
            type: 'http',
            data: {
              'url': 'https://venta.example/api/v1/social/lookup?email=a@b.c',
              'method': 'GET',
              'status_code': 403,
              'body': '{"email":"a@b.c"}',
              'headers': {'Authorization': 'Bearer abc'},
            },
          ),
        ],
      );

      final data = TelemetryConsent.scrubEvent(
        event,
        Hint(),
      )!.breadcrumbs!.single.data!;
      expect(data['url'], 'https://venta.example/api/v1/social/lookup');
      expect(data['method'], 'GET');
      expect(data['status_code'], 403);
      expect(data.containsKey('body'), isFalse);
      expect(data.containsKey('headers'), isFalse);
    });
  });
}
