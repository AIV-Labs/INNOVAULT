import 'dart:ui';

import 'package:flutter/material.dart';

class PressureSensitiveCanvasV1 extends StatefulWidget {
  @override
  _PressureSensitiveCanvasV1State createState() => _PressureSensitiveCanvasV1State();
}

class _PressureSensitiveCanvasV1State extends State<PressureSensitiveCanvasV1> {
  List<TouchPoint?> points = [];

  void updatePoints(PointerEvent details) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset localPosition = renderBox.globalToLocal(details.position);
    setState(() {
      points.add(TouchPoint(localPosition, details.pressure ?? 0));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerMove: updatePoints,
      onPointerUp: (PointerUpEvent event) => setState(() => points.add(null)),
      child: CustomPaint(
        painter: PressureSensitivePainterV1(points),
        child: ConstrainedBox(
          constraints: BoxConstraints.expand(),
        ),
      ),
    );
  }
}
class PressureSensitivePainterV1 extends CustomPainter {
  final List<TouchPoint?> points;

  PressureSensitivePainterV1(this.points);

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
        paint.strokeWidth = (points[i]!.pressure ?? 1) * 10;
        canvas.drawPoints(PointMode.points, [points[i]!.position], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class TouchPoint {
  Offset position;
  double? pressure;

  TouchPoint(this.position, this.pressure);
}