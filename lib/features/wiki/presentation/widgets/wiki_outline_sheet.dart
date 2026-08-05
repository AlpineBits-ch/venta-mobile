import 'package:flutter/material.dart';

import '../../../../core/theme/widget_styles.dart';
import '../../data/wiki_content.dart';

/// "On this page" - the headings of [sections], as somewhere to jump to.
///
/// Resolves to the index *into [sections]* of the chosen heading, or null if
/// the sheet was dismissed. A long page on a phone is otherwise a very tall
/// scroll with no way to skip to the part you came for.
Future<int?> showWikiOutlineSheet(
  BuildContext context,
  List<WikiSection> sections,
) {
  final entries = <MapEntry<int, WikiSection>>[
    for (var i = 0; i < sections.length; i++)
      if (sections[i].title != null) MapEntry(i, sections[i]),
  ];
  if (entries.isEmpty) return Future<int?>.value();

  return showModalBottomSheet<int>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.7,
    ),
    builder: (context) {
      final theme = Theme.of(context);
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.m,
                0,
                AppSpacing.m,
                AppSpacing.s,
              ),
              child: Text('On this page', style: theme.textTheme.titleMedium),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: AppSpacing.s),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  final section = entry.value;
                  // Level 1 headings anchor the page; 2 and 3 hang off them.
                  final indent = (section.level - 1).clamp(0, 2) * 18.0;
                  return InkWell(
                    onTap: () => Navigator.of(context).pop(entry.key),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.m + indent,
                        AppSpacing.s + 2,
                        AppSpacing.m,
                        AppSpacing.s + 2,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 3,
                            height: section.level == 1 ? 16 : 12,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: section.level == 1 ? 0.8 : 0.35,
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s + 2),
                          Expanded(
                            child: Text(
                              section.title!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: section.level == 1
                                  ? theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    )
                                  : theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.75),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
