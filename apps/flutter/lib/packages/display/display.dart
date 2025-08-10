import 'dart:io';

import 'package:flutter/material.dart';

import 'desktop.dart';

class Display extends StatelessWidget {
  final Widget child;

  const Display({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return Desktop(child: child);
    }

    return child;
  }

  static Future<void> initialize() async {
    if (isDesktop) await Desktop.initialize();
  }

  static bool get isDesktop {
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }
}
