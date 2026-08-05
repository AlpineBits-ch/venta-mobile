import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/format/date_time_format.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/load_failure_view.dart';
import '../../data/models/report_dto.dart';
import '../../data/support_repository.dart';

/// What this account reported, and what became of it.
///
/// A low-traffic screen whose whole purpose is to answer "did anything happen
/// to that thing I reported six weeks ago", which is why it lives under Privacy
/// and isn't linked from anywhere else.
///
/// It renders three outcomes and nothing more. The server never returns the
/// moderator's note or who handled it, and that is deliberate rather than an
/// omission to work around: in a harassment case, telling the reporter what was
/// decided is a channel straight back to the person they reported.
class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  List<FiledReportDto>? _reports;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final reports = await getIt<SupportRepository>().myReports();
      if (!mounted) return;
      setState(() {
        _reports = reports;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        // A third state, not an empty list. "You haven't reported anything"
        // for a dropped connection tells someone their report is gone.
        _error = 'Could not load your reports.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final reports = _reports;
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackLocation: RoutePaths.privacy),
        title: const Text('Reports you\'ve filed'),
      ),
      body: switch ((_loading, _error, reports)) {
        (true, _, _) => const Center(child: CircularProgressIndicator()),
        (_, final String error, _) => LoadFailureView(
          message: error,
          onRetry: _load,
        ),
        (_, _, final List<FiledReportDto> rows) when rows.isEmpty =>
          const _EmptyState(),
        (_, _, final List<FiledReportDto> rows) => RefreshIndicator(
          onRefresh: _load,
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.m),
            itemCount: rows.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
            itemBuilder: (context, index) => _ReportTile(report: rows[index]),
          ),
        ),
        _ => LoadFailureView(
          message: 'Could not load your reports.',
          onRetry: _load,
        ),
      },
    );
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({required this.report});

  final FiledReportDto report;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subject = report.subjectKind?.label;
    final reason = report.reason?.label;
    final created = report.createdAt;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  // The reason the user picked, in the words they picked it
                  // in - never the enum. A row whose reason this build doesn't
                  // recognise falls back to the subject rather than showing a
                  // raw wire value.
                  reason ?? subject ?? 'Report',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _StatusChip(status: report.status),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            [
              if (subject != null && reason != null) subject,
              if (created != null) formatRelativeDateTime(created),
            ].join(' · '),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final ReportStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = switch (status) {
      ReportStatus.underReview => theme.colorScheme.primary,
      ReportStatus.actionTaken => theme.colorScheme.tertiary,
      ReportStatus.closed => theme.colorScheme.onSurface,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.badge),
      ),
      child: Text(
        status.label,
        style: theme.textTheme.labelSmall?.copyWith(color: tint),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.flag_outlined,
              size: 40,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              'You haven\'t reported anything.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'You can report a message, a person or a server from its menu.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
