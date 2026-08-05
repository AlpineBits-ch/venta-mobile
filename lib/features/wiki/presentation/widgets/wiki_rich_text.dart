/// Live inline-markdown styling for the rich editor's text fields.
///
/// A block's text stays markdown while you type it - what changes is that
/// `**bold**` is *drawn* bold and its asterisks fade into the background
/// instead of shouting. They fade rather than disappear on purpose: text a
/// caret can move through but can't be seen is how "why can't I delete this
/// character" bugs happen. Put the caret inside the span and the markers come
/// back to full strength, which is also the cue that you're editing markup.
library;

import 'package:flutter/material.dart';

/// One pass over the line, ordered so the greedier constructs win: a `**` run
/// inside backticks is code, not bold.
final _inlinePattern = RegExp(
  r'(?<code>`[^`\n]+`)'
  r'|(?<link>!?\[[^\]\n]*\]\([^)\n]*\))'
  r'|(?<strong>\*\*(?:[^*\n]|\*(?!\*))+\*\*|__[^_\n]+__)'
  r'|(?<del>~~[^~\n]+~~)'
  r'|(?<em>\*[^*\n]+\*|_[^_\n]+_)',
);

/// Colours for [buildWikiInlineSpans], resolved from the theme once per build.
class WikiInlinePalette {
  const WikiInlinePalette({
    required this.marker,
    required this.activeMarker,
    required this.link,
    required this.code,
    required this.codeBackground,
  });

  factory WikiInlinePalette.of(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    return WikiInlinePalette(
      marker: onSurface.withValues(alpha: 0.28),
      activeMarker: onSurface.withValues(alpha: 0.7),
      link: theme.colorScheme.primary,
      code: onSurface.withValues(alpha: 0.92),
      codeBackground: theme.colorScheme.onSurface.withValues(alpha: 0.07),
    );
  }

  final Color marker;
  final Color activeMarker;
  final Color link;
  final Color code;
  final Color codeBackground;
}

const _monospaceFallback = <String>[
  'monospace',
  'Menlo',
  'Consolas',
  'Courier New',
];

/// Styles the inline markdown in [text] without changing a character of it.
///
/// [caret] is an offset into [text]; the span it lands in shows its markers at
/// full strength. Pass null for a caret-less render.
List<InlineSpan> buildWikiInlineSpans({
  required String text,
  required TextStyle base,
  required WikiInlinePalette palette,
  int? caret,
}) {
  final spans = <InlineSpan>[];
  var cursor = 0;

  void plain(int end) {
    if (end > cursor) spans.add(TextSpan(text: text.substring(cursor, end)));
  }

  for (final match in _inlinePattern.allMatches(text)) {
    plain(match.start);
    final raw = match.group(0)!;
    final active =
        caret != null && caret >= match.start && caret <= match.end;
    final markerStyle = base.copyWith(
      color: active ? palette.activeMarker : palette.marker,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
      decoration: TextDecoration.none,
    );

    void emit(
      String open,
      String body,
      String close,
      TextStyle bodyStyle, {
      TextStyle? markers,
    }) {
      final marker = markers ?? markerStyle;
      if (open.isNotEmpty) spans.add(TextSpan(text: open, style: marker));
      if (body.isNotEmpty) spans.add(TextSpan(text: body, style: bodyStyle));
      if (close.isNotEmpty) spans.add(TextSpan(text: close, style: marker));
    }

    if (match.namedGroup('code') != null) {
      emit(
        '`',
        raw.substring(1, raw.length - 1),
        '`',
        base.copyWith(
          fontFamily: _monospaceFallback.first,
          fontFamilyFallback: _monospaceFallback,
          fontSize: (base.fontSize ?? 16) - 1.5,
          color: palette.code,
          backgroundColor: palette.codeBackground,
        ),
      );
    } else if (match.namedGroup('link') != null) {
      // A URL is the one piece of markup long enough to drown the sentence
      // it's in, so it collapses away entirely until the caret comes near -
      // and it does come near before you can delete into it, because the whole
      // match counts as active.
      final open = raw.startsWith('!') ? '![' : '[';
      final split = raw.indexOf('](');
      emit(
        open,
        raw.substring(open.length, split),
        raw.substring(split),
        base.copyWith(
          color: palette.link,
          decoration: TextDecoration.underline,
          decorationColor: palette.link.withValues(alpha: 0.4),
        ),
        markers: active ? markerStyle : _collapsed(base),
      );
    } else if (match.namedGroup('strong') != null) {
      emit(
        raw.substring(0, 2),
        raw.substring(2, raw.length - 2),
        raw.substring(raw.length - 2),
        base.copyWith(fontWeight: FontWeight.w700),
      );
    } else if (match.namedGroup('del') != null) {
      emit(
        '~~',
        raw.substring(2, raw.length - 2),
        '~~',
        base.copyWith(decoration: TextDecoration.lineThrough),
      );
    } else {
      emit(
        raw.substring(0, 1),
        raw.substring(1, raw.length - 1),
        raw.substring(raw.length - 1),
        base.copyWith(fontStyle: FontStyle.italic),
      );
    }
    cursor = match.end;
  }

  plain(text.length);
  return spans;
}

/// Renders a run of markup at effectively zero size. Not removed from the
/// text - the caret can still be placed in it and backspace still deletes one
/// character at a time - just given no room to shout.
TextStyle _collapsed(TextStyle base) => base.copyWith(
  fontSize: 0.1,
  color: const Color(0x00000000),
  letterSpacing: 0,
  wordSpacing: 0,
  decoration: TextDecoration.none,
);

/// The text controller behind every editable block.
///
/// Two jobs. It renders inline markdown live (see [buildWikiInlineSpans]), and
/// it makes backspace-at-the-start-of-a-block detectable at all.
///
/// The second one needs explaining. A soft keyboard pressing backspace with
/// the caret at offset 0 has nothing to delete, so the platform sends the
/// framework nothing and the editor can't tell the key was ever pressed - yet
/// "backspace on an empty bullet removes it" is the single gesture every
/// list-editing UI is judged on. So the text always carries a zero-width space
/// at offset 0: backspace at the start of a block *does* delete something, the
/// controller sees the sentinel vanish, puts it back and reports the keypress.
/// Everything outside this class works in [blockText], which never sees it.
class WikiBlockController extends TextEditingController {
  WikiBlockController({String text = ''}) : super(text: _sentinel + text);

  static const _sentinel = '\u200B';

  /// Fired when backspace was pressed with the caret at the very start.
  VoidCallback? onDeleteAtStart;

  /// The block's real text, sentinel excluded.
  String get blockText {
    final value = text.startsWith(_sentinel) ? text.substring(1) : text;
    // Defensive: a paste could carry zero-width spaces of its own, and they
    // must not reach the saved document.
    return value.contains(_sentinel) ? value.replaceAll(_sentinel, '') : value;
  }

  /// Caret offset in block coordinates.
  int get blockOffset =>
      (selection.baseOffset - 1).clamp(0, blockText.length).toInt();

  /// The selected text, sentinel excluded.
  String get selectedBlockText {
    if (!selection.isValid || selection.isCollapsed) return '';
    return selection.textInside(text).replaceAll(_sentinel, '');
  }

  /// Replaces the text without going through the sentinel bookkeeping - used
  /// for the editor's own rewrites (autoformat, splits, merges), never for
  /// user input.
  void setBlockText(String value, {int? caret}) {
    final offset = (caret ?? value.length).clamp(0, value.length).toInt();
    super.value = TextEditingValue(
      text: _sentinel + value,
      selection: TextSelection.collapsed(offset: offset + 1),
    );
  }

  @override
  set value(TextEditingValue newValue) {
    if (!newValue.text.startsWith(_sentinel)) {
      // A pure deletion of the sentinel is backspace at offset 0. Anything
      // else that lost it (select-all then type, a paste over everything) is
      // an ordinary edit that just needs the sentinel put back.
      final backspacedAtStart =
          newValue.selection.isCollapsed &&
          newValue.selection.baseOffset == 0 &&
          text.startsWith(_sentinel) &&
          newValue.text == text.substring(1);
      super.value = newValue.copyWith(
        text: _sentinel + newValue.text,
        selection: newValue.selection.isValid
            ? TextSelection(
                baseOffset: newValue.selection.baseOffset + 1,
                extentOffset: newValue.selection.extentOffset + 1,
              )
            : const TextSelection.collapsed(offset: 1),
        composing: TextRange.empty,
      );
      if (backspacedAtStart) onDeleteAtStart?.call();
      return;
    }
    // Nothing may reach in front of the sentinel - not the caret, and not the
    // near end of a select-all, which would otherwise wrap it up inside
    // whatever the toolbar does to the selection.
    final selection = newValue.selection;
    if (selection.isValid &&
        (selection.baseOffset == 0 || selection.extentOffset == 0)) {
      newValue = newValue.copyWith(
        selection: selection.copyWith(
          baseOffset: selection.baseOffset == 0 ? 1 : selection.baseOffset,
          extentOffset: selection.extentOffset == 0
              ? 1
              : selection.extentOffset,
        ),
      );
    }
    super.value = newValue;
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    // Mid-composition (CJK input, Android autocorrect) the framework wants its
    // own underlined run and the offsets are in flux - leave it alone.
    if (withComposing && value.isComposingRangeValid) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }
    final base = style ?? const TextStyle();
    return TextSpan(
      style: base,
      children: buildWikiInlineSpans(
        text: text,
        base: base,
        palette: WikiInlinePalette.of(context),
        caret: selection.isValid ? selection.baseOffset : null,
      ),
    );
  }
}
