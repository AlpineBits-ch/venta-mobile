import 'package:flutter_test/flutter_test.dart';
import 'package:venta_mobile/core/routing/route_paths.dart';

/// `RoutePaths.parentOf` is what the Android back button uses on a screen with
/// nothing beneath it, and it has to land on the same place that screen's own
/// back arrow does - the two disagreeing is a bug the user sees, not a
/// stylistic one. The expectations here are the `fallbackLocation` each screen
/// passes to `AppBackButton`.
void main() {
  group('parentOf', () {
    test('a channel goes back to its guild', () {
      expect(RoutePaths.parentOf('/server/g1/channel/c1'), '/server/g1');
    });

    test("a channel's own screens go back to the channel", () {
      expect(
        RoutePaths.parentOf('/server/g1/channel/c1/settings'),
        '/server/g1/channel/c1',
      );
      expect(
        RoutePaths.parentOf('/server/g1/channel/c1/forum'),
        '/server/g1/channel/c1',
      );
    });

    test('guild screens go back to the guild', () {
      for (final location in [
        '/server/g1/members',
        '/server/g1/settings',
        '/server/g1/events',
        '/server/g1/channels-roles',
        '/server/g1/wiki',
      ]) {
        expect(RoutePaths.parentOf(location), '/server/g1', reason: location);
      }
    });

    test('wiki pages go back to the index, page screens to the page', () {
      expect(RoutePaths.parentOf('/server/g1/wiki/p1'), '/server/g1/wiki');
      expect(RoutePaths.parentOf('/server/g1/wiki/new'), '/server/g1/wiki');
      // WikiEditorScreen sends both of its entry points back to the index.
      expect(RoutePaths.parentOf('/server/g1/wiki/p1/edit'), '/server/g1/wiki');
      expect(
        RoutePaths.parentOf('/server/g1/wiki/p1/history'),
        '/server/g1/wiki/p1',
      );
    });

    test('a guild, a conversation and a profile go back to home', () {
      expect(RoutePaths.parentOf('/server/g1'), RoutePaths.home);
      expect(RoutePaths.parentOf('/home/conversation/c1'), RoutePaths.home);
      expect(RoutePaths.parentOf('/home/friends'), RoutePaths.home);
      expect(RoutePaths.parentOf('/user/u1'), RoutePaths.home);
      expect(RoutePaths.parentOf('/me'), RoutePaths.home);
      expect(RoutePaths.parentOf('/settings'), RoutePaths.home);
    });

    test('settings and profile sub-screens go back one level', () {
      expect(RoutePaths.parentOf('/me/edit'), RoutePaths.selfProfile);
      for (final location in [
        '/settings/account',
        '/settings/mfa',
        '/settings/notifications',
        '/settings/appearance',
        '/settings/qr-login',
        '/settings/devices',
      ]) {
        expect(
          RoutePaths.parentOf(location),
          RoutePaths.settings,
          reason: location,
        );
      }
    });

    test('home and the auth screens have nowhere above them', () {
      // Back from these is the press that closes the app.
      expect(RoutePaths.parentOf('/home'), isNull);
      expect(RoutePaths.parentOf('/login'), isNull);
      expect(RoutePaths.parentOf('/register'), isNull);
      expect(RoutePaths.parentOf('/server-setup'), isNull);
      expect(RoutePaths.parentOf('/forgot-password'), isNull);
    });

    test('a query string does not change the parent', () {
      expect(
        RoutePaths.parentOf('/server/g1/channel/c1?message=m1'),
        '/server/g1',
      );
    });
  });
}
