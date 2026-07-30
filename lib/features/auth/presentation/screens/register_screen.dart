import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/widget_styles.dart';
import '../../bloc/auth_bloc.dart';
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
            if (state.status == AuthStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Something went wrong.'),
                ),
              );
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
                // The account is made; all that's left is the code. Swapping
                // the form out rather than popping back to login keeps the
                // bloc - and the credentials it needs to finish signing in -
                // alive, since each auth route builds its own.
                if (pendingEmail != null) {
                  return BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) => VerificationCodeForm(
                      email: pendingEmail,
                      loading: state.status == AuthStatus.loading,
                      errorMessage: state.errorMessage,
                      infoMessage: state.infoMessage,
                      onCancel: () =>
                          context.read<AuthBloc>().add(const LoginCancelled()),
                    ),
                  );
                }
                return _buildForm(context, theme);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, ThemeData theme) {
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
          decoration: const InputDecoration(hintText: 'you@example.com'),
        ),
        const SizedBox(height: AppSpacing.m),
        Text('USERNAME', style: theme.textTheme.labelSmall),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: _usernameController,
          autocorrect: false,
          decoration: const InputDecoration(hintText: 'A unique username'),
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
            decoration: const InputDecoration(),
            child: Text(
              _birthdate == null
                  ? 'Select a date'
                  : '${_birthdate!.year}-${_birthdate!.month.toString().padLeft(2, '0')}-${_birthdate!.day.toString().padLeft(2, '0')}',
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.l),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final loading = state.status == AuthStatus.loading;
            return ElevatedButton(
              onPressed: loading ? null : _submit,
              child: loading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  : const Text('Create Account'),
            );
          },
        ),
      ],
    );
  }
}
