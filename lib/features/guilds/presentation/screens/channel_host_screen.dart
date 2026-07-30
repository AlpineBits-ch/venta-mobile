import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/load_failure_view.dart';
import '../../../household/presentation/screens/chores_channel_screen.dart';
import '../../../household/presentation/screens/decisions_channel_screen.dart';
import '../../../household/presentation/screens/ledger_channel_screen.dart';
import '../../../household/presentation/screens/list_channel_screen.dart';
import '../../../household/presentation/screens/pantry_channel_screen.dart';
import '../../data/guild_repository.dart';
import '../../data/models/channel_dto.dart';
import '../../data/models/guild_dto.dart';
import 'channel_screen.dart';
import 'forum_channel_screen.dart';

/// Decides which screen a channel opens into, from its type.
///
/// This exists as a screen rather than a `switch` in the router because the
/// router runs synchronously against whatever [GuildRepository] happens to
/// have cached, and that cache is empty on a cold start into a persisted
/// route, a deep link or a push notification. Guessing wrong there isn't
/// cosmetic: the default guess is a message thread, and a message composer on
/// a shopping list is exactly the failure this indirection exists to prevent.
///
/// So it waits until the channel is actually known, and treats a type it
/// doesn't recognise as inert rather than as text.
class ChannelHostScreen extends StatefulWidget {
  const ChannelHostScreen({
    super.key,
    required this.guildId,
    required this.channelId,
  });

  final String guildId;
  final String channelId;

  @override
  State<ChannelHostScreen> createState() => _ChannelHostScreenState();
}

class _ChannelHostScreenState extends State<ChannelHostScreen> {
  StreamSubscription<List<GuildDto>>? _guildsSub;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _guildsSub = getIt<GuildRepository>().guildsStream.listen((_) {
      if (mounted) setState(() {});
    });
    if (_channel == null) unawaited(_load());
  }

  @override
  void dispose() {
    unawaited(_guildsSub?.cancel());
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loadFailed = false);
    try {
      await getIt<GuildRepository>().fetchGuild(widget.guildId);
    } catch (_) {
      // Falling back to the full list covers the case where this guild isn't
      // reachable on its own but is in the joined list (a stale id in a
      // persisted route, say).
      try {
        await getIt<GuildRepository>().fetch();
      } catch (_) {
        if (mounted) setState(() => _loadFailed = true);
        return;
      }
    }
    if (mounted) setState(() {});
  }

  ChannelDto? get _channel => getIt<GuildRepository>()
      .cachedById(widget.guildId)
      ?.channels
      .where((c) => c.id == widget.channelId)
      .firstOrNull;

  @override
  Widget build(BuildContext context) {
    final channel = _channel;
    if (channel == null) {
      return Scaffold(
        appBar: AppBar(
          leading: AppBackButton(
            fallbackLocation: RoutePaths.serverPath(widget.guildId),
          ),
        ),
        body: _loadFailed
            ? LoadFailureView(
                message: 'Couldn\'t open that channel.',
                onRetry: _load,
              )
            : const Center(child: CircularProgressIndicator()),
      );
    }

    return switch (channel.type) {
      ChannelType.list => ListChannelScreen(
        guildId: widget.guildId,
        channelId: widget.channelId,
      ),
      ChannelType.chores => ChoresChannelScreen(
        guildId: widget.guildId,
        channelId: widget.channelId,
      ),
      ChannelType.ledger => LedgerChannelScreen(
        guildId: widget.guildId,
        channelId: widget.channelId,
      ),
      ChannelType.pantry => PantryChannelScreen(
        guildId: widget.guildId,
        channelId: widget.channelId,
      ),
      ChannelType.decisions => DecisionsChannelScreen(
        guildId: widget.guildId,
        channelId: widget.channelId,
      ),
      // Forum and Media are both post lists, not message threads.
      ChannelType.forum || ChannelType.media => ForumChannelScreen(
        guildId: widget.guildId,
        channelId: widget.channelId,
      ),
      ChannelType.unknown => _UnknownChannelScreen(
        guildId: widget.guildId,
        channel: channel,
      ),
      // Text, Announcement, Voice and a forum post (a Thread) all open the
      // message thread.
      _ => ChannelScreen(
        guildId: widget.guildId,
        channelId: widget.channelId,
      ),
    };
  }
}

/// A channel type this build has never heard of.
///
/// Rendered inert on purpose. The alternative - assuming it's a text channel -
/// puts a composer in front of somebody and posts messages into something
/// that has no message history, and the guide is explicit that this is the
/// failure mode to design against.
class _UnknownChannelScreen extends StatelessWidget {
  const _UnknownChannelScreen({required this.guildId, required this.channel});

  final String guildId;
  final ChannelDto channel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(
          fallbackLocation: RoutePaths.serverPath(guildId),
        ),
        title: Text('#${channel.name}'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.help_outline_rounded,
                size: 44,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
              ),
              const SizedBox(height: AppSpacing.m),
              Text(
                'This app doesn\'t know this kind of channel yet',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Nothing is missing or broken - #${channel.name} just needs a '
                'newer version of the app to open. Everything in it is safe '
                'where it is.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
