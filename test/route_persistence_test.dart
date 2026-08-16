import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:venta_mobile/core/routing/route_persistence.dart';

class _MemoryStorage implements Storage {
  final values = <String, dynamic>{};

  @override
  dynamic read(String key) => values[key];

  @override
  Future<void> write(String key, dynamic value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<void> clear() async => values.clear();

  @override
  Future<void> close() async {}
}

void main() {
  late _MemoryStorage storage;

  setUp(() {
    storage = _MemoryStorage();
    HydratedBloc.storage = storage;
  });

  group('round trip', () {
    test('a channel is saved and comes back', () {
      RoutePersistence.save('/server/g1/channel/c1');
      expect(RoutePersistence.lastLocation, '/server/g1/channel/c1');
    });

    test('a settings page is not saved, and does not displace one', () {
      RoutePersistence.save('/home/conversation/abc');
      RoutePersistence.save('/settings/notifications');
      expect(RoutePersistence.lastLocation, '/home/conversation/abc');
    });

    test('a household deep link comes back without its focus', () {
      RoutePersistence.save(
        '/server/g1/channel/c1?focusKind=chore&focus=choc_1',
      );
      expect(RoutePersistence.lastLocation, '/server/g1/channel/c1');
    });

    // What an upgraded install has in storage: whatever the previous version
    // wrote, which was every authenticated route it ever visited. Nothing
    // overwrites it either, so filtering only on write would leave someone
    // whose app last closed on a settings page landing there forever.
    test('a location left by the old behaviour is ignored', () {
      storage.values['last_route_location'] = '/settings/notifications';
      expect(RoutePersistence.lastLocation, isNull);
    });
  });

  group('RoutePersistence.isRestorable', () {
    test('restores the places you read messages in', () {
      expect(RoutePersistence.isRestorable('/home/conversation/abc'), isTrue);
      expect(RoutePersistence.isRestorable('/server/g1/channel/c1'), isTrue);
      expect(
        RoutePersistence.isRestorable('/server/g1/channel/c1?focus=x'),
        isTrue,
      );
    });

    test('does not restore settings, profiles or other one-off screens', () {
      const notRestorable = [
        '/settings',
        '/settings/notifications',
        '/settings/privacy/data',
        '/settings/ai/harness',
        '/me',
        '/me/edit',
        '/user/u1',
        '/inbox',
        '/inbox?guildId=g1',
        '/home',
        '/home/friends',
        '/server/g1',
        '/server/g1/members',
        '/server/g1/settings',
        '/server/g1/wiki/p1/edit',
        '/profile-settings',
      ];
      for (final location in notRestorable) {
        expect(
          RoutePersistence.isRestorable(location),
          isFalse,
          reason: '$location should fall back to Home',
        );
      }
    });

    test('does not restore a channel sub-screen, only the channel', () {
      expect(
        RoutePersistence.isRestorable('/server/g1/channel/c1/settings'),
        isFalse,
      );
      expect(
        RoutePersistence.isRestorable('/server/g1/channel/c1/forum'),
        isFalse,
      );
    });
  });
}
