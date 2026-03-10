import 'package:flutter/material.dart';
import 'package:minima/ui/theme/minima_theme.dart';

/// A tappable tile used in settings screens.
/// Shows a label on the left and an optional value on the right.
class SettingsTile extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback? onTap;

  const SettingsTile({super.key, required this.label, this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(label, style: textTheme.bodyMedium)),
            if (value != null)
              Text(value!, style: textTheme.bodyMedium?.copyWith(color: colors.textMuted)),
          ],
        ),
      ),
    );
  }
}
