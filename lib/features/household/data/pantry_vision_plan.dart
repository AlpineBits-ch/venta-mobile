/// Turning "the model says it can see three cartons" into "this is exactly what
/// will be written into a shared cupboard", and then writing it.
///
/// Everything above this file is a guess and everything below it is somebody
/// else's stock. That is the whole reason this is one small pure function plus
/// one small batch of calls, with no widgets, no `getIt`, and no I/O in the
/// resolving half: it is the part of the feature that can silently double a
/// flatmate's shopping or zero it, and the only way to be confident about that
/// is to be able to test it exhaustively without a camera, a key, or a network.
///
/// Three rules from `docs/pantry-vision.md` are load-bearing here and are the
/// reason the code is shaped the way it is:
///
/// **A photo is a stocktake, not a delivery note.** An item already in the
/// pantry is `set` to what the photo shows, never added to. Photographing the
/// same shelf twice must leave three cartons as three cartons. The review sheet
/// can flip one row to [PantryVisionAction.add] where somebody genuinely means
/// "and these on top", but that is a deliberate per-row act, never the default.
///
/// **Absence is never evidence.** A photo is one shelf, not an inventory. Only
/// things the model named appear in the plan at all; a pantry row the photo did
/// not mention is not in the plan, is not zeroed, and is not touched. This falls
/// out of only ever iterating proposals - never the pantry - and there is a test
/// that holds it there.
///
/// **You cannot use up what the house does not have.** In the use-up direction
/// an unrecognised product is [PantryVisionAction.unmatched]: it stays on the
/// review list so somebody can see the photo was read, and it writes nothing.
/// Creating a row in order to decrement it would invent stock out of a bin bag.
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:dio/dio.dart';

import '../../../core/ai/pantry_vision_models.dart';
import 'household_api.dart';
import 'household_api_wave2.dart';
import 'models/pantry_dto.dart';

/// Which way round the photo is being read.
///
/// Deliberately not `PantryScanMode`, which lives in the scanner screen. This
/// file is the one piece of the feature with no dependency on Flutter at all,
/// and a data-layer file reaching up into `presentation/` to borrow an enum is
/// how that stops being true. The caller maps one to the other in a line.
enum PantryVisionDirection {
  /// Unpacking a bag. The photo says what is on the shelf now.
  stockUp,

  /// Photographing what is going in the bin. The photo says what is leaving.
  useUp;

  bool get isStockUp => this == PantryVisionDirection.stockUp;
}

/// What confirming a row will actually do.
///
/// [unmatched] is not a write and is not an error - it is the honest fourth
/// answer, and it has a value of its own rather than being inferred from a null
/// [PantryVisionRow.existing] so that the review sheet cannot accidentally
/// render it as a write. Every "will this touch the pantry" question in this
/// file goes through [PantryVisionRow.willWrite], and that is the only place the
/// distinction is made.
enum PantryVisionAction {
  /// Nothing like it in this pantry, and stock is going in. A new row.
  create,

  /// Land on an absolute quantity. The default for anything already in the
  /// pantry, in both directions - see the stocktake rule in the library doc.
  set,

  /// Add to what is already there. Only ever reached because somebody chose it
  /// on the review row, never by default.
  add,

  /// The photo named something this pantry does not hold, while using up.
  /// Shown as "not in this pantry"; writes nothing.
  unmatched,
}

/// The whole wait for one row's write, matching the barcode scanner's
/// `_scanDeadline`.
///
/// Same reasoning as there: the client already bounds a single request, and
/// this bounds a request plus whatever `429` backoff and catalog lookup ends up
/// stacked on it. It is per row rather than for the batch on purpose - twelve
/// rows behind one shared budget means the last three get whatever is left,
/// which is a partial apply nobody asked for.
const Duration pantryVisionWriteDeadline = Duration(seconds: 18);

/// One reviewable line: what the model said, what it was resolved to, and
/// exactly what will be written if somebody confirms it.
///
/// [targetQuantity] is stored rather than computed on read because it is the
/// number shown on screen and the number sent to the server, and those two must
/// be the same number. But it is only ever produced by [PantryVisionRow.resolve]
/// and [copyWith], never passed in from outside: an edit to the count or a flip
/// from `set` to `add` recomputes it, because a stale target next to an edited
/// count is precisely the bug that doubles somebody's stock.
class PantryVisionRow {
  const PantryVisionRow({
    required this.proposal,
    required this.existing,
    required this.barcode,
    required this.direction,
    required this.action,
    required this.targetQuantity,
    this.included = true,
  });

  /// Resolves one proposal against what the pantry already holds.
  ///
  /// [existing] and [barcode] are supplied by [buildPantryVisionPlan], which
  /// owns the ladder; this only decides the action and the resulting number, so
  /// that [copyWith] can re-run exactly the same decision after an edit.
  factory PantryVisionRow.resolve({
    required PantryVisionItem proposal,
    required PantryVisionDirection direction,
    PantryItemDto? existing,
    String? barcode,
    PantryVisionAction? action,
    bool included = true,
  }) {
    final resolved = _legalAction(
      requested: action,
      existing: existing,
      direction: direction,
    );
    return PantryVisionRow(
      proposal: proposal,
      existing: existing,
      barcode: barcode,
      direction: direction,
      action: resolved,
      targetQuantity: _target(
        action: resolved,
        existing: existing,
        count: proposal.count,
        direction: direction,
      ),
      included: included,
    );
  }

  /// What the model said, in its own words. Kept whole so the review row can
  /// show the brand, the confidence and the "partly hidden" note next to the
  /// name the house is actually going to end up with.
  final PantryVisionItem proposal;

  /// The pantry row this will be written onto, if there is one.
  final PantryItemDto? existing;

  /// The code this house has already learned for this product, if the name
  /// matched one. Never anything the model said - it is never asked for a
  /// barcode and has nowhere to put one.
  final String? barcode;

  final PantryVisionDirection direction;

  final PantryVisionAction action;

  /// The quantity the item will hold afterwards. An absolute level, not a
  /// delta, because that is the thing a person can check against the shelf in
  /// front of them.
  final double targetQuantity;

  /// Cleared by dropping the row in review. A dropped row stays in the plan so
  /// the count of what was seen does not quietly change; it is simply never
  /// written.
  final bool included;

  /// The photo named something this pantry does not hold, on the way out.
  bool get isUnmatched => action == PantryVisionAction.unmatched;

  /// The single question the apply step asks. Nothing else in this file is
  /// allowed to decide that a row is a write.
  bool get willWrite => included && !isUnmatched;

  /// What the item holds now. Zero for something that is not there yet, which
  /// is also what makes the review line "0 -> 2" read correctly for a create.
  double get currentQuantity => existing?.quantity ?? 0;

  /// Signed change in stock. Positive on the way in, negative on the way out.
  double get delta => targetQuantity - currentQuantity;

  /// Whether confirming this row would leave **less** stock than the pantry
  /// currently records, while stocking up.
  ///
  /// Worth surfacing rather than hiding, because it is the honest cost of the
  /// stocktake rule combined with a prompt that counts the front row only: six
  /// tins with three at the back photographs as three, and `set` will write
  /// three. That is correct for somebody who just photographed a full shelf and
  /// wrong for somebody who photographed the front of a deep one, and only they
  /// can tell which. The review row flags it; `add` is one tap away.
  bool get reducesStock => direction.isStockUp && willWrite && delta < 0;

  /// Whether the item will be sitting below its restock threshold afterwards,
  /// or null when there is no threshold to be below.
  ///
  /// Predicted locally, with the same `<=` the pantry screens already use, so
  /// review can say "this puts it on the shopping list" before the write rather
  /// than after it. Advisory: the server decides for real.
  bool? get predictedIsLow {
    final threshold = existing?.lowThreshold;
    if (threshold == null || isUnmatched) return null;
    return targetQuantity <= threshold;
  }

  /// Whether this row can be written with [HouseholdApiWave2.scanPantryItem]
  /// rather than a plain update, which is worth doing because a scan brings the
  /// house's own name, unit and learned defaults with it for free.
  ///
  /// Two conditions beyond having a code, and both exist to stop a scan landing
  /// somewhere other than where this row says it will:
  ///
  /// A scan **adds**; it has no way to subtract. So it is only ever a candidate
  /// on the way in.
  ///
  /// A scan finds its row *by barcode, server-side*. When this row matched an
  /// existing item by name and that item carries no barcode - a row a previous
  /// photo created, say - the server would not find it and would create a second
  /// row for the same product in a shared pantry. So the code is only trusted as
  /// a write target when the server is certain to land on the same item this row
  /// is about: either there is no item yet, or the item already carries this
  /// exact code.
  bool get canScanIn {
    final code = barcode;
    if (code == null || code.isEmpty || !direction.isStockUp) return false;
    final item = existing;
    return item == null || item.barcode == code;
  }

  /// The name that will be written for a new row. The model's, corrected by
  /// whoever is reviewing.
  String get name => proposal.name;

  /// Re-resolves the row after an edit.
  ///
  /// Every field here changes the answer, so nothing is copied straight across:
  /// a new count, a flip to `add`, or a corrected name all run back through
  /// [PantryVisionRow.resolve]. [action] is a request rather than an
  /// instruction - see [_legalAction]; a plan cannot be edited into creating
  /// stock that is on its way to the bin.
  PantryVisionRow copyWith({
    int? count,
    bool? included,
    PantryVisionAction? action,
    String? name,
  }) => PantryVisionRow.resolve(
    proposal: (count == null && name == null)
        ? proposal
        : proposal.copyWith(count: count, name: name),
    existing: existing,
    barcode: barcode,
    direction: direction,
    action: action ?? this.action,
    included: included ?? this.included,
  );

  /// The action the row is actually allowed to have, whatever was asked for.
  ///
  /// Three of the four combinations are structural rather than preference, and
  /// enforcing them here means neither the initial resolve nor a review-sheet
  /// edit can produce a row whose action does not match its data:
  ///
  /// - nothing matched, stocking up - only `create` makes sense;
  /// - nothing matched, using up - only `unmatched`, because inventing a row in
  ///   order to take stock off it is how a bin bag becomes stock;
  /// - something matched - `set` or `add`, never `create`, because that is the
  ///   duplicate row this whole ladder exists to avoid.
  static PantryVisionAction _legalAction({
    required PantryVisionAction? requested,
    required PantryItemDto? existing,
    required PantryVisionDirection direction,
  }) {
    if (existing == null) {
      return direction.isStockUp
          ? PantryVisionAction.create
          : PantryVisionAction.unmatched;
    }
    return requested == PantryVisionAction.add
        ? PantryVisionAction.add
        : PantryVisionAction.set;
  }

  /// The resulting stock level, which is the only number anybody checks.
  ///
  /// `set` reads differently in the two directions and that is deliberate: on
  /// the way in the photo *is* the level, and on the way out the photo is what
  /// left, so the level is what is left over. The clamp at zero is not defensive
  /// tidying - a model that reads four packets where the pantry recorded three
  /// would otherwise write minus one into a shared cupboard.
  static double _target({
    required PantryVisionAction action,
    required PantryItemDto? existing,
    required int count,
    required PantryVisionDirection direction,
  }) {
    final current = existing?.quantity ?? 0;
    return switch (action) {
      PantryVisionAction.create => count.toDouble(),
      PantryVisionAction.add => current + count,
      PantryVisionAction.set => direction.isStockUp
          ? count.toDouble()
          : math.max(0.0, current - count),
      // Nothing is written, so nothing changes. Carried anyway so the review
      // row has a number to render rather than a blank.
      PantryVisionAction.unmatched => current,
    };
  }
}

/// Everything one set of photos proposes doing to one pantry.
class PantryVisionPlan {
  const PantryVisionPlan({required this.rows, this.unreadable = 0});

  static const PantryVisionPlan empty = PantryVisionPlan(rows: []);

  /// In the order the model listed them, after folding duplicates - see
  /// [buildPantryVisionPlan].
  final List<PantryVisionRow> rows;

  /// How many things the model could see but could not name, carried through
  /// from the vision result untouched.
  ///
  /// It survives into the plan because it is the only signal that the plan is
  /// incomplete, and a review sheet that shows six confident rows and hides
  /// "and four I could not read" is a review sheet somebody stops checking.
  final int unreadable;

  bool get isEmpty => rows.isEmpty;

  /// The rows [applyPantryVisionPlan] will actually call for.
  Iterable<PantryVisionRow> get writableRows => rows.where((r) => r.willWrite);

  int get writeCount => writableRows.length;

  /// How many rows the photo named but this pantry does not hold. Shown as its
  /// own line in review, because it is a different sentence from "nothing was
  /// found".
  int get unmatchedCount => rows.where((r) => r.isUnmatched).length;

  /// Swaps one row for an edited copy of itself. The review sheet's only
  /// mutation, kept here so the list stays immutable everywhere else.
  PantryVisionPlan replaceRow(int index, PantryVisionRow row) =>
      PantryVisionPlan(
        rows: [...rows]..[index] = row,
        unreadable: unreadable,
      );
}

/// Resolves everything a set of photos proposed against what the pantry holds,
/// and works out what would be written.
///
/// **Pure.** [pantry] and [learnedBarcodes] are fetched by the caller and passed
/// in; nothing here touches a network, a singleton, or a clock. That is what
/// makes the reconciliation rules testable at all, and they are the rules that
/// decide what happens to somebody else's food.
///
/// The ladder, best rung first, exactly as `docs/pantry-vision.md` §1 sets it
/// out:
///
/// 1. a barcode this house has already taught itself, matched on the name it
///    taught. If that code is also on a row in this pantry, that row is the
///    match too;
/// 2. failing that, a row in this pantry with the same name;
/// 3. failing that, nothing.
///
/// Rung 1 falling through to rung 2 is worth stating because it is not obvious:
/// finding a learned code does **not** end the search. The house can know a code
/// for "oat milk" while the oat milk on the shelf is a row an earlier photo
/// created with no code on it, and treating that as "not in the pantry" would
/// put a second oat milk in a shared cupboard. The code is still recorded - it
/// is what lets the write pick up the house's own name - but the row it lands on
/// is decided by the name.
///
/// Matching is on [normaliseProductName] throughout, the same function the
/// cross-photo merge uses, so the merge and the ladder can never disagree about
/// whether two things are the same product.
PantryVisionPlan buildPantryVisionPlan({
  required PantryVisionResult vision,
  required List<PantryItemDto> pantry,
  required List<PantryBarcodeDto> learnedBarcodes,
  required PantryVisionDirection direction,
}) {
  final itemsByName = <String, PantryItemDto>{};
  final itemsByBarcode = <String, PantryItemDto>{};
  for (final item in pantry) {
    itemsByName.putIfAbsent(normaliseProductName(item.name), () => item);
    final code = item.barcode;
    if (code != null && code.isNotEmpty) {
      itemsByBarcode.putIfAbsent(code, () => item);
    }
  }

  final learnedByName = <String, PantryBarcodeDto>{};
  for (final learned in learnedBarcodes) {
    if (learned.barcode.isEmpty || learned.name.isEmpty) continue;
    learnedByName.putIfAbsent(normaliseProductName(learned.name), () => learned);
  }

  // A house can have taught one code several names - "oat milk" and "oatly oat
  // drink" are one carton - and the model will use whichever the label shows. So
  // a code that is not written on any row here is still allowed to point at one,
  // via a learned name that matches it. Without this, two wordings of the same
  // carton resolve to two different things and the second puts a duplicate row
  // in a shared pantry.
  //
  // Strictly a fallback: a code actually written on an item always wins, which
  // is why this only fills gaps.
  for (final entry in learnedByName.entries) {
    final item = itemsByName[entry.key];
    if (item != null) itemsByBarcode.putIfAbsent(entry.value.barcode, () => item);
  }

  final rows = <PantryVisionRow>[];
  // Where each already-resolved target sits in [rows], so a second proposal for
  // the same thing folds into the first instead of becoming a second row.
  final rowForTarget = <String, int>{};

  for (final proposal in vision.items) {
    final key = proposal.matchKey;
    final barcode = learnedByName[key]?.barcode;
    final existing =
        (barcode == null ? null : itemsByBarcode[barcode]) ?? itemsByName[key];

    // Two differently-worded proposals can land on one pantry row, because the
    // ladder resolves names the merge step considers distinct: "oat milk" and
    // "oatly oat drink" both reach the same learned code. Left alone that is two
    // `set` rows onto one item, the second of which silently overwrites the
    // first - so the counts are folded instead, which is the same thing the
    // cross-photo merge does and is right in both directions.
    final target = existing?.id ?? barcode ?? key;
    final at = rowForTarget[target];
    if (at != null) {
      final row = rows[at];
      rows[at] = row.copyWith(count: row.proposal.count + proposal.count);
      continue;
    }

    rowForTarget[target] = rows.length;
    rows.add(
      PantryVisionRow.resolve(
        proposal: proposal,
        existing: existing,
        barcode: barcode,
        direction: direction,
      ),
    );
  }

  return PantryVisionPlan(rows: rows, unreadable: vision.unreadable);
}

/// What one row's write actually did.
///
/// A batch of writes into a shared pantry cannot report one boolean. Three of
/// twelve failing is a completely different situation from all twelve failing
/// and from all twelve working, and the person who took the photo is the only
/// one who can put it right - so every row comes back with its own answer and
/// the failures carry the error that caused them rather than a shrug.
class PantryVisionOutcome {
  const PantryVisionOutcome({
    required this.row,
    this.item,
    this.error,
    this.stackTrace,
  });

  final PantryVisionRow row;

  /// The pantry item as the server now holds it. Null when this row failed.
  final PantryItemDto? item;

  final Object? error;
  final StackTrace? stackTrace;

  bool get succeeded => error == null;

  /// Ran out of time rather than being refused.
  ///
  /// Worth telling apart, because a timed-out write **may still have landed**:
  /// the request was abandoned, not undone. Offering "try again" on one of these
  /// is how a scan gets applied twice. Offer a reload instead.
  bool get timedOut => error is TimeoutException;
}

/// The writes this feature makes, and nothing else.
///
/// A deliberately tiny port rather than passing [HouseholdApi] around, for two
/// reasons. The blunt one is that half of what this needs - `scanPantryItem` -
/// is an **extension** method, and extension members are resolved statically:
/// a test double that subclasses [HouseholdApi] and overrides it would be
/// ignored, and the batch would go looking for a real network. The better one is
/// that it says exactly what applying a plan is allowed to do to a pantry, which
/// is three things, none of which is a delete.
abstract interface class PantryVisionWriter {
  /// A product this pantry has never held.
  Future<PantryItemDto> createItem(
    String channelId, {
    required String name,
    required double quantity,
    String? unit,
  });

  /// Land an existing row on an absolute quantity.
  Future<PantryItemDto> setQuantity(String itemId, {required double quantity});

  /// Put stock in against a barcode, letting the server find or create the row
  /// and bring the house's own name and defaults with it.
  Future<PantryItemDto> addByBarcode(
    String channelId, {
    required String barcode,
    required double quantity,
  });
}

/// [PantryVisionWriter] over the real API.
class HouseholdPantryVisionWriter implements PantryVisionWriter {
  const HouseholdPantryVisionWriter(
    this.api, {
    this.deadline = pantryVisionWriteDeadline,
  });

  final HouseholdApi api;

  /// Bounds the one call here that can genuinely hang. Held on the writer
  /// rather than read from a global so a caller with a slower tolerance - a
  /// background retry, say - can say so.
  final Duration deadline;

  @override
  Future<PantryItemDto> createItem(
    String channelId, {
    required String name,
    required double quantity,
    String? unit,
  }) => api.createPantryItem(
    channelId,
    name: name,
    quantity: quantity,
    unit: unit,
  );

  @override
  Future<PantryItemDto> setQuantity(String itemId, {required double quantity}) =>
      api.updatePantryItem(itemId, quantity: quantity);

  @override
  Future<PantryItemDto> addByBarcode(
    String channelId, {
    required String barcode,
    required double quantity,
  }) async {
    // Cancelled rather than merely timed out, for the reason the scanner
    // documents: a scan can stack a client timeout, a `429` backoff and a
    // catalog lookup, and abandoning the wait while leaving the request running
    // means the next row queues behind work nobody is waiting for.
    final token = CancelToken();
    final result = await api
        .scanPantryItem(channelId, barcode: barcode, quantity: quantity, cancelToken: token)
        .timeout(
          deadline,
          onTimeout: () {
            token.cancel('pantry vision deadline');
            throw TimeoutException('scan', deadline);
          },
        );
    return result.item;
  }
}

/// Writes a reviewed plan, one call per included row.
///
/// Sequential on purpose. These are writes into one shared pantry and several of
/// them can be about the same product from the server's point of view - a scan
/// resolves its row by barcode - so firing them together is a race with somebody
/// else's stock as the prize. It also keeps the failure story simple: the
/// outcomes come back in plan order and the first failure does not take the rest
/// of the batch with it.
///
/// Nothing thrown escapes. A row that fails is a row that failed; the other
/// eleven still land, and the caller gets a list it can render honestly rather
/// than an exception that loses the eleven successes on its way up.
///
/// [timeout] is an outer bound on each row on top of whatever the writer does
/// for itself. A row that hits it comes back with [PantryVisionOutcome.timedOut]
/// set, which is a distinct thing to show somebody - see the note there about
/// why "try again" is the wrong offer.
Future<List<PantryVisionOutcome>> applyPantryVisionPlan(
  PantryVisionPlan plan, {
  required String channelId,
  required PantryVisionWriter writer,
  Duration timeout = pantryVisionWriteDeadline,
}) async {
  final outcomes = <PantryVisionOutcome>[];
  for (final row in plan.writableRows) {
    try {
      final item = await _writeRow(
        row,
        channelId: channelId,
        writer: writer,
      ).timeout(timeout);
      outcomes.add(PantryVisionOutcome(row: row, item: item));
    } catch (error, stackTrace) {
      outcomes.add(
        PantryVisionOutcome(row: row, error: error, stackTrace: stackTrace),
      );
    }
  }
  return outcomes;
}

/// Picks the one call that lands this row on [PantryVisionRow.targetQuantity].
///
/// The barcode path is preferred where it is safe ([PantryVisionRow.canScanIn])
/// because a scan brings the house's own name, unit and learned defaults with
/// it, which is the whole point of the top rung of the ladder. But a scan
/// **adds**, and the default action for something already in the pantry is
/// `set` - so the amount handed to it is the difference, not the target. Sending
/// the target to a scan is exactly the bug the stocktake rule exists to prevent:
/// one carton on the shelf plus a photo showing three would become four.
///
/// A difference of zero or less cannot be expressed as a scan at all, so those
/// fall back to a plain update: nothing to add, or something to take away.
Future<PantryItemDto> _writeRow(
  PantryVisionRow row, {
  required String channelId,
  required PantryVisionWriter writer,
}) {
  final existing = row.existing;

  if (existing == null) {
    final barcode = row.barcode;
    // A code with no row behind it: let the scan create it, so the house's own
    // name wins over whatever the model called it.
    if (row.canScanIn && barcode != null) {
      return writer.addByBarcode(
        channelId,
        barcode: barcode,
        quantity: row.targetQuantity,
      );
    }
    return writer.createItem(
      channelId,
      name: row.name,
      quantity: row.targetQuantity,
      // Left off deliberately. The model's `unit` describes the pack size on the
      // label ("1 l"), not the unit of the count, and writing "3 l" for three
      // one-litre cartons is a wrong number rather than a missing one. Somebody
      // setting a unit in review or a later scan is how a photo-seeded row gets
      // one.
    );
  }

  final barcode = row.barcode;
  final delta = row.delta;
  if (row.canScanIn && barcode != null && delta > 0) {
    return writer.addByBarcode(
      channelId,
      barcode: barcode,
      quantity: delta,
    );
  }
  return writer.setQuantity(existing.id, quantity: row.targetQuantity);
}
