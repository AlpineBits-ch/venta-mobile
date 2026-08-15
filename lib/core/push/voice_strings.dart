import 'dart:ui';

/// The notification copy behind every voice-ring localization key, in Dart.
///
/// A sibling of [HouseholdStrings] rather than an addition to it, and
/// deliberately so: these are not household copy, and the two features ship on
/// different client releases. A build that carries the household strings and not
/// these has to be able to say so, and it says so through the resource bundle it
/// ships - not through a shared list that would claim both.
///
/// ## Why this exists three times over
///
/// The same strings live in `android/app/src/main/res/values*/strings.xml` and
/// `ios/Runner/*.lproj/Localizable.strings`, and those two are the ones that
/// matter most of the time: a ring push carries a real notification block, so
/// when the app is backgrounded or dead the OS resolves the key against the
/// bundle and draws the notification with no Dart running at all.
///
/// The gap is the foreground. A notification-block push that arrives while the
/// app is in front is handed to `onMessage` and displayed by nobody, so
/// [VoiceRingNotifier] draws it - and to draw the same sentence the OS would
/// have, it needs the same table.
///
/// `test/voice_strings_test.dart` asserts all three stay identical.
///
/// ## Format
///
/// Placeholders are Android's positional form (`%1$s`), matched here verbatim so
/// the two can be compared as text. iOS's `Localizable.strings` uses `%1$@` for
/// the same argument in the same position; that difference is confined to the
/// iOS file.
///
/// **The inviter's display name has no key and never will.** It is what somebody
/// called themselves, and it reads the same in every language.
class VoiceStrings {
  const VoiceStrings._();

  static const fallbackLanguage = 'en';

  /// Every key this feature is allowed to send, named rather than spelled out
  /// at each use. The server's half is `Guild.Contracts/VoiceLocKeys.cs`.
  static const inviteBodyKey = 'voice_ring_invite_body';
  static const hiddenTitleKey = 'voice_ring_hidden_title';
  static const hiddenBodyKey = 'voice_ring_hidden_body';

  static const _en = <String, String>{
    // {1} is the voice channel's name. Only ever filled in for a target who has
    // been checked for ViewChannel on it - a ring is refused outright for
    // anybody who has not, precisely so a private channel's name cannot reach
    // the lock screen of somebody not supposed to know it exists.
    inviteBodyKey: r'Asked you to join %1$s.',

    // What a recipient with hide-push-content gets instead of the inviter's
    // name, and instead of the sentence above. Neither the person, the channel
    // nor the server is named: hiding push content is not satisfied by hiding
    // only the half of the notification that happens to be a sentence.
    hiddenTitleKey: 'Voice invite',
    hiddenBodyKey: 'Someone asked you to join a voice channel',
  };

  static const _de = <String, String>{
    inviteBodyKey: r'Möchte, dass du zu %1$s dazukommst.',
    hiddenTitleKey: 'Sprach-Einladung',
    hiddenBodyKey: 'Jemand möchte dich in einem Sprachkanal dabeihaben',
  };

  static const byLanguage = <String, Map<String, String>>{'en': _en, 'de': _de};

  /// Every key this table knows, in any language. The English map is the
  /// authority: a key translated into German but missing from English is
  /// unreachable, and `voice_strings_test.dart` fails on it.
  static Set<String> get keys => _en.keys.toSet();

  static String get _deviceLanguage =>
      PlatformDispatcher.instance.locale.languageCode.toLowerCase();

  /// The localized sentence for [key] with [args] substituted, or null when
  /// there is nothing better to show than what the server sent.
  ///
  /// Null covers exactly two cases and both mean "use the server's text": no key
  /// at all, and a key this build has never heard of - which is a server running
  /// ahead of this app, the normal state of a mobile release train.
  static String? resolve(String? key, List<String> args, {String? language}) {
    if (key == null || key.isEmpty) return null;

    final requested = (language ?? _deviceLanguage).toLowerCase();
    final template =
        byLanguage[requested]?[key] ?? byLanguage[fallbackLanguage]?[key];
    if (template == null) return null;

    return format(template, args);
  }

  /// Substitutes `%1$s`-style positional placeholders.
  ///
  /// Positional rather than sequential because translations reorder arguments,
  /// and that reordering is the entire reason the platform formats use indices.
  /// A placeholder with no argument behind it is left as written: a visible
  /// `%1$s` is a bug report, and a sentence with a gap in it is a mystery.
  static String format(String template, List<String> args) {
    if (args.isEmpty) return template;

    return template.replaceAllMapped(RegExp(r'%(\d+)\$s'), (match) {
      final index = int.parse(match.group(1)!) - 1;
      if (index < 0 || index >= args.length) return match.group(0)!;
      return args[index];
    });
  }
}
