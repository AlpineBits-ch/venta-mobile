import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../bloc/auth_bloc.dart';
import '../../data/auth_api.dart';
import '../widgets/verification_code_form.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  DateTime? _birthdate;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthdate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(now.year - 120),
      lastDate: now,
    );
    if (picked != null) setState(() => _birthdate = picked);
  }

  /// Back to the login screen this was pushed from - or straight to it if
  /// there's nothing on the stack (a cold start onto `/register`), since
  /// `pop` on an empty stack throws rather than doing nothing.
  void _goToSignIn() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RoutePaths.login);
    }
  }

  void _submit() {
    final birthdate = _birthdate;
    if (birthdate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your date of birth.')),
      );
      return;
    }
    context.read<AuthBloc>().add(
      RegisterSubmitted(
        email: _emailController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        birthdate: birthdate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Create an account')),
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            // Only what couldn't be attributed to a field - a taken username
            // or a rejected address is already shown under the input it's
            // about, and repeating it in a snackbar reads as two problems.
            if (state.status == AuthStatus.failure &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: BlocBuilder<AuthBloc, AuthState>(
              buildWhen: (previous, current) =>
                  (previous.pendingVerificationEmail == null) !=
                  (current.pendingVerificationEmail == null),
              builder: (context, state) {
                final pendingEmail = state.pendingVerificationEmail;
                // The request was accepted - whether that made an account is
                // deliberately not knowable here, so the next screen is the
                // same either way. Swapping the form out rather than popping
                // back to login keeps the bloc - and the credentials it needs
                // to finish signing in - alive, since each auth route builds
                // its own.
                if (pendingEmail != null) {
                  return BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) => VerificationCodeForm(
                      email: pendingEmail,
                      loading: state.status == AuthStatus.loading,
                      errorMessage: state.errorMessage,
                      infoMessage: state.infoMessage,
                      afterRegistration: true,
                      // Popping rather than pushing: this screen was pushed
                      // from login, so back is where they want to be.
                      onSignIn: _goToSignIn,
                      onForgotPassword: () =>
                          context.push(RoutePaths.forgotPassword),
                      onCancel: () =>
                          context.read<AuthBloc>().add(const LoginCancelled()),
                    ),
                  );
                }
                return BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) =>
                      _buildForm(context, theme, state),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, ThemeData theme, AuthState state) {
    final errors = state.registrationErrors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text("Let's get you set up", style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.l),
        Text('EMAIL', style: theme.textTheme.labelSmall),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          decoration: InputDecoration(
            hintText: 'you@example.com',
            // Never "that address is already registered" - the server doesn't
            // say so any more, and this only ever carries what it did say
            // (blank, malformed, disposable domain).
            errorText: errors[RegistrationField.email],
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        Text('USERNAME', style: theme.textTheme.labelSmall),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: _usernameController,
          autocorrect: false,
          decoration: InputDecoration(
            hintText: 'A unique username',
            // The one refusal signup still makes specifically, kept because a
            // user not told to pick another name can't get past this form.
            errorText: errors[RegistrationField.username],
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        Text('PASSWORD', style: theme.textTheme.labelSmall),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: 'At least 8 characters',
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        Text('DATE OF BIRTH', style: theme.textTheme.labelSmall),
        const SizedBox(height: AppSpacing.xs),
        InkWell(
          onTap: _pickBirthdate,
          borderRadius: BorderRadius.circular(AppRadii.input),
          child: InputDecorator(
            decoration: InputDecoration(
              // "Age must be greater than 13" arrives with an *empty*
              // propertyName; `RegistrationFailure.field` routes it here off
              // its errorCode.
              errorText: errors[RegistrationField.birthdate],
            ),
            child: Text(
              _birthdate == null
                  ? 'Select a date'
                  : '${_birthdate!.year}-${_birthdate!.month.toString().padLeft(2, '0')}-${_birthdate!.day.toString().padLeft(2, '0')}',
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.l),
        ElevatedButton(
          onPressed: state.status == AuthStatus.loading ? null : _submit,
          child: state.status == AuthStatus.loading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.onPrimary,
                  ),
                )
              : const Text('Create Account'),
        ),
        const SizedBox(height: AppSpacing.xs),
        // Equal weight with the button above, not fine print. Someone whose
        // address already has an account gets no code and no error - this is
        // the only affordance the server is allowed to give them.
        TextButton(
          onPressed: _goToSignIn,
          child: const Text('Already have an account? Sign in'),
        ),
      ],
    );
  }
}
