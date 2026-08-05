/// A wiki page's `content` is *usually* markdown - but not always.
///
/// Alpine's editor is TipTap, and it only started serialising to markdown
/// (`editor.getMarkdown()`) partway through the wiki's life; before that it
/// saved `editor.getHTML()`. Alpine still reads both - `renderWikiMarkdown`
/// runs the content through `marked` only when it doesn't start with `<` -
/// so any page written before that switch is a blob of TipTap HTML sitting in
/// the same field. Handing that to `MarkdownBody` renders the tags as literal
/// text, which is the bulk of "markdown isn't being rendered" on mobile.
///
/// Everything in this file normalises to markdown first, so the rest of the
/// wiki UI only ever deals with one format.
library;

import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

const _blockTags = {
  'address',
  'article',
  'aside',
  'blockquote',
  'body',
  'details',
  'div',
  'figure',
  'figcaption',
  'footer',
  'h1',
  'h2',
  'h3',
  'h4',
  'h5',
  'h6',
  'header',
  'hr',
  'li',
  'main',
  'ol',
  'p',
  'pre',
  'section',
  'table',
  'ul',
};

/// Matches a GFM task-list marker (`- [ ]`, `* [x]`, `1. [ ]`) at line start.
/// Group 1 is everything up to the box so a replacement can keep the original
/// bullet/indent verbatim.
final _taskItemPattern = RegExp(
  r'^([ \t]*(?:[-*+]|\d+[.)])[ \t]+)\[([ xX])\]',
  multiLine: true,
);

final _fencePattern = RegExp(r'^\s{0,3}(`{3,}|~{3,})');
final _headingPattern = RegExp(r'^(#{1,3})[ \t]+(.+?)[ \t]*#*\s*$');

/// TipTap/marked HTML both start the document with a tag; markdown that
/// happens to begin with an inline `<https://…>` autolink would false-positive
/// here, which is exactly the trade Alpine's `isHtmlContent` already makes.
bool isHtmlWikiContent(String content) => content.trimLeft().startsWith('<');

/// Markdown for [content] whatever format it arrived in.
String normalizeWikiContent(String content) =>
    isHtmlWikiContent(content) ? htmlToMarkdown(content) : content;

/// Converts the subset of HTML Alpine's wiki can produce (TipTap's output,
/// plus whatever `marked` emitted for pages that round-tripped) to markdown.
/// Unknown tags degrade to their children rather than disappearing.
String htmlToMarkdown(String source) {
  final document = html_parser.parse(source);
  final body = document.body;
  if (body == null) return source;
  return _blocksOf(body.nodes).join('\n\n').trim();
}

List<String> _blocksOf(List<dom.Node> nodes) {
  final blocks = <String>[];
  final pending = StringBuffer();

  void flush() {
    final text = pending.toString().trim();
    if (text.isNotEmpty) blocks.add(text);
    pending.clear();
  }

  for (final node in nodes) {
    if (node is dom.Element && _blockTags.contains(node.localName)) {
      flush();
      blocks.addAll(_blockOf(node));
    } else {
      pending.write(_inlineOf(node));
    }
  }
  flush();
  return blocks;
}

List<String> _blockOf(dom.Element element) {
  switch (element.localName) {
    case 'h1':
    case 'h2':
    case 'h3':
    case 'h4':
    case 'h5':
    case 'h6':
      final level = int.parse(element.localName!.substring(1));
      final text = _childrenInline(element).trim();
      return text.isEmpty ? const [] : ['${'#' * level} $text'];
    case 'p':
      final text = _childrenInline(element).trim();
      return text.isEmpty ? const [] : [text];
    case 'hr':
      return const ['---'];
    case 'pre':
      return [_codeBlockOf(element)];
    case 'blockquote':
      final inner = _blocksOf(element.nodes);
      if (inner.isEmpty) return const [];
      final quoted = inner
          .join('\n\n')
          .split('\n')
          .map((line) => line.isEmpty ? '>' : '> $line')
          .join('\n');
      return [quoted];
    case 'ul':
    case 'ol':
      final list = _listOf(element);
      return list.isEmpty ? const [] : [list];
    case 'table':
      final table = _tableOf(element);
      return table == null ? const [] : [table];
    default:
      // div/section/li-outside-a-list/… - keep the children, drop the box.
      return _blocksOf(element.nodes);
  }
}

String _listOf(dom.Element list) {
  final ordered = list.localName == 'ol';
  final lines = <String>[];
  var number = _startNumberOf(list);

  for (final item in list.children) {
    if (item.localName != 'li') continue;

    final checkbox = _findCheckbox(item);
    final dataChecked = item.attributes['data-checked'];
    final String marker;
    if (checkbox != null || dataChecked != null) {
      final checked =
          dataChecked == 'true' ||
          (checkbox?.attributes.containsKey('checked') ?? false);
      marker = '- [${checked ? 'x' : ' '}] ';
    } else if (ordered) {
      marker = '${number++}. ';
    } else {
      marker = '- ';
    }

    // TipTap wraps the box in `<label><input><span></span></label>`; `marked`
    // emits a bare `<input>`. Either way the box itself is already encoded in
    // the marker and must not be emitted again as content.
    final content = item.nodes
        .where((node) => !_isCheckboxChrome(node))
        .toList(growable: false);
    final body = _blocksOf(content).join('\n');
    final bodyLines = body.isEmpty ? const [''] : body.split('\n');
    final continuation = ' ' * marker.length;

    lines.add('$marker${bodyLines.first}');
    for (final line in bodyLines.skip(1)) {
      lines.add(line.isEmpty ? '' : '$continuation$line');
    }
  }
  return lines.join('\n');
}

int _startNumberOf(dom.Element list) {
  final start = int.tryParse(list.attributes['start'] ?? '');
  return start ?? 1;
}

String? _tableOf(dom.Element table) {
  final rows = <List<String>>[];
  void collect(dom.Element parent) {
    for (final child in parent.children) {
      if (child.localName == 'tr') {
        rows.add([
          for (final cell in child.children)
            if (cell.localName == 'td' || cell.localName == 'th')
              _childrenInline(cell)
                  .replaceAll('\n', ' ')
                  .replaceAll('|', r'\|')
                  .trim(),
        ]);
      } else {
        collect(child);
      }
    }
  }

  collect(table);
  if (rows.isEmpty) return null;

  var width = 0;
  for (final row in rows) {
    if (row.length > width) width = row.length;
  }
  if (width == 0) return null;

  String render(List<String> cells) {
    final padded = List.generate(
      width,
      (i) => i < cells.length ? cells[i] : '',
    );
    return '| ${padded.join(' | ')} |';
  }

  return [
    render(rows.first),
    '| ${List.filled(width, '---').join(' | ')} |',
    for (final row in rows.skip(1)) render(row),
  ].join('\n');
}

String _codeBlockOf(dom.Element pre) {
  dom.Element? code;
  for (final child in pre.children) {
    if (child.localName == 'code') {
      code = child;
      break;
    }
  }
  final language =
      RegExp(r'language-([\w+#-]+)').firstMatch(code?.className ?? '')?.group(1) ??
      '';
  final body = (code ?? pre).text.replaceAll(RegExp(r'\n+$'), '');
  return '```$language\n$body\n```';
}

String _childrenInline(dom.Element element) =>
    element.nodes.map(_inlineOf).join();

String _inlineOf(dom.Node node) {
  if (node is dom.Text) return node.data.replaceAll(RegExp(r'\s+'), ' ');
  if (node is! dom.Element) return '';

  switch (node.localName) {
    case 'br':
      // Two trailing spaces is markdown's hard line break, and survives the
      // block joining below where a bare `\n` would be re-flowed.
      return '  \n';
    case 'strong':
    case 'b':
      return _emphasise(_childrenInline(node), '**');
    case 'em':
    case 'i':
      return _emphasise(_childrenInline(node), '*');
    case 'del':
    case 's':
    case 'strike':
      return _emphasise(_childrenInline(node), '~~');
    case 'code':
      final text = node.text.trim();
      return text.isEmpty ? '' : '`$text`';
    case 'a':
      final text = _childrenInline(node).trim();
      final href = node.attributes['href'] ?? '';
      if (href.isEmpty) return text;
      return text.isEmpty ? '<$href>' : '[$text]($href)';
    case 'img':
      final src = node.attributes['src'] ?? '';
      if (src.isEmpty) return '';
      return '![${node.attributes['alt'] ?? ''}]($src)';
    case 'input':
      return '';
    default:
      return _childrenInline(node);
  }
}

/// `**bold**` only binds when the delimiters touch the text, so any leading or
/// trailing whitespace inside the tag has to be hoisted outside it.
String _emphasise(String inner, String token) {
  final trimmed = inner.trim();
  if (trimmed.isEmpty) return inner.isEmpty ? '' : ' ';
  final leading = inner.startsWith(RegExp(r'\s')) ? ' ' : '';
  final trailing = RegExp(r'\s$').hasMatch(inner) ? ' ' : '';
  return '$leading$token$trimmed$token$trailing';
}

dom.Element? _findCheckbox(dom.Element element) {
  for (final child in element.children) {
    if (child.localName == 'input' &&
        (child.attributes['type'] ?? '').toLowerCase() == 'checkbox') {
      return child;
    }
    final nested = _findCheckbox(child);
    if (nested != null) return nested;
  }
  return null;
}

bool _isCheckboxChrome(dom.Node node) {
  if (node is! dom.Element) return false;
  if (node.localName == 'input') {
    return (node.attributes['type'] ?? '').toLowerCase() == 'checkbox';
  }
  return node.localName == 'label' && _findCheckbox(node) != null;
}

// ── Task list toggling ─────────────────────────────────────────────────────

/// Flips the [index]-th checkbox (in document order) of [content] to
/// [checked], returning the content to save. Operates on whichever format the
/// page is stored in so a tap never silently rewrites an HTML page as
/// markdown - the same split Alpine's `toggleNthCheckbox` makes.
String toggleWikiCheckbox(String content, int index, bool checked) {
  if (isHtmlWikiContent(content)) {
    return _toggleHtmlCheckbox(content, index, checked);
  }
  var seen = -1;
  return _mapOutsideFences(content, (line) {
    return line.replaceFirstMapped(_taskItemPattern, (match) {
      seen++;
      if (seen != index) return match.group(0)!;
      return '${match.group(1)}[${checked ? 'x' : ' '}]';
    });
  });
}

String _toggleHtmlCheckbox(String content, int index, bool checked) {
  final document = html_parser.parse(content);
  final boxes = <dom.Element>[];
  void walk(dom.Element element) {
    for (final child in element.children) {
      if (child.localName == 'input' &&
          (child.attributes['type'] ?? '').toLowerCase() == 'checkbox') {
        boxes.add(child);
      }
      walk(child);
    }
  }

  final body = document.body;
  if (body == null) return content;
  walk(body);
  if (index < 0 || index >= boxes.length) return content;

  final box = boxes[index];
  if (checked) {
    box.attributes['checked'] = 'checked';
  } else {
    box.attributes.remove('checked');
  }
  // TipTap reads `data-checked` off the item, not the input, when it parses
  // the document back in - leave both consistent.
  for (dom.Element? node = box.parent; node != null; node = node.parent) {
    if (node.localName == 'li') {
      node.attributes['data-checked'] = '$checked';
      break;
    }
  }
  return body.innerHtml;
}

/// How many task-list checkboxes [markdown] renders, used to offset each
/// section's checkbox indices back into whole-document coordinates.
int countWikiCheckboxes(String markdown) {
  var count = 0;
  _mapOutsideFences(markdown, (line) {
    if (_taskItemPattern.hasMatch(line)) count++;
    return line;
  });
  return count;
}

/// Runs [transform] over every line that isn't inside a fenced code block -
/// a `- [ ]` inside a ``` fence is sample text, not a checkbox.
String _mapOutsideFences(String source, String Function(String line) transform) {
  final lines = source.split('\n');
  String? fence;
  for (var i = 0; i < lines.length; i++) {
    final match = _fencePattern.firstMatch(lines[i]);
    if (match != null) {
      final token = match.group(1)!;
      if (fence == null) {
        fence = token[0];
      } else if (token[0] == fence) {
        fence = null;
      }
      continue;
    }
    if (fence == null) lines[i] = transform(lines[i]);
  }
  return lines.join('\n');
}

// ── Sections ───────────────────────────────────────────────────────────────

/// One `##`-delimited slice of a page.
///
/// Pages are rendered a section at a time rather than as one giant
/// `MarkdownBody` so that the outline sheet has something to scroll to, and so
/// a long page builds lazily instead of all at once.
class WikiSection {
  const WikiSection({
    required this.markdown,
    required this.checkboxOffset,
    this.title,
    this.level = 0,
  });

  /// The section's own markdown, heading line included.
  final String markdown;

  /// Index of this section's first checkbox within the whole page, so a tap
  /// can be mapped back to the right line of the stored content.
  final int checkboxOffset;

  /// Null for the lead-in before the first heading.
  final String? title;

  /// 1-3; 0 for the lead-in.
  final int level;
}

/// Splits [markdown] at every `#`/`##`/`###` heading that isn't inside a
/// fenced code block. Always returns at least one section.
List<WikiSection> splitWikiSections(String markdown) {
  final lines = markdown.split('\n');
  final sections = <WikiSection>[];

  var buffer = <String>[];
  String? title;
  var level = 0;
  var checkboxes = 0;

  void close() {
    final body = buffer.join('\n');
    if (title == null && body.trim().isEmpty) return;
    sections.add(
      WikiSection(
        markdown: body,
        checkboxOffset: checkboxes,
        title: title,
        level: level,
      ),
    );
    checkboxes += countWikiCheckboxes(body);
  }

  String? fence;
  for (final line in lines) {
    final fenceMatch = _fencePattern.firstMatch(line);
    if (fenceMatch != null) {
      final token = fenceMatch.group(1)!;
      if (fence == null) {
        fence = token[0];
      } else if (token[0] == fence) {
        fence = null;
      }
      buffer.add(line);
      continue;
    }

    final heading = fence == null ? _headingPattern.firstMatch(line) : null;
    if (heading != null) {
      close();
      buffer = <String>[line];
      title = heading.group(2)!.trim();
      level = heading.group(1)!.length;
    } else {
      buffer.add(line);
    }
  }
  close();

  if (sections.isEmpty) {
    sections.add(WikiSection(markdown: markdown, checkboxOffset: 0));
  }
  return sections;
}

// ── Search / previews ──────────────────────────────────────────────────────

final _stripPatterns = <RegExp, String>{
  RegExp(r'```[\s\S]*?```'): ' ',
  RegExp(r'`([^`]*)`'): r'$1',
  RegExp(r'!\[[^\]]*\]\([^)]*\)'): ' ',
  RegExp(r'\[([^\]]*)\]\([^)]*\)'): r'$1',
  RegExp(r'^\s{0,3}#{1,6}\s+', multiLine: true): '',
  RegExp(r'^\s{0,3}>\s?', multiLine: true): '',
  RegExp(r'^([ \t]*)(?:[-*+]|\d+[.)])[ \t]+(?:\[[ xX]\][ \t]+)?', multiLine: true):
      '',
  RegExp(r'^\s{0,3}([-*_])\s*(?:\1\s*){2,}$', multiLine: true): '',
  RegExp(r'(\*\*|__|~~|\*|_)'): '',
  RegExp(r'\s+'): ' ',
};

/// Rough plain text for a page, for one-line previews and search snippets.
String wikiPlainText(String content, {int maxLength = 160}) {
  var text = normalizeWikiContent(content);
  _stripPatterns.forEach((pattern, replacement) {
    text = text.replaceAllMapped(
      pattern,
      (match) => replacement.replaceAllMapped(
        RegExp(r'\$(\d)'),
        (ref) => match.group(int.parse(ref.group(1)!)) ?? '',
      ),
    );
  });
  text = text.trim();
  if (text.length <= maxLength) return text;
  return '${text.substring(0, maxLength).trimRight()}…';
}
