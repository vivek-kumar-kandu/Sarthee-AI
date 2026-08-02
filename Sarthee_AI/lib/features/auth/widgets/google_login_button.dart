import 'package:flutter/material.dart';

/// Premium Google OAuth Sign-In Button for Sarthee AI.
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
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return Semantics(
      button: true,
      label: 'Continue with Google authentication',
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton(
          onPressed: loading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            foregroundColor: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF334155),
            side: BorderSide(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
              width: 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
          ),
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF0066FF),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Official Google G Badge / Icon
                    Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF4285F4),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'G',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Continue with Google',
                      style: TextStyle(
                        color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF334155),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
