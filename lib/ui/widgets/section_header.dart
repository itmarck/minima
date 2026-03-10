import 'package:flutter/material.dart';

/// A section header used in settings and list screens.
/// Uses `labelLarge` from the theme (w600, letterSpacing 1.2).
class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.labelLarge);
  }
}
