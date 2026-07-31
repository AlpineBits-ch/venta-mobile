/// Parsing for every `DateTime` the API hands back.
///
/// The backend is not consistent about time-zone designators: some fields
/// arrive as `2026-07-31T07:09:12.481Z` and others as bare
/// `2026-07-31T07:09:12.481` with nothing on the end. Both are UTC - the
/// second one just doesn't say so.
///
/// [DateTime.parse] reads a designator-less string as *local* time, so the
/// `.toLocal()` every formatter calls is a no-op on those fields and the raw
/// UTC wall-clock is what reaches the screen. On a UTC+2 device that's a
/// timestamp two hours in the past, which is how this was found (a pinned
/// message stamped `7:09 AM` when it was pinned at 09:09).
///
/// Rather than fix the one field that was noticed, every DTO routes its
/// `DateTime`s through [ApiDateTimeConverter] so a designator-less string is
/// always read as UTC - the difference between "the server said Z" and "the
/// server forgot to say Z" is not something a screen should be able to see.
library;

import 'package:json_annotation/json_annotation.dart';

/// Reads an API timestamp, treating a missing time-zone designator as UTC.
///
/// [DateTime.parse] already normalises anything that *does* carry one (`Z` or
/// a `±hh:mm` offset) to a UTC value, so the only case left to handle is the
/// one it hands back in local time.
DateTime parseApiDateTime(String raw) {
  final parsed = DateTime.parse(raw);
  if (parsed.isUtc) return parsed;
  return DateTime.utc(
    parsed.year,
    parsed.month,
    parsed.day,
    parsed.hour,
    parsed.minute,
    parsed.second,
    parsed.millisecond,
    parsed.microsecond,
  );
}

/// Same as [parseApiDateTime] for a value that may be absent.
DateTime? tryParseApiDateTime(Object? raw) {
  if (raw is! String || raw.isEmpty) return null;
  try {
    return parseApiDateTime(raw);
  } on FormatException {
    return null;
  }
}

/// Applied at class level on every DTO that carries a `DateTime`, so
/// `json_serializable` routes both nullable and non-nullable fields through
/// [parseApiDateTime] instead of a bare `DateTime.parse`.
class ApiDateTimeConverter implements JsonConverter<DateTime, String> {
  const ApiDateTimeConverter();

  @override
  DateTime fromJson(String json) => parseApiDateTime(json);

  /// Always designator-carrying on the way out - matches what the hand-written
  /// request bodies (`guild_api`, `household_api`, `auth_api`) already send.
  @override
  String toJson(DateTime object) => object.toUtc().toIso8601String();
}
