import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/guilds/data/guild_repository.dart';
import '../../features/guilds/data/models/guild_dto.dart';
import '../../features/profile/data/models/profile_dto.dart';
import '../../features/profile/data/profile_repository.dart';
import '../../features/guild_voice/presentation/widgets/voice_status_bar.dart';
import '../../features/voice/bloc/call_cubit.dart';
import '../../features/voice/presentation/screens/call_screen.dart';
import '../di/injector.dart';
import '../theme/status_colors_extension.dart';
import '../theme/widget_styles.dart';
import '../widgets/server_rail_icon.dart';
import 'route_paths.dart';

/// Persistent chrome for the authenticated app: a docked server-icon rail on
/// the left (always visible — Discord mobile does *not* hide this behind a
/// drawer) with the current nav branch's content pane to its right. Tapping
/// into an actual conversation/channel pushes a full-screen route *outside*
/// this shell (see `RoutePaths.conversation`/`.serverChannel` in
/// `app_router.dart`), which is where the back button belongs — going back
/// returns here with the rail still in place.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.child, required this.currentLocation});

  final Widget child;
  final String currentLocation;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  ProfileDto? _selfProfile;
  List<GuildDto> _guilds = const [];
  bool _callScreenShown = false;

  @override
  void initState() {
    super.initState();

    final profileRepo = getIt<ProfileRepository>();
    final cachedProfile = profileRepo.cachedSelf;
    if (cachedProfile != null) {
      _selfProfile = cachedProfile;
    } else {
      profileRepo.getSelf().then((profile) {
        if (mounted) setState(() => _selfProfile = profile);
      });
    }

    final guildRepo = getIt<GuildRepository>();
    _guilds = guildRepo.cached;
    guildRepo.guildsStream.listen((guilds) {
      if (mounted) setState(() => _guilds = guilds);
    });
    if (_guilds.isEmpty) {
      guildRepo.fetch().catchError((Object e, StackTrace st) {
        debugPrint('guild fetch failed: $e\n$st');
        return <GuildDto>[];
      });
    }
  }

  Future<void> _showAddServerSheet() async {
    final action = await showModalBottomSheet<_AddServerAction>(
      context: context,
      builder: (context) => const _AddServerSheet(),
    );
    if (!mounted || action == null) return;

    switch (action) {
      case _CreateServerAction():
        final name = await _promptForText(
          title: 'Create a server',
          hint: 'Server name',
        );
        if (name == null || name.trim().isEmpty || !mounted) return;
        try {
          final guild =
              await getIt<GuildRepository>().createGuild(name: name.trim());
          if (mounted) context.push(RoutePaths.serverPath(guild.id));
        } catch (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not create that server.')),
            );
          }
        }
      case _JoinServerAction():
        final input = await _promptForText(
          title: 'Join a server',
          hint: 'Invite code or venta://invite/...',
        );
        if (input == null || input.trim().isEmpty || !mounted) return;
        final code = _extractInviteCode(input.trim());
        try {
          final guild = await getIt<GuildRepository>().redeemInvite(code);
          if (mounted) context.push(RoutePaths.serverPath(guild.id));
        } catch (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('That invite doesn\'t look valid.')),
            );
          }
        }
    }
  }

  String _extractInviteCode(String input) {
    final match = RegExp(r'invite/([^/?#]+)').firstMatch(input);
    return match?.group(1) ?? input;
  }

  Future<String?> _promptForText({required String title, required String hint}) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: hint),
          onSubmitted: (value) => Navigator.of(context).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _syncCallScreen(BuildContext context, CallState state) {
    final shouldShow = state.phase != CallPhase.idle;
    if (shouldShow && !_callScreenShown) {
      _callScreenShown = true;
      Navigator.of(context, rootNavigator: true)
          .push(MaterialPageRoute(builder: (_) => const CallScreen()))
          .then((_) => _callScreenShown = false);
    } else if (!shouldShow && _callScreenShown) {
      _callScreenShown = false;
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onHome = widget.currentLocation.startsWith(RoutePaths.home);
    final currentGuildId = _guildIdFromLocation(widget.currentLocation);
    final profile = _selfProfile;

    return BlocListener<CallCubit, CallState>(
      bloc: getIt<CallCubit>(),
      listenWhen: (previous, current) =>
          (previous.phase == CallPhase.idle) != (current.phase == CallPhase.idle),
      listener: _syncCallScreen,
      child: _buildShellScaffold(theme, onHome, currentGuildId, profile),
    );
  }

  Widget _buildShellScaffold(
    ThemeData theme,
    bool onHome,
    String? currentGuildId,
    ProfileDto? profile,
  ) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: _buildRailAndContent(theme, onHome, currentGuildId, profile)),
          const SafeArea(top: false, child: VoiceStatusBar()),
        ],
      ),
    );
  }

  Widget _buildRailAndContent(
    ThemeData theme,
    bool onHome,
    String? currentGuildId,
    ProfileDto? profile,
  ) {
    return Row(
        children: [
          Container(
            width: 76,
            color: context.statusColors.sidebar,
            child: SafeArea(
              right: false,
              bottom: false,
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.s),
                  ServerRailIcon(
                    selected: onHome,
                    icon: Icons.forum_rounded,
                    backgroundColor: onHome ? theme.colorScheme.primary : null,
                    onTap: () => context.go(RoutePaths.home),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    child: Divider(
                      color: context.statusColors.hover,
                      thickness: 2,
                      indent: 16,
                      endIndent: 16,
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        for (final guild in _guilds)
                          ServerRailIcon(
                            selected: guild.id == currentGuildId,
                            label: guild.name.isNotEmpty ? guild.name[0].toUpperCase() : '?',
                            backgroundColor:
                                guild.id == currentGuildId ? theme.colorScheme.primary : null,
                            onTap: () => context.go(RoutePaths.serverPath(guild.id)),
                          ),
                        ServerRailIcon(icon: Icons.add, onTap: _showAddServerSheet),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
                    child: GestureDetector(
                      onTap: () => context.push(RoutePaths.profileSettings),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: context.statusColors.hover,
                        backgroundImage:
                            profile?.avatarUrl != null ? NetworkImage(profile!.avatarUrl!) : null,
                        child: profile?.avatarUrl == null
                            ? Text(
                                (profile?.userName.isNotEmpty ?? false)
                                    ? profile!.userName[0].toUpperCase()
                                    : '?',
                                style: theme.textTheme.titleSmall,
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: widget.child),
        ],
    );
  }

  String? _guildIdFromLocation(String location) {
    final match = RegExp(r'^/server/([^/]+)').firstMatch(location);
    return match?.group(1);
  }
}

sealed class _AddServerAction {
  const _AddServerAction();
}

class _CreateServerAction extends _AddServerAction {
  const _CreateServerAction();
}

class _JoinServerAction extends _AddServerAction {
  const _JoinServerAction();
}

class _AddServerSheet extends StatelessWidget {
  const _AddServerSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Create a server'),
            onTap: () => Navigator.of(context).pop(const _CreateServerAction()),
          ),
          ListTile(
            leading: const Icon(Icons.link),
            title: const Text('Join a server'),
            onTap: () => Navigator.of(context).pop(const _JoinServerAction()),
          ),
        ],
      ),
    );
  }
}
