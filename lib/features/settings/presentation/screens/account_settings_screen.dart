import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/button_progress_indicator.dart';
import '../../../../core/widgets/profile_resolver.dart';
import '../../../../core/widgets/settings_tiles.dart';
import '../../../auth/data/account_repository.dart';
import '../../../auth/data/identity_api.dart';
import '../../../auth/data/models/user_dto.dart';

const _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June', //
  'July', 'August', 'September', 'October', 'November', 'December',
];

String _formatDate(DateTime dateTime) {
  final local = dateTime.toLocal();
  return '${_monthNames[local.month - 1]} ${local.day}, ${local.year}';
}

String _passwordCodeMessage(int code) {
  if (code >= 200 && code < 300) return 'Password changed successfully.';
  if (code == 401) return 'Current password is incorrect.';
  if (code == 422 || code == 400) {
    return 'New password does not meet requirements.';
  }
  if (code == 429) {
    return 'Too many attempts - please wait before trying again.';
  }
  return 'Something went wrong ($code).';
}

/// Credentials, sessions and account lifecycle - the security half of the old
/// combined profile-settings page. Nothing here changes how your profile looks
/// (that's `EditProfileScreen`).
class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  UserDto? _account;
  bool _accountActionInProgress = false;

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _passwordChanging = false;
  bool _signingOutOthers = false;

  @override
  void initState() {
    super.initState();
    _loadAccount();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadAccount() async {
    try {
      final account = await getIt<AccountRepository>().getSelf();
      if (mounted) setState(() => _account = account);
    } catch (_) {
      // Danger zone just stays hidden if this fails.
    }
  }

  bool get _passwordFormValid =>
      _currentPasswordController.text.isNotEmpty &&
      _newPasswordController.text.length >= 8 &&
      _newPasswordController.text == _confirmPasswordController.text;

  Future<void> _submitPasswordChange() async {
    if (!_passwordFormValid || _passwordChanging) return;
    setState(() => _passwordChanging = true);
    final code = await getIt<AccountRepository>().changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );
    if (!mounted) return;
    setState(() => _passwordChanging = false);
    if (code >= 200 && code < 300) {
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(_passwordCodeMessage(code))));
  }

  Future<void> _confirmSignOutOthers() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out of all other devices?'),
        content: const Text(
          'Every other session will be signed out. This device stays signed in.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign out others'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _signingOutOthers = true);
    try {
      await getIt<AccountRepository>().signOutOtherDevices();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signed out of all other devices.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not sign out other devices.')),
        );
      }
    } finally {
      if (mounted) setState(() => _signingOutOthers = false);
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete your account?'),
        content: const Text(
          'You will be signed out on any new login attempt right away. '
          'Everything else keeps working normally for 30 days, during which '
          'you can cancel. After that the deletion becomes permanent and '
          'cannot be undone.',
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
            child: const Text('Delete account'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _accountActionInProgress = true);
    try {
      final purgeScheduledAt = await getIt<AccountRepository>()
          .requestDeletion();
      if (!mounted) return;
      setState(() {
        _account = _account?.copyWith(
          status: UserStatus.pendingDeletion,
          purgeScheduledAt: purgeScheduledAt,
        );
        _accountActionInProgress = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _accountActionInProgress = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not delete your account.')),
        );
      }
    }
  }

  Future<void> _cancelDeleteAccount() async {
    setState(() => _accountActionInProgress = true);
    try {
      await getIt<AccountRepository>().cancelDeletion();
      if (!mounted) return;
      setState(() {
        _account = _account?.copyWith(
          status: UserStatus.active,
          deletionRequestedAt: null,
          purgeScheduledAt: null,
        );
        _accountActionInProgress = false;
      });
    } on DeletionNotCancellableException catch (e) {
      if (mounted) {
        setState(() => _accountActionInProgress = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
        _loadAccount();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _accountActionInProgress = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not cancel deletion.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackLocation: RoutePaths.settings),
        title: const Text('Account'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.m,
          AppSpacing.m,
          AppSpacing.m,
          AppSpacing.xl,
        ),
        children: [
          // Resolved, not read from the cache: this page can be cold-started
          // straight from a persisted route, with nothing having fetched the
          // self profile yet - which is why the username used to render as "-".
          SelfProfileResolver(
            builder: (context, profile) {
              final userId = profile?.userId ?? _account?.id;
              return SettingsSection(
                label: 'Who you are',
                children: [
                  SettingsRow(
                    icon: Icons.alternate_email,
                    title: 'Username',
                    trailing: profile == null
                        ? const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(profile.userName),
                    showChevron: false,
                  ),
                  // Subtitle, not trailing: ids are far too long to sit as a
                  // value on the right - full width and ellipsized is the
                  // readable shape, and there's a copy button because nobody
                  // retypes one of these.
                  SettingsRow(
                    icon: Icons.tag,
                    title: 'User ID',
                    subtitle: userId,
                    showChevron: false,
                    trailing: IconButton(
                      tooltip: 'Copy user ID',
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      onPressed: userId == null
                          ? null
                          : () {
                              Clipboard.setData(ClipboardData(text: userId));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('User ID copied.'),
                                ),
                              );
                            },
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.l),
          SettingsSection(
            label: 'Password',
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: _PasswordChangeForm(
                currentPasswordController: _currentPasswordController,
                newPasswordController: _newPasswordController,
                confirmPasswordController: _confirmPasswordController,
                obscureCurrentPassword: _obscureCurrentPassword,
                obscureNewPassword: _obscureNewPassword,
                onToggleObscureCurrent: () => setState(
                  () => _obscureCurrentPassword = !_obscureCurrentPassword,
                ),
                onToggleObscureNew: () =>
                    setState(() => _obscureNewPassword = !_obscureNewPassword),
                formValid: _passwordFormValid,
                submitting: _passwordChanging,
                onSubmit: _submitPasswordChange,
                onChanged: () => setState(() {}),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          SettingsSection(
            label: 'Devices',
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Signs out every session except this one.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  OutlinedButton(
                    onPressed: _signingOutOthers ? null : _confirmSignOutOthers,
                    child: _signingOutOthers
                        ? ButtonProgressIndicator(
                            onColor: theme.colorScheme.onSurface,
                          )
                        : const Text('Sign out of all other devices'),
                  ),
                ],
              ),
            ),
          ),
          if (_account != null) ...[
            const SizedBox(height: AppSpacing.l),
            _DangerZone(
              account: _account!,
              actionInProgress: _accountActionInProgress,
              onDelete: _confirmDeleteAccount,
              onCancelDeletion: _cancelDeleteAccount,
            ),
          ],
        ],
      ),
    );
  }
}

class _PasswordChangeForm extends StatelessWidget {
  const _PasswordChangeForm({
    required this.currentPasswordController,
    required this.newPasswordController,
    required this.confirmPasswordController,
    required this.obscureCurrentPassword,
    required this.obscureNewPassword,
    required this.onToggleObscureCurrent,
    required this.onToggleObscureNew,
    required this.formValid,
    required this.submitting,
    required this.onSubmit,
    required this.onChanged,
  });

  final TextEditingController currentPasswordController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  final bool obscureCurrentPassword;
  final bool obscureNewPassword;
  final VoidCallback onToggleObscureCurrent;
  final VoidCallback onToggleObscureNew;
  final bool formValid;
  final bool submitting;
  final VoidCallback onSubmit;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: currentPasswordController,
          obscureText: obscureCurrentPassword,
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            hintText: 'Current password',
            suffixIcon: IconButton(
              icon: Icon(
                obscureCurrentPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: onToggleObscureCurrent,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        TextField(
          controller: newPasswordController,
          obscureText: obscureNewPassword,
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            hintText: 'New password (min. 8 characters)',
            suffixIcon: IconButton(
              icon: Icon(
                obscureNewPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: onToggleObscureNew,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        TextField(
          controller: confirmPasswordController,
          obscureText: obscureNewPassword,
          onChanged: (_) => onChanged(),
          onSubmitted: (_) => formValid && !submitting ? onSubmit() : null,
          decoration: const InputDecoration(hintText: 'Confirm new password'),
        ),
        const SizedBox(height: AppSpacing.s),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: formValid && !submitting ? onSubmit : null,
            child: submitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Change password'),
          ),
        ),
      ],
    );
  }
}

/// Visually separated from the settings cards above it: error-tinted fill,
/// error-colored border and heading, and a full-width destructive button. The
/// point is that this block should not look like one more row you might tap by
/// accident on the way down the page.
class _DangerZone extends StatelessWidget {
  const _DangerZone({
    required this.account,
    required this.actionInProgress,
    required this.onDelete,
    required this.onCancelDeletion,
  });

  final UserDto account;
  final bool actionInProgress;
  final VoidCallback onDelete;
  final VoidCallback onCancelDeletion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final error = theme.colorScheme.error;

    final body = switch (account.status) {
      UserStatus.active => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Deleting your account starts a 30-day countdown. You can cancel '
            'during that window; after it, everything is gone for good.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: error,
              foregroundColor: theme.colorScheme.onError,
            ),
            onPressed: actionInProgress ? null : onDelete,
            icon: const Icon(Icons.delete_forever_outlined, size: 18),
            label: const Text('Delete my account'),
          ),
        ],
      ),
      UserStatus.pendingDeletion => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            account.purgeScheduledAt != null
                ? 'Your account is scheduled for deletion on '
                      '${_formatDate(account.purgeScheduledAt!)}.'
                : 'Your account is scheduled for deletion.',
            style: theme.textTheme.bodyMedium?.copyWith(color: error),
          ),
          const SizedBox(height: AppSpacing.m),
          FilledButton(
            onPressed: actionInProgress ? null : onCancelDeletion,
            child: const Text('Cancel deletion'),
          ),
        ],
      ),
      UserStatus.purgeInProgress ||
      UserStatus.deleted ||
      UserStatus.inactive ||
      UserStatus.banned => null,
    };
    if (body == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: error.withValues(alpha: 0.08),
        border: Border.all(color: error.withValues(alpha: 0.45)),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 18, color: error),
              const SizedBox(width: AppSpacing.s),
              Text(
                'DANGER ZONE',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: error,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          body,
        ],
      ),
    );
  }
}
