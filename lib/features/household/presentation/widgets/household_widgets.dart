/// The shared vocabulary the five household channel screens are built from.
/// They differ enormously in content - a shopping list and a shared ledger
/// have nothing in common - so what holds them together as one feature is
/// this: the same card, the same empty state, the same way a person's name is
/// rendered, the same section headers.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/network/api_error.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/adaptive_progress_indicator.dart';
import '../../../../core/widgets/profile_resolver.dart';
import '../../../../core/widgets/shimmer_box.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../guilds/data/models/guild_features.dart';
import '../../data/household_api.dart';
import '../../data/money.dart';

/// For the editor sheets, which live outside a [HouseholdChannelState] and so
/// can't reach its `api` getter.
HouseholdApi get householdApi => getIt<HouseholdApi>();

/// These endpoints say useful things when they refuse ("Anna is not in the
/// rotation", "shares must sum to the total"), and a household is exactly the
/// audience that can act on them - so the server's own wording wins whenever
/// there is one.
String householdErrorText(Object error, String fallback) =>
    apiErrorMessage(error) ?? fallback;

/// `1.0` -> `1`, `1.5` -> `1.5`. Stock is decimal on the wire because it's
/// compared against a threshold, but "1.0 eggs" reads like a bug.
String formatQuantity(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value
      .toStringAsFixed(2)
      .replaceAll(RegExp(r'0+$'), '')
      .replaceAll(RegExp(r'\.$'), '');
}

/// A list item's quantity is free text ("a bunch of the small ones"), so it's
/// shown as typed - except when the pantry wrote it. The restock hand-off
/// stringifies a decimal server-side and lands `5.0 Tab` on the shopping list
/// while the pantry itself shows the same stock as `5`: one number, two
/// spellings, both on screen at once. Only a leading number is touched, and
/// only to give it the same spelling [formatQuantity] would.
final _leadingNumberRe = RegExp(r'^(\d+(?:\.\d+)?)(?=$|\s)');

String formatListQuantity(String raw) {
  final trimmed = raw.trim();
  final match = _leadingNumberRe.firstMatch(trimmed);
  if (match == null) return trimmed;
  final value = double.tryParse(match.group(1)!);
  if (value == null) return trimmed;
  return formatQuantity(value) + trimmed.substring(match.end);
}

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
  const ModuleOffView({
    super.key,
    required this.feature,
    this.guildNoun = 'server',
    this.onOpenSettings,
  });

  final String feature;

  /// What this guild's members call it - `GuildKind.noun`, lowercased. A
  /// household calling its own settings "server settings" is the one piece of
  /// gaming-server vocabulary that leaks into an otherwise house-shaped UI.
  final String guildNoun;

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
          '$label module back on in $guildNoun settings brings it back exactly '
          'as it was.',
      action: onOpenSettings == null
          ? null
          : OutlinedButton(
              onPressed: onOpenSettings,
              child: Text('Open $guildNoun settings'),
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
                          ? const AdaptiveProgressIndicator(
                              size: 18,
                              strokeWidth: 2,
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

/// A money amount, set in tabular figures.
///
/// Proportional digits make a column of amounts wobble, and a wobbling column
/// of money is the first thing that makes a ledger look approximate. Inter has
/// real tabular figures, so this costs nothing but the font feature.
///
/// **There is no loading state here on purpose.** A number that changes after
/// somebody has read it is how a ledger stops being believed, so a caller with
/// no amount yet renders [HouseAmountPending] instead of a placeholder digit.
class HouseAmount extends StatelessWidget {
  const HouseAmount({
    super.key,
    required this.amountMinor,
    required this.currency,
    this.style,
    this.signed = false,
    this.showCurrency = true,
    this.color,
  });

  final int amountMinor;
  final String currency;
  final TextStyle? style;

  /// Prefix a `+` on positive amounts - for balances, where the sign is the
  /// information.
  final bool signed;
  final bool showCurrency;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final base = style ?? Theme.of(context).textTheme.titleSmall;
    return Text(
      formatMinor(
        amountMinor,
        currency,
        signed: signed,
        showCurrency: showCurrency,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: base?.copyWith(
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      semanticsLabel: formatMinor(amountMinor, currency, signed: signed),
    );
  }
}

/// Where an amount would be, when there isn't one yet.
///
/// Used for a variable bill nobody has read off the letter, and while a figure
/// is in flight. Deliberately not a zero and not a shimmering digit: both read
/// as an amount, and this has to read as a question.
class HouseAmountPending extends StatelessWidget {
  const HouseAmountPending({super.key, this.label = 'Amount unknown'});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return HousePill(
      label: label,
      icon: Icons.help_outline_rounded,
      color: theme.colorScheme.tertiary,
    );
  }
}

/// A loading list shaped like the cards that will replace it.
///
/// A centred spinner tells somebody the app is busy; a skeleton tells them what
/// is coming and stops the whole screen jumping when it does.
class HouseCardSkeleton extends StatelessWidget {
  const HouseCardSkeleton({super.key, this.count = 4, this.lines = 2});

  final int count;
  final int lines;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.xl,
      ),
      itemCount: count,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.s),
        child: ExcludeSemantics(
          child: HouseCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(
                  width: 160,
                  height: 15,
                  borderRadius: AppRadii.badge,
                ),
                for (var line = 1; line < lines; line++) ...[
                  const SizedBox(height: AppSpacing.s),
                  ShimmerBox(
                    width: 90.0 + (index % 3) * 30,
                    height: 12,
                    borderRadius: AppRadii.badge,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The row a notification brought somebody to, marked and scrolled into view.
///
/// A deep link that opens a board of forty rows and highlights none of them has
/// not really arrived anywhere. This outlines the row once and fades the
/// outline out, so the mark is gone by the time it would start being noise.
///
/// The fade is skipped under `MediaQuery.disableAnimations` - the outline is
/// still drawn, then removed, because the *information* is not decorative even
/// when the animation is.
class HouseFocusMark extends StatefulWidget {
  const HouseFocusMark({
    super.key,
    required this.focused,
    required this.child,
    this.label,
  });

  final bool focused;
  final Widget child;

  /// Announced to a screen reader when the row is the one that was linked to.
  final String? label;

  @override
  State<HouseFocusMark> createState() => _HouseFocusMarkState();
}

class _HouseFocusMarkState extends State<HouseFocusMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
    value: widget.focused ? 1 : 0,
  );

  @override
  void initState() {
    super.initState();
    if (widget.focused) _run();
  }

  @override
  void didUpdateWidget(HouseFocusMark oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focused && !oldWidget.focused) _run();
  }

  void _run() {
    _controller.value = 1;
    _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.focused) return widget.child;
    final theme = Theme.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      label: widget.label,
      container: widget.label != null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final strength = reduceMotion
              ? (_controller.isAnimating ? 1.0 : _controller.value)
              : Curves.easeOut.transform(_controller.value);
          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.card),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(
                  alpha: 0.9 * strength,
                ),
                width: 2,
              ),
            ),
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// Scrolls [key]'s row into view once the board has laid out.
///
/// Deferred to the end of the frame because the row does not exist yet when a
/// deep link arrives - the board is still fetching. Callers call this from the
/// build that first contains the row.
void revealHouseholdRow(GlobalKey key) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final context = key.currentContext;
    if (context == null) return;
    unawaitedEnsureVisible(context);
  });
}

void unawaitedEnsureVisible(BuildContext context) {
  Scrollable.ensureVisible(
    context,
    duration: const Duration(milliseconds: 320),
    curve: Curves.easeOutCubic,
    alignment: 0.25,
  );
}

/// The primary action, parked in thumb reach.
///
/// These screens are used standing up and one-handed - in a shop, at an open
/// fridge - so the action that matters sits at the bottom of the screen rather
/// than in an app-bar corner nobody can reach without shifting their grip. It
/// floats over the list rather than pushing it, and the list pads for it.
class HouseActionBar extends StatelessWidget {
  const HouseActionBar({super.key, required this.child, this.secondary});

  final Widget child;

  /// Sits above the primary action - a summary line, a warning.
  final Widget? secondary;

  /// What a scrolling list underneath one of these has to reserve at the
  /// bottom, so the last row is not permanently hidden behind it. Generous
  /// rather than exact, because [HousePrimaryButton] grows with the reader's
  /// text size.
  static const reservedHeight = 120.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.m,
            AppSpacing.s,
            AppSpacing.m,
            AppSpacing.s,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (secondary != null) ...[
                secondary!,
                const SizedBox(height: AppSpacing.s),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// A full-width primary button sized for cold hands in a moving tram.
///
/// Material's default 40pt is fine at a desk and not fine here, so every
/// household primary action is 52pt with a generous label.
class HousePrimaryButton extends StatelessWidget {
  const HousePrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.busy = false,
    this.destructive = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool busy;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Grows with the reader's text size instead of clipping the label into an
    // ellipsis. Capped, because past about half again the button stops being a
    // button and starts being a panel.
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.7);
    return SizedBox(
      width: double.infinity,
      height: 52 * scale,
      child: FilledButton(
        onPressed: busy ? null : onPressed,
        style: destructive
            ? FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              )
            : null,
        child: busy
            ? const AdaptiveProgressIndicator(size: 20, strokeWidth: 2)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: AppSpacing.s),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: destructive
                            ? theme.colorScheme.onError
                            : theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// The same button, one step quieter - for the action bar that has two real
/// actions in it rather than one.
///
/// Matched to [HousePrimaryButton] in height and text growth on purpose. Two
/// buttons side by side that scale differently are two buttons that stop lining
/// up the moment somebody turns their text size up, and these are read at an
/// open fridge.
class HouseSecondaryButton extends StatelessWidget {
  const HouseSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.7);
    return SizedBox(
      width: double.infinity,
      height: 52 * scale,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: AppSpacing.s),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The mark on a name a public product catalog suggested and this house has not
/// agreed to yet.
///
/// It exists because the two kinds of name in a pantry look identical and are
/// not: one is what the flat calls the thing, the other is what a stranger's
/// database says is printed on the box. Unmarked, a suggestion that is slightly
/// wrong reads as something the house decided, and nobody corrects it. Marked,
/// it reads as an offer, which is what it is.
class SuggestedNameBadge extends StatelessWidget {
  const SuggestedNameBadge({super.key, this.label = 'Suggested'});

  final String label;

  @override
  Widget build(BuildContext context) =>
      HousePill(label: label, icon: Icons.public_rounded, filled: false);
}

/// The credit a catalog-supplied name owes its source, in the source's own
/// words.
///
/// **Not optional and not ours to paraphrase.** The catalog is built from Open
/// Food Facts under the Open Database License, which requires the licence named
/// and the source credited wherever one of its names is shown. [attribution] is
/// the wording the licence itself blesses and it arrives on the scan response
/// for exactly this reason, so it is printed rather than reworded.
///
/// Quiet on purpose. A legal notice interrupting somebody unpacking a shopping
/// bag is a notice that gets the feature switched off, and an obligation nobody
/// can meet in practice is not met at all. One muted line under the names it
/// covers is the least intrusive placement that is still honest.
class ProductSourceNote extends StatelessWidget {
  const ProductSourceNote({super.key, required this.attribution});

  final String attribution;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.public_rounded,
          size: 13,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            attribution,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

/// The one prompt in the scanner: what this house calls a product.
///
/// Two jobs, one sheet, because they are the same act seen from either side.
/// Either nothing could name the code and somebody types one, or the catalog
/// suggested one and somebody is correcting it. Both end with the house owning
/// the name; two sheets would mean two sets of copy drifting apart.
///
/// [suggestion] is what a public catalog offered, if anything. When it is set
/// the field opens holding it, so agreeing costs one tap and correcting costs a
/// few characters - which matters, because a wrong name that is awkward to fix
/// is worse than no name at all.
class ProductNameSheet extends StatefulWidget {
  const ProductNameSheet({
    super.key,
    this.initialName,
    this.suggestion,
    this.attribution,
    this.brand,
    this.busy = false,
  });

  /// What the field starts with. Usually the name already on the jar.
  final String? initialName;

  /// The catalog's offer, when there was one. Shown as an offer, not a fact.
  final String? suggestion;

  final String? attribution;

  /// The brand the catalog carried, which is often the only thing telling two
  /// nearly identical suggestions apart.
  final String? brand;

  final bool busy;

  @override
  State<ProductNameSheet> createState() => _ProductNameSheetState();
}

class _ProductNameSheetState extends State<ProductNameSheet> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialName ?? widget.suggestion ?? '',
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() => Navigator.of(context).pop(_controller.text.trim());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final suggested = widget.suggestion?.trim();
    final brand = widget.brand?.trim();
    final attribution = widget.attribution?.trim();
    final hasSuggestion = suggested != null && suggested.isNotEmpty;

    return HouseSheet(
      title: hasSuggestion || widget.initialName != null
          ? 'Call it something else'
          : 'What is this?',
      actionLabel: 'Save and carry on',
      busy: widget.busy,
      onAction: _controller.text.trim().isEmpty ? null : _save,
      children: [
        SheetField(
          label: 'Call it',
          child: TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              if (_controller.text.trim().isNotEmpty) _save();
            },
            decoration: const InputDecoration(hintText: 'Oat milk'),
          ),
        ),
        if (hasSuggestion) ...[
          const SizedBox(height: AppSpacing.m),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SuggestedNameBadge(),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Text(
                  brand == null || brand.isEmpty
                      ? suggested
                      : '$suggested · $brand',
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.m),
        Text(
          hasSuggestion
              ? 'That name came from a public product database, not from this '
                    'house. Whatever you save here is what your flat calls it '
                    'from now on, and it wins over the suggestion every time.'
              : 'Only the first time. This house remembers the barcode, so '
                    'every scan of it after this one goes straight in.',
          style: theme.textTheme.bodySmall?.copyWith(color: muted, height: 1.4),
        ),
        if (attribution != null && attribution.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.s),
          ProductSourceNote(attribution: attribution),
        ],
      ],
    );
  }
}

/// The confirmation buzz for something that worked.
///
/// Deliberately only ever on success. A phone that buzzes at a failure teaches
/// people that the buzz means nothing, and these screens lean on it as the
/// confirmation - a batch scan says "got it" by feel, not by a dialog.
void houseHaptic() => unawaited(HapticFeedback.selectionClick());

/// A weightier one, for the actions there is no undoing in one tap.
void houseHapticHeavy() => unawaited(HapticFeedback.mediumImpact());

/// Sheets are opened on the root navigator throughout this app - the shell's
/// nav rail lives in a sibling of the content pane's own Navigator, so a
/// sheet opened locally is clipped to the pane instead of covering the device.
///
/// `useSafeArea` is what keeps a tall sheet (the chore editor is the tallest)
/// off the status bar: `isScrollControlled` lets it grow to the full height of
/// the screen, and `showModalBottomSheet` strips the top padding from the
/// `MediaQuery` it hands the builder - so [HouseSheet]'s own `SafeArea` has
/// nothing left to work with and the title lands on top of the system clock.
Future<T?> showHouseSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) => showModalBottomSheet<T>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  useSafeArea: true,
  builder: builder,
);
