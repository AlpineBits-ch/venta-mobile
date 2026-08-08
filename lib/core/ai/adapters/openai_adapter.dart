/// OpenAI's half of the provider layer.
///
/// ## Why Chat Completions and not Responses
///
/// OpenAI's own documentation now leads with the Responses API and treats
/// `/v1/chat/completions` as the older surface, but Chat Completions is not
/// deprecated, still takes the current models, and is the one shape that every
/// OpenAI-compatible endpoint in existence also speaks. BYOK users point this
/// kind of setting at gateways, proxies and self-hosted stacks far more often
/// than they do at `api.openai.com` itself, and those all implement Chat
/// Completions. Moving to Responses would buy nothing this feature needs -
/// there is no conversation state, no tool loop, no streaming - and would cost
/// that compatibility.
///
/// Note that the two APIs disagree about how an image is attached: Responses
/// takes `{"type": "input_image", "image_url": "data:..."}` with a bare string,
/// Chat Completions takes `{"type": "image_url", "image_url": {"url": "..."}}`
/// with an object. Copying an example from the current docs into this file
/// produces a 400 that reads like the image was rejected.
library;

import 'dart:convert';

import '../ai_provider.dart';
import '../catalog_matcher.dart';
import '../pantry_vision_models.dart';

class OpenAiVisionAdapter implements JsonSchemaAdapter {
  const OpenAiVisionAdapter();

  /// Names the schema in the response format. Constrained by OpenAI to letters,
  /// digits, underscores and dashes.
  static const String schemaName = 'pantry_vision';

  @override
  AiProvider get provider => AiProvider.openai;

  @override
  Uri endpoint(VisionRequest request) =>
      Uri.parse('https://api.openai.com/v1/chat/completions');

  @override
  Map<String, String> headers(VisionRequest request) => {
    'Authorization': 'Bearer ${request.apiKey}',
    'content-type': 'application/json',
  };

  @override
  Map<String, Object?> buildBody(VisionRequest request) =>
      buildJsonBody(request, pantryVisionJsonSchema);

  /// The one body builder. [buildBody] is this with the pantry-vision schema;
  /// the catalog matcher passes its own. One function rather than two so that
  /// the strict-mode contract below cannot end up applying to one call and not
  /// the other.
  ///
  /// A request with no images is a text-only call - the loop emits nothing and
  /// the user message is the prompt alone, which is what the matcher sends.
  @override
  Map<String, Object?> buildJsonBody(
    VisionRequest request,
    Map<String, Object?> schema,
  ) => {
    'model': request.model,
    'messages': [
      {'role': 'system', 'content': request.systemPrompt},
      {
        'role': 'user',
        'content': [
          // Images before the instruction, matching the other two adapters. The
          // ordering matters less here than it does for Claude, but three
          // adapters that build the same conversation in three different orders
          // are three sets of results that cannot be compared.
          for (final image in request.images)
            {
              'type': 'image_url',
              'image_url': {
                'url':
                    'data:${image.mediaType};base64,${base64Encode(image.bytes)}',
              },
            },
          {'type': 'text', 'text': request.userPrompt},
        ],
      },
    ],
    'response_format': {
      'type': 'json_schema',
      'json_schema': {
        'name': schemaName,
        // Strict mode is what makes the schema a guarantee rather than a
        // suggestion, and it is the reason `additionalProperties: false` and a
        // fully-populated `required` are non-negotiable in every schema sent
        // through here - without them OpenAI rejects the request outright
        // rather than relaxing the constraint.
        'strict': true,
        'schema': schema,
      },
    },
  };

  @override
  PantryVisionResult parseResponse(Map<String, Object?> body) =>
      PantryVisionResult.parse(extractJson(body));

  /// Everything between the HTTP response and a decoded object, shared by both
  /// calls this adapter serves - including the refusal field, which is the one
  /// piece of this envelope that is easy to read as an empty answer.
  @override
  Map<String, Object?> extractJson(Map<String, Object?> body) {
    final error = body['error'];
    if (error is Map) {
      throw AiFailure(
        AiFailureKind.badResponse,
        detail: error['message']?.toString(),
      );
    }

    final choices = body['choices'];
    if (choices is! List || choices.isEmpty) {
      throw const AiFailure(
        AiFailureKind.badResponse,
        detail: 'No choices in the response.',
      );
    }

    final first = choices.first;
    if (first is! Map) {
      throw const AiFailure(
        AiFailureKind.badResponse,
        detail: 'Malformed choice in the response.',
      );
    }

    final message = first['message'];
    if (message is! Map) {
      throw const AiFailure(
        AiFailureKind.badResponse,
        detail: 'No message in the response.',
      );
    }

    // Structured outputs put a declined answer in its own field rather than in
    // the content, so a caller that only reads `content` sees an empty string
    // and reports a parse failure for what is actually a refusal - the one
    // failure the user can do something about by taking a different photo.
    final refusal = message['refusal'];
    if (refusal is String && refusal.trim().isNotEmpty) {
      throw AiFailure(AiFailureKind.refused, detail: refusal.trim());
    }

    final payload = message['content']?.toString();
    if (payload == null || payload.trim().isEmpty) {
      throw AiFailure(
        AiFailureKind.badResponse,
        detail: first['finish_reason'] == 'length'
            ? 'The response ran out of tokens before it said anything.'
            : 'No content in the response.',
      );
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(payload);
    } on FormatException catch (e) {
      throw AiFailure(
        AiFailureKind.badResponse,
        detail: first['finish_reason'] == 'length'
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
