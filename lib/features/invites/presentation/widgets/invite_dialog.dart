import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../guilds/data/guild_api.dart';
import '../../../guilds/data/guild_repository.dart';
import '../../../guilds/data/models/invite_dto.dart';
import '../../../guilds/data/models/welcome_screen_dto.dart';

enum _DialogState { loading, ready, joining, joined, error }

/// Modal invite popup - landing target for `venta://invite/{code}`, shown
/// via `showDialog` from the app-level deep link listener (see `app.dart`).
/// Mirrors desktop's `InviteDialogComponent` exactly: same states
/// (loading/ready/joining/joined/error), same guild icon+name+description
/// layout, same "Dismiss" / "Join Server" footer.
class InviteDialog extends StatefulWidget {
  const InviteDialog({super.key, required this.code});

  final String code;

  @override
  State<InviteDialog> createState() => _InviteDialogState();
}

class _InviteDialogState extends State<InviteDialog> {
  InviteDto? _invite;
  _DialogState _state = _DialogState.loading;
  bool _iconFailed = false;
  String? _joinError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final invite = await getIt<GuildRepository>().previewInvite(widget.code);
      if (!mounted) return;
      setState(() {
        _invite = invite;
        _state = _DialogState.ready;
      });
    } catch (_) {
      if (mounted) setState(() => _state = _DialogState.error);
    }
  }

  Future<void> _join() async {
    if (_state == _DialogState.joining) return;
    setState(() {
      _state = _DialogState.joining;
      _joinError = null;
    });
    try {
      final guild = await getIt<GuildRepository>().redeemInvite(widget.code);
      if (!mounted) return;
      setState(() => _state = _DialogState.joined);
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      Navigator.of(context).pop();
      context.push(RoutePaths.serverPath(guild.id));
    } on VerificationLevelNotMetException catch (e) {
      if (mounted) {
        setState(() {
          _state = _DialogState.ready;
          _joinError =
              'This server requires ${_verificationRequirementText(e.requiredLevel)} to join.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _state = _DialogState.ready;
          _joinError = 'Could not join server. Try again.';
        });
      }
    }
  }

  void _dismiss() {
    if (_state == _DialogState.joining) return;
    Navigator.of(context).pop();
  }

  String? _iconUrl(String guildId) =>
      getIt<ApiClient>().url('/api/v1/guild/guilds/$guildId/icon');

  String _initials(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    return words.take(2).map((w) => w.isEmpty ? '' : w[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: _state != _DialogState.joining,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.dialog),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius: BorderRadius.circular(AppRadii.chip),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.groups_outlined,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Text('Server Invite', style: theme.textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: AppSpacing.l),
                Center(child: _buildBody(theme)),
                if (_joinError != null) ...[
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    _joinError!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.l),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _state == _DialogState.joining
                          ? null
                          : _dismiss,
                      child: const Text('Dismiss'),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    if (_state != _DialogState.error &&
                        _invite?.state != InviteState.expired)
                      _buildActionButton(theme),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    switch (_state) {
      case _DialogState.loading:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(AppRadii.dialog),
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Container(
              width: 140,
              height: 16,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(AppRadii.badge),
              ),
            ),
          ],
        );
      case _DialogState.error:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadii.dialog),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.error_outline,
                size: 32,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              'Invalid Invite',
              style: theme.textTheme.titleSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'This invite link is invalid or has expired.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      case _DialogState.ready:
      case _DialogState.joining:
      case _DialogState.joined:
        final invite = _invite!;
        final guild = invite.guild;
        final iconUrl = guild != null ? _iconUrl(guild.id) : null;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppRadii.dialog),
              ),
              alignment: Alignment.center,
              child: iconUrl != null && !_iconFailed
                  ? CachedNetworkImage(
                      imageUrl: iconUrl,
                      fit: BoxFit.cover,
                      width: 64,
                      height: 64,
                      errorWidget: (context, url, error) {
                        WidgetsBinding.instance.addPostFrameCallback(
                          (_) => setState(() => _iconFailed = true),
                        );
                        return const SizedBox.shrink();
                      },
                    )
                  : Text(
                      _initials(guild?.name ?? '?'),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              guild?.name ?? 'Unknown Server',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (guild?.description != null &&
                guild!.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                guild.description!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (invite.state == InviteState.expired) ...[
              const SizedBox(height: 6),
              Text(
                'Invite expired',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            ..._buildWelcomeScreen(theme, invite.welcomeScreen),
          ],
        );
    }
  }

  /// The guild's welcome splash, carried on the invite preview because the
  /// welcome-screen endpoint itself is members-only and whoever is reading
  /// this isn't one yet.
  ///
  /// Only the highlight's own description and emoji are shown: the payload
  /// carries channel *ids*, and a non-member has no way to resolve those to
  /// names.
  List<Widget> _buildWelcomeScreen(ThemeData theme, WelcomeScreenDto? screen) {
    if (screen == null || !screen.enabled) return const [];
    final channels = [...screen.channels]
      ..sort((a, b) => a.position.compareTo(b.position));
    final description = screen.description?.trim();
    if ((description == null || description.isEmpty) && channels.isEmpty) {
      return const [];
    }

    return [
      const SizedBox(height: AppSpacing.m),
      if (description != null && description.isNotEmpty)
        Text(
          description,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
      if (channels.isNotEmpty) ...[
        const SizedBox(height: AppSpacing.s),
        for (final channel in channels)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadii.chip),
              ),
              child: Row(
                children: [
                  if (channel.emoji != null && channel.emoji!.isNotEmpty) ...[
                    Text(channel.emoji!, style: const TextStyle(fontSize: 15)),
                    const SizedBox(width: 6),
                  ] else ...[
                    Icon(
                      Icons.tag,
                      size: 15,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Expanded(
                    child: Text(
                      channel.description,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    ];
  }

  Widget _buildActionButton(ThemeData theme) {
    if (_state == _DialogState.joined) {
      return FilledButton.icon(
        onPressed: null,
        icon: const Icon(Icons.check, size: 16),
        label: const Text('Joined'),
      );
    }
    return FilledButton(
      onPressed: _state == _DialogState.loading ? null : _join,
      child: _state == _DialogState.joining
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.onPrimary,
              ),
            )
          : const Text('Join Server'),
    );
  }
}

/// Turns a `requiredLevel` wire value (`"Low"`/`"Medium"`/`"High"`) into the
/// plain-language requirement it maps to - see the guild verification-level
/// spec's join-gating table.
String _verificationRequirementText(String requiredLevel) =>
    switch (requiredLevel) {
      'Low' => 'a verified email',
      'Medium' => 'a verified email and an account at least 5 minutes old',
      'High' => 'a verified email and an account at least 10 minutes old',
      _ => 'additional account verification',
    };
