/// Day-boundary formatting for message timelines.
///
/// Lives here rather than beside the divider that draws it because the rules
/// are all about time rather than about pixels, and getting them wrong is
/// invisible until midnight or a flight: a divider is either in the right place
/// or it silently claims two different days are one.
library;

const _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// Whether two instants fall on the same local calendar day.
///
/// Compared in local time on purpose. The wire carries UTC (see
/// `ApiDateTimeConverter`), and someone who sent a message at 1am cares which
/// day that was *where they are*, not at Greenwich - comparing the UTC dates
/// would put the divider hours away from the boundary the reader lived.
bool isSameLocalDay(DateTime a, DateTime b) {
  final localA = a.toLocal();
  final localB = b.toLocal();
  return localA.year == localB.year &&
      localA.month == localB.month &&
      localA.day == localB.day;
}

/// Formats a day heading as "Today", "Yesterday", "18 August", or
/// "18 August 2026" - the year appears only when it is not the current one,
/// which is what keeps a normal conversation's dividers short.
///
/// Hand-rolled for the same reason `_formatMessageTime` is: `intl` is not a
/// dependency of this project and one heading does not justify making it one.
///
/// [now] is a parameter rather than read here so the caller decides when the
/// relation is resolved, and so this is testable without waiting for midnight.
/// A list built before midnight keeps saying "Today" until its rows rebuild,
/// which is the behaviour to want - silently relabelling a divider under a
/// reader who has not scrolled is worse than being an hour stale.
String formatDayHeading(DateTime date, DateTime now) {
  final local = date.toLocal();
  final localNow = now.toLocal();
  if (isSameLocalDay(local, localNow)) return 'Today';
  // Subtracted from the local wall clock rather than from the raw instant: on
  // a day that changes offset, 24 hours before local midnight is not
  // necessarily yesterday.
  final yesterday = DateTime(
    localNow.year,
    localNow.month,
    localNow.day,
  ).subtract(const Duration(hours: 12));
  if (isSameLocalDay(local, yesterday)) return 'Yesterday';

  final month = _monthNames[local.month - 1];
  return local.year == localNow.year
      ? '${local.day} $month'
      : '${local.day} $month ${local.year}';
}

/// Whether [current] is the first message of a local calendar day, and so
/// should be headed by a divider.
///
/// [olderNeighbour] is the message immediately *before* it in time - which in
/// a `reverse: true` list is the row at the next index, not the previous one.
/// Null means there is no older message loaded, and a divider is drawn: a
/// window that opens mid-conversation should still say which day it opens on,
/// which is also what Alpine does for the first row of its loaded window.
///
/// A message with no timestamp heads nothing. It still breaks the run above it
/// - the caller folds this into its grouping check - but there is no date to
/// head it with, so inventing one would be worse than omitting it.
bool startsNewDay(DateTime? olderNeighbour, DateTime? current) {
  if (current == null) return false;
  if (olderNeighbour == null) return true;
  return !isSameLocalDay(olderNeighbour, current);
}
