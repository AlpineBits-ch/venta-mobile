import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/format/api_date_time.dart';
import '../../../../core/format/plain_date.dart';
import 'list_item_dto.dart';

part 'meal_dto.freezed.dart';
part 'meal_dto.g.dart';

/// Which meal of the day a plan entry is for. [other] covers what three slots
/// cannot: a birthday cake, Sunday brunch, whatever this house calls it.
enum MealSlot {
  @JsonValue('Breakfast')
  breakfast,
  @JsonValue('Lunch')
  lunch,
  @JsonValue('Dinner')
  dinner,
  @JsonValue('Other')
  other,
}

extension MealSlotX on MealSlot {
  String get wireValue => switch (this) {
    MealSlot.breakfast => 'Breakfast',
    MealSlot.lunch => 'Lunch',
    MealSlot.dinner => 'Dinner',
    MealSlot.other => 'Other',
  };

  String get label => switch (this) {
    MealSlot.breakfast => 'Breakfast',
    MealSlot.lunch => 'Lunch',
    MealSlot.dinner => 'Dinner',
    MealSlot.other => 'Something else',
  };

  IconData get icon => switch (this) {
    MealSlot.breakfast => Icons.free_breakfast_outlined,
    MealSlot.lunch => Icons.lunch_dining_outlined,
    MealSlot.dinner => Icons.dinner_dining_outlined,
    MealSlot.other => Icons.cake_outlined,
  };

  /// Board order, which is the order the day happens in.
  int get position => switch (this) {
    MealSlot.breakfast => 0,
    MealSlot.lunch => 1,
    MealSlot.dinner => 2,
    MealSlot.other => 3,
  };
}

@freezed
sealed class RecipeIngredientDto with _$RecipeIngredientDto {
  const factory RecipeIngredientDto({
    @Default(0) int position,

    /// As written on the recipe - "2 onions, chopped".
    @Default('') String text,

    /// What the pantry and the shopping list match on, when the free text is
    /// too wordy to match by itself.
    String? matchName,

    /// Garnish. Left out of the shopping list unless asked for, and never
    /// counted against whether a recipe is cookable.
    @Default(false) bool isOptional,
  }) = _RecipeIngredientDto;

  factory RecipeIngredientDto.fromJson(Map<String, dynamic> json) =>
      _$RecipeIngredientDtoFromJson(json);
}

/// Caps: 60 ingredients, 200 recipes per channel.
@freezed
sealed class RecipeDto with _$RecipeDto {
  @ApiDateTimeConverter()
  const factory RecipeDto({
    required String id,
    required String channelId,
    @Default('') String title,
    String? description,
    @Default(2) int servings,
    int? prepMinutes,
    String? sourceUrl,
    @Default('') String createdByUserId,
    @Default(<RecipeIngredientDto>[]) List<RecipeIngredientDto> ingredients,
    DateTime? createdAt,
  }) = _RecipeDto;

  factory RecipeDto.fromJson(Map<String, dynamic> json) =>
      _$RecipeDtoFromJson(json);
}

@freezed
sealed class RecipePageDto with _$RecipePageDto {
  const factory RecipePageDto({
    @Default(<RecipeDto>[]) List<RecipeDto> items,
    String? nextCursor,
  }) = _RecipePageDto;

  factory RecipePageDto.fromJson(Map<String, dynamic> json) =>
      _$RecipePageDtoFromJson(json);
}

/// One slot of one day. At least one of [recipeId] / [freeText] is set - most
/// of a real week is "leftovers" rather than a recipe.
@freezed
sealed class MealPlanEntryDto with _$MealPlanEntryDto {
  @PlainDateConverter()
  const factory MealPlanEntryDto({
    required String id,
    required String channelId,

    /// A plain date, deliberately: Thursday dinner is Thursday dinner wherever
    /// your phone is. See [PlainDate].
    required PlainDate date,
    @Default(MealSlot.dinner)
    @JsonKey(unknownEnumValue: MealSlot.dinner)
    MealSlot slot,
    String? recipeId,

    /// Denormalized so a week renders without fetching every recipe it names.
    String? recipeTitle,
    String? freeText,
    String? cookUserId,
    int? servings,
    @Default(0) int position,
  }) = _MealPlanEntryDto;

  factory MealPlanEntryDto.fromJson(Map<String, dynamic> json) =>
      _$MealPlanEntryDtoFromJson(json);
}

extension MealPlanEntryX on MealPlanEntryDto {
  /// One line either way - the recipe's title, or what somebody typed.
  String get displayTitle {
    final title = recipeTitle?.trim();
    if (title != null && title.isNotEmpty) return title;
    final text = freeText?.trim();
    return text == null || text.isEmpty ? 'Something' : text;
  }
}

@freezed
sealed class MealPlanConfigDto with _$MealPlanConfigDto {
  const factory MealPlanConfigDto({
    @Default('') String channelId,

    /// Where the plan-to-shopping-list button writes. Must be a `List` channel
    /// in this guild.
    String? shoppingListChannelId,

    /// What "we already have that" is checked against. Without it the pantry
    /// skip cannot happen and every ingredient is added.
    String? pantryChannelId,
  }) = _MealPlanConfigDto;

  factory MealPlanConfigDto.fromJson(Map<String, dynamic> json) =>
      _$MealPlanConfigDtoFromJson(json);
}

/// What the plan-to-shopping-list button did, **including what it chose not to
/// do**.
///
/// The two skip lists are the point. A shopper who opens the list and finds no
/// onions on it cannot tell a working pantry check from a broken button, and
/// will not press it twice. Both have to be rendered.
@freezed
sealed class ShoppingListResultDto with _$ShoppingListResultDto {
  const factory ShoppingListResultDto({
    @Default(<ListItemDto>[]) List<ListItemDto> added,

    /// Dropped because the configured pantry already has them.
    @Default(<String>[]) List<String> skippedInPantry,

    /// Dropped because an unchecked line on the target list already covers
    /// them.
    @Default(<String>[]) List<String> skippedOnList,

    /// The per-call line cap was hit and the plan had more - offer to run it
    /// again for the rest rather than quietly shipping half a week.
    @Default(false) bool truncated,
  }) = _ShoppingListResultDto;

  factory ShoppingListResultDto.fromJson(Map<String, dynamic> json) =>
      _$ShoppingListResultDtoFromJson(json);
}

/// A recipe ranked by how much about-to-expire stock it uses up.
@freezed
sealed class CookableRecipeDto with _$CookableRecipeDto {
  const factory CookableRecipeDto({
    required RecipeDto recipe,

    /// Ingredients the pantry can cover, optional ones included.
    @Default(0) int haveCount,

    /// **Required** ingredients the pantry cannot cover. Optional lines are
    /// excluded: counting garnish would rank a dinner you can absolutely cook
    /// tonight below one you cannot.
    @Default(0) int missingCount,

    /// How many of the covering items are inside the expiry horizon. The
    /// primary sort key, and the entire reason this exists.
    @Default(0) int expiringCount,
    @Default(<String>[]) List<String> expiringNames,
    @Default(<String>[]) List<String> missing,
  }) = _CookableRecipeDto;

  factory CookableRecipeDto.fromJson(Map<String, dynamic> json) =>
      _$CookableRecipeDtoFromJson(json);
}

@freezed
sealed class CookableResultDto with _$CookableResultDto {
  const factory CookableResultDto({
    @Default(<CookableRecipeDto>[]) List<CookableRecipeDto> items,

    /// Why [items] is empty when it is: no pantry module, no configured
    /// pantry, or nothing in stock. Null when the ranking is genuine. Rendered
    /// rather than swallowed - a bare empty list leaves the house believing the
    /// feature is broken when it is only unconfigured.
    String? reason,
  }) = _CookableResultDto;

  factory CookableResultDto.fromJson(Map<String, dynamic> json) =>
      _$CookableResultDtoFromJson(json);
}
