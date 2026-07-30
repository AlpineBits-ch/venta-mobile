import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/guilds/data/guild_repository.dart';
import '../../features/guilds/data/models/guild_dto.dart';
import '../../features/guilds/data/models/guild_template_dto.dart';
import '../../features/guilds/presentation/screens/create_guild_screen.dart';
import '../../features/guild_voice/bloc/guild_voice_cubit.dart';
import '../../features/guild_voice/presentation/widgets/voice_status_bar.dart';
import '../../features/voice/bloc/call_cubit.dart';
import '../../features/voice/presentation/screens/call_screen.dart';
import '../di/injector.dart';
import '../theme/status_colors_extension.dart';
import '../theme/widget_styles.dart';
import '../widgets/connection_status_banner.dart';
import '../widgets/server_rail_icon.dart';
import '../widgets/user_banner.dart';
import 'route_paths.dart';

/// Persistent chrome for the authenticated app: a docked server-icon rail on
/// the left (always visible - Discord mobile does *not* hide this behind a
/// drawer) with the current nav branch's content pane to its right, and the
/// [UserBanner] pinned across the bottom. Tapping into an actual
/// conversation/channel pushes a full-screen route *outside* this shell (see
/// `RoutePaths.conversation`/`.serverChannel` in `app_router.dart`), which is
/// where the back button belongs - going back returns here with the rail and
/// banner still in place, and no screen that needs the vertical space has to
/// opt out of them.
class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.child,
    required this.currentLocation,
  });

  final Widget child;
  final String currentLocation;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  List<GuildDto> _guilds = const [];
  bool _callScreenShown = false;

  @override
  void initState() {
    super.initState();

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
        // A stepped screen rather than a name prompt: the kind picked here
        // seeds the guild's whole module set, so it's worth a screen of its
        // own. It reports its own failures and pops the created guild.
        final guild = await Navigator.of(context, rootNavigator: true)
            .push<GuildDto>(
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => const CreateGuildScreen(),
              ),
            );
        if (guild != null && mounted) {
          context.push(RoutePaths.serverPath(guild.id));
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
      case _TemplateServerAction():
        await _createFromTemplate();
    }
  }

  Future<void> _createFromTemplate() async {
    final templateId = await _promptForText(
      title: 'Create from a template',
      hint: 'Template id',
    );
    if (templateId == null || templateId.trim().isEmpty || !mounted) return;
    GuildTemplateDetailDto template;
    try {
      template = await getIt<GuildRepository>().getTemplate(templateId.trim());
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('That template id doesn\'t look valid.'),
          ),
        );
      }
      return;
    }
    if (!mounted) return;
    final name = await showDialog<String>(
      context: context,
      builder: (context) => _TemplatePreviewDialog(template: template),
    );
    if (name == null || name.trim().isEmpty || !mounted) return;
    try {
      final guild = await getIt<GuildRepository>().useTemplate(
        template.id,
        name: name.trim(),
      );
      if (mounted) context.push(RoutePaths.serverPath(guild.id));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not create that server.')),
        );
      }
    }
  }

  String _extractInviteCode(String input) {
    final match = RegExp(r'invite/([^/?#]+)').firstMatch(input);
    return match?.group(1) ?? input;
  }

  Future<String?> _promptForText({
    required String title,
    required String hint,
  }) {
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
          .push(
            PageRouteBuilder<void>(
              pageBuilder: (_, _, _) => const CallScreen(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          )
          .then((_) => _callScreenShown = false);
    } else if (!shouldShow && _callScreenShown) {
      _callScreenShown = false;
      Navigator.of(context, rootNavigator: true).pop();
    }
    // Shown from the shell's own context, not `CallScreen`'s - its route is
    // being popped in the same beat this fires, so a SnackBar raised from
    // inside it would vanish with the route before anyone saw it.
    final notice = state.disconnectNotice;
    if (notice != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(notice)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onHome = widget.currentLocation.startsWith(RoutePaths.home);
    final currentGuildId = _guildIdFromLocation(widget.currentLocation);

    return BlocListener<CallCubit, CallState>(
      bloc: getIt<CallCubit>(),
      listenWhen: (previous, current) =>
          (previous.phase == CallPhase.idle) !=
          (current.phase == CallPhase.idle),
      listener: _syncCallScreen,
      child: BlocListener<GuildVoiceCubit, GuildVoiceState>(
        bloc: getIt<GuildVoiceCubit>(),
        listenWhen: (previous, current) =>
            current.errorMessage != null &&
            current.errorMessage != previous.errorMessage,
        listener: (context, state) => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.errorMessage!))),
        child: _buildShellScaffold(theme, onHome, currentGuildId),
      ),
    );
  }

  Widget _buildShellScaffold(
    ThemeData theme,
    bool onHome,
    String? currentGuildId,
  ) {
    // The rail and content pane run the *full* height and the banner floats on
    // top of them, so the sidebar tone reaches the bottom edge of the screen
    // instead of stopping short at a seam. Both get bottom padding equal to the
    // card, so it only ever floats over background - never over a list row or
    // the add-server button.
    final bannerInset = UserBanner.heightFor(context);

    return Scaffold(
      body: Column(
        children: [
          const ConnectionStatusBanner(),
          Expanded(
            child: Stack(
              children: [
                _buildRailAndContent(
                  theme,
                  onHome,
                  currentGuildId,
                  bannerInset,
                ),
                // Voice sits *above* the user banner, same as Discord; the
                // banner is the bottom-most thing and owns the bottom inset.
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [VoiceStatusBar(), UserBanner()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRailAndContent(
    ThemeData theme,
    bool onHome,
    String? currentGuildId,
    double bannerInset,
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
                    padding: EdgeInsets.only(bottom: bannerInset),
                    children: [
                      for (final guild in _guilds)
                        ServerRailIcon(
                          selected: guild.id == currentGuildId,
                          label: guild.name.isNotEmpty
                              ? guild.name[0].toUpperCase()
                              : '?',
                          imageUrl: guild.iconUrl,
                          backgroundColor: guild.id == currentGuildId
                              ? theme.colorScheme.primary
                              : null,
                          onTap: () =>
                              context.go(RoutePaths.serverPath(guild.id)),
                        ),
                      ServerRailIcon(
                        icon: Icons.add,
                        onTap: _showAddServerSheet,
                      ),
                    ],
                  ),
                ),
                // No self-avatar down here any more - it moved into the
                // full-width `UserBanner` floating over the bottom of the
                // rail, which has room for the name and status the bare avatar
                // could never show.
              ],
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: bannerInset),
            child: widget.child,
          ),
        ),
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

class _TemplateServerAction extends _AddServerAction {
  const _TemplateServerAction();
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
          ListTile(
            leading: const Icon(Icons.dashboard_customize_outlined),
            title: const Text('Create from a template'),
            onTap: () =>
                Navigator.of(context).pop(const _TemplateServerAction()),
          ),
        ],
      ),
    );
  }
}

/// Shows what a template creates (channel/category tree, role list) before
/// committing, then collects the new server's name - pops that name on
/// "Create", or `null` on cancel.
class _TemplatePreviewDialog extends StatefulWidget {
  const _TemplatePreviewDialog({required this.template});

  final GuildTemplateDetailDto template;

  @override
  State<_TemplatePreviewDialog> createState() => _TemplatePreviewDialogState();
}

class _TemplatePreviewDialogState extends State<_TemplatePreviewDialog> {
  late final _nameController = TextEditingController(
    text: widget.template.name,
  );

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final snapshot = widget.template.snapshot;
    final channelCount =
        snapshot.uncategorizedChannels.length +
        snapshot.categories.fold<int>(
          0,
          (sum, category) => sum + category.channels.length,
        );
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    );
    return AlertDialog(
      title: Text(widget.template.name),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.template.description != null) ...[
              Text(
                widget.template.description!,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.m),
            ],
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.m,
                vertical: AppSpacing.s,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadii.chip),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.dashboard_customize_outlined,
                    size: 18,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: Text(
                      'Creates ${snapshot.categories.length} categories, '
                      '$channelCount channels, ${snapshot.roles.length} roles',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            Text('NEW SERVER NAME', style: labelStyle),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'My New Server'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_nameController.text),
          child: const Text('Create'),
        ),
      ],
    );
  }
}
