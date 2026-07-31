import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/status_colors_extension.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../conversations/data/conversation_repository.dart';
import '../../bloc/friends_bloc.dart';
import '../../data/models/relationship_model.dart';
import '../../data/relationship_repository.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final _usernameController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  String get _myUserId => getIt<AuthRepository>().currentUserId ?? '';

  void _submitAddFriend(BuildContext context) {
    final username = _usernameController.text.trim();
    if (username.isEmpty) return;
    context.read<FriendsBloc>().add(FriendAddSubmitted(username));
    _usernameController.clear();
    FocusScope.of(context).unfocus();
  }

  Future<void> _openDirectMessage(
    BuildContext context,
    String otherUserId,
  ) async {
    try {
      final conversation = await getIt<ConversationRepository>()
          .createOrOpenDirectMessage(otherUserId);
      if (context.mounted) {
        context.push(RoutePaths.conversationPath(conversation.id));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not start that conversation.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Friends')),
      body: BlocConsumer<FriendsBloc, FriendsState>(
        listener: (context, state) {
          if (state.actionError != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.actionError!)));
          }
        },
        builder: (context, state) {
          if (state.status == FriendsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.m),
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _usernameController,
                      autocorrect: false,
                      onSubmitted: (_) => _submitAddFriend(context),
                      decoration: const InputDecoration(
                        hintText: 'Add a friend by username',
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  ElevatedButton(
                    onPressed: () => _submitAddFriend(context),
                    child: const Text('Send'),
                  ),
                ],
              ),
              if (state.pendingIncoming.isNotEmpty) ...[
                _SectionHeader('PENDING - ${state.pendingIncoming.length}'),
                for (final r in state.pendingIncoming)
                  _RelationshipTile(
                    relationship: r,
                    myUserId: _myUserId,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.check_circle,
                            color: context.statusColors.online,
                          ),
                          onPressed: () => context.read<FriendsBloc>().add(
                            FriendAcceptRequested(r.id),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.cancel,
                            color: context.statusColors.offline,
                          ),
                          onPressed: () => context.read<FriendsBloc>().add(
                            FriendRejectRequested(r.id),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
              if (state.pendingOutgoing.isNotEmpty) ...[
                _SectionHeader('SENT - ${state.pendingOutgoing.length}'),
                for (final r in state.pendingOutgoing)
                  _RelationshipTile(
                    relationship: r,
                    myUserId: _myUserId,
                    subtitle: 'Pending',
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => context.read<FriendsBloc>().add(
                        FriendRevokeRequested(r.id),
                      ),
                    ),
                  ),
              ],
              _SectionHeader('ALL FRIENDS - ${state.friends.length}'),
              if (state.friends.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: Center(
                    child: Text(
                      'No friends yet - add one above.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ),
                )
              else
                for (final r in state.friends)
                  _RelationshipTile(
                    relationship: r,
                    myUserId: _myUserId,
                    onTap: () => _openDirectMessage(
                      context,
                      r.otherParty(_myUserId).userId,
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, AppSpacing.m, 4, AppSpacing.xs),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

class _RelationshipTile extends StatelessWidget {
  const _RelationshipTile({
    required this.relationship,
    required this.myUserId,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final RelationshipModel relationship;
  final String myUserId;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final other = relationship.otherParty(myUserId);
    return ListTile(
      // The same widget the DM list uses, presence dot included - a friend row
      // and a DM row are the same person one screen apart, and rendering them
      // differently makes the friends list look like it failed to load.
      leading: UserAvatar(
        userId: other.userId,
        fallbackLabel: other.userName,
        showStatus: true,
      ),
      title: Text(other.userName),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
