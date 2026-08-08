/// The seam between "we want a photograph read" and "OpenAI, Google, or
/// Anthropic reads it".
///
/// Bring your own key: the user's key lives in the device keychain and the app
/// talks **straight to the provider**. Nothing here ever routes through
/// `api.venta.gg` - no photo, no key, no derived text. That is the whole
/// privacy claim of the feature and it is a property of this file: if a request
/// in here ever acquires a venta base URL, the claim is gone.
///
/// See `docs/pantry-vision.md`.
library;

import 'dart:typed_data';

import 'pantry_vision_models.dart';

enum AiProvider {
  anthropic,
  openai,
  gemini;

  /// What the user sees, and - more importantly - the name in the consent
  /// sheet. A person agreeing to send a photograph of their kitchen to a third
  /// party is entitled to that party's actual name.
  String get label => switch (this) {
    AiProvider.anthropic => 'Claude (Anthropic)',
    AiProvider.openai => 'OpenAI',
    AiProvider.gemini => 'Gemini (Google)',
  };

  /// Where to get a key, shown next to the empty field. Without this the
  /// setting is a dead end for anybody who has not already got one.
  String get keyUrl => switch (this) {
    AiProvider.anthropic => 'https://console.anthropic.com/settings/keys',
    AiProvider.openai => 'https://platform.openai.com/api-keys',
    AiProvider.gemini => 'https://aistudio.google.com/apikey',
  };

  /// The model used when the user has not chosen one.
  ///
  /// Editable in settings on purpose, and this list is the reason why: the
  /// first draft of this file shipped `gpt-5` and `gemini-3-pro`, neither of
  /// which exists any more - both would have 404'd on the very first photo.
  /// Verified against the providers' live model lists on 2026-08-08. Treat
  /// every entry here as stale until re-checked; the free-text field is what
  /// keeps a stale default from being a broken feature.
  String get defaultModel => switch (this) {
    AiProvider.anthropic => 'claude-opus-5',
    // Alias for the Sol variant - the flagship of the 5.6 line.
    AiProvider.openai => 'gpt-5.6',
    AiProvider.gemini => 'gemini-3.6-flash',
  };

  /// Alternatives offered as chips beside the model field, cheapest last. Not
  /// exhaustive and not validated - the field takes free text, because this
  /// list is stale the moment somebody ships a new model.
  List<String> get suggestedModels => switch (this) {
    AiProvider.anthropic => const [
      'claude-opus-5',
      'claude-sonnet-5',
      'claude-haiku-4-5',
    ],
    AiProvider.openai => const ['gpt-5.6', 'gpt-5.6-terra', 'gpt-5.6-luna'],
    AiProvider.gemini => const [
      'gemini-3.6-flash',
      'gemini-3.5-flash',
      'gemini-3.5-flash-lite',
    ],
  };

  static AiProvider? tryParse(String? raw) {
    for (final provider in AiProvider.values) {
      if (provider.name == raw) return provider;
    }
    return null;
  }
}

/// One configured provider: which one, which model. **The key is deliberately
/// not on this object** - it lives in the keychain and is fetched at the moment
/// of use, so it never rides along in state, gets copied into a bloc, or ends
/// up in a `toString()` somewhere in a log.
class AiProviderConfig {
  const AiProviderConfig({required this.provider, required this.model});

  final AiProvider provider;
  final String model;

  AiProviderConfig copyWith({AiProvider? provider, String? model}) =>
      AiProviderConfig(
        provider: provider ?? this.provider,
        model: model ?? this.model,
      );
}

/// A photograph, prepared for sending.
class VisionImage {
  const VisionImage({required this.bytes, required this.mediaType});

  final Uint8List bytes;

  /// `image/jpeg` or `image/png` - all three providers take both.
  final String mediaType;
}

/// Everything an adapter needs for one call. No `BuildContext`, no `getIt`, no
/// ambient state: an adapter is a pure translator, which is what makes both
/// halves of it testable against recorded fixtures.
class VisionRequest {
  const VisionRequest({
    required this.model,
    required this.apiKey,
    required this.images,
    this.systemPrompt = pantryVisionSystemPrompt,
    this.userPrompt = 'List what is in this photo.',
  });

  final String model;
  final String apiKey;
  final List<VisionImage> images;
  final String systemPrompt;
  final String userPrompt;
}

/// A provider adapter: two pure functions and the URL to send the first one to.
///
/// Implementations must not perform I/O. The caller owns the HTTP - one place
/// to put the timeout, the cancel token, and the certainty that no venta
/// interceptor is attached to it.
abstract class VisionAdapter {
  AiProvider get provider;

  Uri endpoint(VisionRequest request);

  Map<String, String> headers(VisionRequest request);

  /// The request body, as a JSON-encodable map.
  Map<String, Object?> buildBody(VisionRequest request);

  /// Pull the model's JSON payload out of the provider's envelope and parse it.
  ///
  /// Throws [AiFailure] for anything that is the provider's fault (a refusal,
  /// a truncated response, an envelope that does not contain what it should).
  /// Must never throw a raw `FormatException` or `TypeError` at the caller.
  PantryVisionResult parseResponse(Map<String, Object?> body);
}

/// Why a read failed, in terms the UI can turn into a sentence somebody can act
/// on. "Something went wrong" is not one of them: a rejected key and a rate
/// limit need completely different responses from the user, and collapsing them
/// is how a five-second fix becomes a support conversation.
enum AiFailureKind {
  /// No key stored for the configured provider - route to settings.
  notConfigured,

  /// The provider rejected the key (401/403).
  badKey,

  /// Rate limited or out of credit (429/402).
  rateLimited,

  /// The provider is down or returned a 5xx.
  providerDown,

  /// Reached the deadline, or the person cancelled.
  timeout,

  /// The response arrived but was not the shape it promised. Gets exactly one
  /// repair retry before it surfaces.
  badResponse,

  /// The model declined to answer. Rare here, but Claude Opus 5 can return a
  /// `refusal` stop reason on a 200, and a caller that reads `content[0]`
  /// unconditionally would crash rather than say so.
  refused,

  /// No usable network.
  offline,
}

class AiFailure implements Exception {
  const AiFailure(this.kind, {this.detail});

  final AiFailureKind kind;

  /// The provider's own words, when it gave any. Shown under the headline
  /// message rather than instead of it.
  final String? detail;

  /// The sentence the user reads.
  String message(AiProvider provider) => switch (kind) {
    AiFailureKind.notConfigured =>
      'No ${provider.label} key set up yet.',
    AiFailureKind.badKey =>
      '${provider.label} rejected that key.',
    AiFailureKind.rateLimited =>
      '${provider.label} is rate limiting this key, or it is out of credit.',
    AiFailureKind.providerDown =>
      '${provider.label} is not answering right now.',
    AiFailureKind.timeout => 'That took too long.',
    AiFailureKind.badResponse =>
      '${provider.label} sent something this app could not read.',
    AiFailureKind.refused =>
      '${provider.label} declined to describe that photo.',
    AiFailureKind.offline => 'No connection.',
  };

  @override
  String toString() => 'AiFailure(${kind.name}${detail == null ? '' : ': $detail'})';
}
