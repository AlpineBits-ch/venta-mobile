/// The sibling sites an instance publishes next to its API - the support desk
/// today, docs and the moderation console in principle.
///
/// Derived from whatever host the client is already pointed at, so a
/// self-hosted instance needs nothing configured. See [siteHost] for the one
/// rule that matters.
enum SiteLabel {
  support,
  docs,
  admin,

  /// The public platform-status page. Same derivation as the rest - a
  /// self-hosted instance on `api.example.org` publishes its own
  /// `status.example.org` and this client links there rather than at
  /// venta.gg's.
  status;

  String get label => name;
}

/// `api.venta.gg` → `support.venta.gg`; `venta.gg` → `support.venta.gg`.
///
/// **Replaces the first label, it does not prepend one.** Prepending is the bug
/// the server side shipped once: an instance on `api.venta.gg` derived
/// `support.api.venta.gg`, a name with no DNS behind it, and every link in the
/// client went nowhere. A bare domain (`venta.gg`), a single label, and a bare
/// IP have no first label to spend, so those do get a prefix.
///
/// [apiUrl] is the instance's API base - `AuthRepository.baseUrl`, or the URL a
/// sign-in was attempted against when there is no session yet.
///
/// The scheme is carried over rather than forced to https: a developer pointed
/// at `http://localhost:5000` should reach `http://support.localhost:5000`
/// rather than a TLS host that isn't there.
///
/// A self-hosted instance can override the server's copy of this with
/// `SUPPORT_DOMAIN`, and there is no way for the client to read that - so if
/// the derived host is wrong for a deployment, the client's links are wrong.
/// That's tolerable because the same derivation is the default on both sides,
/// and the fix is a `/api/v1/configuration` field carrying the real URL, not a
/// hardcoded `venta.gg` here.
String siteHost(String apiUrl, SiteLabel label) {
  final uri = Uri.tryParse(apiUrl);
  final hostname = uri?.host ?? '';
  // Nothing parseable to derive from. Returning the input unchanged would hand
  // a caller a URL that opens the API root; an empty string is a value callers
  // can test, and [supportUrlOrNull] is how they do it.
  if (hostname.isEmpty) return '';

  final scheme = uri!.scheme.isEmpty ? 'https' : uri.scheme;
  final port = uri.hasPort ? ':${uri.port}' : '';
  final labels = hostname.split('.');

  final isBareIp = RegExp(r'^[\d.]+$').hasMatch(hostname);
  final host = labels.length < 3 || isBareIp
      ? '${label.label}.$hostname'
      : [label.label, ...labels.skip(1)].join('.');

  return '$scheme://$host$port';
}

/// [siteHost] for the support desk, or null when it could not be derived -
/// which is the signal to render no link at all rather than a dead one.
String? supportUrlOrNull(String apiUrl) {
  final url = siteHost(apiUrl, SiteLabel.support);
  return url.isEmpty ? null : url;
}

/// The same for the public status page.
///
/// Only ever a *fallback*: an incident's own `url` from the status API is the
/// link that points at the specific incident, and this is where a banner that
/// arrived without one - or the "Open status page" row - goes instead.
String? statusUrlOrNull(String apiUrl) {
  final url = siteHost(apiUrl, SiteLabel.status);
  return url.isEmpty ? null : url;
}
