import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/routing/back_navigation.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/profile_resolver.dart';
import '../../../../core/widgets/settings_tiles.dart';
import '../../../auth/data/account_repository.dart';
import '../../../auth/data/models/user_dto.dart';
import '../../../privacy/data/models/legal_document_dto.dart';

/// Shown when the server reports documents whose current version this account
/// hasn't accepted (`consentRequired` on `GET /users/self`).
///
/// Deliberately not a modal gate. The published terms cover an account that
/// already exists and keeps working; blocking the app behind an Accept button
/// would be coercion dressed as consent, and the withdrawal path here is
/// account deletion, which the user cannot reach if the app won't open.
class _ConsentBanner extends StatelessWidget {
  const _ConsentBanner({required this.documents});

  /// A document type this client doesn't know about is still something the
  /// user has to be told about, so `ConsentRequirementDto.label` falls back to
  /// the wire name rather than the entry being dropped.
  final List<ConsentRequirementDto> documents;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = theme.colorScheme.primary;
    return InkWell(
      onTap: () => context.push(RoutePaths.legalDocuments),
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: tint.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: tint.withValues(alpha: 0.30)),
        ),
        child: Row(
          children: [
            Icon(Icons.description_outlined, size: 20, color: tint),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    documents.length == 1
                        ? '${documents.first.label} has been updated'
                        : 'Terms and policies have been updated',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Review and accept when you get a moment.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

/// One row in the settings index. Declared as data rather than inline widgets
/// so the search field can filter across sections without every page having to
/// know how to match itself.
class _Entry {
  const _Entry({
    required this.section,
    required this.title,
    required this.icon,
    required this.path,
    this.keywords = '',
    this.trailing,
    this.extra,
  });

  final String section;
  final String title;
  final IconData icon;
  final String path;

  /// Handed to `context.push` - lets a row seed the page it opens with state
  /// this screen already fetched instead of making it re-fetch.
  final Object? extra;

  /// Extra words the row should match on that aren't in its title - so
  /// searching "password" finds Account, and "dark" finds Appearance.
  final String keywords;

  final String? trailing;

  bool matches(String query) =>
      title.toLowerCase().contains(query) ||
      keywords.toLowerCase().contains(query);
}

/// What the Log Out row matches on - the [_Entry.keywords] equivalent for the
/// one row that isn't an entry.
const _logOutKeywords = 'log out logout sign out signout leave account';

/// The settings index: search, grouped rows, log out. Everything that isn't
/// your public profile lives behind here, which is what lets
/// `SelfProfileScreen` stay a profile instead of the wall of forms it used to
/// be.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  UserDto? _account;

  @override
  void initState() {
    super.initState();
    _loadAccount();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAccount() async {
    try {
      final account = await getIt<AccountRepository>().getSelf();
      if (mounted) setState(() => _account = account);
    } catch (_) {
      // Only costs the 2FA row its On/Off subtitle and the consent banner.
    }
  }

  /// Documents whose current version this account hasn't accepted. Empty on a
  /// backend that predates versioned consent, which is the same as nothing to
  /// review - see `UserDto.consentRequired`.
  List<ConsentRequirementDto> get _consentRequired =>
      _account?.consentRequired ?? const [];

  Future<void> _confirmLogOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again on this device.'),
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
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    // The router's redirect drops back to /login the moment the session goes
    // unauthenticated, so there's nothing to pop here.
    await context.read<SessionCubit>().signOut();
  }

  List<_Entry> get _entries => [
    _Entry(
      section: 'Account Settings',
      title: 'Account',
      icon: Icons.person_outline,
      path: RoutePaths.accountSettings,
      keywords: 'password change devices sessions delete account email',
    ),
    _Entry(
      section: 'Account Settings',
      title: 'Two-Factor Authentication',
      icon: Icons.shield_outlined,
      path: RoutePaths.mfaSettings,
      keywords: '2fa mfa authenticator recovery codes security',
      trailing: _account == null ? null : (_account!.mfaEnabled ? 'On' : 'Off'),
      extra: _account?.mfaEnabled,
    ),
    const _Entry(
      section: 'Account Settings',
      title: 'Logged-in Devices',
      icon: Icons.devices_outlined,
      path: RoutePaths.devices,
      keywords: 'sessions sign out revoke computer phone browser security',
    ),
    const _Entry(
      section: 'Account Settings',
      title: 'Scan QR Code',
      icon: Icons.qr_code_scanner,
      path: RoutePaths.qrLogin,
      keywords: 'log in desktop web computer browser approve sign in camera',
    ),
    _Entry(
      section: 'Account Settings',
      title: 'Privacy',
      icon: Icons.lock_outline,
      path: RoutePaths.privacy,
      keywords:
          'blocked block dm direct messages friend requests discoverable '
          'visibility read receipts typing consent data export gdpr download '
          'terms policy legal telemetry personalisation personalization '
          'report reports safety moderation abuse harassment',
      trailing: _consentRequired.isEmpty
          ? null
          : '${_consentRequired.length} to review',
    ),
    const _Entry(
      section: 'App Settings',
      title: 'Appearance',
      icon: Icons.palette_outlined,
      path: RoutePaths.appearanceSettings,
      keywords: 'theme dark light mode',
    ),
    const _Entry(
      section: 'App Settings',
      title: 'Notifications',
      icon: Icons.notifications_outlined,
      path: RoutePaths.notificationSettings,
      keywords: 'push mentions sounds cooldown dm',
    ),
    const _Entry(
      section: 'App Settings',
      title: 'Your Profile',
      icon: Icons.badge_outlined,
      path: RoutePaths.editProfile,
      keywords: 'avatar banner bio status accent font',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final visible = query.isEmpty
        ? _entries
        : _entries.where((e) => e.matches(query)).toList();
    // Log Out isn't an `_Entry` (it acts in place rather than pushing a page),
    // which is exactly how it ended up rendering underneath the RESULTS of a
    // search it doesn't match. It filters like everything else now.
    final showLogOut = query.isEmpty || _logOutKeywords.contains(query);
    final sections = <String, List<_Entry>>{};
    for (final entry in visible) {
      sections
          .putIfAbsent(query.isEmpty ? entry.section : 'Results', () => [])
          .add(entry);
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Close',
          onPressed: () => BackNavigation.goBack(context, RoutePaths.home),
        ),
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.m,
          AppSpacing.s,
          AppSpacing.m,
          AppSpacing.xl,
        ),
        children: [
          // Above the search field, and only while something is outstanding:
          // an un-accepted policy is the one thing on this page the user is
          // being asked for rather than offered.
          if (_consentRequired.isNotEmpty && query.isEmpty) ...[
            _ConsentBanner(documents: _consentRequired),
            const SizedBox(height: AppSpacing.m),
          ],
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          if (visible.isEmpty && !showLogOut)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Center(
                child: Text(
                  'Nothing matches "${_query.trim()}"',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          for (final section in sections.entries) ...[
            SettingsSection(
              label: section.key,
              children: [
                for (final entry in section.value)
                  SettingsRow(
                    icon: entry.icon,
                    title: entry.title,
                    trailing: entry.trailing == null
                        ? null
                        : Text(entry.trailing!),
                    onTap: () => context.push(entry.path, extra: entry.extra),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.l),
          ],
          if (showLogOut)
            SettingsSection(
              children: [
                SettingsRow(
                  icon: Icons.logout,
                  title: 'Log Out',
                  destructive: true,
                  showChevron: false,
                  onTap: _confirmLogOut,
                ),
              ],
            ),
          const SizedBox(height: AppSpacing.m),
          // Which account these settings belong to - resolved rather than read
          // from cache, since this page can be the first thing a cold start
          // shows.
          SelfProfileResolver(
            builder: (context, profile) => Center(
              child: Text(
                profile == null ? '' : 'Signed in as ${profile.userName}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
