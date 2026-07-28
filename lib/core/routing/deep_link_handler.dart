import 'route_paths.dart';

/// Single owner for turning a `venta://` URI — or an equivalent synthesized
/// URI from a push-notification tap payload — into a router location.
///
/// Only `invite` is implemented for v1. Other Alpine desktop hosts
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
      default:
        return null;
    }
  }
}
