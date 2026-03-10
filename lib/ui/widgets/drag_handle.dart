import 'package:flutter/material.dart';
import 'package:minima/ui/theme/minima_theme.dart';

/// A small horizontal bar used at the top of bottom sheets
/// to indicate they can be dragged.
class DragHandle extends StatelessWidget {
  const DragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: context.colors.textMuted,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
