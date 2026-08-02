import 'package:flutter/material.dart';

/// Responsive layout widget builder that adapts to screen width constraints.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    required this.mobile,
    this.tablet,
    this.desktop,
    super.key,
  });

  final Widget Function(BuildContext context, BoxConstraints constraints) mobile;
  final Widget Function(BuildContext context, BoxConstraints constraints)? tablet;
  final Widget Function(BuildContext context, BoxConstraints constraints)? desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth >= 840 && desktop != null) {
          return desktop!(context, constraints);
        }
        if (constraints.maxWidth >= 600 && tablet != null) {
          return tablet!(context, constraints);
        }
        return mobile(context, constraints);
      },
    );
  }
}
