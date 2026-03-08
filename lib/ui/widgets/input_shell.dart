import 'package:flutter/material.dart';
import 'package:minima/ui/theme/minima_theme.dart';

class InputShell extends StatelessWidget {
  final VoidCallback onTap;

  const InputShell({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: 'input',
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: MinimaTheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'What is on your mind?',
              style: TextStyle(color: MinimaTheme.textMuted, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
