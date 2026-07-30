import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../messaging/bloc/message_thread_bloc.dart';
import '../../../messaging/data/message_api.dart';
import '../../../messaging/data/message_repository.dart';
import '../../../messaging/presentation/widgets/thread_view.dart';
import '../../data/guild_repository.dart';
import '../../data/models/guild_dto.dart';

/// Full-screen channel thread - reuses `ThreadView`/`MessageThreadBloc`
/// unchanged from DM messaging, just constructed with `channelId` instead
/// of `conversationId`. This is the shared-kernel decision from the Phase 1
/// plan paying off in Phase 2.
///
/// Normally `AppShell` has already primed [GuildRepository]'s cache by the
/// time this is pushed (it's the *first* thing rendered after the server
/// rail). But this route also gets reached directly - a cold start restoring
/// straight into a channel (see `RoutePersistence`), or a deep link/push
/// notification - where `AppShell` never mounts at all. So this fetches for
/// itself when the cache is empty, and rebuilds once it lands rather than
/// being stuck on the "Channel" placeholder title forever.
class ChannelScreen extends StatefulWidget {
  const ChannelScreen({
    super.key,
    required this.guildId,
    required this.channelId,
  });

  final String guildId;
  final String channelId;

  @override
  State<ChannelScreen> createState() => _ChannelScreenState();
}

class _ChannelScreenState extends State<ChannelScreen> {
  StreamSubscription<List<GuildDto>>? _guildsSub;

  @override
  void initState() {
    super.initState();
    final repository = getIt<GuildRepository>();
    if (repository.cachedById(widget.guildId) == null) {
      repository.fetch().catchError((Object _) => <GuildDto>[]);
    }
    _guildsSub = repository.guildsStream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _guildsSub?.cancel();
    super.dispose();
  }

  String _title() {
    final guild = getIt<GuildRepository>().cachedById(widget.guildId);
    final channel = guild?.channels
        .where((c) => c.id == widget.channelId)
        .firstOrNull;
    return channel != null ? '#${channel.name}' : 'Channel';
  }

  @override
  Widget build(BuildContext context) {
    final myUserId = getIt<AuthRepository>().currentUserId ?? '';
    return BlocProvider(
      create: (_) => MessageThreadBloc(
        repository: MessageRepository(
          api: getIt<MessageApi>(),
          realtimeService: getIt(),
          channelId: widget.channelId,
        ),
        myUserId: myUserId,
        soundService: getIt(),
      ),
      child: ThreadView(
        title: _title(),
        myUserId: myUserId,
        guildId: widget.guildId,
      ),
    );
  }
}
