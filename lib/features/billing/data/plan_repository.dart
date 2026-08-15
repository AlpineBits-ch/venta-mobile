import 'dart:async';

import 'package:flutter/foundation.dart';

import 'billing_api.dart';
import 'entitlement_api.dart';
import 'models/billing_catalogue_dto.dart';
import 'models/entitlement_snapshot_dto.dart';
import 'models/entitlement_value.dart';
import 'models/subscription_dto.dart';

/// One plan in the catalogue, and what it includes.
///
/// Two fields and a list, and there used to be a third: a set of keys where
/// this plan granted more than the reader currently has. It is gone. Marking
/// one plan as exceeding another presents it as somewhere to move to, which is
/// the statement this platform does not make - and it made the list read as a
/// ladder rather than as a catalogue. [isCurrent] stays because "this is the
/// one you are on" is a fact about the reader, not a claim about the others.
@immutable
class PlanOption {
  const PlanOption({
    required this.plan,
    required this.isCurrent,
    required this.keys,
  });

  final BillingPlanDto plan;

  /// Whether this is the plan the subject is already on.
  final bool isCurrent;

  /// Every key this plan lists, in reading order.
  final List<String> keys;
}

/// One server the reader manages or pays for, and the plan behind it.
@immutable
class GuildPlan {
  const GuildPlan({
    required this.guildId,
    required this.name,
    required this.subscription,
  });

  final String guildId;

  /// The server's own name, resolved from the guild list this app already
  /// holds. Falls back to a description rather than to the raw id: an id is not
  /// something a person can match to a server they are in.
  final String name;

  final SubscriptionDto subscription;
}

/// Everything the plan screen renders, read in one go.
@immutable
class PlanOverview {
  const PlanOverview({
    required this.snapshot,
    required this.catalogue,
    required this.accountSubscription,
    required this.guildPlans,
  });

  /// This account's resolved ceilings and its plan.
  final EntitlementSnapshotDto snapshot;

  /// Null when the billing service is not part of this instance.
  ///
  /// The plan lists are absent in that case rather than empty. An empty plan
  /// list is a statement that this instance has no plans, and "there is no
  /// billing service to ask" is a different statement that happens to look the
  /// same on screen.
  final BillingCatalogueDto? catalogue;

  /// The subscription behind this account, when there is one. Absent for
  /// somebody on the instance's default plan, which is almost everybody: the
  /// free tier is the state a subject is in, not one somebody put them in.
  final SubscriptionDto? accountSubscription;

  /// Servers the reader pays for or manages, with the plan behind each.
  final List<GuildPlan> guildPlans;

  /// The plan this account is on, or null when no plan resolved these numbers.
  EntitlementPlanDto? get accountPlan => snapshot.plan;

  /// Every key on this account's own snapshot, in reading order.
  List<String> get accountKeys =>
      orderEntitlementKeys(snapshot.entitlements.keys);

  /// Account-side plans from the catalogue, current one marked, in catalogue
  /// order.
  ///
  /// Empty when there is no catalogue. Filtered by subject kind because
  /// `free`/`plus`/`pro` are server plans and `free_user`/`venta_plus` are
  /// account plans, and the two describe different things - a server plan
  /// listed under an account would be describing a capability the account
  /// cannot hold.
  List<PlanOption> get accountPlanOptions =>
      _optionsFor(SubjectKinds.user, accountPlan?.name);

  /// Server-side plans from the catalogue, with [currentPlanName] marked.
  ///
  /// Pass null for [currentPlanName] when the reader's servers are not all on
  /// one plan; nothing is marked then.
  List<PlanOption> guildPlanOptions(String? currentPlanName) =>
      _optionsFor(SubjectKinds.guild, currentPlanName);

  /// The one plan every server here is on, or null when they differ or there
  /// are none.
  ///
  /// Which plan the server list marks as current. Null rather than "the first
  /// one": marking one server's plan while the reader is looking at three
  /// servers on two plans is a statement about a server they have not been told
  /// this is about.
  String? get commonGuildPlanName {
    String? name;
    for (final guild in guildPlans) {
      if (guild.subscription.hasEnded) continue;
      final planName = guild.subscription.planName;
      if (name != null && name != planName) return null;
      name = planName;
    }
    return name;
  }

  /// Every plan of one kind, in the order the server sent them.
  ///
  /// No filtering by what the reader has, no re-ordering, and nothing computed
  /// across plans. The list is the catalogue.
  List<PlanOption> _optionsFor(String subjectKind, String? currentPlanName) {
    final plans = catalogue?.plans ?? const <BillingPlanDto>[];
    return [
      for (final plan in plans)
        if (sameSubjectKind(plan.subjectKind, subjectKind))
          PlanOption(
            plan: plan,
            isCurrent: currentPlanName != null && plan.name == currentPlanName,
            keys: orderEntitlementKeys(plan.entitlements.keys),
          ),
    ];
  }
}

/// Reads the plan surface, and answers whether there is one to read.
///
/// **Nothing here can change anything.** There is no create, cancel, resume,
/// change, card or invoice call, and there is no method that returns a URL to
/// somewhere that has one. This platform describes the plan an account is on
/// and the plans that exist, and says nothing about whether or where any of
/// them could be obtained - see the class comment on [BillingApi].
class PlanRepository {
  PlanRepository({
    required this.entitlements,
    required this.billing,
    required this.guildName,
  });

  final EntitlementApi entitlements;
  final BillingApi billing;

  /// Resolves a server's display name from whatever this app already holds, or
  /// null when it holds nothing for that id. A callback rather than a
  /// `GuildRepository` so this stays readable without standing up the guild
  /// stack, and so a server the reader has left does not have to be fetched.
  final String? Function(String guildId) guildName;

  /// Whether this instance has a plan catalogue to describe.
  ///
  /// **Not whether the reader could buy anything.** An earlier version of this
  /// read `upgradesAvailable` off the entitlement snapshot, which is the wire's
  /// own "can anything be purchased here" flag. That made the presence of a
  /// settings row a statement that purchasing was possible for this reader on
  /// this instance - the same class of signal as a button, delivered by a row
  /// existing. What gates the surface now is whether the catalogue answers at
  /// all, which is a fact about the deployment.
  ///
  /// The two differ in exactly one case, and it comes out better: a hosted
  /// instance with Billing deployed but no Stripe key configured. That instance
  /// has plans, publishes them, and cannot take money. The old gate hid the
  /// plan list there; this one shows it, which is right, because the list is a
  /// description of the product and not a shop. Self-hosted instances behave
  /// identically under both - Billing refuses to start and the gateway filters
  /// the route, so the catalogue `404`s and the surface is absent.
  ///
  /// Three states, and the third one matters: `null` is "not asked yet". The
  /// settings index reads this to decide whether to draw its row, and treating
  /// unknown as false is what keeps a failed probe from ever inventing one.
  final ValueNotifier<bool?> available = ValueNotifier<bool?>(null);

  Future<void>? _probe;

  /// Answers [available] if it has not been answered already.
  ///
  /// One `GET` per app run, fired by the settings index and not waited on.
  /// Coalesced, because that index rebuilds on every keystroke in its search
  /// field, and short-circuited once answered.
  ///
  /// Never throws. A probe that fails leaves [available] as it was - `null` on
  /// the first attempt, which hides the row. That is the safe direction: a row
  /// that appears late is a row somebody finds on their second visit, and a row
  /// that appears where there is no catalogue is a plan surface with nothing
  /// behind it.
  Future<void> ensureProbed() {
    final running = _probe;
    if (running != null) return running;
    if (available.value != null) return Future<void>.value();

    final probe = _runProbe();
    _probe = probe;
    return probe.whenComplete(() => _probe = null);
  }

  Future<void> _runProbe() async {
    try {
      await billing.getCatalogue();
      available.value = true;
    } on BillingNotDeployedException {
      // The documented answer on an instance with no billing service, and the
      // only failure that is an answer rather than a failure.
      available.value = false;
    } catch (e) {
      debugPrint('plan catalogue could not be read: $e');
    }
  }

  /// Reads everything the plan screen shows.
  ///
  /// The snapshot is required and the two billing reads are not: an instance
  /// with no billing service still resolves entitlements, and "here is what you
  /// have" is worth rendering without "here is what else exists". A failure to
  /// read the snapshot is a failure to load the screen, and says so.
  ///
  /// Read on every open rather than cached. The entitlements guide asks for a
  /// refetch when a settings screen opens, and the only thing a cache would buy
  /// is the chance to render a plan the account was on last week.
  Future<PlanOverview> load() async {
    final snapshot = await entitlements.getMine();
    final catalogue = await _catalogueOrNull();
    // Same question the probe asks, answered here for free because the screen
    // just asked it. Keeping the two in one place is what stops the settings
    // row and the screen disagreeing about whether this instance has plans.
    available.value = catalogue != null;
    final subscriptions = catalogue == null
        ? const <SubscriptionDto>[]
        : await _subscriptionsOrEmpty();

    return PlanOverview(
      snapshot: snapshot,
      catalogue: catalogue,
      accountSubscription: pickForSubject(
        subscriptions,
        SubjectKinds.user,
        snapshot.subject.id,
      ),
      guildPlans: _guildPlans(subscriptions),
    );
  }

  /// The catalogue, or null when this instance has no billing service.
  ///
  /// A `404` is the documented answer there and is the only one folded into
  /// null. Anything else propagates, so a `500` fails the screen rather than
  /// quietly rendering it as an instance with no plans.
  Future<BillingCatalogueDto?> _catalogueOrNull() async {
    try {
      return await billing.getCatalogue();
    } on BillingNotDeployedException {
      return null;
    }
  }

  /// The subscriptions, or none.
  ///
  /// Only reached once the catalogue answered, so a `404` here is the narrow
  /// case of one route being filtered and the other not. Treated as "no
  /// subscriptions" rather than as "no billing", because the catalogue already
  /// proved otherwise.
  Future<List<SubscriptionDto>> _subscriptionsOrEmpty() async {
    try {
      return await billing.listSubscriptions();
    } on BillingNotDeployedException {
      return const [];
    }
  }

  /// One row per server, preferring a live subscription over an ended one.
  ///
  /// A server can legitimately have both, and the list carries both, so the
  /// rows are built per subject rather than per subscription - otherwise a
  /// server that resubscribed would appear twice, once saying "Ended".
  List<GuildPlan> _guildPlans(List<SubscriptionDto> subscriptions) {
    final ids = <String>[];
    for (final subscription in subscriptions) {
      if (!sameSubjectKind(subscription.subjectKind, SubjectKinds.guild)) {
        continue;
      }
      if (!ids.contains(subscription.subjectId)) {
        ids.add(subscription.subjectId);
      }
    }

    return [
      for (final id in ids)
        if (pickForSubject(subscriptions, SubjectKinds.guild, id)
            case final SubscriptionDto subscription)
          GuildPlan(
            guildId: id,
            name: guildName(id) ?? 'A server you manage',
            subscription: subscription,
          ),
    ];
  }
}
