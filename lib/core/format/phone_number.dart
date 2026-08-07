/// The one shape a phone number is allowed to take, and the reasons this file
/// is deliberately unhelpful about the shapes it isn't.
///
/// The server accepts E.164 and nothing else: a `+`, a country code, and the
/// national number with its trunk prefix already dropped. It does **not**
/// rewrite `0041…` into `+41…`, and neither does this. That conversion looks
/// obvious and is wrong often enough to matter - `00` is the international
/// prefix across most of Europe but `011` in North America, `010` in Japan,
/// `002` on one Taiwanese carrier, and nothing at all in a few places - so a
/// client that "helpfully" swapped the prefix would sometimes produce a
/// perfectly valid number belonging to a stranger. On a screen whose entire
/// purpose is telling somebody where to send money, that is the one failure
/// mode worth designing against.
///
/// So the rule is: explain what is wrong, ask for the `+` form, change nothing.
///
/// This mirrors `Identity.Application/Services/E164PhoneNumber.Normalize`
/// character for character. It is duplicated rather than deferred to because a
/// round trip is a poor way to find out you typed a space wrong - not because
/// the client is the authority. The server re-normalises whatever arrives and
/// its answer is the one that gets stored.
library;

/// Punctuation people put in phone numbers, which the server strips before it
/// counts digits. The last entry is a non-breaking space: iOS's own contact
/// formatting and a good many web pages emit them, and pasting one in should
/// not be an error.
const _separators = {' ', '-', '.', '(', ')', ' '};

/// E.164 caps the whole number at 15 digits. The floor is the server's, and is
/// low enough to admit the genuinely short national schemes (Niue, Tokelau)
/// rather than being a guess at what a "real" number looks like.
const phoneMinDigits = 6;
const phoneMaxDigits = 15;

/// The example used everywhere the format has to be shown rather than
/// described. Swiss, because that is where TWINT is.
const phoneNumberExample = '+41 79 123 45 67';

/// `+41 79 123 45 67` -> `+41791234567`, or null when [raw] is not E.164.
///
/// Only separators are removed. Nothing is added, substituted or guessed.
String? normalizePhoneNumber(String raw) {
  final trimmed = raw.trim();
  if (!trimmed.startsWith('+')) return null;

  final digits = StringBuffer();
  for (final unit in trimmed.substring(1).split('')) {
    if (_isDigit(unit)) {
      digits.write(unit);
      continue;
    }
    if (_separators.contains(unit)) continue;
    return null;
  }

  final value = digits.toString();
  if (value.length < phoneMinDigits || value.length > phoneMaxDigits) {
    return null;
  }
  // No country code starts with a zero, so a leading one means a trunk prefix
  // came along for the ride - `+0041…`, or `+079…`.
  if (value.startsWith('0')) return null;

  return '+$value';
}

/// Whether [raw] is a number the server will accept.
bool isE164PhoneNumber(String raw) => normalizePhoneNumber(raw) != null;

/// Everything left once the separators are taken out, so the checks below can
/// look at the prefix without tripping over `+41 (0)79`.
String _compact(String raw) =>
    raw.trim().split('').where((unit) => !_separators.contains(unit)).join();

bool _isDigit(String unit) {
  if (unit.length != 1) return false;
  final code = unit.codeUnitAt(0);
  return code >= 0x30 && code <= 0x39;
}

/// What is wrong with [raw], as a sentence to put under the field - or null
/// when there is nothing wrong with it, including when it is still empty.
///
/// Every branch here exists because the generic "invalid phone number" that
/// would replace it leaves somebody staring at a number that looks completely
/// fine to them. The one they typed *is* the one they dial; what it is missing
/// is the part their own phone has never asked them for.
String? phoneNumberProblem(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;
  if (normalizePhoneNumber(trimmed) != null) return null;

  final compact = _compact(trimmed);

  if (compact.startsWith('00')) {
    return 'A number written 00 41 … is not the same thing as +41 … in every '
        'country, so nothing here swaps one for the other - guessing wrong '
        'would hand you a stranger\'s number. Replace the 00 with a + '
        'yourself: $phoneNumberExample.';
  }
  if (!compact.startsWith('+')) {
    return 'Start with a + and the country code - $phoneNumberExample. A '
        'number typed the way you dial it at home doesn\'t say which country '
        'it is in.';
  }

  final body = compact.substring(1);
  if (body.isEmpty) {
    return 'Add the country code and the number after the +.';
  }
  if (!body.split('').every(_isDigit)) {
    return 'After the + this takes digits only. Spaces, dashes, dots and '
        'brackets are fine; anything else is not.';
  }
  if (body.startsWith('0')) {
    return 'Drop the 0 after the +. No country code begins with one - the + '
        'already stands in for the zero you would dial at home, so 079 … '
        'becomes +41 79 ….';
  }
  if (body.length < phoneMinDigits) {
    return 'That is only ${body.length} '
        '${body.length == 1 ? 'digit' : 'digits'} after the +, which is '
        'shorter than any phone number.';
  }
  return 'That is ${body.length} digits after the +. A phone number has at '
      'most $phoneMaxDigits.';
}
