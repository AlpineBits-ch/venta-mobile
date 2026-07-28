import 'route_paths.dart';

/// Single owner for turning a `venta://` URI — or an equivalent synthesized
/// URI from a push-notification tap payload — into a router location.
///
/// `invite` and `conversation` are implemented for v1 (the latter feeds
/// `PushNotificationService`'s notification-tap handling — see
/// `venta://conversation/<id>` synthesized from a message push's
/// `conversationId` data field). Other Alpine desktop hosts
/// (`install-bot`, `discord-import`, `steam-auth`) are out of scope for
/// mobile right now; they fall through to the logged no-op default so
/// adding real support later is a new `case` plus a new route, nothing else.
abstract final class DeepLinkHandler {
  static String? resolve(Uri uri) {
    if (uri.scheme != 'venta') return null;

    switch (uri.host) {
      case 'invite':
        final code = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
        if (code == null || code.isEmpty) return null;
        return RoutePaths.invitePath(code);
      case 'conversation':
        final id = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
        if (id == null || id.isEmpty) return null;
        return RoutePaths.conversationPath(id);
      default:
        return null;
    }
  }
}
