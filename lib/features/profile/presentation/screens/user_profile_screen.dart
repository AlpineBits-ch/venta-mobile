import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/network/privacy_refusal.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/hex_color.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/avatar_image.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../conversations/data/conversation_repository.dart';
import '../../../friends/data/models/relationship_model.dart';
import '../../../friends/data/relationship_repository.dart';
import '../../bloc/user_profile_cubit.dart';
import '../../data/models/profile_dto.dart';
import '../../data/models/profile_extras.dart';
import '../../data/profile_repository.dart';
import '../../../support/data/models/report_dto.dart';
import '../../../support/presentation/widgets/report_sheet.dart';
import '../widgets/status_label.dart';

/// Read-only view of *another* user's profile - the counterpart to
/// `SelfProfileScreen`. Reached by tapping a `UserAvatar` or a message bubble
/// anywhere in the app.
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
      final conversation = await getIt<ConversationRepository>()
          .createOrOpenDirectMessage(userId);
      if (context.mounted) {
        context.push(RoutePaths.conversationPath(conversation.id));
      }
    } catch (error) {
      if (!context.mounted) return;
      // A DM policy or a block, told apart from a genuine failure: "Could not
      // start that conversation" reads as breakage, and the user would keep
      // trying. `PrivacyRefusal` deliberately words both refusals the same way.
      final refusal = privacyRefusalOf(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            refusal?.message ?? 'Could not start that conversation.',
          ),
        ),
      );
    }
  }

  Future<void> _confirmBlock(BuildContext context, String userName) async {
    final cubit = context.read<UserProfileCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Block $userName?'),
        content: const Text(
          'They won\'t be able to message you, call you, add you as a friend '
          'or mention you, and you won\'t see them either. They are not told.\n\n'
          'If you are friends, that ends - unblocking later does not bring it '
          'back.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Block'),
          ),
        ],
      ),
    );
    if (confirmed == true) await cubit.block();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackLocation: RoutePaths.home),
        title: const Text('Profile'),
        actions: [
          // In the overflow rather than beside Message: blocking is rare,
          // destructive and easy to hit by accident next to the action people
          // actually came here for.
          if (!_isSelf)
            BlocBuilder<UserProfileCubit, UserProfileState>(
              builder: (context, state) {
                final profile = state.profile;
                if (profile == null) return const SizedBox.shrink();
                return PopupMenuButton<void>(
                  tooltip: 'More',
                  itemBuilder: (context) => [
                    // Block sits above Report, always. Blocking works
                    // immediately and needs nobody; a report is a queue. A menu
                    // that leads with the queue leaves someone waiting on us
                    // while they are still being messaged.
                    PopupMenuItem<void>(
                      enabled: !state.isActionInProgress,
                      onTap: state.isBlocked
                          ? context.read<UserProfileCubit>().unblock
                          : () => _confirmBlock(context, profile.userName),
                      child: Text(
                        state.isBlocked ? 'Unblock' : 'Block',
                        style: state.isBlocked
                            ? null
                            : TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                      ),
                    ),
                    PopupMenuItem<void>(
                      onTap: () => showReportSheet(
                        context,
                        ReportTarget(
                          targetUserId: userId,
                          subjectKind: ReportSubjectKind.user,
                          title: 'Report ${profile.userName}',
                          displayName: profile.userName,
                          // Nothing is attached from here. A profile report has
                          // no conversation around it, and pulling one in
                          // because we happen to have a DM open would upload
                          // messages the user never chose to send.
                        ),
                      ),
                      child: const Text('Report user'),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
      body: BlocConsumer<UserProfileCubit, UserProfileState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
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
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          final accentColor = profile.accentColor != null
              ? parseHexColor(profile.accentColor!)
              : theme.colorScheme.primary;

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
                        Text(
                          profile.userName,
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(width: AppSpacing.s),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: statusColor(context, profile.onlineStatus),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusLabel(profile.onlineStatus),
                          style: theme.textTheme.labelSmall,
                        ),
                      ],
                    ),
                    if (profile.activity?.summary case final String activity)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          activity,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ),
                    if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.l),
                      Text('ABOUT ME', style: theme.textTheme.labelSmall),
                      const SizedBox(height: AppSpacing.s),
                      Text(profile.bio!, style: theme.textTheme.bodyMedium),
                    ],
                    // Each of these renders only when the server sent the key.
                    // A section missing because of the subject's privacy
                    // settings must look like a profile that never had one, not
                    // like an empty one - "no friends in common" is a claim,
                    // and it isn't ours to make.
                    _ProfileFacts(profile: profile),
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

/// The visibility-gated blocks: mutual servers and friends, linked accounts,
/// birthday. Renders nothing at all when the payload carried none of them,
/// which is the normal case for a stranger.
class _ProfileFacts extends StatelessWidget {
  const _ProfileFacts({required this.profile});

  final ProfileDto profile;

  @override
  Widget build(BuildContext context) {
    final sections = <Widget>[
      if (profile.mutualServers case final List<MutualEntry> servers)
        _Facts(
          label: 'SERVERS IN COMMON',
          text: servers.isEmpty
              ? 'None'
              : servers.map((s) => s.name).join(', '),
        ),
      if (profile.mutualFriends case final List<MutualEntry> friends)
        _Facts(
          label: 'FRIENDS IN COMMON',
          text: friends.isEmpty
              ? 'None'
              : friends.map((f) => f.name).join(', '),
        ),
      if (profile.connections case final List<ProfileConnection> connections
          when connections.isNotEmpty)
        _Facts(
          label: 'CONNECTIONS',
          // The tick is the server's `verified`, not a guess from the presence
          // of a link - an unverified connection is a name the account typed.
          text: connections
              .map((c) => '${c.label}${c.verified ? ' ✓' : ''}')
              .join(', '),
        ),
      if (profile.birthday case final String birthday when birthday.isNotEmpty)
        _Facts(label: 'BIRTHDAY', text: birthday),
    ];
    if (sections.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final section in sections) ...[
          const SizedBox(height: AppSpacing.l),
          section,
        ],
      ],
    );
  }
}

class _Facts extends StatelessWidget {
  const _Facts({required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelSmall),
        const SizedBox(height: AppSpacing.s),
        Text(text, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.isSelf,
    required this.state,
    required this.onMessage,
  });

  final bool isSelf;
  final UserProfileState state;
  final VoidCallback onMessage;

  @override
  Widget build(BuildContext context) {
    if (isSelf) {
      return OutlinedButton.icon(
        onPressed: () => context.push(RoutePaths.editProfile),
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Edit Profile'),
      );
    }

    final relationship = state.relationship;
    final busy = state.isActionInProgress;
    final cubit = context.read<UserProfileCubit>();

    // Ahead of every relationship branch: while blocked there is nothing to
    // offer but undoing it, and an Add Friend button the server will always
    // refuse is worse than no button.
    if (state.isBlocked) {
      return Row(
        children: [
          OutlinedButton.icon(
            onPressed: busy ? null : cubit.unblock,
            icon: const Icon(Icons.block),
            label: const Text('Unblock'),
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(
              'Blocked',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      );
    }

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
      RelationshipStatus.blocked => Text(
        'Blocked',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
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
                  ? DecorationImage(
                      image: NetworkImage(profile.bannerUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
          ),
          Positioned(
            left: AppSpacing.m,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 4,
                ),
              ),
              child: AvatarImage(
                userId: profile.userId,
                imageUrl: profile.avatarUrl,
                label: profile.userName,
                radius: 44,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
