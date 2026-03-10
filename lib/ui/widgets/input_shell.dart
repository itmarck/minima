import 'package:flutter/material.dart';
import 'package:minima/ui/theme/minima_theme.dart';

class InputShell extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback? onSwipeRight;

  const InputShell({super.key, required this.onTap, this.onSwipeRight});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      onHorizontalDragEnd: onSwipeRight != null
          ? (details) {
              if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
                onSwipeRight!();
              }
            }
          : null,
      child: Hero(
        tag: 'input',
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'What is on your mind?',
              style: TextStyle(color: colors.textMuted, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
