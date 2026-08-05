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
import '../../../../core/widgets/profile_resolver.dart';
import '../../../../core/widgets/shimmer_box.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../guilds/data/models/guild_permissions.dart';
import '../../../messaging/presentation/widgets/message_link_launcher.dart';
import '../../data/models/wiki_dto.dart';
import '../../data/models/wiki_page_dto.dart';
import '../../data/models/wiki_page_summary_dto.dart';
import '../../data/wiki_content.dart';
import '../../data/wiki_repository.dart';
import '../wiki_permissions.dart';
import '../widgets/wiki_markdown.dart';
import '../widgets/wiki_outline_sheet.dart';

/// A single wiki page, as something to *read* on a phone.
///
/// Three things drive the layout: the content is split at its headings so the
/// outline sheet has anchors to jump to, task-list checkboxes are live
/// controls (tapping one saves, the way Alpine's do), and the page's place in
/// the tree - the category above it, the sub-pages below it - is on screen so
/// the wiki can be walked without going back to the index every time.
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
  final _scrollController = ScrollController();

  WikiPageDto? _page;
  WikiDto? _wiki;
  String? _error;
  GuildPermissions _permissions = GuildPermissions.none;
  late final StreamSubscription<String> _invalidatedSub;

  List<WikiSection> _sections = const [];
  List<GlobalKey> _sectionKeys = const [];
  double _progress = 0;
  bool _savingCheckbox = false;

  @override
  void initState() {
    super.initState();
    _load();
    unawaited(_loadWiki());
    unawaited(_loadPermissions());
    _scrollController.addListener(_onScroll);
    _invalidatedSub = getIt<WikiRepository>().invalidated
        .where((guildId) => guildId == widget.guildId)
        .listen((_) {
          _load();
          unawaited(_loadWiki());
        });
  }

  @override
  void dispose() {
    unawaited(_invalidatedSub.cancel());
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final extent = position.maxScrollExtent;
    final value = extent <= 0
        ? 0.0
        : (position.pixels / extent).clamp(0.0, 1.0).toDouble();
    if ((value - _progress).abs() > 0.005) setState(() => _progress = value);
  }

  Future<void> _loadPermissions() async {
    try {
      final permissions = await loadGuildPermissions(widget.guildId);
      if (mounted) setState(() => _permissions = permissions);
    } catch (_) {
      // Leave edit/history/delete hidden - server still enforces on write.
    }
  }

  Future<void> _loadWiki() async {
    try {
      final wiki = await getIt<WikiRepository>().getWiki(widget.guildId);
      if (mounted) setState(() => _wiki = wiki);
    } catch (_) {
      // Breadcrumbs and sub-pages are a bonus; the page itself still renders.
    }
  }

  Future<void> _load() async {
    try {
      final page = await getIt<WikiRepository>().getPage(
        widget.guildId,
        widget.pageId,
      );
      if (mounted) setState(() => _applyPage(page, error: null));
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not load this page.');
    }
  }

  /// Must run inside a `setState` - re-derives the section split and the
  /// per-section keys that the outline sheet scrolls to.
  void _applyPage(WikiPageDto page, {String? error}) {
    _page = page;
    _error = error;
    _sections = splitWikiSections(normalizeWikiContent(page.content));
    // Ticking a checkbox re-derives the sections; reusing the keys when the
    // shape is unchanged keeps those subtrees in place instead of tearing
    // them down and rebuilding under the reader's thumb.
    if (_sectionKeys.length != _sections.length) {
      _sectionKeys = List.generate(_sections.length, (_) => GlobalKey());
    }
  }

  Future<void> _refresh() async {
    await Future.wait([_load(), _loadWiki()]);
  }

  Future<void> _toggleCheckbox(int index, bool checked) async {
    final page = _page;
    if (page == null || _savingCheckbox) return;

    final updated = toggleWikiCheckbox(page.content, index, checked);
    if (updated == page.content) return;

    setState(() {
      _applyPage(page.copyWith(content: updated));
      _savingCheckbox = true;
    });

    try {
      final saved = await getIt<WikiRepository>().updatePage(
        widget.guildId,
        widget.pageId,
        content: updated,
      );
      if (mounted) setState(() => _applyPage(saved));
    } catch (_) {
      // The write may well have landed and only the response parse failed, so
      // ask the server what it actually holds before calling this a failure.
      WikiPageDto? server;
      try {
        server = await getIt<WikiRepository>().getPage(
          widget.guildId,
          widget.pageId,
        );
      } catch (_) {
        server = null;
      }
      if (!mounted) return;
      if (server != null && server.content == updated) {
        setState(() => _applyPage(server!));
      } else {
        setState(() => _applyPage(server ?? page));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't save that change.")),
        );
      }
    } finally {
      if (mounted) setState(() => _savingCheckbox = false);
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

  Future<void> _showOutline() async {
    final index = await showWikiOutlineSheet(context, _sections);
    if (index == null || !mounted) return;
    final key = _sectionKeys[index];
    final target = key.currentContext;
    if (target == null || !target.mounted) return;
    await Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      alignment: 0.02,
    );
  }

  void _openPage(String pageId) =>
      context.push(RoutePaths.serverWikiPagePath(widget.guildId, pageId));

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
    final hasOutline = _sections.where((s) => s.title != null).length > 1;

    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(
          fallbackLocation: RoutePaths.serverWikiPath(widget.guildId),
        ),
        title: Text(
          page?.title ?? 'Wiki',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (hasOutline)
            IconButton(
              icon: const Icon(Icons.toc),
              tooltip: 'Outline',
              onPressed: _showOutline,
            ),
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit',
              onPressed: () => context.push(
                RoutePaths.serverWikiPageEditPath(widget.guildId, widget.pageId),
              ),
            ),
          if (canSeeHistory || canDelete)
            PopupMenuButton<String>(
              tooltip: 'More',
              onSelected: (value) {
                switch (value) {
                  case 'history':
                    context.push(
                      RoutePaths.serverWikiHistoryPath(
                        widget.guildId,
                        widget.pageId,
                      ),
                    );
                  case 'delete':
                    unawaited(_delete());
                }
              },
              itemBuilder: (context) => [
                if (canSeeHistory)
                  const PopupMenuItem(
                    value: 'history',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.history),
                      title: Text('Version history'),
                    ),
                  ),
                if (canDelete)
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.delete_outline,
                        color: theme.colorScheme.error,
                      ),
                      title: Text(
                        'Delete page',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  ),
              ],
            ),
        ],
        bottom: page == null
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: SizedBox(
                  height: 2,
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 2,
                    backgroundColor: Colors.transparent,
                    color: theme.colorScheme.primary.withValues(alpha: 0.55),
                  ),
                ),
              ),
      ),
      body: _buildBody(canEdit: canEdit),
    );
  }

  Widget _buildBody({required bool canEdit}) {
    if (_error != null && _page == null) {
      return LoadFailureView(message: _error!, onRetry: _load);
    }
    final page = _page;
    if (page == null) return const _PageSkeleton();

    final wiki = _wiki;
    final children = wiki == null
        ? const <WikiPageSummaryDto>[]
        : (wiki.pages.where((p) => p.parentPageId == page.id).toList()
            ..sort(
              (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
            ));

    return RefreshIndicator(
      onRefresh: _refresh,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: _PageHeader(
              page: page,
              wiki: wiki,
              onOpenPage: _openPage,
            ),
          ),
          SliverToBoxAdapter(
            child: page.content.trim().isEmpty
                ? _EmptyContent(
                    canEdit: canEdit,
                    onEdit: () => context.push(
                      RoutePaths.serverWikiPageEditPath(
                        widget.guildId,
                        widget.pageId,
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.m,
                      AppSpacing.s,
                      AppSpacing.m,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < _sections.length; i++)
                          Padding(
                            key: _sectionKeys[i],
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.m - 2,
                            ),
                            child: WikiMarkdown(
                              data: _sections[i].markdown,
                              checkboxIndexOffset: _sections[i].checkboxOffset,
                              onTapLink: (href) =>
                                  openMessageLink(context, href),
                              onToggleCheckbox: canEdit ? _toggleCheckbox : null,
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
          if (children.isNotEmpty)
            SliverToBoxAdapter(
              child: _SubPages(pages: children, onOpen: _openPage),
            ),
          SliverToBoxAdapter(
            child: _PageFooter(
              page: page,
              canEdit: canEdit,
              onEdit: () => context.push(
                RoutePaths.serverWikiPageEditPath(widget.guildId, widget.pageId),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.page,
    required this.wiki,
    required this.onOpenPage,
  });

  final WikiPageDto page;
  final WikiDto? wiki;
  final ValueChanged<String> onOpenPage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.5);
    final categoryName = _categoryName();
    final parent = _parentPage();
    final updated = page.updatedAt ?? page.createdAt;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.s,
        AppSpacing.m,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (categoryName != null || parent != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4,
                children: [
                  if (categoryName != null)
                    Text(
                      categoryName,
                      style: theme.textTheme.labelSmall?.copyWith(color: muted),
                    ),
                  if (categoryName != null && parent != null)
                    Icon(Icons.chevron_right, size: 13, color: muted),
                  if (parent != null)
                    InkWell(
                      onTap: () => onOpenPage(parent.id),
                      child: Text(
                        parent.title,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (page.isPinned)
                Padding(
                  padding: const EdgeInsets.only(top: 6, right: 6),
                  child: Icon(
                    Icons.push_pin,
                    size: 17,
                    color: theme.colorScheme.primary,
                  ),
                ),
              Expanded(
                child: Text(
                  page.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    height: 1.18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s + 2),
          Row(
            children: [
              UserAvatar(userId: page.lastEditorId ?? page.authorId, radius: 11),
              const SizedBox(width: AppSpacing.s),
              Flexible(
                child: ProfileResolver(
                  userId: page.lastEditorId ?? page.authorId,
                  builder: (context, profile) => Text(
                    profile?.userName ?? 'Someone',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                    ),
                  ),
                ),
              ),
              if (updated != null) ...[
                Text(
                  '  ·  ',
                  style: theme.textTheme.labelMedium?.copyWith(color: muted),
                ),
                Text(
                  formatCompactAgo(updated),
                  style: theme.textTheme.labelMedium?.copyWith(color: muted),
                ),
              ],
              if (page.revisionCount > 0) ...[
                Text(
                  '  ·  ',
                  style: theme.textTheme.labelMedium?.copyWith(color: muted),
                ),
                Text(
                  '${page.revisionCount} '
                  '${page.revisionCount == 1 ? 'revision' : 'revisions'}',
                  style: theme.textTheme.labelMedium?.copyWith(color: muted),
                ),
              ],
            ],
          ),
          if (page.tags.isNotEmpty || page.visibility == WikiVisibility.public)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.s + 2),
              child: Wrap(
                spacing: AppSpacing.xs + 2,
                runSpacing: AppSpacing.xs + 2,
                children: [
                  if (page.visibility == WikiVisibility.public)
                    _Pill(
                      label: 'Public',
                      icon: Icons.public,
                      color: theme.colorScheme.primary,
                    ),
                  for (final tag in page.tags) _Pill(label: tag),
                ],
              ),
            ),
          const Padding(
            padding: EdgeInsets.only(top: AppSpacing.m),
            child: Divider(height: 1),
          ),
        ],
      ),
    );
  }

  String? _categoryName() {
    final categories = wiki?.categories;
    if (categories == null || page.categoryId == null) return null;
    for (final category in categories) {
      if (category.id == page.categoryId) return category.name;
    }
    return null;
  }

  WikiPageSummaryDto? _parentPage() {
    final pages = wiki?.pages;
    if (pages == null || page.parentPageId == null) return null;
    for (final other in pages) {
      if (other.id == page.parentPageId) return other;
    }
    return null;
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, this.icon, this.color});

  final String label;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground =
        color ?? theme.colorScheme.onSurface.withValues(alpha: 0.65);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color == null
            ? context.statusColors.hover
            : color!.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: foreground),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubPages extends StatelessWidget {
  const _SubPages({required this.pages, required this.onOpen});

  final List<WikiPageSummaryDto> pages;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.l,
        AppSpacing.m,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'IN THIS SECTION',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          for (final page in pages)
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadii.chip),
                onTap: () => onOpen(page.id),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
                  child: Row(
                    children: [
                      Icon(
                        Icons.article_outlined,
                        size: 18,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.45,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s + 2),
                      Expanded(
                        child: Text(
                          page.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PageFooter extends StatelessWidget {
  const _PageFooter({
    required this.page,
    required this.canEdit,
    required this.onEdit,
  });

  final WikiPageDto page;
  final bool canEdit;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final created = page.createdAt;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.l,
        AppSpacing.m,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.m),
          if (created != null)
            Text(
              'Created ${formatShortDateTime(created)}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
              ),
            ),
          if (canEdit) ...[
            const SizedBox(height: AppSpacing.m),
            OutlinedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Edit this page'),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyContent extends StatelessWidget {
  const _EmptyContent({required this.canEdit, required this.onEdit});

  final bool canEdit;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.xl,
      ),
      child: Column(
        children: [
          Icon(
            Icons.edit_note,
            size: 38,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            'This page has no content yet.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
          if (canEdit) ...[
            const SizedBox(height: AppSpacing.m),
            FilledButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Start writing'),
            ),
          ],
        ],
      ),
    );
  }
}

class _PageSkeleton extends StatelessWidget {
  const _PageSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.m),
      children: [
        const ShimmerBox(width: 90, height: 11, borderRadius: AppRadii.badge),
        const SizedBox(height: AppSpacing.s + 4),
        const ShimmerBox(height: 26, borderRadius: AppRadii.badge),
        const SizedBox(height: AppSpacing.s),
        const ShimmerBox(width: 200, height: 26, borderRadius: AppRadii.badge),
        const SizedBox(height: AppSpacing.l),
        const ShimmerBox(width: 160, height: 13, borderRadius: AppRadii.badge),
        const SizedBox(height: AppSpacing.l + AppSpacing.s),
        for (var i = 0; i < 8; i++) ...[
          ShimmerBox(
            width: i % 4 == 3 ? 180 : null,
            height: 13,
            borderRadius: AppRadii.badge,
          ),
          const SizedBox(height: AppSpacing.m - 2),
        ],
      ],
    );
  }
}
