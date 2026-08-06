import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import 'models/chore_dto.dart';
import 'models/decision_dto.dart';
import 'models/house_dto.dart';
import 'models/ledger_dto.dart';
import 'models/list_item_dto.dart';
import 'models/pantry_dto.dart';

/// The eight household modules, over the same public gateway prefix every
/// other guild endpoint uses.
///
/// The doubled-looking `/api/v1/guild/guilds/...` and `/api/v1/guild/channels/
/// ...` segments are correct: the gateway strips the `guild` segment before
/// forwarding, so `guild` is the service and `guilds`/`channels` is the
/// resource. Same base as [GuildApi], deliberately - these are guild
/// endpoints, they just happen to be about a fridge.
///
/// Every endpoint here is gated on a `GuildFeatures` module, and a guild
/// without the module answers `403` **for everyone, the owner included**.
/// Callers must check `features` before rendering, not after failing: "your
/// house doesn't do money" and "you're not allowed to see the money" are very
/// different things to show somebody.
class HouseholdApi {
  HouseholdApi({required this.client});

  final ApiClient client;

  String get _base => client.url('/api/v1/guild');

  static String? _iso(DateTime? value) => value?.toUtc().toIso8601String();

  // ---------------------------------------------------------------- lists

  Future<List<ListItemDto>> getListItems(
    String channelId, {
    bool includeChecked = true,
  }) async {
    final response = await client.dio.get<List<dynamic>>(
      '$_base/channels/$channelId/list-items',
      queryParameters: {'includeChecked': includeChecked},
    );
    return response.data!
        .map((json) => ListItemDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<ListItemDto> createListItem(
    String channelId, {
    required String text,
    String? quantity,
    String? note,
    String? section,
    String? assigneeUserId,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '$_base/channels/$channelId/list-items',
      data: {
        'text': text,
        if (quantity != null) 'quantity': quantity,
        if (note != null) 'note': note,
        if (section != null) 'section': section,
        if (assigneeUserId != null) 'assigneeUserId': assigneeUserId,
      },
    );
    return ListItemDto.fromJson(response.data!);
  }

  /// Null-vs-absent matters on every optional field here, so clearing one is
  /// an explicit `clear*` flag rather than "pass null" - which is
  /// indistinguishable from "don't touch it" in an optional parameter.
  Future<ListItemDto> updateListItem(
    String itemId, {
    String? text,
    String? quantity,
    bool clearQuantity = false,
    String? note,
    bool clearNote = false,
    String? section,
    bool clearSection = false,
    String? assigneeUserId,
    bool clearAssignee = false,
  }) async {
    final response = await client.dio.patch<Map<String, dynamic>>(
      '$_base/list-items/$itemId',
      data: {
        if (text != null) 'text': text,
        if (clearQuantity)
          'quantity': null
        else if (quantity != null)
          'quantity': quantity,
        if (clearNote) 'note': null else if (note != null) 'note': note,
        if (clearSection)
          'section': null
        else if (section != null)
          'section': section,
        if (clearAssignee)
          'assigneeUserId': null
        else if (assigneeUserId != null)
          'assigneeUserId': assigneeUserId,
      },
    );
    return ListItemDto.fromJson(response.data!);
  }

  /// Idempotent server-side: ticking an already-ticked item is a `200` with
  /// the item unchanged and no event. A repeat is not an error.
  Future<ListItemDto?> setListItemChecked(String itemId, bool checked) async {
    final response = checked
        ? await client.dio.post<dynamic>('$_base/list-items/$itemId/check')
        : await client.dio.delete<dynamic>('$_base/list-items/$itemId/check');
    final data = response.data;
    return data is Map<String, dynamic> ? ListItemDto.fromJson(data) : null;
  }

  Future<void> deleteListItem(String itemId) async {
    await client.dio.delete<void>('$_base/list-items/$itemId');
  }

  /// Partial is fine: ids left out keep their relative order *after* the ones
  /// sent, so a drag only has to describe the neighbourhood it moved.
  Future<void> reorderListItems(String channelId, List<String> itemIds) async {
    await client.dio.post<void>(
      '$_base/channels/$channelId/list-items/reorder',
      data: {'itemIds': itemIds},
    );
  }

  /// "Clear done" - deletes every checked line. Also re-arms the pantry
  /// restock loop for anything that got here automatically.
  Future<void> clearCheckedListItems(String channelId) async {
    await client.dio.delete<void>(
      '$_base/channels/$channelId/list-items/checked',
    );
  }

  // --------------------------------------------------------------- chores

  Future<List<ChoreDto>> getChores(String channelId) async {
    final response = await client.dio.get<List<dynamic>>(
      '$_base/channels/$channelId/chores',
    );
    return response.data!
        .map((json) => ChoreDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// A chore needs **either** [rotationRoleId] or [fixedAssigneeUserId]; the
  /// server answers `400` for neither or both.
  Future<ChoreDto> createChore(
    String channelId, {
    required String title,
    String? description,
    required int intervalDays,
    required DateTime anchorAt,
    required int effortMinutes,
    String? rotationRoleId,
    String? fixedAssigneeUserId,
    int graceHours = 0,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '$_base/channels/$channelId/chores',
      data: {
        'title': title,
        if (description != null) 'description': description,
        'intervalDays': intervalDays,
        'anchorAt': _iso(anchorAt),
        'effortMinutes': effortMinutes,
        if (rotationRoleId != null) 'rotationRoleId': rotationRoleId,
        if (fixedAssigneeUserId != null)
          'fixedAssigneeUserId': fixedAssigneeUserId,
        'graceHours': graceHours,
      },
    );
    return ChoreDto.fromJson(response.data!);
  }

  Future<ChoreDto> updateChore(
    String choreId, {
    String? title,
    String? description,
    bool clearDescription = false,
    int? intervalDays,
    DateTime? anchorAt,
    int? effortMinutes,
    String? rotationRoleId,
    String? fixedAssigneeUserId,
    int? graceHours,
    bool? isPaused,
  }) async {
    final response = await client.dio.patch<Map<String, dynamic>>(
      '$_base/chores/$choreId',
      data: {
        if (title != null) 'title': title,
        if (clearDescription)
          'description': null
        else if (description != null)
          'description': description,
        if (intervalDays != null) 'intervalDays': intervalDays,
        if (anchorAt != null) 'anchorAt': _iso(anchorAt),
        if (effortMinutes != null) 'effortMinutes': effortMinutes,
        // Assignment is one-or-the-other, so switching to a rotation has to
        // null the fixed assignee in the same request (and vice versa).
        if (rotationRoleId != null) ...{
          'rotationRoleId': rotationRoleId,
          'fixedAssigneeUserId': null,
        },
        if (fixedAssigneeUserId != null) ...{
          'fixedAssigneeUserId': fixedAssigneeUserId,
          'rotationRoleId': null,
        },
        if (graceHours != null) 'graceHours': graceHours,
        if (isPaused != null) 'isPaused': isPaused,
      },
    );
    return ChoreDto.fromJson(response.data!);
  }

  Future<void> deleteChore(String choreId) async {
    await client.dio.delete<void>('$_base/chores/$choreId');
  }

  Future<List<ChoreOccurrenceDto>> getChoreOccurrences(
    String channelId, {
    required DateTime from,
    required DateTime to,
  }) async {
    final response = await client.dio.get<List<dynamic>>(
      '$_base/channels/$channelId/chores/occurrences',
      queryParameters: {'from': _iso(from), 'to': _iso(to)},
    );
    return response.data!
        .map(
          (json) => ChoreOccurrenceDto.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  Future<ChoreOccurrenceDto?> setOccurrenceCompleted(
    String occurrenceId,
    bool completed,
  ) async {
    final response = completed
        ? await client.dio.post<dynamic>(
            '$_base/chore-occurrences/$occurrenceId/complete',
          )
        : await client.dio.delete<dynamic>(
            '$_base/chore-occurrences/$occurrenceId/complete',
          );
    final data = response.data;
    return data is Map<String, dynamic>
        ? ChoreOccurrenceDto.fromJson(data)
        : null;
  }

  Future<ChoreOccurrenceDto?> skipOccurrence(String occurrenceId) async {
    final response = await client.dio.post<dynamic>(
      '$_base/chore-occurrences/$occurrenceId/skip',
    );
    final data = response.data;
    return data is Map<String, dynamic>
        ? ChoreOccurrenceDto.fromJson(data)
        : null;
  }

  /// Reassigns to the lightest-loaded *other* member of the rotation - the
  /// one-tap answer to "I can't do the bins tonight". `400` when nobody else
  /// is in the pool.
  Future<ChoreOccurrenceDto?> swapOccurrence(String occurrenceId) async {
    final response = await client.dio.post<dynamic>(
      '$_base/chore-occurrences/$occurrenceId/swap',
    );
    final data = response.data;
    return data is Map<String, dynamic>
        ? ChoreOccurrenceDto.fromJson(data)
        : null;
  }

  Future<List<ChoreBalanceEntryDto>> getChoreBalance(
    String channelId, {
    int days = 30,
  }) async {
    final response = await client.dio.get<List<dynamic>>(
      '$_base/channels/$channelId/chores/balance',
      queryParameters: {'days': days},
    );
    return response.data!
        .map(
          (json) => ChoreBalanceEntryDto.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  // --------------------------------------------------------------- pantry

  Future<List<PantryItemDto>> getPantryItems(String channelId) async {
    final response = await client.dio.get<List<dynamic>>(
      '$_base/channels/$channelId/pantry-items',
    );
    return response.data!
        .map((json) => PantryItemDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<PantryItemDto> createPantryItem(
    String channelId, {
    required String name,
    required double quantity,
    String? unit,
    double? lowThreshold,
    DateTime? expiresAt,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '$_base/channels/$channelId/pantry-items',
      data: {
        'name': name,
        'quantity': quantity,
        if (unit != null) 'unit': unit,
        if (lowThreshold != null) 'lowThreshold': lowThreshold,
        if (expiresAt != null) 'expiresAt': _iso(expiresAt),
      },
    );
    return PantryItemDto.fromJson(response.data!);
  }

  Future<PantryItemDto> updatePantryItem(
    String itemId, {
    String? name,
    double? quantity,
    String? unit,
    bool clearUnit = false,
    double? lowThreshold,
    bool clearLowThreshold = false,
    DateTime? expiresAt,
    bool clearExpiresAt = false,
  }) async {
    final response = await client.dio.patch<Map<String, dynamic>>(
      '$_base/pantry-items/$itemId',
      data: {
        if (name != null) 'name': name,
        if (quantity != null) 'quantity': quantity,
        if (clearUnit) 'unit': null else if (unit != null) 'unit': unit,
        if (clearLowThreshold)
          'lowThreshold': null
        else if (lowThreshold != null)
          'lowThreshold': lowThreshold,
        if (clearExpiresAt)
          'expiresAt': null
        else if (expiresAt != null)
          'expiresAt': _iso(expiresAt),
      },
    );
    return PantryItemDto.fromJson(response.data!);
  }

  Future<void> deletePantryItem(String itemId) async {
    await client.dio.delete<void>('$_base/pantry-items/$itemId');
  }

  /// Spans **every** pantry in the guild the caller can see - "what needs
  /// eating" is a question about the house, not about one fridge. Results are
  /// filtered per channel by `ViewChannel`, so this can't be used to
  /// enumerate a pantry you're not in.
  ///
  /// [days] is an override for *every* pantry at once, and omitting it is the
  /// right default: each pantry then uses its own `expiryWarningDays`, so a
  /// freezer set to a fortnight and a fridge set to two days both behave
  /// correctly in one response. Passing a number flattens that distinction,
  /// which is only what you want for a deliberate "what goes off this month".
  Future<List<PantryItemDto>> getExpiringPantryItems(
    String guildId, {
    int? days,
  }) async {
    final response = await client.dio.get<List<dynamic>>(
      '$_base/guilds/$guildId/pantry/expiring',
      queryParameters: {if (days != null) 'days': days},
    );
    return response.data!
        .map((json) => PantryItemDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<PantryConfigDto> getPantryConfig(String channelId) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '$_base/channels/$channelId/pantry/config',
    );
    return PantryConfigDto.fromJson(response.data!);
  }

  Future<PantryConfigDto> updatePantryConfig(
    String channelId, {
    required String? restockListChannelId,
    required int expiryWarningDays,
  }) async {
    final response = await client.dio.put<Map<String, dynamic>>(
      '$_base/channels/$channelId/pantry/config',
      data: {
        'restockListChannelId': restockListChannelId,
        'expiryWarningDays': expiryWarningDays,
      },
    );
    return PantryConfigDto.fromJson(response.data!);
  }

  // --------------------------------------------------------------- ledger

  /// One page of a ledger, newest first.
  ///
  /// Keyset-paged: pass the previous page's [ExpensePageDto.nextCursor] back as
  /// [cursor], and a null cursor in the response means the end. [limit]
  /// defaults to 50 server-side and caps at 200; a malformed cursor is a `400`
  /// rather than a silent first page.
  ///
  /// The bare-array shape is still accepted here because it costs one `is`
  /// check: this endpoint used to answer with a flat `Take(200)` array, and a
  /// gateway that hasn't been redeployed yet should degrade to "one page, no
  /// more" rather than to an unreadable ledger.
  Future<ExpensePageDto> getExpenses(
    String channelId, {
    int? limit,
    String? cursor,
  }) async {
    final response = await client.dio.get<dynamic>(
      '$_base/channels/$channelId/expenses',
      queryParameters: {
        if (limit != null) 'limit': limit,
        if (cursor != null) 'cursor': cursor,
      },
    );
    final data = response.data;
    if (data is List) {
      return ExpensePageDto(
        items: data
            .map((json) => ExpenseDto.fromJson(json as Map<String, dynamic>))
            .toList(),
      );
    }
    return ExpensePageDto.fromJson(data as Map<String, dynamic>);
  }

  /// [amountMinor] is a whole number of cents/rappen. There is no code path
  /// in this app that sends `12.34`.
  ///
  /// An empty [shares] with [SplitKind.equal] means everyone in the guild,
  /// which is the common case (rent, internet). Remainders are distributed
  /// server-side and deterministically - never compute them here.
  Future<ExpenseDto> createExpense(
    String channelId, {
    required String description,
    required int amountMinor,
    required String payerUserId,
    required DateTime occurredAt,
    SplitKind splitKind = SplitKind.equal,
    List<({String userId, int shareValue})> shares = const [],
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '$_base/channels/$channelId/expenses',
      data: {
        'description': description,
        'amountMinor': amountMinor,
        'payerUserId': payerUserId,
        'occurredAt': _iso(occurredAt),
        'splitKind': splitKind.wireValue,
        'shares': [
          for (final share in shares)
            {'userId': share.userId, 'shareValue': share.shareValue},
        ],
      },
    );
    return ExpenseDto.fromJson(response.data!);
  }

  Future<ExpenseDto> updateExpense(
    String expenseId, {
    String? description,
    int? amountMinor,
    String? payerUserId,
    DateTime? occurredAt,
    SplitKind? splitKind,
    List<({String userId, int shareValue})>? shares,
  }) async {
    final response = await client.dio.patch<Map<String, dynamic>>(
      '$_base/expenses/$expenseId',
      data: {
        if (description != null) 'description': description,
        if (amountMinor != null) 'amountMinor': amountMinor,
        if (payerUserId != null) 'payerUserId': payerUserId,
        if (occurredAt != null) 'occurredAt': _iso(occurredAt),
        if (splitKind != null) 'splitKind': splitKind.wireValue,
        if (shares != null)
          'shares': [
            for (final share in shares)
              {'userId': share.userId, 'shareValue': share.shareValue},
          ],
      },
    );
    return ExpenseDto.fromJson(response.data!);
  }

  Future<void> deleteExpense(String expenseId) async {
    await client.dio.delete<void>('$_base/expenses/$expenseId');
  }

  /// Members at zero are omitted, so an empty list means the house is settled.
  Future<List<LedgerBalanceDto>> getLedgerBalances(String channelId) async {
    final response = await client.dio.get<List<dynamic>>(
      '$_base/channels/$channelId/ledger/balances',
    );
    return response.data!
        .map((json) => LedgerBalanceDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<TransferSuggestionDto>> getSettleSuggestion(
    String channelId,
  ) async {
    final response = await client.dio.get<List<dynamic>>(
      '$_base/channels/$channelId/ledger/settle-suggestion',
    );
    return response.data!
        .map(
          (json) =>
              TransferSuggestionDto.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  /// Records that somebody paid somebody - it doesn't move any money.
  Future<void> recordSettlement(
    String channelId, {
    required String fromUserId,
    required String toUserId,
    required int amountMinor,
  }) async {
    await client.dio.post<void>(
      '$_base/channels/$channelId/ledger/settlements',
      data: {
        'fromUserId': fromUserId,
        'toUserId': toUserId,
        'amountMinor': amountMinor,
      },
    );
  }

  Future<LedgerConfigDto> getLedgerConfig(String channelId) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '$_base/channels/$channelId/ledger/config',
    );
    return LedgerConfigDto.fromJson(response.data!);
  }

  /// Changing the currency **relabels** existing amounts - it doesn't convert
  /// them. Confirm before calling.
  Future<LedgerConfigDto> updateLedgerConfig(
    String channelId, {
    required String currency,
  }) async {
    final response = await client.dio.put<Map<String, dynamic>>(
      '$_base/channels/$channelId/ledger/config',
      data: {'currency': currency},
    );
    return LedgerConfigDto.fromJson(response.data!);
  }

  // ------------------------------------------------------------ decisions

  Future<List<DecisionDto>> getDecisions(String channelId) async {
    final response = await client.dio.get<List<dynamic>>(
      '$_base/channels/$channelId/decisions',
    );
    return response.data!
        .map((json) => DecisionDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<DecisionDto> createDecision(
    String channelId, {
    required String title,
    String? description,
    required List<String> options,
    int? quorum,
    DateTime? closesAt,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '$_base/channels/$channelId/decisions',
      data: {
        'title': title,
        if (description != null) 'description': description,
        // Bare strings, not `{title, position}` objects: the server binds this
        // to a `List<String>` and assigns each option's position from the
        // order it arrives in. Sending objects fails the whole request with a
        // 400 "Invalid JSON format ... could not be converted to
        // System.String. Path: $.options[0]".
        'options': options,
        if (quorum != null) 'quorum': quorum,
        if (closesAt != null) 'closesAt': _iso(closesAt),
      },
    );
    return DecisionDto.fromJson(response.data!);
  }

  /// One vote per member - `PUT` is the upsert, re-voting replaces.
  ///
  /// [VoteKind.block] requires [reason] (`400` otherwise: a veto nobody can
  /// see the reasoning for is how a house ends up in a silent standoff), and
  /// a block with a null [optionId] objects to the whole decision rather than
  /// one option. [VoteKind.support] requires an [optionId].
  Future<DecisionDto?> vote(
    String decisionId, {
    required VoteKind kind,
    String? optionId,
    String? reason,
  }) async {
    final response = await client.dio.put<dynamic>(
      '$_base/decisions/$decisionId/vote',
      data: {
        'kind': kind.wireValue,
        if (optionId != null) 'optionId': optionId,
        if (reason != null) 'reason': reason,
      },
    );
    final data = response.data;
    return data is Map<String, dynamic> ? DecisionDto.fromJson(data) : null;
  }

  Future<DecisionDto?> closeDecision(String decisionId) async {
    final response = await client.dio.post<dynamic>(
      '$_base/decisions/$decisionId/close',
    );
    final data = response.data;
    return data is Map<String, dynamic> ? DecisionDto.fromJson(data) : null;
  }

  /// Soft-cancel - the decision stays readable, it just stops being live.
  Future<void> cancelDecision(String decisionId) async {
    await client.dio.delete<void>('$_base/decisions/$decisionId');
  }

  // ---------------------------------------------------------- home status

  /// Never returns expired entries; a member with no live status is simply
  /// absent.
  Future<List<HomeStatusDto>> getHomeStatuses(String guildId) async {
    final response = await client.dio.get<List<dynamic>>(
      '$_base/guilds/$guildId/home-status',
    );
    return response.data!
        .map((json) => HomeStatusDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Sets **your own** status - there is no way to set anyone else's.
  /// [expiresInMinutes] defaults server-side to 12 hours, capped at 7 days.
  Future<HomeStatusDto?> setHomeStatus(
    String guildId, {
    required HomeStatusKind kind,
    String? note,
    int? expiresInMinutes,
  }) async {
    final response = await client.dio.put<dynamic>(
      '$_base/guilds/$guildId/home-status',
      data: {
        'kind': kind.wireValue,
        if (note != null) 'note': note,
        if (expiresInMinutes != null) 'expiresInMinutes': expiresInMinutes,
      },
    );
    final data = response.data;
    return data is Map<String, dynamic> ? HomeStatusDto.fromJson(data) : null;
  }

  Future<void> clearHomeStatus(String guildId) async {
    await client.dio.delete<void>('$_base/guilds/$guildId/home-status');
  }

  // ---------------------------------------------------------- quiet hours

  Future<QuietHoursDto> getQuietHours(String guildId) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '$_base/guilds/$guildId/quiet-hours',
    );
    return QuietHoursDto.fromJson(response.data!);
  }

  /// `400` on an out-of-range minute, `start == end`, or an unknown IANA id.
  /// `start > end` is not an error - that's the window wrapping midnight.
  Future<QuietHoursDto> updateQuietHours(
    String guildId, {
    required bool enabled,
    required int startMinuteLocal,
    required int endMinuteLocal,
    required String timeZoneId,
  }) async {
    final response = await client.dio.put<Map<String, dynamic>>(
      '$_base/guilds/$guildId/quiet-hours',
      data: {
        'enabled': enabled,
        'startMinuteLocal': startMinuteLocal,
        'endMinuteLocal': endMinuteLocal,
        'timeZoneId': timeZoneId,
      },
    );
    return QuietHoursDto.fromJson(response.data!);
  }

  // --------------------------------------------------------- guest access

  /// A time-boxed role grant. It lapses on its own - permission resolution
  /// ignores an expired membership from the instant it expires, so the pet
  /// sitter's five days end without anybody remembering to revoke them.
  ///
  /// Needs `ManageGuests` *and* the normal role hierarchy rule: you can only
  /// hand out roles you could assign by hand. Max one year.
  Future<void> grantTemporaryRole(
    String guildId, {
    required String userId,
    required String roleId,
    required DateTime expiresAt,
  }) async {
    await client.dio.post<void>(
      '$_base/guilds/$guildId/members/$userId/roles/$roleId/temporary',
      data: {'expiresAt': _iso(expiresAt)},
    );
  }

  Future<void> revokeTemporaryRole(
    String guildId, {
    required String userId,
    required String roleId,
  }) async {
    await client.dio.delete<void>(
      '$_base/guilds/$guildId/members/$userId/roles/$roleId/temporary',
    );
  }

  // ------------------------------------------------------------- moving out

  /// Removes somebody who has moved out, and cleans up what they were
  /// carrying: their unfinished chores, their name on list items, their
  /// balance.
  ///
  /// This is the *only* way a household removes a member. The `Household`
  /// preset leaves the Moderation module off, which strips `KickMembers` for
  /// everybody including the owner - four people sharing a flat don't ban each
  /// other. Needs `ManageGuild` plus the usual role-hierarchy rule, and the
  /// owner can't be moved out at all (transfer ownership first).
  ///
  /// Throws [MoveOutBlocked] while they still owe money, unless
  /// [writeOffBalances] is set. That refusal is the feature, not an obstacle:
  /// it's the one moment the house is made to look at what the person leaving
  /// owes. Writing it off records the settlements that zero them - it does not
  /// pretend money moved, it's the house agreeing to stop counting the debt,
  /// and the audit log says so.
  Future<MoveOutSummaryDto> moveOut(
    String guildId, {
    required String userId,
    bool writeOffBalances = false,
  }) async {
    try {
      final response = await client.dio.post<dynamic>(
        '$_base/guilds/$guildId/members/$userId/move-out',
        data: {'writeOffBalances': writeOffBalances},
      );
      final data = response.data;
      return data is Map<String, dynamic>
          ? MoveOutSummaryDto.fromJson(data)
          : MoveOutSummaryDto(userId: userId);
    } on DioException catch (error) {
      final blocked = MoveOutBlocked.tryParse(error);
      if (blocked != null) throw blocked;
      rethrow;
    }
  }
}

/// The `409` a move-out answers with while the member is still in the red.
///
/// Carries the balances rather than just a message because the useful screen
/// is "Ben owes 240 CHF - settle up first, or write it off", and that needs the
/// numbers.
class MoveOutBlocked implements Exception {
  const MoveOutBlocked({required this.message, required this.outstanding});

  final String message;
  final List<OutstandingBalanceDto> outstanding;

  static MoveOutBlocked? tryParse(DioException error) {
    if (error.response?.statusCode != 409) return null;
    final data = error.response?.data;
    if (data is! Map) return null;
    final outstanding = data['outstanding'];
    return MoveOutBlocked(
      message: data['error'] as String? ?? 'This member is not settled up',
      outstanding: [
        if (outstanding is List)
          for (final entry in outstanding)
            if (entry is Map<String, dynamic>)
              OutstandingBalanceDto.fromJson(entry),
      ],
    );
  }

  @override
  String toString() => 'MoveOutBlocked($message)';
}
