import 'package:flutter/material.dart';

class Panel extends StatelessWidget {
  final Widget child;
  final Color? color;

  const Panel({super.key, required this.child, this.color});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color,
      body: SafeArea(child: child),
    );
  }
}
