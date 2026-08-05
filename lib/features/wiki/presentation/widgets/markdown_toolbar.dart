import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/status_colors_extension.dart';
import '../../../../core/theme/widget_styles.dart';

/// Matches a list marker at the start of a line: indent, bullet or number,
/// the space after it, and an optional task-list box.
final _listPrefixPattern = RegExp(
  r'^([ \t]*)(?:([-*+])|(\d+)([.)]))([ \t]+)(\[[ xX]\][ \t]+)?',
);

/// Markdown editing actions bound to a [TextEditingController].
///
/// Split out from the toolbar widget because the editor screen also drives
/// these from the keyboard (continuing a list on Enter), and because "toggle
/// this prefix on every selected line" is the kind of off-by-one-prone text
/// surgery that wants to live in one place.
class MarkdownEditingActions {
  const MarkdownEditingActions(this.controller);

  final TextEditingController controller;

  TextSelection get _selection {
    final selection = controller.selection;
    return selection.isValid
        ? selection
        : TextSelection.collapsed(offset: controller.text.length);
  }

  void _set(String text, int caret) {
    controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: caret.clamp(0, text.length)),
    );
  }

  /// Replaces the selection (or inserts at the caret) with [replacement],
  /// leaving the caret just past it.
  void replaceSelection(String replacement) {
    final text = controller.text;
    final selection = _selection;
    final next =
        selection.textBefore(text) + replacement + selection.textAfter(text);
    _set(next, selection.start + replacement.length);
  }

  /// Wraps the selection in [prefix]/[suffix], or unwraps it if it's already
  /// wrapped. With nothing selected, drops the delimiters in and parks the
  /// caret between them so the next keystroke lands inside.
  void wrap(String prefix, [String? suffix]) {
    final end = suffix ?? prefix;
    final text = controller.text;
    final selection = _selection;
    final selected = selection.textInside(text);

    if (selected.isNotEmpty &&
        selected.startsWith(prefix) &&
        selected.endsWith(end) &&
        selected.length >= prefix.length + end.length) {
      final stripped = selected.substring(
        prefix.length,
        selected.length - end.length,
      );
      final next = selection.textBefore(text) + stripped + selection.textAfter(
        text,
      );
      _set(next, selection.start + stripped.length);
      return;
    }

    final next =
        selection.textBefore(text) +
        prefix +
        selected +
        end +
        selection.textAfter(text);
    final caret = selected.isEmpty
        ? selection.start + prefix.length
        : selection.start + prefix.length + selected.length + end.length;
    _set(next, caret);
  }

  /// Adds [prefix] to every line the selection touches, or strips it from all
  /// of them when they already have it.
  void togglePrefix(String prefix) {
    final text = controller.text;
    final selection = _selection;
    final start = _lineStartOf(text, selection.start);
    final end = _lineEndOf(text, selection.end);

    final block = text.substring(start, end);
    final lines = block.split('\n');
    final removing = lines
        .where((line) => line.trim().isNotEmpty)
        .every((line) => line.trimLeft().startsWith(prefix));

    final rewritten = <String>[];
    for (final line in lines) {
      if (line.trim().isEmpty && lines.length > 1) {
        rewritten.add(line);
        continue;
      }
      if (removing) {
        final indent = line.length - line.trimLeft().length;
        rewritten.add(
          line.substring(0, indent) +
              line.trimLeft().substring(prefix.length),
        );
      } else {
        rewritten.add('$prefix$line');
      }
    }

    final replacement = rewritten.join('\n');
    final next = text.replaceRange(start, end, replacement);
    _set(next, start + replacement.length);
  }

  /// Numbered lists have to renumber as they go, so they can't reuse
  /// [togglePrefix]'s "same string on every line".
  void toggleNumberedList() {
    final text = controller.text;
    final selection = _selection;
    final start = _lineStartOf(text, selection.start);
    final end = _lineEndOf(text, selection.end);
    final lines = text.substring(start, end).split('\n');

    final numbered = RegExp(r'^[ \t]*\d+[.)][ \t]+');
    final removing = lines
        .where((line) => line.trim().isNotEmpty)
        .every(numbered.hasMatch);

    final rewritten = <String>[];
    var index = 1;
    for (final line in lines) {
      if (line.trim().isEmpty && lines.length > 1) {
        rewritten.add(line);
        continue;
      }
      rewritten.add(
        removing
            ? line.replaceFirst(numbered, '')
            : '${index++}. ${line.replaceFirst(numbered, '')}',
      );
    }

    final replacement = rewritten.join('\n');
    _set(text.replaceRange(start, end, replacement), start + replacement.length);
  }

  /// `#` → `##` → `###` → plain, on the line under the caret. One button
  /// instead of three, which is what the width of a phone allows.
  void cycleHeading() {
    final text = controller.text;
    final selection = _selection;
    final start = _lineStartOf(text, selection.start);
    final end = _lineEndOf(text, selection.start);
    final line = text.substring(start, end);

    final match = RegExp(r'^(#{1,6})[ \t]+').firstMatch(line);
    final body = match == null ? line : line.substring(match.group(0)!.length);
    final level = match == null ? 0 : match.group(1)!.length;
    final next = switch (level) {
      0 => '# $body',
      1 => '## $body',
      2 => '### $body',
      _ => body,
    };
    _set(text.replaceRange(start, end, next), start + next.length);
  }

  /// Inserts [block] as its own paragraph, adding the blank lines around it
  /// that markdown needs to treat it as one.
  void insertBlock(String block, {int caretOffset = 0}) {
    final text = controller.text;
    final selection = _selection;
    final before = text.substring(0, selection.start);
    final after = text.substring(selection.end);

    final leading = before.isEmpty
        ? ''
        : before.endsWith('\n\n')
        ? ''
        : before.endsWith('\n')
        ? '\n'
        : '\n\n';
    final trailing = after.startsWith('\n') || after.isEmpty ? '\n' : '\n\n';

    final insertion = '$leading$block$trailing';
    _set(
      before + insertion + after,
      before.length +
          leading.length +
          (caretOffset > 0 ? caretOffset : block.length),
    );
  }

  /// Continues a list when Enter is pressed on a list item, and ends the list
  /// when Enter is pressed on an empty one - the behaviour every notes app has
  /// and the single biggest difference between "typing markdown on a phone is
  /// fine" and "typing markdown on a phone is miserable".
  ///
  /// Returns the text/selection to apply, or null when the newline was
  /// ordinary. [previous] is the text as it was before the newline landed.
  static TextEditingValue? continueList(String previous, TextEditingValue now) {
    if (!now.selection.isCollapsed) return null;
    final caret = now.selection.baseOffset;
    if (caret <= 0 || now.text.length != previous.length + 1) return null;
    if (now.text[caret - 1] != '\n') return null;

    final beforeBreak = now.text.substring(0, caret - 1);
    final lineStart = beforeBreak.lastIndexOf('\n') + 1;
    final line = beforeBreak.substring(lineStart);
    final match = _listPrefixPattern.firstMatch(line);
    if (match == null) return null;

    final marker = match.group(0)!;
    if (line.substring(marker.length).trim().isEmpty) {
      // Empty item - Enter should end the list, not add another bullet.
      final text = now.text.replaceRange(lineStart, caret, '');
      return TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: lineStart),
      );
    }

    final indent = match.group(1)!;
    final bullet = match.group(2);
    final number = match.group(3);
    final numberSuffix = match.group(4) ?? '.';
    final space = match.group(5)!;
    final task = match.group(6) == null ? '' : '[ ] ';

    final continuation = bullet != null
        ? '$indent$bullet$space$task'
        : '$indent${(int.tryParse(number ?? '') ?? 1) + 1}'
              '$numberSuffix$space$task';

    final text = now.text.replaceRange(caret, caret, continuation);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: caret + continuation.length),
    );
  }

  static int _lineStartOf(String text, int offset) =>
      text.lastIndexOf('\n', (offset - 1).clamp(0, text.length)) + 1;

  static int _lineEndOf(String text, int offset) {
    final index = text.indexOf('\n', offset.clamp(0, text.length));
    return index < 0 ? text.length : index;
  }
}

/// The formatting strip that sits above the keyboard while editing a page.
class MarkdownToolbar extends StatelessWidget {
  const MarkdownToolbar({
    super.key,
    required this.controller,
    this.onInsertLink,
  });

  final TextEditingController controller;

  /// Opens the link composer - the one action that needs more than a
  /// character insertion, so the screen owns it.
  final VoidCallback? onInsertLink;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actions = MarkdownEditingActions(controller);

    return Container(
      decoration: BoxDecoration(
        color: context.statusColors.sidebar,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            children: [
              _ToolButton(
                icon: Icons.title,
                tooltip: 'Heading',
                onTap: actions.cycleHeading,
              ),
              _ToolButton(
                icon: Icons.format_bold,
                tooltip: 'Bold',
                onTap: () => actions.wrap('**'),
              ),
              _ToolButton(
                icon: Icons.format_italic,
                tooltip: 'Italic',
                onTap: () => actions.wrap('_'),
              ),
              _ToolButton(
                icon: Icons.format_strikethrough,
                tooltip: 'Strikethrough',
                onTap: () => actions.wrap('~~'),
              ),
              const _ToolDivider(),
              _ToolButton(
                icon: Icons.check_box_outlined,
                tooltip: 'Checklist',
                onTap: () => actions.togglePrefix('- [ ] '),
              ),
              _ToolButton(
                icon: Icons.format_list_bulleted,
                tooltip: 'Bulleted list',
                onTap: () => actions.togglePrefix('- '),
              ),
              _ToolButton(
                icon: Icons.format_list_numbered,
                tooltip: 'Numbered list',
                onTap: actions.toggleNumberedList,
              ),
              _ToolButton(
                icon: Icons.format_quote,
                tooltip: 'Quote',
                onTap: () => actions.togglePrefix('> '),
              ),
              const _ToolDivider(),
              _ToolButton(
                icon: Icons.link,
                tooltip: 'Link',
                onTap: onInsertLink ?? () => actions.wrap('[', '](url)'),
              ),
              _ToolButton(
                icon: Icons.code,
                tooltip: 'Inline code',
                onTap: () => actions.wrap('`'),
              ),
              _ToolButton(
                icon: Icons.data_object,
                tooltip: 'Code block',
                onTap: () => actions.insertBlock('```\n\n```', caretOffset: 4),
              ),
              _ToolButton(
                icon: Icons.table_chart_outlined,
                tooltip: 'Table',
                onTap: () => actions.insertBlock(
                  '| Column | Column |\n| --- | --- |\n|  |  |',
                  caretOffset: 2,
                ),
              ),
              _ToolButton(
                icon: Icons.horizontal_rule,
                tooltip: 'Divider',
                onTap: () => actions.insertBlock('---'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        radius: 22,
        // The text field must keep focus through the tap: these actions edit
        // around the current selection, and on Android losing focus loses the
        // selection with it.
        canRequestFocus: false,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: SizedBox(
          width: 44,
          height: 48,
          child: Icon(
            icon,
            size: 20,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.75),
          ),
        ),
      ),
    );
  }
}

class _ToolDivider extends StatelessWidget {
  const _ToolDivider();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 1,
        height: 20,
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        color: Theme.of(context).dividerColor,
      ),
    );
  }
}
