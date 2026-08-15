import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/device/device_id_service.dart';
import '../../../../core/device/device_registration_service.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/format/date_time_format.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/adaptive_progress_indicator.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/settings_tiles.dart';
import '../../../auth/data/account_repository.dart';
import '../../../auth/data/models/login_session_dto.dart';
import '../device_type_icon.dart';

/// Every login on the account - password, Steam, or a QR pairing approved from
/// this phone - with per-session revoke. Reached from the settings index and
/// from the Devices card in Account settings
/// (`RoutePaths.devices`).
///
/// The bulk "sign out of all other devices" action stays on the Account screen;
/// this page is the itemised view, where you can see *which* device you're
/// signing out before you do it.
class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  List<LoginSessionDto>? _sessions;
  bool _failed = false;

  /// Ids currently being revoked - per-row rather than one page-wide flag, so
  /// revoking one device doesn't lock the buttons on all the others.
  final _revoking = <String>{};

  bool _forgetting = false;

  /// This installation's registered device id. Sessions carry it now, which is
  /// what lets a row say "this is the phone you're holding" rather than only
  /// "this is the login you're using" - the two differ for every earlier login
  /// from the same handset.
  String? get _thisDeviceId => getIt<DeviceIdService>().deviceIdOrNull;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _failed = false);
    try {
      final sessions = await getIt<AccountRepository>().listSessions();
      if (!mounted) return;
      setState(() => _sessions = _sorted(sessions));
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  /// This device first, then most-recently-used. The server's order isn't
  /// specified, and "which one am I?" is the first question this page has to
  /// answer.
  List<LoginSessionDto> _sorted(List<LoginSessionDto> sessions) {
    final sorted = [...sessions];
    sorted.sort((a, b) {
      if (a.isCurrent != b.isCurrent) return a.isCurrent ? -1 : 1;
      final aUsed = a.lastUsedAt ?? a.createdAt;
      final bUsed = b.lastUsedAt ?? b.createdAt;
      if (aUsed == null || bUsed == null) {
        return aUsed == null ? (bUsed == null ? 0 : 1) : -1;
      }
      return bUsed.compareTo(aUsed);
    });
    return sorted;
  }

  Future<void> _confirmRevoke(LoginSessionDto session) async {
    final name = session.deviceName ?? 'this device';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sign out $name?'),
        // The delay is the spec's stateless-access-token caveat, stated plainly
        // rather than implied - someone revoking a device they don't trust
        // needs to know it isn't cut off the instant they tap this.
        content: const Text(
          'That device will not be able to stay signed in. It may keep working '
          'for up to an hour before it is fully locked out.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _revoking.add(session.id));
    try {
      await getIt<AccountRepository>().revokeSession(session.id);
      if (!mounted) return;
      setState(() {
        _revoking.remove(session.id);
        _sessions = _sessions?.where((s) => s.id != session.id).toList();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$name signed out.')));
    } catch (_) {
      if (!mounted) return;
      setState(() => _revoking.remove(session.id));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not sign out $name.')));
    }
  }

  /// Unregisters this installation and signs out. Deliberately heavier than
  /// Log Out: the server drops the device row and, by cascade, its push tokens
  /// - which is the only way to stop a handset you're about to wipe or sell
  /// from being rung. It also revokes this device's sessions, so staying
  /// signed in afterwards isn't an option.
  Future<void> _confirmForgetDevice() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forget this device?'),
        content: const Text(
          'This device will be unregistered and signed out. It will stop '
          'receiving notifications and calls entirely. You can sign in again '
          'to register it as a new device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Forget'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _forgetting = true);
    final sessionCubit = context.read<SessionCubit>();
    try {
      await getIt<DeviceRegistrationService>().forgetThisDevice();
    } catch (_) {
      if (!mounted) return;
      setState(() => _forgetting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not forget this device.')),
      );
      return;
    }
    // The router's redirect drops back to /login the moment the session goes
    // unauthenticated, so there's nothing to pop here.
    await sessionCubit.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackLocation: RoutePaths.settings),
        title: const Text('Logged-in Devices'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _sessions == null && !_failed ? null : _load,
          ),
        ],
      ),
      body: SafeArea(child: _body(context)),
    );
  }

  Widget _body(BuildContext context) {
    final theme = Theme.of(context);

    if (_failed) {
      return _CenteredMessage(
        icon: Icons.cloud_off_outlined,
        title: 'Could not load your devices',
        body: 'Check your connection and try again.',
        actionLabel: 'Retry',
        onAction: _load,
      );
    }

    final sessions = _sessions;
    if (sessions == null) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (sessions.isEmpty) {
      return const _CenteredMessage(
        icon: Icons.devices_other,
        title: 'No sessions',
        body: 'Nothing is signed in to this account right now.',
      );
    }

    return RefreshIndicator.adaptive(
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
            label: sessions.length == 1
                ? '1 active session'
                : '${sessions.length} active sessions',
            children: [
              for (final session in sessions)
                _SessionRow(
                  session: session,
                  revoking: _revoking.contains(session.id),
                  onRevoke: () => _confirmRevoke(session),
                  isThisDevice:
                      session.clientDeviceId != null &&
                      session.clientDeviceId == _thisDeviceId,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Text(
              'Signing out a device stops it from staying logged in. It can '
              'take up to an hour to take full effect. To sign out this '
              'device, use Log Out in Settings.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          SettingsSection(
            label: 'This device',
            children: [
              SettingsRow(
                icon: Icons.phonelink_erase_outlined,
                title: 'Forget this device',
                subtitle:
                    'Unregister and sign out. Stops notifications and calls '
                    'reaching this phone at all.',
                showChevron: false,
                destructive: true,
                onTap: _forgetting ? null : _confirmForgetDevice,
                trailing: _forgetting
                    ? const AdaptiveProgressIndicator(size: 18, strokeWidth: 2)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({
    required this.session,
    required this.revoking,
    required this.onRevoke,
    required this.isThisDevice,
  });

  final LoginSessionDto session;
  final bool revoking;
  final VoidCallback onRevoke;

  /// The session came from this installation, by registered device id. Not the
  /// same as [LoginSessionDto.isCurrent]: an earlier login from this phone
  /// that's still alive is this device but not this session, and saying so is
  /// the whole point of the sessions list carrying a device id.
  final bool isThisDevice;

  /// "Active now · 203.0.113.4", or whichever halves actually exist - a
  /// session missing both still renders a row rather than a stray separator.
  String get _subtitle {
    final lastUsed = session.lastUsedAt ?? session.createdAt;
    final parts = [
      if (session.isCurrent)
        'Active now'
      else ...[
        if (isThisDevice) 'This device',
        if (lastUsed != null) 'Last used ${formatRelativeDateTime(lastUsed)}',
      ],
      if (session.ipAddress != null && session.ipAddress!.isNotEmpty)
        session.ipAddress!,
    ];
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SettingsRow(
      icon: deviceTypeIcon(session.deviceType),
      title: session.deviceName ?? 'Unknown device',
      subtitle: _subtitle.isEmpty ? null : _subtitle,
      showChevron: false,
      // The current session deliberately has no action: revoking it here would
      // half-sign-out the app (tokens still in secure storage, refresh dead)
      // instead of going through SessionCubit like Log Out does.
      trailing: session.isCurrent
          ? Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadii.badge),
              ),
              child: Text(
                'THIS DEVICE',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : revoking
          ? const AdaptiveProgressIndicator(size: 18, strokeWidth: 2)
          : IconButton(
              tooltip: 'Sign out this device',
              icon: Icon(Icons.logout, color: theme.colorScheme.error),
              onPressed: onRevoke,
            ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 40,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppSpacing.m),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              body,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: AppSpacing.l),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
