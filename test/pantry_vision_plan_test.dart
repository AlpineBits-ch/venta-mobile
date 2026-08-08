import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:venta_mobile/core/ai/pantry_vision_models.dart';
import 'package:venta_mobile/features/household/data/models/pantry_dto.dart';
import 'package:venta_mobile/features/household/data/pantry_vision_plan.dart';

/// The half of pantry vision that can quietly ruin a shared cupboard.
///
/// Everything the model says is a guess and everything this code writes is
/// somebody else's food, so the rules in `docs/pantry-vision.md` §2 and §3 are
/// tested as behaviour rather than as method calls: a photo is a stocktake and
/// never doubles stock, absence is never evidence, and nothing gets created in
/// order to be used up.
void main() {
  group('resolving a proposal against the pantry', () {
    test('prefers a barcode this house has learned over a matching name', () {
      final plan = buildPantryVisionPlan(
        vision: _sawOne('Oat milk', 2),
        pantry: [
          _item(id: 'by-name', name: 'Oat milk'),
          _item(id: 'by-code', name: 'Hafermilch', barcode: '7610100'),
        ],
        learnedBarcodes: [
          const PantryBarcodeDto(barcode: '7610100', name: 'Oat milk'),
        ],
        direction: PantryVisionDirection.stockUp,
      );

      final row = plan.rows.single;
      expect(row.barcode, '7610100');
      expect(row.existing?.id, 'by-code');
    });

    test('falls through to the name when the learned code is on nothing here',
        () {
      // The house knows a code for oat milk, but the oat milk on this shelf is a
      // row an earlier photo created with no code on it. Treating that as "not
      // in the pantry" would put a second oat milk in a shared cupboard.
      final plan = buildPantryVisionPlan(
        vision: _sawOne('Oat milk', 2),
        pantry: [_item(id: 'seeded', name: 'Oat milk')],
        learnedBarcodes: [
          const PantryBarcodeDto(barcode: '7610100', name: 'Oat milk'),
        ],
        direction: PantryVisionDirection.stockUp,
      );

      final row = plan.rows.single;
      expect(row.existing?.id, 'seeded');
      expect(row.action, PantryVisionAction.set);
      expect(row.barcode, '7610100');
      // The code is recorded but must not be used as the write target: the
      // server resolves a scan by barcode and would not find this row.
      expect(row.canScanIn, isFalse);
    });

    test('matches names regardless of case and punctuation', () {
      final plan = buildPantryVisionPlan(
        vision: _sawOne('oat milk', 2),
        pantry: [_item(id: 'jar', name: 'Oat Milk')],
        learnedBarcodes: const [],
        direction: PantryVisionDirection.stockUp,
      );

      expect(plan.rows.single.existing?.id, 'jar');
    });

    test('matches a name the model punctuated differently', () {
      final plan = buildPantryVisionPlan(
        vision: _sawOne('Oat-milk.', 1),
        pantry: [_item(id: 'jar', name: 'Oat milk')],
        learnedBarcodes: const [],
        direction: PantryVisionDirection.stockUp,
      );

      expect(plan.rows.single.existing?.id, 'jar');
    });

    test('proposes a new row when nothing in the pantry matches', () {
      final plan = buildPantryVisionPlan(
        vision: _sawOne('Passata', 2),
        pantry: [_item(id: 'jar', name: 'Oat milk')],
        learnedBarcodes: const [],
        direction: PantryVisionDirection.stockUp,
      );

      final row = plan.rows.single;
      expect(row.existing, isNull);
      expect(row.action, PantryVisionAction.create);
      expect(row.targetQuantity, 2);
    });

    test('folds two names the house has taught one code into a single row', () {
      // Distinct enough to survive the cross-photo merge, identical once the
      // learned code has had its say. Two `set` rows onto one item would mean
      // the second silently overwrote the first.
      final plan = buildPantryVisionPlan(
        vision: const PantryVisionResult(
          items: [
            PantryVisionItem(name: 'Oat milk', count: 2),
            PantryVisionItem(name: 'Oatly oat drink', count: 1),
          ],
        ),
        pantry: [_item(id: 'jar', name: 'Oat milk', quantity: 5)],
        learnedBarcodes: [
          const PantryBarcodeDto(barcode: '7610100', name: 'Oat milk'),
          const PantryBarcodeDto(barcode: '7610100', name: 'Oatly oat drink'),
        ],
        direction: PantryVisionDirection.stockUp,
      );

      expect(plan.rows, hasLength(1));
      expect(plan.rows.single.proposal.count, 3);
      expect(plan.rows.single.targetQuantity, 3);
    });
  });

  group('stocking up', () {
    test('sets an existing item to what the photo shows rather than adding', () {
      final plan = buildPantryVisionPlan(
        vision: _sawOne('Oat milk', 3),
        pantry: [_item(id: 'jar', name: 'Oat milk', quantity: 3)],
        learnedBarcodes: const [],
        direction: PantryVisionDirection.stockUp,
      );

      final row = plan.rows.single;
      expect(row.action, PantryVisionAction.set);
      expect(row.targetQuantity, 3, reason: 'a photo is a stocktake, not a delivery');
    });

    test('leaves the shelf at three when the same shelf is photographed twice',
        () async {
      // The one that matters. Two applies of the same photo of the same three
      // cartons must leave three cartons, not six.
      const shelf = 'Oat milk';
      final jar = _item(id: 'jar', name: shelf, quantity: 3);
      var pantry = [jar];
      final writer = _FakeWriter(items: {jar.id: jar});

      for (var pass = 0; pass < 2; pass++) {
        final plan = buildPantryVisionPlan(
          vision: _sawOne(shelf, 3),
          pantry: pantry,
          learnedBarcodes: const [],
          direction: PantryVisionDirection.stockUp,
        );
        final outcomes = await applyPantryVisionPlan(
          plan,
          channelId: 'fridge',
          writer: writer,
        );
        expect(outcomes.single.succeeded, isTrue);
        pantry = [outcomes.single.item!];
      }

      expect(pantry.single.quantity, 3);
      expect(writer.creates, isEmpty);
      expect(writer.sets, [('jar', 3.0), ('jar', 3.0)]);
    });

    test('adds instead of setting only when the row is flipped in review', () {
      final plan = buildPantryVisionPlan(
        vision: _sawOne('Oat milk', 2),
        pantry: [_item(id: 'jar', name: 'Oat milk', quantity: 3)],
        learnedBarcodes: const [],
        direction: PantryVisionDirection.stockUp,
      );

      final flipped = plan.rows.single.copyWith(action: PantryVisionAction.add);
      expect(flipped.targetQuantity, 5);
      // And the target follows a later count edit rather than going stale.
      expect(flipped.copyWith(count: 4).targetQuantity, 7);
    });

    test('flags a row that would leave less stock than the pantry records', () {
      // Six tins with three at the back photograph as three, and `set` writes
      // three. Correct for a full shelf, wrong for a deep one, and only the
      // person holding the phone can tell which.
      final plan = buildPantryVisionPlan(
        vision: _sawOne('Tinned tomatoes', 3),
        pantry: [_item(id: 'tins', name: 'Tinned tomatoes', quantity: 6)],
        learnedBarcodes: const [],
        direction: PantryVisionDirection.stockUp,
      );

      expect(plan.rows.single.reducesStock, isTrue);
      expect(plan.rows.single.delta, -3);
    });
  });

  group('using up', () {
    test('takes what the photo shows off what the pantry holds', () {
      final plan = buildPantryVisionPlan(
        vision: _sawOne('Oat milk', 2),
        pantry: [_item(id: 'jar', name: 'Oat milk', quantity: 5)],
        learnedBarcodes: const [],
        direction: PantryVisionDirection.useUp,
      );

      final row = plan.rows.single;
      expect(row.action, PantryVisionAction.set);
      expect(row.targetQuantity, 3);
    });

    test('stops at zero rather than writing a negative quantity', () {
      final plan = buildPantryVisionPlan(
        vision: _sawOne('Oat milk', 4),
        pantry: [_item(id: 'jar', name: 'Oat milk', quantity: 3)],
        learnedBarcodes: const [],
        direction: PantryVisionDirection.useUp,
      );

      expect(plan.rows.single.targetQuantity, 0);
    });

    test('creates nothing for a product this pantry does not hold', () async {
      final plan = buildPantryVisionPlan(
        vision: _sawOne('Passata', 2),
        pantry: [_item(id: 'jar', name: 'Oat milk', quantity: 5)],
        learnedBarcodes: const [],
        direction: PantryVisionDirection.useUp,
      );

      final row = plan.rows.single;
      expect(row.action, PantryVisionAction.unmatched);
      expect(row.isUnmatched, isTrue);
      expect(row.willWrite, isFalse);
      expect(plan.unmatchedCount, 1);

      final writer = _FakeWriter();
      final outcomes = await applyPantryVisionPlan(
        plan,
        channelId: 'fridge',
        writer: writer,
      );
      expect(outcomes, isEmpty);
      expect(writer.calls, isEmpty);
    });

    test('cannot be edited into creating the stock it is trying to remove', () {
      final plan = buildPantryVisionPlan(
        vision: _sawOne('Passata', 2),
        pantry: const [],
        learnedBarcodes: const [],
        direction: PantryVisionDirection.useUp,
      );

      final forced = plan.rows.single.copyWith(
        action: PantryVisionAction.create,
      );
      expect(forced.action, PantryVisionAction.unmatched);
      expect(forced.willWrite, isFalse);
    });

    test('never reaches for a scan, which can only add', () {
      final plan = buildPantryVisionPlan(
        vision: _sawOne('Oat milk', 1),
        pantry: [
          _item(id: 'jar', name: 'Oat milk', quantity: 5, barcode: '7610100'),
        ],
        learnedBarcodes: [
          const PantryBarcodeDto(barcode: '7610100', name: 'Oat milk'),
        ],
        direction: PantryVisionDirection.useUp,
      );

      expect(plan.rows.single.canScanIn, isFalse);
    });
  });

  group('what the photo did not say', () {
    test('leaves pantry items the photo never mentioned out of the plan', () {
      // Absence is never evidence. A photo is one shelf, and everything else in
      // the cupboard must be untouchable by it.
      final plan = buildPantryVisionPlan(
        vision: _sawOne('Oat milk', 2),
        pantry: [
          _item(id: 'jar', name: 'Oat milk', quantity: 1),
          _item(id: 'rice', name: 'Rice', quantity: 4),
          _item(id: 'salt', name: 'Salt', quantity: 1),
        ],
        learnedBarcodes: const [],
        direction: PantryVisionDirection.stockUp,
      );

      expect(plan.rows, hasLength(1));
      expect(
        plan.rows.map((r) => r.existing?.id),
        isNot(anyElement(anyOf('rice', 'salt'))),
      );
    });

    test('never zeroes an item the photo did not mention', () async {
      final writer = _FakeWriter();
      final plan = buildPantryVisionPlan(
        vision: _sawOne('Oat milk', 2),
        pantry: [
          _item(id: 'jar', name: 'Oat milk', quantity: 1),
          _item(id: 'rice', name: 'Rice', quantity: 4),
        ],
        learnedBarcodes: const [],
        direction: PantryVisionDirection.useUp,
      );

      await applyPantryVisionPlan(plan, channelId: 'fridge', writer: writer);
      expect(writer.calls.map((c) => c.id), isNot(contains('rice')));
    });

    test('carries how much the model could not read into the plan', () {
      final plan = buildPantryVisionPlan(
        vision: const PantryVisionResult(
          items: [PantryVisionItem(name: 'Oat milk', count: 2)],
          unreadable: 4,
        ),
        pantry: const [],
        learnedBarcodes: const [],
        direction: PantryVisionDirection.stockUp,
      );

      expect(plan.unreadable, 4);
    });
  });

  group('predicting the consequence', () {
    test('says when a row will land below its restock threshold', () {
      final plan = buildPantryVisionPlan(
        vision: _sawOne('Oat milk', 2),
        pantry: [
          _item(id: 'jar', name: 'Oat milk', quantity: 5, lowThreshold: 2),
        ],
        learnedBarcodes: const [],
        direction: PantryVisionDirection.useUp,
      );

      expect(plan.rows.single.targetQuantity, 3);
      expect(plan.rows.single.predictedIsLow, isFalse);
      expect(plan.rows.single.copyWith(count: 3).predictedIsLow, isTrue);
    });

    test('says nothing at all where there is no threshold to be below', () {
      final plan = buildPantryVisionPlan(
        vision: _sawOne('Oat milk', 2),
        pantry: [_item(id: 'jar', name: 'Oat milk', quantity: 5)],
        learnedBarcodes: const [],
        direction: PantryVisionDirection.useUp,
      );

      expect(plan.rows.single.predictedIsLow, isNull);
    });
  });

  group('applying a reviewed plan', () {
    test('creates a plain row for a product with no learned code', () async {
      final writer = _FakeWriter();
      final plan = buildPantryVisionPlan(
        vision: _sawOne('Passata', 2),
        pantry: const [],
        learnedBarcodes: const [],
        direction: PantryVisionDirection.stockUp,
      );

      await applyPantryVisionPlan(plan, channelId: 'fridge', writer: writer);
      expect(writer.creates, [('Passata', 2.0)]);
      expect(writer.scans, isEmpty);
    });

    test('scans a learned code in so the house keeps its own name', () async {
      final writer = _FakeWriter();
      final plan = buildPantryVisionPlan(
        vision: _sawOne('Oat milk', 2),
        pantry: const [],
        learnedBarcodes: [
          const PantryBarcodeDto(barcode: '7610100', name: 'Oat milk'),
        ],
        direction: PantryVisionDirection.stockUp,
      );

      await applyPantryVisionPlan(plan, channelId: 'fridge', writer: writer);
      expect(writer.creates, isEmpty);
      expect(writer.scans, [('7610100', 2.0)]);
    });

    test('scans only the difference when the row is a stocktake', () async {
      // A scan adds. Handing it the target instead of the difference is exactly
      // how one carton plus a photo of three becomes four.
      final writer = _FakeWriter();
      final plan = buildPantryVisionPlan(
        vision: _sawOne('Oat milk', 3),
        pantry: [
          _item(id: 'jar', name: 'Oat milk', quantity: 1, barcode: '7610100'),
        ],
        learnedBarcodes: [
          const PantryBarcodeDto(barcode: '7610100', name: 'Oat milk'),
        ],
        direction: PantryVisionDirection.stockUp,
      );

      await applyPantryVisionPlan(plan, channelId: 'fridge', writer: writer);
      expect(writer.scans, [('7610100', 2.0)]);
    });

    test('updates rather than scanning when the stocktake means less stock',
        () async {
      final writer = _FakeWriter();
      final plan = buildPantryVisionPlan(
        vision: _sawOne('Oat milk', 1),
        pantry: [
          _item(id: 'jar', name: 'Oat milk', quantity: 4, barcode: '7610100'),
        ],
        learnedBarcodes: [
          const PantryBarcodeDto(barcode: '7610100', name: 'Oat milk'),
        ],
        direction: PantryVisionDirection.stockUp,
      );

      await applyPantryVisionPlan(plan, channelId: 'fridge', writer: writer);
      expect(writer.scans, isEmpty);
      expect(writer.sets, [('jar', 1.0)]);
    });

    test('writes nothing for a row somebody dropped in review', () async {
      final writer = _FakeWriter();
      final plan = buildPantryVisionPlan(
        vision: const PantryVisionResult(
          items: [
            PantryVisionItem(name: 'Oat milk', count: 2),
            PantryVisionItem(name: 'Passata', count: 1),
          ],
        ),
        pantry: const [],
        learnedBarcodes: const [],
        direction: PantryVisionDirection.stockUp,
      );

      final edited = plan.replaceRow(0, plan.rows[0].copyWith(included: false));
      expect(edited.writeCount, 1);

      final outcomes = await applyPantryVisionPlan(
        edited,
        channelId: 'fridge',
        writer: writer,
      );
      expect(outcomes, hasLength(1));
      expect(writer.creates, [('Passata', 1.0)]);
    });

    test('reports the rows that failed and still lands the ones that did not',
        () async {
      // Three of twelve failing has to be visible. An apply that throws loses
      // the nine that worked on the way up.
      final writer = _FakeWriter(failNames: {'Passata'});
      final plan = buildPantryVisionPlan(
        vision: const PantryVisionResult(
          items: [
            PantryVisionItem(name: 'Oat milk', count: 2),
            PantryVisionItem(name: 'Passata', count: 1),
            PantryVisionItem(name: 'Rice', count: 3),
          ],
        ),
        pantry: const [],
        learnedBarcodes: const [],
        direction: PantryVisionDirection.stockUp,
      );

      final outcomes = await applyPantryVisionPlan(
        plan,
        channelId: 'fridge',
        writer: writer,
      );

      expect(outcomes, hasLength(3));
      expect(outcomes.map((o) => o.succeeded), [true, false, true]);
      expect(outcomes[1].row.name, 'Passata');
      expect(outcomes[1].error, isA<StateError>());
      expect(outcomes[1].item, isNull);
      expect(writer.creates, [('Oat milk', 2.0), ('Rice', 3.0)]);
    });

    test('reports a row that ran out of time as timed out, not as refused',
        () async {
      final writer = _FakeWriter(hangNames: {'Oat milk'});
      final plan = buildPantryVisionPlan(
        vision: _sawOne('Oat milk', 2),
        pantry: const [],
        learnedBarcodes: const [],
        direction: PantryVisionDirection.stockUp,
      );

      final outcomes = await applyPantryVisionPlan(
        plan,
        channelId: 'fridge',
        writer: writer,
        timeout: const Duration(milliseconds: 20),
      );

      expect(outcomes.single.succeeded, isFalse);
      expect(outcomes.single.timedOut, isTrue);
    });
  });
}

PantryVisionResult _sawOne(String name, int count) =>
    PantryVisionResult(items: [PantryVisionItem(name: name, count: count)]);

PantryItemDto _item({
  required String id,
  required String name,
  double quantity = 1,
  String? barcode,
  double? lowThreshold,
}) => PantryItemDto(
  id: id,
  channelId: 'fridge',
  name: name,
  quantity: quantity,
  barcode: barcode,
  lowThreshold: lowThreshold,
);

/// Records what a plan asked for instead of doing it, and can be told to refuse
/// or to hang on a named product so the partial-failure paths are reachable
/// without a network.
class _FakeWriter implements PantryVisionWriter {
  _FakeWriter({
    this.items = const {},
    this.failNames = const {},
    this.hangNames = const {},
  });

  /// The pantry as the server holds it, by item id, so an update answers with
  /// the row it actually changed rather than a stub - a test that feeds one
  /// apply's result into the next plan depends on the name surviving.
  final Map<String, PantryItemDto> items;

  final Set<String> failNames;
  final Set<String> hangNames;

  final List<({String kind, String id, double quantity})> calls = [];

  List<(String, double)> get creates => [
    for (final c in calls)
      if (c.kind == 'create') (c.id, c.quantity),
  ];

  List<(String, double)> get sets => [
    for (final c in calls)
      if (c.kind == 'set') (c.id, c.quantity),
  ];

  List<(String, double)> get scans => [
    for (final c in calls)
      if (c.kind == 'scan') (c.id, c.quantity),
  ];

  @override
  Future<PantryItemDto> createItem(
    String channelId, {
    required String name,
    required double quantity,
    String? unit,
  }) async {
    if (hangNames.contains(name)) return Completer<PantryItemDto>().future;
    if (failNames.contains(name)) throw StateError('refused $name');
    calls.add((kind: 'create', id: name, quantity: quantity));
    return PantryItemDto(
      id: 'new-$name',
      channelId: channelId,
      name: name,
      quantity: quantity,
      unit: unit,
    );
  }

  @override
  Future<PantryItemDto> setQuantity(
    String itemId, {
    required double quantity,
  }) async {
    if (hangNames.contains(itemId)) return Completer<PantryItemDto>().future;
    if (failNames.contains(itemId)) throw StateError('refused $itemId');
    calls.add((kind: 'set', id: itemId, quantity: quantity));
    final held = items[itemId];
    return held != null
        ? held.copyWith(quantity: quantity)
        : PantryItemDto(
            id: itemId,
            channelId: 'fridge',
            name: itemId,
            quantity: quantity,
          );
  }

  @override
  Future<PantryItemDto> addByBarcode(
    String channelId, {
    required String barcode,
    required double quantity,
  }) async {
    if (hangNames.contains(barcode)) return Completer<PantryItemDto>().future;
    if (failNames.contains(barcode)) throw StateError('refused $barcode');
    calls.add((kind: 'scan', id: barcode, quantity: quantity));
    return PantryItemDto(
      id: 'scanned-$barcode',
      channelId: channelId,
      name: barcode,
      quantity: quantity,
      barcode: barcode,
    );
  }
}
