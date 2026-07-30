import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../guilds/data/models/guild_permissions.dart';
import '../../data/models/wiki_category_dto.dart';
import '../../data/models/wiki_dto.dart';
import '../../data/models/wiki_page_dto.dart';
import '../../data/models/wiki_page_summary_dto.dart';
import '../../data/wiki_repository.dart';
import '../wiki_permissions.dart';
import '../widgets/markdown_toolbar.dart';

/// Shared create/edit form - pass [pageId] to edit that page, omit it to
/// create a new one. [pageId] (rather than a pre-loaded `WikiPageDto`) keeps
/// this screen reachable by a plain go_router path - it fetches the page
/// itself, the same way every other guild screen fetches its own data on
/// open. Pops with `true` on a successful save so the caller refetches.
class WikiEditorScreen extends StatefulWidget {
  const WikiEditorScreen({super.key, required this.guildId, this.pageId});

  final String guildId;
  final String? pageId;

  bool get isEditing => pageId != null;

  @override
  State<WikiEditorScreen> createState() => _WikiEditorScreenState();
}

class _WikiEditorScreenState extends State<WikiEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();

  String? _categoryId;
  String? _parentPageId;
  bool _isPinned = false;
  WikiVisibility _visibility = WikiVisibility.private;
  List<String> _tags = [];

  WikiDto? _wiki;
  GuildPermissions _permissions = GuildPermissions.none;
  bool _loading = true;
  String? _loadError;
  bool _showPreview = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final pageId = widget.pageId;
      final results = await Future.wait([
        getIt<WikiRepository>().getWiki(widget.guildId),
        loadGuildPermissions(widget.guildId),
        if (pageId != null)
          getIt<WikiRepository>().getPage(widget.guildId, pageId),
      ]);
      if (!mounted) return;
      setState(() {
        _wiki = results[0] as WikiDto;
        _permissions = results[1] as GuildPermissions;
        _loading = false;
        if (pageId != null) {
          final page = results[2] as WikiPageDto;
          _titleController.text = page.title;
          _contentController.text = page.content;
          _categoryId = page.categoryId;
          _parentPageId = page.parentPageId;
          _isPinned = page.isPinned;
          _visibility = page.visibility;
          _tags = [...page.tags];
        }
      });
    } catch (_) {
      if (mounted) setState(() => _loadError = 'Could not load this page.');
    }
  }

  void _addTag(String value) {
    final tag = value.trim();
    if (tag.isEmpty || _tags.contains(tag)) {
      _tagController.clear();
      return;
    }
    setState(() {
      _tags.add(tag);
      _tagController.clear();
    });
  }

  Future<void> _pickCategory() async {
    final categories = _wiki?.categories ?? const <WikiCategoryDto>[];
    final selected = await showModalBottomSheet<String?>(
      context: context,
      builder: (context) => _PickerSheet<String?>(
        title: 'Category',
        options: [
          const _PickerOption(value: null, label: 'None'),
          for (final category in categories)
            _PickerOption(value: category.id, label: category.name),
        ],
        selected: _categoryId,
      ),
    );
    if (selected != _categoryId) setState(() => _categoryId = selected);
  }

  Future<void> _pickParentPage() async {
    final roots = (_wiki?.pages ?? const <WikiPageSummaryDto>[])
        .where((p) => p.parentPageId == null && p.id != widget.pageId)
        .toList();
    final selected = await showModalBottomSheet<String?>(
      context: context,
      builder: (context) => _PickerSheet<String?>(
        title: 'Parent page',
        options: [
          const _PickerOption(value: null, label: 'None (top level)'),
          for (final page in roots)
            _PickerOption(value: page.id, label: page.title),
        ],
        selected: _parentPageId,
      ),
    );
    if (selected != _parentPageId) setState(() => _parentPageId = selected);
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Give the page a title.')));
      return;
    }
    setState(() => _saving = true);
    try {
      final repository = getIt<WikiRepository>();
      final pageId = widget.pageId;
      if (pageId == null) {
        await repository.createPage(
          widget.guildId,
          title: title,
          content: _contentController.text,
          categoryId: _categoryId,
          parentPageId: _parentPageId,
          visibility: _visibility,
          tags: _tags,
          isPinned: _isPinned,
        );
      } else {
        await repository.updatePage(
          widget.guildId,
          pageId,
          title: title,
          content: _contentController.text,
          categoryId: _categoryId,
          clearCategory: _categoryId == null,
          parentPageId: _parentPageId,
          clearParentPage: _parentPageId == null,
          visibility: _visibility,
          tags: _tags,
          isPinned: _isPinned,
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e, st) {
      debugPrint('wiki save failed: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save this page.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.isEditing ? 'Edit page' : 'New page'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.isEditing ? 'Edit page' : 'New page'),
        ),
        body: Center(child: Text(_loadError!)),
      );
    }

    final canPublish = _permissions.has('PublishWikiPublicly');
    final categoryName =
        _findLabel(
          _wiki?.categories,
          _categoryId,
          (c) => c.id,
          (c) => c.name,
        ) ??
        'None';
    final parentTitle =
        _findLabel(_wiki?.pages, _parentPageId, (p) => p.id, (p) => p.title) ??
        'None (top level)';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit page' : 'New page'),
        actions: [
          IconButton(
            icon: Icon(
              _showPreview ? Icons.edit_outlined : Icons.visibility_outlined,
            ),
            tooltip: _showPreview ? 'Edit' : 'Preview',
            onPressed: () => setState(() => _showPreview = !_showPreview),
          ),
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.m),
        children: [
          TextField(
            controller: _titleController,
            style: theme.textTheme.titleLarge,
            decoration: const InputDecoration(
              hintText: 'Page title',
              border: InputBorder.none,
            ),
          ),
          const Divider(height: AppSpacing.l),
          if (_showPreview) ...[
            if (_contentController.text.trim().isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.l),
                child: Text(
                  'Nothing to preview yet.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              )
            else
              MarkdownBody(data: _contentController.text, selectable: true),
          ] else ...[
            MarkdownToolbar(controller: _contentController),
            const SizedBox(height: AppSpacing.xs),
            TextField(
              controller: _contentController,
              maxLines: 14,
              minLines: 8,
              decoration: const InputDecoration(
                hintText: 'Write in Markdown…',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.l),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.folder_outlined),
            title: const Text('Category'),
            subtitle: Text(categoryName),
            trailing: const Icon(Icons.chevron_right),
            onTap: _pickCategory,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.subdirectory_arrow_right),
            title: const Text('Parent page'),
            subtitle: Text(parentTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: _pickParentPage,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.push_pin_outlined),
            title: const Text('Pinned'),
            value: _isPinned,
            onChanged: (value) => setState(() => _isPinned = value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.public),
            title: const Text('Visible to anyone with a share link'),
            subtitle: canPublish
                ? null
                : const Text("You don't have permission to publish publicly"),
            value: _visibility == WikiVisibility.public,
            onChanged: canPublish
                ? (value) => setState(
                    () => _visibility = value
                        ? WikiVisibility.public
                        : WikiVisibility.private,
                  )
                : null,
          ),
          const SizedBox(height: AppSpacing.s),
          Text('Tags', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final tag in _tags)
                InputChip(
                  label: Text(tag),
                  onDeleted: () => setState(() => _tags.remove(tag)),
                ),
              SizedBox(
                width: 140,
                child: TextField(
                  controller: _tagController,
                  decoration: const InputDecoration(
                    hintText: 'Add tag…',
                    isDense: true,
                  ),
                  onSubmitted: _addTag,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String? _findLabel<T>(
  List<T>? items,
  String? id,
  String Function(T) idOf,
  String Function(T) labelOf,
) {
  if (items == null || id == null) return null;
  for (final item in items) {
    if (idOf(item) == id) return labelOf(item);
  }
  return null;
}

class _PickerOption<T> {
  const _PickerOption({required this.value, required this.label});
  final T value;
  final String label;
}

class _PickerSheet<T> extends StatelessWidget {
  const _PickerSheet({
    required this.title,
    required this.options,
    required this.selected,
  });

  final String title;
  final List<_PickerOption<T>> options;
  final T selected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final option in options)
                  ListTile(
                    title: Text(option.label),
                    trailing: option.value == selected
                        ? const Icon(Icons.check)
                        : null,
                    onTap: () => Navigator.of(context).pop(option.value),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
