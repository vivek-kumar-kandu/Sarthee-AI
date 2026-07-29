import 'package:flutter/material.dart';

/// Startup progress presentation for Sarthee AI.
///
/// Supports:
/// • Determinate progress
/// • Indeterminate progress
/// • Status messages
/// • Percentage display
/// • Material 3 theming
/// • Accessibility semantics
class SplashLoadingIndicator extends StatelessWidget {
  const SplashLoadingIndicator({
    required this.progress,
    super.key,
    this.message,
    this.showPercentage = true,
    this.indeterminate = false,
  });

  final double progress;
  final String? message;
  final bool showPercentage;
  final bool indeterminate;

  double get _safeProgress => progress.clamp(0.0, 1.0);

  int get _percentage => (_safeProgress * 100).round();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    final String? normalizedMessage = _normalizeMessage(message);

    final String semanticLabel = normalizedMessage ?? 'Starting Sarthee AI';

    return Semantics(
      container: true,
      liveRegion: true,
      label: semanticLabel,
      value: indeterminate ? 'Loading' : '$_percentage percent',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: indeterminate ? null : _safeProgress,
              minHeight: 5,
              backgroundColor: colors.surfaceContainerHighest,
            ),
          ),

          if (normalizedMessage != null) ...<Widget>[
            const SizedBox(height: 14),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                normalizedMessage,
                key: ValueKey<String>(normalizedMessage),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ],

          if (showPercentage && !indeterminate) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              '$_percentage%',
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.onSurfaceVariant,
                fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String? _normalizeMessage(String? value) {
    final String? trimmed = value?.trim();

    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }
}
