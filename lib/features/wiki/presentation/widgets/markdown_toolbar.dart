import 'package:flutter/material.dart';

/// Inserts markdown syntax around the current selection (or at the cursor)
/// in [controller] — the "raw markdown" editing affordance mobile uses in
/// place of Alpine's TipTap WYSIWYG editor.
class MarkdownToolbar extends StatelessWidget {
  const MarkdownToolbar({super.key, required this.controller});

  final TextEditingController controller;

  void _wrapSelection(String prefix, [String? suffix]) {
    final end = suffix ?? prefix;
    final text = controller.text;
    var selection = controller.selection;
    if (!selection.isValid) selection = TextSelection.collapsed(offset: text.length);

    final selected = selection.textInside(text);
    final newText = selection.textBefore(text) + prefix + selected + end + selection.textAfter(text);
    final cursor = selection.start + prefix.length + selected.length + end.length;
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: cursor),
    );
  }

  void _prefixCurrentLine(String prefix) {
    final text = controller.text;
    var selection = controller.selection;
    if (!selection.isValid) selection = TextSelection.collapsed(offset: text.length);

    final lineStart = text.lastIndexOf('\n', (selection.start - 1).clamp(0, text.length)) + 1;
    final newText = text.replaceRange(lineStart, lineStart, prefix);
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: selection.end + prefix.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          IconButton(
            tooltip: 'Bold',
            icon: const Icon(Icons.format_bold),
            onPressed: () => _wrapSelection('**'),
          ),
          IconButton(
            tooltip: 'Italic',
            icon: const Icon(Icons.format_italic),
            onPressed: () => _wrapSelection('_'),
          ),
          IconButton(
            tooltip: 'Heading',
            icon: const Icon(Icons.title),
            onPressed: () => _prefixCurrentLine('## '),
          ),
          IconButton(
            tooltip: 'Bulleted list',
            icon: const Icon(Icons.format_list_bulleted),
            onPressed: () => _prefixCurrentLine('- '),
          ),
          IconButton(
            tooltip: 'Numbered list',
            icon: const Icon(Icons.format_list_numbered),
            onPressed: () => _prefixCurrentLine('1. '),
          ),
          IconButton(
            tooltip: 'Checklist',
            icon: const Icon(Icons.check_box_outlined),
            onPressed: () => _prefixCurrentLine('- [ ] '),
          ),
          IconButton(
            tooltip: 'Link',
            icon: const Icon(Icons.link),
            onPressed: () => _wrapSelection('[', '](url)'),
          ),
          IconButton(
            tooltip: 'Code',
            icon: const Icon(Icons.code),
            onPressed: () => _wrapSelection('`'),
          ),
        ],
      ),
    );
  }
}
