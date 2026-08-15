import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/format/date_time_format.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/load_failure_view.dart';
import '../../../../core/widgets/settings_tiles.dart';
import '../../data/degradation_log.dart';
// Imported for `DegradationReasonX.sentence`, which is an extension and so has
// to come from the library that declares it rather than through the log.
import '../../data/models/entitlement_degradation_dto.dart';
import '../../data/models/entitlement_value.dart';
import '../../data/models/subscription_dto.dart';
import '../../data/plan_repository.dart';

/// "Your plan" - what this account is on, what it includes, which plans exist,
/// and anything that has been reduced this session.
///
/// **Read-only, and read-only on purpose.** There is no plan change, no cancel,
/// no card and no checkout here, and no route to one: no button, no link, no
/// address and no instruction. That is a deliberate compliance posture for a
/// mobile build rather than an unfinished feature.
///
/// **And the screen says nothing about whether another plan could be had.** That
/// is the stronger half of the same constraint and the easier half to break,
/// because breaking it does not take a control - it takes a word. Copy that
/// frames another plan as attainable, a marker that ranks one plan above
/// another, a heading that reads as an offer, or an ordering that reads as a
/// ladder all make the statement a button would make. So: nothing compares two
/// plans, nothing is marked as exceeding anything, every plan row is drawn
/// identically, and the catalogue renders in the order the server sent it. The
/// reader is told which plan is theirs and what each plan includes. Nothing
/// characterises any of it as within reach.
///
/// **No prices either.** The question this answers is what a plan includes, not
/// what it costs, and an amount with nothing to press beside it is the exact
/// shape of the thing the store rules are about. See
/// `billing_catalogue_dto.dart` for where the price fields, the purchasability
/// flags and the operator's own free-text plan descriptions are all dropped on
/// the way in.
///
/// The tests in `test/plan_screen_test.dart` guard all of this three ways: what
/// renders, what is requested, and what the source contains. These are the
/// constraints most likely to be eroded by a well-meaning change later, and a
/// comment does not stop one.
///
/// The whole screen is absent on an instance with no plan catalogue - the
/// settings index does not draw its row - which is why nothing here has an
/// "unavailable" state. A blank plan card is a statement about somebody's
/// account; the absence of the surface is a statement about the instance.
class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  final _repository = getIt<PlanRepository>();
  final _degradations = getIt<DegradationLog>();

  PlanOverview? _overview;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final overview = await _repository.load();
      if (!mounted) return;
      setState(() {
        _overview = overview;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load your plan.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final overview = _overview;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackLocation: RoutePaths.settings),
        title: const Text('Your plan'),
      ),
      body: switch ((_loading, _error, overview)) {
        (true, _, null) => const Center(
          child: CircularProgressIndicator.adaptive(),
        ),
        (_, final String error, null) => LoadFailureView(
          message: error,
          onRetry: _load,
        ),
        (_, _, final PlanOverview loaded) => RefreshIndicator.adaptive(
          onRefresh: _load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.m,
              AppSpacing.m,
              AppSpacing.m,
              AppSpacing.xl,
            ),
            children: _body(loaded),
          ),
        ),
        _ => LoadFailureView(
          message: 'Could not load your plan.',
          onRetry: _load,
        ),
      },
    );
  }

  List<Widget> _body(PlanOverview overview) {
    final catalogue = overview.catalogue;
    final accountOptions = overview.accountPlanOptions;
    final guildPlanName = overview.commonGuildPlanName;
    final guildOptions = overview.guildPlanOptions(guildPlanName);

    return [
      _CurrentPlanCard(overview: overview),
      const SizedBox(height: AppSpacing.l),
      ..._includes(overview),
      _RecentReductions(log: _degradations),
      if (overview.guildPlans.isNotEmpty) ...[
        SettingsSection(
          label: 'Your servers',
          children: [
            for (final guild in overview.guildPlans)
              _GuildPlanRow(guild: guild),
          ],
        ),
        const SettingsFootnote(
          'Only servers you manage or pay for appear here.',
        ),
        const SizedBox(height: AppSpacing.l),
      ],
      // Both lists need the catalogue, and the catalogue is what an instance
      // with no billing service does not have. Absent rather than empty: a
      // heading over nothing reads as "there are none", which is a claim this
      // client is in no position to make.
      //
      // Headings are nouns naming what the list is. "Account plans" describes
      // its contents; anything phrased around the reader - what is open to
      // them, what they are missing - would be an offer written as a heading,
      // which is the same problem as an offer written as a button.
      if (catalogue != null) ...[
        if (accountOptions.length > 1)
          ..._planList(
            label: 'Account plans',
            options: accountOptions,
            footnote: 'What each account plan includes. Yours is marked.',
          ),
        if (guildOptions.length > 1)
          ..._planList(
            label: 'Server plans',
            options: guildOptions,
            footnote: guildPlanName == null
                ? 'What each server plan includes.'
                : 'What each server plan includes. Your servers are on the '
                      'marked one.',
          ),
      ],
    ];
  }

  /// The resolved ceilings for this account.
  ///
  /// Rendered whether or not a plan was named. A snapshot with no plan is a
  /// real state - an instance that configured none, or a self-hosted one where
  /// everything resolves to maximum - and the limits are still the answer to
  /// "what can I do". Inventing a "Free" to head them would put a tier boundary
  /// on the screen of somebody nobody is charging.
  List<Widget> _includes(PlanOverview overview) {
    final keys = overview.accountKeys;
    if (keys.isEmpty) return const [];

    return [
      SettingsSection(
        label: 'What your account includes',
        children: [
          for (final key in keys)
            _ValueRow(
              label: entitlementKeyLabel(key),
              value: describeEntitlementValue(
                key,
                overview.snapshot.entitlements[key],
              ),
            ),
        ],
      ),
      const SizedBox(height: AppSpacing.l),
    ];
  }

  List<Widget> _planList({
    required String label,
    required List<PlanOption> options,
    required String footnote,
  }) => [
    SettingsSection(
      label: label,
      children: [for (final option in options) _PlanCard(option: option)],
    ),
    SettingsFootnote(footnote),
    const SizedBox(height: AppSpacing.l),
  ];
}

/// The lead: which plan this account is on, and anything the subscription needs
/// to say out loud.
class _CurrentPlanCard extends StatelessWidget {
  const _CurrentPlanCard({required this.overview});

  final PlanOverview overview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final plan = overview.accountPlan;
    final subscription = overview.accountSubscription;

    return SettingsSection(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your account',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              // No plan is a real answer and gets a real sentence, not a blank
              // and not an invented tier name.
              plan == null ? 'Standard limits' : plan.displayName,
              style: theme.textTheme.titleMedium,
            ),
            if (plan != null && plan.isGrandfathered) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                // The whole point of pinning somebody to an older version is
                // that their numbers stop moving when the plan's do, and the
                // one thing they are owed is being told so.
                'You are on earlier terms for this plan. Your limits stay as '
                'they are.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
            if (subscription != null)
              ..._subscriptionLines(context, subscription),
          ],
        ),
      ),
    );
  }
}

/// The status, renewal and grace lines shared by the account card and a server
/// row, in that order.
///
/// Grace last and in the error colour: "a payment did not go through" outranks
/// everything else on the card for the one person it applies to, and putting it
/// under the renewal date is what makes it read as the exception rather than as
/// another attribute.
List<Widget> _subscriptionLines(
  BuildContext context,
  SubscriptionDto subscription,
) {
  final theme = Theme.of(context);
  final muted = theme.textTheme.bodySmall?.copyWith(
    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
  );
  final renewal = subscription.renewalLine;
  final grace = subscription.gracePeriodLine;

  return [
    const SizedBox(height: AppSpacing.xs),
    Text(
      subscription.standing.label,
      style: theme.textTheme.labelSmall?.copyWith(
        color: subscription.standing == SubscriptionStanding.attention
            ? theme.colorScheme.error
            : theme.colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
    ),
    if (renewal != null) ...[
      const SizedBox(height: 2),
      Text(renewal, style: muted),
    ],
    if (!subscription.isPayer) ...[
      const SizedBox(height: 2),
      // Said plainly rather than implied, so nobody reads a card they are not
      // paying for as one they are.
      Text('Paid for by someone else.', style: muted),
    ],
    if (grace != null) ...[
      const SizedBox(height: AppSpacing.xs),
      Text(
        grace,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.error,
        ),
      ),
    ],
  ];
}

/// One server and the plan behind it.
class _GuildPlanRow extends StatelessWidget {
  const _GuildPlanRow({required this.guild});

  final GuildPlan guild;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: 14,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(guild.name, style: theme.textTheme.bodyLarge),
              ),
              const SizedBox(width: AppSpacing.s),
              Text(
                guild.subscription.planDisplayName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          ..._subscriptionLines(context, guild.subscription),
        ],
      ),
    );
  }
}

/// One plan in the list, with everything it includes.
///
/// A card per plan rather than a grid of plans against keys, because a table on
/// a handset is a horizontally scrolling table nobody reads.
///
/// **Every card is drawn the same.** Same padding, same type, same colours, no
/// card larger or brighter than another and nothing pinned to the top or the
/// bottom. The only differing mark is the neutral "Current" badge on the plan
/// the reader is already on, which is a fact about them rather than a claim
/// about the rest. Visual emphasis on one plan is how a list becomes a pricing
/// page even with the prices taken out.
///
/// The operator's free-text `description` is not rendered and not modelled -
/// see `billing_catalogue_dto.dart`. It is the one string on this screen that
/// nobody here writes, so it is the one string no test could guard.
class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.option});

  final PlanOption option;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final plan = option.plan;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.m,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  plan.displayName,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              if (option.isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadii.badge),
                  ),
                  child: Text(
                    'Current',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          for (final key in option.keys)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      entitlementKeyLabel(key),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  // Just the value. An earlier draft put an upward arrow beside
                  // every key where this plan granted more than the reader
                  // currently has. It was accurate and it was an offer: an
                  // arrow pointing up next to a plan you are not on says the
                  // same thing a button would, and turned the list into a
                  // ladder. Nothing here marks one plan against another.
                  Text(
                    describeEntitlementValue(key, plan.entitlements[key]),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// One label and one value.
class _ValueRow extends StatelessWidget {
  const _ValueRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: 14,
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
          const SizedBox(width: AppSpacing.s),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

/// What has actually been reduced, since the app opened.
///
/// The only part of this screen about something that happened rather than about
/// something configured. It reports events, in the past tense, and stops there:
/// a request asked for one thing, the server granted another, and this is what
/// applied the limit. It does not say what the limit would have to be for the
/// request to have succeeded whole, does not describe the limit as liftable,
/// and does not measure it against any plan in the lists above. Those sentences
/// are all one clause away and every one of them is an offer.
///
/// Absent when nothing has been reduced, which is the normal case. An empty
/// heading here would imply the app is watching for something and finding none,
/// on a session where nothing that could be reduced was even attempted.
class _RecentReductions extends StatelessWidget {
  const _RecentReductions({required this.log});

  final DegradationLog log;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<ObservedDegradation>>(
      valueListenable: log.entries,
      builder: (context, entries, _) {
        if (entries.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsSection(
              label: entries.length == 1
                  ? 'Recently limited'
                  : 'Recently limited (${entries.length})',
              children: [
                for (final entry in entries) _DegradationRow(observed: entry),
              ],
            ),
            // Worth saying, because a list headed "Recently limited" otherwise
            // reads as a list of failures. These all succeeded.
            const SettingsFootnote(
              'These requests completed with less than they asked for. '
              'Nothing failed.',
            ),
            const SizedBox(height: AppSpacing.l),
          ],
        );
      },
    );
  }
}

/// One reduction: what was limited, where, from what to what, and by what.
class _DegradationRow extends StatelessWidget {
  const _DegradationRow({required this.observed});

  final ObservedDegradation observed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
    );
    final degradation = observed.degradation;
    final surface = observed.surface;
    final change = degradation.change;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: 14,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.trending_down,
            size: 20,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // "Video quality in Voice". The key names what was capped,
                  // and the surface names where - a reduction with neither is a
                  // number floating free of the thing it happened to.
                  surface == null
                      ? entitlementKeyLabel(degradation.key)
                      : '${entitlementKeyLabel(degradation.key)} in $surface',
                  style: theme.textTheme.bodyLarge,
                ),
                if (change != null) ...[
                  const SizedBox(height: 2),
                  Text(change, style: muted),
                ],
                const SizedBox(height: 2),
                Text(
                  degradation.reason.sentence(degradation.boundBy),
                  style: muted,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          Text(formatCompactAgo(observed.observedAt), style: muted),
        ],
      ),
    );
  }
}
