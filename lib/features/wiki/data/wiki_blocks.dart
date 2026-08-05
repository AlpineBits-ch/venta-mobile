/// The document model behind the wiki's rich editor.
///
/// The stored format never stops being markdown - the rich editor is a *view*
/// over it. Opening it parses the page into a flat list of [WikiBlock]s, every
/// edit serialises straight back, and the markdown editor is the same string
/// with a different widget on top. That's what makes the two modes a toggle
/// rather than two formats: there is only ever one document.
///
/// The parser is deliberately conservative. Anything it can't model as an
/// editable block - tables, raw HTML, footnote definitions - becomes a
/// [WikiBlockKind.raw] block that holds its source verbatim and is rendered
/// read-only, so switching to rich mode can never drop content it didn't
/// understand.
library;

import 'wiki_content.dart';

enum WikiBlockKind {
  paragraph,
  heading,
  bullet,
  numbered,
  task,
  quote,
  code,
  divider,

  /// Source kept verbatim: tables, HTML, anything unrecognised.
  raw,
}

/// One editable node of a wiki page.
class WikiBlock {
  const WikiBlock({
    required this.kind,
    this.text = '',
    this.level = 1,
    this.indent = 0,
    this.checked = false,
    this.number = 1,
    this.language = '',
  });

  const WikiBlock.paragraph([String text = ''])
    : this(kind: WikiBlockKind.paragraph, text: text);

  final WikiBlockKind kind;

  /// The block's own content with its markers stripped: the heading text
  /// without the `#`, the list item without its bullet, the code without its
  /// fence. Still contains *inline* markdown (`**bold**`, links, …), which is
  /// what the editor styles as you type.
  final String text;

  /// Heading level, 1-6.
  final int level;

  /// List nesting depth, 0 for a top-level item.
  final int indent;

  /// Task-list state.
  final bool checked;

  /// Starting number of the numbered-list run this item begins. Items after
  /// the first are renumbered on serialise, so inserting in the middle of a
  /// list can't leave a gap.
  final int number;

  /// Code fence info string.
  final String language;

  bool get isList =>
      kind == WikiBlockKind.bullet ||
      kind == WikiBlockKind.numbered ||
      kind == WikiBlockKind.task;

  /// Blocks the editor puts a text field on. [WikiBlockKind.divider] and
  /// [WikiBlockKind.raw] are shown, not typed into.
  bool get isEditable =>
      kind != WikiBlockKind.divider && kind != WikiBlockKind.raw;

  WikiBlock copyWith({
    WikiBlockKind? kind,
    String? text,
    int? level,
    int? indent,
    bool? checked,
    int? number,
    String? language,
  }) => WikiBlock(
    kind: kind ?? this.kind,
    text: text ?? this.text,
    level: level ?? this.level,
    indent: indent ?? this.indent,
    checked: checked ?? this.checked,
    number: number ?? this.number,
    language: language ?? this.language,
  );

  @override
  bool operator ==(Object other) =>
      other is WikiBlock &&
      other.kind == kind &&
      other.text == text &&
      other.level == level &&
      other.indent == indent &&
      other.checked == checked &&
      other.number == number &&
      other.language == language;

  @override
  int get hashCode =>
      Object.hash(kind, text, level, indent, checked, number, language);

  @override
  String toString() =>
      'WikiBlock(${kind.name}, indent: $indent, '
      '${kind == WikiBlockKind.heading ? 'h$level, ' : ''}'
      '${kind == WikiBlockKind.task ? '${checked ? 'x' : ' '}, ' : ''}'
      '"${text.replaceAll('\n', r'\n')}")';
}

// ── Parsing ────────────────────────────────────────────────────────────────

final _fencePattern = RegExp(r'^[ \t]*(`{3,}|~{3,})[ \t]*([\w+#.-]*)[ \t]*$');
final _headingPattern = RegExp(r'^ {0,3}(#{1,6})(?:[ \t]+(.*?))?[ \t]*#*[ \t]*$');
final _rulePattern = RegExp(r'^ {0,3}([-*_])[ \t]*(?:\1[ \t]*){2,}$');
final _listPattern = RegExp(r'^([ \t]*)(?:([-*+])|(\d{1,9})([.)]))[ \t]+(.*)$');
final _taskPattern = RegExp(r'^\[([ xX])\][ \t]+(.*)$');
final _quotePattern = RegExp(r'^ {0,3}>[ \t]?(.*)$');
final _htmlPattern = RegExp(r'^ {0,3}<[a-zA-Z!/]');
final _tableDelimiterPattern = RegExp(r'^ {0,3}\|?[ \t:|-]*-[ \t:|-]*\|?[ \t]*$');

/// Turns wiki content into editable blocks. Accepts HTML content too - it goes
/// through [normalizeWikiContent] first, same as everywhere else in the wiki.
List<WikiBlock> parseWikiBlocks(String source) {
  final lines = normalizeWikiContent(source).replaceAll('\r\n', '\n').split('\n');
  final blocks = <WikiBlock>[];

  /// Indent columns of the currently open list, outermost first. Nesting is
  /// relative: a list indented with four spaces is one level deep, not two.
  final columns = <int>[];

  var i = 0;
  while (i < lines.length) {
    final line = lines[i];

    if (line.trim().isEmpty) {
      i++;
      continue;
    }

    final fence = _fencePattern.firstMatch(line);
    if (fence != null) {
      final token = fence.group(1)!;
      final body = <String>[];
      i++;
      while (i < lines.length) {
        final close = _fencePattern.firstMatch(lines[i]);
        if (close != null &&
            close.group(1)![0] == token[0] &&
            close.group(1)!.length >= token.length &&
            close.group(2)!.isEmpty) {
          i++;
          break;
        }
        body.add(lines[i]);
        i++;
      }
      columns.clear();
      blocks.add(
        WikiBlock(
          kind: WikiBlockKind.code,
          text: body.join('\n'),
          language: fence.group(2)!,
        ),
      );
      continue;
    }

    // Before the list check: `---` is a thematic break, not a bullet.
    if (_rulePattern.hasMatch(line)) {
      columns.clear();
      blocks.add(const WikiBlock(kind: WikiBlockKind.divider));
      i++;
      continue;
    }

    final heading = _headingPattern.firstMatch(line);
    if (heading != null) {
      columns.clear();
      blocks.add(
        WikiBlock(
          kind: WikiBlockKind.heading,
          level: heading.group(1)!.length,
          text: (heading.group(2) ?? '').trim(),
        ),
      );
      i++;
      continue;
    }

    if (_quotePattern.hasMatch(line)) {
      final body = <String>[];
      while (i < lines.length) {
        final quoted = _quotePattern.firstMatch(lines[i]);
        if (quoted == null) break;
        body.add(quoted.group(1)!);
        i++;
      }
      columns.clear();
      blocks.add(
        WikiBlock(kind: WikiBlockKind.quote, text: _trimBlank(body).join('\n')),
      );
      continue;
    }

    if (_isTableStart(lines, i)) {
      final start = i;
      while (i < lines.length && lines[i].trimLeft().startsWith('|')) {
        i++;
      }
      columns.clear();
      blocks.add(
        WikiBlock(
          kind: WikiBlockKind.raw,
          text: lines.sublist(start, i).join('\n'),
        ),
      );
      continue;
    }

    if (_htmlPattern.hasMatch(line)) {
      final start = i;
      while (i < lines.length && lines[i].trim().isNotEmpty) {
        i++;
      }
      columns.clear();
      blocks.add(
        WikiBlock(
          kind: WikiBlockKind.raw,
          text: lines.sublist(start, i).join('\n'),
        ),
      );
      continue;
    }

    final item = _listPattern.firstMatch(line);
    if (item != null) {
      final column = _columnOf(item.group(1)!);
      while (columns.isNotEmpty && column < columns.last) {
        columns.removeLast();
      }
      if (columns.isEmpty || column > columns.last) columns.add(column);
      final indent = columns.length - 1;

      var body = item.group(5)!;
      final task = _taskPattern.firstMatch(body);
      if (task != null) body = task.group(2)!;

      i++;
      final continuation = <String>[];
      while (i < lines.length) {
        final next = lines[i];
        if (next.trim().isEmpty) break;
        if (_startsBlock(next) || _isTableStart(lines, i)) break;
        continuation.add(next.trimLeft());
        i++;
      }

      final text = [body, ...continuation].join('\n');
      blocks.add(
        task != null
            ? WikiBlock(
                kind: WikiBlockKind.task,
                text: text,
                indent: indent,
                checked: task.group(1)!.toLowerCase() == 'x',
              )
            : item.group(2) != null
            ? WikiBlock(
                kind: WikiBlockKind.bullet,
                text: text,
                indent: indent,
              )
            : WikiBlock(
                kind: WikiBlockKind.numbered,
                text: text,
                indent: indent,
                number: int.tryParse(item.group(3)!) ?? 1,
              ),
      );
      continue;
    }

    final paragraph = <String>[line];
    i++;
    while (i < lines.length) {
      final next = lines[i];
      if (next.trim().isEmpty) break;
      if (_startsBlock(next) || _isTableStart(lines, i)) break;
      paragraph.add(next);
      i++;
    }
    columns.clear();
    blocks.add(
      WikiBlock(kind: WikiBlockKind.paragraph, text: paragraph.join('\n')),
    );
  }

  return blocks;
}

/// Whether [line] would open a new block, used to decide where a paragraph or
/// a list item's continuation lines stop.
bool _startsBlock(String line) =>
    _fencePattern.hasMatch(line) ||
    _rulePattern.hasMatch(line) ||
    _headingPattern.hasMatch(line) ||
    _quotePattern.hasMatch(line) ||
    _listPattern.hasMatch(line) ||
    _htmlPattern.hasMatch(line);

bool _isTableStart(List<String> lines, int index) {
  if (!lines[index].trimLeft().startsWith('|')) return false;
  if (index + 1 >= lines.length) return false;
  final delimiter = lines[index + 1];
  return delimiter.contains('-') && _tableDelimiterPattern.hasMatch(delimiter);
}

int _columnOf(String indent) {
  var column = 0;
  for (final unit in indent.codeUnits) {
    column += unit == 0x09 ? 4 - (column % 4) : 1;
  }
  return column;
}

List<String> _trimBlank(List<String> lines) {
  var start = 0;
  var end = lines.length;
  while (start < end && lines[start].trim().isEmpty) {
    start++;
  }
  while (end > start && lines[end - 1].trim().isEmpty) {
    end--;
  }
  return lines.sublist(start, end);
}

// ── Serialising ────────────────────────────────────────────────────────────

/// Renders [blocks] back to markdown. Two adjacent list items stay on
/// consecutive lines; everything else is separated by a blank line, which is
/// what keeps the result re-parsable into the same blocks.
String wikiBlocksToMarkdown(List<WikiBlock> blocks) {
  final buffer = StringBuffer();
  final counters = <int, int>{};
  WikiBlock? previous;

  for (final block in blocks) {
    if (block.isList) {
      counters.removeWhere((indent, _) => indent > block.indent);
    } else {
      counters.clear();
    }

    final chunk = _render(block, counters);
    if (chunk == null) continue;

    if (previous != null) {
      buffer.write(_tight(previous, block) ? '\n' : '\n\n');
    }
    buffer.write(chunk);
    previous = block;
  }

  return buffer.toString();
}

/// Whether two blocks belong on consecutive lines rather than either side of
/// a blank one. Only items of one list do - and a bullet followed by a
/// numbered item is *two* lists, which need the blank line between them or the
/// second one gets swallowed by the first.
bool _tight(WikiBlock previous, WikiBlock next) {
  if (!previous.isList || !next.isList) return false;
  bool ordered(WikiBlock block) => block.kind == WikiBlockKind.numbered;
  return ordered(previous) == ordered(next);
}

/// Null for a block with nothing in it - an empty paragraph is the editor's
/// way of holding a caret, not a piece of the document.
String? _render(WikiBlock block, Map<int, int> counters) {
  switch (block.kind) {
    case WikiBlockKind.divider:
      return '---';
    case WikiBlockKind.raw:
      return block.text.trim().isEmpty ? null : block.text;
    case WikiBlockKind.code:
      return '```${block.language}\n${block.text}\n```';
    case WikiBlockKind.heading:
      final text = block.text.trim();
      final hashes = '#' * block.level.clamp(1, 6);
      return text.isEmpty ? null : '$hashes $text';
    case WikiBlockKind.quote:
      if (block.text.trim().isEmpty) return null;
      return block.text
          .split('\n')
          .map((line) => line.isEmpty ? '>' : '> $line')
          .join('\n');
    case WikiBlockKind.paragraph:
      return block.text.trim().isEmpty ? null : block.text;
    case WikiBlockKind.bullet:
    case WikiBlockKind.numbered:
    case WikiBlockKind.task:
      final pad = ' ' * (block.indent * 2);
      final String marker;
      if (block.kind == WikiBlockKind.task) {
        marker = '- [${block.checked ? 'x' : ' '}] ';
      } else if (block.kind == WikiBlockKind.numbered) {
        final previous = counters[block.indent];
        final number = previous == null ? block.number : previous + 1;
        counters[block.indent] = number;
        marker = '$number. ';
      } else {
        marker = '- ';
      }
      final lines = block.text.split('\n');
      final continuation = ' ' * (pad.length + marker.length);
      return [
        '$pad$marker${lines.first}',
        for (final line in lines.skip(1))
          if (line.isEmpty) '' else '$continuation$line',
      ].join('\n');
  }
}
