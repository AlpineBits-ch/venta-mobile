/// Date/time strings for UI, hand-rolled rather than pulling in `intl` for a
/// handful of call sites - matching the reasoning already used for
/// `ThreadView`'s message-time helper.
library;

const _monthNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// e.g. `3:45 PM`.
String formatTimeOfDay(DateTime dateTime) {
  final local = dateTime.toLocal();
  final hour12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour < 12 ? 'AM' : 'PM';
  return '$hour12:$minute $period';
}

/// e.g. `Jul 30, 3:45 PM` - the list-row format used by events, pins and
/// search results.
String formatShortDateTime(DateTime dateTime) {
  final local = dateTime.toLocal();
  return '${_monthNames[local.month - 1]} ${local.day}, '
      '${formatTimeOfDay(local)}';
}

/// e.g. `now`, `5m`, `3h`, `2d`, `6w` - the terse elapsed-time label forum
/// post cards and similar dense list rows use, where a full timestamp would
/// crowd out the content. Falls back to [formatShortDateTime] past a year.
String formatCompactAgo(DateTime dateTime, {DateTime? now}) {
  final elapsed = (now ?? DateTime.now()).difference(dateTime.toLocal());
  if (elapsed.isNegative || elapsed.inMinutes < 1) return 'now';
  if (elapsed.inHours < 1) return '${elapsed.inMinutes}m';
  if (elapsed.inDays < 1) return '${elapsed.inHours}h';
  if (elapsed.inDays < 7) return '${elapsed.inDays}d';
  if (elapsed.inDays < 365) return '${elapsed.inDays ~/ 7}w';
  return formatShortDateTime(dateTime);
}

/// "due today, 6:00 PM" / "due tomorrow" / "was due 3 days ago" - deadlines as
/// a household board and the inbox's Waiting tab read them, at a glance.
///
/// Says nothing about whether the row is *overdue*: a chore inside its grace
/// period is late without being overdue, and only the server knows the grace.
/// Render this next to the server's own flag, never in place of it.
String formatDueLabel(DateTime dueAt, {DateTime? now}) {
  final reference = (now ?? DateTime.now()).toLocal();
  final local = dueAt.toLocal();
  final days = DateTime(
    local.year,
    local.month,
    local.day,
  ).difference(DateTime(reference.year, reference.month, reference.day)).inDays;
  return switch (days) {
    0 => 'due today, ${formatTimeOfDay(local)}',
    1 => 'due tomorrow',
    -1 => 'was due yesterday',
    < 0 => 'was due ${-days} days ago',
    < 7 => 'due in $days days',
    _ => 'due ${formatShortDateTime(local)}',
  };
}

/// Same as [formatShortDateTime] but collapses to just the time for today's
/// timestamps, so recent rows don't repeat today's date on every line.
String formatRelativeDateTime(DateTime dateTime, {DateTime? now}) {
  final local = dateTime.toLocal();
  final reference = (now ?? DateTime.now()).toLocal();
  final isToday =
      local.year == reference.year &&
      local.month == reference.month &&
      local.day == reference.day;
  return isToday ? formatTimeOfDay(local) : formatShortDateTime(local);
}
