import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/load_failure_view.dart';
import '../../../../core/widgets/skeleton_list_tile.dart';
import '../../../guilds/data/guild_repository.dart';
import '../../bloc/inbox_cubit.dart';
import '../../data/models/inbox_mention_dto.dart';
import '../../data/models/inbox_task_dto.dart';
import '../../data/models/inbox_unread_dto.dart';
import '../widgets/inbox_mention_tile.dart';
import '../widgets/inbox_task_tile.dart';
import '../widgets/inbox_unread_card.dart';

/// Unread channels, mentions and household rows waiting on the caller, across
/// every guild they're in - the mobile shape of Discord's inbox popout, as a
/// pushed full-screen route rather than an anchored panel (there is nowhere on
/// a phone to anchor one).
///
/// All three tabs load in parallel and render whichever lands first; none
/// waits on the others. Waiting is its own tab rather than more rows under
/// Unread because a household channel holds no message history and so can
/// never *be* unread.
class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key, this.guildId});

  /// The guild this was opened from, when it was opened from one. Only the
  /// Mentions tab can be scoped to it - "unread" is an account-wide question.
  final String? guildId;

  @override
  Widget build(BuildContext context) {
    final id = guildId;
    return BlocProvider(
      create: (_) => InboxCubit(repository: getIt(), guildId: id),
      child: _InboxView(
        guildId: id,
        // Resolved from the cache rather than passed in as route `extra`:
        // extras don't survive a cold start into a restored location, and the
        // guild whose inbox is open is by definition one the rail just loaded.
        guildName: id == null
            ? null
            : getIt<GuildRepository>().cachedById(id)?.name,
      ),
    );
  }
}

class _InboxView extends StatefulWidget {
  const _InboxView({this.guildId, this.guildName});

  final String? guildId;
  final String? guildName;

  @override
  State<_InboxView> createState() => _InboxViewState();
}

class _InboxViewState extends State<_InboxView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Reachable as the only entry on the stack (a restored route), where
        // Flutter's automatic back arrow silently doesn't appear.
        leading: const AppBackButton(fallbackLocation: RoutePaths.home),
        title: const Text('Inbox'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Unread'),
            Tab(text: 'Mentions'),
            // "Waiting on you" in full is the product's name for it and is
            // what the empty state says; the tab itself has to fit two others
            // beside it on a phone.
            Tab(text: 'Waiting'),
          ],
        ),
        actions: [
          // The filter only means anything to the Mentions tab, so it only
          // appears there rather than sitting greyed out next to Unread.
          AnimatedBuilder(
            animation: _tabs,
            builder: (context, _) => _tabs.index == 1
                ? IconButton(
                    icon: const Icon(Icons.tune),
                    tooltip: 'Filter mentions',
                    onPressed: _showFilters,
                  )
                : const SizedBox.shrink(),
          ),
          // Marking everything read has nothing to do with the Waiting tab -
          // a chore is still your turn afterwards - so it goes away there
          // rather than sitting above a list it cannot clear.
          AnimatedBuilder(
            animation: _tabs,
            builder: (context, _) => _tabs.index == 2
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.done_all),
                    tooltip: 'Mark all as read',
                    onPressed: _confirmMarkAllRead,
                  ),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _UnreadTab(onOpen: _openChannel),
          _MentionsTab(onOpen: _openMention),
          _WaitingTab(onOpen: _openTask),
        ],
      ),
    );
  }

  void _openChannel(InboxUnreadGroupDto group) {
    final breadcrumb = group.breadcrumb;
    if (breadcrumb.guildId.isEmpty || breadcrumb.channelId.isEmpty) return;
    // Acked here as well as by the thread itself: the hub's own
    // `ReadStateChanged` goes to the account's *other* devices, so nothing
    // would come back to tell this list the row is gone.
    unawaited(context.read<InboxCubit>().markGroupRead(group));
    context.push(
      RoutePaths.serverChannelPath(breadcrumb.guildId, breadcrumb.channelId),
    );
  }

  void _openMention(InboxMentionDto mention) {
    final conversationId = mention.conversationId;
    if (mention.isDirectMessage && conversationId != null) {
      context.push(RoutePaths.conversationPath(conversationId));
      return;
    }
    final breadcrumb = mention.breadcrumb;
    if (breadcrumb == null ||
        breadcrumb.guildId.isEmpty ||
        breadcrumb.channelId.isEmpty) {
      return;
    }
    context.push(
      RoutePaths.serverChannelPath(breadcrumb.guildId, breadcrumb.channelId),
    );
  }

  /// Household rows land on their module board rather than at the row itself:
  /// a chore occurrence, a decision and a list item have no route of their own
  /// on this client, and the board opens showing the thing anyway.
  void _openTask(InboxTaskDto task) {
    final breadcrumb = task.breadcrumb;
    if (breadcrumb.guildId.isEmpty) return;
    context.push(
      breadcrumb.channelId.isEmpty
          ? RoutePaths.serverPath(breadcrumb.guildId)
          : RoutePaths.serverChannelPath(
              breadcrumb.guildId,
              breadcrumb.channelId,
            ),
    );
  }

  Future<void> _confirmMarkAllRead() async {
    final cubit = context.read<InboxCubit>();
    final messenger = ScaffoldMessenger.of(context);
    // Confirmed because it is a bulk write across every guild the caller is
    // in, and there is no undo for it.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark everything as read?'),
        content: const Text(
          'Every channel in every server will be marked read. This can\'t be '
          'undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Mark all read'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!await cubit.markAllRead()) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Couldn't mark everything as read.")),
      );
    }
  }

  Future<void> _showFilters() async {
    final cubit = context.read<InboxCubit>();
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (context) => _MentionFiltersSheet(
        filters: cubit.state.filters,
        guildName: widget.guildId == null ? null : widget.guildName,
        onChanged: cubit.setFilters,
      ),
    );
  }
}

class _UnreadTab extends StatelessWidget {
  const _UnreadTab({required this.onOpen});

  final void Function(InboxUnreadGroupDto group) onOpen;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InboxCubit, InboxState>(
      buildWhen: (previous, current) =>
          previous.unreadStatus != current.unreadStatus ||
          previous.groups != current.groups ||
          previous.unreadCursor != current.unreadCursor ||
          previous.loadingMoreUnread != current.loadingMoreUnread ||
          previous.previewsUnavailable != current.previewsUnavailable ||
          previous.markingRead != current.markingRead,
      builder: (context, state) {
        final cubit = context.read<InboxCubit>();
        if (state.unreadStatus == InboxTabStatus.loading) {
          return const _LoadingList();
        }
        if (state.unreadStatus == InboxTabStatus.failed) {
          return LoadFailureView(
            message: "Couldn't load your unread channels.",
            onRetry: cubit.refreshUnread,
          );
        }
        if (state.groups.isEmpty) {
          return RefreshIndicator(
            onRefresh: cubit.refreshUnread,
            child: _EmptyState(
              icon: Icons.done_all,
              title: state.hasMoreUnread
                  ? 'Nothing on this page'
                  : "You're all caught up",
              // An empty page with a cursor still behind it is "keep going",
              // not "you're done" - muting and permission filtering are
              // applied after a page is taken, so several can come back empty
              // in a row. Saying "all caught up" here would be a lie.
              message: state.hasMoreUnread
                  ? 'Muted and hidden channels were filtered out of it.'
                  : 'No unread messages anywhere.',
              action: state.hasMoreUnread
                  ? OutlinedButton(
                      onPressed: state.loadingMoreUnread
                          ? null
                          : cubit.loadMoreUnread,
                      child: const Text('Keep looking'),
                    )
                  : null,
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: cubit.refreshUnread,
          child: _PagingList(
            onEndReached: cubit.loadMoreUnread,
            itemCount:
                state.groups.length +
                (state.previewsUnavailable ? 1 : 0) +
                (state.hasMoreUnread ? 1 : 0),
            itemBuilder: (context, index) {
              var cursor = index;
              if (state.previewsUnavailable) {
                if (cursor == 0) return const _PreviewsUnavailableNotice();
                cursor -= 1;
              }
              if (cursor >= state.groups.length) {
                return _LoadMoreFooter(
                  loading: state.loadingMoreUnread,
                  onPressed: cubit.loadMoreUnread,
                );
              }
              final group = state.groups[cursor];
              return InboxUnreadCard(
                group: group,
                previewsUnavailable: state.previewsUnavailable,
                markingRead: state.markingRead.contains(
                  group.breadcrumb.channelId,
                ),
                onOpen: () => onOpen(group),
                onMarkRead: () => _markRead(context, cubit, group),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _markRead(
    BuildContext context,
    InboxCubit cubit,
    InboxUnreadGroupDto group,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    if (!await cubit.markGroupRead(group)) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Couldn't mark that channel as read.")),
      );
    }
  }
}

class _MentionsTab extends StatelessWidget {
  const _MentionsTab({required this.onOpen});

  final void Function(InboxMentionDto mention) onOpen;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InboxCubit, InboxState>(
      buildWhen: (previous, current) =>
          previous.mentionStatus != current.mentionStatus ||
          previous.mentions != current.mentions ||
          previous.mentionCursor != current.mentionCursor ||
          previous.loadingMoreMentions != current.loadingMoreMentions ||
          previous.dismissing != current.dismissing ||
          previous.hasNewMentions != current.hasNewMentions ||
          previous.filters != current.filters,
      builder: (context, state) {
        final cubit = context.read<InboxCubit>();
        return Column(
          children: [
            if (state.hasNewMentions)
              _NewMentionsBanner(onTap: cubit.refreshMentions),
            Expanded(child: _buildBody(context, cubit, state)),
          ],
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, InboxCubit cubit, InboxState state) {
    if (state.mentionStatus == InboxTabStatus.loading) {
      return const _LoadingList();
    }
    if (state.mentionStatus == InboxTabStatus.failed) {
      return LoadFailureView(
        message: "Couldn't load your mentions.",
        onRetry: cubit.refreshMentions,
      );
    }
    if (state.mentions.isEmpty) {
      return RefreshIndicator(
        onRefresh: cubit.refreshMentions,
        child: _EmptyState(
          icon: Icons.alternate_email,
          title: state.hasMoreMentions
              ? 'Nothing on this page'
              : 'No recent mentions',
          // Worth saying plainly: there is no backfill and the index keeps a
          // rolling 31-day window, so this tab is a recent-activity view and
          // never a complete archive.
          message: state.hasMoreMentions
              ? 'Deleted messages were skipped over.'
              : 'Mentions from the last ${_sinceWords(state.filters.since)} '
                    'show up here.',
          action: state.hasMoreMentions
              ? OutlinedButton(
                  onPressed: state.loadingMoreMentions
                      ? null
                      : cubit.loadMoreMentions,
                  child: const Text('Keep looking'),
                )
              : null,
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: cubit.refreshMentions,
      child: _PagingList(
        onEndReached: cubit.loadMoreMentions,
        itemCount: state.mentions.length + (state.hasMoreMentions ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.mentions.length) {
            return _LoadMoreFooter(
              loading: state.loadingMoreMentions,
              onPressed: cubit.loadMoreMentions,
            );
          }
          final mention = state.mentions[index];
          return InboxMentionTile(
            mention: mention,
            dismissing: state.dismissing.contains(mention.messageId),
            onOpen: () => onOpen(mention),
            onDismiss: () => _dismiss(context, cubit, mention),
          );
        },
      ),
    );
  }

  Future<void> _dismiss(
    BuildContext context,
    InboxCubit cubit,
    InboxMentionDto mention,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    if (!await cubit.dismissMention(mention)) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Couldn't dismiss that mention.")),
      );
    }
  }

  static String _sinceWords(InboxMentionSince since) => switch (since) {
    InboxMentionSince.day => '24 hours',
    InboxMentionSince.week => '7 days',
    InboxMentionSince.month => '30 days',
  };
}

/// Household rows waiting on the caller, across every house they're in.
///
/// A separate tab rather than more entries under Unread, because it answers a
/// different question: a list channel holds no message history and so can never
/// *be* unread, which left the modules people most want reminding about with no
/// inbox presence at all.
class _WaitingTab extends StatelessWidget {
  const _WaitingTab({required this.onOpen});

  final void Function(InboxTaskDto task) onOpen;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InboxCubit, InboxState>(
      buildWhen: (previous, current) =>
          previous.taskStatus != current.taskStatus ||
          previous.tasks != current.tasks ||
          previous.tasksTruncated != current.tasksTruncated,
      builder: (context, state) {
        final cubit = context.read<InboxCubit>();
        if (state.taskStatus == InboxTabStatus.loading) {
          return const _LoadingList();
        }
        if (state.taskStatus == InboxTabStatus.failed) {
          return LoadFailureView(
            message: "Couldn't load what's waiting on you.",
            onRetry: cubit.refreshTasks,
          );
        }
        if (state.tasks.isEmpty) {
          return RefreshIndicator(
            onRefresh: cubit.refreshTasks,
            child: const _EmptyState(
              icon: Icons.home_outlined,
              title: 'Nothing waiting on you',
              message:
                  'Chores, votes and list items with your name on them '
                  'show up here.',
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: cubit.refreshTasks,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
            physics: const AlwaysScrollableScrollPhysics(),
            // No cursor to follow - this is a to-do list, and `truncated` is
            // the whole of what the server will say about the rest.
            itemCount: state.tasks.length + (state.tasksTruncated ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= state.tasks.length) {
                return const _TruncatedNotice();
              }
              final task = state.tasks[index];
              return InboxTaskTile(task: task, onOpen: () => onOpen(task));
            },
          ),
        );
      },
    );
  }
}

/// More was waiting than the endpoint returns. Said plainly rather than as a
/// "load more" that would do nothing - there is no cursor, and the boards
/// themselves are where a whole one is read.
class _TruncatedNotice extends StatelessWidget {
  const _TruncatedNotice();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.s,
        AppSpacing.m,
        AppSpacing.m,
      ),
      child: Text(
        'More is waiting than fits here - open the board to see all of it.',
        textAlign: TextAlign.center,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

/// A list that asks for the next page as its end comes into view, and can
/// still be pull-to-refreshed while empty.
class _PagingList extends StatelessWidget {
  const _PagingList({
    required this.itemCount,
    required this.itemBuilder,
    required this.onEndReached,
  });

  final int itemCount;
  final NullableIndexedWidgetBuilder itemBuilder;
  final VoidCallback onEndReached;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        final metrics = notification.metrics;
        if (metrics.axis == Axis.vertical &&
            metrics.pixels >= metrics.maxScrollExtent - 320) {
          onEndReached();
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: itemBuilder,
      ),
    );
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      children: [
        for (var i = 0; i < 5; i++) const SkeletonListTile(subtitle: true),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    // A ListView rather than a Center so pull-to-refresh still works on an
    // empty tab, which is exactly where somebody would reach for it.
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xl * 2,
      ),
      children: [
        Icon(
          icon,
          size: 44,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
        ),
        const SizedBox(height: AppSpacing.m),
        Text(
          title,
          style: theme.textTheme.titleSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(color: muted),
        ),
        if (action != null) ...[
          const SizedBox(height: AppSpacing.l),
          Center(child: action),
        ],
      ],
    );
  }
}

/// Shown above a perfectly good list of groups whose message bodies didn't
/// arrive. Not an error state: the counts and breadcrumbs come from a
/// different service and are still correct, and `InboxCubit` is already
/// retrying the bodies behind this.
class _PreviewsUnavailableNotice extends StatelessWidget {
  const _PreviewsUnavailableNotice();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.xs,
        AppSpacing.m,
        AppSpacing.s,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.sync_problem_outlined, size: 14, color: muted),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Message previews are taking a moment. Counts and channels are '
              'up to date.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: muted,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A mention arrived while this list was open. A tap-to-refresh pill rather
/// than a splice: the list is keyset-paged and whoever is reading it may be
/// halfway down.
class _NewMentionsBanner extends StatelessWidget {
  const _NewMentionsBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.primary.withValues(alpha: 0.12),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.m,
            vertical: AppSpacing.s,
          ),
          child: Row(
            children: [
              Icon(
                Icons.arrow_upward,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Text(
                  'New mentions',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                'Refresh',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadMoreFooter extends StatelessWidget {
  const _LoadMoreFooter({required this.loading, required this.onPressed});

  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
      child: Center(
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : TextButton(onPressed: onPressed, child: const Text('Load more')),
      ),
    );
  }
}

/// The Mentions tab's filters. Everything here is a query parameter on the
/// mentions endpoint; nothing is filtered client-side, so changing one refetches
/// from page one.
class _MentionFiltersSheet extends StatefulWidget {
  const _MentionFiltersSheet({
    required this.filters,
    required this.onChanged,
    this.guildName,
  });

  final InboxMentionFilters filters;
  final ValueChanged<InboxMentionFilters> onChanged;

  /// Null when the inbox wasn't opened from a guild, which is when scoping to
  /// one has nothing to scope to.
  final String? guildName;

  @override
  State<_MentionFiltersSheet> createState() => _MentionFiltersSheetState();
}

class _MentionFiltersSheetState extends State<_MentionFiltersSheet> {
  late InboxMentionFilters _filters = widget.filters;

  void _update(InboxMentionFilters filters) {
    setState(() => _filters = filters);
    widget.onChanged(filters);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.m,
                AppSpacing.m,
                AppSpacing.m,
                AppSpacing.s,
              ),
              child: Text(
                'Show mentions from',
                style: theme.textTheme.labelSmall,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
              child: Wrap(
                spacing: AppSpacing.s,
                children: [
                  for (final since in InboxMentionSince.values)
                    ChoiceChip(
                      label: Text(since.label),
                      selected: _filters.since == since,
                      onSelected: (_) =>
                          _update(_filters.copyWith(since: since)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            const Divider(height: 1),
            SwitchListTile(
              title: const Text('@everyone'),
              value: _filters.includeEveryone,
              onChanged: (value) =>
                  _update(_filters.copyWith(includeEveryone: value)),
            ),
            SwitchListTile(
              title: const Text('Role mentions'),
              subtitle: const Text(
                'Only roles you already held when the message was sent.',
              ),
              value: _filters.includeRoles,
              onChanged: (value) =>
                  _update(_filters.copyWith(includeRoles: value)),
            ),
            SwitchListTile(
              title: const Text('Direct messages'),
              value: _filters.includeDms,
              onChanged: (value) =>
                  _update(_filters.copyWith(includeDms: value)),
            ),
            if (widget.guildName != null)
              SwitchListTile(
                title: Text('Only ${widget.guildName}'),
                value: _filters.guildScoped,
                onChanged: (value) =>
                    _update(_filters.copyWith(guildScoped: value)),
              ),
            const SizedBox(height: AppSpacing.s),
          ],
        ),
      ),
    );
  }
}
