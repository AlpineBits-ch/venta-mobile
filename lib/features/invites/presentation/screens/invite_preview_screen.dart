import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../guilds/data/guild_repository.dart';
import '../../../guilds/data/models/invite_dto.dart';

/// Landing target for `venta://invite/{code}` and the in-app "Join a
/// server" flow — previews the invite, then redeems it and navigates
/// straight to the joined server.
class InvitePreviewScreen extends StatefulWidget {
  const InvitePreviewScreen({super.key, required this.code});

  final String code;

  @override
  State<InvitePreviewScreen> createState() => _InvitePreviewScreenState();
}

class _InvitePreviewScreenState extends State<InvitePreviewScreen> {
  InviteDto? _invite;
  String? _error;
  bool _joining = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final invite = await getIt<GuildRepository>().previewInvite(widget.code);
      if (mounted) setState(() => _invite = invite);
    } catch (_) {
      if (mounted) setState(() => _error = 'That invite is invalid or has expired.');
    }
  }

  Future<void> _join() async {
    setState(() => _joining = true);
    try {
      final guild = await getIt<GuildRepository>().redeemInvite(widget.code);
      if (mounted) context.go(RoutePaths.serverPath(guild.id));
    } catch (_) {
      if (mounted) {
        setState(() {
          _joining = false;
          _error = 'Could not join that server.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final invite = _invite;
    return Scaffold(
      appBar: AppBar(title: const Text('Invite')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: _error != null
              ? Text(_error!, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center)
              : invite == null
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.forum_rounded, size: 48, color: theme.colorScheme.primary),
                        const SizedBox(height: AppSpacing.m),
                        Text(
                          invite.guild?.name ?? 'A server on venta',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          "You've been invited to join",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.l),
                        ElevatedButton(
                          onPressed: _joining ? null : _join,
                          child: _joining
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Join Server'),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
