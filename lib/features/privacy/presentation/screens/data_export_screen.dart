import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/settings_tiles.dart';
import '../../data/models/data_export_dto.dart';
import '../../data/privacy_repository.dart';

const _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June', //
  'July', 'August', 'September', 'October', 'November', 'December',
];

String _formatDate(DateTime dateTime) {
  final local = dateTime.toLocal();
  return '${_monthNames[local.month - 1]} ${local.day}, ${local.year}';
}

/// Request and download a copy of everything the instance holds about the
/// account (GDPR Art. 15/20).
///
/// The archive is assembled by a fan-out across every service, so a request is
/// queued rather than answered - which is why this is a list of requests with
/// states rather than a single button that produces a file.
class DataExportScreen extends StatefulWidget {
  const DataExportScreen({super.key});

  @override
  State<DataExportScreen> createState() => _DataExportScreenState();
}

class _DataExportScreenState extends State<DataExportScreen> {
  List<DataExportDto>? _exports;
  bool _failed = false;
  bool _requesting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _failed = false);
    try {
      final exports = await getIt<PrivacyRepository>().listDataExports();
      if (mounted) setState(() => _exports = exports);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  /// Whether an export is already queued or being built. Only one can be, and
  /// the button says so instead of letting someone queue a second and meet the
  /// rate limit as an error.
  bool get _hasPending =>
      (_exports ?? const <DataExportDto>[]).any((e) => e.status.isInProgress);

  Future<void> _request() async {
    setState(() => _requesting = true);
    try {
      final created = await getIt<PrivacyRepository>().requestDataExport();
      if (!mounted) return;
      setState(() => _exports = [created, ...?_exports]);
      _toast(
        'Your export is being prepared. It can take a while - come back to '
        'this page to download it.',
      );
    } on DataExportRateLimitedException catch (e) {
      if (mounted) {
        final hours = e.retryAfter?.inHours;
        _toast(
          hours == null
              ? 'You can request one export a day. Try again tomorrow.'
              : 'You can request one export a day. Try again in about '
                    '${hours < 1 ? 'an hour' : '$hours hours'}.',
        );
      }
    } catch (_) {
      if (mounted) _toast('Could not request an export.');
    } finally {
      if (mounted) setState(() => _requesting = false);
    }
  }

  /// Hands the signed URL to the platform browser rather than streaming the
  /// archive through the app. It is the densest bundle of personal data the
  /// system can produce, and the right place for it is the user's own
  /// downloads, not this process's heap.
  Future<void> _download(DataExportDto export) async {
    try {
      final url = await getIt<PrivacyRepository>().resolveDataExportDownload(
        export.exportId,
      );
      final opened = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!opened && mounted) _toast('Could not open the download.');
    } on DataExportUnavailableException catch (e) {
      if (!mounted) return;
      // Refresh either way: the row on screen said this was downloadable and
      // the server disagrees, so the list is out of date, not just this row.
      unawaited(_load());
      _toast(
        e.expired
            ? 'That download has expired. Request a new copy.'
            : 'That export didn\'t finish - request a new copy.',
      );
    } catch (_) {
      if (mounted) _toast('Could not start the download.');
    }
  }

  void _toast(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    final exports = _exports;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackLocation: RoutePaths.privacy),
        title: const Text('Your data'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.m,
            AppSpacing.m,
            AppSpacing.m,
            AppSpacing.xl,
          ),
          children: [
            SettingsSection(
              label: 'Request a copy',
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'We\'ll put together everything this server holds about '
                      'your account - your profile, your messages, your '
                      'servers and your settings - as a single archive.\n\n'
                      'It won\'t contain other people\'s personal details, and '
                      'the download link expires after seven days.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(height: 1.4),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    FilledButton.icon(
                      onPressed: _requesting || _hasPending ? null : _request,
                      icon: const Icon(Icons.download_outlined, size: 18),
                      label: Text(
                        _hasPending
                            ? 'An export is already being prepared'
                            : 'Request my data',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SettingsFootnote('One request per day.'),
            const SizedBox(height: AppSpacing.l),
            if (_failed)
              SettingsSection(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Could not load your previous requests.'),
                      const SizedBox(height: AppSpacing.s),
                      OutlinedButton(
                        onPressed: _load,
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
              )
            else if (exports == null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (exports.isNotEmpty)
              SettingsSection(
                label: 'Requests',
                children: [
                  for (final export in exports)
                    _ExportRow(export: export, onDownload: _download),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ExportRow extends StatelessWidget {
  const _ExportRow({required this.export, required this.onDownload});

  final DataExportDto export;
  final Future<void> Function(DataExportDto) onDownload;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final requestedAt = export.requestedAt;
    final expiresAt = export.expiresAt;

    final subtitle = switch (export.status) {
      _ when export.status.isDownloadable && expiresAt != null =>
        'Available until ${_formatDate(expiresAt)}',
      DataExportStatus.failed =>
        export.failureReason ??
            'Something went wrong preparing this one - request another.',
      DataExportStatus.expired => 'The download link has expired.',
      _ when requestedAt != null => 'Requested ${_formatDate(requestedAt)}',
      _ => null,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsRow(
          icon: switch (export.status) {
            DataExportStatus.ready => Icons.folder_zip_outlined,
            DataExportStatus.partial => Icons.folder_zip_outlined,
            DataExportStatus.failed => Icons.error_outline,
            DataExportStatus.expired => Icons.history_toggle_off,
            _ => Icons.hourglass_top_outlined,
          },
          title: export.status.label,
          subtitle: subtitle,
          showChevron: false,
          trailing: switch (export.status) {
            _ when export.status.isDownloadable => FilledButton(
              onPressed: () => onDownload(export),
              child: const Text('Download'),
            ),
            // A spinner rather than a percentage: the saga reports no progress,
            // and an invented bar is a claim the server never made.
            _ when export.status.isInProgress => SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            _ => null,
          },
        ),
        // Beside the working Download button, not instead of it. The archive is
        // real and the user is entitled to it; what they also need is to know
        // it is short of something before they read it as complete.
        if (export.status == DataExportStatus.partial)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.m,
              0,
              AppSpacing.m,
              AppSpacing.m,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_outlined,
                  size: 18,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: Text(
                    export.missingServices.isEmpty
                        ? export.failureReason ??
                              'Some of your data could not be included.'
                        : 'Some of your data could not be included: '
                              '${export.missingServices.join(', ')}. Request '
                              'another copy later to try again.',
                    style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
