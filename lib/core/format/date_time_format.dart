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
