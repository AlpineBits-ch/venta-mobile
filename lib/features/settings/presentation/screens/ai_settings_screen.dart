import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/ai/ai_key_store.dart';
import '../../../../core/ai/ai_provider.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/settings_tiles.dart';

/// Bring-your-own-key AI: which company gets to look at a photograph of your
/// cupboard, which model of theirs, and the key that pays for it.
///
/// Everything on this page is per device and per account. The key is written to
/// the keychain and nowhere else - not to `api.venta.gg`, not into a channel,
/// not into the household. That last part is the reason this is a *settings*
/// page rather than a house setting: a shared configuration would mean one
/// person's card silently paying for everybody else's photographs.
///
/// Three decisions here look like polish and are not:
///
/// **The stored key is never rendered back into the field.** It is read once to
/// build a `sk-…4f2a` hint - enough to tell two keys apart, useless to anybody
/// reading over a shoulder - and then dropped. A settings page that will show
/// you the secret on request is a settings page that shows it to whoever is
/// holding the phone.
///
/// **The model is free text.** Model names churn on a timescale of weeks and
/// BYOK users routinely have access to something the picker would not list.
/// The chips are a convenience, not the set of legal values.
///
/// **The footnote says what actually happens.** This app encrypts messages
/// end-to-end; a photograph sent to a model provider is not covered by that and
/// must never be presented as though it were. The full disclosure is repeated -
/// not merely linked - in [ensureVisionConsent], which fires before the first
/// photo ever leaves the device.
class AiSettingsScreen extends StatefulWidget {
  const AiSettingsScreen({super.key});

  @override
  State<AiSettingsScreen> createState() => _AiSettingsScreenState();
}

class _AiSettingsScreenState extends State<AiSettingsScreen> {
  /// Where the app lands somebody who has never opened this page. Anthropic
  /// because its request shape is the one verified against current reference
  /// docs, so it is the configuration most likely to work first time.
  static const _fallbackProvider = AiProvider.anthropic;

  final _keys = getIt<AiKeyStore>();
  final _keyController = TextEditingController();
  final _modelController = TextEditingController();

  /// Replaced by [_load] before anything is drawn - the screen renders a
  /// spinner until then - but not nullable, so every read below is one branch
  /// shorter.
  AiProviderConfig _config = AiProviderConfig(
    provider: _fallbackProvider,
    model: _fallbackProvider.defaultModel,
  );
  bool _loading = true;

  /// A hint derived from the stored key, or null when there isn't one. Holds
  /// the mask, never the key - see the class doc.
  String? _keyHint;

  /// Whether the entry field is on screen. False once a key is stored, so the
  /// normal state of a configured page is "a key is set", not an empty box that
  /// looks like it lost something.
  bool _entering = false;

  bool _busy = false;

  /// Debounces persisting the model field. Typing a model name is a dozen
  /// keystrokes and each one would otherwise be a keychain write; waiting for a
  /// Save button instead would silently lose the value of anybody who typed and
  /// then hit back, which is most people.
  Timer? _modelDebounce;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _modelDebounce?.cancel();
    _keyController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  AiProvider get _provider => _config.provider;

  Future<void> _load() async {
    final stored = await _keys.readConfig();
    final config =
        stored ??
        AiProviderConfig(
          provider: _fallbackProvider,
          model: _fallbackProvider.defaultModel,
        );
    if (stored == null) {
      // Persist the fallback rather than only displaying it. `_setProvider`
      // no-ops when the tapped provider is already the shown one, so without
      // this a user who accepts the default, pastes a key and leaves has a key
      // stored under a provider `readConfig()` still reports as unset - and
      // every caller downstream says "not configured" over a working key.
      await _keys.writeConfig(config);
    }
    if (!mounted) return;
    _config = config;
    _modelController.text = config.model;
    // The spinner stays up until the key hint is known too. Dropping it a frame
    // early renders the key card in its "no key" shape for one frame on a
    // device that has one, which reads as the key having been lost.
    await _refreshKeyHint();
    if (mounted) setState(() => _loading = false);
  }

  /// Reads the key purely to build the mask and lets it go again. The alternative
  /// - keeping a `bool hasKey` and showing "Key set" - loses the one thing the
  /// hint is for, which is telling a personal key from a work one at a glance.
  Future<void> _refreshKeyHint() async {
    final key = await _keys.readKey(_provider);
    if (!mounted) return;
    setState(() {
      _keyHint = (key == null || key.trim().isEmpty) ? null : maskApiKey(key);
      _entering = _keyHint == null;
    });
  }

  /// Switching provider resets the model to that provider's default.
  ///
  /// Carrying `claude-opus-5` across to OpenAI would produce a 404 from the
  /// provider and a "something went wrong" for the user, and there is only one
  /// model slot to remember - so the reset is the honest behaviour. Anyone with
  /// a specific model retypes it, which is one field.
  Future<void> _setProvider(AiProvider provider) async {
    if (provider == _provider) return;
    _modelDebounce?.cancel();
    final config = AiProviderConfig(
      provider: provider,
      model: provider.defaultModel,
    );
    setState(() {
      _config = config;
      _modelController.text = config.model;
      _keyHint = null;
      _keyController.clear();
    });
    await _keys.writeConfig(config);
    await _refreshKeyHint();
  }

  void _onModelChanged(String value) {
    _modelDebounce?.cancel();
    _modelDebounce = Timer(const Duration(milliseconds: 600), () {
      unawaited(_persistModel(value));
    });
  }

  Future<void> _persistModel(String value) async {
    // An empty field means "use the default" rather than "send no model at
    // all", which would be a request the provider rejects.
    final model = value.trim().isEmpty ? _provider.defaultModel : value.trim();
    final config = _config.copyWith(model: model);
    _config = config;
    await _keys.writeConfig(config);
  }

  Future<void> _useSuggestedModel(String model) async {
    _modelDebounce?.cancel();
    setState(() => _modelController.text = model);
    await _persistModel(model);
  }

  Future<void> _pasteKey() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text == null || text.isEmpty) {
      _toast('Nothing to paste.');
      return;
    }
    setState(() => _keyController.text = text);
  }

  Future<void> _saveKey() async {
    final key = _keyController.text.trim();
    if (key.isEmpty || _busy) return;
    setState(() => _busy = true);
    try {
      await _keys.writeKey(_provider, key);
      // Cleared immediately: the field has served its purpose and a key left
      // sitting in a text controller is a key in a screenshot.
      _keyController.clear();
      await _refreshKeyHint();
      _toast('Key saved on this device.');
    } catch (_) {
      _toast('Could not save that key to the keychain.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _removeKey() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove this key?'),
        content: Text(
          'The key is deleted from this device. Nothing is revoked at '
          '${_provider.label} - do that in their console if you need to.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _keys.deleteKey(_provider);
    await _refreshKeyHint();
    if (mounted) _toast('Key removed from this device.');
  }

  Future<void> _openKeyUrl() async {
    final uri = Uri.tryParse(_provider.keyUrl);
    if (uri == null) return;
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      // The URL is on screen in the row's subtitle either way, so a failure
      // here costs somebody a retype rather than the whole path to a key.
      _toast('Could not open ${_provider.keyUrl}');
    }
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackLocation: RoutePaths.settings),
        title: const Text('AI'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.m,
                AppSpacing.m,
                AppSpacing.m,
                AppSpacing.xl,
              ),
              children: [
                SettingsSection(
                  label: 'Provider',
                  children: [
                    for (final option in AiProvider.values)
                      SettingsRow(
                        icon: Icons.smart_toy_outlined,
                        title: option.label,
                        showChevron: false,
                        trailing: option == _provider
                            ? Icon(Icons.check, color: theme.colorScheme.primary)
                            : null,
                        onTap: () => unawaited(_setProvider(option)),
                      ),
                  ],
                ),
                const SettingsFootnote(
                  'One provider at a time. Keys are kept per provider, so '
                  'switching back does not lose the other one.',
                ),
                const SizedBox(height: AppSpacing.l),
                SettingsSection(
                  label: 'API key',
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    child: _keyEditor(theme),
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                SettingsSection(
                  children: [
                    SettingsRow(
                      icon: Icons.open_in_new,
                      title: 'Get a key from ${_provider.label}',
                      subtitle: _provider.keyUrl,
                      showChevron: false,
                      onTap: () => unawaited(_openKeyUrl()),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.l),
                SettingsSection(
                  label: 'Model',
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    child: _modelEditor(theme),
                  ),
                ),
                const SettingsFootnote(
                  'Free text on purpose - model names change often, and a key '
                  'may have access to one this list has never heard of. Leave '
                  'it empty to fall back to the default.',
                ),
                const SizedBox(height: AppSpacing.l),
                SettingsSection(
                  children: [
                    SettingsRow(
                      icon: Icons.photo_camera_outlined,
                      title: 'Try it on a photo',
                      subtitle: _keyHint == null
                          ? 'Needs a key first'
                          : 'Reads a shelf and shows what came back',
                      onTap: () => context.push(RoutePaths.pantryVisionHarness),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.l),
                _PrivacyNote(provider: _provider),
              ],
            ),
    );
  }

  Widget _keyEditor(ThemeData theme) {
    final hint = _keyHint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hint != null) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.key_outlined,
                size: 20,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: AppSpacing.s),
              // Expanded rather than a fixed-width value column: at 2.35x this
              // line is two or three rows tall and must wrap, not clip.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'A key is stored on this device',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          // Wrap so the two actions stack instead of overflowing once the text
          // scale pushes them past the card.
          Wrap(
            spacing: AppSpacing.s,
            children: [
              TextButton(
                onPressed: _busy
                    ? null
                    : () => setState(() => _entering = !_entering),
                child: Text(_entering ? 'Keep current key' : 'Replace key'),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
                onPressed: _busy ? null : () => unawaited(_removeKey()),
                child: const Text('Remove'),
              ),
            ],
          ),
        ],
        if (_entering) ...[
          if (hint != null) const SizedBox(height: AppSpacing.s),
          TextField(
            controller: _keyController,
            enabled: !_busy,
            // Obscured even while being typed: this gets entered standing in a
            // kitchen as often as anywhere else.
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              labelText: '${_provider.label} API key',
              hintText: 'Paste your key',
              suffixIcon: IconButton(
                icon: const Icon(Icons.content_paste, size: 20),
                tooltip: 'Paste key',
                onPressed: _busy ? null : () => unawaited(_pasteKey()),
              ),
            ),
            onSubmitted: (_) => unawaited(_saveKey()),
          ),
          const SizedBox(height: AppSpacing.s),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(
              onPressed: _busy ? null : () => unawaited(_saveKey()),
              child: const Text('Save key'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _modelEditor(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _modelController,
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(
            labelText: 'Model',
            hintText: _provider.defaultModel,
          ),
          onChanged: _onModelChanged,
        ),
        const SizedBox(height: AppSpacing.s),
        Wrap(
          spacing: AppSpacing.s,
          runSpacing: AppSpacing.xs,
          children: [
            for (final model in _provider.suggestedModels)
              ActionChip(
                label: Text(model),
                onPressed: () => unawaited(_useSuggestedModel(model)),
              ),
          ],
        ),
      ],
    );
  }
}

/// The disclosure, said once in full rather than split across three tooltips.
///
/// Deliberately a bordered block and not a [SettingsFootnote]: a footnote is
/// where explanatory prose goes, and this is not explanatory - it is the one
/// thing on the page somebody could later say they were not told.
class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote({required this.provider});

  final AiProvider provider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: tint.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lock_open_outlined, size: 20, color: tint),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Text(
                  'What leaves this phone',
                  style: theme.textTheme.titleSmall?.copyWith(color: tint),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            'Your key is stored on this device only. It is never sent to '
            'venta, never shared with your household, and never written into a '
            'message.\n\n'
            'Photos go straight from this phone to ${provider.label}, using '
            'your key. They are not end-to-end encrypted - your messages are, '
            'this is not, because ${provider.label} has to be able to read the '
            'picture.\n\n'
            'venta does not store the photos and they are not attached to the '
            'pantry. Only what you confirm afterwards is written down.',
            style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
          ),
        ],
      ),
    );
  }
}

/// Enough of a key to tell two of them apart and not enough to use.
///
/// Public because the harness and any later capture UI want the same shape;
/// keeping a second, subtly different masker somewhere else is how one of them
/// ends up printing four characters too many.
String maskApiKey(String key) {
  final trimmed = key.trim();
  // Below this there is no safe amount to show - a twelve-character key with
  // seven characters visible is most of a key.
  if (trimmed.length < 12) return '…';
  return '${trimmed.substring(0, 3)}…${trimmed.substring(trimmed.length - 4)}';
}

/// The gate every photo path goes through before an image leaves the device.
///
/// Returns true when this provider has already been consented to, or when the
/// user agrees now; false on cancel, and the caller must then do nothing at
/// all - not fall back to a different provider, not send anyway, not ask again
/// in the same breath.
///
/// It lives here, next to the page that carries the same disclosure, because
/// there must be exactly one of it. Phases 2 and 3 both capture photos, from
/// different screens, and a second consent implementation is how one of those
/// screens ends up shipping without one.
///
/// Consent is recorded per provider, not once for the feature: agreeing to send
/// a photograph of your kitchen to Anthropic is not agreeing to send it to
/// Google, and switching provider in settings must not silently inherit an
/// answer about somebody else.
Future<bool> ensureVisionConsent(
  BuildContext context,
  AiProvider provider,
  AiKeyStore keys,
) async {
  if (await keys.hasConsented(provider)) return true;
  if (!context.mounted) return false;

  final agreed = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    // The shell's nav rail is a sibling of the content Navigator; without this
    // the sheet is clipped to the content pane instead of the device.
    useRootNavigator: true,
    // No barrier dismiss and no drag handle: the two ways out of this are the
    // two buttons, so a dismissed sheet cannot be mistaken later for an answer.
    isDismissible: false,
    enableDrag: false,
    builder: (_) => _VisionConsentSheet(provider: provider),
  );

  if (agreed != true) return false;
  await keys.recordConsent(provider);
  return true;
}

class _VisionConsentSheet extends StatelessWidget {
  const _VisionConsentSheet({required this.provider});

  final AiProvider provider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.m,
            AppSpacing.m,
            AppSpacing.m,
            AppSpacing.l,
          ),
          children: [
            Text(
              'Send photos to ${provider.label}?',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.m),
            _ConsentPoint(
              icon: Icons.north_east,
              text:
                  'A photograph of your kitchen is sent to ${provider.label}, '
                  'the company, using your own API key. It does not pass '
                  'through venta.',
            ),
            _ConsentPoint(
              icon: Icons.lock_open_outlined,
              text:
                  'It is not end-to-end encrypted. Your messages are; this is '
                  'not, because ${provider.label} has to be able to read the '
                  'picture.',
            ),
            _ConsentPoint(
              icon: Icons.delete_outline,
              text:
                  'venta does not store the photo, and it is not attached to '
                  'anything in the pantry. It exists for one request and then '
                  'it is gone.',
            ),
            _ConsentPoint(
              icon: Icons.checklist_outlined,
              text:
                  'Whatever comes back is a suggestion. Nothing is written to '
                  'your pantry until you confirm it.',
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              'Asked once per provider. Change or remove your key any time in '
              'Settings > AI.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Agree'),
            ),
            const SizedBox(height: AppSpacing.xs),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsentPoint extends StatelessWidget {
  const _ConsentPoint({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Text(text, style: theme.textTheme.bodyMedium?.copyWith(height: 1.4)),
          ),
        ],
      ),
    );
  }
}
