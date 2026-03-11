import 'package:flutter/material.dart';
import 'package:minima/ui/theme/minima_theme.dart';

/// A list tile for displaying an installed package (app).
/// Supports long-press for context menu and an optional home indicator.
class PackageTile extends StatelessWidget {
  final String label;
  final bool isHome;
  final bool isMuted;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const PackageTile({
    super.key,
    required this.label,
    this.isHome = false,
    this.isMuted = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onLongPress: onLongPress,
      child: ListTile(
        title: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: isMuted ? colors.textMuted : colors.textPrimary),
        ),
        trailing: isHome ? Icon(Icons.home_outlined, color: colors.textMuted, size: 16) : null,
        onTap: onTap,
      ),
    );
  }
}
