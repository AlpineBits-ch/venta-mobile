/// Copy for the server-generated join/leave rows.
///
/// Kept verbatim from desktop's locale strings
/// (`MESSAGE.SYSTEM.GUILD_MEMBER_JOIN/LEAVE.*`) so the same server-assigned
/// `systemMessageVariant` index reads identically on both clients - which is
/// also why this lives here rather than beside one of the two widgets that
/// render it (`ThreadView` and the inbox): a second copy of the list is a
/// second chance for the rotations to drift apart.
library;

const _joinVariants = [
  '%USER% joined the server',
  '%USER% just showed up',
  'Welcome, %USER%. Say hi!',
  '%USER% joined. Everyone, look busy!',
  '%USER% slid into the server',
  '%USER% arrived',
  "Glad you're here, %USER%",
  'A wild %USER% appeared',
  '%USER% hopped into the server',
  'Everyone welcome %USER%!',
];

const _leaveVariants = [
  '%USER% left the server',
  '%USER% wandered off',
  '%USER% has left the building',
  '%USER% is gone',
  '%USER% slipped away',
  "%USER% left. We'll miss you!",
  '%USER% has left the party',
  '%USER% disappeared',
  '%USER% said goodbye',
  '%USER% is no longer with us',
];

/// The join/leave line for [variant], with [userName] substituted in.
///
/// A null or out-of-range [variant] falls back to the first phrasing rather
/// than rendering the raw template.
String systemJoinLeaveText({
  required bool leaving,
  required int? variant,
  required String userName,
}) {
  final variants = leaving ? _leaveVariants : _joinVariants;
  final index = variant ?? 0;
  final template = index >= 0 && index < variants.length
      ? variants[index]
      : variants[0];
  return template.replaceAll('%USER%', userName);
}
