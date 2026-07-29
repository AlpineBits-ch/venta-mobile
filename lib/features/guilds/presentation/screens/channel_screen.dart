import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../messaging/bloc/message_thread_bloc.dart';
import '../../../messaging/data/message_api.dart';
import '../../../messaging/data/message_repository.dart';
import '../../../messaging/presentation/widgets/thread_view.dart';
import '../../data/guild_repository.dart';

/// Full-screen channel thread — reuses `ThreadView`/`MessageThreadBloc`
/// unchanged from DM messaging, just constructed with `channelId` instead
/// of `conversationId`. This is the shared-kernel decision from the Phase 1
/// plan paying off in Phase 2.
class ChannelScreen extends StatelessWidget {
  const ChannelScreen({
    super.key,
    required this.guildId,
    required this.channelId,
  });

  final String guildId;
  final String channelId;

  String _title() {
    final guild = getIt<GuildRepository>().cachedById(guildId);
    final channel = guild?.channels.where((c) => c.id == channelId).firstOrNull;
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
          channelId: channelId,
        ),
        myUserId: myUserId,
        soundService: getIt(),
      ),
      child: ThreadView(title: _title(), myUserId: myUserId, guildId: guildId),
    );
  }
}
