/// Claude's half of the provider layer.
///
/// Two pure functions and a URL. Nothing in this file performs I/O, which is
/// what lets both halves be held to a recorded envelope in a test rather than
/// to a live account.
///
/// ## The two things here that are not obvious
///
/// **`max_tokens` is generous on purpose.** Extended thinking is on by default
/// on `claude-opus-5`, and `max_tokens` caps thinking *plus* output - so a
/// budget sized for the answer alone gets spent on reasoning and the JSON stops
/// halfway through an object. That failure does not announce itself: the
/// response is a 200 with a `max_tokens` stop reason and a `text` block that is
/// valid right up until it is not. Paired with `effort: "low"`, which keeps the
/// thinking short because reading labels off a shelf is not a reasoning problem.
///
/// **The refusal check comes before anything touches `content`.** Claude can
/// decline on a 200 with `stop_reason: "refusal"`, and the content array is
/// empty or partial when it does. Reaching for `content[0]` first turns a
/// perfectly explainable "the model would not describe that photo" into a range
/// error somewhere in a bloc.
library;

import 'dart:convert';

import '../ai_provider.dart';
import '../catalog_matcher.dart';
import '../pantry_vision_models.dart';

class AnthropicVisionAdapter implements JsonSchemaAdapter {
  const AnthropicVisionAdapter();

  /// Generous headroom for thinking plus output - see the file header. The
  /// answer itself is around 400 tokens; the rest of this is the margin that
  /// keeps a truncated object from being the normal outcome.
  static const int maxTokens = 8000;

  @override
  AiProvider get provider => AiProvider.anthropic;

  @override
  Uri endpoint(VisionRequest request) =>
      Uri.parse('https://api.anthropic.com/v1/messages');

  @override
  Map<String, String> headers(VisionRequest request) => {
    'x-api-key': request.apiKey,
    'anthropic-version': '2023-06-01',
    'content-type': 'application/json',
  };

  @override
  Map<String, Object?> buildBody(VisionRequest request) =>
      buildJsonBody(request, pantryVisionJsonSchema);

  /// The one body builder. [buildBody] is this with the pantry-vision schema;
  /// the catalog matcher passes its own. Kept as one function so a change to
  /// how this provider is addressed - a header, a token budget, the order of
  /// the content blocks - cannot apply to one of the two calls and not the
  /// other.
  ///
  /// A request with no images is a text-only call: the loop below simply emits
  /// nothing and the message is the prompt alone, which is what the matcher
  /// sends.
  @override
  Map<String, Object?> buildJsonBody(
    VisionRequest request,
    Map<String, Object?> schema,
  ) => {
    'model': request.model,
    'max_tokens': maxTokens,
    'system': request.systemPrompt,
    'output_config': {
      'effort': 'low',
      'format': {'type': 'json_schema', 'schema': schema},
    },
    'messages': [
      {
        'role': 'user',
        'content': [
          // Images first, then the instruction. Claude attends better to a
          // question asked *about* material it has already been shown than to
          // one asked before it, and with several photos the ordering is what
          // stops the instruction being read as applying only to the last.
          for (final image in request.images)
            {
              'type': 'image',
              'source': {
                'type': 'base64',
                'media_type': image.mediaType,
                'data': base64Encode(image.bytes),
              },
            },
          {'type': 'text', 'text': request.userPrompt},
        ],
      },
    ],
  };

  @override
  PantryVisionResult parseResponse(Map<String, Object?> body) =>
      PantryVisionResult.parse(extractJson(body));

  /// Everything between the HTTP response and a decoded object, shared by both
  /// calls this adapter serves. The refusal check, the hunt for the first
  /// *text* block and the truncation wording are all provider-specific enough
  /// that a second copy of them would drift within a release.
  @override
  Map<String, Object?> extractJson(Map<String, Object?> body) {
    final stopReason = body['stop_reason'];
    if (stopReason == 'refusal') {
      throw const AiFailure(
        AiFailureKind.refused,
        detail: 'The model declined to describe the photo.',
      );
    }

    // A 200 carrying an error envelope. Rare, but cheaper to handle than to
    // debug from a report that only says the parse failed.
    final error = body['error'];
    if (error is Map) {
      throw AiFailure(
        AiFailureKind.badResponse,
        detail: error['message']?.toString(),
      );
    }

    final content = body['content'];
    if (content is! List) {
      throw const AiFailure(
        AiFailureKind.badResponse,
        detail: 'No content in the response.',
      );
    }

    // The first *text* block, not the first block: with thinking on, the array
    // can open with a thinking block, and indexing position zero would hand the
    // decoder a paragraph of reasoning.
    String? payload;
    for (final block in content) {
      if (block is Map && block['type'] == 'text') {
        payload = block['text']?.toString();
        break;
      }
    }

    if (payload == null || payload.trim().isEmpty) {
      throw AiFailure(
        AiFailureKind.badResponse,
        detail: stopReason == 'max_tokens'
            ? 'The response ran out of tokens before it said anything.'
            : 'No text block in the response.',
      );
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(payload);
    } on FormatException catch (e) {
      throw AiFailure(
        AiFailureKind.badResponse,
        detail: stopReason == 'max_tokens'
            // The characteristic shape of a thinking budget eaten alive: valid
            // JSON that simply stops.
            ? 'The response was cut off mid-answer.'
            : e.message,
      );
    }

    if (decoded is! Map) {
      throw const AiFailure(
        AiFailureKind.badResponse,
        detail: 'The response was not a JSON object.',
      );
    }

    return Map<String, Object?>.from(decoded);
  }
}
