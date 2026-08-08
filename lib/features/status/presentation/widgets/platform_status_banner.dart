import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../data/models/platform_status_dto.dart';
import '../../data/status_repository.dart';
import '../status_palette.dart';

/// Wraps the whole app in the platform-status banner.
///
/// Installed as `MaterialApp.builder` rather than inside `AppShell`, which is
/// where the other app-wide banners live. Two reasons, and they are the same
/// reason: an outage is most worth announcing to somebody who *cannot get in*.
/// `AppShell` only exists once a session does, so a banner there is invisible
/// on the login screen - and §5 already notes that a signed-out user, "who is
/// quite possibly signed out *because* of the incident", receives no hub events
/// either. Everything about this feature has to work with no session at all.
class PlatformStatusScope extends StatefulWidget {
  const PlatformStatusScope({super.key, required this.child});

  /// The router's navigator.
  final Widget child;

  @override
  State<PlatformStatusScope> createState() => _PlatformStatusScopeState();
}

class _PlatformStatusScopeState extends State<PlatformStatusScope> {
  /// Resolved once here, never from `build` - this widget sits above the
  /// navigator, so an exception out of its build is the entire app rendering
  /// nothing. Same defence as `SessionNotPersistedBanner`, and it matters more
  /// here: status is the feature most likely to be reached on a launch where
  /// something else already went wrong.
  StatusRepository? _repository;

  @override
  void initState() {
    super.initState();
    try {
      _repository = getIt<StatusRepository>();
    } catch (e) {
      debugPrint(
        'PlatformStatusScope: no status repository, staying hidden: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final repository = _repository;
    if (repository == null) return widget.child;

    return ValueListenableBuilder<PlatformStatusSnapshot>(
      valueListenable: repository.snapshot,
      // The navigator is passed through as `child` so it is never rebuilt by a
      // poll landing, and the Column/Expanded shape below is identical whether
      // or not there is a banner. Both matter: changing the tree *shape* above
      // a Navigator re-parents its element and every route loses its state, so
      // "hide the banner" has to mean an empty box, not a missing widget.
      child: widget.child,
      builder: (context, snapshot, child) {
        final banner = snapshot.visibleBanner;
        final media = MediaQuery.of(context);
        return Column(
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: banner == null
                  ? const SizedBox(width: double.infinity)
                  : _StatusBannerBar(
                      banner: banner,
                      url: repository.urlFor(banner),
                      onDismiss: repository.dismissBanner,
                    ),
            ),
            Expanded(
              child: MediaQuery(
                // The banner's own `SafeArea` has already spent the top inset;
                // leaving it in place below would have every screen pad for a
                // notch that is now covered by the banner.
                data: banner == null
                    ? media
                    : media.copyWith(padding: media.padding.copyWith(top: 0)),
                child: child!,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// The bar itself. Renders [StatusBannerDto.title] and [StatusBannerDto.body]
/// **verbatim** - see the type's own doc comment for why nothing here composes
/// a sentence of its own.
class _StatusBannerBar extends StatelessWidget {
  const _StatusBannerBar({
    required this.banner,
    required this.url,
    required this.onDismiss,
  });

  final StatusBannerDto banner;
  final String? url;
  final VoidCallback onDismiss;

  IconData get _icon => switch (banner.severity) {
    StatusSeverity.critical => Icons.error_outline,
    StatusSeverity.warning => Icons.warning_amber_rounded,
    StatusSeverity.info || StatusSeverity.unknown => Icons.info_outline,
  };

  Future<void> _open() async {
    final target = url;
    if (target == null) return;
    final uri = Uri.tryParse(target);
    if (uri == null) return;
    try {
      // The system browser, not an in-app view: the status page is deliberately
      // hosted away from everything this app talks to, and opening it in a
      // webview inside a client that may itself be failing defeats that.
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('could not open status page: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = context.severityColor(banner.severity);
    final foreground = context.onStatusColor(background);

    return Material(
      color: background,
      child: InkWell(
        onTap: url == null ? null : _open,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.m,
              AppSpacing.s,
              AppSpacing.xs,
              AppSpacing.s,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(_icon, size: 18, color: foreground),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        banner.title,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: foreground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (banner.body.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          banner.body,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: foreground.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  color: foreground,
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Dismiss',
                  onPressed: onDismiss,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
