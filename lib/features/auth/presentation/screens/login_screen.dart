import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/button_progress_indicator.dart';
import '../../bloc/auth_bloc.dart';
import '../widgets/verification_code_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _mfaCodeController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _mfaCodeController.dispose();
    super.dispose();
  }

  void _submit() {
    context.read<AuthBloc>().add(
      LoginSubmitted(
        input: _usernameController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  void _submitMfaCode() {
    context.read<AuthBloc>().add(
      LoginSubmitted(
        input: _usernameController.text.trim(),
        password: _passwordController.text,
        mfaCode: _mfaCodeController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.status == AuthStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Something went wrong.'),
                ),
              );
            }
          },
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        Icons.forum_rounded,
                        color: theme.colorScheme.onPrimary,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    Text('Welcome back', style: theme.textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'We\'re so excited to see you again.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final loading = state.status == AuthStatus.loading;
                        final email = state.pendingVerificationEmail;
                        // Keyed off the pending address, not the status, so
                        // the form survives the `loading` emit while a code
                        // is being checked instead of flicking back to the
                        // credentials it was already past.
                        if (email != null) {
                          return VerificationCodeForm(
                            email: email,
                            loading: loading,
                            errorMessage: state.errorMessage,
                            infoMessage: state.infoMessage,
                            onCancel: () => context.read<AuthBloc>().add(
                              const LoginCancelled(),
                            ),
                          );
                        }
                        if (state.status == AuthStatus.mfaRequired) {
                          return _MfaCodeForm(
                            controller: _mfaCodeController,
                            loading: loading,
                            errorMessage: state.errorMessage,
                            onSubmit: _submitMfaCode,
                            onCancel: () {
                              _mfaCodeController.clear();
                              context.read<AuthBloc>().add(
                                const LoginCancelled(),
                              );
                            },
                          );
                        }
                        return _CredentialsForm(
                          usernameController: _usernameController,
                          passwordController: _passwordController,
                          obscurePassword: _obscurePassword,
                          onToggleObscure: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          loading: loading,
                          onSubmit: _submit,
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Need an account?',
                          style: theme.textTheme.bodySmall,
                        ),
                        // A `TextButton` rather than a bare tappable `Text` so
                        // the link gets a full-height touch target and ink
                        // feedback - as text alone it was a ~16px-tall hit box.
                        TextButton(
                          onPressed: () => context.push(RoutePaths.register),
                          child: Text(
                            'Register',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CredentialsForm extends StatelessWidget {
  const _CredentialsForm({
    required this.usernameController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onToggleObscure,
    required this.loading,
    required this.onSubmit,
  });

  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final bool loading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('USERNAME OR EMAIL', style: theme.textTheme.labelSmall),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: usernameController,
          autocorrect: false,
          decoration: const InputDecoration(
            hintText: 'you, or you@your-server.com',
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        Text('PASSWORD', style: theme.textTheme.labelSmall),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: passwordController,
          obscureText: obscurePassword,
          onSubmitted: (_) => onSubmit(),
          decoration: InputDecoration(
            hintText: 'Your password',
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
        const SizedBox(height: AppSpacing.xs),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => context.push(RoutePaths.forgotPassword),
            child: const Text('Forgot password?'),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        ElevatedButton(
          onPressed: loading ? null : onSubmit,
          child: loading
              ? const ButtonProgressIndicator()
              : const Text('Log In'),
        ),
      ],
    );
  }
}

class _MfaCodeForm extends StatelessWidget {
  const _MfaCodeForm({
    required this.controller,
    required this.loading,
    required this.errorMessage,
    required this.onSubmit,
    required this.onCancel,
  });

  final TextEditingController controller;
  final bool loading;
  final String? errorMessage;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Enter the 6-digit code from your authenticator app, or one of '
          'your recovery codes.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.l),
        Text('CODE', style: theme.textTheme.labelSmall),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: controller,
          autofocus: true,
          autocorrect: false,
          onSubmitted: (_) => onSubmit(),
          decoration: const InputDecoration(hintText: '123456'),
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            errorMessage!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.l),
        ElevatedButton(
          onPressed: loading ? null : onSubmit,
          child: loading
              ? const ButtonProgressIndicator()
              : const Text('Verify'),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextButton(
          onPressed: loading ? null : onCancel,
          child: const Text('Use a different account'),
        ),
      ],
    );
  }
}
