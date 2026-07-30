import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../guilds/data/models/guild_permissions.dart';
import '../../data/models/wiki_page_dto.dart';
import '../../data/wiki_repository.dart';
import '../wiki_permissions.dart';

class WikiPageViewScreen extends StatefulWidget {
  const WikiPageViewScreen({
    super.key,
    required this.guildId,
    required this.pageId,
  });

  final String guildId;
  final String pageId;

  @override
  State<WikiPageViewScreen> createState() => _WikiPageViewScreenState();
}

class _WikiPageViewScreenState extends State<WikiPageViewScreen> {
  WikiPageDto? _page;
  String? _error;
  GuildPermissions _permissions = GuildPermissions.none;
  late final StreamSubscription<String> _invalidatedSub;

  @override
  void initState() {
    super.initState();
    _load();
    unawaited(_loadPermissions());
    _invalidatedSub = getIt<WikiRepository>().invalidated
        .where((guildId) => guildId == widget.guildId)
        .listen((_) => _load());
  }

  @override
  void dispose() {
    unawaited(_invalidatedSub.cancel());
    super.dispose();
  }

  Future<void> _loadPermissions() async {
    try {
      final permissions = await loadGuildPermissions(widget.guildId);
      if (mounted) setState(() => _permissions = permissions);
    } catch (_) {
      // Leave edit/history/delete hidden - server still enforces on write.
    }
  }

  Future<void> _load() async {
    try {
      final page = await getIt<WikiRepository>().getPage(
        widget.guildId,
        widget.pageId,
      );
      if (mounted) setState(() => _page = page);
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not load this page.');
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete page?'),
        content: Text('"${_page?.title}" will be gone for everyone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await getIt<WikiRepository>().deletePage(widget.guildId, widget.pageId);
      if (mounted) context.pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not delete this page.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final page = _page;
    final myUserId = getIt<AuthRepository>().currentUserId ?? '';
    final canEdit =
        page != null &&
        (_permissions.has('EditAnyWikiPage') ||
            (page.authorId == myUserId &&
                _permissions.has('EditOwnWikiPages')));
    final canSeeHistory = _permissions.has('ManageWikiRevisions');
    final canDelete = _permissions.has('DeleteWikiPages');

    Widget body;
    if (_error != null) {
      body = Center(child: Text(_error!));
    } else if (page == null) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      body = ListView(
        padding: const EdgeInsets.all(AppSpacing.m),
        children: [
          Row(
            children: [
              if (page.isPinned) ...[
                Icon(
                  Icons.push_pin,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  page.title,
                  style: theme.textTheme.headlineSmall?.copyWith(height: 1.2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            page.updatedAt != null
                ? 'Updated ${_formatDate(page.updatedAt!)}'
                : 'Not yet saved',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          if (page.tags.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final tag in page.tags)
                  Chip(
                    label: Text(tag, style: theme.textTheme.labelSmall),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
              ],
            ),
          ],
          const Divider(height: AppSpacing.l * 2),
          MarkdownBody(
            data: page.content.isEmpty ? '*This page is empty.*' : page.content,
            selectable: true,
            styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
              p: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
              h1: theme.textTheme.headlineMedium,
              h2: theme.textTheme.headlineSmall,
              h3: theme.textTheme.titleLarge,
              blockSpacing: 16,
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(page?.title ?? 'Wiki'),
        actions: [
          if (canSeeHistory && page != null)
            IconButton(
              icon: const Icon(Icons.history),
              tooltip: 'History',
              onPressed: () => context.push(
                RoutePaths.serverWikiHistoryPath(widget.guildId, widget.pageId),
              ),
            ),
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit',
              onPressed: () => context.push(
                RoutePaths.serverWikiPageEditPath(
                  widget.guildId,
                  widget.pageId,
                ),
              ),
            ),
          if (canDelete)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete',
              onPressed: _delete,
            ),
        ],
      ),
      body: body,
    );
  }

  static String _formatDate(DateTime date) {
    final local = date.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  }
}
