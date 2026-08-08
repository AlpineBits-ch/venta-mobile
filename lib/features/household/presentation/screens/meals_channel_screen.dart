import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/format/plain_date.dart';
import '../../../../core/routing/household_deep_link.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/load_failure_view.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../guilds/data/models/channel_dto.dart';
import '../../../guilds/data/models/guild_features.dart';
import '../../../guilds/data/models/guild_member_dto.dart';
import '../../data/household_api_wave2.dart';
import '../../data/household_repository.dart';
import '../../data/models/meal_dto.dart';
import '../widgets/household_widgets.dart';
import 'household_channel_base.dart';
import 'recipes_screen.dart';

/// A `Meals` channel: what the house is eating, and the shop that follows from
/// it.
///
/// **Not a week grid.** A seven-column board works on a desktop and turns into
/// unreadable confetti at 390pt, and the question a phone gets asked is not
/// "show me the week" - it is "what are we eating tonight and am I cooking".
/// So the week is a strip of days along the top and the answer is the first
/// thing under it, at full width, with no scrolling.
class MealsChannelScreen extends StatefulWidget {
  const MealsChannelScreen({
    super.key,
    required this.guildId,
    required this.channelId,
    this.focus,
  });

  final String guildId;
  final String channelId;

  /// The plan entry a `meals.cooking_today` notification opened this at.
  final HouseholdFocus? focus;

  @override
  State<MealsChannelScreen> createState() => _MealsChannelScreenState();
}

class _MealsChannelScreenState
    extends HouseholdChannelState<MealsChannelScreen> {
  @override
  String get guildId => widget.guildId;
  @override
  String get channelId => widget.channelId;
  @override
  String get requiredFeature => GuildFeature.meals;
  @override
  String get fallbackTitle => 'Meals';

  List<MealPlanEntryDto>? _entries;
  MealPlanConfigDto? _config;
  bool _loadFailed = false;
  StreamSubscription<void>? _eventsSub;

  /// The strip runs from three days back so yesterday's leftovers are still
  /// reachable without a date picker.
  static const _daysBefore = 3;
  static const _daysAfter = 21;

  late PlainDate _selected = PlainDate.today();

  bool get _canPlan => can('PlanMeals');
  bool get _canManage => can('ManageMeals');

  PlainDate get _from => PlainDate.today().addDays(-_daysBefore);
  PlainDate get _to => PlainDate.today().addDays(_daysAfter);

  @override
  void initState() {
    focus = widget.focus;
    super.initState();
    unawaited(_load());
    unawaited(ensureMembers());
    _eventsSub = household
        .channelEvents(widget.channelId, HouseholdEvents.meals)
        .listen((_) => unawaited(_load()));
  }

  @override
  void dispose() {
    unawaited(_eventsSub?.cancel());
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        api.getMealPlan(widget.channelId, from: _from, to: _to),
        api.getMealPlanConfig(widget.channelId),
      ]);
      if (!mounted) return;
      final entries = results[0] as List<MealPlanEntryDto>;
      setState(() {
        _entries = entries;
        _config = results[1] as MealPlanConfigDto;
        _loadFailed = false;
      });
      // A notification about "you're cooking on Thursday" has to land on
      // Thursday, not on today.
      final target = focus;
      if (target != null && target.kind == HouseholdFocusKind.mealPlanEntry) {
        final entry = entries.where((e) => e.id == target.id).firstOrNull;
        if (entry != null && mounted) setState(() => _selected = entry.date);
      }
    } catch (_) {
      if (mounted && _entries == null) setState(() => _loadFailed = true);
    }
  }

  List<MealPlanEntryDto> _entriesOn(PlainDate date) =>
      [...?_entries?.where((e) => e.date == date)]..sort((a, b) {
        final bySlot = a.slot.position.compareTo(b.slot.position);
        return bySlot != 0 ? bySlot : a.position.compareTo(b.position);
      });

  Future<void> _openEntry({
    MealPlanEntryDto? existing,
    MealSlot slot = MealSlot.dinner,
  }) async {
    final saved = await showHouseSheet<bool>(
      context: context,
      builder: (_) => _MealEntrySheet(
        channelId: widget.channelId,
        date: existing?.date ?? _selected,
        slot: existing?.slot ?? slot,
        existing: existing,
        members: members ?? const [],
        currentUserId: currentUserId,
        canDelete: existing != null && (_canManage || _canPlan),
      ),
    );
    if (saved == true) await _load();
  }

  Future<void> _openShoppingList() async {
    final lists =
        guild?.channels.where((c) => c.type == ChannelType.list).toList() ??
        const <ChannelDto>[];
    await showHouseSheet<void>(
      context: context,
      builder: (_) => _ShoppingListSheet(
        channelId: widget.channelId,
        config: _config ?? const MealPlanConfigDto(),
        lists: lists,
        initialFrom: PlainDate.today(),
      ),
    );
  }

  Future<void> _openCookable() async {
    await showHouseSheet<void>(
      context: context,
      builder: (_) => _CookableSheet(channelId: widget.channelId),
    );
  }

  Future<void> _openRecipes() async {
    await Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => RecipesScreen(
          channelId: widget.channelId,
          canEdit: _canPlan,
          canEditAnyone: _canManage,
        ),
      ),
    );
    await _load();
  }

  Future<void> _openConfig() async {
    final channels = guild?.channels ?? const <ChannelDto>[];
    final saved = await showHouseSheet<bool>(
      context: context,
      builder: (_) => _MealsConfigSheet(
        channelId: widget.channelId,
        config: _config ?? const MealPlanConfigDto(),
        lists: channels.where((c) => c.type == ChannelType.list).toList(),
        pantries: channels.where((c) => c.type == ChannelType.pantry).toList(),
      ),
    );
    if (saved == true) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final entries = _entries;
    return Scaffold(
      appBar: buildAppBar(
        actions: [
          IconButton(
            onPressed: _openCookable,
            tooltip: 'What can we cook?',
            icon: const Icon(Icons.auto_awesome_outlined),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) => switch (value) {
              'recipes' => unawaited(_openRecipes()),
              'config' => unawaited(_openConfig()),
              _ => null,
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'recipes', child: Text('Recipes')),
              if (_canManage)
                const PopupMenuItem(
                  value: 'config',
                  child: Text('Shopping and pantry'),
                ),
            ],
          ),
        ],
      ),
      body: !moduleEnabled
          ? buildModuleOff()
          : _loadFailed
          ? LoadFailureView(message: 'Couldn\'t load the plan.', onRetry: _load)
          : entries == null
          ? const HouseCardSkeleton(lines: 2)
          : Column(
              children: [
                _DayStrip(
                  from: _from,
                  days: _daysBefore + _daysAfter + 1,
                  selected: _selected,
                  hasEntries: (date) => _entriesOn(date).isNotEmpty,
                  onSelected: (date) => setState(() => _selected = date),
                ),
                Expanded(child: _buildDay()),
              ],
            ),
      // The highest-value action in the module, at thumb height. Turning a
      // week's plan into one shop is the thing that makes planning worth doing
      // at all, and it must not live in an app-bar corner.
      bottomNavigationBar: moduleEnabled && _canPlan
          ? HouseActionBar(
              child: HousePrimaryButton(
                label: 'Make the shopping list',
                icon: Icons.playlist_add_rounded,
                onPressed: _openShoppingList,
              ),
            )
          : null,
    );
  }

  Widget _buildDay() {
    final entries = _entriesOn(_selected);
    final today = PlainDate.today();
    final isToday = _selected == today;

    if (entries.isEmpty && (_entries?.isEmpty ?? true)) {
      return HouseEmptyState(
        icon: Icons.restaurant_outlined,
        title: 'Nothing planned',
        body: _canPlan
            ? 'Put something down for tonight. Once a few days have meals on '
                  'them, one button turns the whole week into a shopping list '
                  'with what you already have left out.'
            : 'Nobody has planned any meals yet.',
        action: _canPlan
            ? FilledButton.icon(
                onPressed: () => unawaited(_openEntry()),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Plan a meal'),
              )
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.m,
          AppSpacing.s,
          AppSpacing.m,
          AppSpacing.xl,
        ),
        children: [
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Text(
                isToday
                    ? 'Nothing down for today.'
                    : 'Nothing down for this day.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          for (final entry in entries)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s),
              child: focusRow(
                HouseholdFocusKind.mealPlanEntry,
                entry.id,
                label: 'The meal you were told about',
                _MealCard(
                  entry: entry,
                  isMine: entry.cookUserId == currentUserId,
                  onTap: _canPlan
                      ? () => unawaited(_openEntry(existing: entry))
                      : null,
                ),
              ),
            ),
          if (_canPlan) ...[
            const SizedBox(height: AppSpacing.s),
            for (final slot in MealSlot.values)
              if (!entries.any((e) => e.slot == slot))
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: _AddSlotRow(
                    slot: slot,
                    onTap: () => unawaited(_openEntry(slot: slot)),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}

/// The week, as a scrolling strip. Days with something planned carry a dot, so
/// a glance at the strip already answers "is anything down for Thursday".
class _DayStrip extends StatefulWidget {
  const _DayStrip({
    required this.from,
    required this.days,
    required this.selected,
    required this.hasEntries,
    required this.onSelected,
  });

  final PlainDate from;
  final int days;
  final PlainDate selected;
  final bool Function(PlainDate) hasEntries;
  final ValueChanged<PlainDate> onSelected;

  @override
  State<_DayStrip> createState() => _DayStripState();
}

class _DayStripState extends State<_DayStrip> {
  late final ScrollController _controller = ScrollController(
    // Opens on today rather than on the first day in the window, with the
    // three days of history just off to the left where they can be reached.
    initialScrollOffset: (_todayIndex - 1).clamp(0, widget.days) * _tileExtent,
  );

  static const _tileExtent = 60.0;

  int get _todayIndex => PlainDate.today().differenceInDays(widget.from);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = PlainDate.today();
    return SizedBox(
      height: 74,
      child: ListView.builder(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
        itemCount: widget.days,
        itemExtent: _tileExtent,
        itemBuilder: (context, index) {
          final date = widget.from.addDays(index);
          final selected = date == widget.selected;
          final isToday = date == today;
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.s,
            ),
            child: Material(
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadii.card),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => widget.onSelected(date),
                child: Semantics(
                  selected: selected,
                  label:
                      '${_weekdayName(date)} ${date.day} ${_monthName(date)}',
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isToday ? 'Today' : _weekdayName(date).substring(0, 3),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: selected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                          fontWeight: isToday ? FontWeight.w700 : null,
                        ),
                      ),
                      Text(
                        '${date.day}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: selected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.hasEntries(date)
                              ? (selected
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.primary)
                              : Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

const _weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _weekdayName(PlainDate date) => _weekdays[date.weekday - 1];
String _monthName(PlainDate date) => _months[date.month - 1];

class _MealCard extends StatelessWidget {
  const _MealCard({
    required this.entry,
    required this.isMine,
    required this.onTap,
  });

  final MealPlanEntryDto entry;
  final bool isMine;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final cook = entry.cookUserId;

    return HouseCard(
      onTap: onTap,
      tint: isMine ? theme.colorScheme.primary : null,
      child: Row(
        children: [
          Icon(entry.slot.icon, size: 20, color: muted),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.slot.label,
                  style: theme.textTheme.labelSmall?.copyWith(color: muted),
                ),
                const SizedBox(height: 2),
                Text(
                  entry.displayTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (cook != null && cook.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      UserAvatar(userId: cook, radius: 8),
                      const SizedBox(width: 6),
                      MemberName(
                        userId: cook,
                        // "You're cooking" rather than "You" - the whole
                        // question this screen answers.
                        selfLabel: 'You\'re cooking',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isMine ? theme.colorScheme.primary : muted,
                          fontWeight: isMine ? FontWeight.w600 : null,
                        ),
                      ),
                      if (!isMine)
                        Text(
                          ' is cooking',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: muted,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddSlotRow extends StatelessWidget {
  const _AddSlotRow({required this.slot, required this.onTap});

  final MealSlot slot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.45);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: 14,
        ),
        child: Row(
          children: [
            Icon(slot.icon, size: 18, color: muted),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Text(
                'Add ${slot.label.toLowerCase()}',
                style: theme.textTheme.bodyMedium?.copyWith(color: muted),
              ),
            ),
            Icon(Icons.add_rounded, size: 18, color: muted),
          ],
        ),
      ),
    );
  }
}

/// One slot of one day: a recipe, or whatever somebody typed.
class _MealEntrySheet extends StatefulWidget {
  const _MealEntrySheet({
    required this.channelId,
    required this.date,
    required this.slot,
    required this.existing,
    required this.members,
    required this.currentUserId,
    required this.canDelete,
  });

  final String channelId;
  final PlainDate date;
  final MealSlot slot;
  final MealPlanEntryDto? existing;
  final List<GuildMemberDto> members;
  final String currentUserId;
  final bool canDelete;

  @override
  State<_MealEntrySheet> createState() => _MealEntrySheetState();
}

class _MealEntrySheetState extends State<_MealEntrySheet> {
  late MealSlot _slot = widget.slot;
  late final _textController = TextEditingController(
    text: widget.existing?.freeText ?? '',
  );
  late String? _recipeId = widget.existing?.recipeId;
  late String? _recipeTitle = widget.existing?.recipeTitle;
  late String? _cookUserId = widget.existing?.cookUserId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  /// The server needs one of the two, and a form that lets somebody save
  /// neither only buys them a `400`.
  bool get _valid =>
      _recipeId != null || _textController.text.trim().isNotEmpty;

  Future<void> _pickRecipe() async {
    final picked = await Navigator.of(context, rootNavigator: true)
        .push<RecipeDto>(
          MaterialPageRoute<RecipeDto>(
            builder: (_) => RecipesScreen(
              channelId: widget.channelId,
              canEdit: false,
              canEditAnyone: false,
              pickMode: true,
            ),
          ),
        );
    if (picked != null && mounted) {
      setState(() {
        _recipeId = picked.id;
        _recipeTitle = picked.title;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final text = _textController.text.trim();
    try {
      if (widget.existing == null) {
        await householdApi.createMealPlanEntry(
          widget.channelId,
          date: widget.date,
          slot: _slot,
          recipeId: _recipeId,
          freeText: _recipeId == null ? text : null,
          cookUserId: _cookUserId,
        );
      } else {
        await householdApi.updateMealPlanEntry(
          widget.existing!.id,
          slot: _slot,
          recipeId: _recipeId,
          clearRecipe: _recipeId == null,
          freeText: _recipeId == null ? text : null,
          clearFreeText: _recipeId != null,
          cookUserId: _cookUserId,
          clearCook: _cookUserId == null,
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(householdErrorText(error, 'Could not save that.')),
        ),
      );
    }
  }

  Future<void> _delete() async {
    final existing = widget.existing;
    if (existing == null) return;
    try {
      await householdApi.deleteMealPlanEntry(existing.id);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(householdErrorText(error, 'Could not remove that.')),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return HouseSheet(
      title:
          '${_weekdayName(widget.date)} ${widget.date.day} '
          '${_monthName(widget.date)}',
      actionLabel: 'Save',
      busy: _saving,
      onAction: _valid ? _save : null,
      leadingAction: widget.canDelete
          ? TextButton(
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
              onPressed: _delete,
              child: const Text('Remove'),
            )
          : null,
      children: [
        SheetField(
          label: 'Which meal',
          child: Wrap(
            spacing: AppSpacing.xs,
            children: [
              for (final slot in MealSlot.values)
                ChoiceChip(
                  avatar: Icon(slot.icon, size: 16),
                  label: Text(slot.label),
                  selected: _slot == slot,
                  onSelected: (_) => setState(() => _slot = slot),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        SheetField(
          label: 'What',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_recipeId != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.menu_book_outlined),
                  title: Text(_recipeTitle ?? 'A recipe'),
                  trailing: IconButton(
                    onPressed: () => setState(() {
                      _recipeId = null;
                      _recipeTitle = null;
                    }),
                    tooltip: 'Type something instead',
                    icon: const Icon(Icons.close_rounded),
                  ),
                )
              else ...[
                TextField(
                  controller: _textController,
                  autofocus: widget.existing == null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(hintText: 'Leftovers'),
                ),
                const SizedBox(height: AppSpacing.xs),
                // Most of a real week is not a recipe, so typing is the
                // default and picking one is the deliberate step.
                TextButton.icon(
                  onPressed: _pickRecipe,
                  icon: const Icon(Icons.menu_book_outlined, size: 18),
                  label: const Text('Pick a recipe'),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        SheetField(
          label: 'Who is cooking',
          child: Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              ChoiceChip(
                label: const Text('Nobody yet'),
                selected: _cookUserId == null,
                onSelected: (_) => setState(() => _cookUserId = null),
              ),
              for (final member in widget.members)
                ChoiceChip(
                  label: Text(
                    member.userId == widget.currentUserId
                        ? 'Me'
                        : member.nickname ??
                              member.profile?.userName ??
                              'Someone',
                  ),
                  selected: _cookUserId == member.userId,
                  onSelected: (_) =>
                      setState(() => _cookUserId = member.userId),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The plan, turned into one shop.
///
/// **The highest-value screen in this module**, and the reason for the result
/// panel underneath the button: it collects the window's ingredients, drops
/// what the pantry already has and what is already on the list, and adds the
/// rest. A shopper who opens the list and finds no onions on it cannot tell a
/// working pantry check from a broken button, and will not press it twice - so
/// both skip reasons are shown, by name.
class _ShoppingListSheet extends StatefulWidget {
  const _ShoppingListSheet({
    required this.channelId,
    required this.config,
    required this.lists,
    required this.initialFrom,
  });

  final String channelId;
  final MealPlanConfigDto config;
  final List<ChannelDto> lists;
  final PlainDate initialFrom;

  @override
  State<_ShoppingListSheet> createState() => _ShoppingListSheetState();
}

class _ShoppingListSheetState extends State<_ShoppingListSheet> {
  late final PlainDate _from = widget.initialFrom;
  int _days = 7;
  bool _includeOptional = false;
  late String? _listChannelId =
      widget.config.shoppingListChannelId ??
      (widget.lists.isEmpty ? null : widget.lists.first.id);

  bool _running = false;
  ShoppingListResultDto? _result;

  PlainDate get _to => _from.addDays(_days - 1);

  Future<void> _run() async {
    setState(() => _running = true);
    try {
      final result = await householdApi.generateShoppingList(
        widget.channelId,
        from: _from,
        to: _to,
        listChannelId: _listChannelId,
        includeOptional: _includeOptional,
      );
      if (!mounted) return;
      houseHapticHeavy();
      setState(() {
        _result = result;
        _running = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _running = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(householdErrorText(error, 'Could not build the list.')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final result = _result;

    return HouseSheet(
      title: 'Make the shopping list',
      actionLabel: result == null ? 'Add it to the list' : 'Run it again',
      busy: _running,
      onAction: _listChannelId == null ? null : _run,
      children: [
        SheetField(
          label: 'How far ahead',
          child: Wrap(
            spacing: AppSpacing.xs,
            children: [
              for (final days in const [3, 7, 14])
                ChoiceChip(
                  label: Text('$days days'),
                  selected: _days == days,
                  onSelected: (_) => setState(() {
                    _days = days;
                    _result = null;
                  }),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${_weekdayName(_from)} ${_from.day} ${_monthName(_from)} to '
          '${_weekdayName(_to)} ${_to.day} ${_monthName(_to)}',
          style: theme.textTheme.labelSmall?.copyWith(color: muted),
        ),
        const SizedBox(height: AppSpacing.m),
        SheetField(
          label: 'Onto which list',
          child: widget.lists.isEmpty
              ? Text(
                  'This house has no list channel yet. Make one and the plan '
                  'can fill it.',
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                )
              : DropdownButtonFormField<String>(
                  initialValue: _listChannelId,
                  isExpanded: true,
                  items: [
                    for (final list in widget.lists)
                      DropdownMenuItem(
                        value: list.id,
                        child: Text('#${list.name}'),
                      ),
                  ],
                  onChanged: (value) => setState(() => _listChannelId = value),
                ),
        ),
        const SizedBox(height: AppSpacing.s),
        SwitchListTile.adaptive(
          value: _includeOptional,
          contentPadding: EdgeInsets.zero,
          title: const Text('Include the optional bits'),
          subtitle: Text(
            'Garnishes and the "if you have it" lines.',
            style: theme.textTheme.labelSmall?.copyWith(color: muted),
          ),
          onChanged: (value) => setState(() => _includeOptional = value),
        ),
        if (result != null) ...[
          const SizedBox(height: AppSpacing.m),
          _ShoppingListResult(result: result),
        ] else ...[
          const SizedBox(height: AppSpacing.s),
          Text(
            'Anything the pantry already has, or that is already on the list, '
            'is left off - and you will be told which, so a missing onion is '
            'never a mystery.',
            style: theme.textTheme.labelSmall?.copyWith(
              color: muted,
              height: 1.3,
            ),
          ),
        ],
      ],
    );
  }
}

class _ShoppingListResult extends StatelessWidget {
  const _ShoppingListResult({required this.result});

  final ShoppingListResultDto result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    return Semantics(
      liveRegion: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.s),
              Text(
                result.added.isEmpty
                    ? 'Nothing new to buy'
                    : result.added.length == 1
                    ? '1 thing added'
                    : '${result.added.length} things added',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          // Both reasons, by name. This is the part that makes the button
          // trustworthy the second time it is pressed.
          if (result.skippedInPantry.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s),
            _SkipList(
              icon: Icons.kitchen_outlined,
              heading: 'Already in the pantry',
              names: result.skippedInPantry,
            ),
          ],
          if (result.skippedOnList.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s),
            _SkipList(
              icon: Icons.checklist_rounded,
              heading: 'Already on the list',
              names: result.skippedOnList,
            ),
          ],
          if (result.truncated) ...[
            const SizedBox(height: AppSpacing.s),
            Text(
              'That was as much as one go allows. Run it again for the rest.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.tertiary,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.s),
          Text(
            'Quantities are not scaled by servings - a recipe line goes on as '
            'written.',
            style: theme.textTheme.labelSmall?.copyWith(
              color: muted,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkipList extends StatelessWidget {
  const _SkipList({
    required this.icon,
    required this.heading,
    required this.names,
  });

  final IconData icon;
  final String heading;
  final List<String> names;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: muted),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                heading,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                names.join(', '),
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// What can be cooked with what is about to go off.
///
/// Two sort keys, both predictable: how much expiring stock a recipe uses up,
/// then how little is missing. There is deliberately no scoring slider - the
/// value is that somebody can guess the order before they read it.
class _CookableSheet extends StatefulWidget {
  const _CookableSheet({required this.channelId});

  final String channelId;

  @override
  State<_CookableSheet> createState() => _CookableSheetState();
}

class _CookableSheetState extends State<_CookableSheet> {
  CookableResultDto? _result;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final result = await householdApi.getCookableRecipes(widget.channelId);
      if (mounted) {
        setState(() {
          _result = result;
          _failed = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final result = _result;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('What can we cook?', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Ranked by how much of what is about to go off it uses up.',
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
            const SizedBox(height: AppSpacing.m),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: _failed
                  ? LoadFailureView(
                      message: 'Couldn\'t work that out.',
                      onRetry: _load,
                    )
                  : result == null
                  ? const Padding(
                      padding: EdgeInsets.all(AppSpacing.l),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : result.items.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.l,
                      ),
                      // The server says *why* it is empty rather than leaving
                      // the house to conclude the feature is broken when it is
                      // only unconfigured.
                      child: Text(
                        result.reason ??
                            'Nothing in the pantry lines up with a recipe '
                                'just now.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: muted,
                        ),
                      ),
                    )
                  : ListView(
                      shrinkWrap: true,
                      children: [
                        for (final item in result.items)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.s,
                            ),
                            child: _CookableCard(item: item),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CookableCard extends StatelessWidget {
  const _CookableCard({required this.item});

  final CookableRecipeDto item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    return HouseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.recipe.title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              if (item.expiringCount > 0)
                HousePill(
                  label: item.expiringCount == 1
                      ? 'uses 1 thing going off'
                      : 'uses ${item.expiringCount} things going off',
                  icon: Icons.schedule_outlined,
                  color: theme.colorScheme.tertiary,
                ),
              HousePill(
                label: item.missingCount == 0
                    ? 'nothing missing'
                    : '${item.missingCount} missing',
                color: item.missingCount == 0
                    ? theme.colorScheme.primary
                    : null,
              ),
            ],
          ),
          if (item.missing.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Need: ${item.missing.join(', ')}',
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
          ],
        ],
      ),
    );
  }
}

/// Which list the plan shops onto, and which pantry it checks against.
class _MealsConfigSheet extends StatefulWidget {
  const _MealsConfigSheet({
    required this.channelId,
    required this.config,
    required this.lists,
    required this.pantries,
  });

  final String channelId;
  final MealPlanConfigDto config;
  final List<ChannelDto> lists;
  final List<ChannelDto> pantries;

  @override
  State<_MealsConfigSheet> createState() => _MealsConfigSheetState();
}

class _MealsConfigSheetState extends State<_MealsConfigSheet> {
  late String? _listId = widget.config.shoppingListChannelId;
  late String? _pantryId = widget.config.pantryChannelId;
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await householdApi.updateMealPlanConfig(
        widget.channelId,
        shoppingListChannelId: _listId,
        clearShoppingList: _listId == null,
        pantryChannelId: _pantryId,
        clearPantry: _pantryId == null,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(householdErrorText(error, 'Could not save that.')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    return HouseSheet(
      title: 'Shopping and pantry',
      actionLabel: 'Save',
      busy: _saving,
      onAction: _save,
      children: [
        SheetField(
          label: 'Shop onto',
          child: DropdownButtonFormField<String?>(
            initialValue: _listId,
            isExpanded: true,
            items: [
              const DropdownMenuItem<String?>(child: Text('Ask each time')),
              for (final list in widget.lists)
                DropdownMenuItem<String?>(
                  value: list.id,
                  child: Text('#${list.name}'),
                ),
            ],
            onChanged: (value) => setState(() => _listId = value),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        SheetField(
          label: 'Check against',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String?>(
                initialValue: _pantryId,
                isExpanded: true,
                items: [
                  const DropdownMenuItem<String?>(
                    child: Text('Nothing - add every ingredient'),
                  ),
                  for (final pantry in widget.pantries)
                    DropdownMenuItem<String?>(
                      value: pantry.id,
                      child: Text('#${pantry.name}'),
                    ),
                ],
                onChanged: (value) => setState(() => _pantryId = value),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Without a pantry here, nothing can be left off the list for '
                'already being in the cupboard - and "what can we cook" has '
                'nothing to rank.',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: muted,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
