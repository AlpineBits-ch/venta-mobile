import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../data/auth_repository.dart';

enum _Step { email, codeAndPassword, done }

/// "Forgot password?" flow reached from [LoginScreen] - two steps in one
/// screen (email, then code + new password) rather than two routes, since
/// there's nothing else that needs to deep-link into the middle of it.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  _Step _step = _Step.email;
  bool _submitting = false;
  String? _error;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _requestCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await getIt<AuthRepository>().requestPasswordReset(email);
      if (mounted) {
        setState(() {
          _step = _Step.codeAndPassword;
          _submitting = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _submitting = false;
          _error = 'Something went wrong - please try again.';
        });
      }
    }
  }

  Future<void> _resetPassword() async {
    final code = _codeController.text.trim();
    final newPassword = _newPasswordController.text;
    if (code.isEmpty || newPassword.length < 8) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await getIt<AuthRepository>().resetPassword(
        email: _emailController.text.trim(),
        code: code,
        newPassword: newPassword,
      );
      if (mounted) setState(() => _step = _Step.done);
    } catch (_) {
      if (mounted) {
        setState(() {
          _submitting = false;
          _error = 'Invalid or expired code, or that password doesn\'t '
              'meet requirements.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Reset password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              switch (_step) {
                _Step.email => _EmailStep(
                  controller: _emailController,
                  submitting: _submitting,
                  onSubmit: _requestCode,
                ),
                _Step.codeAndPassword => _CodeAndPasswordStep(
                  email: _emailController.text.trim(),
                  codeController: _codeController,
                  newPasswordController: _newPasswordController,
                  obscurePassword: _obscurePassword,
                  onToggleObscure: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  submitting: _submitting,
                  onSubmit: _resetPassword,
                  onResend: _requestCode,
                ),
                _Step.done => _DoneStep(theme: theme),
              },
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.m),
                Text(
                  _error!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EmailStep extends StatelessWidget {
  const _EmailStep({
    required this.controller,
    required this.submitting,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool submitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Enter your email or username and we\'ll send you a code to reset '
          'your password.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.l),
        Text('EMAIL OR USERNAME', style: theme.textTheme.labelSmall),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: controller,
          autocorrect: false,
          keyboardType: TextInputType.emailAddress,
          onSubmitted: (_) => submitting ? null : onSubmit(),
          decoration: const InputDecoration(hintText: 'you@example.com'),
        ),
        const SizedBox(height: AppSpacing.l),
        FilledButton(
          onPressed: submitting ? null : onSubmit,
          child: submitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Send code'),
        ),
      ],
    );
  }
}

class _CodeAndPasswordStep extends StatelessWidget {
  const _CodeAndPasswordStep({
    required this.email,
    required this.codeController,
    required this.newPasswordController,
    required this.obscurePassword,
    required this.onToggleObscure,
    required this.submitting,
    required this.onSubmit,
    required this.onResend,
  });

  final String email;
  final TextEditingController codeController;
  final TextEditingController newPasswordController;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final bool submitting;
  final VoidCallback onSubmit;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'If an account exists for $email, a 6-character code was sent - '
          'it\'s valid for 15 minutes.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.l),
        Text('CODE', style: theme.textTheme.labelSmall),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: codeController,
          autocorrect: false,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(hintText: 'a1b2c3'),
        ),
        const SizedBox(height: AppSpacing.m),
        Text('NEW PASSWORD', style: theme.textTheme.labelSmall),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: newPasswordController,
          obscureText: obscurePassword,
          onSubmitted: (_) => submitting ? null : onSubmit(),
          decoration: InputDecoration(
            hintText: 'At least 8 characters',
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: onToggleObscure,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.l),
        FilledButton(
          onPressed: submitting ? null : onSubmit,
          child: submitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Reset password'),
        ),
        const SizedBox(height: AppSpacing.s),
        Align(
          alignment: Alignment.center,
          child: TextButton(
            onPressed: submitting ? null : onResend,
            child: const Text('Resend code'),
          ),
        ),
      ],
    );
  }
}

class _DoneStep extends StatelessWidget {
  const _DoneStep({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.check_circle_outline,
          size: 48,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: AppSpacing.m),
        Text(
          'Password changed',
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'You can now log in with your new password.',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.l),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Back to login'),
        ),
      ],
    );
  }
}
