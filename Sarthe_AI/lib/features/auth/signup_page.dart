import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/route_names.dart';
import 'widgets/auth_background.dart';
import 'widgets/auth_button.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/google_login_button.dart';
import 'widgets/auth_loading_widget.dart';
import 'auth_provider.dart';
import 'state/auth_startup_state.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key, this.redirectTo});

  final String? redirectTo;

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref
          .read(authControllerProvider.notifier)
          .signup(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            name: _nameController.text.trim(),
          );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _googleLogin() async {
    try {
      await ref.read(authControllerProvider.notifier).googleLogin();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthStartupState startup = ref.watch(authStartupProvider);
    final bool loading = startup.isLoading;

    if (loading) {
      return AuthBackground(
        child: AuthLoadingWidget(
          onRetry: startup.hasError
              ? () => ref.read(authControllerProvider.notifier).retryBootstrap()
              : null,
        ),
      );
    }

    return AuthBackground(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Create account',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                AuthTextField(
                  controller: _nameController,
                  label: 'Full name',
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Name required';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                AuthTextField(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _SignupPasswordField(controller: _passwordController),
                const SizedBox(height: 12),
                AuthTextField(
                  controller: _confirmController,
                  label: 'Confirm password',
                  obscureText: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Confirm your password';
                    if (v != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AuthButton(
                  label: 'Create account',
                  loading: loading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 12),
                GoogleLoginButton(loading: loading, onPressed: _googleLogin),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    context.goNamed(RouteNames.login);
                  },
                  child: const Text('Already have an account? Sign in'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SignupPasswordField extends ConsumerStatefulWidget {
  const _SignupPasswordField({required this.controller});

  final TextEditingController controller;

  @override
  ConsumerState<_SignupPasswordField> createState() =>
      _SignupPasswordFieldState();
}

class _SignupPasswordFieldState extends ConsumerState<_SignupPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return AuthTextField(
      controller: widget.controller,
      label: 'Password',
      obscureText: _obscure,
      suffix: IconButton(
        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
        onPressed: () => setState(() => _obscure = !_obscure),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Password required';
        if (v.length < 6) return 'Minimum 6 characters';
        return null;
      },
    );
  }
}
