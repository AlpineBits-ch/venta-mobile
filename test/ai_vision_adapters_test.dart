import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:venta_mobile/core/ai/adapters/anthropic_adapter.dart';
import 'package:venta_mobile/core/ai/adapters/gemini_adapter.dart';
import 'package:venta_mobile/core/ai/adapters/openai_adapter.dart';
import 'package:venta_mobile/core/ai/ai_provider.dart';
import 'package:venta_mobile/core/ai/pantry_vision_models.dart';
import 'package:venta_mobile/core/ai/vision_image_prep.dart';

/// The provider layer, held to fixtures rather than to three live accounts.
///
/// Every mistake this file exists to catch is one that costs money to discover
/// any other way, and most of them do not look like failures. A schema sent in
/// the wrong dialect comes back as a 200 full of plausible rows with every
/// nullable field filled in with an invention. An API key put in the wrong
/// header is a 401 that reads exactly like a key the user typed wrong. Images
/// placed after the instruction still answer, just worse, and only across a
/// dozen photos. None of those show up in a smoke test at a cupboard; all of
/// them show up here.
///
/// The response envelopes below are hand-written to match what each provider
/// actually returns, including the parts that are easy to forget - a thinking
/// block ahead of the text block, a refusal in its own field, a `finishReason`
/// on a candidate that carries no content.
void main() {
  final images = [
    VisionImage(bytes: Uint8List.fromList([1, 2, 3, 4]), mediaType: 'image/jpeg'),
    VisionImage(bytes: Uint8List.fromList([5, 6, 7, 8]), mediaType: 'image/png'),
  ];

  VisionRequest request({List<VisionImage>? withImages}) => VisionRequest(
    model: 'test-model',
    apiKey: 'sk-test-key',
    images: withImages ?? images,
  );

  /// What the model is asked to produce, as it would come back on the wire.
  const modelPayload = '''
{
  "items": [
    {"name": "Oat milk", "brand": "Oatly", "size": "1", "unit": "l",
     "count": 3, "confidence": "high", "note": null},
    {"name": "Chopped tomatoes", "brand": null, "size": "400", "unit": "g",
     "count": 2, "confidence": "low", "note": "partly hidden"}
  ],
  "unreadable": 2
}
''';

  void expectTheSharedPayloadParsed(PantryVisionResult result) {
    expect(result.items, hasLength(2));
    expect(result.items.first.name, 'Oat milk');
    expect(result.items.first.count, 3);
    expect(result.items.first.brand, 'Oatly');
    expect(result.items.first.confidence, VisionConfidence.high);
    expect(result.items.last.name, 'Chopped tomatoes');
    expect(result.items.last.count, 2);
    expect(result.items.last.brand, isNull);
    expect(result.items.last.note, 'partly hidden');
    expect(result.unreadable, 2);
  }

  Matcher throwsFailure(AiFailureKind kind) => throwsA(
    isA<AiFailure>().having((f) => f.kind, 'kind', kind),
  );

  group('Anthropic', () {
    const adapter = AnthropicVisionAdapter();

    test('sends the key in x-api-key, with the pinned API version', () {
      final headers = adapter.headers(request());
      expect(headers['x-api-key'], 'sk-test-key');
      expect(headers['anthropic-version'], '2023-06-01');
      // The one header that must never appear on a third-party request.
      expect(headers.containsKey('Authorization'), isFalse);
    });

    test('puts every image ahead of the instruction', () {
      final body = adapter.buildBody(request());
      final message = (body['messages']! as List).single as Map;
      final content = message['content']! as List;

      expect(content, hasLength(3));
      expect((content[0] as Map)['type'], 'image');
      expect((content[1] as Map)['type'], 'image');
      expect((content[2] as Map)['type'], 'text');
    });

    test('encodes an image block the way the API expects it', () {
      final body = adapter.buildBody(request());
      final content =
          ((body['messages']! as List).single as Map)['content']! as List;
      final source = (content.first as Map)['source']! as Map;

      expect(source['type'], 'base64');
      expect(source['media_type'], 'image/jpeg');
      expect(source['data'], base64Encode(images.first.bytes));
    });

    test('forces the schema and leaves room for thinking plus output', () {
      final body = adapter.buildBody(request());
      final outputConfig = body['output_config']! as Map;
      final format = outputConfig['format']! as Map;

      expect(format['type'], 'json_schema');
      expect(format['schema'], same(pantryVisionJsonSchema));
      expect(outputConfig['effort'], 'low');
      // The budget covers thinking as well as the answer, so a figure sized for
      // the answer alone truncates the JSON mid-object.
      expect(body['max_tokens'], greaterThanOrEqualTo(4000));
      expect(body['system'], pantryVisionSystemPrompt);
    });

    test('reads the text block past a leading thinking block', () {
      final result = adapter.parseResponse({
        'id': 'msg_01',
        'type': 'message',
        'role': 'assistant',
        'model': 'claude-opus-5',
        'stop_reason': 'end_turn',
        'content': [
          {'type': 'thinking', 'thinking': 'Counting the front row...'},
          {'type': 'text', 'text': modelPayload},
        ],
      });

      expectTheSharedPayloadParsed(result);
    });

    test('a refusal is a refusal, not a crash on an empty content array', () {
      // The whole reason `stop_reason` is checked first: there is nothing at
      // index zero to read.
      expect(
        () => adapter.parseResponse({
          'id': 'msg_02',
          'type': 'message',
          'stop_reason': 'refusal',
          'content': <Object?>[],
        }),
        throwsFailure(AiFailureKind.refused),
      );
    });

    test('a truncated answer fails as a bad response, not a FormatException', () {
      expect(
        () => adapter.parseResponse({
          'stop_reason': 'max_tokens',
          'content': [
            {'type': 'text', 'text': '{"items": [{"name": "Oat mi'},
          ],
        }),
        throwsFailure(AiFailureKind.badResponse),
      );
    });

    test('an envelope of the wrong shape throws AiFailure, not a TypeError', () {
      expect(
        () => adapter.parseResponse({'content': 'not a list'}),
        throwsFailure(AiFailureKind.badResponse),
      );
      expect(
        () => adapter.parseResponse(const {}),
        throwsFailure(AiFailureKind.badResponse),
      );
      expect(
        () => adapter.parseResponse({
          'content': [
            {'type': 'text', 'text': '["not", "an", "object"]'},
          ],
        }),
        throwsFailure(AiFailureKind.badResponse),
      );
    });
  });

  group('OpenAI', () {
    const adapter = OpenAiVisionAdapter();

    test('sends the key as a bearer token', () {
      final headers = adapter.headers(request());
      expect(headers['Authorization'], 'Bearer sk-test-key');
      expect(headers.containsKey('x-api-key'), isFalse);
    });

    test('images go in as data URLs, ahead of the instruction', () {
      final body = adapter.buildBody(request());
      final messages = body['messages']! as List;
      final content = (messages[1] as Map)['content']! as List;

      expect((messages.first as Map)['role'], 'system');
      expect(content, hasLength(3));
      // The Chat Completions shape - an object with a `url`. The Responses API
      // takes `input_image` with a bare string, and copying that form here is a
      // 400 that reads as though the image itself was rejected.
      expect((content[0] as Map)['type'], 'image_url');
      expect(
        ((content[0] as Map)['image_url']! as Map)['url'],
        'data:image/jpeg;base64,${base64Encode(images.first.bytes)}',
      );
      expect(
        ((content[1] as Map)['image_url']! as Map)['url'],
        startsWith('data:image/png;base64,'),
      );
      expect((content[2] as Map)['type'], 'text');
    });

    test('asks for strict structured output against the shared schema', () {
      final format = adapter.buildBody(request())['response_format']! as Map;
      final schema = format['json_schema']! as Map;

      expect(format['type'], 'json_schema');
      expect(schema['strict'], isTrue);
      expect(schema['name'], OpenAiVisionAdapter.schemaName);
      // Sent unmodified: strict mode is what makes `additionalProperties: false`
      // and the full `required` list mandatory rather than optional.
      expect(schema['schema'], same(pantryVisionJsonSchema));
    });

    test('parses the message content', () {
      final result = adapter.parseResponse({
        'id': 'chatcmpl-1',
        'object': 'chat.completion',
        'model': 'gpt-5.6',
        'choices': [
          {
            'index': 0,
            'finish_reason': 'stop',
            'message': {
              'role': 'assistant',
              'content': modelPayload,
              'refusal': null,
            },
          },
        ],
      });

      expectTheSharedPayloadParsed(result);
    });

    test('a refusal arrives in its own field and is reported as one', () {
      // Content is empty here. Read only `content` and this is a parse failure
      // the user cannot act on, instead of "take a different photo".
      expect(
        () => adapter.parseResponse({
          'choices': [
            {
              'finish_reason': 'stop',
              'message': {
                'role': 'assistant',
                'content': null,
                'refusal': 'I cannot help with that.',
              },
            },
          ],
        }),
        throwsFailure(AiFailureKind.refused),
      );
    });

    test('an envelope of the wrong shape throws AiFailure, not a TypeError', () {
      expect(
        () => adapter.parseResponse(const {'choices': <Object?>[]}),
        throwsFailure(AiFailureKind.badResponse),
      );
      expect(
        () => adapter.parseResponse(const {'choices': 'nope'}),
        throwsFailure(AiFailureKind.badResponse),
      );
      expect(
        () => adapter.parseResponse({
          'choices': [
            {
              'message': {'content': 'Sure! Here you go: {items: '},
            },
          ],
        }),
        throwsFailure(AiFailureKind.badResponse),
      );
    });
  });

  group('Gemini', () {
    const adapter = GeminiVisionAdapter();

    test('sends the key in a header, never in the query string', () {
      final headers = adapter.headers(request());
      expect(headers['x-goog-api-key'], 'sk-test-key');
      expect(adapter.endpoint(request()).query, isEmpty);
      expect(adapter.endpoint(request()).toString(), isNot(contains('sk-test')));
    });

    test('the model goes in the path, with or without the models/ prefix', () {
      expect(
        adapter.endpoint(request()).toString(),
        'https://generativelanguage.googleapis.com/v1beta/models/'
        'test-model:generateContent',
      );
      expect(
        adapter
            .endpoint(
              VisionRequest(
                model: 'models/gemini-3.6-flash',
                apiKey: 'k',
                images: images,
              ),
            )
            .toString(),
        endsWith('/models/gemini-3.6-flash:generateContent'),
      );
    });

    test('inline image parts come before the instruction', () {
      final body = adapter.buildBody(request());
      final parts = ((body['contents']! as List).single as Map)['parts']! as List;

      expect(parts, hasLength(3));
      final first = (parts[0] as Map)['inline_data']! as Map;
      expect(first['mime_type'], 'image/jpeg');
      expect(first['data'], base64Encode(images.first.bytes));
      expect((parts[1] as Map).containsKey('inline_data'), isTrue);
      expect((parts[2] as Map)['text'], isNotNull);
    });

    test('the system prompt goes in systemInstruction, not the user turn', () {
      final body = adapter.buildBody(request());
      final instruction = body['systemInstruction']! as Map;
      expect(
        ((instruction['parts']! as List).single as Map)['text'],
        pantryVisionSystemPrompt,
      );
    });

    test('asks for JSON and a schema together', () {
      final config = adapter.buildBody(request())['generationConfig']! as Map;
      // Schema without mime type is accepted and quietly ignored, and the answer
      // comes back as prose in a markdown fence.
      expect(config['responseMimeType'], 'application/json');
      expect(config['responseSchema'], isA<Map<String, Object?>>());
    });

    test('the converted schema drops additionalProperties everywhere', () {
      final converted =
          toGeminiSchema(pantryVisionJsonSchema)! as Map<String, Object?>;

      // Not a spot check - the field 400s wherever it appears, and this schema
      // carries it at two levels of nesting.
      expect(_findKey(converted, 'additionalProperties'), isFalse);
      expect(converted.containsKey('additionalProperties'), isFalse);

      final itemSchema =
          ((converted['properties']! as Map)['items']! as Map)['items']! as Map;
      expect(itemSchema.containsKey('additionalProperties'), isFalse);
      expect(itemSchema['required'], contains('confidence'));
    });

    test('a nullable union becomes a concrete type plus nullable: true', () {
      final converted =
          toGeminiSchema(pantryVisionJsonSchema)! as Map<String, Object?>;
      final properties =
          (((converted['properties']! as Map)['items']! as Map)['items']!
                  as Map)['properties']!
              as Map;

      final brand = properties['brand']! as Map;
      expect(brand['type'], 'string');
      expect(brand['nullable'], isTrue);

      // A field that was never nullable must not acquire the flag - a nullable
      // name is a row the resolver silently drops.
      final name = properties['name']! as Map;
      expect(name['type'], 'string');
      expect(name.containsKey('nullable'), isFalse);

      final count = properties['count']! as Map;
      expect(count['type'], 'integer');
      expect(count.containsKey('nullable'), isFalse);

      // Enums are literal lists, not nested schemas.
      expect(
        (properties['confidence']! as Map)['enum'],
        ['high', 'medium', 'low'],
      );
    });

    test('a property named like a keyword is not rewritten as one', () {
      final converted =
          toGeminiSchema(const {
                'type': 'object',
                'properties': {
                  'type': {'type': 'string'},
                  'additionalProperties': {
                    'type': ['string', 'null'],
                  },
                },
              })!
              as Map<String, Object?>;

      final properties = converted['properties']! as Map;
      expect(properties.keys, containsAll(['type', 'additionalProperties']));
      expect((properties['additionalProperties']! as Map)['nullable'], isTrue);
    });

    test('parses the first text part of the first candidate', () {
      final result = adapter.parseResponse({
        'candidates': [
          {
            'finishReason': 'STOP',
            'content': {
              'role': 'model',
              'parts': [
                {'text': modelPayload},
              ],
            },
          },
        ],
        'usageMetadata': {'promptTokenCount': 1620},
      });

      expectTheSharedPayloadParsed(result);
    });

    test('a blocked prompt is a refusal, not an empty candidate list', () {
      expect(
        () => adapter.parseResponse(const {
          'candidates': <Object?>[],
          'promptFeedback': {'blockReason': 'SAFETY'},
        }),
        throwsFailure(AiFailureKind.refused),
      );
      expect(
        () => adapter.parseResponse(const {
          'candidates': [
            {'finishReason': 'PROHIBITED_CONTENT'},
          ],
        }),
        throwsFailure(AiFailureKind.refused),
      );
    });

    test('an envelope of the wrong shape throws AiFailure, not a TypeError', () {
      expect(
        () => adapter.parseResponse(const {'candidates': 'nope'}),
        throwsFailure(AiFailureKind.badResponse),
      );
      expect(
        () => adapter.parseResponse(const {
          'candidates': [
            {
              'content': {
                'parts': [
                  {'text': 'Here is the list: 1. Oat milk'},
                ],
              },
            },
          ],
        }),
        throwsFailure(AiFailureKind.badResponse),
      );
    });
  });

  _imagePreparationTests();
}

void _imagePreparationTests() {
  group('image preparation', () {
    test('brings the long edge down to the limit and re-encodes as JPEG', () {
      final source = img.Image(width: 2000, height: 1500);
      final prepared = prepareVisionImage(img.encodePng(source));

      expect(prepared.mediaType, 'image/jpeg');
      final decoded = img.decodeJpg(prepared.bytes)!;
      expect(decoded.width, kVisionLongEdgeDefault);
      // Aspect ratio held. A resize that squares the photo off is a shelf the
      // model reads at the wrong proportions and counts badly.
      expect(decoded.height, (kVisionLongEdgeDefault * 0.75).round());
    });

    test('detail mode is the cost knob and it is bigger', () {
      final png = img.encodePng(img.Image(width: 4000, height: 3000));
      expect(
        img.decodeJpg(
          prepareVisionImage(png, longEdge: kVisionLongEdgeDetailed).bytes,
        )!.width,
        kVisionLongEdgeDetailed,
      );
    });

    test('an image already under the limit is not enlarged', () {
      final prepared = prepareVisionImage(
        img.encodePng(img.Image(width: 100, height: 80)),
      );
      expect(img.decodeJpg(prepared.bytes)!.width, 100);
    });

    test('bytes that are not an image are passed through, not thrown at', () {
      // The failure this exists for: `decodeImage` sniffs the format by trying
      // decoders in turn, and one of them reads a header off the end of a short
      // buffer - so junk arrives as a RangeError rather than as a null, on the
      // one screen that has a live camera on it.
      final prepared = prepareVisionImage(Uint8List.fromList([0, 1, 2, 3]));
      expect(prepared.bytes, hasLength(4));
      expect(prepared.mediaType, 'image/jpeg');
    });
  });
}

/// Whether [key] appears anywhere in a nested schema, at any depth.
bool _findKey(Object? node, String key) {
  if (node is List) return node.any((child) => _findKey(child, key));
  if (node is! Map) return false;
  if (node.containsKey(key)) return true;
  return node.values.any((child) => _findKey(child, key));
}
