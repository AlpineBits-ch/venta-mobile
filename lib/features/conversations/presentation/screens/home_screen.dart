import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/status_colors_extension.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/skeleton_list_tile.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../inbox/presentation/widgets/inbox_app_bar_action.dart';
import '../../bloc/conversation_list_bloc.dart';
import '../../data/conversation_prefs.dart';
import '../../data/conversation_repository.dart';
import '../../data/models/conversation_dto.dart';
import '../widgets/conversation_actions_sheet.dart';
import '../widgets/conversation_icon.dart';
import '../widgets/group_settings_sheet.dart';
import '../widgets/new_conversation_dialog.dart';

/// The default landing surface (Discord mobile's "Home" tab) - rendered as
/// the shell's content pane, next to the always-visible server rail
/// (`AppShell`). Tapping a conversation pushes the full-screen thread route.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ConversationListBloc(repository: getIt()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  String get _myUserId => getIt<AuthRepository>().currentUserId ?? '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: const [InboxAppBarAction()],
      ),
      body: BlocListener<ConversationListBloc, ConversationListState>(
        // Reconciling dismissed unread counts writes, so it can't happen in
        // `build` - a listener runs after the frame that delivered the list.
        listener: (context, state) {
          // Gated on `loaded`: a failed fetch leaves the list empty, and
          // reconciling against that would read as "the server has no unread
          // anywhere" and throw away every mark-as-read on the device.
          if (state.status != ConversationListStatus.loaded) return;
          ConversationPrefs.reconcile({
            for (final conversation in state.conversations)
              conversation.id: _mentionCount(conversation, _myUserId),
          });
        },
        child: BlocBuilder<ConversationListBloc, ConversationListState>(
          builder: (context, state) {
            // Pin/mute/mark-as-read are local prefs, not part of the bloc's
            // state - `revision` is what makes this rebuild when they change.
            return ListenableBuilder(
              listenable: ConversationPrefs.revision,
              builder: (context, _) => _buildList(context, theme, state),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showNewConversationDialog(context),
        child: const Icon(Icons.edit_square),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    ThemeData theme,
    ConversationListState state,
  ) {
    // Pinned first, server order preserved within each group.
    final ordered = [
      ...state.conversations.where((c) => ConversationPrefs.isPinned(c.id)),
      ...state.conversations.where((c) => !ConversationPrefs.isPinned(c.id)),
    ];
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: ListView(
        key: ValueKey(state.status),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: context.statusColors.hover,
              child: Icon(
                Icons.people_alt_rounded,
                color: theme.colorScheme.onSurface,
              ),
            ),
            title: const Text('Friends'),
            onTap: () => context.push(RoutePaths.homeFriends),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              AppSpacing.m,
              16,
              AppSpacing.xs,
            ),
            child: Text('DIRECT MESSAGES', style: theme.textTheme.labelSmall),
          ),
          if (state.status == ConversationListStatus.loading)
            for (var i = 0; i < 6; i++) const SkeletonListTile()
          else if (ordered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Center(
                child: Text(
                  'No conversations yet',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            )
          else
            // NOTE: no last-message preview/timestamp here - ConversationDto
            // carries no such field yet; showing one is blocked on the
            // backend adding it, not a client-side gap.
            for (final conversation in ordered)
              _ConversationTile(
                conversation: conversation,
                myUserId: _myUserId,
              ),
        ],
      ),
    );
  }
}

/// This user's unread-mention count on [conversation], as the server reports
/// it - before any local "mark as read" is applied.
int _mentionCount(ConversationDto conversation, String myUserId) =>
    conversation.members
        .where((m) => m.userId == myUserId)
        .firstOrNull
        ?.mentionCount ??
    0;

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conversation, required this.myUserId});

  final ConversationDto conversation;
  final String myUserId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final others = conversation.members
        .where((m) => m.userId != myUserId)
        .toList();
    final title =
        conversation.name ??
        (others.isEmpty
            ? 'Just you'
            : others.map((m) => m.cachedUserName).join(', '));
    final pinned = ConversationPrefs.isPinned(conversation.id);
    final muted = ConversationPrefs.isMuted(conversation.id);
    final unread = ConversationPrefs.visibleMentionCount(
      conversation.id,
      _mentionCount(conversation, myUserId),
    );

    return ListTile(
      leading: others.length == 1
          ? UserAvatar(
              userId: others.single.userId,
              fallbackLabel: title.isNotEmpty ? title[0].toUpperCase() : '?',
              // `UserAvatar` names DM lists as the case presence is for and
              // this one wasn't opting in, so the Friends screen next door had
              // nothing to be consistent with.
              showStatus: true,
              onTap: () =>
                  context.push(RoutePaths.conversationPath(conversation.id)),
            )
          // A group used to be a grey disc with one arbitrary member's initial
          // on it, which made a list of several of them unreadable. This is
          // the group's own icon when it has one and two member faces when it
          // does not.
          : ConversationIcon(conversation: conversation, myUserId: myUserId),
      title: Text(
        title,
        // Muted rows recede the way Discord's do, so the list reads at a
        // glance without the row disappearing entirely.
        style: muted
            ? TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              )
            : null,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (pinned)
            Icon(
              Icons.push_pin,
              size: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          if (muted)
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.xs),
              child: Icon(
                Icons.notifications_off_outlined,
                size: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xs),
            child: AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: unread > 0 ? 1 : 0,
              curve: Curves.easeOut,
              child: CircleAvatar(
                radius: 10,
                backgroundColor: theme.colorScheme.error,
                child: Text(
                  '$unread',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onError,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      onTap: () => context.push(RoutePaths.conversationPath(conversation.id)),
      onLongPress: () => _showActions(context),
    );
  }

  Future<void> _showActions(BuildContext context) async {
    final action = await showConversationActionsSheet(
      context: context,
      conversation: conversation,
      myUserId: myUserId,
    );
    if (action == null || !context.mounted) return;
    switch (action) {
      case ConversationAction.profile:
        final other = conversation.members
            .where((m) => m.userId != myUserId)
            .firstOrNull;
        if (other != null) {
          context.push(RoutePaths.userProfilePath(other.userId));
        }
      case ConversationAction.groupSettings:
        final left = await showGroupSettingsSheet(
          context: context,
          conversationId: conversation.id,
        );
        // Nothing to do on this screen: leaving drops the row through the
        // repository stream the list is already built from.
        if (left) return;
      case ConversationAction.closeDm:
        await _closeDm(context);
      case ConversationAction.pin:
        ConversationPrefs.togglePinned(conversation.id);
      case ConversationAction.markRead:
        ConversationPrefs.markRead(
          conversation.id,
          _mentionCount(conversation, myUserId),
        );
      case ConversationAction.mute:
        ConversationPrefs.toggleMuted(conversation.id);
    }
  }

  Future<void> _closeDm(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await getIt<ConversationRepository>().close(conversation.id);
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Couldn't close that conversation.")),
      );
    }
  }
}
