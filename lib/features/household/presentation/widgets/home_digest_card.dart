import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/format/date_time_format.dart';
import '../../../../core/routing/household_deep_link.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../guilds/data/models/guild_dto.dart';
import '../../../guilds/data/models/guild_features.dart';
import '../../data/household_repository.dart';
import '../../data/models/digest_dto.dart';
import '../../data/models/maintenance_dto.dart';
import '../../data/models/meal_dto.dart';
import '../../data/money.dart';
import 'household_widgets.dart';

/// The house at a glance, above its channel list: your turn, what's running
/// out, what's waiting on your vote, where you stand in the ledger.
///
/// One request (`GET /guilds/{id}/home`) rather than the six board endpoints -
/// this is a glance, and the boards remain the way to read a whole one. Every
/// row deep-links into the module it came from.
///
/// **A null section means "render nothing".** The server deliberately does not
/// distinguish "the module is off" from "you can see no channel of that type",
/// so neither does this: a section that isn't there simply isn't drawn, and a
/// house with nothing outstanding gets no card at all rather than an empty
/// frame telling it so.
class HomeDigestCard extends StatefulWidget {
  const HomeDigestCard({super.key, required this.guild});

  final GuildDto guild;

  /// Whether this guild could have a digest worth drawing. The endpoint is
  /// harmless on a Community guild - every section comes back null - but there
  /// is no reason to spend a request finding that out.
  ///
  /// [GuildFeature.presence] is in the list because the digest's `away` section
  /// belongs to it, and a house that has only turned Presence on still has
  /// something to say.
  static bool appliesTo(GuildDto guild) =>
      GuildFeature.householdChannelModules.any(guild.hasFeature) ||
      guild.hasFeature(GuildFeature.presence);

  @override
  State<HomeDigestCard> createState() => _HomeDigestCardState();
}

class _HomeDigestCardState extends State<HomeDigestCard> {
  HouseholdDigestDto? _digest;
  StreamSubscription<void>? _eventsSub;
  Timer? _refreshDebounce;

  /// Any module mutation can move the digest, and a busy house can produce a
  /// burst of them (a shopping trip is one tick per item). One revalidation a
  /// couple of seconds behind the last of them is plenty for a glance.
  static const _refreshDelay = Duration(seconds: 2);

  HouseholdRepository get _repository => getIt<HouseholdRepository>();

  @override
  void initState() {
    super.initState();
    // Whatever the last visit left behind renders immediately; the fetch below
    // revalidates it against its ETag and usually comes back `304`.
    _digest = _repository.cachedDigest(widget.guild.id);
    unawaited(_load());
    _eventsSub = _repository.events
        .where((e) => e.stringField('guildId') == widget.guild.id)
        .listen((_) => _scheduleRefresh());
  }

  @override
  void didUpdateWidget(covariant HomeDigestCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.guild.id != widget.guild.id) {
      _digest = _repository.cachedDigest(widget.guild.id);
      unawaited(_load());
    }
  }

  @override
  void dispose() {
    _refreshDebounce?.cancel();
    unawaited(_eventsSub?.cancel());
    super.dispose();
  }

  void _scheduleRefresh() {
    _refreshDebounce?.cancel();
    _refreshDebounce = Timer(_refreshDelay, () => unawaited(_load()));
  }

  Future<void> _load() async {
    try {
      final digest = await _repository.homeDigest(widget.guild.id);
      if (mounted) setState(() => _digest = digest);
    } catch (_) {
      // Ambient information above a channel list. Keeping the last copy - or
      // nothing at all - is far less intrusive than an error banner about a
      // card nobody asked for.
    }
  }

  void _openChannel(String channelId) {
    if (channelId.isEmpty) return;
    context.push(RoutePaths.serverChannelPath(widget.guild.id, channelId));
  }

  @override
  Widget build(BuildContext context) {
    final digest = _digest;
    if (digest == null || digest.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    // Roughly in order of "would somebody get up for this": something broken,
    // money with a date on it, tonight's dinner, then the standing state of the
    // house.
    final rows = <Widget>[
      ..._maintenanceRows(digest.maintenance),
      ..._billRows(digest.bills),
      ..._choreRows(digest.chores),
      ..._mealRows(digest.meals),
      ..._listRows(digest.lists),
      ..._pantryRows(digest.pantry),
      ..._decisionRows(digest.decisions),
      ..._ledgerRows(digest.ledger),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.xs,
        AppSpacing.m,
        AppSpacing.xs,
      ),
      child: HouseCard(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.m,
          AppSpacing.s + 2,
          AppSpacing.m,
          AppSpacing.s,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'THE HOUSE',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            ...rows,
          ],
        ),
      ),
    );
  }

  List<Widget> _choreRows(HouseholdChoresDigestDto? chores) {
    if (chores == null) return const [];
    final rows = <Widget>[];
    for (final occurrence in chores.mine) {
      rows.add(
        _DigestRow(
          icon: Icons.cleaning_services_outlined,
          // "Your turn" is the whole point of the row - the rotation goes to
          // whoever is furthest behind, so this is not simply "next".
          title: occurrence.title,
          subtitle: formatDueLabel(occurrence.dueAt),
          urgent: occurrence.isOverdue,
          onTap: () => _openChannel(occurrence.channelId),
        ),
      );
    }
    // The house's own backlog, not just yours - a flat that is behind is worth
    // seeing even on a day when nothing is your turn.
    final houseOnly = chores.houseOverdueCount - chores.mineOverdueCount;
    if (houseOnly > 0) {
      rows.add(
        _DigestRow(
          icon: Icons.groups_outlined,
          title: '$houseOnly overdue elsewhere in the house',
          subtitle: 'Not yours, but nobody has done them',
        ),
      );
    }
    return rows;
  }

  List<Widget> _listRows(List<HouseholdListDigestDto>? lists) {
    if (lists == null) return const [];
    return [
      for (final list in lists)
        if (list.openCount > 0)
          _DigestRow(
            icon: Icons.checklist_outlined,
            title: '${list.channelName}: ${list.openCount} to get',
            subtitle: list.preview.isEmpty
                ? null
                : list.preview.map((item) => item.text).join(', '),
            onTap: () => _openChannel(list.channelId),
          ),
    ];
  }

  List<Widget> _pantryRows(HouseholdPantryDigestDto? pantry) {
    if (pantry == null || pantry.expiringCount == 0) return const [];
    final soonest = pantry.soonest;
    return [
      _DigestRow(
        icon: Icons.kitchen_outlined,
        title:
            '${pantry.expiringCount} thing'
            '${pantry.expiringCount == 1 ? '' : 's'} to eat soon',
        subtitle: soonest.isEmpty
            ? null
            : soonest.map((item) => item.name).join(', '),
        onTap: soonest.isEmpty
            ? null
            : () => _openChannel(soonest.first.channelId),
      ),
    ];
  }

  List<Widget> _decisionRows(HouseholdDecisionsDigestDto? decisions) {
    if (decisions == null) return const [];
    return [
      for (final decision in decisions.awaitingMyVote)
        _DigestRow(
          icon: Icons.how_to_vote_outlined,
          title: decision.title,
          subtitle: decision.closesAt == null
              ? 'Waiting on your vote'
              : 'Waiting on your vote · closes '
                    '${formatRelativeDateTime(decision.closesAt!)}',
          onTap: () => _openChannel(decision.channelId),
        ),
    ];
  }

  /// Bills, which are obligations rather than history - the amount shown is
  /// the caller's own share, computed server-side. It is **null** when there is
  /// no total to divide yet or when the split no longer resolves, and in that
  /// case nothing numeric is drawn at all: a wrong share on a glance is worse
  /// than a missing one, because it is the figure somebody transfers.
  List<Widget> _billRows(HouseholdBillsDigestDto? bills) {
    if (bills == null) return const [];
    final rows = <Widget>[
      for (final bill in bills.dueSoon)
        _DigestRow(
          icon: Icons.receipt_long_outlined,
          title: bill.myShareMinor == null
              ? bill.description
              : '${bill.description} · '
                    '${formatMinor(bill.myShareMinor!, bill.currency)}',
          subtitle: bill.dueAt == null
              ? 'Coming up'
              : formatDueLabel(bill.dueAt!),
          urgent: bill.dueAt != null && bill.dueAt!.isBefore(DateTime.now()),
          onTap: () => _openBill(bill),
        ),
    ];
    // Counted apart from the overdue ones because the action is different: one
    // needs money moved, the other needs somebody to open the post.
    if (bills.needsAmountCount > 0) {
      rows.add(
        _DigestRow(
          icon: Icons.help_outline_rounded,
          title: bills.needsAmountCount == 1
              ? 'A bill needs an amount'
              : '${bills.needsAmountCount} bills need an amount',
          subtitle: 'Nobody has said what they came to',
        ),
      );
    }
    return rows;
  }

  void _openBill(HouseholdBillDigestEntryDto bill) {
    if (bill.channelId.isEmpty) return;
    context.push(
      bill.id.isEmpty
          ? RoutePaths.serverChannelPath(widget.guild.id, bill.channelId)
          : RoutePaths.serverChannelFocusPath(
              widget.guild.id,
              bill.channelId,
              focusKind: HouseholdFocusKind.bill,
              focusId: bill.id,
            ),
    );
  }

  /// "What are we eating and am I cooking", which is the only meals question a
  /// glance can usefully answer.
  List<Widget> _mealRows(HouseholdMealsDigestDto? meals) {
    if (meals == null || meals.today.isEmpty) return const [];
    return [
      for (final meal in meals.today)
        _DigestRow(
          icon: meal.slot.icon,
          title: meal.title,
          subtitle: meal.cookUserId == null
              ? '${meal.slot.label} · nobody down to cook'
              : meals.imCookingToday && MemberName.isSelf(meal.cookUserId!)
              ? '${meal.slot.label} · you\'re cooking'
              : meal.slot.label,
          onTap: () => _openChannel(meal.channelId),
        ),
    ];
  }

  /// Broken things first. `Broken` and `OutOfService` are not synonyms and only
  /// the first is urgent, which is why the tint follows the reason rather than
  /// the mere fact that something is not `Ok`.
  List<Widget> _maintenanceRows(HouseholdMaintenanceDigestDto? maintenance) {
    if (maintenance == null) return const [];
    return [
      for (final asset in maintenance.attention)
        _DigestRow(
          icon: asset.status == AssetStatus.broken
              ? Icons.report_gmailerrorred_rounded
              : Icons.handyman_outlined,
          title: asset.name,
          subtitle: maintenanceReasonLabel(asset.reason) ?? asset.status.label,
          urgent: asset.reason == 'broken',
          onTap: () => _openAsset(asset),
        ),
    ];
  }

  void _openAsset(HouseholdAssetDigestEntryDto asset) {
    if (asset.channelId.isEmpty) return;
    context.push(
      asset.id.isEmpty
          ? RoutePaths.serverChannelPath(widget.guild.id, asset.channelId)
          : RoutePaths.serverChannelFocusPath(
              widget.guild.id,
              asset.channelId,
              focusKind: HouseholdFocusKind.maintenanceAsset,
              focusId: asset.id,
            ),
    );
  }

  List<Widget> _ledgerRows(List<HouseholdLedgerDigestDto>? ledger) {
    if (ledger == null) return const [];
    return [
      for (final entry in ledger)
        if (entry.myNetMinor != 0)
          _DigestRow(
            icon: Icons.receipt_long_outlined,
            // Positive means the house owes you. Said in words rather than as
            // a signed number, because "-CHF 24.00" leaves people working out
            // which direction it points.
            title: entry.myNetMinor > 0
                ? 'The house owes you '
                      '${formatMinor(entry.myNetMinor, entry.currency)}'
                : 'You owe '
                      '${formatMinor(-entry.myNetMinor, entry.currency)}',
            subtitle: entry.channelName,
            onTap: () => _openChannel(entry.channelId),
          ),
    ];
  }
}

class _DigestRow extends StatelessWidget {
  const _DigestRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.urgent = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  /// Overdue. Tinted rather than badged - the card is a glance, and one red
  /// icon reads faster than a pill on a line that is already two lines tall.
  final bool urgent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final subtitle = this.subtitle;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.chip),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 16,
              color: urgent ? theme.colorScheme.error : muted,
            ),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: urgent ? theme.colorScheme.error : null,
                    ),
                  ),
                  if (subtitle != null && subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(color: muted),
                    ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right, size: 16, color: muted),
          ],
        ),
      ),
    );
  }
}
