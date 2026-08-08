import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/format/date_time_format.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/settings_tiles.dart';
import '../../data/models/platform_status_dto.dart';
import '../../data/status_repository.dart';
import '../status_palette.dart';

/// "Platform status" - the component list, whatever is currently open, and a
/// link out to the real status page.
///
/// §4 keeps this in settings deliberately: the component list is not main-UI
/// material, and the 90-day uptime strip belongs on `status.venta.gg` rather
/// than being reimplemented here. What this screen owes the user is the answer
/// to "is it me or is it them", which is the roll-up at the top.
///
/// It is also the one place that renders a *failed* status check. Everywhere
/// else in the app stays silent when the summary can't be read - a failed
/// status check is not evidence of an incident - but somebody who opened this
/// screen asked the question out loud, and a blank page is not an answer.
class PlatformStatusScreen extends StatefulWidget {
  const PlatformStatusScreen({super.key});

  @override
  State<PlatformStatusScreen> createState() => _PlatformStatusScreenState();
}

class _PlatformStatusScreenState extends State<PlatformStatusScreen> {
  final _repository = getIt<StatusRepository>();

  @override
  void initState() {
    super.initState();
    // On top of the 60s poll: this screen can be opened seconds after the app
    // resumed, and the one thing it must not show is a minute-old answer to the
    // question it exists for.
    unawaited(_repository.refresh());
  }

  Future<void> _open(String? url) async {
    if (url == null) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the status page.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackLocation: RoutePaths.settings),
        title: const Text('Platform status'),
      ),
      body: ValueListenableBuilder<PlatformStatusSnapshot>(
        valueListenable: _repository.snapshot,
        builder: (context, snapshot, _) {
          return RefreshIndicator(
            onRefresh: _repository.refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.m,
                AppSpacing.m,
                AppSpacing.m,
                AppSpacing.xl,
              ),
              children: _body(context, snapshot),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _body(BuildContext context, PlatformStatusSnapshot snapshot) {
    final summary = snapshot.summary;

    if (summary == null) {
      return [
        const SizedBox(height: AppSpacing.xl),
        if (snapshot.checking)
          const Center(child: CircularProgressIndicator())
        else
          _UnverifiedCard(onRetry: _repository.refresh),
        const SizedBox(height: AppSpacing.l),
        ..._statusPageLink(),
      ];
    }

    final open = summary.open;

    return [
      _IndicatorCard(summary: summary),
      // Shown *alongside* the cached answer rather than instead of it: what the
      // client last read is still the best thing it knows, and the honest
      // caveat is that it may have moved on since.
      if (snapshot.unverified) ...[
        const SizedBox(height: AppSpacing.s),
        const SettingsFootnote(
          'The system status could not be verified just now - this is the last '
          'reading, and it may be out of date.',
        ),
      ],
      const SizedBox(height: AppSpacing.l),
      if (open.isNotEmpty) ...[
        SettingsSection(
          label: open.length == 1 ? 'Ongoing' : 'Ongoing (${open.length})',
          children: [
            for (final incident in open)
              _IncidentRow(
                incident: incident,
                onTap: () => _open(_repository.urlForIncident(incident)),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.l),
      ],
      if (summary.components.isNotEmpty) ...[
        SettingsSection(
          label: 'Components',
          children: [
            for (final component in summary.components)
              _ComponentRow(component: component),
          ],
        ),
        const SizedBox(height: AppSpacing.l),
      ],
      if (summary.recent.isNotEmpty) ...[
        SettingsSection(
          label: 'Recently resolved',
          children: [
            for (final incident in summary.recent)
              _IncidentRow(
                incident: incident,
                onTap: () => _open(_repository.urlForIncident(incident)),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.l),
      ],
      ..._statusPageLink(),
    ];
  }

  List<Widget> _statusPageLink() {
    final url = _repository.statusPageUrl;
    if (url == null) return const [];
    return [
      SettingsSection(
        children: [
          SettingsRow(
            icon: Icons.open_in_new,
            title: 'Open the status page',
            subtitle: Uri.parse(url).host,
            onTap: () => _open(url),
          ),
        ],
      ),
      const SettingsFootnote(
        'Full history, past incidents and 90-day uptime live there.',
      ),
    ];
  }
}

/// The roll-up: one dot, one line, and when it was last confirmed.
class _IndicatorCard extends StatelessWidget {
  const _IndicatorCard({required this.summary});

  final PlatformStatusDto summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = context.indicatorColor(summary.indicator);
    final updatedAt = summary.updatedAt;

    return SettingsSection(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    summary.indicator.label,
                    style: theme.textTheme.titleSmall,
                  ),
                  if (updatedAt != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Updated ${formatRelativeDateTime(updatedAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// What this screen shows when the status endpoint itself could not be reached.
///
/// The deliberate exception to "say nothing when the status call fails". It
/// claims nothing about the platform - only that this device could not confirm
/// anything either way, which is a materially different statement from "all
/// systems operational" and the reason a blank screen would be wrong here.
class _UnverifiedCard extends StatelessWidget {
  const _UnverifiedCard({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SettingsSection(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 36,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              'The system status could not be verified',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'This device could not reach the status service, so there is '
              'nothing to report either way. It may be your connection.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}

/// One component and its dot. The name is the server's prose; the colour comes
/// from [StatusComponentDto.status], which is the stable half.
class _ComponentRow extends StatelessWidget {
  const _ComponentRow({required this.component});

  final StatusComponentDto component;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uptime = component.uptime90d;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: 14,
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: context.componentColor(component.status),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(component.name, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 2),
                Text(
                  component.status.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          if (uptime != null)
            Text(
              // Two decimals, per §4 - the difference between 99.9% and 99.87%
              // is the entire point of publishing the number.
              '${(uptime * 100).toStringAsFixed(2)}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
        ],
      ),
    );
  }
}

/// One incident or maintenance window, with its latest update underneath.
class _IncidentRow extends StatelessWidget {
  const _IncidentRow({required this.incident, required this.onTap});

  final StatusIncidentDto incident;
  final VoidCallback onTap;

  /// The one line under the title: what the incident last said, or - for a
  /// maintenance window that has posted nothing - when it is scheduled for.
  String? _subtitle() {
    final body = incident.latestUpdate?.body;
    if (body != null && body.trim().isNotEmpty) return body.trim();
    final from = incident.scheduledFor;
    if (from != null) {
      final until = incident.scheduledUntil;
      final start = formatShortDateTime(from);
      return until == null
          ? 'Scheduled for $start'
          : 'Scheduled for $start - ${formatTimeOfDay(until)}';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = _subtitle();

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: 14,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              incident.kind == IncidentKind.maintenance
                  ? Icons.build_outlined
                  : Icons.report_problem_outlined,
              size: 20,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(incident.title, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 2),
                  Text(
                    incident.status.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.xs),
              child: Icon(
                Icons.open_in_new,
                size: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
