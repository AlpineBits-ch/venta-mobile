import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/button_progress_indicator.dart';
import '../../../auth/data/account_repository.dart';
import '../../../auth/data/identity_api.dart';

/// Enroll/disable authenticator-app 2FA and manage recovery codes. Reached
/// from the settings index (`RoutePaths.mfaSettings`).
class MfaSettingsScreen extends StatefulWidget {
  const MfaSettingsScreen({super.key, this.enabled});

  /// Current 2FA state when the caller already has the account loaded. `null`
  /// means "look it up yourself" - a route restored from a cold start has no
  /// caller to ask, and guessing `false` would offer to enroll someone who is
  /// already enrolled.
  final bool? enabled;

  @override
  State<MfaSettingsScreen> createState() => _MfaSettingsScreenState();
}

class _MfaSettingsScreenState extends State<MfaSettingsScreen> {
  late bool _enabled = widget.enabled ?? false;
  MfaEnrollment? _enrollment;
  bool _enrolling = false;
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  List<String>? _recoveryCodes;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.enabled == null) _loadEnabled();
  }

  Future<void> _loadEnabled() async {
    try {
      final account = await getIt<AccountRepository>().getSelf();
      if (mounted) setState(() => _enabled = account.mfaEnabled);
    } catch (_) {
      // Overview stays on the "set up" path; enrolling while already enrolled
      // is rejected by the server rather than silently doing the wrong thing.
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _startEnroll() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final enrollment = await getIt<IdentityApi>().enrollMfa();
      if (mounted) {
        setState(() {
          _enrollment = enrollment;
          _enrolling = true;
          _busy = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'Could not start enrollment - try again.';
        });
      }
    }
  }

  Future<void> _confirmEnroll() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final codes = await getIt<IdentityApi>().enableMfa(code);
      if (mounted) {
        setState(() {
          _enabled = true;
          _recoveryCodes = codes;
          _enrolling = false;
          _busy = false;
        });
      }
    } on MfaActionFailedException catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e.message;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'Something went wrong - try again.';
        });
      }
    }
  }

  Future<void> _disable() async {
    final password = await _promptPassword('Disable two-factor authentication');
    if (password == null || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await getIt<IdentityApi>().disableMfa(password);
      if (mounted) {
        setState(() {
          _enabled = false;
          _recoveryCodes = null;
          _busy = false;
        });
      }
    } on MfaActionFailedException catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not disable 2FA.')));
      }
    }
  }

  Future<void> _regenerateCodes() async {
    final password = await _promptPassword('Generate new recovery codes');
    if (password == null || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final codes = await getIt<IdentityApi>().regenerateRecoveryCodes(
        password,
      );
      if (mounted) {
        setState(() {
          _recoveryCodes = codes;
          _busy = false;
        });
      }
    } on MfaActionFailedException catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not generate new codes.')),
        );
      }
    }
  }

  Future<String?> _promptPassword(String title) {
    _passwordController.clear();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: _passwordController,
          obscureText: true,
          autofocus: true,
          onSubmitted: (text) =>
              text.isEmpty ? null : Navigator.of(context).pop(text),
          decoration: const InputDecoration(hintText: 'Your password'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          // Rebuilds on each keystroke so Confirm stays disabled until there's
          // actually a password to send - otherwise it fired an empty string
          // at the API and came back as a generic failure snackbar.
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _passwordController,
            builder: (context, value, _) => FilledButton(
              onPressed: value.text.isEmpty
                  ? null
                  : () => Navigator.of(context).pop(value.text),
              child: const Text('Confirm'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackLocation: RoutePaths.settings),
        title: const Text('Two-Factor Authentication'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: _recoveryCodes != null
              ? _RecoveryCodesView(
                  codes: _recoveryCodes!,
                  onDone: () => setState(() => _recoveryCodes = null),
                )
              : _enrolling
              ? _EnrollView(
                  enrollment: _enrollment!,
                  codeController: _codeController,
                  busy: _busy,
                  error: _error,
                  onConfirm: _confirmEnroll,
                  onCancel: () => setState(() {
                    _enrolling = false;
                    // Both views render `_error`; without clearing it here a
                    // failed code check follows you back to the overview.
                    _error = null;
                    _codeController.clear();
                  }),
                )
              : _OverviewView(
                  enabled: _enabled,
                  busy: _busy,
                  error: _error,
                  onEnroll: _startEnroll,
                  onDisable: _disable,
                  onRegenerateCodes: _regenerateCodes,
                ),
        ),
      ),
    );
  }
}

class _OverviewView extends StatelessWidget {
  const _OverviewView({
    required this.enabled,
    required this.busy,
    required this.error,
    required this.onEnroll,
    required this.onDisable,
    required this.onRegenerateCodes,
  });

  final bool enabled;
  final bool busy;
  final String? error;
  final VoidCallback onEnroll;
  final VoidCallback onDisable;
  final VoidCallback onRegenerateCodes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              enabled ? Icons.verified_user : Icons.shield_outlined,
              color: enabled ? theme.colorScheme.primary : null,
            ),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: Text(
                enabled
                    ? 'Two-factor authentication is enabled.'
                    : 'Two-factor authentication is off.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.l),
        if (!enabled)
          FilledButton(
            onPressed: busy ? null : onEnroll,
            child: const Text('Set up two-factor authentication'),
          )
        else ...[
          OutlinedButton(
            onPressed: busy ? null : onRegenerateCodes,
            child: const Text('Generate new recovery codes'),
          ),
          const SizedBox(height: AppSpacing.s),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            onPressed: busy ? null : onDisable,
            child: const Text('Disable two-factor authentication'),
          ),
        ],
        if (error != null) ...[
          const SizedBox(height: AppSpacing.m),
          Text(
            error!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}

class _EnrollView extends StatelessWidget {
  const _EnrollView({
    required this.enrollment,
    required this.codeController,
    required this.busy,
    required this.error,
    required this.onConfirm,
    required this.onCancel,
  });

  final MfaEnrollment enrollment;
  final TextEditingController codeController;
  final bool busy;
  final String? error;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Scan this with your authenticator app (Google Authenticator, '
          '1Password, Authy, ...):',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.l),
        Center(
          // Stays white in both themes - QR scanners need the light quiet
          // zone - but takes the app's card radius so it doesn't read as a
          // bare rectangle pasted onto a rounded layout.
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadii.card),
            ),
            child: QrImageView(
              data: enrollment.otpAuthUri,
              size: 200,
              backgroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        Text('Or enter this code manually:', style: theme.textTheme.bodySmall),
        const SizedBox(height: AppSpacing.xs),
        SelectableText(
          enrollment.secret,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: AppSpacing.l),
        Text(
          'ENTER THE 6-DIGIT CODE FROM YOUR APP',
          style: theme.textTheme.labelSmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: codeController,
          autocorrect: false,
          keyboardType: TextInputType.number,
          onSubmitted: (_) => busy ? null : onConfirm(),
          decoration: const InputDecoration(hintText: '123456'),
        ),
        if (error != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            error!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.l),
        FilledButton(
          onPressed: busy ? null : onConfirm,
          child: busy
              ? const ButtonProgressIndicator()
              : const Text('Verify and enable'),
        ),
        const SizedBox(height: AppSpacing.s),
        TextButton(
          onPressed: busy ? null : onCancel,
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class _RecoveryCodesView extends StatelessWidget {
  const _RecoveryCodesView({required this.codes, required this.onDone});

  final List<String> codes;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: Text(
                'Save these recovery codes somewhere safe - they\'re shown '
                'only once, and each replaces the codes issued before it.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.l),
        Container(
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadii.card),
          ),
          child: SelectableText(
            codes.join('\n'),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
              height: 1.8,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        OutlinedButton.icon(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: codes.join('\n')));
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Recovery codes copied.')),
            );
          },
          icon: const Icon(Icons.copy_outlined),
          label: const Text('Copy all'),
        ),
        const SizedBox(height: AppSpacing.l),
        FilledButton(onPressed: onDone, child: const Text('I\'ve saved these')),
      ],
    );
  }
}
