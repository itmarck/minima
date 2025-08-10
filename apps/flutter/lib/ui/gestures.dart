import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class Gestures extends StatefulWidget {
  final Widget child;
  final void Function()? onLongPress;
  final void Function()? onDoubleTap;

  const Gestures({
    super.key,
    required this.child,
    this.onLongPress,
    this.onDoubleTap,
  });

  @override
  State<Gestures> createState() => _GesturesState();
}

class _GesturesState extends State<Gestures> {
  Timer timer = Timer(Duration.zero, () {});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (details) {
        timer = Timer(Duration(seconds: 2), () {
          widget.onLongPress?.call();
          HapticFeedback.vibrate();
        });
      },
      onLongPressEnd: (details) {
        timer.cancel();
      },
      onDoubleTap: () {
        widget.onDoubleTap?.call();
        HapticFeedback.mediumImpact();
      },
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity == null) return;

        if (details.primaryVelocity! < 0) {
          // Swipe up
        }
      },
      child: widget.child,
    );
  }
}
