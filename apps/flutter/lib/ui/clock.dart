import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';

class Clock extends StatefulWidget {
  final double width;
  final double ratio;
  final Color color;
  final bool withBorder;

  const Clock({
    super.key,
    this.width = 12.0,
    double ratio = 45,
    required this.color,
    this.withBorder = true,
  }) : ratio = ratio > 100 ? 100 : ratio;

  @override
  State<Clock> createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  late Timer timer;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {});
        }
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.now();

    return LayoutBuilder(
      builder: (context, constraints) {
        final space = min(constraints.maxWidth, constraints.maxHeight);
        final size = space * (widget.ratio.abs() / 100);
        final timeSize = size * 0.2;
        final separtor = size * 0.08;
        final dateSize = size * 0.08;
        final margin = size * 0.05;

        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: margin),
              child: Text(
                '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: timeSize,
                  color: widget.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: timeSize + separtor),
              child: Text(
                '${date.day}/${date.month}/${date.year}',
                style: TextStyle(fontSize: dateSize, color: widget.color.withAlpha(128)),
              ),
            ),
            if (widget.withBorder)
              CustomPaint(
                size: Size(size, size),
                painter: ClockPainter(date: date, color: widget.color, width: widget.width),
              ),
          ],
        );
      },
    );
  }
}

class ClockPainter extends CustomPainter {
  final DateTime date;
  final Color color;
  final double width;

  ClockPainter({required this.date, required this.color, this.width = 12.0});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final backgroundPaint = Paint()
      ..color = color.withAlpha(64)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = width;

    canvas.drawCircle(center, radius - width / 2, backgroundPaint);

    double progress = (date.hour % 12) / 12 + (date.minute / (12 * 60));
    double startAngle = -pi / 2;
    double sweepAngle = 2 * pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - width / 2),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(ClockPainter oldDelegate) => true;
}
