import 'package:flutter/material.dart';

class GoogleLoginButton extends StatelessWidget {
  const GoogleLoginButton({
    super.key,
    required this.onPressed,
    this.loading = false,
  });

  final VoidCallback onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: loading ? null : onPressed,
      icon: const Icon(Icons.g_translate),
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: loading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Continue with Google'),
      ),
    );
  }
}
