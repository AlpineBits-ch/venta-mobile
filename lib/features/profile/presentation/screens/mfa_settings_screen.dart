import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../auth/data/identity_api.dart';

/// Enroll/disable authenticator-app 2FA and manage recovery codes. Pushed
/// from `ProfileSettingsScreen`'s security section rather than a go_router
/// route - nothing deep-links into it.
class MfaSettingsScreen extends StatefulWidget {
  const MfaSettingsScreen({super.key, required this.enabled});

  final bool enabled;

  @override
  State<MfaSettingsScreen> createState() => _MfaSettingsScreenState();
}

class _MfaSettingsScreenState extends State<MfaSettingsScreen> {
  late bool _enabled = widget.enabled;
  MfaEnrollment? _enrollment;
  bool _enrolling = false;
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  List<String>? _recoveryCodes;
  bool _busy = false;
  String? _error;

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
      if (mounted) setState(() {
        _busy = false;
        _error = e.message;
      });
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
    setState(() => _busy = true);
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not disable 2FA.')),
        );
      }
    }
  }

  Future<void> _regenerateCodes() async {
    final password = await _promptPassword('Generate new recovery codes');
    if (password == null || !mounted) return;
    setState(() => _busy = true);
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
          decoration: const InputDecoration(hintText: 'Your password'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pop(_passwordController.text),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Two-Factor Authentication')),
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
                  onCancel: () => setState(() => _enrolling = false),
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
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.m),
            color: Colors.white,
            child: QrImageView(
              data: enrollment.otpAuthUri,
              size: 200,
              backgroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        Text(
          'Or enter this code manually:',
          style: theme.textTheme.bodySmall,
        ),
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
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
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
          onPressed: () =>
              Clipboard.setData(ClipboardData(text: codes.join('\n'))),
          icon: const Icon(Icons.copy_outlined),
          label: const Text('Copy all'),
        ),
        const SizedBox(height: AppSpacing.l),
        FilledButton(
          onPressed: onDone,
          child: const Text('I\'ve saved these'),
        ),
      ],
    );
  }
}
