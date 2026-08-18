import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mobile/core/device/device_id_service.dart';
import 'package:venta_mobile/core/mls/mls_sync_service.dart';
import 'package:venta_mobile/core/realtime/realtime_service.dart';
import 'package:venta_mobile/core/realtime/realtime_transport.dart';
import 'package:venta_mobile/features/auth/data/auth_repository.dart';
import 'package:venta_mobile/features/conversations/data/conversation_api.dart';
import 'package:venta_mobile/features/conversations/data/conversation_repository.dart';
import 'package:venta_mobile/features/conversations/data/models/conversation_dto.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockDeviceIdService extends Mock implements DeviceIdService {}

class _MockConversationApi extends Mock implements ConversationApi {}

class _MockMlsSyncService extends Mock implements MlsSyncService {}

/// A transport the test pushes hub methods through by hand.
class _FakeTransport implements RealtimeTransport {
  final _statusController =
      StreamController<RealtimeConnectionStatus>.broadcast();
  final _handlers = <String, void Function(List<Object?>?)>{};

  /// Delivers a hub method exactly as the real transport would - and, like the
  /// real one, silently does nothing for a method nobody registered.
  void emit(String method, Map<String, dynamic> payload) {
    _handlers[method]?.call([payload]);
  }

  bool isRegistered(String method) => _handlers.containsKey(method);

  @override
  Stream<RealtimeConnectionStatus> get connectionStatus =>
      _statusController.stream;

  @override
  bool get isConnected => true;

  @override
  bool get isDisconnected => false;

  @override
  void configure({
    required String hubUrl,
    required Future<String> Function() accessTokenFactory,
  }) {}

  @override
  void on(String method, void Function(List<Object?>? args) handler) {
    _handlers[method] = handler;
  }

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> invoke(String method, {List<Object>? args}) async {}
}

ConversationDto _group({String? name, DateTime? iconUpdatedAt}) =>
    ConversationDto(
      id: 'conv-1',
      name: name,
      encryptionState: ConversationEncryption.plain,
      iconUpdatedAt: iconUpdatedAt,
      members: const [
        ConversationMemberDto(
          id: 'm1',
          userId: 'user-1',
          cachedUserName: 'Ada',
        ),
        ConversationMemberDto(
          id: 'm2',
          userId: 'user-2',
          cachedUserName: 'Grace',
        ),
        ConversationMemberDto(
          id: 'm3',
          userId: 'user-3',
          cachedUserName: 'Edsger',
        ),
      ],
    );

void main() {
  late _FakeTransport transport;
  late RealtimeService realtime;
  late _MockConversationApi api;
  late ConversationRepository repository;

  setUp(() async {
    final auth = _MockAuthRepository();
    when(() => auth.baseUrl).thenReturn('https://example.test');
    when(() => auth.ensureValidToken()).thenAnswer((_) async => 'token');
    final devices = _MockDeviceIdService();
    when(() => devices.deviceId).thenReturn('device-1');

    transport = _FakeTransport();
    realtime = RealtimeService(
      transport: transport,
      authRepository: auth,
      deviceIdService: devices,
    );
    await realtime.start();

    api = _MockConversationApi();
    repository = ConversationRepository(
      api: api,
      mlsSync: _MockMlsSyncService(),
      realtimeService: realtime,
    );
  });

  tearDown(() => repository.dispose());

  group('ConversationDto', () {
    test('a group with no icon parses with a null stamp', () {
      final dto = ConversationDto.fromJson(const {
        'id': 'conv-1',
        'name': 'Lunch',
        'members': <dynamic>[],
        'encryptionState': 'Plain',
        'iconUpdatedAt': null,
      });
      expect(dto.iconUpdatedAt, isNull);
    });

    /// The stamp is the icon URL's cache key, so a designator-less value read
    /// as local time would produce a different key on every device - see
    /// `ApiDateTimeConverter`.
    test('an iconUpdatedAt without a Z is still read as UTC', () {
      final dto = ConversationDto.fromJson(const {
        'id': 'conv-1',
        'members': <dynamic>[],
        'encryptionState': 'Plain',
        'iconUpdatedAt': '2026-08-18T07:09:12.481',
      });
      expect(dto.iconUpdatedAt, DateTime.utc(2026, 8, 18, 7, 9, 12, 481));
    });
  });

  group('replaceCached', () {
    test('swaps the held conversation and republishes the list', () async {
      when(() => api.list()).thenAnswer((_) async => [_group(name: 'Lunch')]);
      await repository.fetch();

      final published = <List<ConversationDto>>[];
      final sub = repository.conversationsStream.listen(published.add);

      repository.replaceCached(_group(name: 'Dinner'));
      await Future<void>.delayed(Duration.zero);

      expect(repository.cached.single.name, 'Dinner');
      // Home renders the stream, so a patch that does not reach it is
      // invisible until something else refetches.
      expect(published.single.single.name, 'Dinner');
      await sub.cancel();
    });

    test('appends a conversation the cache has never seen', () async {
      when(() => api.list()).thenAnswer((_) async => <ConversationDto>[]);
      await repository.fetch();

      repository.replaceCached(_group(name: 'Lunch'));

      expect(repository.cached, hasLength(1));
    });
  });

  group('conversation.ConversationUpdated', () {
    setUp(() async {
      when(() => api.list()).thenAnswer((_) async => [_group(name: 'Lunch')]);
      await repository.fetch();
      clearInteractions(api);
    });

    test('is registered on the transport at all', () {
      // The bug this whole feature tripped over: a handler for an unregistered
      // method is unreachable code.
      expect(transport.isRegistered('conversation.ConversationUpdated'), isTrue);
    });

    test('a rename is applied from the push without a refetch', () async {
      transport.emit('conversation.ConversationUpdated', {
        'conversationId': 'conv-1',
        'name': 'Dinner',
        'iconUpdatedAt': null,
      });
      await Future<void>.delayed(Duration.zero);

      expect(repository.cached.single.name, 'Dinner');
      // The push carries the new values outright, so asking the server again
      // would be a round-trip for something already in hand.
      verifyNever(() => api.list());
    });

    /// `null` is a real value here - it is how a group says its name was
    /// cleared and the member list goes back in the title - so it must not be
    /// treated as "unchanged".
    test('a cleared name is applied rather than ignored', () async {
      transport.emit('conversation.ConversationUpdated', {
        'conversationId': 'conv-1',
        'name': null,
        'iconUpdatedAt': null,
      });
      await Future<void>.delayed(Duration.zero);

      expect(repository.cached.single.name, isNull);
    });

    test('an icon stamp is applied', () async {
      transport.emit('conversation.ConversationUpdated', {
        'conversationId': 'conv-1',
        'name': 'Lunch',
        'iconUpdatedAt': '2026-08-18T07:09:12.481Z',
      });
      await Future<void>.delayed(Duration.zero);

      expect(
        repository.cached.single.iconUpdatedAt,
        DateTime.utc(2026, 8, 18, 7, 9, 12, 481),
      );
    });

    /// The hub is not consistent about property casing, and a PascalCase
    /// payload read case-sensitively would find no `name` at all - which reads
    /// as "the name was removed" and would silently clear the group's name.
    test('a PascalCase payload is read the same as a camelCase one', () async {
      transport.emit('conversation.ConversationUpdated', {
        'ConversationId': 'conv-1',
        'Name': 'Dinner',
        'IconUpdatedAt': null,
      });
      await Future<void>.delayed(Duration.zero);

      expect(repository.cached.single.name, 'Dinner');
    });

    test('a push for an unheld conversation changes nothing', () async {
      transport.emit('conversation.ConversationUpdated', {
        'conversationId': 'someone-elses',
        'name': 'Dinner',
      });
      await Future<void>.delayed(Duration.zero);

      expect(repository.cached.single.name, 'Lunch');
      verifyNever(() => api.list());
    });

    /// Everything that is not a rename is structural and genuinely needs the
    /// list again - the fast path must not swallow those.
    test('a structural event still refetches', () async {
      when(() => api.list()).thenAnswer((_) async => [_group(name: 'Lunch')]);
      transport.emit('conversation.MemberLeft', {'conversationId': 'conv-1'});
      await Future<void>.delayed(Duration.zero);

      verify(() => api.list()).called(1);
    });
  });
}
