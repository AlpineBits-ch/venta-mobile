/// Where the user's own API key lives, and the record that they agreed to it
/// leaving the device.
///
/// Two things are stored here and they are deliberately separate. The **key** is
/// a credential: it is a secret the user pays money against, it goes in the
/// device keychain, and it exists on this device only. The **consent** is a fact
/// about a conversation that happened once - somebody was told, in words, that a
/// photograph of their kitchen would be sent to a named third party and would
/// not be covered by this app's end-to-end encryption, and they said yes.
///
/// Consent is recorded **per provider**, because it is not transferable.
/// Agreeing to send photographs to Anthropic is not agreeing to send them to
/// Google, and a user who switches provider in settings is a user who has not
/// yet been asked about the new one. Storing a single "AI consent" flag would
/// silently carry the first answer onto every later provider, which is the one
/// way this feature could reasonably be called deceptive.
///
/// Deleting a key does **not** clear the consent for that provider. The consent
/// records that a disclosure was made and accepted; rotating an expired key is
/// not a reason to make somebody read the same sheet again.
///
/// Nothing on this class is ever logged, and the key is never put on a state
/// object - it is fetched at the moment of use and passed straight into a
/// request body. See `AiProviderConfig`, which pointedly does not carry it, and
/// `docs/pantry-vision.md` §5.
library;

import '../storage/secure_storage_service.dart';
import 'ai_provider.dart';

class AiKeyStore {
  // The lint's suggested fix - an initializing formal - is not expressible
  // here: a named parameter cannot start with an underscore, and the field is
  // private because nothing outside this class should be reaching past it into
  // the keychain.
  // ignore: prefer_initializing_formals
  AiKeyStore({required SecureStorageService storage}) : _storage = storage;

  final SecureStorageService _storage;

  /// One entry per provider rather than one entry for "the" key, so that
  /// switching provider in settings and switching back does not cost the user
  /// their first key. BYOK users often hold two.
  static String _keyEntry(AiProvider provider) => 'ai_key_${provider.name}';

  static String _consentEntry(AiProvider provider) =>
      'ai_consent_${provider.name}';

  static const _providerEntry = 'ai_provider';
  static const _modelEntry = 'ai_model';

  /// Null when nothing is stored, and also null for a stored empty string - a
  /// field somebody cleared and saved must read as "no key", not as a key that
  /// every provider will reject with a 401 the UI then reports as "your key was
  /// rejected".
  Future<String?> readKey(AiProvider provider) async {
    final stored = await _storage.readAiSecret(_keyEntry(provider));
    return _orNullIfBlank(stored);
  }

  /// Trimmed on the way in. Keys are pasted, and a leading space or a trailing
  /// newline off a clipboard is invisible in the field and fatal at the header.
  Future<void> writeKey(AiProvider provider, String key) =>
      _storage.writeAiSecret(_keyEntry(provider), key.trim());

  Future<void> deleteKey(AiProvider provider) =>
      _storage.deleteAiSecret(_keyEntry(provider));

  Future<bool> hasKey(AiProvider provider) async =>
      await readKey(provider) != null;

  /// Which provider the user picked, plus its model. Null until configured.
  ///
  /// A stored provider with no stored model falls back to that provider's
  /// [AiProvider.defaultModel] rather than returning null, because the two
  /// values are written together and a half-written config is a bug that should
  /// degrade into a working request, not into "not configured".
  Future<AiProviderConfig?> readConfig() async {
    final provider = AiProvider.tryParse(
      await _storage.readAiSecret(_providerEntry),
    );
    // Also covers a provider that has been removed from the enum since it was
    // written - `tryParse` returns null and the user is asked to pick again,
    // which is the only honest outcome.
    if (provider == null) return null;

    final model = _orNullIfBlank(await _storage.readAiSecret(_modelEntry));
    return AiProviderConfig(
      provider: provider,
      model: model ?? provider.defaultModel,
    );
  }

  Future<void> writeConfig(AiProviderConfig config) async {
    await _storage.writeAiSecret(_providerEntry, config.provider.name);
    await _storage.writeAiSecret(_modelEntry, config.model.trim());
  }

  Future<bool> hasConsented(AiProvider provider) async =>
      await _storage.readAiSecret(_consentEntry(provider)) == '1';

  Future<void> recordConsent(AiProvider provider) =>
      _storage.writeAiSecret(_consentEntry(provider), '1');

  static String? _orNullIfBlank(String? raw) {
    final trimmed = raw?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  /// The default `Object.toString` prints the type and nothing else, which is
  /// what is wanted. Overriding it to be helpful is how a key ends up in a
  /// crash report, so this is stated rather than left to chance.
  @override
  String toString() => 'AiKeyStore';
}
