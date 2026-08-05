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
import '../../../../core/widgets/user_avatar.dart';
import '../../data/models/wiki_revision_dto.dart';
import '../../data/wiki_content.dart';
import '../../data/wiki_repository.dart';
import '../widgets/wiki_markdown.dart';

/// Every saved version of a page, newest first, as a timeline.
///
/// A revision list is only useful if you can tell the versions apart, so each
/// row leads with who saved it and when, and how much longer or shorter the
/// page got - the cheapest honest stand-in for a diff, and enough to find the
/// edit you're looking for before opening it.
class WikiHistoryScreen extends StatefulWidget {
  const WikiHistoryScreen({
    super.key,
    required this.guildId,
    required this.pageId,
  });

  final String guildId;
  final String pageId;

  @override
  State<WikiHistoryScreen> createState() => _WikiHistoryScreenState();
}

class _WikiHistoryScreenState extends State<WikiHistoryScreen> {
  List<WikiRevisionDto>? _revisions;
  String? _error;
  String? _restoringId;
  final _expanded = <String>{};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final revisions = await getIt<WikiRepository>().getRevisions(
        widget.guildId,
        widget.pageId,
      );
      revisions.sort((a, b) => b.revisionNumber.compareTo(a.revisionNumber));
      if (mounted) {
        setState(() {
          _revisions = revisions;
          _error = null;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not load history.');
    }
  }

  Future<void> _restore(WikiRevisionDto revision) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore this version?'),
        content: Text(
          'Revision ${revision.revisionNumber} becomes the current page. The '
          'version you have now is kept in history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _restoringId = revision.id);
    try {
      await getIt<WikiRepository>().restoreRevision(
        widget.guildId,
        widget.pageId,
        revision.id,
      );
      if (mounted) context.pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not restore that version.')),
        );
      }
    } finally {
      if (mounted) setState(() => _restoringId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final revisions = _revisions;

    Widget body;
    if (_error != null && revisions == null) {
      body = LoadFailureView(message: _error!, onRetry: _load);
    } else if (revisions == null) {
      body = const Center(child: CircularProgressIndicator());
    } else if (revisions.isEmpty) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.history,
                size: 36,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(height: AppSpacing.m),
              Text('No earlier versions yet', style: theme.textTheme.titleSmall),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'A version is saved every time someone edits this page.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      body = RefreshIndicator(
        onRefresh: _load,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
          itemCount: revisions.length,
          itemBuilder: (context, index) {
            final revision = revisions[index];
            final previous = index + 1 < revisions.length
                ? revisions[index + 1]
                : null;
            return _RevisionTile(
              revision: revision,
              previous: previous,
              isLatest: index == 0,
              isLast: index == revisions.length - 1,
              expanded: _expanded.contains(revision.id),
              restoring: _restoringId == revision.id,
              onToggle: () => setState(() {
                if (!_expanded.remove(revision.id)) _expanded.add(revision.id);
              }),
              onRestore: () => _restore(revision),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(
          fallbackLocation: RoutePaths.serverWikiPagePath(
            widget.guildId,
            widget.pageId,
          ),
        ),
        title: const Text('Version history'),
      ),
      body: body,
    );
  }
}

class _RevisionTile extends StatelessWidget {
  const _RevisionTile({
    required this.revision,
    required this.previous,
    required this.isLatest,
    required this.isLast,
    required this.expanded,
    required this.restoring,
    required this.onToggle,
    required this.onRestore,
  });

  final WikiRevisionDto revision;
  final WikiRevisionDto? previous;
  final bool isLatest;
  final bool isLast;
  final bool expanded;
  final bool restoring;
  final VoidCallback onToggle;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.5);
    final created = revision.createdAt;
    final delta = previous == null
        ? null
        : revision.content.length - previous!.content.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.m,
              AppSpacing.s + 2,
              AppSpacing.m,
              AppSpacing.s + 2,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    UserAvatar(userId: revision.editorId, radius: 15),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 14,
                        margin: const EdgeInsets.only(top: 4),
                        color: theme.dividerColor,
                      ),
                  ],
                ),
                const SizedBox(width: AppSpacing.s + 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: ProfileResolver(
                              userId: revision.editorId,
                              builder: (context, profile) => Text(
                                profile?.userName ?? 'Someone',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          if (isLatest) ...[
                            const SizedBox(width: AppSpacing.s),
                            _Tag(
                              label: 'Latest',
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 1),
                      Text(
                        [
                          'v${revision.revisionNumber}',
                          if (created != null) formatShortDateTime(created),
                          if (delta != null && delta != 0)
                            '${delta > 0 ? '+' : '−'}${delta.abs()} chars',
                        ].join('  ·  '),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: muted,
                        ),
                      ),
                      if (revision.summary?.isNotEmpty == true)
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(
                            revision.summary!,
                            style: theme.textTheme.bodySmall,
                          ),
                        )
                      else if (!expanded)
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(
                            wikiPlainText(revision.content, maxLength: 90),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: muted,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: Icon(Icons.expand_more, size: 20, color: muted),
                ),
              ],
            ),
          ),
        ),
        if (expanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.m,
              0,
              AppSpacing.m,
              AppSpacing.m,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  constraints: const BoxConstraints(maxHeight: 320),
                  padding: const EdgeInsets.all(AppSpacing.m),
                  decoration: BoxDecoration(
                    color: context.statusColors.hover,
                    borderRadius: BorderRadius.circular(AppRadii.card),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: SingleChildScrollView(
                    child: revision.content.trim().isEmpty
                        ? Text(
                            'This version was empty.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: muted,
                            ),
                          )
                        : WikiMarkdown(
                            data: revision.content,
                            selectable: false,
                          ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.tonalIcon(
                    onPressed: restoring ? null : onRestore,
                    icon: restoring
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.restore, size: 18),
                    label: const Text('Restore this version'),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadii.badge + 2),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
