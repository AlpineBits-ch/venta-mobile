import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/avatar_palette.dart';
import '../../../../core/theme/hex_color.dart';
import '../../../../core/theme/status_colors_extension.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../bloc/self_profile_cubit.dart';
import '../../data/models/profile_dto.dart';

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

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
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
