import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/status_colors_extension.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../data/wiki_blocks.dart';
import 'wiki_block_editor.dart';

/// The formatting strip above the keyboard in rich mode.
///
/// Unlike the markdown toolbar, which only ever inserts characters, this one
/// reports state: the button for the block you're standing in is lit, and
/// pressing it again turns the formatting back off. That feedback is most of
/// what makes a block editor feel like one rather than like a text box with
/// buttons over it.
class WikiRichToolbar extends StatelessWidget {
  const WikiRichToolbar({
    super.key,
    required this.controller,
    this.onInsertLink,
  });

  final WikiBlockEditorController controller;
  final VoidCallback? onInsertLink;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: context.statusColors.sidebar,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 48,
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              final block = controller.focusedBlock;
              final isList = block?.isList ?? false;
              return ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                children: [
                  for (var level = 1; level <= 3; level++)
                    _ToolButton(
                      label: 'H$level',
                      tooltip: 'Heading $level',
                      active:
                          block?.kind == WikiBlockKind.heading &&
                          block?.level == level,
                      onTap: () => controller.setKind(
                        WikiBlockKind.heading,
                        level: level,
                      ),
                    ),
                  const _ToolDivider(),
                  _ToolButton(
                    icon: Icons.format_bold,
                    tooltip: 'Bold',
                    onTap: () => controller.wrapInline('**'),
                  ),
                  _ToolButton(
                    icon: Icons.format_italic,
                    tooltip: 'Italic',
                    onTap: () => controller.wrapInline('_'),
                  ),
                  _ToolButton(
                    icon: Icons.format_strikethrough,
                    tooltip: 'Strikethrough',
                    onTap: () => controller.wrapInline('~~'),
                  ),
                  _ToolButton(
                    icon: Icons.code,
                    tooltip: 'Inline code',
                    onTap: () => controller.wrapInline('`'),
                  ),
                  _ToolButton(
                    icon: Icons.link,
                    tooltip: 'Link',
                    onTap: onInsertLink ?? () {},
                  ),
                  const _ToolDivider(),
                  _ToolButton(
                    icon: Icons.check_box_outlined,
                    tooltip: 'Checklist',
                    active: block?.kind == WikiBlockKind.task,
                    onTap: () => controller.setKind(WikiBlockKind.task),
                  ),
                  _ToolButton(
                    icon: Icons.format_list_bulleted,
                    tooltip: 'Bulleted list',
                    active: block?.kind == WikiBlockKind.bullet,
                    onTap: () => controller.setKind(WikiBlockKind.bullet),
                  ),
                  _ToolButton(
                    icon: Icons.format_list_numbered,
                    tooltip: 'Numbered list',
                    active: block?.kind == WikiBlockKind.numbered,
                    onTap: () => controller.setKind(WikiBlockKind.numbered),
                  ),
                  _ToolButton(
                    icon: Icons.format_indent_decrease,
                    tooltip: 'Outdent',
                    enabled: isList && (block?.indent ?? 0) > 0,
                    onTap: () => controller.indent(-1),
                  ),
                  _ToolButton(
                    icon: Icons.format_indent_increase,
                    tooltip: 'Indent',
                    enabled: isList,
                    onTap: () => controller.indent(1),
                  ),
                  const _ToolDivider(),
                  _ToolButton(
                    icon: Icons.format_quote,
                    tooltip: 'Quote',
                    active: block?.kind == WikiBlockKind.quote,
                    onTap: () => controller.setKind(WikiBlockKind.quote),
                  ),
                  _ToolButton(
                    icon: Icons.data_object,
                    tooltip: 'Code block',
                    active: block?.kind == WikiBlockKind.code,
                    onTap: () => controller.setKind(WikiBlockKind.code),
                  ),
                  _ToolButton(
                    icon: Icons.table_chart_outlined,
                    tooltip: 'Table',
                    onTap: () => controller.insertBlock(
                      const WikiBlock(
                        kind: WikiBlockKind.raw,
                        text: '| Column | Column |\n| --- | --- |\n|  |  |',
                      ),
                    ),
                  ),
                  _ToolButton(
                    icon: Icons.horizontal_rule,
                    tooltip: 'Divider',
                    onTap: () => controller.setKind(WikiBlockKind.divider),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    this.icon,
    this.label,
    required this.tooltip,
    required this.onTap,
    this.active = false,
    this.enabled = true,
  });

  final IconData? icon;
  final String? label;
  final String tooltip;
  final VoidCallback onTap;
  final bool active;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = !enabled
        ? theme.colorScheme.onSurface.withValues(alpha: 0.25)
        : active
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withValues(alpha: 0.75);

    return Tooltip(
      message: tooltip,
      child: InkResponse(
        radius: 22,
        // The block's text field has to keep focus through the tap - these
        // actions edit around its selection, and on Android losing focus loses
        // the selection with it.
        canRequestFocus: false,
        onTap: enabled
            ? () {
                HapticFeedback.selectionClick();
                onTap();
              }
            : null,
        child: Container(
          width: 44,
          height: 48,
          alignment: Alignment.center,
          child: Container(
            width: 36,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active
                  ? theme.colorScheme.primary.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadii.chip),
            ),
            child: icon != null
                ? Icon(icon, size: 20, color: color)
                : Text(
                    label!,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
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
