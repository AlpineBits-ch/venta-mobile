// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RecipeIngredientDto _$RecipeIngredientDtoFromJson(Map<String, dynamic> json) =>
    _RecipeIngredientDto(
      position: (json['position'] as num?)?.toInt() ?? 0,
      text: json['text'] as String? ?? '',
      matchName: json['matchName'] as String?,
      isOptional: json['isOptional'] as bool? ?? false,
    );

Map<String, dynamic> _$RecipeIngredientDtoToJson(
  _RecipeIngredientDto instance,
) => <String, dynamic>{
  'position': instance.position,
  'text': instance.text,
  'matchName': instance.matchName,
  'isOptional': instance.isOptional,
};

_RecipeDto _$RecipeDtoFromJson(Map<String, dynamic> json) => _RecipeDto(
  id: json['id'] as String,
  channelId: json['channelId'] as String,
  title: json['title'] as String? ?? '',
  description: json['description'] as String?,
  servings: (json['servings'] as num?)?.toInt() ?? 2,
  prepMinutes: (json['prepMinutes'] as num?)?.toInt(),
  sourceUrl: json['sourceUrl'] as String?,
  createdByUserId: json['createdByUserId'] as String? ?? '',
  ingredients:
      (json['ingredients'] as List<dynamic>?)
          ?.map((e) => RecipeIngredientDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <RecipeIngredientDto>[],
  createdAt: _$JsonConverterFromJson<String, DateTime>(
    json['createdAt'],
    const ApiDateTimeConverter().fromJson,
  ),
);

Map<String, dynamic> _$RecipeDtoToJson(_RecipeDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'channelId': instance.channelId,
      'title': instance.title,
      'description': instance.description,
      'servings': instance.servings,
      'prepMinutes': instance.prepMinutes,
      'sourceUrl': instance.sourceUrl,
      'createdByUserId': instance.createdByUserId,
      'ingredients': instance.ingredients,
      'createdAt': _$JsonConverterToJson<String, DateTime>(
        instance.createdAt,
        const ApiDateTimeConverter().toJson,
      ),
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

_RecipePageDto _$RecipePageDtoFromJson(Map<String, dynamic> json) =>
    _RecipePageDto(
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => RecipeDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <RecipeDto>[],
      nextCursor: json['nextCursor'] as String?,
    );

Map<String, dynamic> _$RecipePageDtoToJson(_RecipePageDto instance) =>
    <String, dynamic>{
      'items': instance.items,
      'nextCursor': instance.nextCursor,
    };

_MealPlanEntryDto _$MealPlanEntryDtoFromJson(Map<String, dynamic> json) =>
    _MealPlanEntryDto(
      id: json['id'] as String,
      channelId: json['channelId'] as String,
      date: const PlainDateConverter().fromJson(json['date'] as String),
      slot:
          $enumDecodeNullable(
            _$MealSlotEnumMap,
            json['slot'],
            unknownValue: MealSlot.dinner,
          ) ??
          MealSlot.dinner,
      recipeId: json['recipeId'] as String?,
      recipeTitle: json['recipeTitle'] as String?,
      freeText: json['freeText'] as String?,
      cookUserId: json['cookUserId'] as String?,
      servings: (json['servings'] as num?)?.toInt(),
      position: (json['position'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$MealPlanEntryDtoToJson(_MealPlanEntryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'channelId': instance.channelId,
      'date': const PlainDateConverter().toJson(instance.date),
      'slot': _$MealSlotEnumMap[instance.slot]!,
      'recipeId': instance.recipeId,
      'recipeTitle': instance.recipeTitle,
      'freeText': instance.freeText,
      'cookUserId': instance.cookUserId,
      'servings': instance.servings,
      'position': instance.position,
    };

const _$MealSlotEnumMap = {
  MealSlot.breakfast: 'Breakfast',
  MealSlot.lunch: 'Lunch',
  MealSlot.dinner: 'Dinner',
  MealSlot.other: 'Other',
};

_MealPlanConfigDto _$MealPlanConfigDtoFromJson(Map<String, dynamic> json) =>
    _MealPlanConfigDto(
      channelId: json['channelId'] as String? ?? '',
      shoppingListChannelId: json['shoppingListChannelId'] as String?,
      pantryChannelId: json['pantryChannelId'] as String?,
    );

Map<String, dynamic> _$MealPlanConfigDtoToJson(_MealPlanConfigDto instance) =>
    <String, dynamic>{
      'channelId': instance.channelId,
      'shoppingListChannelId': instance.shoppingListChannelId,
      'pantryChannelId': instance.pantryChannelId,
    };

_ShoppingListResultDto _$ShoppingListResultDtoFromJson(
  Map<String, dynamic> json,
) => _ShoppingListResultDto(
  added:
      (json['added'] as List<dynamic>?)
          ?.map((e) => ListItemDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ListItemDto>[],
  skippedInPantry:
      (json['skippedInPantry'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  skippedOnList:
      (json['skippedOnList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  truncated: json['truncated'] as bool? ?? false,
);

Map<String, dynamic> _$ShoppingListResultDtoToJson(
  _ShoppingListResultDto instance,
) => <String, dynamic>{
  'added': instance.added,
  'skippedInPantry': instance.skippedInPantry,
  'skippedOnList': instance.skippedOnList,
  'truncated': instance.truncated,
};

_CookableRecipeDto _$CookableRecipeDtoFromJson(Map<String, dynamic> json) =>
    _CookableRecipeDto(
      recipe: RecipeDto.fromJson(json['recipe'] as Map<String, dynamic>),
      haveCount: (json['haveCount'] as num?)?.toInt() ?? 0,
      missingCount: (json['missingCount'] as num?)?.toInt() ?? 0,
      expiringCount: (json['expiringCount'] as num?)?.toInt() ?? 0,
      expiringNames:
          (json['expiringNames'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      missing:
          (json['missing'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$CookableRecipeDtoToJson(_CookableRecipeDto instance) =>
    <String, dynamic>{
      'recipe': instance.recipe,
      'haveCount': instance.haveCount,
      'missingCount': instance.missingCount,
      'expiringCount': instance.expiringCount,
      'expiringNames': instance.expiringNames,
      'missing': instance.missing,
    };

_CookableResultDto _$CookableResultDtoFromJson(Map<String, dynamic> json) =>
    _CookableResultDto(
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (e) => CookableRecipeDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <CookableRecipeDto>[],
      reason: json['reason'] as String?,
    );

Map<String, dynamic> _$CookableResultDtoToJson(_CookableResultDto instance) =>
    <String, dynamic>{'items': instance.items, 'reason': instance.reason};
