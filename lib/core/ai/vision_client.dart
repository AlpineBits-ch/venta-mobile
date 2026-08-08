/// The one place in this feature that touches a network.
///
/// ## The bare Dio is the privacy claim
///
/// This client constructs its own [Dio] and must never be handed the app's
/// `ApiClient`. That instance carries interceptors which attach the venta
/// access token, the device id and the venta base URL to every request that
/// passes through it - which is correct for every other call in the app and
/// catastrophic here. A shelf photograph going to OpenAI with a venta bearer
/// token stapled to it is a credential leak to a third party; the same request
/// picking up a venta base URL is somebody's kitchen arriving at
/// `api.venta.gg`, which is the exact thing `docs/pantry-vision.md` promises
/// does not happen.
///
/// The promise is a property of this file. It survives only as long as nobody
/// reaches for `getIt<ApiClient>()` here because it was convenient.
///
/// ## What it owns
///
/// Everything the adapters deliberately do not: the key lookup, one bounded
/// deadline, cancellation, the mapping from a status code to something the user
/// can act on, and the single repair retry. The adapters stay pure and
/// fixture-testable because all of it lives here.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import 'adapters/anthropic_adapter.dart';
import 'adapters/gemini_adapter.dart';
import 'adapters/openai_adapter.dart';
import 'ai_key_store.dart';
import 'ai_provider.dart';
import 'catalog_matcher.dart';
import 'pantry_vision_models.dart';

/// Typed as [JsonSchemaAdapter] rather than [VisionAdapter] because this client
/// makes two different calls through the same adapter - a photo read and a
/// catalog match - and only the wider surface can express the second. Every
/// implementation satisfies both.
JsonSchemaAdapter visionAdapterFor(AiProvider provider) => switch (provider) {
  AiProvider.anthropic => const AnthropicVisionAdapter(),
  AiProvider.openai => const OpenAiVisionAdapter(),
  AiProvider.gemini => const GeminiVisionAdapter(),
};

class PantryVisionClient {
  PantryVisionClient({required AiKeyStore keys, Dio? http})
    // A named parameter cannot start with an underscore, so the lint's
    // suggested initializing formal is not expressible here.
    // ignore: prefer_initializing_formals
    : _keys = keys,
      // A bare client with no interceptors and no base URL. See the header:
      // this is not a stylistic choice, it is the feature's privacy boundary.
      _http =
          http ??
          Dio(
            BaseOptions(
              connectTimeout: _deadline,
              sendTimeout: _deadline,
              receiveTimeout: _deadline,
              // Non-2xx is mapped by hand below rather than thrown at the
              // caller as a Dio error with a stack trace nobody can read.
              responseType: ResponseType.json,
            ),
          );

  final AiKeyStore _keys;
  final Dio _http;

  /// One deadline for the whole read, repair retry included.
  ///
  /// Per-attempt would be the easier thing to write and the wrong thing to
  /// ship: two thirty-second attempts is a minute of somebody holding a phone at
  /// a cupboard, which is indistinguishable from a hang and is how the feature
  /// gets closed rather than reported. A single vision call is 5-15s, so thirty
  /// seconds is already generous for the first one.
  static const _deadline = Duration(seconds: 30);

  /// Appended to the prompt on the one retry a malformed answer gets.
  ///
  /// Short on purpose. A long correction is a second instruction competing with
  /// the first, and the failure being repaired is a formatting slip, not a
  /// misunderstanding of the task.
  static const _repairInstruction =
      '\n\nYour previous reply could not be parsed. Reply with only the JSON '
      'object described by the schema - no prose, no markdown fences, nothing '
      'before or after it.';

  Future<PantryVisionResult> read(
    List<VisionImage> images, {
    CancelToken? cancelToken,
  }) async {
    // Nothing to look at. Guarded rather than sent, because a vision request
    // with no image is a call the user pays for whose only possible output is
    // an invented shelf.
    if (images.isEmpty) return const PantryVisionResult(items: []);

    final config = await _keys.readConfig();
    if (config == null) {
      throw const AiFailure(AiFailureKind.notConfigured);
    }

    final apiKey = await _keys.readKey(config.provider);
    if (apiKey == null) {
      throw const AiFailure(AiFailureKind.notConfigured);
    }

    final adapter = visionAdapterFor(config.provider);
    final request = VisionRequest(
      model: config.model,
      apiKey: apiKey,
      images: images,
    );

    // Our own token, so the deadline can cancel the request in flight rather
    // than abandon a socket that keeps uploading a photograph nobody is waiting
    // for any more. A caller's cancel is chained onto it.
    final token = CancelToken();
    unawaited(
      cancelToken?.whenCancel.then((_) {
        if (!token.isCancelled) token.cancel('cancelled by the caller');
      }),
    );

    try {
      return await _withRepair(
        adapter,
        request,
        token,
        pantryVisionJsonSchema,
        adapter.parseResponse,
      ).timeout(
        _deadline,
        onTimeout: () {
          if (!token.isCancelled) token.cancel('deadline');
          throw const AiFailure(AiFailureKind.timeout);
        },
      );
    } on TimeoutException {
      // Belt and braces: `onTimeout` above throws, so this is only reachable if
      // something below rethrows one of its own.
      throw const AiFailure(AiFailureKind.timeout);
    }
  }

  /// Rung 3 of the resolution ladder: asks the model which of the catalog rows
  /// our own search returned is the product it read off the shelf.
  ///
  /// **This never throws, and that is part of the contract rather than
  /// defensiveness.** It is the *second* call in a pipeline whose first call
  /// already cost the user a photograph, fifteen seconds and real money. Losing
  /// all of that because an optional refinement rate-limited, or because the key
  /// was cleared between the two calls, would be absurd - so every failure
  /// [AiFailure] can describe degrades to [CatalogMatchChoice.abstainAll], which
  /// is a perfectly usable answer: every row arrives at review as "pick one",
  /// with the picker a tap away and the search pre-filled. That is exactly what
  /// the user would have had if this feature did not exist.
  ///
  /// The model's answer is a set of *indices* into the lists in [items]. It has
  /// no way to name a product other than by position and no field to put a code
  /// in - see `catalog_matcher.dart`, which owns that guarantee. Nothing here is
  /// written anywhere; a match is a pre-filled suggestion that somebody still
  /// confirms.
  Future<List<CatalogMatchChoice>> matchCatalog(
    List<CatalogMatchCandidates> items, {
    CancelToken? cancelToken,
  }) async {
    // Nothing to choose between. Guarded rather than sent, for the same reason
    // an imageless read is: the answer is already known and the call would be
    // paid for.
    if (!items.any((item) => item.hasCandidates)) {
      return CatalogMatchChoice.abstainAll(items);
    }

    final config = await _keys.readConfig();
    if (config == null) return CatalogMatchChoice.abstainAll(items);

    final apiKey = await _keys.readKey(config.provider);
    if (apiKey == null) return CatalogMatchChoice.abstainAll(items);

    final adapter = visionAdapterFor(config.provider);
    final request = VisionRequest(
      model: config.model,
      apiKey: apiKey,
      // No photograph. The proposal has already been read out of one; sending it
      // again would double the cost of the shelf to re-ask a text question.
      images: const [],
      systemPrompt: catalogMatchSystemPrompt,
      userPrompt: buildCatalogMatchPrompt(items),
    );

    final token = CancelToken();
    unawaited(
      cancelToken?.whenCancel.then((_) {
        if (!token.isCancelled) token.cancel('cancelled by the caller');
      }),
    );

    try {
      return await _withRepair(
        adapter,
        request,
        token,
        catalogMatchJsonSchema,
        (body) => parseCatalogMatchResponse(adapter.extractJson(body), items),
      ).timeout(
        _deadline,
        onTimeout: () {
          if (!token.isCancelled) token.cancel('deadline');
          throw const AiFailure(AiFailureKind.timeout);
        },
      );
    } on AiFailure {
      return CatalogMatchChoice.abstainAll(items);
    } on TimeoutException {
      return CatalogMatchChoice.abstainAll(items);
    }
  }

  /// Generic in what it parses so that both calls share one copy of the repair
  /// rule. The rule itself is the thing worth having only once - it is what
  /// decides which failures cost the user a second request.
  Future<T> _withRepair<T>(
    JsonSchemaAdapter adapter,
    VisionRequest request,
    CancelToken token,
    Map<String, Object?> schema,
    T Function(Map<String, Object?> body) parse,
  ) async {
    try {
      return await _attempt(adapter, request, token, schema, parse);
    } on AiFailure catch (failure) {
      // Exactly one repair, and only for a response that arrived and was wrong.
      // A rejected key or a rate limit does not get better by being asked twice,
      // and retrying either one costs the user real money or real time for a
      // certain second failure.
      if (failure.kind != AiFailureKind.badResponse || token.isCancelled) {
        rethrow;
      }

      return _attempt(
        adapter,
        VisionRequest(
          model: request.model,
          apiKey: request.apiKey,
          images: request.images,
          systemPrompt: request.systemPrompt,
          userPrompt: '${request.userPrompt}$_repairInstruction',
        ),
        token,
        schema,
        parse,
      );
    }
  }

  Future<T> _attempt<T>(
    JsonSchemaAdapter adapter,
    VisionRequest request,
    CancelToken token,
    Map<String, Object?> schema,
    T Function(Map<String, Object?> body) parse,
  ) async {
    final Response<Object?> response;
    try {
      response = await _http.requestUri<Object?>(
        adapter.endpoint(request),
        data: adapter.buildJsonBody(request, schema),
        cancelToken: token,
        options: Options(
          method: 'POST',
          headers: adapter.headers(request),
          responseType: ResponseType.json,
          sendTimeout: _deadline,
          receiveTimeout: _deadline,
        ),
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }

    final body = _asJsonMap(response.data);
    if (body == null) {
      throw const AiFailure(
        AiFailureKind.badResponse,
        detail: 'The response was not a JSON object.',
      );
    }

    try {
      return parse(body);
    } on AiFailure {
      rethrow;
    } catch (e) {
      // The adapters are written not to leak a raw `TypeError`, but this is the
      // seam where one would reach a bloc and become an unhandled exception in
      // a screen that had a perfectly good error state to show instead.
      throw AiFailure(AiFailureKind.badResponse, detail: e.toString());
    }
  }

  AiFailure _mapDioException(DioException e) => switch (e.type) {
    DioExceptionType.badResponse => _mapStatus(e.response),
    DioExceptionType.connectionError => const AiFailure(AiFailureKind.offline),
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.transformTimeout ||
    // A cancel is either the deadline or the person, and both of those are the
    // same sentence on screen.
    DioExceptionType.cancel => const AiFailure(AiFailureKind.timeout),
    DioExceptionType.badCertificate => const AiFailure(
      AiFailureKind.providerDown,
      detail: 'The provider presented a certificate this device would not '
          'accept.',
    ),
    // Dio buries a genuine "no network" here as often as it reports one.
    DioExceptionType.unknown =>
      e.error is SocketException
          ? const AiFailure(AiFailureKind.offline)
          : AiFailure(AiFailureKind.providerDown, detail: e.message),
  };

  AiFailure _mapStatus(Response<Object?>? response) {
    final status = response?.statusCode ?? 0;
    final detail = _providerMessage(response?.data);

    // 402 sits with 429 rather than with the other 4xx on purpose: "out of
    // credit" and "too many requests" are the same problem from the user's
    // side - the key is fine, the account cannot spend right now - and they
    // want the same sentence and the same suggestion.
    return switch (status) {
      401 || 403 => AiFailure(AiFailureKind.badKey, detail: detail),
      402 || 429 => AiFailure(AiFailureKind.rateLimited, detail: detail),
      >= 500 => AiFailure(AiFailureKind.providerDown, detail: detail),
      // Everything else that arrived: a bad model id, an oversized image, a
      // schema the provider would not take. All of them are "the request was
      // wrong", and all of them are worth showing the provider's own words for,
      // because ours would be a guess.
      _ => AiFailure(AiFailureKind.badResponse, detail: detail),
    };
  }

  /// All three providers put a human-readable reason at `error.message`.
  static String? _providerMessage(Object? data) {
    final body = _asJsonMap(data);
    final error = body?['error'];
    if (error is Map) {
      final message = error['message']?.toString().trim();
      if (message != null && message.isNotEmpty) return message;
    }
    if (error is String && error.trim().isNotEmpty) return error.trim();
    return null;
  }

  /// Dio hands back a decoded map when the provider sets a JSON content type
  /// and a raw string when it does not - and a provider returning an error page
  /// under `text/html` is exactly the case that must not crash on a cast.
  static Map<String, Object?>? _asJsonMap(Object? data) {
    if (data is Map) return Map<String, Object?>.from(data);
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) return Map<String, Object?>.from(decoded);
      } on FormatException {
        return null;
      }
    }
    return null;
  }
}
