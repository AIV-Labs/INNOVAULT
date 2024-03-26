import 'dart:ui';
import 'package:flutter/material.dart';

class PressureSensitiveCanvas extends StatefulWidget {
  @override
  _PressureSensitiveCanvasState createState() => _PressureSensitiveCanvasState();
}

class _PressureSensitiveCanvasState extends State<PressureSensitiveCanvas> {
  final List<TouchPoint?> points = [];

  void updatePoints(PointerEvent details) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset localPosition = renderBox.globalToLocal(details.position);

    setState(() {
      if (details is PointerDownEvent || details is PointerMoveEvent) {
        points.add(TouchPoint(localPosition, details.pressure ?? 0));
      }

      if (details is PointerUpEvent || details is PointerCancelEvent) {
        points.add(null); // Add a null point to signify the end of the current stroke.
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: updatePoints,
      onPointerMove: updatePoints,
      onPointerUp: updatePoints,
      onPointerCancel: updatePoints,
      child: CustomPaint(
        painter: PressureSensitivePainter(points),
        child: ConstrainedBox(constraints: BoxConstraints.expand()),
      ),
    );
  }
}

class PressureSensitivePainter extends CustomPainter {
  final List<TouchPoint?> points;

  PressureSensitivePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        paint.strokeWidth = (points[i]!.pressure ?? 1) * 10;
        canvas.drawLine(points[i]!.position, points[i + 1]!.position, paint);
      } else if (points[i] != null && points[i + 1] == null) {
        // This is the end of a stroke, no action needed here for now.
      }
    }
  }

  @override
  bool shouldRepaint(PressureSensitivePainter oldDelegate) {
    // Only repaint if the list of points has changed.
    return oldDelegate.points != points;
  }
}

class TouchPoint {
  Offset position;
  double? pressure;

  TouchPoint(this.position, this.pressure);
}
