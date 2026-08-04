import 'dart:math';

import 'package:sentry_flutter/sentry_flutter.dart';

import '../storage/secure_storage_service.dart';

/// Who a crash report says it came from, and what it is allowed to carry.
///
/// The account's `allowDataCollection` flag used to gate nothing at all while
/// Sentry ran unconditionally, which is the specific failure T0-4 exists to fix:
/// a stored consent flag that gates nothing is worse than no flag, because it is
/// a false representation to the user.
///
/// What this does *not* do is turn error reporting off. Crash reporting is
/// service-operational - an app that cannot report why it died cannot be fixed
/// for anyone - so it stays on, and consent decides only whether the report is
/// attributable:
///
///  * **Consented**: reports carry the account's user id, so a support thread
///    can be tied to the crash behind it.
///  * **Not consented** (and every launch before sign-in): reports carry
///    [installId], 16 random bytes minted once per installation and stored
///    nowhere but this device's keychain. It survives sign-out on purpose -
///    it names the install, not the person - and it is deliberately *not* the
///    device id, which the server holds against the account and which would
///    therefore re-identify the very report this is pseudonymizing.
///
/// The PII scrub in [scrubEvent] applies in both cases. Consent to be
/// identified is not consent to have an email address, a phone number or a
/// request body swept into an error report.
class TelemetryConsent {
  TelemetryConsent({required this.secureStorage});

  final SecureStorageService secureStorage;

  String? _installId;
  bool _consented = false;

  /// The pseudonym. Null only if the keychain could not be reached before the
  /// first report - in which case the report simply carries no user at all,
  /// which is the safe direction.
  String? get installId => _installId;

  /// Reads (or mints) the install id. Safe to call before sign-in; safe to call
  /// more than once.
  Future<void> init() async {
    if (_installId != null) return;
    try {
      final existing = await secureStorage.readTelemetryInstallId();
      if (existing != null && existing.isNotEmpty) {
        _installId = existing;
        return;
      }
      final generated = _randomHex(16);
      await secureStorage.writeTelemetryInstallId(generated);
      _installId = generated;
    } catch (_) {
      // A keychain fault here must not cost the app its error reporting, and
      // must not be reported through the very reporter it is configuring.
      // Reports go out unattributed until the next launch succeeds.
    }
  }

  /// Applies the account's consent. Called after sign-in once the privacy
  /// record is known, and again whenever it changes.
  ///
  /// [userId] is only ever attached when [allowDataCollection] is true. Passing
  /// a user id with consent false is not an error and does not leak - the id is
  /// dropped here rather than at the call site, so no caller has to remember
  /// the rule.
  Future<void> apply({
    required bool allowDataCollection,
    String? userId,
  }) async {
    _consented = allowDataCollection;
    final identifier = allowDataCollection ? userId : _installId;
    await Sentry.configureScope((scope) async {
      // `id` is the only attribute set. `SentryUser` asserts that at least one
      // of id/username/email/ipAddress is present, which is why an unknown
      // identifier clears the user outright rather than sending an empty one.
      await scope.setUser(
        identifier == null ? null : SentryUser(id: identifier),
      );
      await scope.setTag('data_collection_consent', '$allowDataCollection');
    });
  }

  /// Drops back to the pseudonym. Called on sign-out: the next person to use
  /// this handset must not have their crashes filed under the last one's id.
  Future<void> signedOut() => apply(allowDataCollection: false);

  /// Whether the account has consented - read by anything that would otherwise
  /// attach user data to a report or a breadcrumb.
  bool get hasConsent => _consented;

  /// Strips identifiers Sentry collects by default or picks up from a Dio
  /// breadcrumb, before the event leaves the device.
  ///
  /// Wired as `options.beforeSend`. Written as a static so it can be installed
  /// during `SentryFlutter.init`, which runs before the container exists.
  ///
  /// Mutates rather than rebuilding through `copyWith`: every `copyWith` in
  /// this SDK is written `field ?? this.field`, so passing null to clear a
  /// field is silently a no-op and a scrub written that way would have looked
  /// right and shipped nothing. The protocol objects' fields are mutable, so
  /// this assigns to them directly.
  static SentryEvent? scrubEvent(SentryEvent event, Hint hint) {
    final user = event.user;
    if (user != null) {
      user
        ..email = null
        ..username = null
        ..ipAddress = null
        ..name = null
        ..geo = null
        // Where a Dio interceptor would deposit a request body.
        ..data = null;
      // An id-less user carries nothing but the attributes just removed.
      if (user.id == null) event.user = null;
    }

    final request = event.request;
    if (request != null) {
      // Rebuilt rather than mutated: `data` is a getter over a private field
      // with no setter, so it cannot be cleared in place, and it is the field
      // most likely to be carrying a password or a message body.
      //
      // What survives is what identifies the *endpoint* - which is the whole
      // diagnostic value of a request on an error report. The query string
      // goes with the rest: an email lookup or a token would sit there.
      event.request = SentryRequest(
        url: request.url,
        method: request.method,
        apiTarget: request.apiTarget,
      );
    }

    final breadcrumbs = event.breadcrumbs;
    if (breadcrumbs != null) {
      for (final crumb in breadcrumbs) {
        crumb.data = _scrubBreadcrumbData(crumb.data);
      }
    }
    return event;
  }

  /// HTTP breadcrumbs carry the full request URL, and several routes in this
  /// API put an identifier in the path (`/relationships/{userId}/block`,
  /// `/user/{id}`). The path is what makes the breadcrumb useful, so it stays;
  /// the query string - where a token or an email lookup would sit - does not.
  static Map<String, dynamic>? _scrubBreadcrumbData(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) return data;
    final scrubbed = <String, dynamic>{};
    for (final entry in data.entries) {
      if (const {'body', 'data', 'request_body', 'headers'}.contains(
        entry.key,
      )) {
        continue;
      }
      final value = entry.value;
      scrubbed[entry.key] = entry.key == 'url' && value is String
          ? _stripQuery(value)
          : value;
    }
    return scrubbed;
  }

  static String _stripQuery(String url) {
    final cut = url.indexOf('?');
    return cut == -1 ? url : url.substring(0, cut);
  }

  static String _randomHex(int byteCount) {
    final random = Random.secure();
    return [
      for (var i = 0; i < byteCount; i++)
        random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ].join();
  }
}
