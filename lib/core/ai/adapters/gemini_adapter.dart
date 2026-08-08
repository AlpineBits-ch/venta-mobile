/// Gemini's half of the provider layer.
///
/// ## Why `generateContent` and not the Interactions API
///
/// Google's current documentation leads with an Interactions API
/// (`POST /v1beta/interactions`, a flat `input` array, a `response_format`
/// object) and labels `generateContent` the legacy surface. `generateContent`
/// is still documented, still serves the current models, and is still what the
/// overwhelming majority of Gemini-compatible tooling speaks - and this feature
/// uses none of what the new API adds. It is worth revisiting when a model the
/// user wants is Interactions-only; until then the older endpoint is the one
/// with the wider reach and no migration to pay for.
///
/// ## The schema dialect is the trap
///
/// `generationConfig.responseSchema` is **not** JSON Schema. It is Google's own
/// OpenAPI-derived `Schema` type, and it differs from the schema the other two
/// adapters send in exactly the two ways this app's schema uses:
///
/// * it has no `additionalProperties` - depending on the model and API version
///   the field is either ignored or rejected outright with a 400, and the 400
///   reads like the request was malformed rather than the schema;
/// * nullability is a separate `"nullable": true` flag on the property, not a
///   `"type": ["string", "null"]` union. Send the union and the field either
///   fails validation or silently becomes a required non-null string, which is
///   how `brand: null` turns into `brand: "unknown"` across every row.
///
/// So [toGeminiSchema] translates rather than this file keeping a second copy of
/// the schema. One schema with a converter cannot drift; two schemas will.
library;

import 'dart:convert';

import '../ai_provider.dart';
import '../catalog_matcher.dart';
import '../pantry_vision_models.dart';

class GeminiVisionAdapter implements JsonSchemaAdapter {
  const GeminiVisionAdapter();

  @override
  AiProvider get provider => AiProvider.gemini;

  @override
  Uri endpoint(VisionRequest request) => Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models/'
    '${_modelId(request.model)}:generateContent',
  );

  /// The key goes in a header, never in the `?key=` query parameter Google's
  /// quickstarts still show. A query string is the one part of a request that
  /// ends up in proxy logs, crash breadcrumbs and error messages verbatim.
  @override
  Map<String, String> headers(VisionRequest request) => {
    'x-goog-api-key': request.apiKey,
    'content-type': 'application/json',
  };

  @override
  Map<String, Object?> buildBody(VisionRequest request) =>
      buildJsonBody(request, pantryVisionJsonSchema);

  /// The one body builder. [buildBody] is this with the pantry-vision schema;
  /// the catalog matcher passes its own, and it goes through the same
  /// [toGeminiSchema] translation - which is the point of routing both calls
  /// through here, since a second schema sent in JSON Schema's dialect would
  /// come back as a 200 full of inventions rather than as an error.
  ///
  /// A request with no images is a text-only call: the loop emits nothing and
  /// the single part is the prompt.
  @override
  Map<String, Object?> buildJsonBody(
    VisionRequest request,
    Map<String, Object?> schema,
  ) => {
    'systemInstruction': {
      'parts': [
        {'text': request.systemPrompt},
      ],
    },
    'contents': [
      {
        'role': 'user',
        'parts': [
          // Images before the instruction, as in the other two adapters.
          for (final image in request.images)
            {
              'inline_data': {
                'mime_type': image.mediaType,
                'data': base64Encode(image.bytes),
              },
            },
          {'text': request.userPrompt},
        ],
      },
    ],
    'generationConfig': {
      // Both fields, always. `responseSchema` without `responseMimeType` is
      // accepted and then ignored, and the answer comes back as prose wrapped
      // in a markdown fence.
      'responseMimeType': 'application/json',
      'responseSchema': toGeminiSchema(schema),
    },
  };

  @override
  PantryVisionResult parseResponse(Map<String, Object?> body) =>
      PantryVisionResult.parse(extractJson(body));

  /// Everything between the HTTP response and a decoded object, shared by both
  /// calls this adapter serves - including the blocked-prompt check, which has
  /// to happen before the candidate list is indexed rather than as an
  /// explanation for why the list was empty.
  @override
  Map<String, Object?> extractJson(Map<String, Object?> body) {
    final error = body['error'];
    if (error is Map) {
      throw AiFailure(
        AiFailureKind.badResponse,
        detail: error['message']?.toString(),
      );
    }

    // A blocked *prompt* comes back as a 200 with no candidates at all, so this
    // has to be checked before the candidate list is indexed rather than as an
    // explanation for why the list was empty.
    final feedback = body['promptFeedback'];
    if (feedback is Map && feedback['blockReason'] != null) {
      throw AiFailure(
        AiFailureKind.refused,
        detail: feedback['blockReason']?.toString(),
      );
    }

    final candidates = body['candidates'];
    if (candidates is! List || candidates.isEmpty) {
      throw const AiFailure(
        AiFailureKind.badResponse,
        detail: 'No candidates in the response.',
      );
    }

    final candidate = candidates.first;
    if (candidate is! Map) {
      throw const AiFailure(
        AiFailureKind.badResponse,
        detail: 'Malformed candidate in the response.',
      );
    }

    final finishReason = candidate['finishReason']?.toString();
    if (finishReason != null && _refusalReasons.contains(finishReason)) {
      throw AiFailure(AiFailureKind.refused, detail: finishReason);
    }

    final content = candidate['content'];
    final parts = content is Map ? content['parts'] : null;
    String? payload;
    if (parts is List) {
      for (final part in parts) {
        if (part is Map && part['text'] != null) {
          payload = part['text']?.toString();
          break;
        }
      }
    }

    if (payload == null || payload.trim().isEmpty) {
      throw AiFailure(
        AiFailureKind.badResponse,
        detail: finishReason == 'MAX_TOKENS'
            ? 'The response ran out of tokens before it said anything.'
            : 'No text part in the response.',
      );
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(payload);
    } on FormatException catch (e) {
      throw AiFailure(
        AiFailureKind.badResponse,
        detail: finishReason == 'MAX_TOKENS'
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

  /// Everything Gemini reports when it has declined rather than failed. Kept
  /// apart from the bad-response path because the two need opposite things from
  /// the user - retry the same photo, or take a different one.
  static const _refusalReasons = {
    'SAFETY',
    'BLOCKLIST',
    'PROHIBITED_CONTENT',
    'IMAGE_SAFETY',
    'RECITATION',
    'SPII',
  };

  /// A model the user typed as `models/gemini-3.6-flash` is the same model. The
  /// field is free text on purpose (model names churn), so the one paste people
  /// actually make is normalised here rather than being a 404 that reads as
  /// "that model does not exist".
  static String _modelId(String model) {
    final trimmed = model.trim();
    return trimmed.startsWith('models/')
        ? trimmed.substring('models/'.length)
        : trimmed;
  }
}

/// Rewrites a JSON Schema into Gemini's `Schema` dialect.
///
/// Two rules, both explained in this file's header: `additionalProperties` is
/// dropped, and a `["string", "null"]` union becomes the concrete type plus
/// `"nullable": true`.
///
/// Property *names* are routed around the keyword handling deliberately. A
/// schema whose object has a property literally called `type` or
/// `additionalProperties` is legal, and a converter that recursed blindly over
/// every map would rewrite that property's name as though it were a keyword.
/// This app's schema has no such property today; the next one to be added might.
Object? toGeminiSchema(Object? node) {
  if (node is List) return node.map(toGeminiSchema).toList();
  if (node is! Map) return node;

  final out = <String, Object?>{};
  var nullable = false;

  for (final entry in node.entries) {
    final key = entry.key.toString();
    final value = entry.value;

    switch (key) {
      // Not part of the dialect. Sent anyway it is either ignored or 400s, and
      // the 400 does not say which field it was about.
      case 'additionalProperties':
        continue;

      case 'type':
        if (value is List) {
          final types = value.map((e) => e.toString()).toList();
          nullable = types.contains('null');
          out['type'] = types.firstWhere(
            (t) => t != 'null',
            // A property declared as nothing but null is meaningless here;
            // calling it a string keeps the rest of the schema valid rather
            // than sending a `type` Gemini will reject.
            orElse: () => 'string',
          );
        } else {
          out['type'] = value;
        }

      // Lists of literals, not lists of schemas.
      case 'required':
      case 'enum':
        out[key] = value;

      // Keys here are property names chosen by whoever wrote the schema, so
      // only the values are converted.
      case 'properties':
        if (value is Map) {
          out[key] = <String, Object?>{
            for (final property in value.entries)
              property.key.toString(): toGeminiSchema(property.value),
          };
        } else {
          out[key] = value;
        }

      default:
        out[key] = toGeminiSchema(value);
    }
  }

  if (nullable) out['nullable'] = true;
  return out;
}
