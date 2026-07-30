import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/avatar_palette.dart';
import '../../../../core/theme/hex_color.dart';
import '../../../../core/theme/status_colors_extension.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../auth/data/account_repository.dart';
import '../../../auth/data/identity_api.dart';
import '../../../auth/data/models/notification_settings_dto.dart';
import '../../../auth/data/models/user_dto.dart';
import '../../bloc/self_profile_cubit.dart';
import '../../data/models/profile_dto.dart';

const _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June', //
  'July', 'August', 'September', 'October', 'November', 'December',
];

String _formatDate(DateTime dateTime) {
  final local = dateTime.toLocal();
  return '${_monthNames[local.month - 1]} ${local.day}, ${local.year}';
}

const _accentSwatches = <String>[
  '#7C72FF', // brand
  '#F43F5E', // rose
  '#FB923C', // orange
  '#FBBF24', // amber
  '#34D399', // emerald
  '#22D3EE', // cyan
  '#60A5FA', // blue
  '#C084FC', // purple
  '#F472B6', // pink
  '#94A3B8', // slate
];

TextStyle _fontPreviewStyle(ProfileFont font) => switch (font) {
  ProfileFont.defaultFont => GoogleFonts.inter(),
  ProfileFont.serif => GoogleFonts.merriweather(),
  ProfileFont.monospace => GoogleFonts.robotoMono(),
  ProfileFont.rounded => GoogleFonts.varelaRound(),
  ProfileFont.display => GoogleFonts.oswald(),
  ProfileFont.handwritten => GoogleFonts.caveat(
    textStyle: const TextStyle(fontSize: 20),
  ),
};

String _fontLabel(ProfileFont font) => switch (font) {
  ProfileFont.defaultFont => 'Default',
  ProfileFont.serif => 'Serif',
  ProfileFont.monospace => 'Monospace',
  ProfileFont.rounded => 'Rounded',
  ProfileFont.display => 'Display',
  ProfileFont.handwritten => 'Handwritten',
};

String _passwordCodeMessage(int code) {
  if (code >= 200 && code < 300) return 'Password changed successfully.';
  if (code == 401) return 'Current password is incorrect.';
  if (code == 422 || code == 400) return 'New password does not meet requirements.';
  if (code == 429) return 'Too many attempts - please wait before trying again.';
  return 'Something went wrong ($code).';
}

String _statusLabel(OnlineStatus status) => switch (status) {
  OnlineStatus.online => 'Online',
  OnlineStatus.idle => 'Idle',
  OnlineStatus.doNotDisturb => 'Do Not Disturb',
  OnlineStatus.hidden => 'Invisible',
  OnlineStatus.offline => 'Offline',
};

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _bioController = TextEditingController();
  final _picker = ImagePicker();
  bool _bioDirty = false;
  String? _seededProfileId;

  UserDto? _account;
  bool _accountActionInProgress = false;

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _passwordChanging = false;
  bool _signingOutOthers = false;

  NotificationSettingsDto _notificationSettings =
      const NotificationSettingsDto();
  bool _notificationSettingsSaving = false;

  @override
  void initState() {
    super.initState();
    _loadAccount();
    _loadNotificationSettings();
  }

  @override
  void dispose() {
    _bioController.dispose();
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
      // Danger-zone section just stays hidden if this fails.
    }
  }

  Future<void> _loadNotificationSettings() async {
    try {
      final settings = await getIt<AccountRepository>()
          .getNotificationSettings();
      if (mounted) setState(() => _notificationSettings = settings);
    } catch (_) {
      // Keep defaults if this fails.
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

  Future<void> _applyNotificationSettings(
    NotificationSettingsDto settings,
  ) async {
    setState(() {
      _notificationSettings = settings;
      _notificationSettingsSaving = true;
    });
    try {
      await getIt<AccountRepository>().updateNotificationSettings(settings);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save notification settings.')),
        );
      }
    } finally {
      if (mounted) setState(() => _notificationSettingsSaving = false);
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

  void _seedBio(ProfileDto profile) {
    if (_seededProfileId == profile.id && !_bioDirty) return;
    if (_seededProfileId != profile.id) {
      _bioController.text = profile.bio ?? '';
      _seededProfileId = profile.id;
    }
  }

  Future<void> _pickAvatar(BuildContext context) async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;
    if (context.mounted) {
      context.read<SelfProfileCubit>().uploadAvatar(file.path);
    }
  }

  Future<void> _pickBanner(BuildContext context) async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;
    if (context.mounted) {
      context.read<SelfProfileCubit>().uploadBanner(file.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Your Profile')),
      body: BlocConsumer<SelfProfileCubit, SelfProfileState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          final profile = state.profile;
          if (profile == null) {
            return const Center(child: CircularProgressIndicator());
          }
          _seedBio(profile);
          final accentColor = profile.accentColor != null
              ? parseHexColor(profile.accentColor!)
              : theme.colorScheme.primary;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              _BannerAndAvatar(
                profile: profile,
                accentColor: accentColor,
                onTapBanner: () => _pickBanner(context),
                onTapAvatar: () => _pickAvatar(context),
                onRemoveAvatar: () =>
                    context.read<SelfProfileCubit>().removeAvatar(),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.userName, style: theme.textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.l),
                    Text('STATUS', style: theme.textTheme.labelSmall),
                    const SizedBox(height: AppSpacing.s),
                    _StatusPicker(current: profile.onlineStatus),
                    const SizedBox(height: AppSpacing.l),
                    Text('BIO', style: theme.textTheme.labelSmall),
                    const SizedBox(height: AppSpacing.s),
                    TextField(
                      controller: _bioController,
                      maxLines: 3,
                      maxLength: 190,
                      onChanged: (_) => setState(() => _bioDirty = true),
                      decoration: const InputDecoration(
                        hintText: 'Tell people about yourself',
                      ),
                    ),
                    if (_bioDirty)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: state.isSaving
                              ? null
                              : () {
                                  context
                                      .read<SelfProfileCubit>()
                                      .updateProfile(
                                        bio: _bioController.text.trim(),
                                      );
                                  setState(() => _bioDirty = false);
                                },
                          child: const Text('Save bio'),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.l),
                    Text('ACCENT COLOR', style: theme.textTheme.labelSmall),
                    const SizedBox(height: AppSpacing.s),
                    _AccentColorPicker(
                      current: profile.accentColor,
                      onSelected: (hex) => context
                          .read<SelfProfileCubit>()
                          .updateProfile(accentColor: hex),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    Text('FONT', style: theme.textTheme.labelSmall),
                    const SizedBox(height: AppSpacing.s),
                    _FontPicker(
                      current: profile.font,
                      onSelected: (font) => context
                          .read<SelfProfileCubit>()
                          .updateProfile(font: font),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    const Divider(),
                    const SizedBox(height: AppSpacing.s),
                    Text('SECURITY', style: theme.textTheme.labelSmall),
                    const SizedBox(height: AppSpacing.s),
                    _PasswordChangeForm(
                      currentPasswordController: _currentPasswordController,
                      newPasswordController: _newPasswordController,
                      confirmPasswordController: _confirmPasswordController,
                      obscureCurrentPassword: _obscureCurrentPassword,
                      obscureNewPassword: _obscureNewPassword,
                      onToggleObscureCurrent: () => setState(
                        () => _obscureCurrentPassword =
                            !_obscureCurrentPassword,
                      ),
                      onToggleObscureNew: () => setState(
                        () => _obscureNewPassword = !_obscureNewPassword,
                      ),
                      formValid: _passwordFormValid,
                      submitting: _passwordChanging,
                      onSubmit: _submitPasswordChange,
                      onChanged: () => setState(() {}),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    OutlinedButton(
                      onPressed: _signingOutOthers
                          ? null
                          : _confirmSignOutOthers,
                      child: _signingOutOthers
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Sign out of all other devices'),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    const Divider(),
                    const SizedBox(height: AppSpacing.s),
                    Text('NOTIFICATIONS', style: theme.textTheme.labelSmall),
                    _NotificationSettingsSection(
                      settings: _notificationSettings,
                      saving: _notificationSettingsSaving,
                      onChanged: _applyNotificationSettings,
                    ),
                    if (_account != null) ...[
                      const SizedBox(height: AppSpacing.l),
                      const Divider(),
                      const SizedBox(height: AppSpacing.s),
                      Text('DANGER ZONE', style: theme.textTheme.labelSmall),
                      const SizedBox(height: AppSpacing.s),
                      _DangerZone(
                        account: _account!,
                        actionInProgress: _accountActionInProgress,
                        onDelete: _confirmDeleteAccount,
                        onCancelDeletion: _cancelDeleteAccount,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BannerAndAvatar extends StatelessWidget {
  const _BannerAndAvatar({
    required this.profile,
    required this.accentColor,
    required this.onTapBanner,
    required this.onTapAvatar,
    required this.onRemoveAvatar,
  });

  final ProfileDto profile;
  final Color accentColor;
  final VoidCallback onTapBanner;
  final VoidCallback onTapAvatar;
  final VoidCallback onRemoveAvatar;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: onTapBanner,
            child: Container(
              height: 110,
              width: double.infinity,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.35),
                image: profile.bannerUrl != null
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(profile.bannerUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: profile.bannerUrl == null
                  ? Center(
                      child: Icon(
                        Icons.add_photo_alternate_outlined,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    )
                  : null,
            ),
          ),
          Positioned(
            left: AppSpacing.m,
            bottom: 0,
            child: GestureDetector(
              onTap: onTapAvatar,
              onLongPress: profile.avatarUrl != null ? onRemoveAvatar : null,
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 4,
                  ),
                  color: AvatarPalette.colorForUserId(profile.userId),
                  image: profile.avatarUrl != null
                      ? DecorationImage(
                          image: CachedNetworkImageProvider(profile.avatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: profile.avatarUrl == null
                    ? Center(
                        child: Text(
                          profile.userName.isNotEmpty
                              ? profile.userName[0].toUpperCase()
                              : '?',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(color: Colors.white),
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPicker extends StatelessWidget {
  const _StatusPicker({required this.current});
  final OnlineStatus current;

  static const _options = [
    OnlineStatus.online,
    OnlineStatus.idle,
    OnlineStatus.doNotDisturb,
    OnlineStatus.hidden,
  ];

  Color _dotColor(BuildContext context, OnlineStatus status) =>
      switch (status) {
        OnlineStatus.online => context.statusColors.online,
        OnlineStatus.idle => context.statusColors.idle,
        OnlineStatus.doNotDisturb => context.statusColors.doNotDisturb,
        OnlineStatus.hidden ||
        OnlineStatus.offline => context.statusColors.offline,
      };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.s,
      runSpacing: AppSpacing.s,
      children: [
        for (final status in _options)
          ChoiceChip(
            selected: status == current,
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _dotColor(context, status),
                  ),
                ),
                const SizedBox(width: 6),
                Text(_statusLabel(status)),
              ],
            ),
            onSelected: (_) =>
                context.read<SelfProfileCubit>().setStatus(status),
          ),
      ],
    );
  }
}

class _AccentColorPicker extends StatelessWidget {
  const _AccentColorPicker({required this.current, required this.onSelected});
  final String? current;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.s,
      runSpacing: AppSpacing.s,
      children: [
        for (final hex in _accentSwatches)
          GestureDetector(
            onTap: () => onSelected(hex),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: parseHexColor(hex),
                shape: BoxShape.circle,
                border: current?.toUpperCase() == hex.toUpperCase()
                    ? Border.all(
                        color: Theme.of(context).colorScheme.onSurface,
                        width: 2,
                      )
                    : null,
              ),
            ),
          ),
      ],
    );
  }
}

class _FontPicker extends StatelessWidget {
  const _FontPicker({required this.current, required this.onSelected});
  final ProfileFont current;
  final ValueChanged<ProfileFont> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RadioGroup<ProfileFont>(
      groupValue: current,
      onChanged: (value) {
        if (value != null) onSelected(value);
      },
      child: Column(
        children: [
          for (final font in ProfileFont.values)
            RadioListTile<ProfileFont>(
              contentPadding: EdgeInsets.zero,
              value: font,
              title: Text(
                _fontLabel(font),
                style: _fontPreviewStyle(
                  font,
                ).copyWith(fontSize: 16, color: theme.colorScheme.onSurface),
              ),
            ),
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

class _NotificationSettingsSection extends StatelessWidget {
  const _NotificationSettingsSection({
    required this.settings,
    required this.saving,
    required this.onChanged,
  });

  final NotificationSettingsDto settings;
  final bool saving;
  final ValueChanged<NotificationSettingsDto> onChanged;

  static const _cooldownOptions = [5, 10, 15, 30, 60, 120, 300];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Notifications enabled'),
          value: settings.enabled,
          onChanged: saving
              ? null
              : (value) => onChanged(settings.copyWith(enabled: value)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Direct messages'),
          value: settings.dm,
          onChanged: saving
              ? null
              : (value) => onChanged(settings.copyWith(dm: value)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Mentions'),
          value: settings.mentions,
          onChanged: saving
              ? null
              : (value) => onChanged(settings.copyWith(mentions: value)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Sounds'),
          value: settings.sounds,
          onChanged: saving
              ? null
              : (value) => onChanged(settings.copyWith(sounds: value)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Notification cooldown'),
          subtitle: const Text('Limit how often notifications can repeat'),
          value: settings.cooldownEnabled,
          onChanged: saving
              ? null
              : (value) =>
                    onChanged(settings.copyWith(cooldownEnabled: value)),
        ),
        if (settings.cooldownEnabled) ...[
          const SizedBox(height: AppSpacing.s),
          DropdownButtonFormField<int>(
            initialValue: _cooldownOptions.contains(settings.cooldownSeconds)
                ? settings.cooldownSeconds
                : _cooldownOptions.first,
            decoration: const InputDecoration(labelText: 'Cooldown length'),
            items: [
              for (final seconds in _cooldownOptions)
                DropdownMenuItem(
                  value: seconds,
                  child: Text(
                    seconds < 60 ? '$seconds seconds' : '${seconds ~/ 60} minute(s)',
                  ),
                ),
            ],
            onChanged: saving
                ? null
                : (value) => onChanged(
                    settings.copyWith(cooldownSeconds: value ?? settings.cooldownSeconds),
                  ),
          ),
        ],
      ],
    );
  }
}

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
    switch (account.status) {
      case UserStatus.active:
        return OutlinedButton(
          style: OutlinedButton.styleFrom(foregroundColor: theme.colorScheme.error),
          onPressed: actionInProgress ? null : onDelete,
          child: const Text('Delete my account'),
        );
      case UserStatus.pendingDeletion:
        final purgeDate = account.purgeScheduledAt;
        return Container(
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                purgeDate != null
                    ? 'Your account is scheduled for deletion on '
                          '${_formatDate(purgeDate)}.'
                    : 'Your account is scheduled for deletion.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
              const SizedBox(height: AppSpacing.s),
              FilledButton(
                onPressed: actionInProgress ? null : onCancelDeletion,
                child: const Text('Cancel deletion'),
              ),
            ],
          ),
        );
      case UserStatus.purgeInProgress:
      case UserStatus.deleted:
      case UserStatus.inactive:
      case UserStatus.banned:
        return const SizedBox.shrink();
    }
  }
}
