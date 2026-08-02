import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/route_names.dart';
import 'widgets/auth_background.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/google_login_button.dart';
import 'widgets/auth_loading_widget.dart';
import 'auth_provider.dart';
import 'state/auth_startup_state.dart';

/// Sarthee AI Signup Page maintaining complete visual continuity with Splash, Onboarding & Login.
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
      await ref.read(authControllerProvider.notifier).signup(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            name: _nameController.text.trim(),
          );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _googleLogin() async {
    try {
      await ref.read(authControllerProvider.notifier).googleLogin();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthStartupState startup = ref.watch(authStartupProvider);
    final bool loading = startup.isLoading;
    final ThemeData theme = Theme.of(context);
    final Color primaryColor = const Color(0xFF0066FF);

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
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // 1. Hero Brand Logo Transition (Continuous with Splash & Onboarding)
            Hero(
              tag: 'sarthee-logo',
              child: Semantics(
                image: true,
                label: 'Sarthee AI logo',
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.18),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/images/logo/sarthee_logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: primaryColor,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.travel_explore_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 2. Headline Typography
            Text(
              'Create Account',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: const Color(0xFF1E293B),
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),

            const SizedBox(height: 8),

            // 3. Subtitle Description
            Text(
              'Join Sarthee AI to unlock smart travel experiences',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF64748B),
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 14),

            // 4. Decorative Star Divider: ──── ✦ ──── (Opacity ~40%)
            Opacity(
              opacity: 0.40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: 44,
                    child: Divider(
                      thickness: 1.5,
                      color: primaryColor,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.star_rounded,
                      size: 10,
                      color: primaryColor,
                    ),
                  ),
                  SizedBox(
                    width: 44,
                    child: Divider(
                      thickness: 1.5,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 5. Input Fields
            AuthTextField(
              controller: _nameController,
              label: 'Full Name',
              prefixIcon: const Icon(Icons.person_outline_rounded),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Full name required';
                return null;
              },
            ),

            const SizedBox(height: 14),

            AuthTextField(
              controller: _emailController,
              label: 'Email Address',
              prefixIcon: const Icon(Icons.email_outlined),
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email required';
                if (!v.contains('@')) return 'Enter a valid email address';
                return null;
              },
            ),

            const SizedBox(height: 14),

            _SignupPasswordField(controller: _passwordController),

            const SizedBox(height: 14),

            AuthTextField(
              controller: _confirmController,
              label: 'Confirm Password',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              obscureText: true,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Confirm your password';
                if (v != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // 6. Primary CTA Button ("Create Account →") matching Onboarding Action Button style
            SizedBox(
              width: double.infinity,
              height: 52,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.30),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Create Account →'),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 7. Divider Label
            Row(
              children: <Widget>[
                const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Or continue with',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF94A3B8),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
              ],
            ),

            const SizedBox(height: 16),

            // 8. Social OAuth Button
            GoogleLoginButton(loading: loading, onPressed: _googleLogin),

            const SizedBox(height: 24),

            // 9. Sign In Navigation Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Already have an account?',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF64748B),
                    fontSize: 14,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.goNamed(RouteNames.login);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: primaryColor,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  child: const Text('Sign In'),
                ),
              ],
            ),
          ],
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
      prefixIcon: const Icon(Icons.lock_outlined),
      obscureText: _obscure,
      suffix: IconButton(
        icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
        onPressed: () => setState(() => _obscure = !_obscure),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Password required';
        if (v.length < 6) return 'Minimum 6 characters required';
        return null;
      },
    );
  }
}
