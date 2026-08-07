import 'dart:convert';

import '../routing/household_deep_link.dart';
import 'household_strings.dart';

/// A household-module push, as the backend's `HouseholdPushService` builds it.
///
/// Deliberately not a [MessagePushPayload]: there is no message, nothing here
/// is end-to-end encrypted, and the useful title is "Bins" rather than a
/// person's name. The two are told apart on the first key either parser reads,
/// `type`.
///
/// The push half of a household alert - the same `kind`, `targetId`, title and
/// body the `guild.HouseholdAlert` hub event carries (see `HouseholdAlert`).
/// A chore falling due, an expense you have a share in, a decision opened or
/// blocked, a restock, a pantry about to go off: [kind] is a stable slug and
/// the list keeps growing, so nothing branches on it to decide whether to show
/// the notification - an unrecognised kind still has a title, a body and
/// somewhere to land.
class HouseholdPushPayload {
  const HouseholdPushPayload({
    required this.kind,
    required this.guildId,
    required this.title,
    this.body = '',
    this.channelId,
    this.targetId,
    this.recipientUserId,
    this.hidden = false,
    this.titleLocKey,
    this.titleLocArgs = const [],
    this.bodyLocKey,
    this.bodyLocArgs = const [],
  });

  static const type = 'household';

  /// `chore.due`, and whatever the server adds later.
  final String kind;

  final String guildId;

  /// The module channel this came from, so tapping opens the right board.
  /// Absent for the guild-scoped modules, which have no channel of their own.
  final String? channelId;

  /// The row it's about - an occurrence id, an expense id. Also what the
  /// server collapses on, so a second notification about one chore replaces
  /// the first rather than stacking.
  final String? targetId;

  /// The server's English. What [localizedTitle] falls back to, and all a build
  /// that never declared `push.loc.v1` is sent.
  final String title;
  final String body;

  /// The localization key [title] is the English rendering of, or null when the
  /// title is something the user typed - a shopping-list line, an expense
  /// description, a pantry item's name - which reads the same in every language.
  ///
  /// Only ever populated for a build that declared `push.loc.v1` at device
  /// registration, because a key with no entry in the app bundle renders as the
  /// key itself rather than falling back to English. See `PushCapabilities`
  /// server-side.
  final String? titleLocKey;

  /// Values for the key's placeholders, in order, already formatted by the
  /// server. Empty for a key that takes none.
  final List<String> titleLocArgs;

  final String? bodyLocKey;
  final List<String> bodyLocArgs;

  final String? recipientUserId;

  /// The recipient has "hide push content" on, so [title] and [body] are
  /// already the server's neutral stand-ins. Nothing extra to do - it's here
  /// because a client that renders its own richer copy must not.
  final bool hidden;

  /// Where tapping this should land: the row it is about, the board it
  /// happened on when the kind names no row, or the house itself when the
  /// module isn't a channel.
  ///
  /// Deliberately the same function `HouseholdAlert.route` calls. The two
  /// envelopes carry the same alert and differ only in whether the app was
  /// running when it arrived, so a chore reminder tapped from the tray and one
  /// tapped in-app have to reach the same row.
  String get route => householdAlertRoute(
    guildId: guildId,
    kind: kind,
    channelId: channelId,
    targetId: targetId,
  );

  /// What to actually show, in the reader's language where there is one.
  ///
  /// Only reached when the app is in the foreground - a backgrounded or dead app
  /// has the OS resolve the very same key against the app bundle and never runs
  /// this. The two must agree, which is what
  /// `test/household_strings_test.dart` checks.
  String get localizedTitle =>
      HouseholdStrings.resolve(titleLocKey, titleLocArgs) ?? title;

  String get localizedBody =>
      HouseholdStrings.resolve(bodyLocKey, bodyLocArgs) ?? body;

  static bool matches(Map<String, dynamic> data) => data['type'] == type;

  static HouseholdPushPayload? tryParse(Map<String, dynamic> data) {
    if (!matches(data)) return null;
    final guildId = _string(data['guildId']);
    final kind = _string(data['kind']);
    if (guildId == null || kind == null) return null;

    return HouseholdPushPayload(
      kind: kind,
      guildId: guildId,
      channelId: _string(data['channelId']),
      targetId: _string(data['targetId']),
      title: _string(data['title']) ?? 'Home',
      body: _string(data['body']) ?? '',
      recipientUserId: _string(data['recipientUserId']),
      hidden: data['hidden'] == '1' || data['hidden'] == true,
      titleLocKey: _string(data['titleLocKey']),
      titleLocArgs: _args(data['titleLocArgs']),
      bodyLocKey: _string(data['bodyLocKey']),
      bodyLocArgs: _args(data['bodyLocArgs']),
    );
  }

  static String? _string(Object? value) {
    if (value == null) return null;
    final text = value.toString();
    return text.isEmpty ? null : text;
  }

  /// FCM data values are strings only, so an argument list arrives as JSON.
  ///
  /// Anything unparseable yields an empty list rather than throwing: this runs
  /// in a background isolate where an exception is a notification that silently
  /// never arrives, and an empty list only costs the reader the translation -
  /// [localizedBody] falls through to the server's English.
  static List<String> _args(Object? value) {
    final text = _string(value);
    if (text == null) return const [];

    try {
      final decoded = jsonDecode(text);
      if (decoded is! List) return const [];
      return decoded.map((e) => e?.toString() ?? '').toList(growable: false);
    } on FormatException {
      return const [];
    }
  }
}
