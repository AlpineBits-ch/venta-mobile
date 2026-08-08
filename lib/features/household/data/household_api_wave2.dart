// Request bodies here are built with `if (x != null) 'key': x`, which is the
// shape every other API file in this app uses (`household_api.dart`,
// `guild_api.dart`, `wiki_api.dart`) and which reads better next to the
// `if (clearX) 'key': null else if (x != null) ...` pairs that carry the
// null-vs-absent distinction the server cares about. `flutter_lints` would
// rather have the newer `'key': ?x` element form; adopting it in this one file
// would make it the only API file in the repo spelled that way, so the lint is
// silenced here rather than the convention broken. Worth sweeping repo-wide in
// one go if it is ever worth doing at all.
// ignore_for_file: use_null_aware_elements

import 'package:dio/dio.dart';

import '../../../core/format/plain_date.dart';
import 'household_api.dart';
import 'models/absence_dto.dart';
import 'models/bill_dto.dart';
import 'models/ledger_dto.dart';
import 'models/maintenance_dto.dart';
import 'models/meal_dto.dart';
import 'models/pantry_dto.dart';

/// The second wave of household modules, on the same client [HouseholdApi]
/// uses.
///
/// An extension rather than more methods on the class itself: `household_api`
/// is already the longest file in this feature, and bills, meals, maintenance,
/// absences and pantry capture are five modules that arrived together and will
/// be read together. Nothing here is special - same base, same gateway prefix,
/// same `403`-means-the-module-is-off rule.
extension HouseholdApiWave2 on HouseholdApi {
  String get _base => client.url('/api/v1/guild');

  static String? _iso(DateTime? value) => value?.toUtc().toIso8601String();

  // ---------------------------------------------------------------- bills

  Future<List<RecurringExpenseDto>> getRecurringExpenses(
    String channelId,
  ) async {
    final response = await client.dio.get<List<dynamic>>(
      '$_base/channels/$channelId/recurring-expenses',
    );
    return response.data!
        .map(
          (json) => RecurringExpenseDto.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  /// [amountMinor] null means the amount varies and every period waits for a
  /// figure. [autoPost] is only legal alongside a fixed amount - the server
  /// answers `400` otherwise, and so should the form.
  Future<RecurringExpenseDto> createRecurringExpense(
    String channelId, {
    required String description,
    int? amountMinor,
    String? payerUserId,
    SplitKind splitKind = SplitKind.equal,
    ExpenseCategory category = ExpenseCategory.uncategorized,
    RecurrenceUnit recurrenceUnit = RecurrenceUnit.month,
    int recurrenceInterval = 1,
    DateTime? anchorAt,
    int leadDays = 3,
    bool autoPost = false,
    List<({String userId, num shareValue})> shares = const [],
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '$_base/channels/$channelId/recurring-expenses',
      data: {
        'description': description,
        if (amountMinor != null) 'amountMinor': amountMinor,
        if (payerUserId != null) 'payerUserId': payerUserId,
        'splitKind': splitKind.wireValue,
        'category': category.wireValue,
        'recurrenceUnit': recurrenceUnit.wireValue,
        'recurrenceInterval': recurrenceInterval,
        if (anchorAt != null) 'anchorAt': _iso(anchorAt),
        'leadDays': leadDays,
        'autoPost': autoPost,
        'shares': [
          for (final share in shares)
            {'userId': share.userId, 'shareValue': share.shareValue},
        ],
      },
    );
    return RecurringExpenseDto.fromJson(response.data!);
  }

  /// Editing a schedule **moves** its pending bills rather than regenerating
  /// them, so an amount somebody typed off a paper letter survives a change of
  /// due date.
  Future<RecurringExpenseDto> updateRecurringExpense(
    String templateId, {
    String? description,
    int? amountMinor,
    bool clearAmount = false,
    String? payerUserId,
    SplitKind? splitKind,
    ExpenseCategory? category,
    RecurrenceUnit? recurrenceUnit,
    int? recurrenceInterval,
    DateTime? anchorAt,
    int? leadDays,
    bool? autoPost,
    bool? isPaused,
    List<({String userId, num shareValue})>? shares,
  }) async {
    final response = await client.dio.patch<Map<String, dynamic>>(
      '$_base/recurring-expenses/$templateId',
      data: {
        if (description != null) 'description': description,
        if (clearAmount)
          'clearAmount': true
        else if (amountMinor != null)
          'amountMinor': amountMinor,
        if (payerUserId != null) 'payerUserId': payerUserId,
        if (splitKind != null) 'splitKind': splitKind.wireValue,
        if (category != null) 'category': category.wireValue,
        if (recurrenceUnit != null) 'recurrenceUnit': recurrenceUnit.wireValue,
        if (recurrenceInterval != null)
          'recurrenceInterval': recurrenceInterval,
        if (anchorAt != null) 'anchorAt': _iso(anchorAt),
        if (leadDays != null) 'leadDays': leadDays,
        if (autoPost != null) 'autoPost': autoPost,
        if (isPaused != null) 'isPaused': isPaused,
        if (shares != null)
          'shares': [
            for (final share in shares)
              {'userId': share.userId, 'shareValue': share.shareValue},
          ],
      },
    );
    return RecurringExpenseDto.fromJson(response.data!);
  }

  Future<void> deleteRecurringExpense(String templateId) async {
    await client.dio.delete<void>('$_base/recurring-expenses/$templateId');
  }

  /// The house's obligations, not its history. [status] is `Pending`, `Posted`
  /// or `Skipped`.
  Future<List<BillOccurrenceDto>> getBills(
    String channelId, {
    BillStatus? status,
    DateTime? from,
    DateTime? to,
  }) async {
    final response = await client.dio.get<List<dynamic>>(
      '$_base/channels/$channelId/bills',
      queryParameters: {
        if (status != null) 'status': status.wireValue,
        if (from != null) 'from': _iso(from),
        if (to != null) 'to': _iso(to),
      },
    );
    return response.data!
        .map((json) => BillOccurrenceDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Turns an obligation into an expense.
  ///
  /// [amountMinor] is required for a variable bill and optional for a fixed
  /// one; [occurredAt] defaults server-side to now, which is right for "I have
  /// just paid this" and wrong for a letter that has been on the table a week.
  Future<BillOccurrenceDto> postBill(
    String billId, {
    int? amountMinor,
    DateTime? occurredAt,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '$_base/bills/$billId/post',
      data: {
        if (amountMinor != null) 'amountMinor': amountMinor,
        if (occurredAt != null) 'occurredAt': _iso(occurredAt),
      },
    );
    return BillOccurrenceDto.fromJson(response.data!);
  }

  /// Not charged this period. Distinct from deleting the schedule, which would
  /// lose every future period with it.
  Future<BillOccurrenceDto> skipBill(String billId, {String? reason}) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '$_base/bills/$billId/skip',
      data: {if (reason != null && reason.isNotEmpty) 'reason': reason},
    );
    return BillOccurrenceDto.fromJson(response.data!);
  }

  // ------------------------------------------------------- ledger rollup

  /// Default window is six months, capped at three years.
  ///
  /// `byPeriod` is **not zero-filled**: a month with no spending is absent
  /// rather than present as a zero, so nothing here may draw the gap as a data
  /// point.
  Future<LedgerSummaryDto> getLedgerSummary(
    String channelId, {
    DateTime? from,
    DateTime? to,
    String? groupBy,
  }) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '$_base/channels/$channelId/ledger/summary',
      queryParameters: {
        if (from != null) 'from': _iso(from),
        if (to != null) 'to': _iso(to),
        if (groupBy != null) 'groupBy': groupBy,
      },
    );
    return LedgerSummaryDto.fromJson(response.data!);
  }

  /// Presigned per request - **never cache one of these URLs**, it carries an
  /// expiry and a stored copy 403s the moment it lapses.
  Future<List<ExpenseReceiptDto>> getReceipts(String expenseId) async {
    final response = await client.dio.get<List<dynamic>>(
      '$_base/expenses/$expenseId/receipts',
    );
    return response.data!
        .map((json) => ExpenseReceiptDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<ExpenseReceiptDto> uploadReceipt(
    String expenseId, {
    required String filePath,
    required String fileName,
  }) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });
    final response = await client.dio.post<Map<String, dynamic>>(
      '$_base/expenses/$expenseId/receipts',
      data: form,
    );
    return ExpenseReceiptDto.fromJson(response.data!);
  }

  Future<void> deleteReceipt(String receiptId) async {
    await client.dio.delete<void>('$_base/receipts/$receiptId');
  }

  // -------------------------------------------------------------- absence

  Future<List<AbsenceDto>> getAbsences(
    String guildId, {
    DateTime? from,
    DateTime? to,
  }) async {
    final response = await client.dio.get<List<dynamic>>(
      '$_base/guilds/$guildId/absences',
      queryParameters: {
        if (from != null) 'from': _iso(from),
        if (to != null) 'to': _iso(to),
      },
    );
    return response.data!
        .map((json) => AbsenceDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// **Your own only.** There is no permission bit and no way to declare
  /// somebody else away: doing so would move their chores off them without
  /// their knowing.
  ///
  /// Max 180 days, max 20 live per member, and an overlap is rejected with a
  /// `400` naming the collision rather than merged.
  Future<AbsenceSavedDto> createAbsence(
    String guildId, {
    required DateTime startAt,
    required DateTime endAt,
    String? note,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '$_base/guilds/$guildId/absences',
      data: {
        'startAt': _iso(startAt),
        'endAt': _iso(endAt),
        if (note != null && note.isNotEmpty) 'note': note,
      },
    );
    return AbsenceSavedDto.fromJson(response.data!);
  }

  Future<AbsenceSavedDto> updateAbsence(
    String absenceId, {
    DateTime? startAt,
    DateTime? endAt,
    String? note,
    bool clearNote = false,
  }) async {
    final response = await client.dio.patch<Map<String, dynamic>>(
      '$_base/absences/$absenceId',
      data: {
        if (startAt != null) 'startAt': _iso(startAt),
        if (endAt != null) 'endAt': _iso(endAt),
        if (clearNote) 'clearNote': true else if (note != null) 'note': note,
      },
    );
    return AbsenceSavedDto.fromJson(response.data!);
  }

  Future<void> deleteAbsence(String absenceId) async {
    await client.dio.delete<void>('$_base/absences/$absenceId');
  }

  // ---------------------------------------------------------------- nudge

  /// Asks the house about an overdue chore, **without saying who asked**.
  ///
  /// Nothing in the request, the payload or the copy carries a sender, and the
  /// UI must not add one. The entire value of the feature is that the app does
  /// the asking so nobody has to be the person who nags.
  ///
  /// Throws [NudgeRejected] on the two `409`s: a second nudge inside the
  /// 12-hour cooldown (per occurrence, not per sender), and one inside the
  /// guild's quiet hours - which is **rejected, not deferred**. A deferred
  /// reminder is still true at 07:00; a deferred nudge is somebody's 23:40
  /// impulse arriving seven hours later about a bin that may already be out.
  Future<DateTime?> nudgeOccurrence(String occurrenceId) async {
    try {
      final response = await client.dio.post<Map<String, dynamic>>(
        '$_base/chore-occurrences/$occurrenceId/nudge',
      );
      final raw = response.data?['nudgedAt'];
      return raw is String ? DateTime.tryParse(raw)?.toUtc() : null;
    } on DioException catch (error) {
      final rejected = NudgeRejected.tryParse(error);
      if (rejected != null) throw rejected;
      rethrow;
    }
  }

  // -------------------------------------------------------- pantry capture

  /// One scan, resolved in three steps that get progressively less certain
  /// about what the code means.
  ///
  /// What this house has already called the code wins outright. Failing that a
  /// shared public product catalog may suggest a name, which comes back on
  /// [ScanResultDto.catalog] with the credit it owes its source and **without**
  /// teaching the house anything. Failing both, this throws
  /// [PantryNameRequired] - still the one moment worth interrupting somebody
  /// for, and now a much rarer one, because a common grocery resolves on its
  /// first scan rather than its second.
  ///
  /// The catalog step may make one outbound call, bounded so that it can never
  /// make a scan worse than a scan with no catalog behind it at all: the server
  /// skips it unless the instance has budget against the source's rate limit,
  /// cuts it off after about a second, and treats any failure as "no
  /// suggestion".
  ///
  /// [cancelToken] exists because this is the one call in the feature a person
  /// stands and waits for. The client's own timeouts bound a single attempt,
  /// but a `429` retry is a wait on top of that and the catalog step adds its
  /// own second - so the scanner puts a deadline on the whole thing and needs a
  /// way to actually abandon the request rather than leave it running behind a
  /// screen that has already given up on it.
  Future<ScanResultDto> scanPantryItem(
    String channelId, {
    required String barcode,
    double? quantity,
    String? name,
    String? unit,
    DateTime? expiresAt,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await client.dio.post<Map<String, dynamic>>(
        '$_base/channels/$channelId/pantry-items/scan',
        cancelToken: cancelToken,
        data: {
          'barcode': barcode,
          if (quantity != null) 'quantity': quantity,
          if (name != null && name.isNotEmpty) 'name': name,
          if (unit != null && unit.isNotEmpty) 'unit': unit,
          if (expiresAt != null) 'expiresAt': _iso(expiresAt),
        },
      );
      return ScanResultDto.fromJson(response.data!);
    } on DioException catch (error) {
      if (PantryNameRequired.matches(error)) {
        throw PantryNameRequired(barcode);
      }
      rethrow;
    }
  }

  /// The one-tap "used it up". Runs the same low-stock and restock loop a
  /// manual edit does, so the same alerts fire.
  Future<PantryItemDto> consumePantryItem(
    String itemId, {
    double? amount,
    bool all = false,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '$_base/pantry-items/$itemId/consume',
      data: {if (all) 'all': true else if (amount != null) 'amount': amount},
    );
    return PantryItemDto.fromJson(response.data!);
  }

  /// Also ticks off the shopping-list line the pantry created, which is what
  /// re-arms the restock loop for next time.
  Future<PantryItemDto> restockPantryItem(
    String itemId, {
    double? amount,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '$_base/pantry-items/$itemId/restock',
      data: {if (amount != null) 'amount': amount},
    );
    return PantryItemDto.fromJson(response.data!);
  }

  /// "This is what we call this." The house stating a name for a barcode.
  ///
  /// **Moves no stock**, which is the whole reason it is not a second scan. A
  /// scan carrying a name would add to the jar, cannot be asked to add nothing,
  /// and rewrites the learned default quantity on the way past - three things a
  /// client would have to compensate for, twice, differently, on two platforms.
  ///
  /// It is also where a catalog suggestion stops being a suggestion. Until
  /// somebody calls this, an ODbL-derived name has taught the house nothing on
  /// purpose; afterwards it is a name a person stated, it is the house's, and it
  /// wins over the catalog on every scan from then on.
  ///
  /// [unit] and [defaultQuantity] left null mean "leave whatever is there", not
  /// "clear it": a correction made from a scanner toast knows the name and
  /// nothing else.
  Future<TeachBarcodeResultDto> teachPantryBarcode(
    String guildId,
    String barcode, {
    required String name,
    String? unit,
    double? defaultQuantity,
  }) async {
    final response = await client.dio.put<Map<String, dynamic>>(
      '$_base/guilds/$guildId/pantry/barcodes/${Uri.encodeComponent(barcode)}',
      data: {
        'name': name,
        if (unit != null && unit.isNotEmpty) 'unit': unit,
        if (defaultQuantity != null) 'defaultQuantity': defaultQuantity,
      },
    );
    return TeachBarcodeResultDto.fromJson(response.data!);
  }

  Future<List<PantryBarcodeDto>> getLearnedBarcodes(
    String guildId, {
    String? query,
  }) async {
    final response = await client.dio.get<List<dynamic>>(
      '$_base/guilds/$guildId/pantry/barcodes',
      queryParameters: {if (query != null && query.isNotEmpty) 'q': query},
    );
    return response.data!
        .map((json) => PantryBarcodeDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ---------------------------------------------------------------- meals

  Future<RecipePageDto> getRecipes(
    String channelId, {
    int? limit,
    String? cursor,
  }) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '$_base/channels/$channelId/recipes',
      queryParameters: {
        if (limit != null) 'limit': limit,
        if (cursor != null) 'cursor': cursor,
      },
    );
    return RecipePageDto.fromJson(response.data!);
  }

  Future<RecipeDto> createRecipe(
    String channelId, {
    required String title,
    String? description,
    int? servings,
    int? prepMinutes,
    String? sourceUrl,
    List<({String text, String? matchName, bool isOptional})> ingredients =
        const [],
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '$_base/channels/$channelId/recipes',
      data: {
        'title': title,
        if (description != null) 'description': description,
        if (servings != null) 'servings': servings,
        if (prepMinutes != null) 'prepMinutes': prepMinutes,
        if (sourceUrl != null) 'sourceUrl': sourceUrl,
        'ingredients': [
          for (final line in ingredients)
            {
              'text': line.text,
              if (line.matchName != null) 'matchName': line.matchName,
              'isOptional': line.isOptional,
            },
        ],
      },
    );
    return RecipeDto.fromJson(response.data!);
  }

  Future<RecipeDto> updateRecipe(
    String recipeId, {
    String? title,
    String? description,
    bool clearDescription = false,
    int? servings,
    int? prepMinutes,
    bool clearPrepMinutes = false,
    String? sourceUrl,
    bool clearSourceUrl = false,
    List<({String text, String? matchName, bool isOptional})>? ingredients,
  }) async {
    final response = await client.dio.patch<Map<String, dynamic>>(
      '$_base/recipes/$recipeId',
      data: {
        if (title != null) 'title': title,
        if (clearDescription)
          'clearDescription': true
        else if (description != null)
          'description': description,
        if (servings != null) 'servings': servings,
        if (clearPrepMinutes)
          'clearPrepMinutes': true
        else if (prepMinutes != null)
          'prepMinutes': prepMinutes,
        if (clearSourceUrl)
          'clearSourceUrl': true
        else if (sourceUrl != null)
          'sourceUrl': sourceUrl,
        if (ingredients != null)
          'ingredients': [
            for (final line in ingredients)
              {
                'text': line.text,
                if (line.matchName != null) 'matchName': line.matchName,
                'isOptional': line.isOptional,
              },
          ],
      },
    );
    return RecipeDto.fromJson(response.data!);
  }

  Future<void> deleteRecipe(String recipeId) async {
    await client.dio.delete<void>('$_base/recipes/$recipeId');
  }

  /// The window is capped at 60 days server-side.
  Future<List<MealPlanEntryDto>> getMealPlan(
    String channelId, {
    required PlainDate from,
    required PlainDate to,
  }) async {
    final response = await client.dio.get<List<dynamic>>(
      '$_base/channels/$channelId/meal-plan',
      queryParameters: {'from': from.toIso(), 'to': to.toIso()},
    );
    return response.data!
        .map((json) => MealPlanEntryDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// At least one of [recipeId] / [freeText] is required.
  Future<MealPlanEntryDto> createMealPlanEntry(
    String channelId, {
    required PlainDate date,
    MealSlot slot = MealSlot.dinner,
    String? recipeId,
    String? freeText,
    String? cookUserId,
    int? servings,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '$_base/channels/$channelId/meal-plan',
      data: {
        'date': date.toIso(),
        'slot': slot.wireValue,
        if (recipeId != null) 'recipeId': recipeId,
        if (freeText != null && freeText.isNotEmpty) 'freeText': freeText,
        if (cookUserId != null) 'cookUserId': cookUserId,
        if (servings != null) 'servings': servings,
      },
    );
    return MealPlanEntryDto.fromJson(response.data!);
  }

  Future<MealPlanEntryDto> updateMealPlanEntry(
    String entryId, {
    PlainDate? date,
    MealSlot? slot,
    String? recipeId,
    bool clearRecipe = false,
    String? freeText,
    bool clearFreeText = false,
    String? cookUserId,
    bool clearCook = false,
    int? servings,
    bool clearServings = false,
  }) async {
    final response = await client.dio.patch<Map<String, dynamic>>(
      '$_base/meal-plan/$entryId',
      data: {
        if (date != null) 'date': date.toIso(),
        if (slot != null) 'slot': slot.wireValue,
        if (clearRecipe)
          'clearRecipe': true
        else if (recipeId != null)
          'recipeId': recipeId,
        if (clearFreeText)
          'clearFreeText': true
        else if (freeText != null)
          'freeText': freeText,
        if (clearCook)
          'clearCook': true
        else if (cookUserId != null)
          'cookUserId': cookUserId,
        if (clearServings)
          'clearServings': true
        else if (servings != null)
          'servings': servings,
      },
    );
    return MealPlanEntryDto.fromJson(response.data!);
  }

  Future<void> deleteMealPlanEntry(String entryId) async {
    await client.dio.delete<void>('$_base/meal-plan/$entryId');
  }

  /// The plan turned into one shop.
  ///
  /// Collects the window's ingredients, drops what the pantry already has and
  /// what is already on the list, and appends the rest with `section` set to
  /// the recipe's title. **Both skip reasons come back and both have to be
  /// shown** - a shopper who cannot see why onions are missing will not trust
  /// the button twice. Ingredients are deliberately not scaled by servings.
  Future<ShoppingListResultDto> generateShoppingList(
    String channelId, {
    required PlainDate from,
    required PlainDate to,
    String? listChannelId,
    bool includeOptional = false,
    bool skipPantry = false,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '$_base/channels/$channelId/meal-plan/shopping-list',
      data: {
        'from': from.toIso(),
        'to': to.toIso(),
        if (listChannelId != null) 'listChannelId': listChannelId,
        'includeOptional': includeOptional,
        'skipPantry': skipPantry,
      },
    );
    return ShoppingListResultDto.fromJson(response.data!);
  }

  /// Ranked by how much about-to-expire stock a recipe uses up, then by how
  /// little is missing. Two sort keys a person can predict, and no slider.
  Future<CookableResultDto> getCookableRecipes(
    String channelId, {
    int? expiringDays,
    int? limit,
  }) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '$_base/channels/$channelId/recipes/cookable',
      queryParameters: {
        if (expiringDays != null) 'expiringDays': expiringDays,
        if (limit != null) 'limit': limit,
      },
    );
    return CookableResultDto.fromJson(response.data!);
  }

  Future<MealPlanConfigDto> getMealPlanConfig(String channelId) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '$_base/channels/$channelId/meals/config',
    );
    return MealPlanConfigDto.fromJson(response.data!);
  }

  Future<MealPlanConfigDto> updateMealPlanConfig(
    String channelId, {
    String? shoppingListChannelId,
    bool clearShoppingList = false,
    String? pantryChannelId,
    bool clearPantry = false,
  }) async {
    final response = await client.dio.put<Map<String, dynamic>>(
      '$_base/channels/$channelId/meals/config',
      data: {
        if (clearShoppingList)
          'clearShoppingList': true
        else if (shoppingListChannelId != null)
          'shoppingListChannelId': shoppingListChannelId,
        if (clearPantry)
          'clearPantry': true
        else if (pantryChannelId != null)
          'pantryChannelId': pantryChannelId,
      },
    );
    return MealPlanConfigDto.fromJson(response.data!);
  }

  // ---------------------------------------------------------- maintenance

  Future<List<MaintenanceAssetDto>> getMaintenanceAssets(
    String channelId,
  ) async {
    final response = await client.dio.get<List<dynamic>>(
      '$_base/channels/$channelId/maintenance-assets',
    );
    return response.data!
        .map(
          (json) => MaintenanceAssetDto.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  Future<MaintenanceAssetDto> createMaintenanceAsset(
    String channelId, {
    required String name,
    String? location,
    String? brand,
    String? model,
    String? serialNumber,
    DateTime? purchasedAt,
    DateTime? warrantyUntil,
    String? vendorName,
    String? vendorPhone,
    String? vendorEmail,
    String? notes,
    int? serviceIntervalDays,
    DateTime? lastServicedAt,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '$_base/channels/$channelId/maintenance-assets',
      data: {
        'name': name,
        if (location != null) 'location': location,
        if (brand != null) 'brand': brand,
        if (model != null) 'model': model,
        if (serialNumber != null) 'serialNumber': serialNumber,
        if (purchasedAt != null) 'purchasedAt': _iso(purchasedAt),
        if (warrantyUntil != null) 'warrantyUntil': _iso(warrantyUntil),
        if (vendorName != null) 'vendorName': vendorName,
        if (vendorPhone != null) 'vendorPhone': vendorPhone,
        if (vendorEmail != null) 'vendorEmail': vendorEmail,
        if (notes != null) 'notes': notes,
        if (serviceIntervalDays != null)
          'serviceIntervalDays': serviceIntervalDays,
        if (lastServicedAt != null) 'lastServicedAt': _iso(lastServicedAt),
      },
    );
    return MaintenanceAssetDto.fromJson(response.data!);
  }

  Future<MaintenanceAssetDto> updateMaintenanceAsset(
    String assetId, {
    String? name,
    String? location,
    String? brand,
    String? model,
    String? serialNumber,
    DateTime? purchasedAt,
    bool clearPurchasedAt = false,
    DateTime? warrantyUntil,
    bool clearWarrantyUntil = false,
    String? vendorName,
    String? vendorPhone,
    String? vendorEmail,
    String? notes,
    int? serviceIntervalDays,
    bool clearServiceInterval = false,
    DateTime? lastServicedAt,
  }) async {
    final response = await client.dio.patch<Map<String, dynamic>>(
      '$_base/maintenance-assets/$assetId',
      data: {
        if (name != null) 'name': name,
        if (location != null) 'location': location,
        if (brand != null) 'brand': brand,
        if (model != null) 'model': model,
        if (serialNumber != null) 'serialNumber': serialNumber,
        if (clearPurchasedAt)
          'clearPurchasedAt': true
        else if (purchasedAt != null)
          'purchasedAt': _iso(purchasedAt),
        if (clearWarrantyUntil)
          'clearWarrantyUntil': true
        else if (warrantyUntil != null)
          'warrantyUntil': _iso(warrantyUntil),
        if (vendorName != null) 'vendorName': vendorName,
        if (vendorPhone != null) 'vendorPhone': vendorPhone,
        if (vendorEmail != null) 'vendorEmail': vendorEmail,
        if (notes != null) 'notes': notes,
        if (clearServiceInterval)
          'clearServiceInterval': true
        else if (serviceIntervalDays != null)
          'serviceIntervalDays': serviceIntervalDays,
        if (lastServicedAt != null) 'lastServicedAt': _iso(lastServicedAt),
      },
    );
    return MaintenanceAssetDto.fromJson(response.data!);
  }

  Future<void> deleteMaintenanceAsset(String assetId) async {
    await client.dio.delete<void>('$_base/maintenance-assets/$assetId');
  }

  /// Reporting a fault is `LogMaintenance`, **not** `ManageMaintenance`, on
  /// purpose: whoever discovers the washing machine is dead is whoever tried to
  /// use it. It should be one tap from anywhere the asset appears.
  Future<MaintenanceAssetDto> setAssetStatus(
    String assetId, {
    required AssetStatus status,
    String? note,
  }) async {
    final response = await client.dio.put<Map<String, dynamic>>(
      '$_base/maintenance-assets/$assetId/status',
      data: {
        'status': status.wireValue,
        if (note != null && note.isNotEmpty) 'note': note,
      },
    );
    return MaintenanceAssetDto.fromJson(response.data!);
  }

  /// Records what was actually done and when, and schedules the next service
  /// from **that** date rather than from the one it was supposed to happen on.
  ///
  /// It does not clear a `Broken` status: a visit is not proof it works.
  Future<MaintenanceAssetDto> recordService(
    String assetId, {
    DateTime? performedAt,
    String? title,
    String? notes,
    String? vendorName,
    int? costMinor,
    String? currency,
    String? expenseId,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '$_base/maintenance-assets/$assetId/serviced',
      data: {
        if (performedAt != null) 'performedAt': _iso(performedAt),
        if (title != null && title.isNotEmpty) 'title': title,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        if (vendorName != null && vendorName.isNotEmpty)
          'vendorName': vendorName,
        if (costMinor != null) 'costMinor': costMinor,
        if (currency != null) 'currency': currency,
        if (expenseId != null) 'expenseId': expenseId,
      },
    );
    return MaintenanceAssetDto.fromJson(response.data!);
  }

  Future<MaintenanceRecordPageDto> getMaintenanceRecords(
    String channelId, {
    String? assetId,
    int? limit,
    String? cursor,
  }) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '$_base/channels/$channelId/maintenance-records',
      queryParameters: {
        if (assetId != null) 'assetId': assetId,
        if (limit != null) 'limit': limit,
        if (cursor != null) 'cursor': cursor,
      },
    );
    return MaintenanceRecordPageDto.fromJson(response.data!);
  }

  /// Spans every maintenance channel the caller can see: what is broken, what
  /// is overdue a service, and what is about to fall out of warranty.
  Future<List<MaintenanceAttentionDto>> getMaintenanceAttention(
    String guildId,
  ) async {
    final response = await client.dio.get<List<dynamic>>(
      '$_base/guilds/$guildId/maintenance/attention',
    );
    return response.data!
        .map(
          (json) =>
              MaintenanceAttentionDto.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }
}

/// A scan that nothing could put a name to: not this house, and not the shared
/// product catalog either.
///
/// Not a failure - it is the feature working through to its last step. A
/// scanner catches this, asks for a name, and re-scans with it, after which the
/// house owns the answer forever. It stays the normal outcome for cleaning
/// products and toiletries, where public coverage is close to zero.
class PantryNameRequired implements Exception {
  const PantryNameRequired(this.barcode);

  final String barcode;

  /// Matched on the server's own wording because the endpoint answers a plain
  /// `400` for every validation failure it has. A future build that adds a
  /// machine-readable code should switch to it; getting this wrong costs a
  /// scanner one clumsy error message, not a lost item.
  static bool matches(DioException error) {
    if (error.response?.statusCode != 400) return false;
    final data = error.response?.data;
    final text = data is String ? data : data?.toString() ?? '';
    return text.toLowerCase().contains('name is required');
  }

  @override
  String toString() => 'PantryNameRequired($barcode)';
}

/// The `409` a nudge answers with, carrying when it would be accepted.
///
/// Two shapes, one class: a cooldown that has not run out
/// ([nextNudgeAt]) and a house that is asleep ([quietUntil]). Both are
/// answerable with a time rather than an apology, which is the difference
/// between "that didn't work" and "try after seven".
///
/// Note what it does **not** carry: who nudged last. The cooldown is per
/// occurrence rather than per sender precisely so that nobody can be identified
/// by elimination.
class NudgeRejected implements Exception {
  const NudgeRejected({
    required this.message,
    this.nextNudgeAt,
    this.quietUntil,
  });

  final String message;

  /// Somebody already nudged about this occurrence recently.
  final DateTime? nextNudgeAt;

  /// The house is inside its quiet hours. **Rejected, not deferred** - a nudge
  /// held until morning is an impulse from last night arriving as though it
  /// were fresh.
  final DateTime? quietUntil;

  bool get isQuietHours => quietUntil != null;

  static NudgeRejected? tryParse(DioException error) {
    if (error.response?.statusCode != 409) return null;
    final data = error.response?.data;
    if (data is! Map) return null;
    return NudgeRejected(
      message: data['error'] as String? ?? 'That nudge was turned down',
      nextNudgeAt: _time(data['nextNudgeAt']),
      quietUntil: _time(data['quietUntil']),
    );
  }

  static DateTime? _time(Object? raw) =>
      raw is String ? DateTime.tryParse(raw)?.toUtc() : null;

  @override
  String toString() => 'NudgeRejected($message)';
}
