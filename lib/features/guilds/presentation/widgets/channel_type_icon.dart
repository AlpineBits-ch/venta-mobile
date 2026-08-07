import 'package:flutter/material.dart';

import '../../data/models/channel_dto.dart';

/// The glyph in front of a channel's name, wherever one is listed - the guild
/// sidebar, the inbox, anything else naming a channel it isn't inside.
///
/// Lives here rather than on [ChannelType] itself so the DTO layer stays free
/// of Material imports, and in one place rather than per-screen so a household
/// channel doesn't pick up a `#` on the surface that forgot about it.
IconData channelTypeIcon(ChannelType type) => switch (type) {
  ChannelType.voice => Icons.volume_up_outlined,
  ChannelType.forum => Icons.forum_outlined,
  ChannelType.media => Icons.perm_media_outlined,
  ChannelType.announcement => Icons.campaign_outlined,
  // Household channels hold rows, not messages - a `#` in front of a shopping
  // list would promise a conversation that isn't there.
  ChannelType.list => Icons.checklist_rounded,
  ChannelType.chores => Icons.cleaning_services_outlined,
  ChannelType.ledger => Icons.account_balance_wallet_outlined,
  ChannelType.pantry => Icons.kitchen_outlined,
  ChannelType.decisions => Icons.how_to_vote_outlined,
  ChannelType.meals => Icons.restaurant_outlined,
  ChannelType.maintenance => Icons.handyman_outlined,
  ChannelType.unknown => Icons.help_outline_rounded,
  // Text and Thread.
  _ => Icons.tag,
};
