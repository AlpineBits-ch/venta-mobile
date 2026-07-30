/// The shared vocabulary the five household channel screens are built from.
/// They differ enormously in content - a shopping list and a shared ledger
/// have nothing in common - so what holds them together as one feature is
/// this: the same card, the same empty state, the same way a person's name is
/// rendered, the same section headers.
library;

import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/network/api_error.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/profile_resolver.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../guilds/data/models/guild_features.dart';
import '../../data/household_api.dart';

/// For the editor sheets, which live outside a [HouseholdChannelState] and so
/// can't reach its `api` getter.
HouseholdApi get householdApi => getIt<HouseholdApi>();

/// These endpoints say useful things when they refuse ("Anna is not in the
/// rotation", "shares must sum to the total"), and a household is exactly the
/// audience that can act on them - so the server's own wording wins whenever
/// there is one.
String householdErrorText(Object error, String fallback) =>
    apiErrorMessage(error) ?? fallback;

/// A person's display name, resolved from their id.
///
/// Says "You" for yourself, because every one of these screens is fundamentally
/// about who owes what and whose turn it is, and reading your own username
/// back at you in that context is oddly distancing.
class MemberName extends StatelessWidget {
  const MemberName({
    super.key,
    required this.userId,
    this.style,
    this.selfLabel = 'You',
    this.possessive = false,
  });

  final String userId;
  final TextStyle? style;
  final String selfLabel;

  /// Renders `Anna's` / `your` - for "Ben did Anna's washing-up".
  final bool possessive;

  static bool isSelf(String userId) =>
      userId.isNotEmpty && userId == getIt<AuthRepository>().currentUserId;

  @override
  Widget build(BuildContext context) {
    if (isSelf(userId)) {
      return Text(
        possessive ? 'your' : selfLabel,
        style: style,
        overflow: TextOverflow.ellipsis,
      );
    }
    return ProfileResolver(
      userId: userId,
      builder: (context, profile) {
        final name = profile?.userName ?? '…';
        return Text(
          possessive ? '$name’s' : name,
          style: style,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}

/// The rounded surface every household row/panel sits on - one place to
/// change, so a chore card and an expense card never drift apart.
class HouseCard extends StatelessWidget {
  const HouseCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding = const EdgeInsets.all(AppSpacing.m),
    this.tint,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry padding;

  /// Washes the card in a colour at low alpha - overdue chores, blocked
  /// options. Used sparingly: if everything is tinted, nothing is.
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: tint == null
          ? theme.colorScheme.surfaceContainerHighest
          : Color.alphaBlend(
              tint!.withValues(alpha: 0.12),
              theme.colorScheme.surfaceContainerHighest,
            ),
      borderRadius: BorderRadius.circular(AppRadii.card),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Small-caps section header used between groups of rows (a list's "Dairy",
/// the chore board's "Overdue", the ledger's month headings).
class HouseSectionHeader extends StatelessWidget {
  const HouseSectionHeader({
    super.key,
    required this.label,
    this.trailing,
    this.color,
  });

  final String label;
  final Widget? trailing;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xs,
        AppSpacing.m,
        AppSpacing.xs,
        AppSpacing.s,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ),
          if (trailing != null)
            DefaultTextStyle.merge(
              style: theme.textTheme.labelSmall!.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              child: trailing!,
            ),
        ],
      ),
    );
  }
}

/// The "nothing here yet" state. Household screens start empty far more often
/// than a chat channel does - a new house has an empty list, an empty rota and
/// an empty ledger on day one - so the empty state is doing real work: it has
/// to say what the thing is *for*, not just that it's empty.
class HouseEmptyState extends StatelessWidget {
  const HouseEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.action,
  });

  final IconData icon;
  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 44,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              body,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.4,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.l),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// What a household channel shows when its module has been switched off.
///
/// This is deliberately *not* a permission error. The endpoints behind it
/// answer `403` for everyone including the owner while the module is off, and
/// telling someone they're "not allowed" to see their own shopping list -
/// with no way to fix it, because there is no admin escape hatch - would be
/// both wrong and infuriating. The channel and its contents are still there;
/// only the module is off.
class ModuleOffView extends StatelessWidget {
  const ModuleOffView({super.key, required this.feature, this.onOpenSettings});

  final String feature;

  /// Only passed when the viewer actually has `ManageGuild` - for everyone
  /// else this is information, not a task.
  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final label = GuildFeature.labels[feature] ?? feature;
    return HouseEmptyState(
      icon: Icons.toggle_off_outlined,
      title: '$label is switched off',
      body:
          'This channel and everything in it is still here. Turning the '
          '$label module back on in server settings brings it back exactly '
          'as it was.',
      action: onOpenSettings == null
          ? null
          : OutlinedButton(
              onPressed: onOpenSettings,
              child: const Text('Open server settings'),
            ),
    );
  }
}

/// A compact status/metadata pill - "Low", "Blocked", "20 min", "Overdue".
class HousePill extends StatelessWidget {
  const HousePill({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.filled = true,
  });

  final String label;
  final IconData? icon;
  final Color? color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = color ?? theme.colorScheme.onSurface.withValues(alpha: 0.7);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: filled ? tint.withValues(alpha: 0.14) : null,
        border: filled
            ? null
            : Border.all(color: tint.withValues(alpha: 0.35), width: 1),
        borderRadius: BorderRadius.circular(AppRadii.badge + 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: tint),
            const SizedBox(width: 3),
          ],
          // Kept to one line: pills sit in dense rows, and a wrapping pill
          // pushes the row's height around as data changes.
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: tint,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Labelled block inside an editor sheet - the same small-caps label +
/// content pairing the events and create-channel dialogs already use.
class SheetField extends StatelessWidget {
  const SheetField({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

/// The standard bottom-sheet shell for household editors: title, scrollable
/// body, keyboard-aware padding, one full-width primary action.
class HouseSheet extends StatelessWidget {
  const HouseSheet({
    super.key,
    required this.title,
    required this.children,
    required this.actionLabel,
    this.onAction,
    this.busy = false,
    this.leadingAction,
  });

  final String title;
  final List<Widget> children;
  final String actionLabel;

  /// Null disables the primary button - the "you haven't filled this in yet"
  /// state, which is preferable to letting someone press it and read an error.
  final VoidCallback? onAction;
  final bool busy;

  /// Sits to the left of the primary action - "Delete", typically.
  final Widget? leadingAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.l,
          right: AppSpacing.l,
          top: AppSpacing.l,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.l,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.l),
              ...children,
              const SizedBox(height: AppSpacing.l),
              Row(
                children: [
                  if (leadingAction != null) ...[
                    leadingAction!,
                    const SizedBox(width: AppSpacing.s),
                  ],
                  Expanded(
                    child: FilledButton(
                      onPressed: busy ? null : onAction,
                      child: busy
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(actionLabel),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sheets are opened on the root navigator throughout this app - the shell's
/// nav rail lives in a sibling of the content pane's own Navigator, so a
/// sheet opened locally is clipped to the pane instead of covering the device.
Future<T?> showHouseSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) => showModalBottomSheet<T>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  builder: builder,
);
