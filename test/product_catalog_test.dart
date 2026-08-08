import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mobile/core/network/api_client.dart';
import 'package:venta_mobile/features/auth/data/auth_repository.dart';
import 'package:venta_mobile/features/household/data/household_api.dart';
import 'package:venta_mobile/features/household/data/household_api_wave2.dart';
import 'package:venta_mobile/features/household/data/models/pantry_dto.dart';
import 'package:venta_mobile/features/household/presentation/widgets/product_catalog_picker.dart';

/// The parts of catalog search that are wrong silently.
///
/// None of these fail loudly if they regress. A request fired at two characters
/// still answers `200` with nothing in it, so the only symptom is a burst of
/// traffic per keystroke. A dropped `barcode` leaves the picker returning
/// matches nobody can adopt, which looks like the adopt button being broken. A
/// `500+` rendered as `500` reads as a precise total the server explicitly
/// declined to give. A missing attribution is a licence breach that renders
/// perfectly. And a name in the "wrong" language filtered out on the way
/// through costs somebody the typing the whole feature exists to save.
class _MockAuthRepository extends Mock implements AuthRepository {}

/// Answers each request from [handler], recording what was asked for.
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this.handler);

  final List<RequestOptions> requests = [];

  final Object? Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode(handler(options)),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

const _base = 'https://example.test';

Map<String, dynamic> _match({
  String name = 'Shampoo',
  String language = 'en',
  String? brand,
  Object? quantity,
  String? quantityUnit,
  String? barcode = '7610100000001',
  String sourceName = 'Open Food Facts',
}) => {
  'name': name,
  'language': language,
  'brand': brand,
  'quantity': quantity,
  'quantityUnit': quantityUnit,
  'barcode': barcode,
  'source': 'off',
  'sourceName': sourceName,
  'sourceUrl': 'https://world.openfoodfacts.org/product/7610100000001',
  'license': 'ODbL 1.0',
  'licenseUrl': 'https://opendatacommons.org/licenses/odbl/1-0/',
  'attribution': 'Product data from Open Food Facts, ODbL 1.0',
  'importedAt': '2026-07-01T09:00:00Z',
};

Map<String, dynamic> _envelope({
  String query = 'shampoo',
  List<Map<String, dynamic>>? results,
  int count = 1,
  bool countIsLowerBound = false,
}) => {
  'query': query,
  'results': results ?? [_match()],
  'count': count,
  'countIsLowerBound': countIsLowerBound,
  'limit': 25,
  'offset': 0,
  'attribution': 'Product data from Open Food Facts, ODbL 1.0',
  'license': 'ODbL 1.0',
  'licenseUrl': 'https://opendatacommons.org/licenses/odbl/1-0/',
};

void main() {
  late _ScriptedAdapter adapter;
  late HouseholdApi api;

  void build(Object? Function(RequestOptions options) handler) {
    final auth = _MockAuthRepository();
    when(() => auth.baseUrl).thenReturn(_base);
    when(() => auth.ensureValidToken()).thenAnswer((_) async => 'token');

    final client = ApiClient(authRepository: auth);
    adapter = _ScriptedAdapter(handler);
    client.dio.httpClientAdapter = adapter;
    api = HouseholdApi(client: client);
  }

  group('searchProductCatalog', () {
    // The server answers 200-with-nothing below three characters, so firing
    // anyway is not an error - it is a request per keystroke whose answer was
    // known before it left. Nothing surfaces if this regresses.
    test('does not touch the network under three characters', () async {
      build((_) => _envelope());

      for (final term in ['', 'o', 'oa', '  oa  ']) {
        final result = await api.searchProductCatalog(term);
        expect(result.results, isEmpty);
        expect(result.count, 0);
      }

      expect(adapter.requests, isEmpty);
    });

    test('searches at exactly three characters', () async {
      build((_) => _envelope(query: 'oat'));

      final result = await api.searchProductCatalog('  oat  ');

      expect(adapter.requests, hasLength(1));
      final request = adapter.requests.single;
      // Not nested under a guild id: the catalog is one shared database.
      expect(request.path, '$_base/api/v1/guild/pantry/catalog/search');
      // Trimmed, so trailing whitespace does not become a different query.
      expect(request.queryParameters['q'], 'oat');
      expect(request.queryParameters['limit'], 25);
      expect(request.queryParameters['offset'], 0);
      expect(result.query, 'oat');
    });

    test('passes limit, offset and Accept-Language through', () async {
      build((_) => _envelope());

      await api.searchProductCatalog(
        'shampoo',
        limit: 50,
        offset: 25,
        acceptLanguage: 'de-CH',
      );

      final request = adapter.requests.single;
      expect(request.queryParameters['limit'], 50);
      expect(request.queryParameters['offset'], 25);
      expect(request.headers['Accept-Language'], 'de-CH');
    });

    // `quantity` is the pack size on the packaging and is absent for roughly
    // seven groceries in eight, so a parse that cannot survive a null there
    // fails on the ordinary case rather than an edge one.
    test(
      'parses the envelope, per-result barcode and a null quantity',
      () async {
        build(
          (_) => _envelope(
            count: 37,
            results: [
              _match(
                name: 'Oat drink',
                brand: 'Oatly, Oatly AB',
                quantity: 1,
                quantityUnit: 'l',
                barcode: '7394376616068',
              ),
              _match(name: 'Oat milk barista', barcode: '7394376615009'),
            ],
          ),
        );

        final result = await api.searchProductCatalog('oat milk');

        expect(result.count, 37);
        expect(result.countIsLowerBound, isFalse);
        expect(result.attribution, contains('Open Food Facts'));
        expect(result.results, hasLength(2));

        final first = result.results.first;
        expect(first.barcode, '7394376616068');
        expect(first.quantity, 1);
        expect(first.quantityUnit, 'l');
        // Comma-joined free text, kept exactly as it arrived.
        expect(first.brand, 'Oatly, Oatly AB');
        expect(productPackSizeLabel(first), '1 l');

        final second = result.results.last;
        expect(second.barcode, '7394376615009');
        expect(second.quantity, isNull);
        expect(productPackSizeLabel(second), isNull);
      },
    );

    // A response from before the field existed must read as "no code here",
    // not blow up the whole page of results.
    test('tolerates a result with no barcode at all', () async {
      build((_) {
        final json = _match();
        json.remove('barcode');
        return _envelope(results: [json]);
      });

      final result = await api.searchProductCatalog('shampoo');

      expect(result.results.single.barcode, isNull);
    });

    // Asking in French and being answered in German is normal and is not an
    // error: the name is still one a person can read off the packet, and
    // dropping it costs them the typing this feature exists to save.
    test('keeps a result whose language is not the one asked for', () async {
      build(
        (_) => _envelope(
          results: [
            _match(name: 'Haferdrink', language: 'de', brand: 'Migros'),
          ],
        ),
      );

      final result = await api.searchProductCatalog(
        'avoine',
        acceptLanguage: 'fr-CH',
      );

      expect(result.results, hasLength(1));
      expect(result.results.single.language, 'de');
      expect(result.results.single.name, 'Haferdrink');
    });

    test('an empty result set is a success, not a failure', () async {
      build((_) => _envelope(query: 'm-budget', results: [], count: 0));

      final result = await api.searchProductCatalog('m-budget');

      expect(result.isEmpty, isTrue);
      expect(result.count, 0);
    });
  });

  group('countLabel', () {
    test('renders a stopped count as 500+', () {
      const envelope = ProductCatalogSearchDto(
        count: 500,
        countIsLowerBound: true,
      );
      expect(envelope.countLabel, '500+');
    });

    test('renders an exact count bare', () {
      const envelope = ProductCatalogSearchDto(count: 37);
      expect(envelope.countLabel, '37');
    });
  });

  group('picker sheet', () {
    Widget host(ProductCatalogSearchFn search, {String query = 'shampoo'}) =>
        MaterialApp(
          home: Scaffold(
            body: ProductCatalogPickerSheet(
              initialQuery: query,
              search: search,
            ),
          ),
        );

    // The licence obliges crediting the source wherever one of its names is
    // shown. A missing credit renders perfectly and breaks nothing visible,
    // which is exactly why it needs a test rather than a review.
    testWidgets('renders the envelope attribution under the results', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          (query, {CancelToken? cancelToken}) async =>
              ProductCatalogSearchDto.fromJson(_envelope()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(
        find.text('Product data from Open Food Facts, ODbL 1.0'),
        findsOneWidget,
      );
      expect(find.text('Shampoo'), findsOneWidget);
      // Per-row source, which varies by database and is never hardcoded.
      expect(find.text('Open Food Facts'), findsOneWidget);
    });

    testWidgets('shows a name that came back in another language', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          (query, {CancelToken? cancelToken}) async =>
              ProductCatalogSearchDto.fromJson(
                _envelope(
                  results: [_match(name: 'Haferdrink', language: 'de')],
                ),
              ),
          query: 'avoine',
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Haferdrink'), findsOneWidget);
    });

    testWidgets('a lower-bound count reads 500+ in the header', (tester) async {
      await tester.pumpWidget(
        host(
          (query, {CancelToken? cancelToken}) async =>
              ProductCatalogSearchDto.fromJson(
                _envelope(count: 500, countIsLowerBound: true),
              ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('500+ matches'), findsOneWidget);
    });

    // "Not in our catalog" is the true statement; "no such product" is not,
    // and it is the one that stops somebody adding it by hand.
    testWidgets('an empty result set offers adding by hand', (tester) async {
      await tester.pumpWidget(
        host(
          (query, {CancelToken? cancelToken}) async =>
              ProductCatalogSearchDto.fromJson(
                _envelope(query: 'm-budget', results: [], count: 0),
              ),
          query: 'm-budget',
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(
        find.text('Nothing in the catalogue matches that'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Adding it by hand is completely normal'),
        findsOneWidget,
      );
    });

    testWidgets('does not search under three characters', (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        host((query, {CancelToken? cancelToken}) async {
          calls++;
          return ProductCatalogSearchDto.fromJson(_envelope());
        }, query: 'oa'),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(calls, 0);
      expect(find.text('Type a few more letters'), findsOneWidget);
    });

    // Two searches in flight means the slower, staler one can land last and
    // win. Only the newest may write to the list.
    testWidgets('a stale reply never overwrites a newer one', (tester) async {
      final gates = <String, Completer<ProductCatalogSearchDto>>{};
      await tester.pumpWidget(
        host((query, {CancelToken? cancelToken}) {
          final gate = Completer<ProductCatalogSearchDto>();
          gates[query] = gate;
          return gate.future;
        }, query: 'oat'),
      );
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'oat milk');
      await tester.pump(productCatalogDebounce + const Duration(seconds: 1));

      gates['oat milk']!.complete(
        ProductCatalogSearchDto.fromJson(
          _envelope(results: [_match(name: 'Oat drink')]),
        ),
      );
      await tester.pump();
      expect(find.text('Oat drink'), findsOneWidget);

      // The first, slower query finally lands. It must be ignored.
      gates['oat']!.complete(
        ProductCatalogSearchDto.fromJson(
          _envelope(results: [_match(name: 'Oat flakes')]),
        ),
      );
      await tester.pump();

      expect(find.text('Oat drink'), findsOneWidget);
      expect(find.text('Oat flakes'), findsNothing);
    });

    testWidgets('tapping a result returns it', (tester) async {
      ProductCatalogMatchDto? chosen;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  chosen = await showHouseSheetForTest(context);
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      await tester.tap(find.text('Shampoo'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(chosen?.name, 'Shampoo');
      expect(chosen?.barcode, '7610100000001');
    });
  });
}

/// The picker as a caller actually gets it - a modal sheet returning the chosen
/// match - with the network stubbed out.
Future<ProductCatalogMatchDto?> showHouseSheetForTest(BuildContext context) =>
    showModalBottomSheet<ProductCatalogMatchDto>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ProductCatalogPickerSheet(
        initialQuery: 'shampoo',
        search: (query, {CancelToken? cancelToken}) async =>
            ProductCatalogSearchDto.fromJson(_envelope()),
      ),
    );
