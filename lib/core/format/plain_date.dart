import 'package:json_annotation/json_annotation.dart';

/// A calendar date with no time and no zone - `2026-08-07`.
///
/// Distinct from [DateTime] on purpose. Thursday dinner is Thursday dinner
/// whether your phone is in Zurich or in a departure lounge in Lisbon, and the
/// moment a plain date is carried as an instant it starts moving: midnight UTC
/// renders as the previous evening west of Greenwich, so a week's meal plan
/// silently shifts by a day for anybody travelling. The server sends these as
/// `DateOnly` for the same reason.
class PlainDate implements Comparable<PlainDate> {
  const PlainDate(this.year, this.month, this.day);

  final int year;
  final int month;
  final int day;

  /// The date it is where the reader is standing, which is the only sensible
  /// reading of "today" for a plan somebody cooks from.
  factory PlainDate.today({DateTime? now}) {
    final local = (now ?? DateTime.now()).toLocal();
    return PlainDate(local.year, local.month, local.day);
  }

  factory PlainDate.fromDateTime(DateTime value) {
    final local = value.toLocal();
    return PlainDate(local.year, local.month, local.day);
  }

  /// `2026-08-07`, and also tolerant of a full timestamp, because the same
  /// field is a `DateOnly` on some endpoints and a `DateTimeOffset` on others.
  factory PlainDate.parse(String raw) {
    final datePart = raw.length >= 10 ? raw.substring(0, 10) : raw;
    final parts = datePart.split('-');
    if (parts.length != 3) throw FormatException('Not a plain date', raw);
    return PlainDate(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  static PlainDate? tryParse(Object? raw) {
    if (raw is! String || raw.isEmpty) return null;
    try {
      return PlainDate.parse(raw);
    } on FormatException {
      return null;
    }
  }

  /// Noon rather than midnight, so a `DateTime` derived from this survives a
  /// daylight-saving jump without landing on the day before.
  DateTime toLocalDateTime() => DateTime(year, month, day, 12);

  PlainDate addDays(int days) {
    final shifted = DateTime(year, month, day).add(Duration(days: days));
    return PlainDate(shifted.year, shifted.month, shifted.day);
  }

  int differenceInDays(PlainDate other) => DateTime(
    year,
    month,
    day,
  ).difference(DateTime(other.year, other.month, other.day)).inDays;

  /// `DateTime.weekday` - Monday is 1.
  int get weekday => DateTime(year, month, day).weekday;

  String toIso() =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';

  @override
  int compareTo(PlainDate other) => toIso().compareTo(other.toIso());

  bool operator <(PlainDate other) => compareTo(other) < 0;
  bool operator >(PlainDate other) => compareTo(other) > 0;
  bool operator <=(PlainDate other) => compareTo(other) <= 0;
  bool operator >=(PlainDate other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) =>
      other is PlainDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => toIso();
}

class PlainDateConverter implements JsonConverter<PlainDate, String> {
  const PlainDateConverter();

  @override
  PlainDate fromJson(String json) => PlainDate.parse(json);

  @override
  String toJson(PlainDate object) => object.toIso();
}
