import 'package:flutter_test/flutter_test.dart';
import 'package:venta_mobile/features/wiki/data/wiki_content.dart';

void main() {
  group('normalizeWikiContent', () {
    test('leaves markdown alone', () {
      const source = '# Title\n\n- [ ] a task\n- [x] a done task';
      expect(normalizeWikiContent(source), source);
    });

    test('converts TipTap task lists to GFM checkboxes', () {
      // The exact shape TipTap's `TaskList`/`TaskItem` extensions serialise -
      // the box lives in a <label> next to a <div><p> holding the text.
      const html =
          '<ul data-type="taskList">'
          '<li data-checked="true" data-type="taskItem">'
          '<label><input type="checkbox" checked><span></span></label>'
          '<div><p>Buy milk</p></div></li>'
          '<li data-checked="false" data-type="taskItem">'
          '<label><input type="checkbox"><span></span></label>'
          '<div><p>Feed cat</p></div></li>'
          '</ul>';
      expect(normalizeWikiContent(html), '- [x] Buy milk\n- [ ] Feed cat');
    });

    test('converts marked-style checkbox items', () {
      const html =
          '<ul><li><input checked="" disabled="" type="checkbox"> done</li>'
          '<li><input disabled="" type="checkbox"> todo</li></ul>';
      expect(normalizeWikiContent(html), '- [x] done\n- [ ] todo');
    });

    test('converts headings, emphasis, links and code', () {
      const html =
          '<h2>Rules</h2><p>Be <strong>nice</strong> and <em>kind</em>. '
          'See <a href="https://venta.gg">the site</a>.</p>'
          '<pre><code class="language-dart">void main() {}</code></pre>';
      expect(normalizeWikiContent(html), '''
## Rules

Be **nice** and *kind*. See [the site](https://venta.gg).

```dart
void main() {}
```''');
    });

    test('converts nested and ordered lists', () {
      const html =
          '<ol><li><p>First</p><ul><li>Inner</li></ul></li>'
          '<li>Second</li></ol>';
      expect(normalizeWikiContent(html), '1. First\n   - Inner\n2. Second');
    });

    test('converts tables and blockquotes', () {
      const html =
          '<table><thead><tr><th>Role</th><th>Who</th></tr></thead>'
          '<tbody><tr><td>Admin</td><td>Ada</td></tr></tbody></table>'
          '<blockquote><p>Careful.</p></blockquote>';
      expect(normalizeWikiContent(html), '''
| Role | Who |
| --- | --- |
| Admin | Ada |

> Careful.''');
    });

    test('keeps unknown wrappers by keeping their children', () {
      const html = '<div><section><p>Still here</p></section></div>';
      expect(normalizeWikiContent(html), 'Still here');
    });
  });

  group('toggleWikiCheckbox', () {
    test('flips the addressed markdown box only', () {
      const source = '- [ ] one\n- [ ] two\n- [ ] three';
      expect(
        toggleWikiCheckbox(source, 1, true),
        '- [ ] one\n- [x] two\n- [ ] three',
      );
    });

    test('unchecks, and keeps the original bullet character', () {
      expect(toggleWikiCheckbox('* [x] one', 0, false), '* [ ] one');
    });

    test('ignores task-looking lines inside fenced code', () {
      const source = '```\n- [ ] not a box\n```\n\n- [ ] real box';
      expect(
        toggleWikiCheckbox(source, 0, true),
        '```\n- [ ] not a box\n```\n\n- [x] real box',
      );
    });

    test('edits HTML content as HTML rather than rewriting the format', () {
      const html =
          '<ul data-type="taskList">'
          '<li data-checked="false" data-type="taskItem">'
          '<label><input type="checkbox"></label><div><p>Task</p></div>'
          '</li></ul>';
      final toggled = toggleWikiCheckbox(html, 0, true);
      expect(isHtmlWikiContent(toggled), isTrue);
      expect(toggled, contains('checked'));
      expect(toggled, contains('data-checked="true"'));
    });
  });

  group('countWikiCheckboxes', () {
    test('counts bullets and numbers but not fenced samples', () {
      const source = '- [ ] a\n1. [x] b\n\n```\n- [ ] c\n```';
      expect(countWikiCheckboxes(source), 2);
    });
  });

  group('splitWikiSections', () {
    test('splits at headings and offsets each section\'s checkboxes', () {
      const source =
          'Intro line\n\n'
          '# One\n- [ ] a\n- [ ] b\n\n'
          '## Two\n- [ ] c';
      final sections = splitWikiSections(source);

      expect(sections.map((s) => s.title), [null, 'One', 'Two']);
      expect(sections.map((s) => s.level), [0, 1, 2]);
      expect(sections.map((s) => s.checkboxOffset), [0, 0, 2]);
    });

    test('does not split on a # inside a fenced block', () {
      const source = '# Real\n\n```\n# not a heading\n```';
      expect(splitWikiSections(source).length, 1);
    });

    test('always returns at least one section', () {
      expect(splitWikiSections('just text').single.title, isNull);
    });
  });

  group('wikiPlainText', () {
    test('strips markdown down to something previewable', () {
      const source = '## Heading\n\nSome **bold** and [a link](https://x.dev).';
      expect(wikiPlainText(source), 'Heading Some bold and a link.');
    });

    test('truncates on the requested length', () {
      final long = 'word ' * 100;
      expect(wikiPlainText(long, maxLength: 20).length, lessThanOrEqualTo(21));
    });
  });
}
