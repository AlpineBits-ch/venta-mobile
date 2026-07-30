import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/profile/data/models/profile_dto.dart';
import '../../features/profile/presentation/widgets/status_label.dart';
import '../../features/profile/presentation/widgets/status_picker_sheet.dart';
import '../di/injector.dart';
import '../routing/route_paths.dart';
import '../theme/avatar_palette.dart';
import '../theme/hex_color.dart';
import '../theme/status_colors_extension.dart';
import '../theme/widget_styles.dart';
import 'profile_resolver.dart';

/// The signed-in user's permanent footer, Discord-style: avatar with presence
/// ring, name, current status, and a shortcut into settings. Mounted by
/// `AppShell`, which only wraps the browse-level routes (DM list, friends,
/// channel list) - so it disappears on its own the moment you open an actual
/// conversation/channel/settings page, where the vertical space matters more.
///
/// Resolves the profile through [SelfProfileResolver] rather than taking it
/// from the shell: the banner outlives every screen, so it has to pick up
/// avatar/status changes made anywhere in the app.
class UserBanner extends StatelessWidget {
  const UserBanner({super.key});

  /// Fixed content height, enforced below with a [SizedBox] so [heightFor]
  /// stays exact rather than an estimate the layout can drift away from. 48 is
  /// the floor for this row: a 40px avatar plus its 4px breathing room, which is
  /// also the minimum comfortable tap target for the buttons beside it.
  static const _rowHeight = 48.0;

  /// Margins + internal padding around [_rowHeight]: the tightest spacing token
  /// inside the card, no top margin (the shadow already separates it from the
  /// content pane), and one step of clearance above the system gesture bar.
  static const _cardPadding = AppSpacing.xs;
  static const _marginBottom = AppSpacing.s;
  static const _chrome = _cardPadding * 2 + _marginBottom;

  /// Total space the floating card occupies, bottom system inset included.
  /// `AppShell` pads the rail's icon list and the content pane by this much so
  /// the card floats over the shell's own background instead of over something
  /// you needed to see or tap.
  static double heightFor(BuildContext context) =>
      _rowHeight + _chrome + MediaQuery.paddingOf(context).bottom;

  @override
  Widget build(BuildContext context) => SelfProfileResolver(
    builder: (context, profile) => _Banner(profile: profile),
  );
}

class _Banner extends StatelessWidget {
  const _Banner({required this.profile});

  final ProfileDto? profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = profile?.userName ?? '';
    final status = profile?.onlineStatus ?? OnlineStatus.offline;

    // Floats: inset from all three edges with the sidebar/scaffold showing
    // around it, rounded on every corner, lifted by a shadow - a card over the
    // app rather than a strip welded to its bottom. `AppShell` stacks it over
    // the rail and content pane and pads both by [heightFor], so it overlays
    // background only, never a row you needed to reach.
    //
    // Tinted with the user's own accent, like Discord's themed banner - blended
    // into the sidebar tone rather than layered on top, so it stays chrome.
    final accent = profile?.accentColor;
    final background = accent == null
        ? context.statusColors.sidebar
        : Color.alphaBlend(
            parseHexColor(accent).withValues(alpha: 0.22),
            context.statusColors.sidebar,
          );

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.s,
          0,
          AppSpacing.s,
          UserBanner._marginBottom,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadii.dialog),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(UserBanner._cardPadding),
          child: SizedBox(
            height: UserBanner._rowHeight,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadii.card),
                    onTap: () => context.push(RoutePaths.selfProfile),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      child: Row(
                        children: [
                          _PresenceAvatar(
                            profile: profile,
                            status: status,
                            ringColor: background,
                          ),
                          const SizedBox(width: AppSpacing.s),
                          // Flexible, not Expanded: the column shrink-wraps the
                          // name so the chevron sits right beside it (Discord's
                          // layout) instead of drifting to the far edge.
                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name.isEmpty ? 'Your profile' : name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  statusLabel(status),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Its own tap target inside the profile row, the way
                          // Discord splits them: the row opens your profile, the
                          // chevron just flips your presence.
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            tooltip: 'Set status',
                            iconSize: 20,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded),
                            onPressed: () => showStatusPickerSheet(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Compact so it fits the 48px row without forcing Material's
                // default 48px button box past it.
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Settings',
                  icon: const Icon(Icons.settings_outlined, size: 22),
                  onPressed: () => context.push(RoutePaths.settings),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PresenceAvatar extends StatelessWidget {
  const _PresenceAvatar({
    required this.profile,
    required this.status,
    required this.ringColor,
  });

  final ProfileDto? profile;
  final OnlineStatus status;

  /// The card's own (accent-tinted) background, so the dot's ring reads as a
  /// cut-out rather than a mismatched grey circle.
  final Color ringColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatarUrl = profile?.avatarUrl;
    final userName = profile?.userName ?? '';

    return SizedBox(
      width: 44,
      height: 40,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AvatarPalette.colorForUserId(
              profile?.userId ?? getIt<AuthRepository>().currentUserId ?? '',
            ),
            backgroundImage: avatarUrl != null
                ? CachedNetworkImageProvider(avatarUrl)
                : null,
            child: avatarUrl == null
                ? Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          // Always drawn, unlike `StatusDot` - the banner spells the status out
          // in words right beside it, so a missing dot would look broken. The
          // ring matches the card, not the scaffold.
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: statusColor(context, status),
                border: Border.all(color: ringColor, width: 2.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
