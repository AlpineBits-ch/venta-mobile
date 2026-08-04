import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/format/date_time_format.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/load_failure_view.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../guilds/data/models/guild_features.dart';
import '../../data/household_repository.dart';
import '../../data/models/decision_dto.dart';
import '../widgets/household_widgets.dart';
import 'household_channel_base.dart';

/// A `Decisions` channel.
///
/// **This is not a poll, and none of this file may be built like one.** An
/// option carries when quorum is met and nobody has blocked it; one reasoned
/// block beats any amount of support. Household questions aren't well served
/// by majority rule - the person who has to live with the downside should be
/// able to stop it, and everyone else should be able to read why. So objections
/// are rendered as work to resolve, at the top, with their reasoning, and never
/// as a tally row next to the supports.
class DecisionsChannelScreen extends StatefulWidget {
  const DecisionsChannelScreen({
    super.key,
    required this.guildId,
    required this.channelId,
  });

  final String guildId;
  final String channelId;

  @override
  State<DecisionsChannelScreen> createState() => _DecisionsChannelScreenState();
}

class _DecisionsChannelScreenState
    extends HouseholdChannelState<DecisionsChannelScreen> {
  @override
  String get guildId => widget.guildId;
  @override
  String get channelId => widget.channelId;
  @override
  String get requiredFeature => GuildFeature.decisions;
  @override
  String get fallbackTitle => 'Decisions';

  List<DecisionDto>? _decisions;
  bool _loadFailed = false;
  StreamSubscription<void>? _eventsSub;

  bool get _canCreate => can('CreateDecisions');
  bool get _canVote => can('VoteDecisions');

  @override
  void initState() {
    super.initState();
    _load();
    _eventsSub = household
        .channelEvents(widget.channelId, HouseholdEvents.decisions)
        .listen((_) => _load());
  }

  @override
  void dispose() {
    unawaited(_eventsSub?.cancel());
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final decisions = await api.getDecisions(widget.channelId);
      if (mounted) {
        setState(() {
          _decisions = decisions;
          _loadFailed = false;
        });
      }
    } catch (_) {
      if (mounted && _decisions == null) setState(() => _loadFailed = true);
    }
  }

  Future<DecisionDto?> _reload(String decisionId) async {
    await _load();
    return (_decisions ?? const <DecisionDto>[])
        .where((d) => d.id == decisionId)
        .firstOrNull;
  }

  Future<void> _open(DecisionDto decision) async {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) => DecisionDetailScreen(
          decision: decision,
          canVote: _canVote,
          canClose: _canCreate,
          reload: () => _reload(decision.id),
        ),
      ),
    );
    await _load();
  }

  Future<void> _create() async {
    final created = await showHouseSheet<bool>(
      context: context,
      builder: (_) => _NewDecisionSheet(channelId: widget.channelId),
    );
    if (created == true) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final decisions = _decisions;
    final open = [...?decisions?.where((d) => d.status.isOpen)];
    final settled = [...?decisions?.where((d) => !d.status.isOpen)];

    return Scaffold(
      appBar: buildAppBar(),
      body: !moduleEnabled
          ? buildModuleOff()
          : _loadFailed
          ? LoadFailureView(
              message: 'Couldn\'t load the decisions.',
              onRetry: _load,
            )
          : decisions == null
          ? const Center(child: CircularProgressIndicator())
          : decisions.isEmpty
          ? HouseEmptyState(
              icon: Icons.how_to_vote_outlined,
              title: 'Nothing to decide',
              body: _canCreate
                  ? 'Put a question to the house. Anyone can object with a '
                        'reason, and one objection is enough to stop it - '
                        'this isn\'t majority rule.'
                  : 'Nobody has opened a decision yet.',
              action: _canCreate
                  ? FilledButton(
                      onPressed: _create,
                      child: const Text('Open a decision'),
                    )
                  : null,
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.m,
                  AppSpacing.m,
                  AppSpacing.m,
                  80,
                ),
                children: [
                  if (open.isNotEmpty) ...[
                    const HouseSectionHeader(label: 'Open'),
                    for (final decision in open)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.s),
                        child: _DecisionCard(
                          decision: decision,
                          onTap: () => _open(decision),
                        ),
                      ),
                  ],
                  if (settled.isNotEmpty) ...[
                    const HouseSectionHeader(label: 'Settled'),
                    for (final decision in settled)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.s),
                        child: _DecisionCard(
                          decision: decision,
                          onTap: () => _open(decision),
                        ),
                      ),
                  ],
                ],
              ),
            ),
      floatingActionButton: moduleEnabled && _canCreate
          ? FloatingActionButton(
              onPressed: _create,
              tooltip: 'New decision',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

/// Status colours, in one place so a blocked decision never accidentally reads
/// as a decided one.
Color decisionStatusColor(BuildContext context, DecisionStatus status) {
  final scheme = Theme.of(context).colorScheme;
  return switch (status) {
    DecisionStatus.open => scheme.primary,
    DecisionStatus.decided => scheme.primary,
    DecisionStatus.blocked => scheme.error,
    DecisionStatus.cancelled ||
    DecisionStatus.expired => scheme.onSurface.withValues(alpha: 0.5),
  };
}

class _DecisionCard extends StatelessWidget {
  const _DecisionCard({required this.decision, required this.onTap});

  final DecisionDto decision;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final color = decisionStatusColor(context, decision.status);
    final objections = decision.blocks.length;

    return HouseCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(decision.title, style: theme.textTheme.titleSmall),
              ),
              const SizedBox(width: AppSpacing.s),
              HousePill(label: decision.status.label, color: color),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            [
              '${decision.options.length} '
                  '${decision.options.length == 1 ? 'option' : 'options'}',
              if (decision.quorum != null) 'needs ${decision.quorum} votes',
              if (decision.closesAt != null && decision.status.isOpen)
                'closes ${formatShortDateTime(decision.closesAt!)}',
            ].join(' · '),
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
          ),
          // The single most important thing about a decision that has one.
          if (objections > 0) ...[
            const SizedBox(height: AppSpacing.s),
            Row(
              children: [
                Icon(
                  Icons.report_problem_outlined,
                  size: 14,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    objections == 1
                        ? '1 objection to resolve'
                        : '$objections objections to resolve',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (decision.myVoteKind != null) ...[
            const SizedBox(height: AppSpacing.s),
            HousePill(
              label: switch (decision.myVoteKind!) {
                VoteKind.support => 'You backed an option',
                VoteKind.abstain => 'You abstained',
                VoteKind.block => 'You objected',
              },
              icon: switch (decision.myVoteKind!) {
                VoteKind.support => Icons.thumb_up_outlined,
                VoteKind.abstain => Icons.remove_rounded,
                VoteKind.block => Icons.pan_tool_outlined,
              },
              filled: false,
            ),
          ],
        ],
      ),
    );
  }
}

/// One decision in full: what's being decided, what people have said, and
/// what's standing in the way.
class DecisionDetailScreen extends StatefulWidget {
  const DecisionDetailScreen({
    super.key,
    required this.decision,
    required this.canVote,
    required this.canClose,
    required this.reload,
  });

  final DecisionDto decision;
  final bool canVote;

  /// `CreateDecisions` - opening and closing are the same permission.
  final bool canClose;
  final Future<DecisionDto?> Function() reload;

  @override
  State<DecisionDetailScreen> createState() => _DecisionDetailScreenState();
}

class _DecisionDetailScreenState extends State<DecisionDetailScreen> {
  late DecisionDto _decision = widget.decision;
  bool _busy = false;

  Future<void> _refresh() async {
    final updated = await widget.reload();
    if (updated != null && mounted) setState(() => _decision = updated);
  }

  Future<void> _vote({
    required VoteKind kind,
    String? optionId,
    String? reason,
  }) async {
    if (!widget.canVote || _busy) return;
    setState(() => _busy = true);
    try {
      final updated = await householdApi.vote(
        _decision.id,
        kind: kind,
        optionId: optionId,
        reason: reason,
      );
      if (updated != null && mounted) {
        setState(() => _decision = updated);
      } else {
        await _refresh();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(householdErrorText(error, 'Could not record that.')),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _object({String? optionId}) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => _ObjectionDialog(
        optionTitle: optionId == null
            ? null
            : _decision.options
                  .where((o) => o.id == optionId)
                  .firstOrNull
                  ?.title,
      ),
    );
    if (reason == null || reason.trim().isEmpty) return;
    await _vote(
      kind: VoteKind.block,
      optionId: optionId,
      reason: reason.trim(),
    );
  }

  Future<void> _close() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Close this decision?'),
        content: const Text(
          'It stops taking votes and settles on whatever the votes support - '
          'or on "no agreement" if everything has been objected to.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep it open'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Close it'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _busy = true);
    try {
      final updated = await householdApi.closeDecision(_decision.id);
      if (updated != null && mounted) {
        setState(() => _decision = updated);
      } else {
        await _refresh();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(householdErrorText(error, 'Could not close that.')),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel this decision?'),
        content: const Text(
          'It stays readable, it just stops being live. Nobody has to have '
          'been wrong for a question to be withdrawn.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep it'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Cancel it'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await householdApi.cancelDecision(_decision.id);
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(householdErrorText(error, 'Could not cancel that.')),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final decision = _decision;
    final open = decision.status.isOpen;
    final statusColor = decisionStatusColor(context, decision.status);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Decision'),
        actions: [
          if (widget.canClose && open)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) => switch (value) {
                'close' => unawaited(_close()),
                'cancel' => unawaited(_cancel()),
                _ => null,
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'close', child: Text('Close it now')),
                PopupMenuItem(
                  value: 'cancel',
                  child: Text('Withdraw the question'),
                ),
              ],
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.m,
            AppSpacing.m,
            AppSpacing.m,
            AppSpacing.xl,
          ),
          children: [
            Text(decision.title, style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.s),
            Row(
              children: [
                HousePill(label: decision.status.label, color: statusColor),
                const SizedBox(width: AppSpacing.s),
                Flexible(
                  child: Text(
                    [
                      if (decision.quorum != null)
                        '${decision.quorum} votes needed',
                      if (decision.closesAt != null && open)
                        'closes ${formatShortDateTime(decision.closesAt!)}',
                    ].join(' · '),
                    style: theme.textTheme.bodySmall?.copyWith(color: muted),
                  ),
                ),
              ],
            ),
            if (decision.description?.trim().isNotEmpty ?? false) ...[
              const SizedBox(height: AppSpacing.m),
              Text(decision.description!, style: theme.textTheme.bodyMedium),
            ],
            if (!open) ...[
              const SizedBox(height: AppSpacing.m),
              _OutcomeBanner(decision: decision),
            ],

            // Objections come *before* the options. They're not a counter-tally
            // to be weighed against support - they're the thing that has to be
            // dealt with before anything can carry.
            if (decision.blocks.isNotEmpty) ...[
              HouseSectionHeader(
                label: 'Objections to resolve',
                color: theme.colorScheme.error,
              ),
              for (final block in decision.blocks)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.s),
                  child: _ObjectionCard(
                    block: block,
                    optionTitle: block.optionId == null
                        ? null
                        : decision.options
                              .where((o) => o.id == block.optionId)
                              .firstOrNull
                              ?.title,
                  ),
                ),
            ],

            const HouseSectionHeader(label: 'Options'),
            for (final option in decision.sortedOptions)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s),
                child: _OptionCard(
                  option: option,
                  isMine:
                      decision.myVoteOptionId == option.id &&
                      decision.myVoteKind == VoteKind.support,
                  isOutcome: decision.outcomeOptionId == option.id,
                  onSupport: open && widget.canVote && !_busy
                      ? () => _vote(kind: VoteKind.support, optionId: option.id)
                      : null,
                  onObject: open && widget.canVote && !_busy
                      ? () => _object(optionId: option.id)
                      : null,
                ),
              ),

            if (open && widget.canVote) ...[
              const SizedBox(height: AppSpacing.s),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _busy
                          ? null
                          : () => _vote(kind: VoteKind.abstain),
                      icon: const Icon(Icons.remove_rounded, size: 18),
                      label: const Text('Abstain'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                      ),
                      onPressed: _busy ? null : () => _object(),
                      icon: const Icon(Icons.pan_tool_outlined, size: 18),
                      label: const Text('Object'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                'Supporting picks one option. Objecting stops one - or the '
                'whole question - and needs a reason everyone can read. An '
                'option with objections can\'t carry however much support it '
                'has.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: muted,
                  height: 1.4,
                ),
              ),
            ],
            if (open && !widget.canVote) ...[
              const SizedBox(height: AppSpacing.s),
              Text(
                'You can read this, but you\'re not set up to vote on it.',
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OutcomeBanner extends StatelessWidget {
  const _OutcomeBanner({required this.decision});

  final DecisionDto decision;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = decisionStatusColor(context, decision.status);
    final outcome = decision.options
        .where((o) => o.id == decision.outcomeOptionId)
        .firstOrNull;

    final (icon, title, body) = switch (decision.status) {
      DecisionStatus.decided => (
        Icons.check_circle_outline_rounded,
        outcome == null ? 'Decided' : outcome.title,
        'Quorum was met and nobody objected.',
      ),
      // Not "the least-hated option wins". "We couldn't agree" is a result.
      DecisionStatus.blocked => (
        Icons.block_rounded,
        'No agreement',
        'Every option was objected to, so nothing carries. Talk it through '
            'and open a new one when there\'s something else to put.',
      ),
      DecisionStatus.expired => (
        Icons.hourglass_disabled_outlined,
        'Expired',
        'Not enough people voted before it closed. Abstaining doesn\'t count '
            'toward the quorum.',
      ),
      DecisionStatus.cancelled => (
        Icons.undo_rounded,
        'Withdrawn',
        'The question was taken back.',
      ),
      DecisionStatus.open => (
        Icons.hourglass_empty_rounded,
        'Open',
        'Still being decided.',
      ),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: HouseCard(
        tint: color,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(color: color),
                  ),
                  const SizedBox(height: 2),
                  Text(body, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ObjectionCard extends StatelessWidget {
  const _ObjectionCard({required this.block, required this.optionTitle});

  final DecisionBlockDto block;
  final String? optionTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return HouseCard(
      tint: theme.colorScheme.error,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(userId: block.userId, radius: 10),
              const SizedBox(width: AppSpacing.s),
              Flexible(
                child: MemberName(
                  userId: block.userId,
                  style: theme.textTheme.labelLarge,
                ),
              ),
              Flexible(
                child: Text(
                  optionTitle == null
                      ? ' objects to the whole thing'
                      : ' objects to',
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
          if (optionTitle != null) ...[
            const SizedBox(height: 2),
            Text(
              '“$optionTitle”',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.s),
          Text(block.reason, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.option,
    required this.isMine,
    required this.isOutcome,
    this.onSupport,
    this.onObject,
  });

  final DecisionOptionDto option;
  final bool isMine;
  final bool isOutcome;
  final VoidCallback? onSupport;
  final VoidCallback? onObject;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return HouseCard(
      onTap: option.isBlocked ? null : onSupport,
      tint: option.isBlocked
          ? theme.colorScheme.error
          : isOutcome || isMine
          ? theme.colorScheme.primary
          : null,
      child: Row(
        children: [
          Icon(
            option.isBlocked
                ? Icons.do_not_disturb_on_outlined
                : isMine
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            color: option.isBlocked
                ? theme.colorScheme.error
                : isMine
                ? theme.colorScheme.primary
                : muted,
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  option.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: option.isBlocked ? muted : null,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      option.supportCount == 1
                          ? '1 in favour'
                          : '${option.supportCount} in favour',
                      style: theme.textTheme.labelSmall?.copyWith(color: muted),
                    ),
                    if (option.isBlocked) ...[
                      const SizedBox(width: AppSpacing.s),
                      // Said plainly, because a support count next to a block
                      // is exactly the thing that reads like a poll otherwise.
                      HousePill(
                        label: 'can\'t carry',
                        color: theme.colorScheme.error,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (onObject != null && !option.isBlocked)
            IconButton(
              onPressed: onObject,
              tooltip: 'Object to this one',
              icon: Icon(Icons.pan_tool_outlined, size: 18, color: muted),
            ),
        ],
      ),
    );
  }
}

/// A block without a reason is how a house ends up in a silent standoff, so
/// the reason isn't optional here any more than it is on the server.
class _ObjectionDialog extends StatefulWidget {
  const _ObjectionDialog({required this.optionTitle});

  final String? optionTitle;

  @override
  State<_ObjectionDialog> createState() => _ObjectionDialogState();
}

class _ObjectionDialogState extends State<_ObjectionDialog> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(
        widget.optionTitle == null
            ? 'Object to this decision'
            : 'Object to “${widget.optionTitle}”',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'One objection is enough to stop it. Say why - everyone in the '
            'house will read this, and it\'s what gets resolved.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          TextField(
            controller: _controller,
            autofocus: true,
            minLines: 2,
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'I\'d be the one paying for it',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
          ),
          onPressed: _controller.text.trim().isEmpty
              ? null
              : () => Navigator.of(context).pop(_controller.text),
          child: const Text('Object'),
        ),
      ],
    );
  }
}

class _NewDecisionSheet extends StatefulWidget {
  const _NewDecisionSheet({required this.channelId});

  final String channelId;

  @override
  State<_NewDecisionSheet> createState() => _NewDecisionSheetState();
}

class _NewDecisionSheetState extends State<_NewDecisionSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _optionControllers = [TextEditingController(), TextEditingController()];
  int? _quorum;
  DateTime? _closesAt;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(() => setState(() {}));
    for (final controller in _optionControllers) {
      controller.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (final controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  List<String> get _options => [
    for (final controller in _optionControllers)
      if (controller.text.trim().isNotEmpty) controller.text.trim(),
  ];

  bool get _valid =>
      _titleController.text.trim().isNotEmpty && _options.length >= 2;

  Future<void> _pickCloses() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _closesAt ?? now.add(const Duration(days: 3)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date != null && mounted) setState(() => _closesAt = date);
  }

  Future<void> _save() async {
    if (!_valid) return;
    setState(() => _saving = true);
    try {
      final description = _descriptionController.text.trim();
      await householdApi.createDecision(
        widget.channelId,
        title: _titleController.text.trim(),
        description: description.isEmpty ? null : description,
        options: _options,
        quorum: _quorum,
        closesAt: _closesAt,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            householdErrorText(error, 'Could not open that decision.'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return HouseSheet(
      title: 'Open a decision',
      actionLabel: 'Open it',
      busy: _saving,
      onAction: _valid ? _save : null,
      children: [
        SheetField(
          label: 'The question',
          child: TextField(
            controller: _titleController,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Should we get a dishwasher?',
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        SheetField(
          label: 'Background',
          child: TextField(
            controller: _descriptionController,
            minLines: 2,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Anything people need to know before deciding',
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        SheetField(
          label: 'Options',
          child: Column(
            children: [
              for (var i = 0; i < _optionControllers.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.s),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _optionControllers[i],
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            hintText: switch (i) {
                              0 => 'Yes, and split the cost',
                              1 => 'No',
                              _ => 'Another option',
                            },
                          ),
                        ),
                      ),
                      if (_optionControllers.length > 2)
                        IconButton(
                          onPressed: () => setState(
                            () => _optionControllers.removeAt(i).dispose(),
                          ),
                          icon: const Icon(Icons.close),
                          tooltip: 'Remove',
                        ),
                    ],
                  ),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() {
                    final controller = TextEditingController()
                      ..addListener(() => setState(() {}));
                    _optionControllers.add(controller);
                  }),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Another option'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        SheetField(
          label: 'How many have to vote',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppSpacing.xs,
                children: [
                  ChoiceChip(
                    label: const Text('No minimum'),
                    selected: _quorum == null,
                    onSelected: (_) => setState(() => _quorum = null),
                  ),
                  for (final count in const [2, 3, 4, 5])
                    ChoiceChip(
                      label: Text('$count'),
                      selected: _quorum == count,
                      onSelected: (_) => setState(() => _quorum = count),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Abstentions don\'t count toward this - if it never gets '
                'there, the decision expires rather than carrying.',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        SheetField(
          label: 'Closes',
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickCloses,
                  icon: const Icon(Icons.event_outlined, size: 18),
                  label: Text(
                    _closesAt == null
                        ? 'Leave it open'
                        : formatShortDateTime(_closesAt!).split(',').first,
                  ),
                ),
              ),
              if (_closesAt != null)
                IconButton(
                  onPressed: () => setState(() => _closesAt = null),
                  icon: const Icon(Icons.close),
                  tooltip: 'Clear',
                ),
            ],
          ),
        ),
      ],
    );
  }
}
