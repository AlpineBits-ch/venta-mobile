import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../data/models/wiki_revision_dto.dart';
import '../../data/wiki_repository.dart';

class WikiHistoryScreen extends StatefulWidget {
  const WikiHistoryScreen({super.key, required this.guildId, required this.pageId});

  final String guildId;
  final String pageId;

  @override
  State<WikiHistoryScreen> createState() => _WikiHistoryScreenState();
}

class _WikiHistoryScreenState extends State<WikiHistoryScreen> {
  List<WikiRevisionDto>? _revisions;
  String? _error;
  String? _restoringId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final revisions =
          await getIt<WikiRepository>().getRevisions(widget.guildId, widget.pageId);
      revisions.sort((a, b) => b.revisionNumber.compareTo(a.revisionNumber));
      if (mounted) setState(() => _revisions = revisions);
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not load history.');
    }
  }

  Future<void> _restore(WikiRevisionDto revision) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore this version?'),
        content: Text('Revision ${revision.revisionNumber} will become the current page content.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
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
      await getIt<WikiRepository>().restoreRevision(widget.guildId, widget.pageId, revision.id);
      if (mounted) context.pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Could not restore that version.')));
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
    if (_error != null) {
      body = Center(child: Text(_error!));
    } else if (revisions == null) {
      body = const Center(child: CircularProgressIndicator());
    } else if (revisions.isEmpty) {
      body = Center(
        child: Text(
          'No earlier versions yet.',
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
        ),
      );
    } else {
      body = ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
        itemCount: revisions.length,
        itemBuilder: (context, index) {
          final revision = revisions[index];
          final isRestoring = _restoringId == revision.id;
          return ExpansionTile(
            title: Text('Revision ${revision.revisionNumber}'),
            subtitle: Text(
              revision.summary?.isNotEmpty == true
                  ? revision.summary!
                  : revision.createdAt != null
                      ? _formatDate(revision.createdAt!)
                      : '',
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: MarkdownBody(data: revision.content),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.tonal(
                    onPressed: isRestoring ? null : () => _restore(revision),
                    child: isRestoring
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Restore this version'),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(appBar: AppBar(title: const Text('History')), body: body);
  }

  static String _formatDate(DateTime date) {
    final local = date.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  }
}
