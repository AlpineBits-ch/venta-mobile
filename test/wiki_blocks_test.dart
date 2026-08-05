import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:venta_mobile/features/wiki/data/wiki_blocks.dart';
import 'package:venta_mobile/features/wiki/presentation/widgets/wiki_rich_text.dart';

/// Parse then serialise: the result has to be re-parsable into exactly the
/// same blocks, which is the property that makes the Rich/Markdown toggle safe
/// to flip in either direction as often as you like.
void expectStable(String markdown) {
  final blocks = parseWikiBlocks(markdown);
  final rendered = wikiBlocksToMarkdown(blocks);
  expect(
    parseWikiBlocks(rendered),
    blocks,
    reason: 'round trip changed the document:\n$rendered',
  );
}

void main() {
  group('parseWikiBlocks', () {
    test('splits paragraphs on blank lines and keeps soft wraps', () {
      final blocks = parseWikiBlocks('one\nstill one\n\ntwo');
      expect(blocks, [
        const WikiBlock.paragraph('one\nstill one'),
        const WikiBlock.paragraph('two'),
      ]);
    });

    test('reads headings without their hashes', () {
      final blocks = parseWikiBlocks('# Title\n\n### Deep ###');
      expect(blocks, [
        const WikiBlock(kind: WikiBlockKind.heading, level: 1, text: 'Title'),
        const WikiBlock(kind: WikiBlockKind.heading, level: 3, text: 'Deep'),
      ]);
    });

    test('reads bullets, numbers and tasks', () {
      final blocks = parseWikiBlocks('- a\n\n1. b\n\n- [x] c\n- [ ] d');
      expect(blocks, [
        const WikiBlock(kind: WikiBlockKind.bullet, text: 'a'),
        const WikiBlock(kind: WikiBlockKind.numbered, text: 'b'),
        const WikiBlock(kind: WikiBlockKind.task, text: 'c', checked: true),
        const WikiBlock(kind: WikiBlockKind.task, text: 'd'),
      ]);
    });

    test('nests by relative indent, not by column count', () {
      // Four-space nesting is one level deep, the same as two-space nesting.
      final blocks = parseWikiBlocks('- a\n    - b\n        - c\n- d');
      expect(blocks.map((block) => block.indent), [0, 1, 2, 0]);
    });

    test('keeps a list item continuation with its item', () {
      final blocks = parseWikiBlocks('- item\n  more of it\n- next');
      expect(blocks.first.text, 'item\nmore of it');
      expect(blocks.length, 2);
    });

    test('remembers where a numbered list starts', () {
      final blocks = parseWikiBlocks('3. a\n4. b');
      expect(blocks.first.number, 3);
      expect(wikiBlocksToMarkdown(blocks), '3. a\n4. b');
    });

    test('reads a fenced code block with its language', () {
      final blocks = parseWikiBlocks('```dart\nvoid main() {}\n\nx\n```');
      expect(blocks, [
        const WikiBlock(
          kind: WikiBlockKind.code,
          language: 'dart',
          text: 'void main() {}\n\nx',
        ),
      ]);
    });

    test('a list marker inside a fence is not a list', () {
      final blocks = parseWikiBlocks('```\n- not a bullet\n```');
      expect(blocks.single.kind, WikiBlockKind.code);
      expect(blocks.single.text, '- not a bullet');
    });

    test('reads a quote as one block', () {
      final blocks = parseWikiBlocks('> one\n> two\n\nafter');
      expect(blocks.first.kind, WikiBlockKind.quote);
      expect(blocks.first.text, 'one\ntwo');
      expect(blocks.last, const WikiBlock.paragraph('after'));
    });

    test('--- is a divider, not a bullet', () {
      expect(parseWikiBlocks('---').single.kind, WikiBlockKind.divider);
      expect(parseWikiBlocks('- - -').single.kind, WikiBlockKind.divider);
    });

    test('keeps a table verbatim as a raw block', () {
      const table = '| a | b |\n| --- | --- |\n| 1 | 2 |';
      final blocks = parseWikiBlocks('intro\n\n$table\n\nafter');
      expect(blocks[1], const WikiBlock(kind: WikiBlockKind.raw, text: table));
      expect(blocks.length, 3);
    });

    test('keeps embedded HTML verbatim as a raw block', () {
      final blocks = parseWikiBlocks(
        'text\n\n<details><summary>x</summary></details>\n\nmore',
      );
      expect(blocks[1].kind, WikiBlockKind.raw);
      expect(blocks[1].text, '<details><summary>x</summary></details>');
    });

    test('converts a legacy HTML page before splitting it', () {
      // A page last saved by Alpine's TipTap editor is HTML, not markdown.
      final blocks = parseWikiBlocks(
        '<h2>Title</h2><ul data-type="taskList">'
        '<li data-checked="true"><label><input type="checkbox" checked>'
        '</label><div><p>done</p></div></li></ul>',
      );
      expect(blocks, [
        const WikiBlock(kind: WikiBlockKind.heading, level: 2, text: 'Title'),
        const WikiBlock(kind: WikiBlockKind.task, text: 'done', checked: true),
      ]);
    });

    test('an empty document is no blocks at all', () {
      expect(parseWikiBlocks(''), isEmpty);
      expect(parseWikiBlocks('   \n\n  '), isEmpty);
    });
  });

  group('wikiBlocksToMarkdown', () {
    test('keeps list items adjacent and everything else spaced', () {
      final markdown = wikiBlocksToMarkdown(const [
        WikiBlock(kind: WikiBlockKind.heading, text: 'Title'),
        WikiBlock(kind: WikiBlockKind.bullet, text: 'a'),
        WikiBlock(kind: WikiBlockKind.bullet, text: 'b'),
        WikiBlock.paragraph('after'),
      ]);
      expect(markdown, '# Title\n\n- a\n- b\n\nafter');
    });

    test('separates a bullet list from an ordered one that follows it', () {
      // Without the blank line the ordered items are read as continuations of
      // the bullet list and lose their numbers.
      final markdown = wikiBlocksToMarkdown(const [
        WikiBlock(kind: WikiBlockKind.task, text: 'a'),
        WikiBlock(kind: WikiBlockKind.bullet, text: 'b'),
        WikiBlock(kind: WikiBlockKind.numbered, text: 'c'),
      ]);
      expect(markdown, '- [ ] a\n- b\n\n1. c');
      expect(parseWikiBlocks(markdown).map((block) => block.kind), const [
        WikiBlockKind.task,
        WikiBlockKind.bullet,
        WikiBlockKind.numbered,
      ]);
    });

    test('renumbers an ordered list so an insert cannot leave a gap', () {
      final markdown = wikiBlocksToMarkdown(const [
        WikiBlock(kind: WikiBlockKind.numbered, text: 'a', number: 1),
        WikiBlock(kind: WikiBlockKind.numbered, text: 'b', number: 9),
        WikiBlock(kind: WikiBlockKind.numbered, text: 'c', number: 4),
      ]);
      expect(markdown, '1. a\n2. b\n3. c');
    });

    test('numbers each nesting level independently', () {
      final markdown = wikiBlocksToMarkdown(const [
        WikiBlock(kind: WikiBlockKind.numbered, text: 'a'),
        WikiBlock(kind: WikiBlockKind.numbered, text: 'a1', indent: 1),
        WikiBlock(kind: WikiBlockKind.numbered, text: 'a2', indent: 1),
        WikiBlock(kind: WikiBlockKind.numbered, text: 'b'),
      ]);
      expect(markdown, '1. a\n  1. a1\n  2. a2\n2. b');
    });

    test('drops the empty blocks the editor uses to hold a caret', () {
      final markdown = wikiBlocksToMarkdown(const [
        WikiBlock.paragraph('a'),
        WikiBlock.paragraph('   '),
        WikiBlock.paragraph('b'),
      ]);
      expect(markdown, 'a\n\nb');
    });

    test('indents a list item continuation under its marker', () {
      final markdown = wikiBlocksToMarkdown(const [
        WikiBlock(kind: WikiBlockKind.task, text: 'item\nmore', checked: true),
      ]);
      expect(markdown, '- [x] item\n      more');
    });
  });

  group('round trip', () {
    test('survives a page using everything at once', () {
      expectStable('''
# Title

Some **bold** text with a [link](https://example.com).

## Tasks

- [ ] todo
- [x] done
  - nested bullet

1. first
2. second

> a quote
> over two lines

```dart
void main() {}
```

| a | b |
| --- | --- |
| 1 | 2 |

---

Closing paragraph.
''');
    });

    test('normalises loose markdown without losing any of it', () {
      // Star bullets, four-space nesting and a lazy continuation all still
      // mean the same thing after a trip through the block editor.
      const source = '* a\n    * b\n* c\nlazy continuation';
      final first = parseWikiBlocks(source);
      final rendered = wikiBlocksToMarkdown(first);
      expect(rendered, '- a\n  - b\n- c\n  lazy continuation');
      expect(parseWikiBlocks(rendered), first);
    });
  });

  group('WikiBlockController', () {
    test('hides its sentinel from blockText', () {
      final controller = WikiBlockController(text: 'hello');
      expect(controller.blockText, 'hello');
      expect(controller.text.length, 6);
      controller.dispose();
    });

    test('reports backspace at the very start and puts itself back', () {
      final controller = WikiBlockController(text: 'hello');
      var deletes = 0;
      controller.onDeleteAtStart = () => deletes++;

      // What the platform sends when backspace eats the sentinel.
      controller.value = const TextEditingValue(
        text: 'hello',
        selection: TextSelection.collapsed(offset: 0),
      );

      expect(deletes, 1);
      expect(controller.blockText, 'hello');
      expect(controller.selection.baseOffset, 1);
      controller.dispose();
    });

    test('a replacement that loses the sentinel is not a backspace', () {
      final controller = WikiBlockController(text: 'hello');
      var deletes = 0;
      controller.onDeleteAtStart = () => deletes++;

      // Select all, type "x".
      controller.value = const TextEditingValue(
        text: 'x',
        selection: TextSelection.collapsed(offset: 1),
      );

      expect(deletes, 0);
      expect(controller.blockText, 'x');
      controller.dispose();
    });

    test('keeps the caret from parking in front of the sentinel', () {
      final controller = WikiBlockController(text: 'hi');
      controller.value = controller.value.copyWith(
        selection: const TextSelection.collapsed(offset: 0),
      );
      expect(controller.selection.baseOffset, 1);
      expect(controller.blockOffset, 0);
      controller.dispose();
    });

    test('strips zero-width spaces that arrive by paste', () {
      final controller = WikiBlockController();
      controller.value = const TextEditingValue(text: '\u200Ba\u200Bb');
      expect(controller.blockText, 'ab');
      controller.dispose();
    });
  });

  group('buildWikiInlineSpans', () {
    const base = TextStyle(fontSize: 16);
    const palette = WikiInlinePalette(
      marker: Color(0x44000000),
      activeMarker: Color(0xAA000000),
      link: Color(0xFF0000FF),
      code: Color(0xFF000000),
      codeBackground: Color(0x11000000),
    );

    List<TextSpan> spansOf(String text, {int? caret}) =>
        buildWikiInlineSpans(
          text: text,
          base: base,
          palette: palette,
          caret: caret,
        ).cast<TextSpan>();

    test('draws bold text bold and fades its asterisks', () {
      final spans = spansOf('a **b** c');
      expect(spans.map((span) => span.text), ['a ', '**', 'b', '**', ' c']);
      expect(spans[2].style?.fontWeight, FontWeight.w700);
      expect(spans[1].style?.color, palette.marker);
    });

    test('brings the markers back when the caret is inside the span', () {
      final spans = spansOf('**b**', caret: 3);
      expect(spans.first.style?.color, palette.activeMarker);
    });

    test('a link shows its text, not its target, in the accent colour', () {
      final spans = spansOf('see [docs](https://x.dev)');
      expect(spans.map((span) => span.text), [
        'see ',
        '[',
        'docs',
        '](https://x.dev)',
      ]);
      expect(spans[2].style?.color, palette.link);
      // The URL is still there to edit, just given no room until you go near.
      expect(spans[3].style?.fontSize, lessThan(1));
      expect(spans[3].style?.color, const Color(0x00000000));
    });

    test('the link target comes back when the caret reaches it', () {
      final spans = spansOf('[docs](https://x.dev)', caret: 21);
      expect(spans.last.style?.fontSize, base.fontSize);
      expect(spans.last.style?.color, palette.activeMarker);
    });

    test('backticks win over the emphasis inside them', () {
      final spans = spansOf('`a **b**`');
      expect(spans.map((span) => span.text), ['`', 'a **b**', '`']);
    });

    test('leaves plain text as a single span', () {
      final spans = spansOf('nothing to see');
      expect(spans.single.text, 'nothing to see');
    });
  });
}
