import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/avatar_palette.dart';
import '../../../../core/theme/hex_color.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/settings_tiles.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../friends/data/models/relationship_model.dart';
import '../../../friends/data/relationship_repository.dart';
import '../../bloc/self_profile_cubit.dart';
import '../../data/models/profile_dto.dart';
import '../widgets/status_label.dart';
import '../widgets/status_picker_sheet.dart';

/// Your own profile as *other people* see it, plus the entry points to change
/// it. Deliberately read-only: every editing control lives in
/// `EditProfileScreen` behind the "Edit Profile" button, and everything that
/// isn't your profile at all (password, 2FA, notifications, theme) lives in
/// `SettingsScreen` behind the gear - the split Discord uses, and the reason
/// this page can stay short enough to take in at a glance.
class SelfProfileScreen extends StatelessWidget {
  const SelfProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // The banner image runs up under the status bar; the close/gear buttons
      // float on top of it rather than in an opaque app bar.
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: _GlassButton(
          icon: Icons.close,
          tooltip: 'Close',
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(RoutePaths.home),
        ),
        actions: [
          _GlassButton(
            icon: Icons.settings_outlined,
            tooltip: 'Settings',
            onPressed: () => context.push(RoutePaths.settings),
          ),
          const SizedBox(width: AppSpacing.s),
        ],
      ),
      body: BlocConsumer<SelfProfileCubit, SelfProfileState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          final profile = state.profile;
          if (profile == null) {
            if (state.status == SelfProfileStatus.error) {
              return Center(
                child: Text(
                  'Could not load your profile.',
                  style: theme.textTheme.bodyMedium,
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          }

          final accentColor = profile.accentColor != null
              ? parseHexColor(profile.accentColor!)
              : theme.colorScheme.primary;

          return ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            children: [
              _ProfileHeader(profile: profile, accentColor: accentColor),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.userName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    // Tapping the status line is the same menu as the banner's
                    // chevron - the fastest thing people change on this page.
                    InkWell(
                      borderRadius: BorderRadius.circular(AppRadii.chip),
                      onTap: () => showStatusPickerSheet(context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xs,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: statusColor(
                                  context,
                                  profile.onlineStatus,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              statusLabel(profile.onlineStatus),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonalIcon(
                        onPressed: () => context.push(RoutePaths.editProfile),
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Edit Profile'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    if ((profile.bio ?? '').isNotEmpty) ...[
                      SettingsSection(
                        label: 'About Me',
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.m),
                          child: Text(
                            profile.bio!,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.m),
                    ],
                    const _FriendsCard(),
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

/// Friend count with a stack of their avatars, tapping through to the friends
/// list. The only "social" card here with real data behind it - Discord's
/// Connections/Orbs/Member-Since cards have no venta equivalent yet.
class _FriendsCard extends StatefulWidget {
  const _FriendsCard();

  @override
  State<_FriendsCard> createState() => _FriendsCardState();
}

class _FriendsCardState extends State<_FriendsCard> {
  List<RelationshipModel> _relationships = const [];

  @override
  void initState() {
    super.initState();
    final repository = getIt<RelationshipRepository>();
    _relationships = repository.cached;
    if (_relationships.isEmpty) {
      repository.fetch().then<void>((list) {
        if (mounted) setState(() => _relationships = list);
      }, onError: (Object e) => debugPrint('relationship fetch failed: $e'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final myUserId = getIt<AuthRepository>().currentUserId ?? '';
    final friends = _relationships
        .where((r) => r.status == RelationshipStatus.friends)
        .toList();

    // `go`, not `push`: /home/friends lives inside the shell, and pushing it on
    // top of this (non-shell) route would instantiate a second AppShell reusing
    // the shell Navigator's GlobalKey - Navigator asserts on the duplicate key.
    // Replacing the stack is also what you want here: you end up in the friends
    // browser with the rail, not with a profile buried underneath it.
    void openFriends() => context.go(RoutePaths.homeFriends);

    return SettingsSection(
      child: SettingsRow(
        icon: Icons.people_alt_outlined,
        title: 'Friends',
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final friend in friends.take(4))
              Padding(
                padding: const EdgeInsets.only(left: 2),
                child: UserAvatar(
                  userId: friend.otherParty(myUserId).userId,
                  radius: 14,
                  onTap: openFriends,
                ),
              ),
            const SizedBox(width: AppSpacing.s),
            Text('${friends.length}'),
          ],
        ),
        onTap: openFriends,
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile, required this.accentColor});

  final ProfileDto profile;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Banner reaches behind the app bar, so its height has to include the
    // status-bar inset or the avatar collides with the close button.
    final bannerHeight = 180 + MediaQuery.paddingOf(context).top;

    return SizedBox(
      height: bannerHeight + 44,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: bannerHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.35),
              image: profile.bannerUrl != null
                  ? DecorationImage(
                      image: CachedNetworkImageProvider(profile.bannerUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(AppRadii.dialog),
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.m,
            bottom: 0,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.scaffoldBackgroundColor,
                      width: 5,
                    ),
                    color: AvatarPalette.colorForUserId(profile.userId),
                    image: profile.avatarUrl != null
                        ? DecorationImage(
                            image: CachedNetworkImageProvider(
                              profile.avatarUrl!,
                            ),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: profile.avatarUrl == null
                      ? Center(
                          child: Text(
                            profile.userName.isNotEmpty
                                ? profile.userName[0].toUpperCase()
                                : '?',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        )
                      : null,
                ),
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusColor(context, profile.onlineStatus),
                      border: Border.all(
                        color: theme.scaffoldBackgroundColor,
                        width: 4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Circular translucent icon button for use on top of the banner image, where
/// a bare icon can land on any color the user uploaded.
class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.black.withValues(alpha: 0.4),
        shape: const CircleBorder(),
        child: IconButton(
          tooltip: tooltip,
          icon: Icon(icon, color: Colors.white, size: 20),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
