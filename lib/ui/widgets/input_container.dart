import 'package:flutter/material.dart';
import 'package:minima/ui/theme/minima_theme.dart';

/// The shared visual box for the text input area.
///
/// Used by [InputShell] (inactive hint) and [InputOverlay] (active TextField).
/// The [trailing] widget is positioned absolutely so it never affects
/// the container's intrinsic height.
class InputContainer extends StatelessWidget {
  final Widget child;
  final Widget? trailing;

  const InputContainer({super.key, required this.child, this.trailing});

  /// Hint text shown when the input is inactive.
  static const hintText = 'What is on your mind?';

  /// Fixed height for the container.
  static const height = 56.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Stack(
      children: [
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: height),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(
            left: 16,
            right: trailing != null ? 64 : 16,
            top: 14,
            bottom: 14,
          ),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: child,
        ),
        if (trailing != null)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(child: trailing!),
          ),
      ],
    );
  }
}
