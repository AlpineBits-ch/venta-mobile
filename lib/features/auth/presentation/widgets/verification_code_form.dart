import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/button_progress_indicator.dart';
import '../../bloc/auth_bloc.dart';

/// The 6-character code from the verification email.
///
/// Shown by both the login and the register screen - registering signs you in
/// straight away, and the server refuses that until the address is confirmed,
/// so this is the normal last step of signing up rather than an error path.
/// Mirrors the MFA code form on the login screen, which is the same shape of
/// problem: a code standing between correct credentials and a session.
class VerificationCodeForm extends StatefulWidget {
  const VerificationCodeForm({
    super.key,
    required this.email,
    required this.loading,
    this.errorMessage,
    this.infoMessage,
    required this.onCancel,
  });

  /// The address the code went to, when the flow knows it (registering does).
  /// Empty when it doesn't - signing in takes a username or
  /// `user@self-hosted-server`, neither of which is an email - and then the
  /// form asks for it, because `verify-email` is keyed on the address.
  final String email;
  final bool loading;
  final String? errorMessage;
  final String? infoMessage;

  /// Back to the credentials form - without it the code step is a dead end
  /// for anyone whose email never arrives.
  final VoidCallback onCancel;

  @override
  State<VerificationCodeForm> createState() => _VerificationCodeFormState();
}

class _VerificationCodeFormState extends State<VerificationCodeForm> {
  final _controller = TextEditingController();
  final _emailController = TextEditingController();

  /// Whether this form has to collect the address as well as the code.
  bool get _needsEmail => widget.email.isEmpty;

  String? get _email {
    final value = _needsEmail ? _emailController.text.trim() : widget.email;
    return value.isEmpty ? null : value;
  }

  /// Seconds left before "Send it again" comes back, matching Alpine's
  /// 60-second cooldown - resending in a loop just races the mail server.
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _controller.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    final code = _controller.text.trim();
    if (code.length < 6 || _email == null) return;
    context.read<AuthBloc>().add(
      VerificationCodeSubmitted(code, email: _email),
    );
  }

  void _resend() {
    context.read<AuthBloc>().add(
      VerificationCodeResendRequested(email: _email),
    );
    setState(() => _resendCooldown = 60);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      setState(() => _resendCooldown--);
      if (_resendCooldown <= 0) timer.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Confirm your email', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        if (_needsEmail)
          Text(
            'This account still needs its email confirmed. Enter the address '
            'you signed up with and the 6-character code sent to it.',
            style: theme.textTheme.bodyMedium?.copyWith(color: muted),
          )
        else
          Text.rich(
            TextSpan(
              style: theme.textTheme.bodyMedium?.copyWith(color: muted),
              children: [
                const TextSpan(text: 'We sent a 6-character code to '),
                TextSpan(
                  text: widget.email,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(
                  text:
                      '. Enter it to finish setting up - it expires in '
                      'five minutes.',
                ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.l),
        if (_needsEmail) ...[
          Text('EMAIL', style: theme.textTheme.labelSmall),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(hintText: 'you@example.com'),
          ),
          const SizedBox(height: AppSpacing.m),
        ],
        Text('CODE', style: theme.textTheme.labelSmall),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: _controller,
          autofocus: !_needsEmail,
          autocorrect: false,
          // Alphanumeric, not numeric: the server issues codes like `6f64d8`
          // and Alpine's own input sets `integerOnly: false`. A number pad
          // here makes the code that actually arrives impossible to type.
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.none,
          enableSuggestions: false,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(letterSpacing: 8),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
          ],
          onChanged: (value) {
            // Re-renders so the button enables on the sixth digit; also lets
            // a pasted code submit without a further tap - but not before the
            // address is in, or it would fire against an empty email.
            setState(() {});
            if (value.trim().length == 6 && _email != null) _submit();
          },
          onSubmitted: (_) => _submit(),
          decoration: const InputDecoration(
            hintText: 'a1b2c3',
            counterText: '',
          ),
        ),
        if (widget.errorMessage != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.errorMessage!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
        if (widget.infoMessage != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.infoMessage!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.l),
        ElevatedButton(
          onPressed:
              widget.loading ||
                  _controller.text.trim().length < 6 ||
                  _email == null
              ? null
              : _submit,
          child: widget.loading
              ? const ButtonProgressIndicator()
              : const Text('Verify'),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextButton(
          onPressed: widget.loading || _resendCooldown > 0 ? null : _resend,
          child: Text(
            _resendCooldown > 0
                ? 'Send it again in ${_resendCooldown}s'
                : 'Send it again',
          ),
        ),
        TextButton(
          onPressed: widget.loading ? null : widget.onCancel,
          child: const Text('Use a different account'),
        ),
      ],
    );
  }
}
