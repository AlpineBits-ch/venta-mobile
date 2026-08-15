import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/routing/back_navigation.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/status_colors_extension.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/adaptive_progress_indicator.dart';
import '../../../../core/widgets/load_failure_view.dart';
import '../../../guilds/data/models/guild_permissions.dart';
import '../../data/models/wiki_dto.dart';
import '../../data/models/wiki_page_dto.dart';
import '../../data/models/wiki_page_summary_dto.dart';
import '../../data/wiki_content.dart';
import '../../data/wiki_editor_prefs.dart';
import '../../data/wiki_repository.dart';
import '../wiki_permissions.dart';
import '../widgets/markdown_toolbar.dart';
import '../widgets/wiki_block_editor.dart';
import '../widgets/wiki_markdown.dart';
import '../widgets/wiki_rich_toolbar.dart';

/// Shared create/edit form - pass [pageId] to edit that page, omit it to
/// create a new one. [pageId] (rather than a pre-loaded `WikiPageDto`) keeps
/// this screen reachable by a plain go_router path - it fetches the page
/// itself, the same way every other guild screen fetches its own data on
/// open.
///
/// The writing surface owns the whole screen: everything that isn't the title
/// or the text - category, parent, pinning, visibility, tags - lives in a
/// sheet behind one button. The previous version stacked those controls under
/// a 14-line text box, which on a phone with the keyboard up left about four
/// visible lines to write a wiki page in.
///
/// Three surfaces over one document. [WikiBlockEditor] is the default: blocks
/// that look the way they will read, with a heading sized like a heading and a
/// checkbox you can tick. The markdown editor is the same string in a plain
/// text field for people who'd rather type the syntax. Preview is the reader's
/// renderer. All three read and write `_contentController.text`, so switching
/// between them is a change of lens, never a conversion.
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
  final _contentFocus = FocusNode();
  final _richController = WikiBlockEditorController();

  String? _categoryId;
  String? _parentPageId;
  bool _isPinned = false;
  WikiVisibility _visibility = WikiVisibility.private;
  List<String> _tags = [];

  late _Snapshot _saved = _Snapshot.empty;

  WikiDto? _wiki;
  GuildPermissions _permissions = GuildPermissions.none;
  bool _loading = true;
  String? _loadError;
  bool _showPreview = false;
  late bool _rich = WikiEditorPrefs.mode == WikiEditorMode.rich;
  bool _saving = false;

  /// Previous content text, so an incoming change can be recognised as "a
  /// newline was just typed" and continue the list the caret is sitting in.
  String _previousContent = '';
  bool _applyingEdit = false;

  @override
  void initState() {
    super.initState();
    _contentController.addListener(_onContentChanged);
    _titleController.addListener(_onDirtyMaybeChanged);
    _load();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _contentFocus.dispose();
    _richController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
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
        if (pageId != null) {
          final page = results[2] as WikiPageDto;
          _titleController.text = page.title;
          // A page last saved by Alpine's WYSIWYG editor may still hold HTML.
          // Editing here is a markdown editor, so convert once on open rather
          // than showing the author a wall of tags they'd have to hand-edit.
          _contentController.text = normalizeWikiContent(page.content);
          _categoryId = page.categoryId;
          _parentPageId = page.parentPageId;
          _isPinned = page.isPinned;
          _visibility = page.visibility;
          _tags = [...page.tags];
        }
        _previousContent = _contentController.text;
        _saved = _snapshot();
        // Last, so the controller writes above don't wake the dirty-tracking
        // listener while the form is still being populated.
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadError = 'Could not load this page.';
        });
      }
    }
  }

  _Snapshot _snapshot() => _Snapshot(
    title: _titleController.text,
    content: _contentController.text,
    categoryId: _categoryId,
    parentPageId: _parentPageId,
    isPinned: _isPinned,
    visibility: _visibility,
    tags: [..._tags],
  );

  bool get _dirty => _snapshot() != _saved;

  void _onDirtyMaybeChanged() {
    // `PopScope.canPop` is read at build time, so the unsaved-changes guard
    // only arms itself if the screen rebuilds when the text changes.
    if (!_loading && mounted) setState(() {});
  }

  /// The rich editor hands back the whole document after every edit. Feeding
  /// it through the same controller everything else reads keeps dirty
  /// tracking, the word count, Preview and saving working unchanged - there is
  /// still exactly one copy of the page in this screen.
  void _onRichChanged(String markdown) {
    if (_contentController.text == markdown) return;
    _applyingEdit = true;
    _contentController.text = markdown;
    _applyingEdit = false;
    _previousContent = markdown;
    _onDirtyMaybeChanged();
  }

  void _onContentChanged() {
    if (_applyingEdit) return;
    // Continuing a list on Enter is the markdown field's job; in rich mode the
    // block editor has already done it structurally.
    if (_rich && !_showPreview) {
      _previousContent = _contentController.text;
      _onDirtyMaybeChanged();
      return;
    }
    final value = _contentController.value;
    final continued = MarkdownEditingActions.continueList(
      _previousContent,
      value,
    );
    if (continued != null) {
      _applyingEdit = true;
      _contentController.value = continued;
      _applyingEdit = false;
      _previousContent = continued.text;
    } else {
      _previousContent = value.text;
    }
    _onDirtyMaybeChanged();
  }

  Future<void> _openSettings() async {
    final wiki = _wiki;
    if (wiki == null) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      builder: (sheetContext) => _PageSettingsSheet(
        wiki: wiki,
        editingPageId: widget.pageId,
        canPublish: _permissions.has('PublishWikiPublicly'),
        categoryId: _categoryId,
        parentPageId: _parentPageId,
        isPinned: _isPinned,
        visibility: _visibility,
        tags: _tags,
        onChanged:
            ({
              required String? categoryId,
              required String? parentPageId,
              required bool isPinned,
              required WikiVisibility visibility,
              required List<String> tags,
            }) {
              setState(() {
                _categoryId = categoryId;
                _parentPageId = parentPageId;
                _isPinned = isPinned;
                _visibility = visibility;
                _tags = tags;
              });
            },
      ),
    );
  }

  Future<void> _insertLink() async {
    final selection = _contentController.selection;
    final selected = _rich
        ? _richController.selectedText
        : selection.isValid
        ? selection.textInside(_contentController.text)
        : '';

    final result = await showDialog<({String text, String url})>(
      context: context,
      builder: (context) => _LinkDialog(initialText: selected),
    );
    if (result == null) return;
    final markdown = '[${result.text}](${result.url})';
    if (_rich) {
      _richController.insertText(markdown);
    } else {
      MarkdownEditingActions(_contentController).replaceSelection(markdown);
    }
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
        final created = await repository.createPage(
          widget.guildId,
          title: title,
          content: _contentController.text,
          categoryId: _categoryId,
          parentPageId: _parentPageId,
          visibility: _visibility,
          tags: _tags,
          isPinned: _isPinned,
        );
        if (!mounted) return;
        setState(() => _saved = _snapshot());
        // Land on the page that was just written rather than back on the
        // index - the next thing anyone wants is to see how it reads.
        context.pushReplacement(
          RoutePaths.serverWikiPagePath(widget.guildId, created.id),
        );
        return;
      }

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
      if (!mounted) return;
      setState(() => _saved = _snapshot());
      Navigator.of(context).pop(true);
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

  Future<bool> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text("This page hasn't been saved yet."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  Future<void> _handleBack() async {
    if (_dirty && !await _confirmDiscard()) return;
    if (!mounted) return;
    BackNavigation.goBack(context, RoutePaths.serverWikiPath(widget.guildId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = widget.isEditing ? 'Edit page' : 'New page';

    if (_loading || _loadError != null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Back',
            onPressed: _handleBack,
          ),
          title: Text(title),
        ),
        body: _loadError != null
            ? LoadFailureView(message: _loadError!, onRetry: _load)
            : const Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    return PopScope(
      canPop: !_dirty || _saving,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        // `Navigator.pop` doesn't consult `PopScope`, so this is the escape
        // hatch out of a guard that just declined the system back gesture.
        final navigator = Navigator.of(context);
        if (await _confirmDiscard()) navigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Back',
            onPressed: _handleBack,
          ),
          title: Text(title),
          actions: [
            IconButton(
              icon: const Icon(Icons.tune),
              tooltip: 'Page settings',
              onPressed: _openSettings,
            ),
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.s),
              child: FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.m,
                    vertical: AppSpacing.s,
                  ),
                  minimumSize: const Size(0, 36),
                ),
                child: _saving
                    ? const AdaptiveProgressIndicator(size: 16, strokeWidth: 2)
                    : const Text('Save'),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(44),
            child: _EditorModeBar(
              surface: _surface,
              wordCount: _wordCount(_contentController.text),
              onChanged: _selectSurface,
            ),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.m,
                AppSpacing.s,
                AppSpacing.m,
                0,
              ),
              child: TextField(
                controller: _titleController,
                readOnly: _showPreview,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 2,
                minLines: 1,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
                decoration: InputDecoration(
                  hintText: 'Page title',
                  hintStyle: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    height: 1.2,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
                  ),
                  filled: false,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.m,
                vertical: AppSpacing.s + 2,
              ),
              child: Divider(height: 1),
            ),
            Expanded(
              child: switch (_surface) {
                _EditorSurface.preview => _buildPreview(),
                _EditorSurface.rich => WikiBlockEditor(
                  markdown: _contentController.text,
                  onChanged: _onRichChanged,
                  controller: _richController,
                ),
                _EditorSurface.markdown => _buildWriter(),
              },
            ),
          ],
        ),
        bottomNavigationBar: switch (_surface) {
          _EditorSurface.preview => null,
          _EditorSurface.rich => WikiRichToolbar(
            controller: _richController,
            onInsertLink: _insertLink,
          ),
          _EditorSurface.markdown => MarkdownToolbar(
            controller: _contentController,
            onInsertLink: _insertLink,
          ),
        },
      ),
    );
  }

  _EditorSurface get _surface => _showPreview
      ? _EditorSurface.preview
      : _rich
      ? _EditorSurface.rich
      : _EditorSurface.markdown;

  void _selectSurface(_EditorSurface surface) {
    if (surface == _surface) return;
    if (surface == _EditorSurface.preview) FocusScope.of(context).unfocus();
    setState(() {
      _showPreview = surface == _EditorSurface.preview;
      if (surface == _EditorSurface.preview) return;
      _rich = surface == _EditorSurface.rich;
      WikiEditorPrefs.mode = _rich
          ? WikiEditorMode.rich
          : WikiEditorMode.markdown;
    });
  }

  Widget _buildWriter() {
    final theme = Theme.of(context);
    return TextField(
      controller: _contentController,
      focusNode: _contentFocus,
      expands: true,
      maxLines: null,
      minLines: null,
      textAlignVertical: TextAlignVertical.top,
      textCapitalization: TextCapitalization.sentences,
      keyboardType: TextInputType.multiline,
      style: theme.textTheme.bodyLarge?.copyWith(height: 1.55),
      decoration: InputDecoration(
        hintText:
            'Write in Markdown…\n\n'
            '# Heading\n'
            '- [ ] a task\n'
            '**bold**, `code`, [links](https://…)',
        hintMaxLines: 6,
        filled: false,
        contentPadding: const EdgeInsets.fromLTRB(
          AppSpacing.m,
          0,
          AppSpacing.m,
          AppSpacing.m,
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
    );
  }

  Widget _buildPreview() {
    final theme = Theme.of(context);
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Text(
            'Nothing to preview yet.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        0,
        AppSpacing.m,
        AppSpacing.xl,
      ),
      child: WikiMarkdown(data: content, selectable: false),
    );
  }

  static int _wordCount(String text) =>
      text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;
}

/// Snapshot of everything the form owns, so "are there unsaved changes?" is
/// one equality check rather than seven remembered fields.
class _Snapshot {
  const _Snapshot({
    required this.title,
    required this.content,
    required this.categoryId,
    required this.parentPageId,
    required this.isPinned,
    required this.visibility,
    required this.tags,
  });

  static const empty = _Snapshot(
    title: '',
    content: '',
    categoryId: null,
    parentPageId: null,
    isPinned: false,
    visibility: WikiVisibility.private,
    tags: <String>[],
  );

  final String title;
  final String content;
  final String? categoryId;
  final String? parentPageId;
  final bool isPinned;
  final WikiVisibility visibility;
  final List<String> tags;

  @override
  bool operator ==(Object other) =>
      other is _Snapshot &&
      other.title == title &&
      other.content == content &&
      other.categoryId == categoryId &&
      other.parentPageId == parentPageId &&
      other.isPinned == isPinned &&
      other.visibility == visibility &&
      other.tags.length == tags.length &&
      other.tags.every(tags.contains);

  @override
  int get hashCode => Object.hash(
    title,
    content,
    categoryId,
    parentPageId,
    isPinned,
    visibility,
    tags.length,
  );
}

/// Which of the three surfaces is showing. Rich and Markdown are the two ways
/// to write the page; Preview is the reader's view of it.
enum _EditorSurface { rich, markdown, preview }

class _EditorModeBar extends StatelessWidget {
  const _EditorModeBar({
    required this.surface,
    required this.wordCount,
    required this.onChanged,
  });

  final _EditorSurface surface;
  final int wordCount;
  final ValueChanged<_EditorSurface> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        0,
        AppSpacing.m,
        AppSpacing.s,
      ),
      child: Row(
        children: [
          // Scrollable so the three chips never squeeze the word count off a
          // narrow phone - on anything wider they simply all fit.
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _ModeChip(
                    label: 'Rich',
                    icon: Icons.text_fields,
                    selected: surface == _EditorSurface.rich,
                    onTap: () => onChanged(_EditorSurface.rich),
                  ),
                  const SizedBox(width: AppSpacing.xs + 2),
                  _ModeChip(
                    label: 'Markdown',
                    icon: Icons.code,
                    selected: surface == _EditorSurface.markdown,
                    onTap: () => onChanged(_EditorSurface.markdown),
                  ),
                  const SizedBox(width: AppSpacing.xs + 2),
                  _ModeChip(
                    label: 'Preview',
                    icon: Icons.visibility_outlined,
                    selected: surface == _EditorSurface.preview,
                    onTap: () => onChanged(_EditorSurface.preview),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          Text(
            '$wordCount ${wordCount == 1 ? 'word' : 'words'}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: foreground),
              const SizedBox(width: 5),
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

typedef _SettingsChanged =
    void Function({
      required String? categoryId,
      required String? parentPageId,
      required bool isPinned,
      required WikiVisibility visibility,
      required List<String> tags,
    });

class _PageSettingsSheet extends StatefulWidget {
  const _PageSettingsSheet({
    required this.wiki,
    required this.editingPageId,
    required this.canPublish,
    required this.categoryId,
    required this.parentPageId,
    required this.isPinned,
    required this.visibility,
    required this.tags,
    required this.onChanged,
  });

  final WikiDto wiki;
  final String? editingPageId;
  final bool canPublish;
  final String? categoryId;
  final String? parentPageId;
  final bool isPinned;
  final WikiVisibility visibility;
  final List<String> tags;
  final _SettingsChanged onChanged;

  @override
  State<_PageSettingsSheet> createState() => _PageSettingsSheetState();
}

class _PageSettingsSheetState extends State<_PageSettingsSheet> {
  final _tagController = TextEditingController();

  late String? _categoryId = widget.categoryId;
  late String? _parentPageId = widget.parentPageId;
  late bool _isPinned = widget.isPinned;
  late WikiVisibility _visibility = widget.visibility;
  late List<String> _tags = [...widget.tags];

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  void _publish() {
    widget.onChanged(
      categoryId: _categoryId,
      parentPageId: _parentPageId,
      isPinned: _isPinned,
      visibility: _visibility,
      tags: [..._tags],
    );
  }

  void _update(VoidCallback change) {
    setState(change);
    _publish();
  }

  void _addTag(String value) {
    final tag = value.trim().replaceAll(',', '');
    _tagController.clear();
    if (tag.isEmpty || _tags.contains(tag)) return;
    _update(() => _tags = [..._tags, tag]);
  }

  Future<void> _pickParent() async {
    final candidates =
        widget.wiki.pages
            .where(
              (page) =>
                  page.id != widget.editingPageId && page.parentPageId == null,
            )
            .toList()
          ..sort(
            (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
          );

    final selected = await showModalBottomSheet<_Selection<String?>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.75,
      ),
      builder: (context) => _SearchablePicker(
        title: 'Parent page',
        selected: _parentPageId,
        options: [
          const _Option<String?>(value: null, label: 'None (top level)'),
          for (final page in candidates)
            _Option<String?>(value: page.id, label: page.title),
        ],
      ),
    );
    if (selected != null) _update(() => _parentPageId = selected.value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = [...widget.wiki.categories]
      ..sort((a, b) => a.position.compareTo(b.position));
    final parentTitle = _titleOfPage(widget.wiki.pages, _parentPageId);

    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.m,
          0,
          AppSpacing.m,
          AppSpacing.m,
        ),
        children: [
          Text('Page settings', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.l),

          _SettingLabel('Category', icon: Icons.folder_outlined),
          const SizedBox(height: AppSpacing.s),
          Wrap(
            spacing: AppSpacing.xs + 2,
            runSpacing: AppSpacing.xs + 2,
            children: [
              ChoiceChip(
                label: const Text('None'),
                selected: _categoryId == null,
                onSelected: (_) => _update(() => _categoryId = null),
              ),
              for (final category in categories)
                ChoiceChip(
                  label: Text(category.name),
                  selected: _categoryId == category.id,
                  onSelected: (_) => _update(() => _categoryId = category.id),
                ),
            ],
          ),
          if (categories.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                'No categories yet - pages without one are listed under '
                'Uncategorized.',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),

          const SizedBox(height: AppSpacing.l),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.subdirectory_arrow_right),
            title: const Text('Parent page'),
            subtitle: Text(parentTitle ?? 'None (top level)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _pickParent,
          ),

          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.push_pin_outlined),
            title: const Text('Pinned'),
            subtitle: const Text('Shown at the top of the wiki'),
            value: _isPinned,
            onChanged: (value) => _update(() => _isPinned = value),
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.public),
            title: const Text('Public'),
            subtitle: Text(
              widget.canPublish
                  ? 'Visible to anyone with a share link'
                  : "You don't have permission to publish publicly",
            ),
            value: _visibility == WikiVisibility.public,
            onChanged: widget.canPublish
                ? (value) => _update(
                    () => _visibility = value
                        ? WikiVisibility.public
                        : WikiVisibility.private,
                  )
                : null,
          ),

          const SizedBox(height: AppSpacing.m),
          _SettingLabel('Tags', icon: Icons.sell_outlined),
          const SizedBox(height: AppSpacing.s),
          Wrap(
            spacing: AppSpacing.xs + 2,
            runSpacing: AppSpacing.xs + 2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final tag in _tags)
                InputChip(
                  label: Text(tag),
                  onDeleted: () =>
                      _update(() => _tags = [..._tags]..remove(tag)),
                ),
              SizedBox(
                width: 150,
                child: TextField(
                  controller: _tagController,
                  decoration: const InputDecoration(
                    hintText: 'Add tag…',
                    isDense: true,
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: _addTag,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  static String? _titleOfPage(List<WikiPageSummaryDto> pages, String? id) {
    if (id == null) return null;
    for (final page in pages) {
      if (page.id == id) return page.title;
    }
    return null;
  }
}

class _SettingLabel extends StatelessWidget {
  const _SettingLabel(this.label, {required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: AppSpacing.s),
        Text(label, style: theme.textTheme.titleSmall?.copyWith(color: color)),
      ],
    );
  }
}

class _Option<T> {
  const _Option({required this.value, required this.label});

  final T value;
  final String label;
}

/// Wraps the picked value so "dismissed" and "picked None" stay distinct
/// across a nullable-valued sheet.
class _Selection<T> {
  const _Selection(this.value);

  final T value;
}

class _SearchablePicker extends StatefulWidget {
  const _SearchablePicker({
    required this.title,
    required this.options,
    required this.selected,
  });

  final String title;
  final List<_Option<String?>> options;
  final String? selected;

  @override
  State<_SearchablePicker> createState() => _SearchablePickerState();
}

class _SearchablePickerState extends State<_SearchablePicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = _query.trim().toLowerCase();
    final options = query.isEmpty
        ? widget.options
        : widget.options
              .where((option) => option.label.toLowerCase().contains(query))
              .toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
              child: Text(widget.title, style: theme.textTheme.titleMedium),
            ),
            if (widget.options.length > 8)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.m,
                  AppSpacing.s,
                  AppSpacing.m,
                  0,
                ),
                child: TextField(
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Search',
                    isDense: true,
                    prefixIcon: Icon(Icons.search, size: 20),
                  ),
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
            const SizedBox(height: AppSpacing.s),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];
                  return ListTile(
                    title: Text(option.label),
                    trailing: option.value == widget.selected
                        ? Icon(Icons.check, color: theme.colorScheme.primary)
                        : null,
                    onTap: () =>
                        Navigator.of(context).pop(_Selection(option.value)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkDialog extends StatefulWidget {
  const _LinkDialog({required this.initialText});

  final String initialText;

  @override
  State<_LinkDialog> createState() => _LinkDialogState();
}

class _LinkDialogState extends State<_LinkDialog> {
  late final _textController = TextEditingController(text: widget.initialText);
  final _urlController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Insert link'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _textController,
            autofocus: widget.initialText.isEmpty,
            decoration: const InputDecoration(labelText: 'Text'),
          ),
          const SizedBox(height: AppSpacing.s),
          TextField(
            controller: _urlController,
            autofocus: widget.initialText.isNotEmpty,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'URL',
              hintText: 'https://',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final url = _urlController.text.trim();
            if (url.isEmpty) return;
            final text = _textController.text.trim();
            Navigator.of(
              context,
            ).pop((text: text.isEmpty ? url : text, url: url));
          },
          child: const Text('Insert'),
        ),
      ],
    );
  }
}
