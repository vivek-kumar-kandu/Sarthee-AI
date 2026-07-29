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

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key, this.redirectTo});

  final String? redirectTo;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref
          .read(authControllerProvider.notifier)
          .login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
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
                  'Welcome back',
                  style: Theme.of(context).textTheme.headlineSmall,
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
                _PasswordField(controller: _passwordController),
                const SizedBox(height: 16),
                AuthButton(
                  label: 'Sign in',
                  loading: loading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 12),
                GoogleLoginButton(loading: loading, onPressed: _googleLogin),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    context.goNamed(RouteNames.signup);
                  },
                  child: const Text('Create an account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordField extends ConsumerStatefulWidget {
  const _PasswordField({required this.controller});

  final TextEditingController controller;

  @override
  ConsumerState<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends ConsumerState<_PasswordField> {
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
