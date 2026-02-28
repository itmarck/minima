import 'dart:async';

import 'package:flutter/material.dart';
import 'package:minima/ui/theme/minima_theme.dart';

class DigitalClock extends StatefulWidget {
  const DigitalClock({super.key});

  @override
  State<DigitalClock> createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  late Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hour = _now.hour.toString().padLeft(2, '0');
    final minute = _now.minute.toString().padLeft(2, '0');

    return Text(
      '$hour:$minute',
      style: const TextStyle(
        color: MinimaTheme.textPrimary,
        fontSize: 64,
        fontWeight: FontWeight.w200,
        letterSpacing: 4,
      ),
    );
  }
}
