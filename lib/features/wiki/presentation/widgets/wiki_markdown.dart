import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;

import '../../../../core/theme/status_colors_extension.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/adaptive_progress_indicator.dart';
import '../../data/wiki_content.dart';

/// GitHub-flavoured markdown - task lists, tables, strikethrough, autolinks -
/// plus `:shortcode:` emoji, which Alpine's `marked` config also accepts.
///
/// Deliberately *not* [md.ExtensionSet.gitHubWeb]: that one adds GitHub's
/// `> [!NOTE]` alerts, which parse to a `<div>` wrapping `<p>`s, and `<div>`
/// isn't in `flutter_markdown_plus`'s block-tag list - the paragraphs inside
/// it end up parsed as inline children of an inline element and the render
/// falls over.
final _wikiExtensionSet = md.ExtensionSet(
  md.ExtensionSet.gitHubFlavored.blockSyntaxes,
  <md.InlineSyntax>[
    ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes,
    md.EmojiSyntax(),
  ],
);

/// [IntrinsicColumnWidth] plus a few logical pixels of slack.
///
/// A selectable table cell is a `SelectableText`, so its text is laid out by
/// `RenderEditable`, which reserves a caret margin *inside* the width it was
/// given but doesn't add that margin to the intrinsic width it reports. Sized
/// to exactly its intrinsic width, the last character of the widest cell wraps
/// onto its own line - "Member" rendering as "Membe/r". The slack covers the
/// caret gap and the sub-pixel rounding on top of it; a handful of pixels of
/// extra air in a table column is invisible.
///
/// Still an `IntrinsicColumnWidth` subclass on purpose:
/// `flutter_markdown_plus` decides whether to wrap the table in a horizontal
/// scroller with an `is IntrinsicColumnWidth` check, and a table too wide for
/// a phone has to be able to scroll.
class _SlackIntrinsicColumnWidth extends IntrinsicColumnWidth {
  const _SlackIntrinsicColumnWidth();

  /// `RenderEditable` reserves `cursorWidth + caret gap` (3px) inside the
  /// width it is handed; the rest is headroom for the sub-pixel rounding on
  /// top of that.
  static const _slack = 8.0;

  @override
  double maxIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) =>
      super.maxIntrinsicWidth(cells, containerWidth) + _slack;
}

const _monospaceFallback = <String>[
  'monospace', // Android
  'Menlo', // iOS/macOS
  'Consolas', // Windows
  'Courier New',
];

/// The wiki's reading typography, kept in one place so the page view, the
/// editor's preview and the revision previews are literally the same document.
///
/// [MarkdownStyleSheet.fromTheme] gets the colours right but its metrics are
/// tuned for a dense chat bubble - this widens the leading, gives headings
/// asymmetric padding so a heading hugs the text it introduces rather than
/// floating between two paragraphs, and gives code/quotes/tables real
/// containers instead of bare text styles.
MarkdownStyleSheet wikiMarkdownStyleSheet(BuildContext context) {
  final theme = Theme.of(context);
  final colors = theme.colorScheme;
  final onSurface = colors.onSurface;
  final muted = onSurface.withValues(alpha: 0.55);
  final surfaceTint = context.statusColors.hover;

  final code = TextStyle(
    fontFamily: _monospaceFallback.first,
    fontFamilyFallback: _monospaceFallback,
    fontSize: 13.5,
    height: 1.45,
    color: onSurface.withValues(alpha: 0.92),
  );

  return MarkdownStyleSheet.fromTheme(theme).copyWith(
    p: theme.textTheme.bodyLarge?.copyWith(height: 1.62, letterSpacing: 0.05),
    pPadding: EdgeInsets.zero,
    h1: theme.textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.w800,
      height: 1.25,
      letterSpacing: -0.4,
    ),
    h1Padding: const EdgeInsets.only(top: AppSpacing.s, bottom: AppSpacing.xs),
    h2: theme.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w700,
      fontSize: 19,
      height: 1.3,
      letterSpacing: -0.2,
    ),
    h2Padding: const EdgeInsets.only(top: AppSpacing.xs, bottom: 2),
    h3: theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
      fontSize: 16.5,
      height: 1.35,
    ),
    h3Padding: const EdgeInsets.only(top: AppSpacing.xs, bottom: 2),
    h4: theme.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w700,
      color: onSurface,
    ),
    h5: theme.textTheme.titleSmall?.copyWith(color: muted),
    h6: theme.textTheme.labelMedium?.copyWith(
      color: muted,
      letterSpacing: 0.6,
      fontWeight: FontWeight.w700,
    ),
    a: theme.textTheme.bodyLarge?.copyWith(
      color: colors.primary,
      decoration: TextDecoration.underline,
      decorationColor: colors.primary.withValues(alpha: 0.4),
      height: 1.62,
    ),
    em: const TextStyle(fontStyle: FontStyle.italic),
    strong: const TextStyle(fontWeight: FontWeight.w700),
    del: const TextStyle(decoration: TextDecoration.lineThrough),
    code: code.copyWith(backgroundColor: surfaceTint),
    codeblockPadding: const EdgeInsets.all(AppSpacing.m),
    codeblockDecoration: BoxDecoration(
      color: surfaceTint,
      borderRadius: BorderRadius.circular(AppRadii.card),
      border: Border.all(color: theme.dividerColor),
    ),
    blockquote: theme.textTheme.bodyLarge?.copyWith(
      height: 1.55,
      color: onSurface.withValues(alpha: 0.8),
    ),
    blockquotePadding: const EdgeInsets.fromLTRB(
      AppSpacing.m,
      AppSpacing.s + 2,
      AppSpacing.m,
      AppSpacing.s + 2,
    ),
    blockquoteDecoration: BoxDecoration(
      color: colors.primary.withValues(alpha: 0.07),
      borderRadius: const BorderRadius.horizontal(
        left: Radius.circular(3),
        right: Radius.circular(AppRadii.card),
      ),
      border: Border(left: BorderSide(color: colors.primary, width: 3)),
    ),
    horizontalRuleDecoration: BoxDecoration(
      border: Border(top: BorderSide(color: theme.dividerColor)),
    ),
    listBullet: theme.textTheme.bodyLarge?.copyWith(height: 1.62, color: muted),
    listIndent: 22,
    listBulletPadding: const EdgeInsets.only(right: AppSpacing.xs, top: 1),
    blockSpacing: AppSpacing.m - 2,
    // An intrinsic width is what makes `flutter_markdown_plus` put the table
    // in a horizontal scroller - with the default flex width a wide table is
    // squeezed into the viewport one character per column.
    tableColumnWidth: const _SlackIntrinsicColumnWidth(),
    tableBorder: TableBorder.all(color: theme.dividerColor, width: 1),
    tablePadding: EdgeInsets.zero,
    tableCellsPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.s + 2,
      vertical: AppSpacing.s,
    ),
    tableHeadCellsDecoration: BoxDecoration(color: surfaceTint),
    tableHead: theme.textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.w700,
      color: onSurface,
    ),
    tableBody: theme.textTheme.bodyMedium,
    img: theme.textTheme.bodySmall,
    checkbox: theme.textTheme.bodyLarge,
    textScaler: MediaQuery.textScalerOf(context),
  );
}

/// A rendered slice of wiki markdown.
///
/// Wraps [MarkdownBody] with the three things the raw widget doesn't do on its
/// own and the old screens were missing: HTML content is normalised to
/// markdown first, links actually open, and task-list checkboxes are real
/// tappable controls rather than static glyphs.
class WikiMarkdown extends StatefulWidget {
  const WikiMarkdown({
    super.key,
    required this.data,
    this.onTapLink,
    this.onToggleCheckbox,
    this.checkboxIndexOffset = 0,
    this.selectable = true,
  });

  /// Markdown *or* HTML - [normalizeWikiContent] sorts it out.
  final String data;

  final void Function(String href)? onTapLink;

  /// Called with the checkbox's whole-document index and its new state.
  /// Null renders the boxes read-only.
  final void Function(int index, bool checked)? onToggleCheckbox;

  /// Added to every checkbox index reported by [onToggleCheckbox], so a page
  /// split into sections still reports document-wide positions.
  final int checkboxIndexOffset;

  final bool selectable;

  @override
  State<WikiMarkdown> createState() => _WikiMarkdownState();
}

class _WikiMarkdownState extends State<WikiMarkdown> {
  late String _markdown = normalizeWikiContent(widget.data);
  late int _checkboxCount = countWikiCheckboxes(_markdown);

  /// `checkboxBuilder` is handed the checked state and nothing else, so
  /// position has to be inferred from call order - which is document order,
  /// since `MarkdownBuilder` walks the parsed tree once. Wrapping back to zero
  /// when the count is exhausted keeps that honest if the widget re-parses
  /// without this state object being rebuilt.
  int _checkboxCursor = 0;

  @override
  void didUpdateWidget(covariant WikiMarkdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _markdown = normalizeWikiContent(widget.data);
      _checkboxCount = countWikiCheckboxes(_markdown);
      _checkboxCursor = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    _checkboxCursor = 0;
    return MarkdownBody(
      data: _markdown,
      selectable: widget.selectable,
      softLineBreak: true,
      fitContent: false,
      styleSheet: wikiMarkdownStyleSheet(context),
      listItemCrossAxisAlignment: MarkdownListItemCrossAxisAlignment.start,
      extensionSet: _wikiExtensionSet,
      onTapLink: (text, href, title) {
        if (href != null) widget.onTapLink?.call(href);
      },
      checkboxBuilder: _buildCheckbox,
      imageBuilder: (uri, title, alt) => _WikiImage(uri: uri, alt: alt),
    );
  }

  Widget _buildCheckbox(bool checked) {
    if (_checkboxCount > 0 && _checkboxCursor >= _checkboxCount) {
      _checkboxCursor = 0;
    }
    final index = _checkboxCursor++;
    final onToggle = widget.onToggleCheckbox;

    return Padding(
      // Nudged down onto the first line's optical centre - the bullet slot is
      // baseline-aligned against `p`'s 1.62 leading.
      padding: const EdgeInsets.only(top: 3, right: AppSpacing.xs),
      child: WikiCheckbox(
        checked: checked,
        onTap: onToggle == null
            ? null
            : () => onToggle(widget.checkboxIndexOffset + index, !checked),
      ),
    );
  }
}

/// The wiki's task-list box, shared by the reader and the rich editor so a
/// checklist looks identical whether you're reading it or writing it.
class WikiCheckbox extends StatelessWidget {
  const WikiCheckbox({super.key, required this.checked, this.onTap});

  final bool checked;

  /// Null renders the box read-only.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final box = Container(
      width: 19,
      height: 19,
      decoration: BoxDecoration(
        color: checked ? theme.colorScheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: checked
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withValues(alpha: 0.35),
          width: 1.6,
        ),
      ),
      child: checked
          ? Icon(Icons.check, size: 14, color: theme.colorScheme.onPrimary)
          : null,
    );
    if (onTap == null) return box;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: box,
    );
  }
}

/// Wiki images are attachments on the open internet, arbitrary aspect ratio,
/// and frequently missing. Give them a rounded frame, a loading box that
/// doesn't collapse the layout, and a caption when the author wrote one.
class _WikiImage extends StatelessWidget {
  const _WikiImage({required this.uri, this.alt});

  final Uri uri;
  final String? alt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.card),
            child: Image.network(
              uri.toString(),
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) => progress == null
                  ? child
                  : Container(
                      height: 160,
                      alignment: Alignment.center,
                      color: context.statusColors.hover,
                      child: const AdaptiveProgressIndicator(
                        size: 20,
                        strokeWidth: 2,
                      ),
                    ),
              errorBuilder: (context, _, _) => Container(
                height: 96,
                alignment: Alignment.center,
                color: context.statusColors.hover,
                child: Icon(
                  Icons.broken_image_outlined,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
          if (alt != null && alt!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              alt!,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
