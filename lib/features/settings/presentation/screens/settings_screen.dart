import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/profile_resolver.dart';
import '../../../../core/widgets/settings_tiles.dart';
import '../../../auth/data/account_repository.dart';
import '../../../auth/data/models/user_dto.dart';

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
      // Only costs the 2FA row its On/Off subtitle.
    }
  }

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
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(RoutePaths.home),
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
          if (visible.isEmpty)
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
