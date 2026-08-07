import 'dart:ui';

/// The notification copy behind every household localization key, in Dart.
///
/// ## Why this exists three times over
///
/// The same strings live in `android/app/src/main/res/values*/strings.xml` and
/// `ios/Runner/*.lproj/Localizable.strings`, and those two are the ones that
/// matter most of the time: a household push carries a real notification block,
/// so when the app is backgrounded or dead the OS resolves the key against the
/// bundle and draws the notification without Dart running at all. That is the
/// whole reason the server sends keys rather than a data-only payload - it works
/// when the app does not.
///
/// The gap is the foreground. A notification-block push that arrives while the
/// app is in front is handed to `onMessage` and displayed by nobody, so
/// [HouseholdNotifier] draws it - and to draw the same sentence the OS would
/// have, it needs the same table. Hence this copy.
///
/// `test/household_strings_test.dart` asserts all three stay identical, which is
/// the only thing that keeps "three copies" from meaning "three versions".
///
/// ## Format
///
/// Placeholders are Android's positional form (`%1$s`), matched here verbatim so
/// the two can be compared as text. iOS's `Localizable.strings` uses `%1$@` for
/// the same argument in the same position; that difference is confined to the
/// iOS file.
class HouseholdStrings {
  const HouseholdStrings._();

  /// The language used when the reader's own is not translated. Not a fallback
  /// to the server's text: [resolve] returning null is what asks the caller to
  /// use that instead, and it does so only for a key nobody has translated at
  /// all - which means a key added to the server ahead of this table.
  static const fallbackLanguage = 'en';

  static const _en = <String, String>{
    'household_chore_due_body': "Your turn, and it's due now.",
    'household_chore_nudge_body': 'Still waiting on this one at home.',
    'household_chore_reassigned_body': "Picked up from a flatmate who's away.",
    'household_expense_share_body': r'Your share is %1$s.',
    'household_expense_paid_body': r'Recorded as paid by you: %1$s.',
    'household_settlement_received_title': 'Payment received',
    'household_settlement_received_body': r'%1$s was recorded as paid to you.',
    'household_settlement_recorded_title': 'Payment recorded',
    'household_settlement_recorded_body': r'%1$s was recorded as paid by you.',
    'household_bill_due_body': r'Due today. Your share is %1$s.',
    'household_bill_due_soon_body': r'Due in %1$s. Your share is %2$s.',
    'household_bill_posted_body': r'Added to the ledger. Your share is %1$s.',
    'household_bill_needs_amount_body':
        'A bill needs an amount before it can be split.',
    'household_meal_cooking_today_title': "You're down to cook",
    'household_meal_cooking_today_body': "You're down to cook this today.",
    'household_maintenance_due_body': 'This is due for a service.',
    'household_maintenance_warranty_body': r'The warranty runs out in %1$s.',
    'household_maintenance_broken_body':
        "Marked as broken. Don't use it for now.",
    'household_decision_opened_body': 'A house decision needs your vote.',
    'household_decision_opened_closing_body':
        'A house decision needs your vote before it closes.',
    'household_decision_blocked_body': r'Blocked: %1$s',
    'household_list_item_added_body':
        r"Just went on %1$s - could you grab it while you're out?",
    'household_list_item_assigned_body':
        r"You've been asked to pick this up from %1$s.",
    'household_list_completed_body': 'Everything on it is ticked off.',
    'household_pantry_low_body': 'Running low at home.',
    'household_pantry_low_listed_body':
        r"Running low, so it's gone on %1$s.",
    'household_pantry_restock_body':
        "Ran low at home and went on the list - could you grab it while you're out?",
    'household_pantry_expiring_title': 'Use it or lose it',
    'household_pantry_expiring_one_body': r'%1$s is about to go off.',
    'household_pantry_expiring_two_body':
        r'%1$s and %2$s are about to go off.',
    'household_pantry_expiring_many_body':
        r'%1$s, %2$s and %3$s more are about to go off.',
    'household_hidden_title': 'Home',
    'household_hidden_body': 'Something needs your attention at home',
  };

  static const _de = <String, String>{
    'household_chore_due_body': 'Du bist dran, und es ist jetzt fällig.',
    'household_chore_nudge_body': 'Das ist zu Hause immer noch offen.',
    'household_chore_reassigned_body':
        'Von jemandem übernommen, der gerade nicht zu Hause ist.',
    'household_expense_share_body': r'Dein Anteil beträgt %1$s.',
    'household_expense_paid_body': r'Als von dir bezahlt erfasst: %1$s.',
    'household_settlement_received_title': 'Zahlung erhalten',
    'household_settlement_received_body':
        r'%1$s wurde als an dich gezahlt erfasst.',
    'household_settlement_recorded_title': 'Zahlung erfasst',
    'household_settlement_recorded_body':
        r'%1$s wurde als von dir gezahlt erfasst.',
    'household_bill_due_body': r'Heute fällig. Dein Anteil beträgt %1$s.',
    'household_bill_due_soon_body':
        r'Fällig in %1$s. Dein Anteil beträgt %2$s.',
    'household_bill_posted_body':
        r'Zum Haushaltsbuch hinzugefügt. Dein Anteil beträgt %1$s.',
    'household_bill_needs_amount_body':
        'Eine Rechnung braucht einen Betrag, bevor sie geteilt werden kann.',
    'household_meal_cooking_today_title': 'Du kochst heute',
    'household_meal_cooking_today_body': 'Das kochst du heute.',
    'household_maintenance_due_body': 'Das ist zur Wartung fällig.',
    'household_maintenance_warranty_body': r'Die Garantie läuft in %1$s ab.',
    'household_maintenance_broken_body':
        'Als defekt markiert. Bitte vorerst nicht benutzen.',
    'household_decision_opened_body':
        'Eine Entscheidung im Haushalt braucht deine Stimme.',
    'household_decision_opened_closing_body':
        'Eine Entscheidung im Haushalt braucht deine Stimme, bevor sie schließt.',
    'household_decision_blocked_body': r'Blockiert: %1$s',
    'household_list_item_added_body':
        r'Steht jetzt auf %1$s - kannst du es unterwegs mitnehmen?',
    'household_list_item_assigned_body':
        r'Du sollst das von %1$s mitbringen.',
    'household_list_completed_body': 'Alles darauf ist abgehakt.',
    'household_pantry_low_body': 'Zu Hause geht es zur Neige.',
    'household_pantry_low_listed_body':
        r'Geht zur Neige und steht jetzt auf %1$s.',
    'household_pantry_restock_body':
        'Ist zu Hause ausgegangen und steht auf der Liste - kannst du es unterwegs mitnehmen?',
    'household_pantry_expiring_title': 'Aufbrauchen oder wegwerfen',
    'household_pantry_expiring_one_body': r'%1$s läuft bald ab.',
    'household_pantry_expiring_two_body': r'%1$s und %2$s laufen bald ab.',
    'household_pantry_expiring_many_body':
        r'%1$s, %2$s und %3$s weitere laufen bald ab.',
    'household_hidden_title': 'Zuhause',
    'household_hidden_body': 'Zu Hause braucht etwas deine Aufmerksamkeit',
  };

  /// Keyed by language code alone, not by full locale. A household notification
  /// is two short sentences with no dates, no currency formatting of its own and
  /// no regional idiom in it - the server has already formatted every value that
  /// would have needed one - so `de_CH` and `de_DE` want the same string and
  /// splitting them would only produce bundles that drift.
  static const byLanguage = <String, Map<String, String>>{
    'en': _en,
    'de': _de,
  };

  /// Every key this table knows, in any language. The English map is the
  /// authority: a key translated into German but missing from English is a
  /// mistake, and `household_strings_test.dart` fails on it.
  static Set<String> get keys => _en.keys.toSet();

  /// The reader's language, from the platform. Read lazily rather than cached
  /// because it can change while the app is running.
  static String get _deviceLanguage =>
      PlatformDispatcher.instance.locale.languageCode.toLowerCase();

  /// The localized sentence for [key] with [args] substituted, or null when
  /// there is nothing better to show than what the server sent.
  ///
  /// Null covers exactly two cases and both mean "use the server's text": no key
  /// at all (the copy is user content - a shopping-list line, an expense
  /// description), and a key this build has never heard of, which is a server
  /// running ahead of this app. Neither is an error worth logging; a key added
  /// tomorrow arriving today is the normal state of a mobile release train.
  static String? resolve(
    String? key,
    List<String> args, {
    String? language,
  }) {
    if (key == null || key.isEmpty) return null;

    final requested = (language ?? _deviceLanguage).toLowerCase();
    final template =
        byLanguage[requested]?[key] ?? byLanguage[fallbackLanguage]?[key];
    if (template == null) return null;

    return format(template, args);
  }

  /// Substitutes `%1$s`-style positional placeholders.
  ///
  /// Positional rather than sequential because translations reorder arguments -
  /// German puts the amount where English puts the verb - and that reordering is
  /// the entire reason the platform formats use indices. A placeholder with no
  /// argument behind it is left as written rather than replaced with an empty
  /// hole: a visible `%2$s` is a bug report, and a sentence with a gap in it is
  /// a mystery.
  static String format(String template, List<String> args) {
    if (args.isEmpty) return template;

    return template.replaceAllMapped(RegExp(r'%(\d+)\$s'), (match) {
      final index = int.parse(match.group(1)!) - 1;
      if (index < 0 || index >= args.length) return match.group(0)!;
      return args[index];
    });
  }
}
