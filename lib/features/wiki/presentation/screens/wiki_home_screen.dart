import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/format/date_time_format.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/status_colors_extension.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/load_failure_view.dart';
import '../../../../core/widgets/shimmer_box.dart';
import '../../../guilds/data/models/guild_permissions.dart';
import '../../data/models/wiki_category_dto.dart';
import '../../data/models/wiki_dto.dart';
import '../../data/models/wiki_page_summary_dto.dart';
import '../../data/wiki_repository.dart';
import '../wiki_permissions.dart';
import 'wiki_category_manager_screen.dart';

/// Landing screen for a guild's wiki.
///
/// The shape of the thing being browsed is a tree (categories nest, pages nest
/// inside them), and the previous version flattened it into three sections
/// that each re-listed the same pages - a pinned page appeared under Pinned,
/// again under Recently updated, and a third time under its category, with no
/// way to tell those three rows apart. This one shows every page exactly once:
/// pinned pages get a rail because they're shortcuts, not entries, and Browse
/// / Recent are two views of the same set rather than two lists stacked on top
/// of each other.
class WikiHomeScreen extends StatefulWidget {
  const WikiHomeScreen({super.key, required this.guildId});

  final String guildId;

  @override
  State<WikiHomeScreen> createState() => _WikiHomeScreenState();
}

enum _WikiView { browse, recent }

class _WikiHomeScreenState extends State<WikiHomeScreen> {
  final _searchController = TextEditingController();

  WikiDto? _wiki;
  String? _error;
  GuildPermissions _permissions = GuildPermissions.none;
  late final StreamSubscription<String> _invalidatedSub;

  _WikiView _view = _WikiView.browse;
  String _query = '';

  /// Collapsed rather than expanded ids: a wiki opens fully expanded (the
  /// whole point of the screen is seeing what's in here), and collapsing is
  /// the deliberate act worth remembering.
  final _collapsedCategories = <String>{};
  final _collapsedPages = <String>{};

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
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPermissions() async {
    try {
      final permissions = await loadGuildPermissions(widget.guildId);
      if (mounted) setState(() => _permissions = permissions);
    } catch (_) {
      // Leave create/manage actions hidden - server still enforces on write.
    }
  }

  Future<void> _load() async {
    try {
      final wiki = await getIt<WikiRepository>().getWiki(widget.guildId);
      if (mounted) {
        setState(() {
          _wiki = wiki;
          _error = null;
        });
      }
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
    if (mounted) unawaited(_load());
  }

  void _openPage(String pageId) =>
      context.push(RoutePaths.serverWikiPagePath(widget.guildId, pageId));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wiki = _wiki;
    final canCreate = _permissions.has('CreateWikiPages');
    final canManageStructure = _permissions.has('ManageWikiStructure');

    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(
          fallbackLocation: RoutePaths.serverPath(widget.guildId),
        ),
        titleSpacing: 0,
        // See `AppTheme` - custom multi-line title, not a candidate for the
        // iOS centred nav title.
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Wiki'),
            if (wiki != null && wiki.pages.isNotEmpty)
              Text(
                _countLabel(wiki),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
          ],
        ),
        actions: [
          if (canManageStructure)
            IconButton(
              icon: const Icon(Icons.folder_outlined),
              tooltip: 'Manage categories',
              onPressed: _manageCategories,
            ),
        ],
      ),
      body: _buildBody(canCreate),
      floatingActionButton: canCreate && wiki != null && wiki.pages.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => context.push(
                RoutePaths.serverWikiNewPagePath(widget.guildId),
              ),
              icon: const Icon(Icons.add),
              label: const Text('New page'),
            )
          : null,
    );
  }

  String _countLabel(WikiDto wiki) {
    final pages = wiki.pages.length;
    final categories = wiki.categories.length;
    final pageLabel = '$pages ${pages == 1 ? 'page' : 'pages'}';
    if (categories == 0) return pageLabel;
    return '$pageLabel · $categories '
        '${categories == 1 ? 'category' : 'categories'}';
  }

  Widget _buildBody(bool canCreate) {
    if (_error != null && _wiki == null) {
      return LoadFailureView(message: _error!, onRetry: _load);
    }
    final wiki = _wiki;
    if (wiki == null) return const _WikiHomeSkeleton();
    if (wiki.pages.isEmpty && wiki.categories.isEmpty) {
      return _EmptyWiki(canCreate: canCreate, guildId: widget.guildId);
    }

    final pinned = wiki.pages.where((page) => page.isPinned).toList()
      ..sort(_byRecency);

    return RefreshIndicator.adaptive(
      onRefresh: _load,
      child: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverToBoxAdapter(
            child: _SearchField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          if (_query.trim().isNotEmpty)
            ..._searchSlivers(wiki)
          else ...[
            if (pinned.isNotEmpty)
              SliverToBoxAdapter(
                child: _PinnedRail(pages: pinned, onOpen: _openPage),
              ),
            SliverToBoxAdapter(
              child: _ViewSwitcher(
                value: _view,
                onChanged: (view) => setState(() => _view = view),
              ),
            ),
            if (_view == _WikiView.browse)
              _rowSliver(_browseRows(wiki))
            else
              _rowSliver(_recentRows(wiki)),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 96)),
        ],
      ),
    );
  }

  SliverList _rowSliver(List<_Row> rows) {
    return SliverList.builder(
      itemCount: rows.length,
      itemBuilder: (context, index) => _buildRow(rows[index]),
    );
  }

  Widget _buildRow(_Row row) {
    switch (row) {
      case _CategoryRow(:final category, :final depth, :final pageCount):
        final collapsed = _collapsedCategories.contains(category.id);
        return _CategoryHeader(
          key: ValueKey('category-${category.id}'),
          name: category.name,
          depth: depth,
          pageCount: pageCount,
          collapsed: collapsed,
          onTap: () => setState(() {
            if (!_collapsedCategories.remove(category.id)) {
              _collapsedCategories.add(category.id);
            }
          }),
        );
      case _LabelRow(:final label):
        return _CategoryHeader(
          key: ValueKey('label-$label'),
          name: label,
          depth: 0,
          pageCount: null,
          collapsed: false,
          onTap: null,
        );
      case _PageRow(
        :final page,
        :final depth,
        :final childCount,
        :final subtitle,
      ):
        return _PageTile(
          key: ValueKey('page-${page.id}'),
          page: page,
          depth: depth,
          childCount: childCount,
          subtitle: subtitle,
          expanded: !_collapsedPages.contains(page.id),
          onTap: () => _openPage(page.id),
          onToggleChildren: childCount == 0
              ? null
              : () => setState(() {
                  if (!_collapsedPages.remove(page.id)) {
                    _collapsedPages.add(page.id);
                  }
                }),
        );
    }
  }

  // ── Row assembly ─────────────────────────────────────────────────────────

  List<_Row> _browseRows(WikiDto wiki) {
    final rows = <_Row>[];
    final categories = [...wiki.categories]
      ..sort((a, b) => a.position.compareTo(b.position));
    final categoryIds = {for (final category in categories) category.id};

    List<WikiCategoryDto> childCategories(String? parentId) => categories
        .where(
          (category) => parentId == null
              // A category whose parent was deleted would otherwise vanish
              // from the tree entirely - float it to the root instead.
              ? category.parentCategoryId == null ||
                    !categoryIds.contains(category.parentCategoryId)
              : category.parentCategoryId == parentId,
        )
        .toList(growable: false);

    List<WikiPageSummaryDto> pagesIn(String? categoryId) =>
        wiki.pages
            .where(
              (page) =>
                  page.categoryId == categoryId && page.parentPageId == null,
            )
            .toList()
          ..sort(_byTitle);

    // A category whose ancestry loops back on itself would otherwise recurse
    // forever and hang the frame, so both walks below are visit-guarded.
    int pagesUnder(WikiCategoryDto category, Set<String> seen) {
      if (!seen.add(category.id)) return 0;
      var count = wiki.pages.where((p) => p.categoryId == category.id).length;
      for (final child in childCategories(category.id)) {
        count += pagesUnder(child, seen);
      }
      return count;
    }

    final visitedPages = <String>{};
    void addPage(WikiPageSummaryDto page, int depth) {
      if (!visitedPages.add(page.id)) return;
      final children = _childrenOf(wiki, page.id);
      rows.add(_PageRow(page: page, depth: depth, childCount: children.length));
      if (_collapsedPages.contains(page.id)) return;
      for (final child in children) {
        addPage(child, depth + 1);
      }
    }

    final visitedCategories = <String>{};
    void addCategory(WikiCategoryDto category, int depth) {
      if (!visitedCategories.add(category.id)) return;
      rows.add(
        _CategoryRow(
          category: category,
          depth: depth,
          pageCount: pagesUnder(category, <String>{}),
        ),
      );
      if (_collapsedCategories.contains(category.id)) return;
      for (final child in childCategories(category.id)) {
        addCategory(child, depth + 1);
      }
      for (final page in pagesIn(category.id)) {
        addPage(page, depth + 1);
      }
    }

    for (final category in childCategories(null)) {
      addCategory(category, 0);
    }

    final loose = pagesIn(null);
    if (loose.isNotEmpty) {
      if (categories.isNotEmpty) rows.add(const _LabelRow('Uncategorized'));
      for (final page in loose) {
        addPage(page, categories.isEmpty ? 0 : 1);
      }
    }
    return rows;
  }

  List<_Row> _recentRows(WikiDto wiki) {
    final pages = [...wiki.pages]..sort(_byRecency);
    return [
      for (final page in pages)
        _PageRow(
          page: page,
          depth: 0,
          childCount: 0,
          subtitle: _breadcrumbOf(wiki, page),
        ),
    ];
  }

  List<Widget> _searchSlivers(WikiDto wiki) {
    final query = _query.trim().toLowerCase();
    final categoryNames = {
      for (final category in wiki.categories)
        category.id: category.name.toLowerCase(),
    };

    final matches =
        wiki.pages.where((page) {
          if (page.title.toLowerCase().contains(query)) return true;
          if (page.tags.any((tag) => tag.toLowerCase().contains(query))) {
            return true;
          }
          final category = categoryNames[page.categoryId];
          return category != null && category.contains(query);
        }).toList()..sort((a, b) {
          // Prefix matches on the title first - that's almost always what the
          // person typing was reaching for.
          final aStarts = a.title.toLowerCase().startsWith(query);
          final bStarts = b.title.toLowerCase().startsWith(query);
          if (aStarts != bStarts) return aStarts ? -1 : 1;
          return _byTitle(a, b);
        });

    if (matches.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _NoResults(query: _query.trim()),
        ),
      ];
    }

    return [
      SliverToBoxAdapter(
        child: _SectionLabel(
          '${matches.length} ${matches.length == 1 ? 'result' : 'results'}',
        ),
      ),
      SliverList.builder(
        itemCount: matches.length,
        itemBuilder: (context, index) {
          final page = matches[index];
          return _PageTile(
            key: ValueKey('result-${page.id}'),
            page: page,
            depth: 0,
            childCount: 0,
            subtitle: _breadcrumbOf(wiki, page),
            highlight: query,
            expanded: false,
            onTap: () => _openPage(page.id),
          );
        },
      ),
    ];
  }

  String? _breadcrumbOf(WikiDto wiki, WikiPageSummaryDto page) {
    final parts = <String>[];
    for (final category in wiki.categories) {
      if (category.id == page.categoryId) {
        parts.add(category.name);
        break;
      }
    }
    for (final other in wiki.pages) {
      if (other.id == page.parentPageId) {
        parts.add(other.title);
        break;
      }
    }
    final updated = page.updatedAt;
    if (updated != null) parts.add(formatCompactAgo(updated));
    return parts.isEmpty ? null : parts.join(' · ');
  }
}

List<WikiPageSummaryDto> _childrenOf(WikiDto wiki, String pageId) =>
    wiki.pages.where((page) => page.parentPageId == pageId).toList()
      ..sort(_byTitle);

int _byTitle(WikiPageSummaryDto a, WikiPageSummaryDto b) =>
    a.title.toLowerCase().compareTo(b.title.toLowerCase());

int _byRecency(WikiPageSummaryDto a, WikiPageSummaryDto b) =>
    (b.updatedAt ?? b.createdAt ?? DateTime(0)).compareTo(
      a.updatedAt ?? a.createdAt ?? DateTime(0),
    );

// ── Rows ───────────────────────────────────────────────────────────────────

sealed class _Row {
  const _Row();
}

class _CategoryRow extends _Row {
  const _CategoryRow({
    required this.category,
    required this.depth,
    required this.pageCount,
  });

  final WikiCategoryDto category;
  final int depth;
  final int pageCount;
}

class _LabelRow extends _Row {
  const _LabelRow(this.label);

  final String label;
}

class _PageRow extends _Row {
  const _PageRow({
    required this.page,
    required this.depth,
    required this.childCount,
    this.subtitle,
  });

  final WikiPageSummaryDto page;
  final int depth;
  final int childCount;
  final String? subtitle;
}

// ── Pieces ─────────────────────────────────────────────────────────────────

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.s,
        AppSpacing.m,
        AppSpacing.xs,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search pages and tags',
          isDense: true,
          prefixIcon: const Icon(Icons.search, size: 20),
          prefixIconConstraints: const BoxConstraints(minWidth: 42),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) => value.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    tooltip: 'Clear',
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                  ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.composerPill),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.composerPill),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.composerPill),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _ViewSwitcher extends StatelessWidget {
  const _ViewSwitcher({required this.value, required this.onChanged});

  final _WikiView value;
  final ValueChanged<_WikiView> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.s,
        AppSpacing.m,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          _SwitcherChip(
            label: 'Browse',
            icon: Icons.account_tree_outlined,
            selected: value == _WikiView.browse,
            onTap: () => onChanged(_WikiView.browse),
          ),
          const SizedBox(width: AppSpacing.s),
          _SwitcherChip(
            label: 'Recent',
            icon: Icons.history_toggle_off,
            selected: value == _WikiView.recent,
            onTap: () => onChanged(_WikiView.recent),
          ),
        ],
      ),
    );
  }
}

class _SwitcherChip extends StatelessWidget {
  const _SwitcherChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = selected
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface.withValues(alpha: 0.7);
    return Material(
      color: selected ? theme.colorScheme.primary : context.statusColors.hover,
      borderRadius: BorderRadius.circular(AppRadii.composerPill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.composerPill),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.m - 2,
            vertical: AppSpacing.s,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: foreground),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pinned pages as a horizontal rail. They're the "start here" set - a
/// server's rules, its onboarding guide - and a rail reads as shortcuts rather
/// than as one more copy of the list below.
class _PinnedRail extends StatelessWidget {
  const _PinnedRail({required this.pages, required this.onOpen});

  final List<WikiPageSummaryDto> pages;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Pinned', icon: Icons.push_pin),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            itemCount: pages.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.s),
            itemBuilder: (context, index) {
              final page = pages[index];
              final updated = page.updatedAt;
              return SizedBox(
                width: 176,
                child: Material(
                  color: theme.colorScheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadii.card),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadii.card),
                    onTap: () => onOpen(page.id),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.s + 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.push_pin,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                          const Spacer(),
                          Text(
                            page.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.onSurface,
                              height: 1.25,
                            ),
                          ),
                          if (updated != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              formatCompactAgo(updated),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label, {this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurface.withValues(alpha: 0.5);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.s,
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 6),
          ],
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({
    super.key,
    required this.name,
    required this.depth,
    required this.pageCount,
    required this.collapsed,
    required this.onTap,
  });

  final String name;
  final int depth;
  final int? pageCount;
  final bool collapsed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurface.withValues(alpha: 0.7);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.m + depth * 16.0,
          AppSpacing.m - 2,
          AppSpacing.m,
          AppSpacing.xs,
        ),
        child: Row(
          children: [
            if (onTap != null)
              AnimatedRotation(
                turns: collapsed ? -0.25 : 0,
                duration: const Duration(milliseconds: 150),
                child: Icon(Icons.expand_more, size: 18, color: color),
              )
            else
              Icon(Icons.more_horiz, size: 16, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                name.toUpperCase(),
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.7,
                ),
              ),
            ),
            if (pageCount != null) ...[
              const SizedBox(width: AppSpacing.s),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: context.statusColors.hover,
                  borderRadius: BorderRadius.circular(AppRadii.badge + 2),
                ),
                child: Text(
                  '$pageCount',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PageTile extends StatelessWidget {
  const _PageTile({
    super.key,
    required this.page,
    required this.depth,
    required this.childCount,
    required this.expanded,
    required this.onTap,
    this.onToggleChildren,
    this.subtitle,
    this.highlight,
  });

  final WikiPageSummaryDto page;
  final int depth;
  final int childCount;
  final bool expanded;
  final VoidCallback onTap;
  final VoidCallback? onToggleChildren;
  final String? subtitle;
  final String? highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.45);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.m + depth * 16.0,
          AppSpacing.s + 2,
          AppSpacing.s,
          AppSpacing.s + 2,
        ),
        child: Row(
          children: [
            Icon(
              childCount > 0
                  ? Icons.folder_copy_outlined
                  : Icons.article_outlined,
              size: 19,
              color: muted,
            ),
            const SizedBox(width: AppSpacing.s + 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HighlightedText(
                    text: page.title,
                    highlight: highlight,
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: muted,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (page.visibility == WikiVisibility.public)
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.xs),
                child: Icon(Icons.public, size: 15, color: muted),
              ),
            if (onToggleChildren != null)
              IconButton(
                icon: AnimatedRotation(
                  turns: expanded ? 0 : -0.25,
                  duration: const Duration(milliseconds: 150),
                  child: const Icon(Icons.expand_more, size: 20),
                ),
                color: muted,
                visualDensity: VisualDensity.compact,
                tooltip: expanded ? 'Hide sub-pages' : 'Show sub-pages',
                onPressed: onToggleChildren,
              )
            else
              const SizedBox(width: AppSpacing.s),
          ],
        ),
      ),
    );
  }
}

/// Bolds the matched span of a search hit so a long list of similar titles is
/// scannable at a glance.
class _HighlightedText extends StatelessWidget {
  const _HighlightedText({
    required this.text,
    required this.highlight,
    this.style,
  });

  final String text;
  final String? highlight;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final query = highlight;
    final start = query == null || query.isEmpty
        ? -1
        : text.toLowerCase().indexOf(query);
    if (start < 0) {
      return Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: style,
      );
    }
    final end = start + query!.length;
    final accent = style?.copyWith(
      fontWeight: FontWeight.w700,
      color: Theme.of(context).colorScheme.primary,
    );
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: text.substring(0, start)),
          TextSpan(text: text.substring(start, end), style: accent),
          TextSpan(text: text.substring(end)),
        ],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            size: 36,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppSpacing.m),
          Text('No page matches "$query"', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Search looks at page titles, tags and category names.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
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
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadii.dialog + 4),
              ),
              child: Icon(
                Icons.menu_book_outlined,
                size: 34,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Text('No pages yet', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              canCreate
                  ? 'Start documenting your server - the first page can be '
                        'anything from rules to a getting-started guide.'
                  : 'Nobody has written anything here yet.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            if (canCreate) ...[
              const SizedBox(height: AppSpacing.l),
              FilledButton.icon(
                onPressed: () =>
                    context.push(RoutePaths.serverWikiNewPagePath(guildId)),
                icon: const Icon(Icons.add),
                label: const Text('Write the first page'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WikiHomeSkeleton extends StatelessWidget {
  const _WikiHomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.s,
        AppSpacing.m,
        AppSpacing.m,
      ),
      children: [
        const ShimmerBox(height: 44, borderRadius: AppRadii.composerPill),
        const SizedBox(height: AppSpacing.l),
        SizedBox(
          height: 96,
          child: Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                const ShimmerBox(
                  width: 176,
                  height: 96,
                  borderRadius: AppRadii.card,
                ),
                const SizedBox(width: AppSpacing.s),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.l),
        for (var i = 0; i < 6; i++) ...[
          Row(
            children: [
              const ShimmerBox(width: 20, height: 20, borderRadius: 4),
              const SizedBox(width: AppSpacing.s + 2),
              ShimmerBox(
                width: 120.0 + (i.isEven ? 80 : 30),
                height: 14,
                borderRadius: AppRadii.badge,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
        ],
      ],
    );
  }
}
