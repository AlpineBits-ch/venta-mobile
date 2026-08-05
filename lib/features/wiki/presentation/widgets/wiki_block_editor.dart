import 'package:flutter/material.dart';

import '../../../../core/theme/status_colors_extension.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../data/wiki_blocks.dart';
import 'markdown_toolbar.dart';
import 'wiki_markdown.dart';
import 'wiki_rich_text.dart';

/// A what-you-see-is-what-you-get editor for a wiki page.
///
/// The page is still markdown - this is a *view* over it. Every block owns a
/// text field styled the way the reader will see it (a heading is heading-sized
/// here too, a checkbox is a real checkbox you can tick), and every edit is
/// serialised straight back to markdown through [onChanged]. Which means the
/// markdown editor isn't a different document, just a different lens: the
/// toggle between them is lossless in both directions.
///
/// The parts that don't fit a text field - tables, embedded HTML - are shown
/// rendered with an "edit source" affordance rather than being flattened into
/// something the block model can hold. Nothing is ever dropped for not being
/// understood.
class WikiBlockEditor extends StatefulWidget {
  const WikiBlockEditor({
    super.key,
    required this.markdown,
    required this.onChanged,
    this.controller,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.m,
      AppSpacing.s,
      AppSpacing.m,
      AppSpacing.xl,
    ),
  });

  final String markdown;
  final ValueChanged<String> onChanged;

  /// Lets the formatting toolbar - which lives outside this widget, above the
  /// keyboard - act on whichever block has the caret.
  final WikiBlockEditorController? controller;

  final EdgeInsets padding;

  @override
  State<WikiBlockEditor> createState() => _WikiBlockEditorState();
}

/// Handle the toolbar holds onto. Notifies when the focused block changes so
/// the toolbar can light up the buttons that are currently active.
class WikiBlockEditorController extends ChangeNotifier {
  _WikiBlockEditorState? _state;

  /// The block with the caret, or the last one that had it. Null before the
  /// editor is attached.
  WikiBlock? get focusedBlock => _state?._targetEntry?.block;

  bool get isFocused => _state?._focusedEntry != null;

  /// Text currently selected in the focused block - seeds the link dialog.
  String get selectedText => _state?._selectedText ?? '';

  /// Switches the focused block to [kind], or back to a paragraph if it is
  /// already that kind (so every button is a toggle).
  void setKind(WikiBlockKind kind, {int level = 1}) =>
      _state?._applyKind(kind, level: level);

  void indent(int delta) => _state?._indentFocused(delta);

  void wrapInline(String prefix, [String? suffix]) =>
      _state?._wrapInline(prefix, suffix);

  void insertText(String text) => _state?._insertText(text);

  void insertBlock(WikiBlock block) => _state?._insertAfterFocused(block);

  void _attach(_WikiBlockEditorState state) {
    _state = state;
    // The toolbar is a sibling of the editor, so it may already have been
    // built for this frame - notifying now would mark it dirty mid-build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (identical(_state, state)) _notify();
    });
  }

  void _detach(_WikiBlockEditorState state) {
    if (identical(_state, state)) _state = null;
  }

  void _notify() {
    if (hasListeners) notifyListeners();
  }
}

/// One block's mutable editing state: the model, its controller and its focus.
class _Entry {
  _Entry(this.block) : controller = WikiBlockController(text: block.text);

  WikiBlock block;
  final WikiBlockController controller;
  final FocusNode focus = FocusNode();

  void dispose() {
    controller.dispose();
    focus.dispose();
  }
}

class _WikiBlockEditorState extends State<WikiBlockEditor> {
  final _entries = <_Entry>[];
  _Entry? _focusedEntry;

  /// The markdown this editor last produced, so [didUpdateWidget] can tell a
  /// change that came from here from one that came from the markdown editor.
  String _lastEmitted = '';

  /// Set while the editor is rewriting a block itself, so its own writes don't
  /// come back round as user input.
  bool _rewriting = false;

  @override
  void initState() {
    super.initState();
    _load(widget.markdown);
    widget.controller?._attach(this);
  }

  @override
  void didUpdateWidget(covariant WikiBlockEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.controller, widget.controller)) {
      oldWidget.controller?._detach(this);
      widget.controller?._attach(this);
    }
    if (widget.markdown != oldWidget.markdown &&
        widget.markdown != _lastEmitted) {
      setState(() => _load(widget.markdown));
    }
  }

  @override
  void dispose() {
    widget.controller?._detach(this);
    for (final entry in _entries) {
      entry.dispose();
    }
    super.dispose();
  }

  void _load(String markdown) {
    // The fields holding these are still mounted for the rest of this frame -
    // pulling their controllers out from under them now would tear down a
    // widget mid-update.
    final replaced = [..._entries];
    if (replaced.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (final entry in replaced) {
          entry.dispose();
        }
      });
    }
    _entries
      ..clear()
      ..addAll(parseWikiBlocks(markdown).map(_Entry.new));
    if (_entries.isEmpty) _entries.add(_Entry(const WikiBlock.paragraph()));
    for (final entry in _entries) {
      _attach(entry);
    }
    _focusedEntry = null;
    _lastEmitted = markdown;
  }

  void _attach(_Entry entry) {
    entry.controller.addListener(() => _onTextChanged(entry));
    entry.controller.onDeleteAtStart = () => _onDeleteAtStart(entry);
    entry.focus.addListener(() => _onFocusChanged(entry));
  }

  void _emit() {
    _lastEmitted = wikiBlocksToMarkdown([
      for (final entry in _entries) entry.block,
    ]);
    widget.onChanged(_lastEmitted);
    // Any edit can change which block the caret is in or what kind it is, and
    // the toolbar's lit buttons are how you know.
    widget.controller?._notify();
  }

  // ── Focus ────────────────────────────────────────────────────────────────

  void _onFocusChanged(_Entry entry) {
    if (entry.focus.hasFocus) {
      _focusedEntry = entry;
      widget.controller?._notify();
      return;
    }
    if (_focusedEntry != entry) return;
    // Moving between blocks unfocuses one before focusing the next, so only
    // clear if nothing else has claimed the caret by the end of the frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _focusedEntry != entry || entry.focus.hasFocus) return;
      _focusedEntry = null;
      widget.controller?._notify();
    });
  }

  /// The block a toolbar action applies to: the focused one, or the last block
  /// when the keyboard has been dismissed. Actions refocus it either way, so
  /// the result is always on screen.
  _Entry? get _targetEntry =>
      _focusedEntry ?? (_entries.isEmpty ? null : _entries.last);

  String get _selectedText => _targetEntry?.controller.selectedBlockText ?? '';

  // ── Editing ──────────────────────────────────────────────────────────────

  void _onTextChanged(_Entry entry) {
    if (_rewriting) return;
    final index = _entries.indexOf(entry);
    if (index < 0) return;

    final text = entry.controller.blockText;
    if (text == entry.block.text) return;

    final caret = entry.controller.blockOffset;
    if (entry.block.kind != WikiBlockKind.code &&
        caret > 0 &&
        caret <= text.length &&
        text[caret - 1] == '\n') {
      _onNewline(index, text, caret);
      return;
    }
    if (_applyTrigger(index, text, caret)) return;

    entry.block = entry.block.copyWith(text: text);
    _emit();
  }

  void _onNewline(int index, String text, int caret) {
    final entry = _entries[index];
    final block = entry.block;
    final before = text.substring(0, caret - 1);
    final after = text.substring(caret);

    // ``` + Enter opens a code block rather than leaving three backticks on a
    // line of their own.
    final fence = RegExp(
      r'^[ \t]*(?:`{3,}|~{3,})[ \t]*([\w+#.-]*)$',
    ).firstMatch(before);
    if (fence != null) {
      _rewrite(
        index,
        WikiBlock(
          kind: WikiBlockKind.code,
          text: after,
          language: fence.group(1)!,
        ),
        caret: 0,
      );
      return;
    }

    if (RegExp(r'^ {0,3}([-*_])[ \t]*(?:\1[ \t]*){2,}$').hasMatch(before)) {
      _rewrite(index, const WikiBlock(kind: WikiBlockKind.divider));
      _insertAt(index + 1, WikiBlock.paragraph(after), focus: true);
      return;
    }

    if (block.kind == WikiBlockKind.quote) {
      final lineStart = before.lastIndexOf('\n') + 1;
      if (before.substring(lineStart).trim().isEmpty) {
        // Enter on an empty quote line steps back out of the quote.
        _rewrite(
          index,
          block.copyWith(
            text: lineStart == 0 ? '' : before.substring(0, lineStart - 1),
          ),
        );
        _insertAt(index + 1, WikiBlock.paragraph(after), focus: true);
      } else {
        entry.block = block.copyWith(text: text);
        _emit();
      }
      return;
    }

    if (block.isList && before.trim().isEmpty && after.trim().isEmpty) {
      // Enter on an empty list item steps out one level, then ends the list.
      _rewrite(
        index,
        block.indent > 0
            ? block.copyWith(text: '', indent: block.indent - 1)
            : const WikiBlock.paragraph(),
        caret: 0,
      );
      return;
    }

    _rewrite(index, block.copyWith(text: before), caret: before.length);
    _insertAt(
      index + 1,
      block.isList
          ? block.copyWith(text: after, checked: false)
          : WikiBlock.paragraph(after),
      focus: true,
    );
  }

  /// Backspace with the caret at offset 0.
  void _onDeleteAtStart(_Entry entry) {
    final index = _entries.indexOf(entry);
    if (index < 0) return;
    final block = entry.block;

    // A formatted block loses its formatting first - one backspace to turn a
    // bullet back into a paragraph, a second to merge it upwards.
    if (block.isList && block.indent > 0) {
      _rewrite(index, block.copyWith(indent: block.indent - 1), caret: 0);
      return;
    }
    if (block.kind != WikiBlockKind.paragraph) {
      _rewrite(index, WikiBlock.paragraph(block.text), caret: 0);
      return;
    }

    if (index == 0) return;
    final previous = _entries[index - 1];
    if (!previous.block.isEditable) {
      _removeAt(index - 1);
      return;
    }

    final caret = previous.block.text.length;
    final merged = previous.block.text + block.text;
    _rewriting = true;
    previous.block = previous.block.copyWith(text: merged);
    previous.controller.setBlockText(merged, caret: caret);
    _rewriting = false;
    _removeAt(index);
    previous.focus.requestFocus();
  }

  /// Markdown shorthands that convert the block as you type them: `# `, `- `,
  /// `1. `, `[] `, `> `. Fires only when the caret sits right after the
  /// shorthand, so typing a hyphen mid-sentence is still a hyphen.
  bool _applyTrigger(int index, String text, int caret) {
    final block = _entries[index].block;
    if (block.kind == WikiBlockKind.code ||
        block.kind == WikiBlockKind.quote ||
        !block.isEditable) {
      return false;
    }
    final head = text.substring(0, caret);
    final rest = text.substring(caret);

    final heading = RegExp(r'^(#{1,6}) $').firstMatch(head);
    if (heading != null) {
      final level = heading.group(1)!.length;
      if (block.kind == WikiBlockKind.heading && block.level == level) {
        return false;
      }
      _rewrite(
        index,
        WikiBlock(kind: WikiBlockKind.heading, level: level, text: rest),
        caret: 0,
      );
      return true;
    }

    final task = RegExp(r'^(?:[-*+] )?\[([ xX]?)\] $').firstMatch(head);
    if (task != null && block.kind != WikiBlockKind.task) {
      _rewrite(
        index,
        WikiBlock(
          kind: WikiBlockKind.task,
          text: rest,
          indent: block.indent,
          checked: task.group(1)!.toLowerCase() == 'x',
        ),
        caret: 0,
      );
      return true;
    }

    if (RegExp(r'^[-*+] $').hasMatch(head) &&
        block.kind != WikiBlockKind.bullet) {
      _rewrite(
        index,
        WikiBlock(
          kind: WikiBlockKind.bullet,
          text: rest,
          indent: block.indent,
        ),
        caret: 0,
      );
      return true;
    }

    final numbered = RegExp(r'^(\d{1,9})[.)] $').firstMatch(head);
    if (numbered != null && block.kind != WikiBlockKind.numbered) {
      _rewrite(
        index,
        WikiBlock(
          kind: WikiBlockKind.numbered,
          text: rest,
          indent: block.indent,
          number: int.tryParse(numbered.group(1)!) ?? 1,
        ),
        caret: 0,
      );
      return true;
    }

    if (head == '> ') {
      _rewrite(
        index,
        WikiBlock(kind: WikiBlockKind.quote, text: rest),
        caret: 0,
      );
      return true;
    }
    return false;
  }

  /// Replaces the block at [index] and resyncs its controller without the
  /// rewrite bouncing back through [_onTextChanged].
  void _rewrite(int index, WikiBlock block, {int? caret}) {
    final entry = _entries[index];
    _rewriting = true;
    entry.block = block;
    entry.controller.setBlockText(
      block.text,
      caret: caret ?? entry.controller.blockOffset,
    );
    _rewriting = false;
    setState(() {});
    _emit();
  }

  void _insertAt(
    int index,
    WikiBlock block, {
    bool focus = false,
    int caret = 0,
  }) {
    final entry = _Entry(block);
    _attach(entry);
    setState(() => _entries.insert(index, entry));
    _emit();
    if (!focus) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_entries.contains(entry)) return;
      entry.focus.requestFocus();
      entry.controller.setBlockText(block.text, caret: caret);
    });
  }

  void _removeAt(int index) {
    if (_entries.length <= 1) return;
    final entry = _entries[index];
    if (_focusedEntry == entry) _focusedEntry = null;
    setState(() => _entries.removeAt(index));
    _emit();
    // The removal can be triggered from inside the controller's own value
    // setter; don't pull the object out from under it mid-call.
    WidgetsBinding.instance.addPostFrameCallback((_) => entry.dispose());
  }

  void _appendParagraph() {
    final last = _entries.last;
    if (last.block.kind == WikiBlockKind.paragraph &&
        last.block.text.isEmpty) {
      last.focus.requestFocus();
      return;
    }
    _insertAt(_entries.length, const WikiBlock.paragraph(), focus: true);
  }

  // ── Toolbar actions ──────────────────────────────────────────────────────

  void _applyKind(WikiBlockKind kind, {int level = 1}) {
    final entry = _targetEntry;
    if (entry == null) return;
    final index = _entries.indexOf(entry);
    if (index < 0) return;
    final block = entry.block;

    if (kind == WikiBlockKind.divider) {
      _insertAfterFocused(const WikiBlock(kind: WikiBlockKind.divider));
      return;
    }
    if (!block.isEditable) return;

    final same =
        block.kind == kind &&
        (kind != WikiBlockKind.heading || block.level == level);
    _rewrite(
      index,
      same
          ? WikiBlock.paragraph(block.text)
          : block.copyWith(kind: kind, level: level, checked: false),
      caret: entry.controller.blockOffset,
    );
    entry.focus.requestFocus();
  }

  void _indentFocused(int delta) {
    final entry = _targetEntry;
    if (entry == null || !entry.block.isList) return;
    final index = _entries.indexOf(entry);
    if (index < 0) return;
    final indent = (entry.block.indent + delta).clamp(0, 5);
    if (indent == entry.block.indent) return;
    _rewrite(index, entry.block.copyWith(indent: indent));
    entry.focus.requestFocus();
  }

  void _wrapInline(String prefix, String? suffix) {
    final entry = _targetEntry;
    if (entry == null || !entry.block.isEditable) return;
    MarkdownEditingActions(entry.controller).wrap(prefix, suffix);
    entry.focus.requestFocus();
  }

  void _insertText(String text) {
    final entry = _targetEntry;
    if (entry == null || !entry.block.isEditable) return;
    MarkdownEditingActions(entry.controller).replaceSelection(text);
    entry.focus.requestFocus();
  }

  void _insertAfterFocused(WikiBlock block) {
    final entry = _targetEntry;
    final index = entry == null ? _entries.length - 1 : _entries.indexOf(entry);
    _insertAt(index + 1, block);
    if (block.isEditable) return;
    // Nothing to type into a divider or a table, so leave a paragraph behind
    // it - otherwise inserting one at the end of a page traps the caret.
    if (index + 2 >= _entries.length) {
      _insertAt(index + 2, const WikiBlock.paragraph(), focus: true);
    }
  }

  void _toggleTask(int index) {
    final block = _entries[index].block;
    setState(
      () => _entries[index].block = block.copyWith(checked: !block.checked),
    );
    _emit();
  }

  Future<void> _editSource(int index) async {
    final entry = _entries[index];
    final edited = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _SourceSheet(source: entry.block.text),
    );
    if (edited == null || !mounted) return;
    final blocks = parseWikiBlocks(edited);
    if (blocks.isEmpty) {
      _removeAt(index);
      return;
    }
    _rewrite(index, blocks.first);
    for (var i = 1; i < blocks.length; i++) {
      _insertAt(index + i, blocks[i]);
    }
  }

  Future<void> _showBlockMenu(int index) async {
    final block = _entries[index].block;
    if (!mounted) return;
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!block.isEditable)
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('Edit source'),
                onTap: () => Navigator.of(context).pop('source'),
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete block'),
              onTap: () => Navigator.of(context).pop('delete'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    if (action == 'delete') {
      _removeAt(index);
    } else if (action == 'source') {
      await _editSource(index);
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────

  /// Display numbers for ordered items, recomputed each build so inserting in
  /// the middle of a list renumbers everything below it immediately.
  List<int?> _numbering() {
    final numbers = List<int?>.filled(_entries.length, null);
    final counters = <int, int>{};
    for (var i = 0; i < _entries.length; i++) {
      final block = _entries[i].block;
      if (!block.isList) {
        counters.clear();
        continue;
      }
      counters.removeWhere((indent, _) => indent > block.indent);
      if (block.kind != WikiBlockKind.numbered) continue;
      final previous = counters[block.indent];
      final number = previous == null ? block.number : previous + 1;
      counters[block.indent] = number;
      numbers[i] = number;
    }
    return numbers;
  }

  @override
  Widget build(BuildContext context) {
    final numbers = _numbering();
    return ListView.builder(
      padding: widget.padding,
      itemCount: _entries.length + 1,
      itemBuilder: (context, index) {
        if (index == _entries.length) {
          return _TrailingTap(onTap: _appendParagraph);
        }
        return _BlockRow(
          key: ObjectKey(_entries[index]),
          entry: _entries[index],
          number: numbers[index],
          isFirst: index == 0,
          onToggleTask: () => _toggleTask(index),
          onMenu: () => _showBlockMenu(index),
          onEditSource: () => _editSource(index),
        );
      },
    );
  }
}

// ── Block rendering ────────────────────────────────────────────────────────

const _indentStep = 22.0;

class _BlockRow extends StatelessWidget {
  const _BlockRow({
    super.key,
    required this.entry,
    required this.number,
    required this.isFirst,
    required this.onToggleTask,
    required this.onMenu,
    required this.onEditSource,
  });

  final _Entry entry;
  final int? number;
  final bool isFirst;
  final VoidCallback onToggleTask;
  final VoidCallback onMenu;
  final VoidCallback onEditSource;

  @override
  Widget build(BuildContext context) {
    final block = entry.block;
    switch (block.kind) {
      case WikiBlockKind.divider:
        return _DividerBlock(onMenu: onMenu);
      case WikiBlockKind.raw:
        return _RawBlock(
          source: block.text,
          onEdit: onEditSource,
          onMenu: onMenu,
        );
      case WikiBlockKind.code:
        return _CodeBlock(entry: entry, onMenu: onMenu);
      case WikiBlockKind.quote:
        return _QuoteBlock(entry: entry);
      default:
        return _TextBlock(
          entry: entry,
          number: number,
          isFirst: isFirst,
          onToggleTask: onToggleTask,
        );
    }
  }
}

/// Paragraphs, headings and list items - a gutter plus a field styled the way
/// the reader will see the line.
class _TextBlock extends StatelessWidget {
  const _TextBlock({
    required this.entry,
    required this.number,
    required this.isFirst,
    required this.onToggleTask,
  });

  final _Entry entry;
  final int? number;
  final bool isFirst;
  final VoidCallback onToggleTask;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final block = entry.block;
    final style = wikiBlockTextStyle(theme, block);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.4);

    Widget? gutter;
    switch (block.kind) {
      case WikiBlockKind.bullet:
        gutter = Padding(
          padding: const EdgeInsets.only(top: 5, right: AppSpacing.s),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: muted, shape: BoxShape.circle),
          ),
        );
      case WikiBlockKind.numbered:
        gutter = Padding(
          padding: const EdgeInsets.only(right: AppSpacing.s),
          child: SizedBox(
            width: 18,
            child: Text(
              '${number ?? block.number}.',
              textAlign: TextAlign.right,
              style: style.copyWith(color: muted, fontWeight: FontWeight.w600),
            ),
          ),
        );
      case WikiBlockKind.task:
        gutter = Padding(
          padding: const EdgeInsets.only(top: 3, right: AppSpacing.s),
          child: WikiCheckbox(checked: block.checked, onTap: onToggleTask),
        );
      default:
        gutter = null;
    }

    return Padding(
      padding: EdgeInsets.only(
        left: block.indent * _indentStep,
        top: _topGapFor(block, isFirst),
        bottom: 2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ?gutter,
          Expanded(
            child: _BlockField(
              entry: entry,
              style: style,
              placeholder: _placeholderFor(block),
            ),
          ),
        ],
      ),
    );
  }

  /// Headings get air above them so they read as introducing what follows,
  /// which is the same rhythm `wikiMarkdownStyleSheet` gives the reader.
  static double _topGapFor(WikiBlock block, bool isFirst) {
    if (isFirst) return 0;
    return switch (block.kind) {
      WikiBlockKind.heading => block.level <= 2 ? AppSpacing.m : AppSpacing.s,
      WikiBlockKind.bullet ||
      WikiBlockKind.numbered ||
      WikiBlockKind.task => 2,
      _ => AppSpacing.s,
    };
  }

  static String _placeholderFor(WikiBlock block) => switch (block.kind) {
    WikiBlockKind.heading => 'Heading ${block.level}',
    WikiBlockKind.bullet || WikiBlockKind.numbered => 'List item',
    WikiBlockKind.task => 'To-do',
    _ => "Write, or type '# ', '- ', '1. ' or '[] '",
  };
}

class _QuoteBlock extends StatelessWidget {
  const _QuoteBlock({required this.entry});

  final _Entry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.m,
          AppSpacing.s + 2,
          AppSpacing.s,
          AppSpacing.s + 2,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.07),
          borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(3),
            right: Radius.circular(AppRadii.card),
          ),
          border: Border(
            left: BorderSide(color: theme.colorScheme.primary, width: 3),
          ),
        ),
        child: _BlockField(
          entry: entry,
          style: wikiBlockTextStyle(theme, entry.block),
          placeholder: 'Quote',
        ),
      ),
    );
  }
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.entry, required this.onMenu});

  final _Entry entry;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = wikiBlockTextStyle(theme, entry.block);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.5);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      child: Container(
        decoration: BoxDecoration(
          color: context.statusColors.hover,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: theme.dividerColor),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.m,
          AppSpacing.s,
          AppSpacing.s,
          AppSpacing.m,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.data_object, size: 14, color: muted),
                const SizedBox(width: AppSpacing.xs + 2),
                Text(
                  entry.block.language.isEmpty
                      ? 'Code'
                      : entry.block.language,
                  style: theme.textTheme.labelSmall?.copyWith(color: muted),
                ),
                const Spacer(),
                InkResponse(
                  radius: 18,
                  canRequestFocus: false,
                  onTap: onMenu,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    child: Icon(Icons.more_horiz, size: 18, color: muted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            _BlockField(
              entry: entry,
              style: style,
              placeholder: 'Code',
              styleInline: false,
            ),
          ],
        ),
      ),
    );
  }
}

/// A table or a chunk of HTML: shown the way it will render, edited as source.
class _RawBlock extends StatelessWidget {
  const _RawBlock({
    required this.source,
    required this.onEdit,
    required this.onMenu,
  });

  final String source;
  final VoidCallback onEdit;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.5);
    final isTable = source.trimLeft().startsWith('|');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.card),
        onTap: onEdit,
        onLongPress: onMenu,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(color: theme.dividerColor),
          ),
          padding: const EdgeInsets.all(AppSpacing.s + 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isTable ? Icons.table_chart_outlined : Icons.code,
                    size: 14,
                    color: muted,
                  ),
                  const SizedBox(width: AppSpacing.xs + 2),
                  Text(
                    isTable ? 'Table' : 'Embedded HTML',
                    style: theme.textTheme.labelSmall?.copyWith(color: muted),
                  ),
                  const Spacer(),
                  Text(
                    'Tap to edit',
                    style: theme.textTheme.labelSmall?.copyWith(color: muted),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s),
              IgnorePointer(child: WikiMarkdown(data: source, selectable: false)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DividerBlock extends StatelessWidget {
  const _DividerBlock({required this.onMenu});

  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onMenu,
      onLongPress: onMenu,
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.m - 2),
        child: Divider(height: 1),
      ),
    );
  }
}

/// The text field inside a block, plus the placeholder a `TextField` can't
/// draw for itself here - [WikiBlockController]'s sentinel means the field is
/// never technically empty, so `hintText` would never show.
class _BlockField extends StatelessWidget {
  const _BlockField({
    required this.entry,
    required this.style,
    required this.placeholder,
    this.styleInline = true,
  });

  final _Entry entry;
  final TextStyle style;
  final String placeholder;
  final bool styleInline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: Listenable.merge([entry.controller, entry.focus]),
      builder: (context, _) {
        final showPlaceholder =
            entry.controller.blockText.isEmpty && entry.focus.hasFocus;
        return Stack(
          children: [
            if (showPlaceholder)
              Positioned(
                left: 0,
                top: 0,
                right: 0,
                child: IgnorePointer(
                  child: Text(
                    placeholder,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: style.copyWith(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
            TextField(
              controller: entry.controller,
              focusNode: entry.focus,
              style: style,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textCapitalization: styleInline
                  ? TextCapitalization.sentences
                  : TextCapitalization.none,
              autocorrect: styleInline,
              enableSuggestions: styleInline,
              cursorColor: theme.colorScheme.primary,
              decoration: const InputDecoration(
                filled: false,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Tap target under the last block. Without it, a page ending in a table or a
/// code block has nowhere left to put the caret.
class _TrailingTap extends StatelessWidget {
  const _TrailingTap({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: const SizedBox(height: 140),
    );
  }
}

class _SourceSheet extends StatefulWidget {
  const _SourceSheet({required this.source});

  final String source;

  @override
  State<_SourceSheet> createState() => _SourceSheetState();
}

class _SourceSheetState extends State<_SourceSheet> {
  late final _controller = TextEditingController(text: widget.source);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.m,
            0,
            AppSpacing.m,
            AppSpacing.m,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Edit source', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.m),
              TextField(
                controller: _controller,
                autofocus: true,
                maxLines: 10,
                minLines: 4,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                  fontFamilyFallback: const ['monospace', 'Menlo', 'Consolas'],
                ),
                decoration: const InputDecoration(isDense: true),
              ),
              const SizedBox(height: AppSpacing.m),
              FilledButton(
                onPressed: () =>
                    Navigator.of(context).pop(_controller.text),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The reading typography, block by block, so what you type looks like what
/// gets published. Kept in step with `wikiMarkdownStyleSheet` deliberately -
/// if these two drift, "preview" stops meaning anything.
TextStyle wikiBlockTextStyle(ThemeData theme, WikiBlock block) {
  final text = theme.textTheme;
  final onSurface = theme.colorScheme.onSurface;
  final muted = onSurface.withValues(alpha: 0.55);

  switch (block.kind) {
    case WikiBlockKind.heading:
      return switch (block.level) {
        1 =>
          text.headlineSmall!.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.25,
            letterSpacing: -0.4,
          ),
        2 =>
          text.titleLarge!.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 19,
            height: 1.3,
            letterSpacing: -0.2,
          ),
        3 =>
          text.titleMedium!.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16.5,
            height: 1.35,
          ),
        4 => text.titleSmall!.copyWith(
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
        5 => text.titleSmall!.copyWith(color: muted),
        _ => text.labelMedium!.copyWith(
          color: muted,
          letterSpacing: 0.6,
          fontWeight: FontWeight.w700,
        ),
      };
    case WikiBlockKind.code:
      return text.bodyMedium!.copyWith(
        fontFamily: 'monospace',
        fontFamilyFallback: const [
          'monospace',
          'Menlo',
          'Consolas',
          'Courier New',
        ],
        fontSize: 13.5,
        height: 1.45,
        color: onSurface.withValues(alpha: 0.92),
      );
    case WikiBlockKind.quote:
      return text.bodyLarge!.copyWith(
        height: 1.55,
        color: onSurface.withValues(alpha: 0.8),
      );
    default:
      return text.bodyLarge!.copyWith(height: 1.62, letterSpacing: 0.05);
  }
}
