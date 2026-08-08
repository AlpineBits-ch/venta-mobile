import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/format/phone_number.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/button_progress_indicator.dart';
import '../../../../core/widgets/profile_resolver.dart';
import '../../../../core/widgets/settings_tiles.dart';
import '../../../../core/widgets/shimmer_box.dart';
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

  final _phoneController = TextEditingController();

  /// What the server has, which is not the same thing as what is in the field.
  /// Seeded from the account read and then replaced with whatever the server
  /// echoes back on save, because the stored form is the one other people see.
  String? _savedPhone;
  bool _phoneSaving = false;
  bool _phoneRemoving = false;

  /// Distinguishes "still loading" from "the read failed" - the first gets a
  /// skeleton, the second gets a usable empty field rather than a skeleton
  /// that never resolves.
  bool _accountLoadFailed = false;

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
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadAccount() async {
    try {
      final account = await getIt<AccountRepository>().getSelf();
      if (!mounted) return;
      setState(() {
        _account = account;
        _accountLoadFailed = false;
        _savedPhone = account.phoneNumber;
        // Only while nobody is mid-edit: a background refresh must not eat
        // half-typed digits.
        if (!_phoneSaving && !_phoneRemoving) {
          _phoneController.text = account.phoneNumber ?? '';
        }
      });
    } catch (_) {
      // Danger zone just stays hidden if this fails; the phone field falls
      // back to an empty one you can still type into.
      if (mounted) setState(() => _accountLoadFailed = true);
    }
  }

  Future<void> _savePhone() async {
    final typed = _phoneController.text.trim();
    if (typed.isEmpty || phoneNumberProblem(typed) != null || _phoneSaving) {
      return;
    }
    setState(() => _phoneSaving = true);
    try {
      final stored = await getIt<AccountRepository>().setPhoneNumber(typed);
      if (!mounted) return;
      setState(() {
        _phoneSaving = false;
        _savedPhone = stored;
        _account = _account?.copyWith(phoneNumber: stored);
        // Snapped to the server's spelling, so the field and every other
        // member's screen are showing the same string.
        if (stored != null) _phoneController.text = stored;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Phone number saved.')));
    } on PhoneNumberRejectedException catch (e) {
      if (!mounted) return;
      setState(() => _phoneSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _phoneSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save your phone number.')),
      );
    }
  }

  Future<void> _confirmRemovePhone() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove your phone number?'),
        content: const Text(
          'This takes the number off your account and switches sharing off in '
          'every household, so nobody sees it anywhere. If you add a number '
          'here later, you choose which households see it again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep it'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _phoneRemoving = true);
    try {
      await getIt<AccountRepository>().removePhoneNumber();
      if (!mounted) return;
      setState(() {
        _phoneRemoving = false;
        _savedPhone = null;
        _account = _account?.copyWith(phoneNumber: null);
        _phoneController.clear();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Phone number removed.')));
    } catch (_) {
      if (!mounted) return;
      setState(() => _phoneRemoving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not remove your phone number.')),
      );
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
          // Account data, not profile data: it belongs to the person rather
          // than to any one household, it is the same field a future SMS
          // second factor would read, and putting it here is what makes the
          // per-household sharing switch in the ledger mean something. A
          // number entered in one place and shared nowhere is the default.
          SettingsSection(
            label: 'Phone number',
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: PhoneNumberCard(
                controller: _phoneController,
                saved: _savedPhone,
                loading: _account == null && !_accountLoadFailed,
                saving: _phoneSaving,
                removing: _phoneRemoving,
                onChanged: () => setState(() {}),
                onSave: _savePhone,
                onRemove: _confirmRemovePhone,
              ),
            ),
          ),
          const SettingsFootnote(
            'Nobody sees this until you switch it on inside a household, one '
            'household at a time - it is off everywhere by default. Removing '
            'the number switches that off again everywhere; changing it '
            'leaves your households as they are. It is stored as ordinary '
            'text that our servers can read, and nothing anywhere checks that '
            'the number is yours or that it still works.',
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
            children: [
              // The itemised view, where you can see which device you're
              // signing out before doing it. The blunt instrument below stays
              // for when you don't care which.
              SettingsRow(
                icon: Icons.devices_outlined,
                title: 'Logged-in devices',
                onTap: () => context.push(RoutePaths.devices),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Signs out every session except this one.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s),
                    OutlinedButton(
                      onPressed: _signingOutOthers
                          ? null
                          : _confirmSignOutOthers,
                      child: _signingOutOthers
                          ? ButtonProgressIndicator(
                              onColor: theme.colorScheme.onSurface,
                            )
                          : const Text('Sign out of all other devices'),
                    ),
                  ],
                ),
              ),
            ],
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

/// The account's phone number: enter it, change it, take it away again.
///
/// Presentational on purpose - it owns no repository and no futures, so the
/// layout test can pump it at every text size in both themes without a
/// container. The screen above holds the controller and does the talking.
///
/// Three things this must never do, in rough order of how much damage they'd
/// cause:
///
///  * claim the number has been checked. Nothing checks it. There is no SMS,
///    no call, and no flag on the account that could carry the answer even if
///    there were.
///  * quietly convert `0041…` into `+41…`. See `phoneNumberProblem` - the
///    conversion is wrong in enough countries to produce a stranger's live
///    number, so the field explains the `+` and waits.
///  * hide removal. Somebody who wants their number off this account is
///    usually in a hurry, and a delete buried behind an edit flow is a delete
///    that gets abandoned.
class PhoneNumberCard extends StatelessWidget {
  const PhoneNumberCard({
    super.key,
    required this.controller,
    required this.saved,
    required this.onChanged,
    required this.onSave,
    required this.onRemove,
    this.loading = false,
    this.saving = false,
    this.removing = false,
  });

  final TextEditingController controller;

  /// The E.164 string the server currently holds, or null for no number.
  final String? saved;

  final VoidCallback onChanged;
  final VoidCallback onSave;
  final VoidCallback onRemove;

  /// The account hasn't been read yet - a skeleton in the shape of the field,
  /// rather than a spinner that says nothing about what is coming.
  final bool loading;

  final bool saving;
  final bool removing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    if (loading) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ExcludeSemantics(
            child: ShimmerBox(height: 52, borderRadius: AppRadii.input),
          ),
          SizedBox(height: AppSpacing.m),
          ExcludeSemantics(
            child: ShimmerBox(
              width: 180,
              height: 14,
              borderRadius: AppRadii.badge,
            ),
          ),
        ],
      );
    }

    final typed = controller.text.trim();
    final problem = phoneNumberProblem(typed);
    final normalized = normalizePhoneNumber(typed);
    final busy = saving || removing;
    final changed = normalized != saved;
    final canSave = typed.isNotEmpty && problem == null && changed && !busy;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          onChanged: (_) => onChanged(),
          onSubmitted: (_) => canSave ? onSave() : null,
          enabled: !busy,
          keyboardType: TextInputType.phone,
          autofillHints: const [AutofillHints.telephoneNumber],
          decoration: InputDecoration(
            hintText: phoneNumberExample,
            errorText: problem,
            // These sentences are long because the short version ("invalid
            // number") is the one that leaves people stuck. They must be
            // allowed to wrap rather than ellipsize.
            errorMaxLines: 8,
            helperText: problem == null
                ? 'Starts with + and the country code.'
                : null,
            helperMaxLines: 2,
            prefixIcon: const Icon(Icons.phone_outlined),
          ),
        ),
        // The server takes the spaces out, so a number typed with them is
        // about to look different to everybody else. Saying so beforehand
        // stops the save looking like it changed something.
        if (normalized != null && normalized != typed) ...[
          const SizedBox(height: AppSpacing.s),
          Text(
            'Stored as $normalized.',
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
          ),
        ],
        const SizedBox(height: AppSpacing.m),
        FilledButton(
          // A floor rather than a fixed height: 48pt is the target size, and a
          // label that has grown past it with the reader's text size needs the
          // button to grow with it instead of clipping.
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          onPressed: canSave ? onSave : null,
          child: saving
              ? ButtonProgressIndicator(onColor: theme.colorScheme.onPrimary)
              : Text(saved == null ? 'Save number' : 'Save changes'),
        ),
        // Never behind an overflow menu or an edit mode. Somebody taking their
        // number off this account usually wants it gone now.
        if (saved != null) ...[
          const SizedBox(height: AppSpacing.s),
          OutlinedButton.icon(
            onPressed: busy ? null : onRemove,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(
                color: theme.colorScheme.error.withValues(alpha: 0.5),
              ),
            ),
            icon: removing
                ? ButtonProgressIndicator(onColor: theme.colorScheme.error)
                : const Icon(Icons.delete_outline_rounded, size: 18),
            label: const Text('Remove my number'),
          ),
        ],
      ],
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
