import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/hex_color.dart';
import '../../../../core/theme/status_colors_extension.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../conversations/data/conversation_repository.dart';
import '../../../friends/data/models/relationship_model.dart';
import '../../../friends/data/relationship_repository.dart';
import '../../bloc/user_profile_cubit.dart';
import '../../data/models/profile_dto.dart';
import '../../data/profile_repository.dart';

Color _statusDotColor(BuildContext context, OnlineStatus status) => switch (status) {
      OnlineStatus.online => context.statusColors.online,
      OnlineStatus.idle => context.statusColors.idle,
      OnlineStatus.doNotDisturb => context.statusColors.doNotDisturb,
      OnlineStatus.hidden || OnlineStatus.offline => context.statusColors.offline,
    };

String _statusLabel(OnlineStatus status) => switch (status) {
      OnlineStatus.online => 'Online',
      OnlineStatus.idle => 'Idle',
      OnlineStatus.doNotDisturb => 'Do Not Disturb',
      OnlineStatus.hidden => 'Invisible',
      OnlineStatus.offline => 'Offline',
    };

/// Read-only view of *another* user's profile — the counterpart to
/// `ProfileSettingsScreen` (which is self-only and editable). Reached by
/// tapping a `UserAvatar` or a message bubble anywhere in the app.
class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserProfileCubit(
        userId: userId,
        profileRepository: getIt<ProfileRepository>(),
        relationshipRepository: getIt<RelationshipRepository>(),
      ),
      child: _UserProfileView(userId: userId),
    );
  }
}

class _UserProfileView extends StatelessWidget {
  const _UserProfileView({required this.userId});

  final String userId;

  bool get _isSelf => userId == (getIt<AuthRepository>().currentUserId ?? '');

  Future<void> _openDirectMessage(BuildContext context) async {
    try {
      final conversation =
          await getIt<ConversationRepository>().createOrOpenDirectMessage(userId);
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
      appBar: AppBar(title: const Text('Profile')),
      body: BlocConsumer<UserProfileCubit, UserProfileState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          final profile = state.profile;
          if (state.status == UserProfileStatus.loading || profile == null) {
            if (state.status == UserProfileStatus.error) {
              return Center(
                child: Text(
                  'Could not load this profile.',
                  style: theme.textTheme.bodyMedium,
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          }

          final accentColor =
              profile.accentColor != null ? parseHexColor(profile.accentColor!) : theme.colorScheme.primary;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              _BannerAndAvatar(profile: profile, accentColor: accentColor),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(profile.userName, style: theme.textTheme.titleLarge),
                        const SizedBox(width: AppSpacing.s),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _statusDotColor(context, profile.onlineStatus),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _statusLabel(profile.onlineStatus),
                          style: theme.textTheme.labelSmall,
                        ),
                      ],
                    ),
                    if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.l),
                      Text('ABOUT ME', style: theme.textTheme.labelSmall),
                      const SizedBox(height: AppSpacing.s),
                      Text(profile.bio!, style: theme.textTheme.bodyMedium),
                    ],
                    const SizedBox(height: AppSpacing.l),
                    _ActionRow(
                      isSelf: _isSelf,
                      state: state,
                      onMessage: () => _openDirectMessage(context),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.isSelf, required this.state, required this.onMessage});

  final bool isSelf;
  final UserProfileState state;
  final VoidCallback onMessage;

  @override
  Widget build(BuildContext context) {
    if (isSelf) {
      return OutlinedButton.icon(
        onPressed: () => context.push(RoutePaths.profileSettings),
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Edit Profile'),
      );
    }

    final relationship = state.relationship;
    final busy = state.isActionInProgress;
    final cubit = context.read<UserProfileCubit>();

    if (relationship == null) {
      return Wrap(
        spacing: AppSpacing.s,
        children: [
          ElevatedButton.icon(
            onPressed: busy ? null : cubit.sendFriendRequest,
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Add Friend'),
          ),
          OutlinedButton.icon(
            onPressed: onMessage,
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Message'),
          ),
        ],
      );
    }

    return switch (relationship.status) {
      RelationshipStatus.friends => OutlinedButton.icon(
          onPressed: onMessage,
          icon: const Icon(Icons.chat_bubble_outline),
          label: const Text('Message'),
        ),
      RelationshipStatus.pendingIncoming => Wrap(
          spacing: AppSpacing.s,
          children: [
            ElevatedButton.icon(
              onPressed: busy ? null : cubit.acceptRequest,
              icon: const Icon(Icons.check),
              label: const Text('Accept'),
            ),
            OutlinedButton.icon(
              onPressed: busy ? null : cubit.rejectOrRevokeRequest,
              icon: const Icon(Icons.close),
              label: const Text('Decline'),
            ),
          ],
        ),
      RelationshipStatus.pendingOutgoing => OutlinedButton.icon(
          onPressed: busy ? null : cubit.rejectOrRevokeRequest,
          icon: const Icon(Icons.hourglass_empty),
          label: const Text('Cancel Request'),
        ),
      RelationshipStatus.blocked => Text('Blocked', style: Theme.of(context).textTheme.bodyMedium),
    };
  }
}

class _BannerAndAvatar extends StatelessWidget {
  const _BannerAndAvatar({required this.profile, required this.accentColor});

  final ProfileDto profile;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 110,
            width: double.infinity,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.35),
              image: profile.bannerUrl != null
                  ? DecorationImage(image: NetworkImage(profile.bannerUrl!), fit: BoxFit.cover)
                  : null,
            ),
          ),
          Positioned(
            left: AppSpacing.m,
            bottom: 0,
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 4),
                color: context.statusColors.hover,
                image: profile.avatarUrl != null
                    ? DecorationImage(image: NetworkImage(profile.avatarUrl!), fit: BoxFit.cover)
                    : null,
              ),
              child: profile.avatarUrl == null
                  ? Center(
                      child: Text(
                        profile.userName.isNotEmpty ? profile.userName[0].toUpperCase() : '?',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
