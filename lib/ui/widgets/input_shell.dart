import 'package:flutter/material.dart';
import 'package:minima/ui/theme/minima_theme.dart';
import 'package:minima/ui/widgets/input_container.dart';

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
      child: InputContainer(
        child: Text(
          InputContainer.hintText,
          style: TextStyle(color: colors.textMuted, fontSize: 16),
        ),
      ),
    );
  }
}
