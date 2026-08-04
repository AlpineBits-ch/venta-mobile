import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/avatar_image.dart';
import '../../../friends/data/relationship_repository.dart';
import '../../data/models/blocked_user_dto.dart';

/// The accounts this user has blocked, with an unblock on each.
///
/// There is no "who has blocked me" here and there must never be one: a block
/// is invisible to the person blocked, and a screen that reveals it hands back
/// the whole point of making it invisible.
class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  List<BlockedUserDto>? _blocked;
  bool _failed = false;

  /// Cursor for the next page, null once the list is complete.
  String? _cursor;
  bool _loadingMore = false;

  /// Ids with an unblock in flight - per row, not one screen-wide flag, so
  /// unblocking one person doesn't freeze the rest of the list.
  final Set<String> _busy = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _failed = false);
    try {
      final page = await getIt<RelationshipRepository>().fetchBlocked();
      if (mounted) {
        setState(() {
          _blocked = page.blocked;
          _cursor = page.hasMore ? page.nextCursor : null;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  /// Explicit rather than an infinite scroll: the whole list is normally one
  /// page, and a failed background fetch on a screen like this one would
  /// silently under-report who is blocked.
  Future<void> _loadMore() async {
    final cursor = _cursor;
    if (cursor == null || _loadingMore) return;
    setState(() => _loadingMore = true);
    try {
      final page = await getIt<RelationshipRepository>().fetchBlocked(
        cursor: cursor,
      );
      if (!mounted) return;
      setState(() {
        _blocked = [...?_blocked, ...page.blocked];
        _cursor = page.hasMore ? page.nextCursor : null;
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not load the rest of the list.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  Future<void> _unblock(BlockedUserDto user) async {
    setState(() => _busy.add(user.userId));
    try {
      await getIt<RelationshipRepository>().unblock(user.userId);
      if (!mounted) return;
      setState(
        () => _blocked = [
          for (final b in _blocked ?? const <BlockedUserDto>[])
            if (b.userId != user.userId) b,
        ],
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not unblock ${user.userName}.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy.remove(user.userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final blocked = _blocked;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackLocation: RoutePaths.privacy),
        title: const Text('Blocked users'),
      ),
      body: switch ((_failed, blocked)) {
        (true, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Could not load your block list.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.m),
                FilledButton(onPressed: _load, child: const Text('Try again')),
              ],
            ),
          ),
        ),
        (_, null) => const Center(child: CircularProgressIndicator()),
        (_, final List<BlockedUserDto> list) when list.isEmpty => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Text(
              'You haven\'t blocked anyone.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
        (_, final List<BlockedUserDto> list) => RefreshIndicator(
          onRefresh: _load,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
            itemCount: list.length + (_cursor != null ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == list.length) {
                return Padding(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  child: Center(
                    child: TextButton(
                      onPressed: _loadingMore ? null : _loadMore,
                      child: Text(_loadingMore ? 'Loading...' : 'Show more'),
                    ),
                  ),
                );
              }
              final user = list[index];
              final busy = _busy.contains(user.userId);
              return ListTile(
                // `AvatarImage`, not a null check on `avatarUrl`: the URL is
                // always present and 404s when nothing was uploaded.
                leading: AvatarImage(
                  userId: user.userId,
                  imageUrl: user.avatarUrl,
                  label: user.userName,
                  radius: AppRadii.avatarMedium,
                ),
                title: Text(user.userName),
                trailing: TextButton(
                  onPressed: busy ? null : () => _unblock(user),
                  child: Text(busy ? 'Unblocking...' : 'Unblock'),
                ),
              );
            },
          ),
        ),
      },
    );
  }
}
