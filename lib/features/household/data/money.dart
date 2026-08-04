/// Minor-unit money formatting and parsing for the shared ledger.
///
/// The ledger is integer minor units end to end - a decimal never crosses the
/// wire. These helpers exist so the *only* place a decimal exists is the text
/// the user actually reads and types, and the conversion happens in one place
/// rather than being re-derived (differently) at each call site.
library;

/// Currencies whose minor unit isn't 1/100. Everything absent from here is
/// treated as two decimals, which covers the overwhelming majority.
const _exponents = <String, int>{
  // No minor unit at all.
  'JPY': 0, 'KRW': 0, 'VND': 0, 'CLP': 0, 'ISK': 0, 'HUF': 0,
  'TWD': 0, 'UGX': 0, 'PYG': 0, 'RWF': 0, 'XAF': 0, 'XOF': 0,
  // Thousandths.
  'BHD': 3, 'IQD': 3, 'JOD': 3, 'KWD': 3, 'LYD': 3, 'OMR': 3, 'TND': 3,
};

/// How many decimal places [currency] is written with.
int currencyExponent(String currency) =>
    _exponents[currency.toUpperCase()] ?? 2;

/// `1234, 'CHF'` -> `CHF 12.34`.
///
/// The ISO code leads rather than a symbol: symbols are ambiguous across
/// locales ($ alone is four different currencies), and a household ledger is
/// exactly where that ambiguity costs someone money.
String formatMinor(
  int amountMinor,
  String currency, {

  /// Prefix a `+` on positive amounts - for balances, where the sign *is* the
  /// information ("you're owed" vs "you owe").
  bool signed = false,
  bool showCurrency = true,
}) {
  final exponent = currencyExponent(currency);
  final negative = amountMinor < 0;
  final absolute = amountMinor.abs();
  final scale = _pow10(exponent);
  final whole = absolute ~/ scale;
  final digits = exponent == 0
      ? ''
      : '.${(absolute % scale).toString().padLeft(exponent, '0')}';
  final amount = '${_groupThousands(whole)}$digits';
  final body = showCurrency
      ? '${currency.toUpperCase()} ${signed && amountMinor > 0 ? '+' : ''}'
            '$amount'
      : '${signed && amountMinor > 0 ? '+' : ''}$amount';
  // The minus leads the whole thing rather than sitting between the code and
  // the digits: "-CHF 12.34" is unambiguous, "CHF -12.34" reads for a beat
  // like a currency called "CHF -".
  return negative ? '-$body' : body;
}

/// The inverse, for text fields: `"12.34"` / `"12,34"` / `"12"` -> `1234`.
///
/// Returns null for anything that isn't a plain non-negative amount, so the
/// caller can keep the save button disabled rather than guessing at what
/// someone half-typed.
int? parseAmountToMinor(String input, String currency) {
  final cleaned = input.trim().replaceAll(',', '.').replaceAll(' ', '');
  if (cleaned.isEmpty) return null;
  if (!RegExp(r'^\d*\.?\d*$').hasMatch(cleaned)) return null;
  final exponent = currencyExponent(currency);
  final parts = cleaned.split('.');
  if (parts.length > 2) return null;
  final wholeText = parts[0].isEmpty ? '0' : parts[0];
  final whole = int.tryParse(wholeText);
  if (whole == null) return null;
  var fractionText = parts.length == 2 ? parts[1] : '';
  // More decimals typed than the currency has: truncate rather than reject,
  // so pasting "12.345" into a CHF field isn't a dead end.
  if (fractionText.length > exponent) {
    fractionText = fractionText.substring(0, exponent);
  }
  fractionText = fractionText.padRight(exponent, '0');
  final fraction = exponent == 0 ? 0 : int.tryParse(fractionText);
  if (fraction == null) return null;
  return whole * _pow10(exponent) + fraction;
}

/// The value a text field should start with when editing an existing amount -
/// unformatted (no grouping, no code), so it round-trips through
/// [parseAmountToMinor] unchanged.
String editableAmount(int amountMinor, String currency) {
  final exponent = currencyExponent(currency);
  final scale = _pow10(exponent);
  final whole = amountMinor.abs() ~/ scale;
  if (exponent == 0) return '$whole';
  final fraction = (amountMinor.abs() % scale).toString().padLeft(
    exponent,
    '0',
  );
  return '$whole.$fraction';
}

int _pow10(int exponent) {
  var result = 1;
  for (var i = 0; i < exponent; i++) {
    result *= 10;
  }
  return result;
}

/// The separator between thousands: U+202F, a narrow no-break space.
///
/// Written as an escape rather than typed, because an invisible character in
/// source silently changes when a file is copied around. No-break matters -
/// `1 234.00` must never wrap across a line - and a space rather than a comma
/// or a point sidesteps the locale argument entirely, since `1,234.00` and
/// `1.234,00` mean different things in different places.
const groupSeparator = '\u202f';

String _groupThousands(int value) {
  final digits = value.toString();
  if (digits.length <= 3) return digits;
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(groupSeparator);
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

/// The codes offered in the ledger's currency picker. Not exhaustive - the
/// field accepts any ISO-4217 code - just the ones worth one tap.
const commonCurrencyCodes = <String>[
  'CHF',
  'EUR',
  'GBP',
  'USD',
  'SEK',
  'NOK',
  'DKK',
  'PLN',
  'CZK',
  'CAD',
  'AUD',
  'NZD',
  'JPY',
];
