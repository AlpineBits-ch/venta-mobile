import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../messaging/bloc/message_thread_bloc.dart';
import '../../../messaging/data/message_api.dart';
import '../../../messaging/data/message_repository.dart';
import '../../../messaging/presentation/widgets/thread_view.dart';
import '../../data/forum_visits.dart';
import '../../data/guild_repository.dart';
import '../../data/models/channel_dto.dart';
import '../../data/models/guild_dto.dart';
import '../widgets/forum_post_header.dart';

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
      _recordForumVisit();
    });
    _recordForumVisit();
  }

  /// Puts this post in its forum's sidebar list, if that's what it is.
  ///
  /// Called again whenever the guild cache lands, because the interesting
  /// case - a cold start straight into a post, a deep link, a notification -
  /// is precisely the one where nothing is cached yet at `initState`.
  void _recordForumVisit() {
    final channel = _channel;
    if (channel == null || channel.type != ChannelType.thread) return;
    final parent = _parentOf(channel);
    if (!(parent?.type.isForumLike ?? false)) return;
    ForumVisits.record(
      forumChannelId: parent!.id,
      postId: channel.id,
      name: channel.name,
    );
  }

  ChannelDto? _parentOf(ChannelDto channel) {
    final parentId = channel.parentChannelId;
    if (parentId == null) return null;
    return getIt<GuildRepository>()
        .cachedById(widget.guildId)
        ?.channels
        .where((c) => c.id == parentId)
        .firstOrNull;
  }

  @override
  void dispose() {
    _guildsSub?.cancel();
    super.dispose();
  }

  ChannelDto? get _channel => getIt<GuildRepository>()
      .cachedById(widget.guildId)
      ?.channels
      .where((c) => c.id == widget.channelId)
      .firstOrNull;

  /// A forum post is titled like the post, not like a channel - it's a
  /// sentence, and `#dark-mode-is-too-bright` reads wrong.
  String _title() {
    final channel = _channel;
    if (channel == null) return 'Channel';
    return channel.type == ChannelType.thread
        ? channel.name
        : '#${channel.name}';
  }

  /// Present only for a post inside a Forum/Media channel - see
  /// [ForumPostHeader], which renders nothing when there's nothing to say.
  Widget? _banner() {
    final channel = _channel;
    if (channel == null || channel.type != ChannelType.thread) return null;
    if (!(_parentOf(channel)?.type.isForumLike ?? false)) return null;
    return ForumPostHeader(guildId: widget.guildId, post: channel);
  }

  @override
  Widget build(BuildContext context) {
    final myUserId = getIt<AuthRepository>().currentUserId ?? '';
    return BlocProvider(
      create: (_) => MessageThreadBloc(
        repository: MessageRepository(
          api: getIt<MessageApi>(),
          realtimeService: getIt(),
          mls: getIt(),
          mlsSync: getIt(),
          channelId: widget.channelId,
        ),
        myUserId: myUserId,
        soundService: getIt(),
      ),
      child: ThreadView(
        title: _title(),
        myUserId: myUserId,
        guildId: widget.guildId,
        banner: _banner(),
      ),
    );
  }
}
