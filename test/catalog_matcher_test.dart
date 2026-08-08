import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mobile/core/ai/ai_key_store.dart';
import 'package:venta_mobile/core/ai/ai_provider.dart';
import 'package:venta_mobile/core/ai/catalog_matcher.dart';
import 'package:venta_mobile/core/ai/pantry_vision_models.dart';
import 'package:venta_mobile/core/ai/vision_client.dart';
import 'package:venta_mobile/features/household/data/models/pantry_dto.dart';

/// The matcher, held to hand-written answers rather than to a live model.
///
/// Every test here is about one property: **a model can only pick a row we
/// showed it, and any answer that is not a clean pick is an abstention.** That
/// property is the entire reason rung 3 of the resolution ladder is allowed to
/// exist at all - the alternative design, asking a model for a barcode, is
/// forbidden forever - so the interesting cases are all the ways an answer can
/// be wrong rather than the one way it can be right.
///
/// A wrong barcode does not fail loudly. It writes a product that does not exist
/// into a shared household cupboard, under a code a flatmate will later scan and
/// trust, and it outlives everybody's memory of the photograph that caused it.
/// None of that shows up at a cupboard; all of it shows up here.
void main() {
  ProductCatalogMatchDto row(
    String name, {
    String? brand,
    double? quantity,
    String? unit,
    String? barcode,
    String source = 'Open Food Facts',
  }) => ProductCatalogMatchDto(
    name: name,
    brand: brand,
    quantity: quantity,
    quantityUnit: unit,
    barcode: barcode,
    sourceName: source,
  );

  PantryVisionItem proposal(
    String name, {
    String? brand,
    String? size,
    String? unit,
  }) => PantryVisionItem(
    name: name,
    count: 1,
    brand: brand,
    size: size,
    unit: unit,
  );

  final oatly = row(
    'Oatly Oat Drink',
    brand: 'Oatly',
    quantity: 1,
    unit: 'l',
    barcode: '7394376616068',
  );
  final alpro = row(
    'Alpro Oat Original',
    brand: 'Alpro',
    quantity: 1,
    unit: 'l',
    barcode: '5411188119098',
  );
  final ownBrand = row(
    'M-Budget Hafer Drink',
    brand: 'Migros',
    quantity: 1,
    unit: 'l',
    barcode: '7610200416087',
  );

  CatalogMatchCandidates oatMilk({List<ProductCatalogMatchDto>? candidates}) =>
      CatalogMatchCandidates(
        proposal: proposal('Oat milk', brand: 'Oatly', size: '1', unit: 'l'),
        candidates: candidates ?? [oatly, alpro, ownBrand],
      );

  CatalogMatchCandidates tomatoes() => CatalogMatchCandidates(
    proposal: proposal('Chopped tomatoes', size: '400', unit: 'g'),
    candidates: [
      row('Mutti Polpa', brand: 'Mutti', quantity: 400, unit: 'g', barcode: '80042556'),
    ],
  );

  Map<String, Object?> answer(List<Map<String, Object?>> matches) => {
    'matches': matches,
  };

  Map<String, Object?> match({
    required Object? item,
    required Object? choice,
    String confidence = 'high',
    String? reason,
  }) => {
    if (item != _absent) 'item': item,
    if (choice != _absent) 'choice': choice,
    'confidence': confidence,
    'reason': reason,
  };

  group('parsing an answer', () {
    test('a valid index resolves to that row, and to that row\'s barcode', () {
      final items = [oatMilk()];

      final choices = parseCatalogMatchResponse(
        answer([
          match(item: 0, choice: 1, confidence: 'medium', reason: 'same brand'),
        ]),
        items,
      );

      expect(choices, hasLength(1));
      expect(choices.single.isMatch, isTrue);
      expect(choices.single.match, same(alpro));
      // The point of the whole design: the code came off the row we already
      // held, not out of the model's answer.
      expect(choices.single.barcode, '5411188119098');
      expect(choices.single.confidence, VisionConfidence.medium);
      expect(choices.single.reason, 'same brand');
      expect(choices.single.proposal.name, 'Oat milk');
    });

    /// The most important test in this file.
    ///
    /// An index past the end of the list is the single most likely way a model
    /// gets this wrong - it is an off-by-one, or a count, or a rank it invented.
    /// It must not throw, and it must not be clamped into the list: clamping
    /// would hand somebody a real barcode for a product nobody chose, which is
    /// indistinguishable afterwards from a code that was scanned.
    test('an out-of-range index abstains rather than crashing or clamping', () {
      final items = [oatMilk()];

      final choices = parseCatalogMatchResponse(
        answer([match(item: 0, choice: 12)]),
        items,
      );

      expect(choices, hasLength(1));
      expect(choices.single.isMatch, isFalse);
      expect(choices.single.match, isNull);
      expect(choices.single.barcode, isNull);
    });

    test('an index one past the end abstains', () {
      final items = [oatMilk()];

      final choices = parseCatalogMatchResponse(
        answer([match(item: 0, choice: 3)]),
        items,
      );

      expect(choices.single.match, isNull);
    });

    test('a negative index abstains', () {
      final items = [oatMilk()];

      final choices = parseCatalogMatchResponse(
        answer([match(item: 0, choice: -1)]),
        items,
      );

      expect(choices.single.match, isNull);
    });

    test('a null choice abstains, and keeps the model\'s reason', () {
      final items = [oatMilk()];

      final choices = parseCatalogMatchResponse(
        answer([
          match(
            item: 0,
            choice: null,
            confidence: 'high',
            reason: 'four own-brand cartons, none distinguishable',
          ),
        ]),
        items,
      );

      expect(choices.single.match, isNull);
      expect(
        choices.single.reason,
        'four own-brand cartons, none distinguishable',
      );
      // A "high confidence" abstention is a contradiction, and the first thing
      // anybody would do with one is sort a review list by it.
      expect(choices.single.confidence, VisionConfidence.low);
    });

    test('an entry with no item field abstains', () {
      final items = [oatMilk()];

      final choices = parseCatalogMatchResponse(
        answer([match(item: _absent, choice: 0)]),
        items,
      );

      expect(choices.single.match, isNull);
    });

    test('an entry with no choice field abstains', () {
      final items = [oatMilk()];

      final choices = parseCatalogMatchResponse(
        answer([match(item: 0, choice: _absent)]),
        items,
      );

      expect(choices.single.match, isNull);
    });

    test('an entry whose item is out of range is dropped, not misapplied', () {
      final items = [oatMilk()];

      final choices = parseCatalogMatchResponse(
        answer([match(item: 7, choice: 0)]),
        items,
      );

      expect(choices, hasLength(1));
      expect(choices.single.match, isNull);
    });

    test('an item the model omitted entirely abstains', () {
      final items = [oatMilk(), tomatoes()];

      final choices = parseCatalogMatchResponse(
        answer([match(item: 1, choice: 0)]),
        items,
      );

      expect(choices, hasLength(2));
      expect(choices.first.match, isNull);
      expect(choices.last.match?.name, 'Mutti Polpa');
    });

    test('an empty or missing matches array abstains for every item', () {
      final items = [oatMilk(), tomatoes()];

      for (final body in <Map<String, Object?>>[
        {},
        {'matches': null},
        {'matches': 'no idea'},
        {'matches': <Object?>[]},
        {'matches': <Object?>['not an object']},
      ]) {
        final choices = parseCatalogMatchResponse(body, items);
        expect(choices, hasLength(2), reason: '$body');
        expect(choices.every((c) => c.match == null), isTrue, reason: '$body');
      }
    });

    /// The rule: **a duplicate is harmless, a contradiction abstains.**
    ///
    /// Two entries naming the same candidate are a model repeating itself and
    /// the first is kept. Two naming different candidates are a model
    /// disagreeing with itself, and there is no principled way to pick a winner
    /// - "first wins" would be a coin toss over which product goes into a
    /// shared cupboard, so neither wins.
    test('two entries for one item that agree keep the first', () {
      final items = [oatMilk()];

      final choices = parseCatalogMatchResponse(
        answer([
          match(item: 0, choice: 0, confidence: 'high', reason: 'first'),
          match(item: 0, choice: 0, confidence: 'low', reason: 'second'),
        ]),
        items,
      );

      expect(choices.single.match, same(oatly));
      expect(choices.single.confidence, VisionConfidence.high);
      expect(choices.single.reason, 'first');
    });

    test('two entries for one item that disagree abstain', () {
      final items = [oatMilk()];

      final choices = parseCatalogMatchResponse(
        answer([
          match(item: 0, choice: 0),
          match(item: 0, choice: 2),
        ]),
        items,
      );

      expect(choices.single.match, isNull);
    });

    test('a contradicted item does not take the other items down with it', () {
      final items = [oatMilk(), tomatoes()];

      final choices = parseCatalogMatchResponse(
        answer([
          match(item: 0, choice: 0),
          match(item: 0, choice: 1),
          match(item: 1, choice: 0),
        ]),
        items,
      );

      expect(choices.first.match, isNull);
      expect(choices.last.match?.name, 'Mutti Polpa');
    });

    test('a pick contradicted by an abstention abstains', () {
      final items = [oatMilk()];

      final choices = parseCatalogMatchResponse(
        answer([
          match(item: 0, choice: 1),
          match(item: 0, choice: null),
        ]),
        items,
      );

      expect(choices.single.match, isNull);
    });

    /// A model that has been told about barcodes elsewhere in its life may try
    /// to be helpful. It has nowhere to put one - the schema says integer or
    /// null - but a parser that coerced strings would turn the attempt into a
    /// subscript, and a short code would land inside the list.
    test('a barcode where an index belongs cannot produce a match', () {
      final items = [oatMilk()];

      for (final bad in <Object?>[
        '7394376616068',
        '0',
        '1',
        ' 1 ',
        'one',
        true,
        <String, Object?>{'barcode': '7394376616068'},
        <Object?>[1],
      ]) {
        final choices = parseCatalogMatchResponse(
          answer([match(item: 0, choice: bad)]),
          items,
        );
        expect(choices.single.match, isNull, reason: 'choice: $bad');
      }
    });

    test('a stringly item number is not attributed to an item', () {
      final items = [oatMilk()];

      final choices = parseCatalogMatchResponse(
        answer([match(item: '0', choice: 0)]),
        items,
      );

      expect(choices.single.match, isNull);
    });

    test('a whole-numbered float is a valid index; a fractional one is not', () {
      final items = [oatMilk()];

      expect(
        parseCatalogMatchResponse(
          answer([match(item: 0, choice: 1.0)]),
          items,
        ).single.match,
        same(alpro),
      );
      expect(
        parseCatalogMatchResponse(
          answer([match(item: 0, choice: 1.5)]),
          items,
        ).single.match,
        isNull,
      );
    });

    test('an item that was never sent, having no candidates, abstains', () {
      final items = [oatMilk(candidates: const [])];

      final choices = parseCatalogMatchResponse(
        answer([match(item: 0, choice: 0)]),
        items,
      );

      expect(choices.single.match, isNull);
    });
  });

  group('candidate list', () {
    test('is capped, and an index beyond the cap abstains', () {
      final many = [
        for (var i = 0; i < 25; i++) row('Product $i', barcode: '111$i'),
      ];
      final items = [
        CatalogMatchCandidates(proposal: proposal('Thing'), candidates: many),
      ];

      expect(items.single.candidates, hasLength(maxCatalogCandidates));

      // The prompt and the lookup share one list, so a number the model could
      // never have been shown resolves to nothing rather than to row 9.
      expect(
        parseCatalogMatchResponse(
          answer([match(item: 0, choice: maxCatalogCandidates)]),
          items,
        ).single.match,
        isNull,
      );
      expect(
        parseCatalogMatchResponse(
          answer([match(item: 0, choice: maxCatalogCandidates - 1)]),
          items,
        ).single.match?.name,
        'Product ${maxCatalogCandidates - 1}',
      );
    });
  });

  group('the prompt', () {
    test('never contains a barcode', () {
      final items = [oatMilk(), tomatoes()];
      final prompt = buildCatalogMatchPrompt(items);

      for (final code in const [
        '7394376616068',
        '5411188119098',
        '7610200416087',
        '80042556',
      ]) {
        expect(prompt, isNot(contains(code)));
      }
    });

    test('numbers items by their position in the caller\'s list', () {
      final items = [oatMilk(), oatMilk(candidates: const []), tomatoes()];
      final prompt = buildCatalogMatchPrompt(items);

      // The item with nothing to choose between is not sent - it abstains for
      // free - but the ones after it keep their own numbers, or every answer
      // after a skipped item would land on the wrong row.
      expect(prompt, contains('Item 0:'));
      expect(prompt, isNot(contains('Item 1:')));
      expect(prompt, contains('Item 2:'));
    });

    test('describes candidates by the fields that tell them apart', () {
      final prompt = buildCatalogMatchPrompt([oatMilk()]);

      expect(prompt, contains('0. Oatly Oat Drink - Oatly - 1 l - Open Food Facts'));
      expect(prompt, contains('1. Alpro Oat Original - Alpro - 1 l'));
      expect(prompt, contains('Oat milk - Oatly - 1 l'));
    });

    test('prints a pack size without a trailing decimal point', () {
      final prompt = buildCatalogMatchPrompt([
        CatalogMatchCandidates(
          proposal: proposal('Cornflakes'),
          candidates: [row('Kellogg\'s', quantity: 380, unit: 'g')],
        ),
      ]);

      expect(prompt, contains('380 g'));
      expect(prompt, isNot(contains('380.0')));
    });
  });

  group('the schema', () {
    /// The guarantee is structural, not behavioural: there is nowhere in the
    /// response for thirteen digits to arrive. If this test ever fails because
    /// somebody added a string field, the feature has lost the property it was
    /// built around.
    test('offers no string field a code could arrive in', () {
      final entry =
          ((catalogMatchJsonSchema['properties']!
                      as Map<String, Object?>)['matches']!
                  as Map<String, Object?>)['items']!
              as Map<String, Object?>;
      final properties = entry['properties']! as Map<String, Object?>;

      // The whole vocabulary of an answer. Nothing here is a product, a name or
      // a code - only positions in a list we supplied.
      expect(properties.keys.toList(), [
        'item',
        'choice',
        'confidence',
        'reason',
      ]);
      expect(
        (catalogMatchJsonSchema['properties']! as Map).keys.toList(),
        ['matches'],
      );
      expect((properties['item']! as Map)['type'], 'integer');
      expect((properties['choice']! as Map)['type'], ['integer', 'null']);
      expect(entry['additionalProperties'], isFalse);
      expect(entry['required'], properties.keys.toList());
      expect(catalogMatchJsonSchema['additionalProperties'], isFalse);
    });
  });

  group('the client', () {
    late _MockKeys keys;

    setUp(() {
      keys = _MockKeys();
      when(() => keys.readConfig()).thenAnswer(
        (_) async => const AiProviderConfig(
          provider: AiProvider.anthropic,
          model: 'test-model',
        ),
      );
      when(
        () => keys.readKey(AiProvider.anthropic),
      ).thenAnswer((_) async => 'sk-test-key');
    });

    PantryVisionClient clientWith(_StubAdapter adapter) => PantryVisionClient(
      keys: keys,
      http: Dio()..httpClientAdapter = adapter,
    );

    test('a rate-limited batch abstains for every item instead of throwing', () async {
      final items = [oatMilk(), tomatoes()];
      final adapter = _StubAdapter(
        status: 429,
        body: {
          'error': {'message': 'rate limit'},
        },
      );

      final choices = await clientWith(adapter).matchCatalog(items);

      expect(choices, hasLength(2));
      expect(choices.every((c) => c.match == null), isTrue);
      // Losing the whole photograph because an optional second call was
      // throttled would be absurd: the proposals are still there, every row
      // just arrives as "pick one".
      expect(choices.map((c) => c.proposal.name), ['Oat milk', 'Chopped tomatoes']);
    });

    test('a provider outage abstains rather than throwing', () async {
      final choices = await clientWith(
        _StubAdapter(status: 500, body: const {}),
      ).matchCatalog([oatMilk()]);

      expect(choices.single.match, isNull);
    });

    test('an unreadable answer abstains after its one repair attempt', () async {
      final adapter = _StubAdapter(status: 200, body: 'not json at all');

      final choices = await clientWith(adapter).matchCatalog([oatMilk()]);

      expect(choices.single.match, isNull);
      expect(adapter.calls, 2, reason: 'one repair, and only one');
    });

    test('no configured provider abstains without a request', () async {
      when(() => keys.readConfig()).thenAnswer((_) async => null);
      final adapter = _StubAdapter(status: 200, body: const {});

      final choices = await clientWith(adapter).matchCatalog([oatMilk()]);

      expect(choices.single.match, isNull);
      expect(adapter.calls, 0);
    });

    test('nothing to choose between is answered without paying for it', () async {
      final adapter = _StubAdapter(status: 200, body: const {});

      final choices = await clientWith(adapter).matchCatalog([
        oatMilk(candidates: const []),
      ]);

      expect(choices, hasLength(1));
      expect(choices.single.match, isNull);
      expect(adapter.calls, 0);
    });

    test('a good answer resolves through the provider envelope', () async {
      final adapter = _StubAdapter(
        status: 200,
        body: {
          'stop_reason': 'end_turn',
          'content': [
            {'type': 'thinking', 'thinking': 'weighing the cartons'},
            {
              'type': 'text',
              'text': jsonEncode(
                answer([
                  match(item: 0, choice: 0, reason: 'same brand and size'),
                  match(item: 1, choice: 0, confidence: 'low'),
                ]),
              ),
            },
          ],
        },
      );

      final choices = await clientWith(adapter).matchCatalog([
        oatMilk(),
        tomatoes(),
      ]);

      expect(choices.first.barcode, '7394376616068');
      expect(choices.first.reason, 'same brand and size');
      expect(choices.last.match?.name, 'Mutti Polpa');
    });

    test('sends no barcode over the wire, and no photograph', () async {
      final adapter = _StubAdapter(
        status: 200,
        body: {
          'content': [
            {'type': 'text', 'text': jsonEncode(answer(const []))},
          ],
        },
      );

      await clientWith(adapter).matchCatalog([oatMilk(), tomatoes()]);

      final sent = jsonEncode(adapter.requests.single.data);
      for (final code in const [
        '7394376616068',
        '5411188119098',
        '7610200416087',
        '80042556',
      ]) {
        expect(sent, isNot(contains(code)));
      }
      expect(sent, isNot(contains('base64')));
      expect(sent, contains('Item 0:'));
      expect(sent, contains('Abstaining is the right answer'));
    });
  });
}

/// A sentinel for "this key is not in the object at all", which is a different
/// answer from a key holding null and is worth testing separately.
const Object _absent = Object();

class _MockKeys extends Mock implements AiKeyStore {}

/// Answers every request with one canned response, and remembers what it was
/// asked. No network, no key, no provider.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter({required this.status, required this.body});

  final int status;
  final Object? body;
  final List<RequestOptions> requests = [];

  int get calls => requests.length;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      body is String ? body! as String : jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [
          body is String ? Headers.textPlainContentType : Headers.jsonContentType,
        ],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
