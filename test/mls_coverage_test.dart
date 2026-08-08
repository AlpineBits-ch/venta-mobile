import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mobile/core/device/device_id_service.dart';
import 'package:venta_mobile/core/mls/mls_coverage_service.dart';
import 'package:venta_mobile/core/mls/mls_service.dart';
import 'package:venta_mobile/core/mls/mls_sync_service.dart';
import 'package:venta_mobile/core/network/api_client.dart';
import 'package:venta_mobile/features/auth/data/auth_repository.dart';
import 'package:venta_mobile/features/mls/data/mls_api.dart';
import 'package:venta_mobile/features/mls/data/models/mls_dtos.dart';

/// What these cover: a device gets into an MLS group exactly one way - some
/// member's client seals it a Welcome - and if it had no key package available
/// at that moment it is simply left out, with nothing ever adding it afterwards.
///
/// The server reported that at three moments: creating a conversation, enabling
/// encryption, and the commit that admits somebody. Each is one response handed
/// to one client, so the information existed for a few seconds in one place and
/// then was gone. To the person holding the left-out device it looked like
/// nothing at all - no error, no failed request, just a conversation that opens
/// empty, which is indistinguishable from one nobody has written in.
///
/// `GET .../mls/coverage` lets the question be asked again. Two properties of
/// the answer are load-bearing here and neither is cosmetic:
///
/// 1. **`covered: false` is evidence, not proof.** A device that walked back in
///    by external commit leaves none of the three traces the server looks for
///    and reads as uncovered while decrypting perfectly. Telling that device it
///    cannot read the conversation it is currently reading is worse than saying
///    nothing, so the answer is always crossed against local group state.
/// 2. **Empty lists are not an all-clear.** When `coverageUnavailable` is set
///    they are empty because nothing could be looked up, and letting that clear
///    a warning reproduces exactly the silence this route exists to break.
class _MockApi extends Mock implements MlsApi {}

class _MockMls extends Mock implements MlsService {}

class _MockDeviceIds extends Mock implements DeviceIdService {}

class _MockAuth extends Mock implements AuthRepository {}

/// Answers each request from a queue of canned responses (the last repeats),
/// recording what it was asked.
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this.responses);

  final List<ResponseBody Function()> responses;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final index = requests.length - 1;
    return responses[index < responses.length ? index : responses.length - 1]();
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Map<String, dynamic> body) => ResponseBody.fromString(
  jsonEncode(body),
  200,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

const _context = 'conv_1';
const _thisDevice = 'device-this';
const _myLaptop = 'device-my-laptop';
const _peer = 'user_peer';

MlsCoverageDto _coverage({
  bool encrypted = true,
  int? generation = 2,
  List<MlsDeviceCoverageDto> own = const [],
  List<UnreachableDeviceDto> peers = const [],
  bool unavailable = false,
}) => MlsCoverageDto(
  contextId: _context,
  encrypted: encrypted,
  generation: encrypted ? generation : null,
  ownDevices: own,
  unreachableDevices: peers,
  coverageUnavailable: unavailable,
);

MlsDeviceCoverageDto _device(
  String id, {
  String? name,
  required bool covered,
}) => MlsDeviceCoverageDto(deviceId: id, deviceName: name, covered: covered);

void main() {
  late _MockApi api;
  late _MockMls mls;
  late StreamController<MlsContextChanged> changes;
  late MlsCoverageService service;

  setUp(() {
    api = _MockApi();
    mls = _MockMls();
    changes = StreamController<MlsContextChanged>.broadcast();

    final deviceIds = _MockDeviceIds();
    when(() => deviceIds.deviceIdOrNull).thenReturn(_thisDevice);
    when(() => mls.deviceIdService).thenReturn(deviceIds);

    // Locked out by default: no group for the context, in any generation.
    when(() => mls.activeGroupId(any())).thenReturn(null);
    when(() => mls.groupId(any(), any())).thenReturn(null);

    service = MlsCoverageService(
      api: api,
      mls: mls,
      contextChanged: changes.stream,
    );
  });

  tearDown(() async {
    service.dispose();
    await changes.close();
  });

  void serverSays(MlsCoverageDto dto) {
    when(
      () => api.getCoverage(
        contextId: any(named: 'contextId'),
        isChannel: any(named: 'isChannel'),
      ),
    ).thenAnswer((_) async => dto);
  }

  Future<DeviceCoverageView> read({bool refresh = false}) =>
      service.view(_context, isChannel: false, refresh: refresh);

  group('reading the answer', () {
    test('splits the three situations apart', () async {
      // They read differently and they resolve differently. Collapsing them
      // into one warning is the main way this can be made worse than the
      // silence it replaces.
      serverSays(
        _coverage(
          own: [
            _device(_thisDevice, name: 'Pixel 8', covered: false),
            _device(_myLaptop, name: 'MacBook Pro', covered: false),
            _device('device-my-tablet', name: 'iPad', covered: true),
          ],
          peers: const [
            UnreachableDeviceDto(
              userId: _peer,
              deviceId: 'device-theirs',
              deviceName: 'iPhone 15',
            ),
          ],
        ),
      );

      final view = await read();

      expect(view.encrypted, isTrue);
      expect(view.lockedOutHere, isTrue);
      expect(
        view.otherOwnDevices.map((d) => d.deviceId),
        [_myLaptop],
        reason:
            'a covered device is not stranded, and the device in hand has '
            'its own case with an action on it',
      );
      expect(view.peerDevices.single.deviceId, 'device-theirs');
    });

    test('a covered device in hand says nothing at all', () async {
      serverSays(_coverage(own: [_device(_thisDevice, covered: true)]));

      final view = await read();

      expect(view.lockedOutHere, isFalse);
      expect(view.hasStrandedDevices, isFalse);
    });

    test('a device the answer never mentions is not accused', () async {
      // A handset registered after the answer was computed, or one the roster
      // lookup dropped. Absent is not the same as uncovered.
      serverSays(_coverage(own: [_device(_myLaptop, covered: false)]));

      final view = await read();

      expect(view.lockedOutHere, isFalse);
      expect(view.otherOwnDevices, hasLength(1));
    });
  });

  group('the local cross-check', () {
    test('suppresses a false alarm on a device that walked back in', () async {
      // The external-commit case. It leaves none of the three traces the server
      // computes `covered` from - no Welcome addressed to it, no commit
      // published from it, no record that it built the group - and it decrypts
      // everything perfectly. The server's answer alone would put a permanent
      // "you can't read this" above a conversation the user is reading.
      when(() => mls.groupId(_context, 2)).thenReturn('group-held-here');
      serverSays(_coverage(own: [_device(_thisDevice, covered: false)]));

      final view = await read();

      expect(view.lockedOutHere, isFalse);
    });

    test('asks about the generation the answer was computed for', () async {
      // Holding generation 1 says nothing about generation 2: a device left out
      // of the re-key genuinely cannot read what is being sent now, and a check
      // that only asked "has this device ever held a group here" would wave it
      // through.
      when(() => mls.groupId(_context, 1)).thenReturn('an-old-group');
      when(() => mls.groupId(_context, 2)).thenReturn(null);
      serverSays(
        _coverage(generation: 2, own: [_device(_thisDevice, covered: false)]),
      );

      expect((await read()).lockedOutHere, isTrue);
    });

    test('says nothing when this installation has no device id yet', () async {
      final deviceIds = _MockDeviceIds();
      when(() => deviceIds.deviceIdOrNull).thenReturn(null);
      when(() => mls.deviceIdService).thenReturn(deviceIds);
      serverSays(_coverage(own: [_device(_thisDevice, covered: false)]));

      final view = await read();

      expect(view.lockedOutHere, isFalse);
      expect(
        view.otherOwnDevices,
        hasLength(1),
        reason: 'with nothing to match against, every entry is "some device"',
      );
    });
  });

  group('encryption off', () {
    test('renders nothing, and is not "everybody is outside"', () async {
      serverSays(_coverage(encrypted: false));

      final view = await read();

      expect(view.encrypted, isFalse);
      expect(view.lockedOutHere, isFalse);
      expect(view.hasStrandedDevices, isFalse);
      expect(view.unavailable, isFalse);
    });
  });

  group('coverageUnavailable', () {
    test('never clears what was already known', () async {
      serverSays(
        _coverage(
          own: [_device(_myLaptop, name: 'MacBook Pro', covered: false)],
        ),
      );
      expect((await read()).otherOwnDevices, hasLength(1));

      // The sibling service is down. Both lists come back empty because nothing
      // could be looked up, not because anybody got let in.
      serverSays(_coverage(unavailable: true));
      final view = await read(refresh: true);

      expect(view.otherOwnDevices, hasLength(1));
      expect(view.unavailable, isTrue);
    });

    test('never reads as an all-clear on its own', () async {
      serverSays(_coverage(unavailable: true));

      final view = await read();

      expect(view.unavailable, isTrue);
      expect(view.hasStrandedDevices, isFalse);
    });

    test('does not accuse the device in hand', () async {
      // Its list is empty for the same reason every other list is. Reading an
      // absent entry as "uncovered" would raise the one notice with an action
      // on it on no evidence whatsoever.
      serverSays(
        _coverage(
          unavailable: true,
          own: [_device(_thisDevice, covered: false)],
        ),
      );

      expect((await read()).lockedOutHere, isFalse);
    });

    test('does replace an answer about a different generation', () async {
      serverSays(
        _coverage(generation: 2, own: [_device(_myLaptop, covered: false)]),
      );
      await read();

      // Not stale - wrong. A verdict about generation 2 says nothing about the
      // group that exists now, so keeping it would be worse than admitting the
      // lookup failed.
      serverSays(_coverage(generation: 3, unavailable: true));
      final view = await read(refresh: true);

      expect(view.otherOwnDevices, isEmpty);
      expect(view.unavailable, isTrue);
    });

    test(
      'a failed request keeps the warning and says it could not ask',
      () async {
        serverSays(_coverage(own: [_device(_myLaptop, covered: false)]));
        await read();

        when(
          () => api.getCoverage(
            contextId: any(named: 'contextId'),
            isChannel: any(named: 'isChannel'),
          ),
        ).thenThrow(Exception('offline'));
        final view = await read(refresh: true);

        expect(view.otherOwnDevices, hasLength(1));
        expect(view.unavailable, isTrue);
      },
    );

    test('a failed request with nothing known says nothing', () async {
      when(
        () => api.getCoverage(
          contextId: any(named: 'contextId'),
          isChannel: any(named: 'isChannel'),
        ),
      ).thenThrow(Exception('offline'));

      final view = await read();

      expect(view.encrypted, isFalse);
      expect(view.lockedOutHere, isFalse);
      expect(view.unavailable, isTrue);
    });
  });

  group('caching', () {
    test('asks once per context, not on a timer', () async {
      serverSays(_coverage(own: [_device(_thisDevice, covered: true)]));

      await read();
      await read();
      await read();

      verify(
        () => api.getCoverage(
          contextId: _context,
          isChannel: any(named: 'isChannel'),
        ),
      ).called(1);
    });

    test('a refresh asks again - the security screen always does', () async {
      serverSays(_coverage(own: [_device(_thisDevice, covered: true)]));

      await read();
      await read(refresh: true);

      verify(
        () => api.getCoverage(
          contextId: _context,
          isChannel: any(named: 'isChannel'),
        ),
      ).called(2);
    });

    test('a changed generation throws the answer away', () async {
      // A device covered in generation 2 is not covered in generation 3, so an
      // answer that names a generation nobody believes in any more is not a
      // stale answer but a wrong one.
      serverSays(
        _coverage(generation: 2, own: [_device(_thisDevice, covered: true)]),
      );
      await read();

      service.noteGeneration(_context, 3);
      await read();

      verify(
        () => api.getCoverage(
          contextId: _context,
          isChannel: any(named: 'isChannel'),
        ),
      ).called(2);
    });

    test('the same generation keeps it', () async {
      serverSays(
        _coverage(generation: 2, own: [_device(_thisDevice, covered: true)]),
      );
      await read();

      service.noteGeneration(_context, 2);
      await read();

      verify(
        () => api.getCoverage(
          contextId: _context,
          isChannel: any(named: 'isChannel'),
        ),
      ).called(1);
    });

    test('a Welcome landing locally throws it away', () async {
      // The device that just got in is exactly the one whose notice has to come
      // down without waiting for the next launch.
      serverSays(_coverage(own: [_device(_thisDevice, covered: false)]));
      expect((await read()).lockedOutHere, isTrue);

      when(() => mls.groupId(_context, 2)).thenReturn('group-now-held');
      changes.add(
        const MlsContextChanged(
          contextId: _context,
          isChannel: false,
          selfRemoved: false,
        ),
      );
      await pumpEventQueue();

      expect((await read()).lockedOutHere, isFalse);
      verify(
        () => api.getCoverage(
          contextId: _context,
          isChannel: any(named: 'isChannel'),
        ),
      ).called(2);
    });

    test('a change elsewhere leaves this context alone', () async {
      serverSays(_coverage(own: [_device(_thisDevice, covered: true)]));
      await read();

      changes.add(
        const MlsContextChanged(
          contextId: 'conv_elsewhere',
          isChannel: false,
          selfRemoved: false,
        ),
      );
      await pumpEventQueue();
      await read();

      verify(
        () => api.getCoverage(
          contextId: _context,
          isChannel: any(named: 'isChannel'),
        ),
      ).called(1);
    });

    test('cached() reports nothing before anything has been asked', () {
      expect(service.cached(_context), isNull);
    });
  });

  group('on the wire', () {
    late _MockAuth auth;

    setUp(() {
      auth = _MockAuth();
      when(() => auth.baseUrl).thenReturn('https://api.venta.gg');
      when(() => auth.ensureValidToken()).thenAnswer((_) async => 'token');
    });

    ({MlsApi api, _ScriptedAdapter adapter}) wired(
      List<ResponseBody Function()> responses,
    ) {
      final client = ApiClient(
        authRepository: auth,
        deviceId: () => _thisDevice,
        registerDevice: () async {},
      );
      final adapter = _ScriptedAdapter(responses);
      client.dio.httpClientAdapter = adapter;
      return (api: MlsApi(client: client), adapter: adapter);
    }

    test('a conversation asks the conversation route', () async {
      final w = wired([
        () => _json({'contextId': _context, 'encrypted': false}),
      ]);

      await w.api.getCoverage(contextId: _context, isChannel: false);

      expect(
        w.adapter.requests.single.path,
        'https://api.venta.gg/api/v1/messaging/conversations/$_context/mls/coverage',
      );
    });

    test('a channel asks the channel route', () async {
      final w = wired([
        () => _json({'contextId': 'chan_1', 'encrypted': false}),
      ]);

      await w.api.getCoverage(contextId: 'chan_1', isChannel: true);

      expect(
        w.adapter.requests.single.path,
        'https://api.venta.gg/api/v1/messaging/channels/chan_1/mls/coverage',
      );
    });

    test(
      'the answer parses, including the fields that decide the UI',
      () async {
        final w = wired([
          () => _json({
            'contextId': _context,
            'encrypted': true,
            'generation': 2,
            'ownDevices': [
              {
                'deviceId': _thisDevice,
                'deviceName': 'Pixel 8',
                'covered': false,
              },
            ],
            'unreachableDevices': [
              {'userId': _peer, 'deviceId': 'd-77a', 'deviceName': 'iPhone 15'},
            ],
            'coverageUnavailable': false,
          }),
        ]);

        final dto = await w.api.getCoverage(
          contextId: _context,
          isChannel: false,
        );

        expect(dto.generation, 2);
        expect(dto.ownDevices.single.covered, isFalse);
        expect(dto.ownDevices.single.deviceName, 'Pixel 8');
        expect(dto.unreachableDevices.single.deviceName, 'iPhone 15');
        expect(dto.coverageUnavailable, isFalse);
      },
    );

    test('enabling encryption carries this device\'s id', () async {
      // Without it the server cannot tell which device built the group, so it
      // declines to say anything about this account's own hardware - on exactly
      // the path where the account's other devices are most likely to fall out.
      // The header comes from the interceptor every request goes through, not
      // from a second mechanism bolted onto this call.
      final w = wired([
        () => _json({'contextId': 'chan_1', 'encrypted': true}),
      ]);

      await w.api.enableChannelEncryption(
        channelId: 'chan_1',
        dto: const EnableMlsDto(mlsGroupId: 'g', epoch: 0),
      );

      expect(w.adapter.requests.single.headers['X-Device-Id'], _thisDevice);
    });
  });
}
