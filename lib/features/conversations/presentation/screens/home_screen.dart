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
import '../../bloc/conversation_list_bloc.dart';
import '../../data/models/conversation_dto.dart';
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
      appBar: AppBar(title: const Text('Home')),
      body: BlocBuilder<ConversationListBloc, ConversationListState>(
        builder: (context, state) {
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
                  child: Text(
                    'DIRECT MESSAGES',
                    style: theme.textTheme.labelSmall,
                  ),
                ),
                if (state.status == ConversationListStatus.loading)
                  for (var i = 0; i < 6; i++) const SkeletonListTile()
                else if (state.conversations.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xl,
                    ),
                    child: Center(
                      child: Text(
                        'No conversations yet',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  // NOTE: no last-message preview/timestamp here - ConversationDto
                  // carries no such field yet; showing one is blocked on the
                  // backend adding it, not a client-side gap.
                  for (final conversation in state.conversations)
                    _ConversationTile(
                      conversation: conversation,
                      myUserId: _myUserId,
                    ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showNewConversationDialog(context),
        child: const Icon(Icons.edit_square),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conversation, required this.myUserId});

  final ConversationDto conversation;
  final String myUserId;

  @override
  Widget build(BuildContext context) {
    final others = conversation.members
        .where((m) => m.userId != myUserId)
        .toList();
    final title =
        conversation.name ??
        (others.isEmpty
            ? 'Just you'
            : others.map((m) => m.cachedUserName).join(', '));
    final myMembership = conversation.members
        .where((m) => m.userId == myUserId)
        .firstOrNull;
    final unread = myMembership?.mentionCount ?? 0;

    return ListTile(
      leading: others.length == 1
          ? UserAvatar(
              userId: others.single.userId,
              fallbackLabel: title.isNotEmpty ? title[0].toUpperCase() : '?',
              onTap: () =>
                  context.push(RoutePaths.conversationPath(conversation.id)),
            )
          : CircleAvatar(
              backgroundColor: context.statusColors.hover,
              child: Text(title.isNotEmpty ? title[0].toUpperCase() : '?'),
            ),
      title: Text(title),
      trailing: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: unread > 0 ? 1 : 0,
        curve: Curves.easeOut,
        child: CircleAvatar(
          radius: 10,
          backgroundColor: Theme.of(context).colorScheme.error,
          child: Text(
            '$unread',
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onError,
            ),
          ),
        ),
      ),
      onTap: () => context.push(RoutePaths.conversationPath(conversation.id)),
    );
  }
}
