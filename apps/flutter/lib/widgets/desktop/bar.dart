import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class Bar extends StatelessWidget implements PreferredSizeWidget {
  const Bar({super.key});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      child: WindowCaption(
        title: Text('Minima'),
        brightness: Theme.of(context).brightness,
        backgroundColor: Colors.transparent,
      ),
      preferredSize: const Size.fromHeight(32.0),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(32.0);
}
