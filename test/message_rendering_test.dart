import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:venta_mobile/features/messaging/presentation/widgets/thread_view.dart';

/// The parts of message rendering whose behaviour is a deliberate copy of
/// Alpine's, and which nothing else would notice going wrong.
///
/// All three are silent failures in production. A jumbo-emoji rule that
/// diverges renders the same message large on one client and small on the
/// other; a bracket-strip applied in the wrong place either shows punctuation
/// the sender never typed or silently re-enables a link preview they
/// suppressed; and a fenced code block that stops highlighting just looks like
/// a plainer design choice.
void main() {
  group('isOnlyEmojiMessage', () {
    test('a lone emoji, and a short run of them, render large', () {
      expect(isOnlyEmojiMessage('😀'), isTrue);
      expect(isOnlyEmojiMessage('😀😀😀'), isTrue);
      // A ZWJ sequence is one glyph made of several code points, and the ZWJ
      // itself is in the pattern precisely so it does not break the run.
      expect(isOnlyEmojiMessage('👨‍👩‍👧'), isTrue);
      // A variation selector likewise - `❤` and `❤️` are the same expression.
      expect(isOnlyEmojiMessage('❤️'), isTrue);
    });

    test(
      'spaces between emoji do not break the run, other whitespace does',
      () {
        expect(isOnlyEmojiMessage('😀 😀'), isTrue);
        // Only U+0020 is stripped, matching Alpine. A message with a line break
        // in it is a layout rather than a single expression.
        expect(isOnlyEmojiMessage('😀\n😀'), isFalse);
      },
    );

    test('text alongside the emoji keeps it at body size', () {
      expect(isOnlyEmojiMessage('hi'), isFalse);
      expect(isOnlyEmojiMessage('😀 hi'), isFalse);
      expect(isOnlyEmojiMessage(''), isFalse);
      expect(isOnlyEmojiMessage('   '), isFalse);
    });

    test('flags are excluded, however few of them there are', () {
      // Regional indicators pair into one glyph, so a "three emoji" message of
      // flags is six code points and 2.5x turns it into a wall.
      expect(isOnlyEmojiMessage('🇩🇪'), isFalse);
      expect(isOnlyEmojiMessage('🇩🇪🇫🇷'), isFalse);
    });

    test('a long run is capped', () {
      // The cap is on UTF-16 code units, not glyphs - 16 surrogate pairs is 32
      // units and over the 30 Alpine allows.
      expect(isOnlyEmojiMessage('😀' * 15), isTrue);
      expect(isOnlyEmojiMessage('😀' * 16), isFalse);
    });
  });

  group('stripNoPreviewBrackets', () {
    test('takes the brackets off a suppressed link', () {
      expect(
        stripNoPreviewBrackets('see <https://example.com> for more'),
        'see https://example.com for more',
      );
    });

    test('leaves everything else alone', () {
      // No scheme, so this is not the opt-out convention - it is a word in
      // angle brackets, and eating them would corrupt the message.
      expect(stripNoPreviewBrackets('a <b> c'), 'a <b> c');
      expect(
        stripNoPreviewBrackets('plain https://example.com'),
        'plain https://example.com',
      );
    });

    test('handles several on one line', () {
      expect(
        stripNoPreviewBrackets('<https://a.test> and <http://b.test>'),
        'https://a.test and http://b.test',
      );
    });
  });

  group('emojiShortcodeIndex', () {
    test('derives a colon-free shortcode from every name', () {
      expect(emojiShortcodeIndex, isNotEmpty);
      for (final entry in emojiShortcodeIndex.take(200)) {
        expect(entry.shortcode, matches(RegExp(r'^[a-z0-9]+(_[a-z0-9]+)*$')));
        expect(entry.emoji, isNotEmpty);
      }
    });

    test('a substring query still reaches the common shortcodes', () {
      // The dataset has no shortcode ids, so `:joy:` is not a key here the way
      // it is on desktop - the substring match is what keeps it reachable.
      final joy = emojiShortcodeIndex.where((e) => e.shortcode.contains('joy'));
      expect(joy, isNotEmpty);
      expect(
        emojiShortcodeIndex.where((e) => e.shortcode.contains('grin')),
        isNotEmpty,
      );
    });
  });

  group('wikiShareLink', () {
    test('is bare, so the server attaches its own card', () {
      final link = wikiShareLink('guild-1', 'page-2');
      expect(link, 'https://venta.gg/wiki/guild-1/page-2');
      // Bracketing it would suppress the very embed it exists to produce.
      expect(link.startsWith('<'), isFalse);
    });
  });

  group('fenced code blocks', () {
    /// Every `TextSpan` colour in the rendered subtree, which is what tells a
    /// highlighted block apart from a plain one.
    Set<Color?> spanColors(WidgetTester tester) {
      final colors = <Color?>{};
      for (final rich in tester.widgetList<RichText>(find.byType(RichText))) {
        rich.text.visitChildren((span) {
          if (span is TextSpan) colors.add(span.style?.color);
          return true;
        });
      }
      return colors;
    }

    Future<void> pump(WidgetTester tester, String markdown) {
      final theme = ThemeData(brightness: Brightness.dark);
      return tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: MarkdownBody(
              data: markdown,
              builders: {'pre': MessageCodeBlockBuilder(theme: theme)},
            ),
          ),
        ),
      );
    }

    testWidgets('a known language is coloured', (tester) async {
      await pump(tester, '```dart\nfinal x = 1;\n```');
      expect(find.textContaining('final'), findsWidgets);
      // More than one colour means the highlighter ran: a plain block is one
      // colour throughout.
      expect(spanColors(tester).length, greaterThan(1));
    });

    testWidgets('an alias resolves the same way it does on desktop', (
      tester,
    ) async {
      await pump(tester, '```js\nconst x = 1;\n```');
      expect(spanColors(tester).length, greaterThan(1));
    });

    testWidgets('an unknown language falls back to plain text', (tester) async {
      await pump(tester, '```notalanguage\nfinal x = 1;\n```');
      // Still rendered, still readable - just not coloured. Alpine escapes and
      // prints it for exactly this case rather than guessing at the language.
      expect(find.textContaining('final x = 1;'), findsWidgets);
      expect(spanColors(tester).length, 1);
    });

    testWidgets('a fence with no language is left plain', (tester) async {
      await pump(tester, '```\nfinal x = 1;\n```');
      expect(find.textContaining('final x = 1;'), findsWidgets);
      expect(spanColors(tester).length, 1);
    });
  });
}
