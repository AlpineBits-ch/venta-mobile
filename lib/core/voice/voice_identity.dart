/// How the SFU names a connection, and how to get a user id back out of one.
///
/// An identity is the **bare user id** - not `user-{userId}`, whatever the
/// worked examples in the spec look like at a glance. A secondary connection
/// appends a tag: `{userId}#{tag}`, e.g. `AbC123#screen`.
///
/// The `#` separator is guaranteed to be unambiguous in both directions. User
/// ids are Sqids and never contain one, and [connectionTag] strips a tag to
/// letters and digits before it is appended, so splitting on the *first* `#`
/// always recovers the user id exactly.
///
/// This is what lets a remote LiveKit participant be mapped to a user without
/// consulting the snapshot at all - which matters, because tracks arrive from
/// the SDK carrying an identity and nothing else, and the roster read that
/// would otherwise be needed can be a round trip behind the media.
class VoiceIdentity {
  const VoiceIdentity._();

  static const String _separator = '#';

  /// The user behind an identity, primary or secondary alike.
  ///
  /// An identity with no tag is returned unchanged, which is the ordinary case:
  /// this client only ever opens primary connections.
  static String userIdOf(String identity) {
    final index = identity.indexOf(_separator);
    return index < 0 ? identity : identity.substring(0, index);
  }

  /// The tag on a secondary connection, or null on a primary one.
  static String? tagOf(String identity) {
    final index = identity.indexOf(_separator);
    return index < 0 ? null : identity.substring(index + 1);
  }

  /// Whether [identity] is the primary connection of [userId] - the one
  /// carrying their microphone.
  static bool isPrimaryOf(String identity, String userId) =>
      identity == userId;

  /// Sanitises a tag the way the server does before it builds an identity from
  /// it: letters and digits only, truncated to 32 characters, falling back to
  /// `alt` when nothing survives.
  ///
  /// Mirrored here so a caller can predict the identity its own secondary
  /// connection will be given, rather than discovering it from the response.
  static String connectionTag(String tag) {
    final cleaned = tag.replaceAll(RegExp('[^A-Za-z0-9]'), '');
    if (cleaned.isEmpty) return 'alt';
    return cleaned.length <= 32 ? cleaned : cleaned.substring(0, 32);
  }
}
