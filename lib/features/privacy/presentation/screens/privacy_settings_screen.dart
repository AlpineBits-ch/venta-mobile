import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/network/privacy_refusal.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/settings_tiles.dart';
import '../../data/models/privacy_settings_dto.dart';
import '../../data/privacy_repository.dart';
import '../widgets/privacy_choice_row.dart';

/// Everything the account can decide about who reaches it, what it shares, and
/// what may be done with its data.
///
/// Saves on every control, like `NotificationSettingsScreen` - no Save button,
/// because each switch here is independently meaningful and a privacy setting
/// the user believes they changed and didn't is the worst possible failure
/// mode for this screen in particular. The write is a sparse `PATCH` of the one
/// field, so two clients touching different settings never clobber each other.
///
/// Nothing here is the enforcement point. Every one of these is applied
/// server-side; the screen's job is to state the current answer honestly and to
/// report a refusal rather than swallow it.
class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  static const _retentionOptions = <int?>[null, 1, 7, 30, 90, 365];

  PrivacySettingsDto? _settings;
  bool _loading = true;
  bool _saving = false;
  String? _loadError;

  /// Fields the server has refused with `minor_restriction` this session.
  ///
  /// `GET /privacy-settings` carries no "this account is a minor" flag - the
  /// floors are applied by clamping the values it returns, which is
  /// indistinguishable from an adult who chose those values. So the first
  /// refusal is where the client finds out, and from then on the control is
  /// locked with a reason rather than left to bounce again. [PrivacySettingsDto.isMinor]
  /// stays honoured for the day the record does say so.
  final Set<String> _minorLocked = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final settings = await getIt<PrivacyRepository>().fetch();
      if (!mounted) return;
      setState(() {
        _settings = settings;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        // No partial screen: rendering the restrictive defaults as though they
        // were this account's settings would show someone "Nobody" for a
        // policy they have set to "Everyone", which is worse than an error.
        _loadError = 'Could not load your privacy settings.';
      });
    }
  }

  /// Applies one field. [changes] is the wire-shaped patch body.
  ///
  /// Optimistic, with [optimistic] describing what the row should look like
  /// while the write is in flight - a switch that waits a round-trip before
  /// moving reads as broken. A refusal or a failure puts the old value back.
  Future<void> _patch(
    Map<String, dynamic> changes, {
    required PrivacySettingsDto optimistic,
  }) async {
    final previous = _settings;
    setState(() {
      _settings = optimistic;
      _saving = true;
    });
    try {
      final saved = await getIt<PrivacyRepository>().update(changes);
      if (!mounted) return;
      setState(() => _settings = saved);
      // Consent to telemetry takes effect on the next report, not the next
      // launch - see `applyTelemetryConsent`.
      if (changes.containsKey('allowDataCollection')) {
        unawaited(applyTelemetryConsent());
      }
    } on PrivacyRefusalException catch (e) {
      if (!mounted) return;
      setState(() {
        _settings = previous;
        final field = e.field;
        if (e.refusal == PrivacyRefusal.minorRestriction && field != null) {
          _minorLocked.add(field);
        }
      });
      _toast(e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _settings = previous);
      _toast('Could not save that setting.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _toast(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  /// The one-liner under a control the account's age locks. Written without
  /// naming an age: the server decides what a minor is per jurisdiction, and a
  /// client that hardcodes "under 18" will be wrong somewhere.
  static const _minorNote = 'Not available on this account.';

  /// Whether [field] is locked by a minor floor, from the record if it says so
  /// and otherwise from a refusal already met.
  bool _locked(String field) =>
      (_settings?.lockedForMinor(field) ?? false) ||
      _minorLocked.contains(field);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackLocation: RoutePaths.settings),
        title: const Text('Privacy'),
      ),
      body: switch ((_loading, _loadError, _settings)) {
        (true, _, _) => const Center(child: CircularProgressIndicator()),
        (_, final String error, _) => _LoadFailure(
          message: error,
          onRetry: _load,
        ),
        (_, _, final PrivacySettingsDto settings) => _body(settings),
        _ => _LoadFailure(
          message: 'Could not load your privacy settings.',
          onRetry: _load,
        ),
      },
    );
  }

  Widget _body(PrivacySettingsDto s) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.xl,
      ),
      children: [
        if (s.isMinor || _minorLocked.isNotEmpty) ...[
          const _MinorBanner(),
          const SizedBox(height: AppSpacing.l),
        ],

        // ── Who can reach you ────────────────────────────────────────────
        SettingsSection(
          label: 'Who can reach you',
          children: [
            PrivacyChoiceRow<DirectMessagePolicy>(
              icon: Icons.chat_bubble_outline,
              title: 'Direct messages',
              value: s.directMessagePolicy,
              options: DirectMessagePolicy.values,
              labelOf: (v) => v.label,
              descriptionOf: (v) => v.description,
              unavailable: _locked('directMessagePolicy')
                  ? const {DirectMessagePolicy.everyone}
                  : const {},
              unavailableNote: _minorNote,
              onChanged: (v) => _patch({
                'directMessagePolicy': v.name.pascal,
              }, optimistic: s.copyWith(directMessagePolicy: v)),
            ),
            PrivacyChoiceRow<FriendRequestPolicy>(
              icon: Icons.person_add_alt_1_outlined,
              title: 'Friend requests',
              value: s.friendRequestPolicy,
              options: FriendRequestPolicy.values,
              labelOf: (v) => v.label,
              onChanged: (v) => _patch({
                'friendRequestPolicy': v.name.pascal,
              }, optimistic: s.copyWith(friendRequestPolicy: v)),
            ),
            SettingsRow(
              icon: Icons.dns_outlined,
              title: 'Server message privacy',
              subtitle: 'Turn direct messages off for individual servers',
              onTap: () => context.push(RoutePaths.guildDmPrivacy),
            ),
            SettingsRow(
              icon: Icons.block,
              title: 'Blocked users',
              onTap: () => context.push(RoutePaths.blockedUsers),
            ),
          ],
        ),
        const SettingsFootnote(
          'Blocking someone stops them reaching you anywhere - messages, '
          'friend requests, calls and mentions. They are not told.',
        ),
        const SizedBox(height: AppSpacing.l),

        // ── Discoverability ──────────────────────────────────────────────
        SettingsSection(
          label: 'How people find you',
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('By username'),
                subtitle: const Text('An exact-username search finds you'),
                value: s.discoverableByUsername,
                onChanged: _saving
                    ? null
                    : (v) => _patch({
                        'discoverableByUsername': v,
                      }, optimistic: s.copyWith(discoverableByUsername: v)),
              ),
              _MinorLockableSwitch(
                title: 'By email address',
                value: s.discoverableByEmail,
                locked: _locked('discoverableByEmail'),
                enabled: !_saving,
                onChanged: (v) => _patch({
                  'discoverableByEmail': v,
                }, optimistic: s.copyWith(discoverableByEmail: v)),
              ),
              _MinorLockableSwitch(
                title: 'By phone number',
                value: s.discoverableByPhone,
                locked: _locked('discoverableByPhone'),
                enabled: !_saving,
                onChanged: (v) => _patch({
                  'discoverableByPhone': v,
                }, optimistic: s.copyWith(discoverableByPhone: v)),
              ),
            ],
          ),
        ),
        const SettingsFootnote(
          'When a lookup is turned off, it returns the same "not found" as a '
          'username that never existed.',
        ),
        const SizedBox(height: AppSpacing.l),

        // ── Profile visibility ───────────────────────────────────────────
        SettingsSection(
          label: 'On your profile',
          children: [
            PrivacyChoiceRow<ProfileVisibility>(
              icon: Icons.dns_outlined,
              title: 'Servers in common',
              value: s.mutualServersVisibility,
              options: ProfileVisibility.values,
              labelOf: (v) => v.label,
              onChanged: (v) => _patch({
                'mutualServersVisibility': v.name.pascal,
              }, optimistic: s.copyWith(mutualServersVisibility: v)),
            ),
            PrivacyChoiceRow<ProfileVisibility>(
              icon: Icons.people_outline,
              title: 'Friends in common',
              value: s.mutualFriendsVisibility,
              options: ProfileVisibility.values,
              labelOf: (v) => v.label,
              onChanged: (v) => _patch({
                'mutualFriendsVisibility': v.name.pascal,
              }, optimistic: s.copyWith(mutualFriendsVisibility: v)),
            ),
            PrivacyChoiceRow<ProfileVisibility>(
              icon: Icons.link,
              title: 'Connections',
              value: s.connectionsVisibility,
              options: ProfileVisibility.values,
              labelOf: (v) => v.label,
              onChanged: (v) => _patch({
                'connectionsVisibility': v.name.pascal,
              }, optimistic: s.copyWith(connectionsVisibility: v)),
            ),
            PrivacyChoiceRow<ProfileVisibility>(
              icon: Icons.cake_outlined,
              title: 'Birthday',
              value: s.birthdayVisibility,
              options: ProfileVisibility.values,
              labelOf: (v) => v.label,
              onChanged: (v) => _patch({
                'birthdayVisibility': v.name.pascal,
              }, optimistic: s.copyWith(birthdayVisibility: v)),
            ),
          ],
        ),
        const SettingsFootnote(
          'A field you hide is left out of your profile entirely, not hidden '
          'by the app that displays it.',
        ),
        const SizedBox(height: AppSpacing.l),

        // ── Activity and voice ───────────────────────────────────────────
        SettingsSection(
          label: 'Activity and voice',
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Share what I\'m playing'),
                subtitle: const Text('Shows on your profile and in servers'),
                value: s.shareActivity,
                onChanged: _saving
                    ? null
                    : (v) => _patch({
                        'shareActivity': v,
                      }, optimistic: s.copyWith(shareActivity: v)),
              ),
              SwitchListTile(
                title: const Text('Proximity voice'),
                subtitle: const Text(
                  'Lets in-game voice be heard by players near you',
                ),
                value: s.allowPositionalVoiceCapture,
                onChanged: _saving
                    ? null
                    : (v) => _patch(
                        {'allowPositionalVoiceCapture': v},
                        optimistic: s.copyWith(allowPositionalVoiceCapture: v),
                      ),
              ),
              _MinorLockableSwitch(
                title: 'Allow my voice in clips',
                subtitle:
                    'Whether recordings others make may include your voice',
                value: s.allowVoiceRecordingInClips,
                locked: _locked('allowVoiceRecordingInClips'),
                enabled: !_saving,
                onChanged: (v) => _patch({
                  'allowVoiceRecordingInClips': v,
                }, optimistic: s.copyWith(allowVoiceRecordingInClips: v)),
              ),
            ],
          ),
        ),
        const SettingsFootnote(
          'Turning clip recording on is not consent to any particular '
          'recording - you are still asked at the time, every time.',
        ),
        const SizedBox(height: AppSpacing.l),

        // ── Messages ─────────────────────────────────────────────────────
        SettingsSection(
          label: 'Messages',
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Send read receipts'),
                subtitle: const Text(
                  'Off means you don\'t see others\' either',
                ),
                value: s.sendReadReceipts,
                onChanged: _saving
                    ? null
                    : (v) => _patch({
                        'sendReadReceipts': v,
                      }, optimistic: s.copyWith(sendReadReceipts: v)),
              ),
              SwitchListTile(
                title: const Text('Send typing indicators'),
                subtitle: const Text(
                  'Off means you don\'t see others\' either',
                ),
                value: s.sendTypingIndicators,
                onChanged: _saving
                    ? null
                    : (v) => _patch({
                        'sendTypingIndicators': v,
                      }, optimistic: s.copyWith(sendTypingIndicators: v)),
              ),
              PrivacyChoiceRow<int?>(
                icon: Icons.auto_delete_outlined,
                title: 'Delete my messages after',
                value: _retentionOptions.contains(s.dmRetentionDays)
                    ? s.dmRetentionDays
                    : null,
                options: _retentionOptions,
                labelOf: _retentionLabel,
                onChanged: (v) => _patch(
                  {'dmRetentionDays': v},
                  // `copyWith` can't set a nullable field back to null, so the
                  // "keep forever" case rebuilds the record without it.
                  optimistic: v == null
                      ? s.clearRetention()
                      : s.copyWith(dmRetentionDays: v),
                ),
              ),
            ],
          ),
        ),
        const SettingsFootnote(
          'Message deletion applies to messages you sent, in every '
          'conversation. It never removes anyone else\'s.',
        ),
        const SizedBox(height: AppSpacing.l),

        // ── Safety and notifications ─────────────────────────────────────
        SettingsSection(
          label: 'Safety',
          children: [
            PrivacyChoiceRow<ExplicitContentFilter>(
              icon: Icons.image_not_supported_outlined,
              title: 'Filter explicit images',
              value: s.explicitContentFilter,
              options: ExplicitContentFilter.values,
              labelOf: (v) => v.label,
              unavailable: _locked('explicitContentFilter')
                  ? const {ExplicitContentFilter.off}
                  : const {},
              unavailableNote: _minorNote,
              onChanged: (v) => _patch({
                'explicitContentFilter': v.name.pascal,
              }, optimistic: s.copyWith(explicitContentFilter: v)),
            ),
            SettingsRow(
              icon: Icons.flag_outlined,
              title: 'Reports you\'ve filed',
              onTap: () => context.push(RoutePaths.myReports),
            ),
          ],
        ),
        const SettingsFootnote(
          'A report is reviewed by the moderation team. Blocking someone works '
          'immediately and needs nobody - the two are worth doing together.',
        ),
        const SizedBox(height: AppSpacing.l),
        SettingsSection(
          label: 'Notifications',
          child: SwitchListTile(
            title: const Text('Hide content in notifications'),
            subtitle: const Text(
              'Push notifications show only that something arrived',
            ),
            value: s.hidePushContent,
            onChanged: _saving
                ? null
                : (v) => _patch({
                    'hidePushContent': v,
                  }, optimistic: s.copyWith(hidePushContent: v)),
          ),
        ),
        const SizedBox(height: AppSpacing.l),

        // ── Consent ──────────────────────────────────────────────────────
        SettingsSection(
          label: 'How your data is used',
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Diagnostics linked to my account'),
                subtitle: const Text(
                  'Crash reports still get sent either way - this decides '
                  'whether they say who you are',
                ),
                isThreeLine: true,
                value: s.allowDataCollection,
                onChanged: _saving
                    ? null
                    : (v) => _patch({
                        'allowDataCollection': v,
                      }, optimistic: s.copyWith(allowDataCollection: v)),
              ),
              _MinorLockableSwitch(
                title: 'Personalisation',
                subtitle: 'Use my activity to tailor what I\'m shown',
                value: s.allowPersonalization,
                locked: _locked('allowPersonalization'),
                enabled: !_saving,
                onChanged: (v) => _patch({
                  'allowPersonalization': v,
                }, optimistic: s.copyWith(allowPersonalization: v)),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.l),

        SettingsSection(
          label: 'Your data',
          children: [
            SettingsRow(
              icon: Icons.download_outlined,
              title: 'Request a copy of my data',
              onTap: () => context.push(RoutePaths.dataExport),
            ),
            SettingsRow(
              icon: Icons.gavel_outlined,
              title: 'Terms and policies',
              onTap: () => context.push(RoutePaths.legalDocuments),
            ),
          ],
        ),
        const SettingsFootnote(
          'To have your data erased, delete your account under Settings › '
          'Account.',
        ),
      ],
    );
  }

  static String _retentionLabel(int? days) => switch (days) {
    null => 'Keep forever',
    1 => '1 day',
    7 => '1 week',
    30 => '30 days',
    90 => '90 days',
    365 => '1 year',
    final other => '$other days',
  };
}

/// `.name` gives `friendsAndServerMembers`; the wire wants
/// `FriendsAndServerMembers`. Derived rather than hand-listed per enum so a new
/// member cannot be added with a silently missing mapping - the enums here are
/// all straight PascalCase on the wire, which is what makes that safe.
extension on String {
  String get pascal => isEmpty ? this : this[0].toUpperCase() + substring(1);
}

extension on PrivacySettingsDto {
  /// Freezed's `copyWith` treats a null argument as "unchanged", so there is no
  /// way to *clear* [dmRetentionDays] through it. This rebuilds the one field.
  PrivacySettingsDto clearRetention() => PrivacySettingsDto(
    allowDataCollection: allowDataCollection,
    allowPersonalization: allowPersonalization,
    allowVoiceRecordingInClips: allowVoiceRecordingInClips,
    directMessagePolicy: directMessagePolicy,
    friendRequestPolicy: friendRequestPolicy,
    discoverableByUsername: discoverableByUsername,
    discoverableByEmail: discoverableByEmail,
    discoverableByPhone: discoverableByPhone,
    mutualServersVisibility: mutualServersVisibility,
    mutualFriendsVisibility: mutualFriendsVisibility,
    connectionsVisibility: connectionsVisibility,
    birthdayVisibility: birthdayVisibility,
    shareActivity: shareActivity,
    allowPositionalVoiceCapture: allowPositionalVoiceCapture,
    sendReadReceipts: sendReadReceipts,
    sendTypingIndicators: sendTypingIndicators,
    explicitContentFilter: explicitContentFilter,
    hidePushContent: hidePushContent,
    version: version,
    isMinor: isMinor,
  );
}

/// A switch the account's age may forbid. Rendered disabled with a reason
/// rather than hidden - see [PrivacyChoiceRow.unavailable].
class _MinorLockableSwitch extends StatelessWidget {
  const _MinorLockableSwitch({
    required this.title,
    required this.value,
    required this.locked,
    required this.enabled,
    required this.onChanged,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final bool locked;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title),
      subtitle: switch ((locked, subtitle)) {
        (true, _) => const Text(_PrivacySettingsScreenState._minorNote),
        (_, final String text) => Text(text),
        _ => null,
      },
      // A locked control shows `false` whatever is stored: the floor forces it
      // off server-side, and rendering a stored `true` next to "not available"
      // would be the screen contradicting itself.
      value: locked ? false : value,
      onChanged: locked || !enabled ? null : onChanged,
    );
  }
}

class _MinorBanner extends StatelessWidget {
  const _MinorBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: tint.withValues(alpha: 0.30)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, size: 20, color: tint),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(
              'Some settings on this page are fixed because of the age on '
              'this account. They unlock on their own when that changes.',
              style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadFailure extends StatelessWidget {
  const _LoadFailure({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.m),
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
