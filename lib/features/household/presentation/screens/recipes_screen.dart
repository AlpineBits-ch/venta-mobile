import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/load_failure_view.dart';
import '../../data/household_api_wave2.dart';
import '../../data/models/meal_dto.dart';
import '../widgets/household_widgets.dart';

/// The house's recipes.
///
/// Doubles as a picker: opened from the meal-plan sheet with [pickMode] set, a
/// tap pops the chosen recipe back rather than opening it. One screen rather
/// than two because the list is the same list and the difference is one line of
/// behaviour.
class RecipesScreen extends StatefulWidget {
  const RecipesScreen({
    super.key,
    required this.channelId,
    required this.canEdit,
    required this.canEditAnyone,
    this.pickMode = false,
  });

  final String channelId;

  /// `PlanMeals` - add a recipe, and edit your own.
  final bool canEdit;

  /// `ManageMeals` - edit and delete anyone's.
  final bool canEditAnyone;

  final bool pickMode;

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  List<RecipeDto>? _recipes;
  String? _nextCursor;
  bool _loadFailed = false;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final page = await householdApi.getRecipes(widget.channelId);
      if (mounted) {
        setState(() {
          _recipes = page.items;
          _nextCursor = page.nextCursor;
          _loadFailed = false;
        });
      }
    } catch (_) {
      if (mounted && _recipes == null) setState(() => _loadFailed = true);
    }
  }

  Future<void> _loadMore() async {
    final cursor = _nextCursor;
    if (cursor == null || _loadingMore) return;
    setState(() => _loadingMore = true);
    try {
      final page = await householdApi.getRecipes(
        widget.channelId,
        cursor: cursor,
      );
      if (!mounted) return;
      setState(() {
        _recipes = [...?_recipes, ...page.items];
        _nextCursor = page.nextCursor;
      });
    } catch (_) {
      // The page already on screen is still correct.
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  Future<void> _openEditor([RecipeDto? existing]) async {
    final saved = await showHouseSheet<bool>(
      context: context,
      builder: (_) =>
          _RecipeSheet(channelId: widget.channelId, existing: existing),
    );
    if (saved == true) await _load();
  }

  void _pick(RecipeDto recipe) => Navigator.of(context).pop(recipe);

  @override
  Widget build(BuildContext context) {
    final recipes = _recipes;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pickMode ? 'Pick a recipe' : 'Recipes'),
      ),
      body: _loadFailed
          ? LoadFailureView(
              message: 'Couldn\'t load the recipes.',
              onRetry: _load,
            )
          : recipes == null
          ? const HouseCardSkeleton(lines: 2)
          : recipes.isEmpty
          ? HouseEmptyState(
              icon: Icons.menu_book_outlined,
              title: 'No recipes yet',
              body: widget.canEdit
                  ? 'Write down the four or five things this house actually '
                        'cooks. Their ingredients are what turns a week of '
                        'plans into a shopping list.'
                  : 'Nobody has written down a recipe yet.',
              action: widget.canEdit
                  ? FilledButton(
                      onPressed: () => unawaited(_openEditor()),
                      child: const Text('Add a recipe'),
                    )
                  : null,
            )
          : RefreshIndicator.adaptive(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.m,
                  AppSpacing.m,
                  AppSpacing.m,
                  HouseActionBar.reservedHeight,
                ),
                children: [
                  for (final recipe in recipes)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.s),
                      child: _RecipeCard(
                        recipe: recipe,
                        onTap: widget.pickMode
                            ? () => _pick(recipe)
                            : widget.canEditAnyone || widget.canEdit
                            ? () => unawaited(_openEditor(recipe))
                            : null,
                      ),
                    ),
                  if (_nextCursor != null)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.s),
                      child: OutlinedButton(
                        onPressed: _loadingMore ? null : _loadMore,
                        child: Text(_loadingMore ? 'Loading…' : 'Show more'),
                      ),
                    ),
                ],
              ),
            ),
      bottomNavigationBar:
          widget.canEdit && !widget.pickMode && (recipes?.isNotEmpty ?? false)
          ? HouseActionBar(
              child: HousePrimaryButton(
                label: 'Add a recipe',
                icon: Icons.add_rounded,
                onPressed: () => unawaited(_openEditor()),
              ),
            )
          : null,
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({required this.recipe, this.onTap});

  final RecipeDto recipe;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    return HouseCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            recipe.title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              HousePill(
                label: 'serves ${recipe.servings}',
                icon: Icons.people_outline_rounded,
              ),
              if (recipe.prepMinutes != null)
                HousePill(
                  label: '${recipe.prepMinutes} min',
                  icon: Icons.timer_outlined,
                ),
              HousePill(
                label: recipe.ingredients.length == 1
                    ? '1 ingredient'
                    : '${recipe.ingredients.length} ingredients',
              ),
            ],
          ),
          if (recipe.description?.trim().isNotEmpty ?? false) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              recipe.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
          ],
        ],
      ),
    );
  }
}

/// Writing a recipe down.
///
/// Ingredients are one free-text line each, typed the way a recipe is written
/// ("2 onions, chopped"). Nothing computes on them except the shopping-list
/// match, and forcing a quantity/unit/name triple would make the common case
/// three times slower to enter for no gain.
class _RecipeSheet extends StatefulWidget {
  const _RecipeSheet({required this.channelId, this.existing});

  final String channelId;
  final RecipeDto? existing;

  @override
  State<_RecipeSheet> createState() => _RecipeSheetState();
}

class _RecipeSheetState extends State<_RecipeSheet> {
  late final _titleController = TextEditingController(
    text: widget.existing?.title ?? '',
  );
  late final _servingsController = TextEditingController(
    text: '${widget.existing?.servings ?? 2}',
  );

  /// One line per ingredient, which is how a recipe is written down and how
  /// somebody will paste one in.
  late final _ingredientsController = TextEditingController(
    text: (widget.existing?.ingredients ?? const <RecipeIngredientDto>[])
        .map((i) => i.text)
        .join('\n'),
  );
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _servingsController.dispose();
    _ingredientsController.dispose();
    super.dispose();
  }

  List<({String text, String? matchName, bool isOptional})> get _ingredients =>
      [
        for (final line in _ingredientsController.text.split('\n'))
          if (line.trim().isNotEmpty)
            (text: line.trim(), matchName: null, isOptional: false),
      ];

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      if (widget.existing == null) {
        await householdApi.createRecipe(
          widget.channelId,
          title: _titleController.text.trim(),
          servings: int.tryParse(_servingsController.text.trim()),
          ingredients: _ingredients,
        );
      } else {
        await householdApi.updateRecipe(
          widget.existing!.id,
          title: _titleController.text.trim(),
          servings: int.tryParse(_servingsController.text.trim()),
          ingredients: _ingredients,
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
      await householdApi.deleteRecipe(existing.id);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(householdErrorText(error, 'Could not delete that.')),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return HouseSheet(
      title: widget.existing == null ? 'New recipe' : 'Edit recipe',
      actionLabel: 'Save',
      busy: _saving,
      onAction: _titleController.text.trim().isEmpty ? null : _save,
      leadingAction: widget.existing == null
          ? null
          : TextButton(
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
              onPressed: _delete,
              child: const Text('Delete'),
            ),
      children: [
        SheetField(
          label: 'Called',
          child: TextField(
            controller: _titleController,
            autofocus: widget.existing == null,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'Lentil soup'),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        SheetField(
          label: 'Serves',
          child: TextField(
            controller: _servingsController,
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        SheetField(
          label: 'Ingredients',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _ingredientsController,
                minLines: 4,
                maxLines: 12,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: '2 onions\n500g red lentils\nStock cube',
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'One per line, written however you write them. These are what '
                'the shopping list is built from.',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
