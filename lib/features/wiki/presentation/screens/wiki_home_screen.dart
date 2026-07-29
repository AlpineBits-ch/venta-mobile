import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../guilds/data/models/guild_permissions.dart';
import '../../data/models/wiki_dto.dart';
import '../../data/models/wiki_page_summary_dto.dart';
import '../../data/wiki_repository.dart';
import '../wiki_permissions.dart';
import 'wiki_category_manager_screen.dart';

/// Landing screen for a guild's wiki: pinned pages, recently updated pages,
/// then every category with its root pages, then anything uncategorized.
/// Categories are shown as a flat, position-ordered list — mobile v1's
/// simplification of Alpine's arbitrarily-nestable category tree (see the
/// wiki feature plan's scope decisions).
class WikiHomeScreen extends StatefulWidget {
  const WikiHomeScreen({super.key, required this.guildId});

  final String guildId;

  @override
  State<WikiHomeScreen> createState() => _WikiHomeScreenState();
}

class _WikiHomeScreenState extends State<WikiHomeScreen> {
  WikiDto? _wiki;
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
      // Leave create/manage actions hidden — server still enforces on write.
    }
  }

  Future<void> _load() async {
    try {
      final wiki = await getIt<WikiRepository>().getWiki(widget.guildId);
      if (mounted) setState(() => _wiki = wiki);
    } catch (e, st) {
      debugPrint('wiki load failed: $e\n$st');
      if (mounted) setState(() => _error = 'Could not load the wiki.');
    }
  }

  Future<void> _manageCategories() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => WikiCategoryManagerScreen(guildId: widget.guildId),
      ),
    );
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final wiki = _wiki;
    final canCreate = _permissions.has('CreateWikiPages');
    final canManageStructure = _permissions.has('ManageWikiStructure');

    Widget body;
    if (_error != null) {
      body = Center(child: Text(_error!));
    } else if (wiki == null) {
      body = const Center(child: CircularProgressIndicator());
    } else if (wiki.pages.isEmpty && wiki.categories.isEmpty) {
      body = _EmptyWiki(canCreate: canCreate, guildId: widget.guildId);
    } else {
      body = _WikiOutline(guildId: widget.guildId, wiki: wiki);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wiki'),
        actions: [
          if (canManageStructure)
            IconButton(
              icon: const Icon(Icons.folder_outlined),
              tooltip: 'Manage categories',
              onPressed: _manageCategories,
            ),
        ],
      ),
      body: body,
      floatingActionButton: canCreate
          ? FloatingActionButton(
              onPressed: () => context.push(
                RoutePaths.serverWikiNewPagePath(widget.guildId),
              ),
              tooltip: 'New page',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class _EmptyWiki extends StatelessWidget {
  const _EmptyWiki({required this.canCreate, required this.guildId});

  final bool canCreate;
  final String guildId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 40,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
            ),
            const SizedBox(height: AppSpacing.m),
            Text('No pages yet', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              canCreate
                  ? 'Start documenting your server — the first page can be anything from rules to a getting-started guide.'
                  : 'Nobody has written anything here yet.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            if (canCreate) ...[
              const SizedBox(height: AppSpacing.m),
              FilledButton.icon(
                onPressed: () =>
                    context.push(RoutePaths.serverWikiNewPagePath(guildId)),
                icon: const Icon(Icons.add),
                label: const Text('New page'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WikiOutline extends StatelessWidget {
  const _WikiOutline({required this.guildId, required this.wiki});

  final String guildId;
  final WikiDto wiki;

  List<WikiPageSummaryDto> _childrenOf(String pageId) =>
      wiki.pages.where((p) => p.parentPageId == pageId).toList()
        ..sort((a, b) => a.title.compareTo(b.title));

  @override
  Widget build(BuildContext context) {
    final pinned = wiki.pages.where((p) => p.isPinned).toList()
      ..sort(
        (a, b) =>
            (b.updatedAt ?? DateTime(0)).compareTo(a.updatedAt ?? DateTime(0)),
      );
    final recent = [...wiki.pages]
      ..sort(
        (a, b) =>
            (b.updatedAt ?? DateTime(0)).compareTo(a.updatedAt ?? DateTime(0)),
      );
    final recentTop = recent.take(8).toList();

    final categories = [...wiki.categories]
      ..sort((a, b) => a.position.compareTo(b.position));
    final uncategorizedRoots =
        wiki.pages
            .where((p) => p.categoryId == null && p.parentPageId == null)
            .toList()
          ..sort((a, b) => a.title.compareTo(b.title));

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      children: [
        if (pinned.isNotEmpty) ...[
          const _SectionHeader(icon: Icons.push_pin, label: 'Pinned'),
          for (final page in pinned) _PageTile(guildId: guildId, page: page),
        ],
        if (recentTop.isNotEmpty) ...[
          const _SectionHeader(icon: Icons.update, label: 'Recently updated'),
          for (final page in recentTop) _PageTile(guildId: guildId, page: page),
        ],
        for (final category in categories) ...[
          _SectionHeader(icon: Icons.folder_outlined, label: category.name),
          for (final page
              in wiki.pages
                  .where(
                    (p) =>
                        p.categoryId == category.id && p.parentPageId == null,
                  )
                  .toList()
                ..sort((a, b) => a.title.compareTo(b.title)))
            _PageTile(
              guildId: guildId,
              page: page,
              children: _childrenOf(page.id),
            ),
        ],
        if (uncategorizedRoots.isNotEmpty) ...[
          const _SectionHeader(
            icon: Icons.description_outlined,
            label: 'Uncategorized',
          ),
          for (final page in uncategorizedRoots)
            _PageTile(
              guildId: guildId,
              page: page,
              children: _childrenOf(page.id),
            ),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurface.withValues(alpha: 0.55);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _PageTile extends StatelessWidget {
  const _PageTile({
    required this.guildId,
    required this.page,
    this.children = const [],
    this.indent = 0,
  });

  final String guildId;
  final WikiPageSummaryDto page;
  final List<WikiPageSummaryDto> children;
  final int indent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: indent * 20.0),
          child: ListTile(
            leading: Icon(
              page.isPinned ? Icons.push_pin : Icons.description_outlined,
              size: 20,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            title: Text(page.title, style: theme.textTheme.bodyMedium),
            trailing: page.visibility == WikiVisibility.public
                ? Icon(
                    Icons.public,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  )
                : null,
            onTap: () =>
                context.push(RoutePaths.serverWikiPagePath(guildId, page.id)),
          ),
        ),
        for (final child in children)
          _PageTile(guildId: guildId, page: child, indent: indent + 1),
      ],
    );
  }
}
