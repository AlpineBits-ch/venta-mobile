import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/format/date_time_format.dart';
import '../../../../core/realtime/realtime_event.dart';
import '../../../../core/realtime/realtime_service.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/load_failure_view.dart';
import '../../../../core/widgets/profile_resolver.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../messaging/data/message_api.dart';
import '../../../messaging/data/message_content_codec.dart';
import '../../../messaging/data/models/attachment_dto.dart';
import '../../../messaging/presentation/widgets/message_attachment_view.dart';
import '../../../auth/data/auth_repository.dart';
import '../../data/forum_visits.dart';
import '../../data/guild_repository.dart';
import '../../data/models/channel_dto.dart';
import '../../data/models/forum_config_dto.dart';
import '../../data/models/forum_post_dto.dart';
import '../../data/models/forum_tag_dto.dart';
import '../../data/models/guild_emoji_dto.dart';
import '../../data/models/guild_permissions.dart';
import '../widgets/forum_tag_chip.dart';
import '../widgets/forum_tag_selector.dart';

/// The sort/layout a member last chose for one forum, remembered locally.
///
/// The forum's own `defaultSortOrder`/`defaultLayout` only *seed* these - once
/// someone picks for themselves their choice wins, which is why this is stored
/// rather than re-read from the config every open. Piggybacks on
/// `HydratedBloc.storage` for the same reason `RoutePersistence` does.
abstract final class _ForumViewPrefs {
  static String _key(String channelId) => 'forum_view_prefs_$channelId';

  static Map<String, dynamic>? _read(String channelId) {
    final raw = HydratedBloc.storage.read(_key(channelId));
    return raw is Map ? raw.cast<String, dynamic>() : null;
  }

  static ForumSortOrder? sort(String channelId) =>
      switch (_read(channelId)?['sort']) {
        'activity' => ForumSortOrder.latestActivity,
        'created' => ForumSortOrder.creationDate,
        _ => null,
      };

  static ForumLayout? layout(String channelId) =>
      switch (_read(channelId)?['layout']) {
        'list' => ForumLayout.list,
        'gallery' => ForumLayout.gallery,
        _ => null,
      };

  static void save(
    String channelId, {
    required ForumSortOrder sort,
    required ForumLayout layout,
  }) {
    unawaited(
      HydratedBloc.storage.write(_key(channelId), {
        'sort': sort.querySortValue,
        'layout': layout == ForumLayout.gallery ? 'gallery' : 'list',
      }),
    );
  }
}

/// What a post card previews from the post's opening message: its text, its
/// first image, or both. Either field may be null - an image-only post is
/// normal in a Media channel, and a text-only one in a Forum.
typedef _PostPreview = ({String? text, String? imageUrl});

/// A Forum (or Media) channel's post list. Each "post" is a `Thread`-typed
/// channel parented to this forum, so opening one is just opening a channel -
/// the message list is `ChannelScreen`, unchanged.
///
/// Reads the paginated `/posts` endpoint rather than the legacy `/threads`
/// one: only `/posts` carries tags, pinning, lock state, activity sort and a
/// cursor (and `/threads` is capped at 50 entries).
class ForumChannelScreen extends StatefulWidget {
  const ForumChannelScreen({
    super.key,
    required this.guildId,
    required this.channelId,
  });

  final String guildId;
  final String channelId;

  @override
  State<ForumChannelScreen> createState() => _ForumChannelScreenState();
}

class _ForumChannelScreenState extends State<ForumChannelScreen> {
  final _scrollController = ScrollController();

  List<ForumPostDto> _posts = const [];
  List<ForumTagDto> _tags = const [];
  List<GuildEmojiDto>? _guildEmojis;
  ForumConfigDto _config = const ForumConfigDto();
  GuildPermissions _permissions = GuildPermissions.none;

  String? _cursor;
  bool _loading = true;
  bool _loadingMore = false;
  bool _loadFailed = false;
  bool _creating = false;

  Set<String> _selectedTagIds = {};
  late ForumSortOrder _sort;
  late ForumLayout _layout;
  ForumArchiveFilter _archived = ForumArchiveFilter.active;

  /// First message per post, fetched lazily as cards scroll into view - see
  /// [_ensurePreview]. A null value means "looked, found nothing".
  final Map<String, _PostPreview?> _previews = {};
  final Set<String> _previewsInFlight = {};

  StreamSubscription<RealtimeEvent>? _realtimeSub;
  Timer? _reloadDebounce;

  /// Set when `/guilds/{id}/me` couldn't be read at all - which is not the
  /// same as being told "no". Everything else stays hidden on a failure, but
  /// posting doesn't: a forum with no way to start a post and no explanation
  /// reads as broken, and `POST /threads` is authorised server-side anyway, so
  /// the worst case is a refusal we can show a reason for.
  bool _permissionsFailed = false;

  bool get _canModerate =>
      _permissions.has('ManageAnyThread') || _permissions.has('ManageChannel');

  bool get _canCreatePosts =>
      _permissions.has('CreateThreads') || _permissionsFailed;

  String? get _myUserId => getIt<AuthRepository>().currentUserId;

  ChannelDto? get _channel => getIt<GuildRepository>()
      .cachedById(widget.guildId)
      ?.channels
      .where((c) => c.id == widget.channelId)
      .firstOrNull;

  @override
  void initState() {
    super.initState();
    _sort = _ForumViewPrefs.sort(widget.channelId) ?? _config.defaultSortOrder;
    _layout = _ForumViewPrefs.layout(widget.channelId) ?? _config.defaultLayout;
    _subscribeToRealtime();
    unawaited(_init());
  }

  @override
  void dispose() {
    _reloadDebounce?.cancel();
    unawaited(_realtimeSub?.cancel());
    _scrollController.dispose();
    super.dispose();
  }

  void _subscribeToRealtime() {
    _realtimeSub = getIt<RealtimeService>().events
        .where(
          (e) => switch (e.name) {
            // A post's tag changes, pin, lock and archive all arrive as one
            // ThreadUpdated carrying the full current state - so any of them
            // is just "this forum's list moved on".
            'guild.ThreadCreated' || 'guild.ThreadUpdated' =>
              e.stringField('parentChannelId') == widget.channelId,
            'guild.ForumTagCreated' ||
            'guild.ForumTagUpdated' ||
            'guild.ForumTagDeleted' ||
            'guild.ForumTagsReordered' ||
            'guild.ForumConfigUpdated' =>
              e.stringField('channelId') == widget.channelId,
            _ => false,
          },
        )
        .listen(_onRealtimeEvent);
  }

  void _onRealtimeEvent(RealtimeEvent event) {
    if (event.name == 'guild.ForumTagDeleted') {
      // No per-post updates follow a tag deletion, so the id has to be dropped
      // from everything cached here by hand.
      final tagId = event.stringField('tagId');
      if (tagId != null) {
        setState(() {
          _tags = [
            for (final tag in _tags)
              if (tag.id != tagId) tag,
          ];
          _selectedTagIds = {..._selectedTagIds}..remove(tagId);
          _posts = [
            for (final post in _posts)
              post.tagIds.contains(tagId)
                  ? post.copyWith(
                      tagIds: [
                        for (final id in post.tagIds)
                          if (id != tagId) id,
                      ],
                    )
                  : post,
          ];
        });
      }
      return;
    }
    if (event.name.startsWith('guild.ForumTag') ||
        event.name == 'guild.ForumConfigUpdated') {
      unawaited(_loadMeta());
      return;
    }
    // Thread events can arrive in bursts (a post created with a first message
    // fires twice); one reload per burst is enough.
    _reloadDebounce?.cancel();
    _reloadDebounce = Timer(
      const Duration(milliseconds: 350),
      () => unawaited(_loadPosts()),
    );
  }

  Future<void> _init() async {
    await _loadMeta(seedViewPrefs: true);
    await _loadPosts();
    unawaited(_loadPermissions());
  }

  Future<void> _loadPermissions() async {
    final repository = getIt<GuildRepository>();
    final ownerId = repository.cachedById(widget.guildId)?.ownerId;
    try {
      final self = await repository.getOwnMember(widget.guildId);
      if (mounted) {
        setState(() {
          _permissions = ownerId == null
              ? self.permissions
              : self.effectivePermissions(ownerId);
          _permissionsFailed = false;
        });
      }
    } catch (_) {
      // Moderation entries stay hidden; the server enforces them anyway. The
      // *create* button is the exception - see [_permissionsFailed].
      if (mounted) setState(() => _permissionsFailed = true);
    }
  }

  Future<void> _loadMeta({bool seedViewPrefs = false}) async {
    final repository = getIt<GuildRepository>();
    try {
      final results = await Future.wait([
        repository.getForumTags(widget.channelId),
        repository.getForumConfig(widget.channelId),
      ]);
      if (!mounted) return;
      final tags = results[0] as List<ForumTagDto>;
      final config = results[1] as ForumConfigDto;
      setState(() {
        _tags = tags;
        _config = config;
        if (seedViewPrefs) {
          _sort =
              _ForumViewPrefs.sort(widget.channelId) ?? config.defaultSortOrder;
          _layout =
              _ForumViewPrefs.layout(widget.channelId) ?? config.defaultLayout;
        }
      });
      if (tags.any((t) => t.emojiId != null)) {
        final emojis = await repository.getEmojis(widget.guildId);
        if (mounted) setState(() => _guildEmojis = emojis);
      }
    } catch (_) {
      // A forum with no tags configured yet, or a transient failure - the post
      // list is still perfectly usable without the filter bar.
    }
  }

  /// Loads page one under the current filters. Any filter change starts over:
  /// a cursor is only valid for the sort and filters it was issued under.
  Future<void> _loadPosts() async {
    if (mounted) setState(() => _loadFailed = false);
    try {
      final page = await getIt<GuildRepository>().getForumPosts(
        widget.channelId,
        tagIds: _selectedTagIds.toList(),
        matchAll: _selectedTagIds.length > 1,
        sort: _sort,
        archived: _archived,
      );
      if (!mounted) return;
      setState(() {
        _posts = page.posts;
        _cursor = page.nextCursor;
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadFailed = _posts.isEmpty;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    final cursor = _cursor;
    if (cursor == null || _loadingMore) return;
    setState(() => _loadingMore = true);
    try {
      final page = await getIt<GuildRepository>().getForumPosts(
        widget.channelId,
        tagIds: _selectedTagIds.toList(),
        matchAll: _selectedTagIds.length > 1,
        sort: _sort,
        archived: _archived,
        cursor: cursor,
      );
      if (!mounted) return;
      setState(() {
        // Pinned posts sort above unpinned ones *within* the ordering, so
        // they occupy the top of page one and never come back on a later one.
        // Append as-is: the cursor encodes the pinned flag, so re-sorting here
        // would desync from what the next page assumes.
        _posts = [..._posts, ...page.posts];
        _cursor = page.nextCursor;
      });
    } catch (_) {
      // Keep what's already shown; the next scroll retries.
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  void _applyFilters(VoidCallback mutate) {
    setState(() {
      mutate();
      _loading = true;
      _posts = const [];
      _cursor = null;
    });
    unawaited(_loadPosts());
  }

  /// The post's opening message - its text and its first image - used as the
  /// card preview. An image-only opening post is common in a Media channel,
  /// so the thumbnail matters as much as the text here.
  ///
  /// The message list comes back newest-first, so the *first* message sits at
  /// `messageCount - 1`. A stale count just means an empty page, which falls
  /// back to the most recent message rather than showing nothing.
  Future<void> _ensurePreview(ForumPostDto post) async {
    if (_previews.containsKey(post.id) || _previewsInFlight.contains(post.id)) {
      return;
    }
    if (post.messageCount == 0) {
      _previews[post.id] = null;
      return;
    }
    _previewsInFlight.add(post.id);
    try {
      final api = getIt<MessageApi>();
      final offset = post.messageCount > 1 ? post.messageCount - 1 : 0;
      var messages = await api.getForChannel(post.id, offset: offset, limit: 1);
      if (messages.isEmpty && offset > 0) {
        messages = await api.getForChannel(post.id, limit: 1);
      }
      _PostPreview? preview;
      if (messages.isNotEmpty) {
        final message = messages.first;
        final text = MessageContentCodec.decode(message.content).trim();
        final image = message.attachments.where((a) => a.isImage).firstOrNull;
        final imageUrl = image == null
            ? null
            : resolveAttachmentThumbnailUrl(image);
        if (text.isNotEmpty || imageUrl != null) {
          preview = (text: text.isEmpty ? null : text, imageUrl: imageUrl);
        }
      }
      if (mounted) setState(() => _previews[post.id] = preview);
    } catch (_) {
      if (mounted) setState(() => _previews[post.id] = null);
    } finally {
      _previewsInFlight.remove(post.id);
    }
  }

  void _openPost(ForumPostDto post) =>
      _openPostById(post.id, name: post.name);

  void _openPostById(String postId, {required String name}) {
    // Recorded here as well as in `ChannelScreen` because a just-created post
    // isn't in the guild's channel cache yet, and that's the one path where
    // the post screen can't name it for itself.
    ForumVisits.record(
      forumChannelId: widget.channelId,
      postId: postId,
      name: name,
    );
    context.push(RoutePaths.serverChannelPath(widget.guildId, postId));
  }

  Future<void> _createPost() async {
    final input = await showModalBottomSheet<_NewPostInput>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (sheetContext) => _CreatePostSheet(
        tags: _tags,
        guildEmojis: _guildEmojis,
        requireTag: _config.requireTag,
        canApplyModerated: _canModerate,
      ),
    );
    if (input == null || !mounted) return;
    setState(() => _creating = true);
    try {
      final post = await getIt<GuildRepository>().createThread(
        widget.channelId,
        name: input.name,
        content: input.content.isEmpty ? null : input.content,
        tagIds: input.tagIds.toList(),
      );
      await _loadPosts();
      if (mounted) _openPostById(post.id, name: post.name);
    } catch (e) {
      if (mounted) {
        // Say which kind of "no" it was. "Could not create post" in front of
        // somebody who isn't allowed to post - or whose server is down - is
        // the message that sends them looking for a bug in their own typing.
        final status = e is DioException ? e.response?.statusCode : null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(switch (status) {
              403 => 'You don\'t have permission to post in this forum.',
              null || >= 500 => 'The server couldn\'t take that post. Try '
                  'again in a moment.',
              _ => 'Could not create post.',
            }),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  Future<void> _showPostActions(ForumPostDto post) async {
    final isAuthor =
        post.createdByUserId != null && post.createdByUserId == _myUserId;
    final canEditTags = _tags.isNotEmpty && (isAuthor || _canModerate);
    final canArchive =
        _canModerate || (isAuthor && _permissions.has('ManageOwnThreads'));
    final action = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.open_in_new),
              title: const Text('Open post'),
              onTap: () => Navigator.pop(sheetContext, 'open'),
            ),
            if (canEditTags)
              ListTile(
                leading: const Icon(Icons.sell_outlined),
                title: const Text('Edit tags'),
                onTap: () => Navigator.pop(sheetContext, 'tags'),
              ),
            if (_canModerate) ...[
              ListTile(
                leading: Icon(
                  post.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                ),
                title: Text(post.isPinned ? 'Unpin post' : 'Pin post'),
                onTap: () => Navigator.pop(sheetContext, 'pin'),
              ),
              ListTile(
                leading: Icon(
                  post.isLocked ? Icons.lock_open_outlined : Icons.lock_outline,
                ),
                title: Text(post.isLocked ? 'Unlock post' : 'Lock post'),
                subtitle: Text(
                  post.isLocked
                      ? 'Allow new messages again'
                      : 'Stop new messages without archiving',
                ),
                onTap: () => Navigator.pop(sheetContext, 'lock'),
              ),
            ],
            if (canArchive && !post.isArchived)
              ListTile(
                leading: const Icon(Icons.archive_outlined),
                title: const Text('Archive post'),
                subtitle: const Text('Stays readable; posting revives it'),
                onTap: () => Navigator.pop(sheetContext, 'archive'),
              ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    switch (action) {
      case 'open':
        _openPost(post);
      case 'tags':
        await _editTags(post);
      case 'pin':
        await _runPostAction(
          () => getIt<GuildRepository>().setPostPinned(post.id, !post.isPinned),
          failure: 'Could not change the pin.',
        );
      case 'lock':
        await _runPostAction(
          () => getIt<GuildRepository>().setPostLocked(post.id, !post.isLocked),
          failure: 'Could not change the lock.',
        );
      case 'archive':
        await _runPostAction(
          () => getIt<GuildRepository>().archiveThread(post.id),
          failure: 'Could not archive that post.',
        );
    }
  }

  Future<void> _runPostAction(
    Future<void> Function() action, {
    required String failure,
  }) async {
    try {
      await action();
      await _loadPosts();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure)));
      }
    }
  }

  Future<void> _editTags(ForumPostDto post) async {
    final picked = await showForumTagPickerSheet(
      context,
      tags: _tags,
      initialSelection: post.tagIds.toSet(),
      guildEmojis: _guildEmojis,
      canApplyModerated: _canModerate,
      requireTag: _config.requireTag,
    );
    if (picked == null || !mounted) return;
    try {
      final updated = await getIt<GuildRepository>().setPostTags(
        post.id,
        picked.toList(),
      );
      if (mounted) {
        setState(
          () => _posts = [
            for (final p in _posts)
              if (p.id == post.id) updated else p,
          ],
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not update those tags.')),
        );
      }
    }
  }

  void _setLayout(ForumLayout layout) {
    setState(() => _layout = layout);
    _ForumViewPrefs.save(widget.channelId, sort: _sort, layout: layout);
  }

  void _setSort(ForumSortOrder sort) {
    _ForumViewPrefs.save(widget.channelId, sort: sort, layout: _layout);
    _applyFilters(() => _sort = sort);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final channel = _channel;
    final isMedia = channel?.type == ChannelType.media;
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(
          fallbackLocation: RoutePaths.serverPath(widget.guildId),
        ),
        title: Text(channel?.name ?? (isMedia ? 'Media' : 'Forum')),
        actions: [
          IconButton(
            icon: Icon(
              _layout == ForumLayout.gallery
                  ? Icons.grid_view_outlined
                  : Icons.view_agenda_outlined,
            ),
            tooltip: _layout == ForumLayout.gallery
                ? 'Gallery view'
                : 'List view',
            onPressed: () => _setLayout(
              _layout == ForumLayout.gallery
                  ? ForumLayout.list
                  : ForumLayout.gallery,
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'sort_activity':
                  _setSort(ForumSortOrder.latestActivity);
                case 'sort_created':
                  _setSort(ForumSortOrder.creationDate);
                case 'archived_hide':
                  _applyFilters(() => _archived = ForumArchiveFilter.active);
                case 'archived_show':
                  _applyFilters(() => _archived = ForumArchiveFilter.all);
                case 'archived_only':
                  _applyFilters(() => _archived = ForumArchiveFilter.archived);
                case 'settings':
                  context.push(
                    RoutePaths.serverChannelForumSettingsPath(
                      widget.guildId,
                      widget.channelId,
                    ),
                  );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                enabled: false,
                height: 32,
                child: Text('SORT BY'),
              ),
              CheckedPopupMenuItem(
                value: 'sort_activity',
                checked: _sort == ForumSortOrder.latestActivity,
                child: const Text('Latest activity'),
              ),
              CheckedPopupMenuItem(
                value: 'sort_created',
                checked: _sort == ForumSortOrder.creationDate,
                child: const Text('Date posted'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                enabled: false,
                height: 32,
                child: Text('ARCHIVED POSTS'),
              ),
              CheckedPopupMenuItem(
                value: 'archived_hide',
                checked: _archived == ForumArchiveFilter.active,
                child: const Text('Hidden'),
              ),
              CheckedPopupMenuItem(
                value: 'archived_show',
                checked: _archived == ForumArchiveFilter.all,
                child: const Text('Shown'),
              ),
              CheckedPopupMenuItem(
                value: 'archived_only',
                checked: _archived == ForumArchiveFilter.archived,
                child: const Text('Only archived'),
              ),
              if (_permissions.has('ManageChannel')) ...[
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'settings',
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: Icon(Icons.sell_outlined),
                    title: Text('Tags & settings'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (_tags.isNotEmpty) _buildFilterBar(theme),
          Expanded(child: _buildBody(theme)),
        ],
      ),
      floatingActionButton: _canCreatePosts
          ? FloatingActionButton(
              onPressed: _creating ? null : _createPost,
              tooltip: 'New post',
              child: _creating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildFilterBar(ThemeData theme) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
        children: [
          for (final tag in _tags)
            Padding(
              padding: const EdgeInsets.only(
                right: AppSpacing.xs,
                top: AppSpacing.s,
                bottom: AppSpacing.s,
              ),
              child: ForumTagChip(
                tag: tag,
                emojiImageUrl: forumTagEmojiUrl(tag, _guildEmojis),
                selected: _selectedTagIds.contains(tag.id),
                showCount: true,
                onTap: () => _applyFilters(() {
                  final next = {..._selectedTagIds};
                  if (!next.remove(tag.id)) next.add(tag.id);
                  _selectedTagIds = next;
                }),
              ),
            ),
          if (_selectedTagIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
              child: TextButton(
                onPressed: () =>
                    _applyFilters(() => _selectedTagIds = <String>{}),
                child: const Text('Clear'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_loadFailed) {
      return LoadFailureView(
        message: 'Couldn\'t load posts.',
        onRetry: _loadPosts,
      );
    }
    if (_posts.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) => RefreshIndicator(
          onRefresh: _loadPosts,
          child: ListView(
            children: [
              SizedBox(
                height: constraints.maxHeight,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.l),
                    child: Text(
                      _selectedTagIds.isNotEmpty
                          ? 'No posts match those tags.'
                          : _archived == ForumArchiveFilter.archived
                          ? 'Nothing archived here yet.'
                          : 'No posts yet - be the first!',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPosts,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels >=
              notification.metrics.maxScrollExtent - 400) {
            unawaited(_loadMore());
          }
          return false;
        },
        child: _layout == ForumLayout.gallery
            ? _buildGallery()
            : _buildList(theme),
      ),
    );
  }

  Widget _buildList(ThemeData theme) {
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: _posts.length + (_cursor != null ? 1 : 0),
      separatorBuilder: (_, _) => Divider(
        height: 1,
        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
      ),
      itemBuilder: (context, index) {
        if (index >= _posts.length) return const _PageLoader();
        final post = _posts[index];
        unawaited(_ensurePreview(post));
        return _PostRow(
          post: post,
          tags: _tags,
          guildEmojis: _guildEmojis,
          preview: _previews[post.id],
          onTap: () => _openPost(post),
          onLongPress: () => _showPostActions(post),
        );
      },
    );
  }

  Widget _buildGallery() {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.s,
        AppSpacing.m,
        88,
      ),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 260,
        mainAxisExtent: 176,
        crossAxisSpacing: AppSpacing.s,
        mainAxisSpacing: AppSpacing.s,
      ),
      itemCount: _posts.length + (_cursor != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _posts.length) return const _PageLoader();
        final post = _posts[index];
        unawaited(_ensurePreview(post));
        return _PostCard(
          post: post,
          tags: _tags,
          guildEmojis: _guildEmojis,
          preview: _previews[post.id],
          onTap: () => _openPost(post),
          onLongPress: () => _showPostActions(post),
        );
      },
    );
  }
}

class _PageLoader extends StatelessWidget {
  const _PageLoader();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(AppSpacing.m),
    child: Center(
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    ),
  );
}

/// Shared bits of both card shapes: the pin/lock/archive affordances and the
/// applied-tag chips (rendered in array order - the backend already sorts
/// them by each tag's own position).
List<Widget> _appliedTagChips(
  ForumPostDto post,
  List<ForumTagDto> tags,
  List<GuildEmojiDto>? guildEmojis, {
  int max = 3,
}) {
  final applied = [
    for (final id in post.tagIds) ...tags.where((t) => t.id == id),
  ];
  if (applied.isEmpty) return const [];
  return [
    for (final tag in applied.take(max))
      ForumTagChip(
        tag: tag,
        emojiImageUrl: forumTagEmojiUrl(tag, guildEmojis),
        dense: true,
      ),
    if (applied.length > max)
      Builder(
        builder: (context) => Text(
          '+${applied.length - max}',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
  ];
}

/// The activity timestamp shown on a card - `lastActivityAt` where the
/// backend has it, falling back to creation for posts that predate activity
/// tracking or have no replies (matching how `sort=activity` orders them).
String? _postAgo(ForumPostDto post) {
  final when = post.lastActivityAt ?? post.createdAt;
  return when == null ? null : formatCompactAgo(when);
}

/// One post as a full-width row - the default (`List`) layout.
class _PostRow extends StatelessWidget {
  const _PostRow({
    required this.post,
    required this.tags,
    required this.guildEmojis,
    required this.preview,
    required this.onTap,
    required this.onLongPress,
  });

  final ForumPostDto post;
  final List<ForumTagDto> tags;
  final List<GuildEmojiDto>? guildEmojis;
  final _PostPreview? preview;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final ago = _postAgo(post);
    final chips = _appliedTagChips(post, tags, guildEmojis);

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Opacity(
        // Archived posts stay readable but recede - they're off the default
        // list anyway, so seeing one means someone asked to.
        opacity: post.isArchived ? 0.6 : 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.m,
            vertical: AppSpacing.s + 2,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (post.createdByUserId != null) ...[
                UserAvatar(
                  userId: post.createdByUserId!,
                  radius: AppRadii.avatarSmall,
                ),
                const SizedBox(width: AppSpacing.s),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (post.isPinned) ...[
                          Icon(
                            Icons.push_pin,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                        ],
                        if (post.isLocked) ...[
                          Icon(Icons.lock_outline, size: 14, color: muted),
                          const SizedBox(width: 4),
                        ],
                        Expanded(
                          child: Text(
                            post.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (ago != null) ...[
                          const SizedBox(width: AppSpacing.s),
                          Text(ago, style: theme.textTheme.labelSmall),
                        ],
                      ],
                    ),
                    if (chips.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(spacing: 4, runSpacing: 4, children: chips),
                    ],
                    if (preview?.text != null || preview?.imageUrl != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (preview?.text != null)
                            Expanded(
                              child: Text(
                                preview!.text!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: muted,
                                ),
                              ),
                            )
                          else
                            Expanded(
                              child: Text(
                                'Image',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: muted,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          if (preview?.imageUrl != null) ...[
                            const SizedBox(width: AppSpacing.s),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppRadii.chip,
                              ),
                              child: CachedNetworkImage(
                                imageUrl: preview!.imageUrl!,
                                width: 44,
                                height: 44,
                                fit: BoxFit.cover,
                                errorWidget: (_, _, _) =>
                                    const SizedBox.shrink(),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (post.createdByUserId != null) ...[
                          Flexible(
                            child: ProfileResolver(
                              userId: post.createdByUserId!,
                              builder: (context, profile) => Text(
                                profile?.userName ?? '…',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelSmall,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s),
                        ],
                        Icon(Icons.chat_bubble_outline, size: 13, color: muted),
                        const SizedBox(width: 4),
                        Text(
                          '${post.messageCount}',
                          style: theme.textTheme.labelSmall,
                        ),
                        if (post.isArchived) ...[
                          const SizedBox(width: AppSpacing.s),
                          Text(
                            'Archived',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: muted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One post as a grid tile - the `Gallery` layout hint, for media-forward
/// forums.
class _PostCard extends StatelessWidget {
  const _PostCard({
    required this.post,
    required this.tags,
    required this.guildEmojis,
    required this.preview,
    required this.onTap,
    required this.onLongPress,
  });

  final ForumPostDto post;
  final List<ForumTagDto> tags;
  final List<GuildEmojiDto>? guildEmojis;
  final _PostPreview? preview;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final ago = _postAgo(post);
    final chips = _appliedTagChips(post, tags, guildEmojis, max: 2);

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: Opacity(
          opacity: post.isArchived ? 0.6 : 1,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s + 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (post.isPinned) ...[
                      Icon(
                        Icons.push_pin,
                        size: 13,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                    ],
                    if (post.isLocked) ...[
                      Icon(Icons.lock_outline, size: 13, color: muted),
                      const SizedBox(width: 4),
                    ],
                    Expanded(
                      child: Text(
                        post.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Gallery is the media-forward layout, so when the opening
                // message has an image it takes the body of the card and the
                // text steps aside; without one, the text fills that space.
                Expanded(
                  child: preview?.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadii.chip),
                          child: CachedNetworkImage(
                            imageUrl: preview!.imageUrl!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorWidget: (_, _, _) => Text(
                              preview!.text ?? '',
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: muted,
                              ),
                            ),
                          ),
                        )
                      : Text(
                          preview?.text ?? '',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: muted,
                          ),
                        ),
                ),
                if (chips.isNotEmpty) ...[
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    clipBehavior: Clip.hardEdge,
                    children: chips,
                  ),
                  const SizedBox(height: 6),
                ],
                Row(
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 13, color: muted),
                    const SizedBox(width: 4),
                    Text(
                      '${post.messageCount}',
                      style: theme.textTheme.labelSmall,
                    ),
                    const Spacer(),
                    if (ago != null)
                      Text(ago, style: theme.textTheme.labelSmall),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// What [_CreatePostSheet] resolves to.
class _NewPostInput {
  const _NewPostInput({
    required this.name,
    required this.content,
    required this.tagIds,
  });
  final String name;
  final String content;
  final Set<String> tagIds;
}

/// Discord's "new post" composer: title, opening message, tags. The message
/// is posted server-side as the post's first message in the same round trip.
class _CreatePostSheet extends StatefulWidget {
  const _CreatePostSheet({
    required this.tags,
    required this.guildEmojis,
    required this.requireTag,
    required this.canApplyModerated,
  });

  final List<ForumTagDto> tags;
  final List<GuildEmojiDto>? guildEmojis;
  final bool requireTag;
  final bool canApplyModerated;

  @override
  State<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<_CreatePostSheet> {
  final _nameController = TextEditingController();
  final _contentController = TextEditingController();
  Set<String> _tagIds = {};

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final missingTag = widget.requireTag && _tagIds.isEmpty;
    final canPost = _nameController.text.trim().isNotEmpty && !missingTag;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('New post', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.m),
                TextField(
                  controller: _nameController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: AppSpacing.s),
                TextField(
                  controller: _contentController,
                  minLines: 3,
                  maxLines: 6,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Message (optional)',
                  ),
                ),
                if (widget.tags.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.l),
                  Row(
                    children: [
                      Text('TAGS', style: theme.textTheme.labelSmall),
                      if (widget.requireTag) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '· required',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: missingTag
                                ? theme.colorScheme.error
                                : theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s),
                  ForumTagSelector(
                    tags: widget.tags,
                    selectedTagIds: _tagIds,
                    guildEmojis: widget.guildEmojis,
                    canApplyModerated: widget.canApplyModerated,
                    onChanged: (next) => setState(() => _tagIds = next),
                  ),
                ],
                const SizedBox(height: AppSpacing.l),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    FilledButton(
                      onPressed: canPost
                          ? () => Navigator.of(context).pop(
                              _NewPostInput(
                                name: _nameController.text.trim(),
                                content: _contentController.text.trim(),
                                tagIds: _tagIds,
                              ),
                            )
                          : null,
                      child: const Text('Post'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
