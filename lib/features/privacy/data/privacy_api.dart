import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/privacy_refusal.dart';
import 'models/data_export_dto.dart';
import 'models/guild_dm_preference_dto.dart';
import 'models/legal_document_dto.dart';
import 'models/privacy_settings_dto.dart';

/// Everything behind the Privacy screen: the account's privacy record, its data
/// exports, its legal consents, and the per-guild DM overrides.
///
/// Three services answer these, and the gateway prefixes each route with the
/// service that owns it - Identity for the settings, the exports and the legal
/// documents; Guild for the per-guild overrides. Blocking is Social's, and
/// lives on `RelationshipApi` with the rest of the relationship verbs rather
/// than here, because a block *is* a relationship state.
class PrivacyApi {
  PrivacyApi({required this.client});

  final ApiClient client;

  String get _base => client.url('/api/v1/identity');

  String get _guildBase => client.url('/api/v1/guild');

  Future<PrivacySettingsDto> getSettings() async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '$_base/privacy-settings',
    );
    return PrivacySettingsDto.fromJson(response.data!);
  }

  /// Sparse update: send only the keys that changed.
  ///
  /// The endpoint's contract is "omitted means leave alone", so there is no
  /// read-modify-write here and no way for this client to clobber a field a
  /// newer client knows about. It is also why [changes] is a raw map rather
  /// than a [PrivacySettingsDto] - serialising the DTO would send every field,
  /// which is exactly the write this shape exists to avoid.
  ///
  /// Throws [PrivacyRefusalException] on a minor floor.
  Future<PrivacySettingsDto> updateSettings(
    Map<String, dynamic> changes,
  ) async {
    try {
      final response = await client.dio.patch<Map<String, dynamic>>(
        '$_base/privacy-settings',
        data: changes,
      );
      return PrivacySettingsDto.fromJson(response.data!);
    } on DioException catch (e) {
      final refusal = privacyRefusalOf(e);
      if (refusal != null) throw refusal;
      rethrow;
    }
  }

  // ── Data exports (GDPR Art. 15/20) ──────────────────────────────────────

  Future<List<DataExportDto>> listDataExports() async {
    final response = await client.dio.get<List<dynamic>>('$_base/data-exports');
    return (response.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(DataExportDto.fromJson)
        .toList();
  }

  /// Queues an export. Rate-limited to one per account per 24 hours, which
  /// arrives as [DataExportRateLimitedException] rather than a bare 429 -
  /// the screen has to say *when* they can ask again, not just that they can't.
  ///
  /// This one `429` is the account's own daily export limit and is **not** the
  /// gateway's shared token bucket, so `RateLimitInterceptor` retrying it would
  /// be a day-long wait: it carries `retryAfterSeconds`, not `retry_after`, and
  /// the interceptor's own retry ends after three attempts and hands the
  /// response through untouched either way.
  Future<DataExportDto> requestDataExport() async {
    try {
      final response = await client.dio.post<Map<String, dynamic>>(
        '$_base/data-exports',
      );
      return DataExportDto.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        throw DataExportRateLimitedException(
          retryAfter: _retryAfterOf(e.response!),
        );
      }
      rethrow;
    }
  }

  /// `retryAfterSeconds` in the body, or the `Retry-After` header.
  static Duration? _retryAfterOf(Response<dynamic> response) {
    final data = response.data;
    final seconds = data is Map ? data['retryAfterSeconds'] : null;
    final value =
        (seconds is num ? seconds.toDouble() : null) ??
        double.tryParse(response.headers.value('retry-after') ?? '');
    if (value == null || value <= 0) return null;
    return Duration(seconds: value.round());
  }

  /// Resolves the short-lived signed URL an export downloads from.
  ///
  /// The endpoint answers `302`, and Dio would follow it and buffer the whole
  /// archive into memory - which is both pointless (the file belongs in the
  /// user's downloads, not in the heap) and unbounded. Redirects are turned off
  /// so the `Location` can be handed to the platform browser instead.
  Future<String> resolveDataExportDownload(String exportId) async {
    try {
      final response = await client.dio.get<void>(
        '$_base/data-exports/$exportId/download',
        options: Options(
          followRedirects: false,
          // A 302 is the success case here, so it must not be an error.
          validateStatus: (status) =>
              status != null && status >= 200 && status < 400,
        ),
      );
      final location = response.headers.value('location');
      if (location == null || location.isEmpty) {
        throw StateError('Export download returned no location header.');
      }
      return location;
    } on DioException catch (e) {
      // 409: the export failed and there is no artifact. 410: there was one and
      // it has been deleted. Both are ordinary outcomes of a list the user is
      // looking at rather than errors, and the screen says different things.
      final status = e.response?.statusCode;
      if (status == 409 || status == 410) {
        throw DataExportUnavailableException(expired: status == 410);
      }
      rethrow;
    }
  }

  // ── Legal documents and consent ─────────────────────────────────────────

  Future<List<LegalDocumentDto>> getLegalDocuments() async {
    final response = await client.dio.get<List<dynamic>>(
      '$_base/legal/documents',
    );
    return (response.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(LegalDocumentDto.fromJson)
        .toList();
  }

  /// Where one published version can be read.
  ///
  /// [LegalDocumentDto.url] when the server supplied one, otherwise the
  /// anonymous `legal/documents/{type}/{version}` route, which serves the
  /// markdown the content hash covers. Built rather than left null so a
  /// document without a rendered page is still readable - it is the text
  /// someone is being asked to accept, and "isn't published yet" next to an
  /// Accept button is the worst version of this screen.
  String legalDocumentUrl(LegalDocumentDto document) {
    final url = document.url;
    if (url != null && url.isNotEmpty) return url;
    return '$_base/legal/documents/${document.documentType.wireValue}/'
        '${document.version}';
  }

  Future<List<UserConsentDto>> getConsents() async {
    final response = await client.dio.get<List<dynamic>>(
      '$_base/legal/consents',
    );
    return (response.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(UserConsentDto.fromJson)
        .toList();
  }

  /// Records acceptance of one document version.
  ///
  /// The server stamps the IP itself - nothing about where the acceptance came
  /// from is the client's to assert.
  Future<void> acceptConsent({
    required LegalDocumentType documentType,
    required String version,
  }) async {
    await client.dio.post<void>(
      '$_base/legal/consents',
      data: {'documentType': documentType.wireValue, 'version': version},
    );
  }

  // ── Per-guild DM overrides ──────────────────────────────────────────────

  /// Stored overrides **only**. A guild missing from the answer is not an
  /// error and not a `false` - it is a guild following the global policy.
  Future<List<GuildDmPreferenceDto>> getGuildDmPreferences() async {
    final response = await client.dio.get<List<dynamic>>(
      '$_guildBase/users/me/guild-privacy',
    );
    return (response.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(GuildDmPreferenceDto.fromJson)
        .toList();
  }

  /// Throws [GuildMembershipGoneException] on the `404` for a guild the account
  /// has left.
  Future<void> setGuildDmPreference({
    required String guildId,
    required bool allowDirectMessages,
  }) async {
    try {
      await client.dio.put<void>(
        '$_guildBase/guilds/$guildId/privacy',
        data: {'allowDirectMessages': allowDirectMessages},
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const GuildMembershipGoneException();
      }
      rethrow;
    }
  }
}
