import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth_provider.dart';
import '../state/auth_startup_state.dart';

/// Shared loading overlay for auth flows — splash, login, signup.
class AuthLoadingWidget extends ConsumerWidget {
  const AuthLoadingWidget({
    super.key,
    this.message,
    this.showRetry = false,
    this.onRetry,
    this.compact = false,
  });

  final String? message;
  final bool showRetry;
  final VoidCallback? onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AuthStartupState startup = ref.watch(authStartupProvider);
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    final String displayMessage = message ?? startup.stepMessage;
    final bool canRetry = showRetry || (startup.hasError && startup.isOffline);

    return Semantics(
      container: true,
      liveRegion: true,
      label: displayMessage,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: compact ? 28 : 36,
            height: compact ? 28 : 36,
            child: CircularProgressIndicator(
              strokeWidth: compact ? 2.5 : 3,
              color: colors.primary,
            ),
          ),
          SizedBox(height: compact ? 12 : 16),
          Text(
            displayMessage,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (startup.hasError && startup.error != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              startup.error!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: colors.error),
            ),
          ],
          if (canRetry && onRetry != null) ...<Widget>[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ],
      ),
    );
  }
}
