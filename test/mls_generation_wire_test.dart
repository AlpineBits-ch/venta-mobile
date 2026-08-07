import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mobile/core/crypto/account_encryption_service.dart';
import 'package:venta_mobile/core/crypto/account_identity_service.dart';
import 'package:venta_mobile/core/crypto/master_key_api.dart';
import 'package:venta_mobile/core/device/device_api.dart';
import 'package:venta_mobile/core/network/api_client.dart';
import 'package:venta_mobile/features/auth/data/auth_repository.dart';

/// What these cover: the request and response shapes of the §C.1.1/§H.2
/// generation routes, against the contracts in `Identity.Application`.
///
/// These exist because every other test in this repo mocks the API layer, and
/// that is exactly the seam the bugs were hiding in. Four of them, all invisible
/// to a mocked test and all fatal in production:
///
/// * the three recovery-key routes were spelled `/api/v1/backup/...`, which
///   matches no gateway route - YARP only forwards `/api/v1/identity/**` to the
///   identity service, so the whole of §C.1.1 answered 404;
/// * `fetchIdentityKey` read `identityPublicKey`, a field the server has never
///   sent, so an account that *had* an identity key looked like one that did
///   not - and "no key published" is the one answer that licenses minting a
///   second one;
/// * `uploadIdentityKey` sent `identityPublicKey`/`wrappedPrivateKey` against a
///   DTO whose fields are `publicKey`/`version`/`password`, so publication was a
///   400 even when it was reached;
/// * `uploadDeviceCertificate` posted the client's own certificate object -
///   epoch-seconds timestamps and all - against a DTO wanting
///   `certificate`/`issuedAt`/`expiresAt`/`identityKeyVersion` with
///   `DateTimeOffset` times, which does not deserialise from a number.
///
/// A shape test is cheap and this class of bug is not.

class _MockAuthRepository extends Mock implements AuthRepository {}

/// Records every request and answers from a per-path table.
class _RecordingAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];

  /// Path fragment -> (status, body). First match wins.
  final List<(String, int, Object?)> responses = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    for (final (fragment, status, body) in responses) {
      if (options.path.contains(fragment)) {
        return ResponseBody.fromString(
          body == null ? '' : jsonEncode(body),
          status,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      }
    }
    return ResponseBody.fromString(
      '{}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

const _base = 'https://example.test';

EncryptedMasterKeyDto _wrapping(String label, {String? verifier}) =>
    EncryptedMasterKeyDto(
      cipherText: 'ct-$label',
      salt: 'salt-$label',
      iv: 'iv-$label',
      argon2Iterations: 3,
      argon2Memory: 65536,
      argon2Parallelism: 1,
      version: 4,
      publicVerifier: verifier,
    );

void main() {
  late _RecordingAdapter adapter;
  late ApiClient client;
  late MasterKeyApi masterKeys;
  late DeviceApi devices;

  RequestOptions requestFor(String fragment) => adapter.requests.firstWhere(
    (r) => r.path.contains(fragment),
    orElse: () => throw StateError(
      'no request matching "$fragment"; saw '
      '${adapter.requests.map((r) => r.path).toList()}',
    ),
  );

  Map<String, dynamic> bodyFor(String fragment) =>
      Map<String, dynamic>.from(requestFor(fragment).data as Map);

  setUp(() {
    final auth = _MockAuthRepository();
    when(() => auth.baseUrl).thenReturn(_base);
    when(() => auth.ensureValidToken()).thenAnswer((_) async => 'token');

    client = ApiClient(authRepository: auth);
    adapter = _RecordingAdapter();
    client.dio.httpClientAdapter = adapter;

    masterKeys = MasterKeyApi(client: client);
    devices = DeviceApi(client: client);
  });

  group('gateway routing', () {
    // The gateway forwards `/api/v1/identity/{**}` to the identity service and
    // rewrites it to `/api/v1/{**}`. Nothing forwards a bare `/api/v1/backup`.
    test('every recovery-key route goes through the identity prefix', () async {
      adapter.responses.add((
        'recovery-key',
        200,
        {
          'version': 4,
          'kdf': 'argon2id',
          'iterations': 3,
          'memoryKiB': 65536,
          'parallelism': 1,
          'salt': 'salt-p',
          'iv': 'iv-p',
          'cipherText': 'ct-p',
          'encryptedHistoryRecoverable': true,
        },
      ));

      await masterKeys.fetchRecoveryKey();
      await masterKeys.putRecoveryKey(
        version: 4,
        passwordWrapping: _wrapping('p'),
        recoveryCodeWrapping: _wrapping('r'),
        password: 'hunter2',
      );
      await masterKeys.rewrapPassword(
        version: 4,
        passwordWrapping: _wrapping('p2'),
        password: 'hunter2',
      );

      for (final request in adapter.requests) {
        expect(
          request.path,
          startsWith('$_base/api/v1/identity/backup/recovery-key'),
          reason: '/api/v1/backup/** is not a route the gateway knows',
        );
      }
    });
  });

  group('PUT backup/recovery-key', () {
    setUp(() {
      adapter.responses.add(('recovery-key', 200, {'version': 4}));
    });

    test('uses the server\'s KDF field names, not the engine\'s', () async {
      // `PutRecoveryKeyDto` is `iterations`/`memoryKiB`/`parallelism`. The engine
      // struct is `argon2Iterations`/`argon2Memory`/`argon2Parallelism`. Sending
      // the second set leaves all three at the server's defaults, which the
      // reader then derives a different wrap key from - and the failure looks
      // exactly like a wrong password.
      await masterKeys.putRecoveryKey(
        version: 4,
        passwordWrapping: _wrapping('p'),
        recoveryCodeWrapping: _wrapping('r'),
        password: 'hunter2',
      );

      final body = bodyFor('recovery-key');
      expect(body['iterations'], 3);
      expect(body['memoryKiB'], 65536);
      expect(body['parallelism'], 1);
      expect(body['kdf'], 'argon2id');
      expect(body['cipherText'], 'ct-p');
      expect(body.containsKey('argon2Iterations'), isFalse);
    });

    test('carries the account password (§C.1 re-authentication)', () async {
      await masterKeys.putRecoveryKey(
        version: 4,
        passwordWrapping: _wrapping('p'),
        recoveryCodeWrapping: _wrapping('r'),
        password: 'hunter2',
      );

      expect(bodyFor('recovery-key')['password'], 'hunter2');
    });

    test('nests the recovery-code wrapping and shares one version', () async {
      await masterKeys.putRecoveryKey(
        version: 4,
        passwordWrapping: _wrapping('p'),
        recoveryCodeWrapping: _wrapping('r'),
        password: 'hunter2',
      );

      final body = bodyFor('recovery-key');
      expect(body['version'], 4);
      final nested = Map<String, dynamic>.from(
        body['recoveryCodeWrapping'] as Map,
      );
      expect(nested['cipherText'], 'ct-r');
      expect(
        nested.containsKey('version'),
        isFalse,
        reason:
            'MasterKeyWrappingDto has no version - both wrappings share the '
            'envelope\'s, because they seal the same bytes',
      );
    });

    test(
      'rewrap-password nests the wrapping and carries a credential',
      () async {
        // §J.2 says this route deliberately takes no credential. It does now -
        // §L.8 found that nothing verified the wrapping, so the route was an
        // unauthenticated write that destroys the account's encrypted history.
        await masterKeys.rewrapPassword(
          version: 4,
          passwordWrapping: _wrapping('p2'),
          password: 'hunter2',
        );

        final body = bodyFor('rewrap-password');
        expect(body['version'], 4);
        expect(body['password'], 'hunter2');
        expect(
          Map<String, dynamic>.from(
            body['passwordWrapping'] as Map,
          )['cipherText'],
          'ct-p2',
        );
      },
    );

    test('a reset ticket is an accepted alternative to the password', () async {
      await masterKeys.rewrapPassword(
        version: 4,
        passwordWrapping: _wrapping('p2'),
        rewrapTicket: 'ticket-abc',
      );

      final body = bodyFor('rewrap-password');
      expect(body['rewrapTicket'], 'ticket-abc');
      expect(body.containsKey('password'), isFalse);
    });
  });

  group('the publicVerifier (§L.11)', () {
    setUp(() {
      adapter.responses.add(('recovery-key', 200, {'version': 4}));
      adapter.responses.add(('users/master', 200, {'version': 1}));
    });

    // Echo hard-refuses a key-establishing write without one
    // (`BackupController.cs:344`), and until §L.11 no client derived one at all
    // - Alpine left the field null and mobile routed around the requirement.
    // The value now comes from the engine, so both clients produce identical
    // bytes for the same master key; deriving it in Dart would both put the
    // master key in the host language and re-open the §C.1.2 divergence.
    test('travels on both wrappings of a recovery-key write', () async {
      await masterKeys.putRecoveryKey(
        version: 4,
        passwordWrapping: _wrapping('p', verifier: 'dmVyaWZpZXI='),
        recoveryCodeWrapping: _wrapping('r', verifier: 'dmVyaWZpZXI='),
        password: 'hunter2',
      );

      final body = bodyFor('recovery-key');
      expect(body['publicVerifier'], 'dmVyaWZpZXI=');
      expect(
        Map<String, dynamic>.from(
          body['recoveryCodeWrapping'] as Map,
        )['publicVerifier'],
        'dmVyaWZpZXI=',
        reason:
            'both wrappings seal one key, so both carry one verifier - Echo '
            'refuses a mismatch because it means two keys were called one',
      );
    });

    test(
      'travels on the legacy first write, which is where key material starts',
      () async {
        // `establish` goes through `POST users/master` precisely because
        // `PUT recovery-key` 400s on an establishing write. That route accepts a
        // verifier too, so the account acquires one at creation rather than
        // waiting for a later same-version backfill.
        await masterKeys.upload(_wrapping('p', verifier: 'dmVyaWZpZXI='));

        expect(bodyFor('users/master')['publicVerifier'], 'dmVyaWZpZXI=');
      },
    );

    test('travels on rewrap-password, which is what it gates', () async {
      await masterKeys.rewrapPassword(
        version: 4,
        passwordWrapping: _wrapping('p2', verifier: 'dmVyaWZpZXI='),
        password: 'hunter2',
      );

      expect(
        Map<String, dynamic>.from(
          bodyFor('rewrap-password')['passwordWrapping'] as Map,
        )['publicVerifier'],
        'dmVyaWZpZXI=',
      );
    });

    test('is omitted, not nulled, when the account has none', () async {
      // Every account in the field. A literal null would be a value the server
      // could store; omitting leaves the backfill path free to fill it in.
      await masterKeys.putRecoveryKey(
        version: 4,
        passwordWrapping: _wrapping('p'),
        recoveryCodeWrapping: _wrapping('r'),
        password: 'hunter2',
      );

      expect(bodyFor('recovery-key').containsKey('publicVerifier'), isFalse);
    });

    test('a stored verifier round-trips back out unchanged', () async {
      adapter.responses.insert(0, (
        'backup/recovery-key',
        200,
        {
          'version': 4,
          'salt': 'salt-p',
          'iv': 'iv-p',
          'cipherText': 'ct-p',
          'publicVerifier': 'c3RvcmVk',
          'encryptedHistoryRecoverable': true,
        },
      ));

      final state = await masterKeys.fetchRecoveryKey();

      expect(
        state!.passwordWrapping!.publicVerifier,
        'c3RvcmVk',
        reason:
            'the value is immutable at a version - echoing back what the '
            'server holds is the only correct thing to send',
      );
    });
  });

  group('GET backup/recovery-key', () {
    test(
      'reads the declared KDF parameters rather than compiled-in defaults',
      () async {
        // Contract §D: the reader must derive from the declared header. A wrapping
        // written at m=131072 that is read back as m=65536 does not open, and the
        // only symptom is "wrong password" on the recovery journey.
        adapter.responses.add((
          'recovery-key',
          200,
          {
            'version': 7,
            'kdf': 'argon2id',
            'iterations': 5,
            'memoryKiB': 131072,
            'parallelism': 2,
            'salt': 'salt-p',
            'iv': 'iv-p',
            'cipherText': 'ct-p',
            'recoveryCodeWrapping': {
              'kdf': 'argon2id',
              'iterations': 5,
              'memoryKiB': 131072,
              'parallelism': 2,
              'salt': 'salt-r',
              'iv': 'iv-r',
              'cipherText': 'ct-r',
            },
            'encryptedHistoryRecoverable': true,
          },
        ));

        final state = await masterKeys.fetchRecoveryKey();

        expect(state!.version, 7);
        expect(state.passwordWrapping!.argon2Iterations, 5);
        expect(state.passwordWrapping!.argon2Memory, 131072);
        expect(state.passwordWrapping!.argon2Parallelism, 2);
        expect(state.recoveryCodeWrapping!.argon2Memory, 131072);
        expect(
          state.recoveryCodeWrapping!.version,
          7,
          reason: 'the nested wrapping carries no version of its own',
        );
      },
    );

    test(
      'a 404 falls back to the legacy route and reports no envelope',
      () async {
        adapter.responses.add(('backup/recovery-key', 404, null));
        adapter.responses.add(('users/master', 404, null));

        expect(await masterKeys.fetchRecoveryKey(), isNull);
      },
    );

    test('a completed loss survives the round trip', () async {
      adapter.responses.add((
        'recovery-key',
        200,
        {
          'version': 1,
          'salt': 'salt-p',
          'iv': 'iv-p',
          'cipherText': 'ct-p',
          'passwordWrappingInvalidatedAt': '2026-08-01T10:00:00Z',
          'encryptedHistoryRecoverable': false,
        },
      ));

      final state = await masterKeys.fetchRecoveryKey();

      expect(state!.encryptedHistoryRecoverable, isFalse);
      expect(state.needsPasswordRewrap, isTrue);
      expect(state.hasRecoveryCodeWrapping, isFalse);
    });
  });

  group('the account identity key (§H.2)', () {
    test(
      'reads publicKey, which is the field the server actually sends',
      () async {
        adapter.responses.add((
          'identity-key',
          200,
          {
            'userId': 'user_1',
            'publicKey': 'aWRlbnRpdHktcHVibGlj',
            'version': 3,
            'rotationSignature': null,
          },
        ));

        final key = await masterKeys.fetchIdentityKey('user_1');

        expect(key, isNotNull);
        expect(key!.publicKey, 'aWRlbnRpdHktcHVibGlj');
        expect(key.version, 3);
      },
    );

    test('a 404 is "none published", not an error', () async {
      adapter.responses.add(('identity-key', 404, null));

      expect(await masterKeys.fetchIdentityKey('user_1'), isNull);
    });

    test('publishing sends publicKey, a version and the password', () async {
      await masterKeys.uploadIdentityKey(
        identityPublicKey: 'aWRlbnRpdHktcHVibGlj',
        password: 'hunter2',
        version: 1,
        deviceId: 'device_1',
      );

      final body = bodyFor('users/identity-key');
      expect(body['publicKey'], 'aWRlbnRpdHktcHVibGlj');
      expect(
        body['version'],
        1,
        reason:
            'the server requires version > the stored one, which starts at 0',
      );
      expect(
        body['password'],
        'hunter2',
        reason:
            'a first publication costs the password too - whoever publishes '
            'first is who every peer TOFU-pins',
      );
      expect(body.containsKey('identityPublicKey'), isFalse);
      expect(
        body.containsKey('wrappedPrivateKey'),
        isFalse,
        reason:
            'the private half rides in the backup envelope (§K.3), not here '
            '- the server has no such field and never did',
      );
    });
  });

  group('the device certificate (§H.2)', () {
    test('matches UpdateDeviceCertificateDto, with ISO-8601 times', () async {
      final issuedAt = DateTime.utc(2026, 8, 2, 12);
      final expiresAt = issuedAt.add(const Duration(days: 180));

      await devices.uploadDeviceCertificate(
        clientDeviceId: 'device_1',
        certificate: 'Y2VydA==',
        issuedAt: issuedAt,
        expiresAt: expiresAt,
        identityKeyVersion: 2,
      );

      final request = requestFor('/certificate');
      expect(request.method, 'PUT');
      expect(
        request.path,
        '$_base/api/v1/identity/devices/client/device_1/certificate',
      );

      final body = Map<String, dynamic>.from(request.data as Map);
      expect(body['certificate'], 'Y2VydA==');
      expect(body['identityKeyVersion'], 2);
      // `DateTimeOffset` server-side. The epoch-seconds form the *signed*
      // payload uses (§K.1) does not deserialise into one, so the two
      // representations must not be confused.
      expect(body['issuedAt'], '2026-08-02T12:00:00.000Z');
      expect(body['expiresAt'], isA<String>());
      expect(body['expiresAt'], contains('2027-01-29'));
    });

    test('the issued lifetime is within the server\'s maximum', () {
      // `DeviceCertificate.MaxLifetime` server-side is 180 days and the check is
      // `expiresAt - issuedAt > MaxLifetime`, so 180 is the longest window that
      // is accepted. A day more and *every* certificate this client issues is a
      // 400 - which reads as "certificates do not work" rather than as an
      // off-by-one, because nothing else would ever succeed either.
      expect(
        AccountIdentityService.certificateLifetime,
        lessThanOrEqualTo(const Duration(days: 180)),
      );
      // And the renewal window has to sit inside it, or a certificate would be
      // reissued before it was ever considered current.
      expect(
        AccountEncryptionService.renewBefore,
        lessThan(AccountIdentityService.certificateLifetime),
      );
    });
  });

  group('capability reporting (§I.4)', () {
    test('registration declares what this build understands', () async {
      adapter.responses.add(('devices', 200, {'identityRotated': false}));

      await devices.register(
        clientDeviceId: 'device_1',
        deviceName: 'Test',
        deviceType: 'Mobile',
        identityPublicKey: 'a2V5',
      );

      final body = bodyFor('/devices');
      final capabilities = List<String>.from(body['capabilities'] as List);
      expect(
        capabilities,
        containsAll(const [
          'mls.device-cert.v1',
          'mls.join-request.conversation.v1',
          'mls.protection-level.v1',
          'mls.backup.v1',
        ]),
        reason:
            'the server computes the §I.1 coverage telemetry from these, '
            'not from a version string',
      );
    });

    test('the declared set is the one the coverage gate reads', () {
      // Pinned as a list rather than only as a "contains", so adding one is a
      // deliberate act: a capability claimed here is a claim the server will let
      // an account enter VerifiedDevices on.
      //
      // `push.loc.v1` is the one entry that claims nothing about MLS. It says
      // this build ships the string resources household notification keys
      // resolve against, and the server reads it to decide whether a push may
      // carry `body_loc_key` at all - a key with no entry in the bundle costs
      // the notification its text rather than falling back to English. Removing
      // those resources means removing it here in the same commit.
      expect(DeviceApi.capabilities, const [
        'mls.device-cert.v1',
        'mls.join-request.conversation.v1',
        'mls.protection-level.v1',
        'mls.backup.v1',
        'push.loc.v1',
      ]);
    });
  });
}
