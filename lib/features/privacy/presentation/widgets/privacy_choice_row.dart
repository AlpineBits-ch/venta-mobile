import 'package:flutter/material.dart';

import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/settings_tiles.dart';

/// A settings row whose value is one of a small set of choices, picked from a
/// bottom sheet.
///
/// A `DropdownButtonFormField` was the obvious thing and is the wrong one here:
/// these choices need a sentence of explanation each ("Friends, plus people who
/// share a server with you"), and a dropdown has nowhere to put one. The sheet
/// is the same shape `showStatusPickerSheet` already uses - a `ListTile` per
/// option with a trailing check - so the two read as one app.
class PrivacyChoiceRow<T> extends StatelessWidget {
  const PrivacyChoiceRow({
    super.key,
    required this.title,
    required this.value,
    required this.options,
    required this.labelOf,
    required this.onChanged,
    this.icon,
    this.subtitle,
    this.descriptionOf,

    /// Choices the server will refuse for this account (a minor floor). Shown
    /// disabled with [unavailableNote] rather than hidden - a control that
    /// silently has fewer options than another account's is one the user cannot
    /// reason about, and the refusal would otherwise arrive as a bounced write.
    this.unavailable = const {},
    this.unavailableNote,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final T value;
  final List<T> options;
  final String Function(T) labelOf;
  final String Function(T)? descriptionOf;
  final ValueChanged<T> onChanged;
  final Set<T> unavailable;
  final String? unavailableNote;

  Future<void> _pick(BuildContext context) async {
    final picked = await showModalBottomSheet<T>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
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
                child: Text(title, style: theme.textTheme.titleMedium),
              ),
              for (final option in options)
                _OptionTile(
                  label: labelOf(option),
                  description: unavailable.contains(option)
                      ? unavailableNote
                      : descriptionOf?.call(option),
                  selected: option == value,
                  onTap: unavailable.contains(option)
                      ? null
                      : () => Navigator.of(sheetContext).pop(option),
                ),
              const SizedBox(height: AppSpacing.s),
            ],
          ),
        );
      },
    );
    if (picked != null && picked != value) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return SettingsRow(
      icon: icon,
      title: title,
      subtitle: subtitle,
      trailing: Text(labelOf(value)),
      onTap: () => _pick(context),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String? description;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      enabled: onTap != null,
      title: Text(label),
      subtitle: description == null || description!.isEmpty
          ? null
          : Text(description!),
      trailing: selected
          ? Icon(Icons.check, color: theme.colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}
