import 'route_paths.dart';

/// What a resolved `venta://` URI should do - most hosts just push a route,
/// but `invite` opens a modal popup over whatever screen is currently up
/// (matching desktop's `InviteDialogComponent`, which is a global overlay
/// rather than a navigated page) instead of a full navigation.
sealed class DeepLinkTarget {
  const DeepLinkTarget();
}

class RouteTarget extends DeepLinkTarget {
  const RouteTarget(this.path);
  final String path;
}

class InviteTarget extends DeepLinkTarget {
  const InviteTarget(this.code);
  final String code;
}

/// Single owner for turning a `venta://` URI - or an equivalent synthesized
/// URI from a push-notification tap payload - into a [DeepLinkTarget].
///
/// `invite` and `conversation` are implemented for v1 (the latter feeds
/// `PushNotificationService`'s notification-tap handling - see
/// `venta://conversation/<id>` synthesized from a message push's
/// `conversationId` data field). Other Alpine desktop hosts
/// (`install-bot`, `discord-import`, `steam-auth`) are out of scope for
/// mobile right now; they fall through to the logged no-op default so
/// adding real support later is a new `case` plus a new route, nothing else.
abstract final class DeepLinkHandler {
  /// Invites are matched against the whole URL rather than by scheme+host,
  /// mirroring Alpine's `handleDeepLink` (`url.match(/invite\/([^/?#]+)/)`).
  ///
  /// That is the difference between working and not: an invite reaches this
  /// client as `venta://invite/CODE` from the custom scheme, as
  /// `https://venta.gg/invite/CODE` when it's shared as a link, and with a
  /// query string on either. Keying on `uri.host == 'invite'` only ever
  /// matched the first of those.
  static final _inviteRe = RegExp(r'invite/([^/?#]+)');

  static DeepLinkTarget? resolve(Uri uri) {
    final invite = _inviteRe.firstMatch(uri.toString())?.group(1);
    if (invite != null && invite.isNotEmpty) return InviteTarget(invite);

    if (uri.scheme != 'venta') return null;

    switch (uri.host) {
      case 'conversation':
        final id = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
        if (id == null || id.isEmpty) return null;
        return RouteTarget(RoutePaths.conversationPath(id));
      default:
        return null;
    }
  }
}
