import 'dart:async';

import 'models/data_export_dto.dart';
import 'models/guild_dm_preference_dto.dart';
import 'models/legal_document_dto.dart';
import 'models/privacy_settings_dto.dart';
import 'privacy_api.dart';

/// The account's privacy record, fetched once and kept.
///
/// Two kinds of caller read this and they want different things from a cache
/// miss, so both are offered deliberately:
///
///  * The Privacy screen wants the truth or a spinner - [fetch]/[ensureLoaded].
///  * The emit-site gates (typing indicators today) want an answer *now*, on
///    every keystroke, and cannot await a round-trip - [cached].
///
/// [cached] is null until a fetch lands, and the gates treat null as "send it".
/// That looks like it contradicts the fail-closed rule, and is worth being
/// explicit about: the server enforces every one of these settings at its own
/// emit site, so a client that guesses wrong leaks nothing - the indicator is
/// dropped server-side. Failing closed here would instead silently disable
/// typing indicators for every user during any Identity blip, which protects
/// nobody. Where the client *is* the only enforcement point - it isn't, for
/// anything in this spec - the answer would be the other way round.
class PrivacyRepository {
  PrivacyRepository({required this.api});

  final PrivacyApi api;

  final _controller = StreamController<PrivacySettingsDto>.broadcast();

  PrivacySettingsDto? _cache;

  /// In-flight fetch, so a cold screen and a gate asking at the same moment
  /// share one request rather than racing two.
  Future<PrivacySettingsDto>? _inFlight;

  Stream<PrivacySettingsDto> get changes => _controller.stream;

  /// The last known settings, or null if none have been fetched this session.
  PrivacySettingsDto? get cached => _cache;

  /// Whether this device should emit a typing indicator. See the class comment
  /// for why an unknown answer is "yes".
  bool get shouldSendTypingIndicators => _cache?.sendTypingIndicators ?? true;

  /// Whether another member's typing indicator should be rendered.
  ///
  /// Reciprocal with [shouldSendTypingIndicators] on purpose: a user who
  /// withholds the signal does not receive it either. Without that, the setting
  /// is a way to take without giving, which is the property that makes it
  /// unusable in practice. The server applies the same rule; this stops the
  /// indicator flickering in from events already in flight when it's turned off.
  bool get shouldRenderTypingIndicators => shouldSendTypingIndicators;

  Future<PrivacySettingsDto> fetch() {
    final existing = _inFlight;
    if (existing != null) return existing;
    final request = api.getSettings().then(_store);
    _inFlight = request;
    return request.whenComplete(() => _inFlight = null);
  }

  /// The cached record, fetching once if nothing is cached yet.
  Future<PrivacySettingsDto> ensureLoaded() async => _cache ?? await fetch();

  /// Applies a sparse change set. [changes] uses the wire field names, matching
  /// `PATCH /privacy-settings` - see [PrivacyApi.updateSettings] for why this
  /// is a map and not a DTO.
  Future<PrivacySettingsDto> update(Map<String, dynamic> changes) async {
    final updated = await api.updateSettings(changes);
    return _store(updated);
  }

  PrivacySettingsDto _store(PrivacySettingsDto settings) {
    // A response that lost the race to a newer write would otherwise roll the
    // screen back to a value the user already replaced. `version` is carried
    // for exactly this and is never rendered.
    final current = _cache;
    if (current != null && settings.version < current.version) return current;
    _cache = settings;
    _controller.add(settings);
    return settings;
  }

  // ── Data exports ────────────────────────────────────────────────────────

  Future<List<DataExportDto>> listDataExports() => api.listDataExports();

  Future<DataExportDto> requestDataExport() => api.requestDataExport();

  Future<String> resolveDataExportDownload(String exportId) =>
      api.resolveDataExportDownload(exportId);

  // ── Legal ───────────────────────────────────────────────────────────────

  Future<List<LegalDocumentDto>> getLegalDocuments() =>
      api.getLegalDocuments();

  String legalDocumentUrl(LegalDocumentDto document) =>
      api.legalDocumentUrl(document);

  Future<List<UserConsentDto>> getConsents() => api.getConsents();

  Future<void> acceptConsent({
    required LegalDocumentType documentType,
    required String version,
  }) => api.acceptConsent(documentType: documentType, version: version);

  // ── Per-guild DM overrides ──────────────────────────────────────────────

  Future<List<GuildDmPreferenceDto>> getGuildDmPreferences() =>
      api.getGuildDmPreferences();

  Future<void> setGuildDmPreference({
    required String guildId,
    required bool allowDirectMessages,
  }) => api.setGuildDmPreference(
    guildId: guildId,
    allowDirectMessages: allowDirectMessages,
  );

  /// Drops the cached record on a session change - see
  /// `resetSessionScopedCaches()`. Nothing is emitted: the next account's
  /// settings are unknown, not "the restrictive defaults", and pushing a
  /// synthetic value would have every gate act on a record no user owns.
  void clear() => _cache = null;

  void dispose() => unawaited(_controller.close());
}
