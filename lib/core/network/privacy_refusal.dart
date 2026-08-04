import 'package:dio/dio.dart';

/// Why a privacy-aware endpoint refused, as a machine-readable code rather than
/// prose.
///
/// The DM, friend-request and privacy-write paths all answer a refusal with
/// `403` and a code, precisely so the client can tell "not allowed" from
/// "malformed" - a distinction the old `400 "User cannot be added to
/// conversation if not friends"` could not express, and which is why the same
/// wording used to be shown for a blocked user, a friends-only recipient and a
/// genuine bad request.
enum PrivacyRefusal {
  /// The recipient's DM policy does not admit you.
  recipientDmPolicy,

  /// You are blocked, or you have blocked them.
  ///
  /// Deliberately worded to the *user* exactly as [recipientDmPolicy] is - see
  /// [message]. The code is distinguishable here because the client is on the
  /// refused party's own device; what must not be distinguishable is what
  /// reaches the screen.
  blocked,

  /// The target's friend-request policy does not admit you.
  ///
  /// Also what "no such user", "not discoverable" and "they blocked you" all
  /// answer with - the server collapses those four deliberately.
  friendRequestPolicy,

  /// An attachment was refused by the recipient's explicit-content filter.
  explicitContentFiltered,

  /// A minor floor forbids the write. [PrivacyRefusalException.field] names the
  /// setting.
  minorRestriction,

  /// The policy data could not be reached, so nothing was decided.
  ///
  /// A `503`, not a `403`: this is the one member here that is **not** a
  /// refusal, and telling the user they can't message someone because a lookup
  /// timed out is a lie the app would keep repeating. See [isRetryable].
  lookupUnavailable,
}

/// Thrown for a `403` carrying one of the codes above, or the `503` that means
/// no decision was reached at all.
class PrivacyRefusalException implements Exception {
  const PrivacyRefusalException(this.refusal, {this.field});

  final PrivacyRefusal refusal;

  /// The setting the server named, on [PrivacyRefusal.minorRestriction] only.
  final String? field;

  /// Whether trying again could plausibly succeed.
  ///
  /// True only for [PrivacyRefusal.lookupUnavailable]. Everything else is a
  /// decision, and an optimistic UI must drop the action rather than leave a
  /// retry affordance that can only fail again.
  bool get isRetryable => refusal == PrivacyRefusal.lookupUnavailable;

  /// What to put in front of the user.
  ///
  /// [PrivacyRefusal.blocked] and [PrivacyRefusal.recipientDmPolicy] share one
  /// sentence on purpose. Cross-cutting rule 5: "blocked", "not discoverable"
  /// and "does not exist" must be indistinguishable to the refused party, and a
  /// client that says "you have been blocked" hands back exactly the oracle the
  /// server went to the trouble of withholding.
  ///
  /// `blocked` is only ever returned to the *blocker*, so it is the one case
  /// where the app could say more - and deliberately doesn't here, because the
  /// two codes reach the same call sites and one sentence that is always true
  /// beats two that have to be kept indistinguishable by hand. Screens that
  /// know they are looking at a block (the profile menu, the block list) say so
  /// from their own state instead.
  String get message => switch (refusal) {
    PrivacyRefusal.recipientDmPolicy ||
    PrivacyRefusal.blocked => 'You can\'t message this person.',
    PrivacyRefusal.friendRequestPolicy =>
      'That friend request couldn\'t be sent.',
    PrivacyRefusal.explicitContentFiltered =>
      'That attachment was refused by the recipient\'s content filter.',
    PrivacyRefusal.minorRestriction =>
      'That setting can\'t be changed on this account.',
    PrivacyRefusal.lookupUnavailable =>
      'Couldn\'t check that just now - try again in a moment.',
  };
}

/// Reads the refusal code off a failed request, or null if it isn't one.
///
/// Tolerant about where the code sits: the services answer a refusal as
/// `{code}`, `{error}` or a bare string depending on which one refused, and a
/// refusal the client fails to recognise degrades into the caller's generic
/// error rather than into a wrong claim about why.
///
/// `503` is read as well as `403`, for `privacy_lookup_unavailable` alone. It
/// arrives on exactly the same routes and would otherwise fall into the same
/// generic "could not start that conversation" as a real refusal, which is the
/// one outcome the separate status code exists to prevent.
PrivacyRefusalException? privacyRefusalOf(Object error) {
  if (error is! DioException) return null;
  final status = error.response?.statusCode;
  if (status != 403 && status != 503) return null;
  final data = error.response?.data;

  String? code;
  String? field;
  if (data is String) {
    code = data.trim();
  } else if (data is Map) {
    for (final key in const ['code', 'error', 'reason', 'detail', 'title']) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) {
        code = value.trim();
        break;
      }
    }
    final named = data['field'];
    if (named is String && named.isNotEmpty) field = named;
  }
  if (code == null) return null;

  final refusal = switch (code) {
    'recipient_dm_policy' => PrivacyRefusal.recipientDmPolicy,
    'blocked' => PrivacyRefusal.blocked,
    'friend_request_policy' => PrivacyRefusal.friendRequestPolicy,
    'explicit_content_filtered' => PrivacyRefusal.explicitContentFiltered,
    'minor_restriction' => PrivacyRefusal.minorRestriction,
    'privacy_lookup_unavailable' => PrivacyRefusal.lookupUnavailable,
    _ => null,
  };
  if (refusal == null) return null;
  // A code that arrived on the wrong status is not read: `blocked` under a 503
  // would have the app state a decision the server explicitly did not make,
  // and `privacy_lookup_unavailable` under a 403 would offer a retry of
  // something already decided.
  final expected = refusal == PrivacyRefusal.lookupUnavailable ? 503 : 403;
  if (status != expected) return null;
  return PrivacyRefusalException(refusal, field: field);
}
