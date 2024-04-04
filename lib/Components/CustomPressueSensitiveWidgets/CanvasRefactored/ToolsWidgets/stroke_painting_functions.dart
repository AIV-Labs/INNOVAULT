

import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

import '../../../../Functions/Providers/pen_options_provider.dart';

class StrokePainter extends CustomPainter {
  final Stroke stroke;
  final PointerMode strokeStyle;
  StrokePainter({required this.stroke, required this.strokeStyle});

  @override
  void paint(Canvas canvas, Size size) {
    if (strokeStyle == PointerMode.pen){
      final paint = _getPaint(stroke.style);

      final pointVectors = stroke.points.whereType<PointVector>().toList();
      if (pointVectors.isNotEmpty) {
        final path = generatePath(pointVectors, stroke.options);
        canvas.drawPath(path, paint);
      }

      final dots = stroke.points.whereType<Dot>().toList();
      for (final dot in dots) {
        canvas.drawCircle(Offset(dot.x, dot.y), dot.radius, paint);
      }
    }
    // brush
    // if (strokeStyle == PointerMode.brush) {
    //   final paint = Paint()
    //     ..color = stroke.style.color
    //     ..style = PaintingStyle.stroke
    //     ..strokeCap = StrokeCap.round
    //     ..strokeJoin = StrokeJoin.round
    //     ..strokeWidth = stroke.style.size; // Adjust for brush size
    //
    //   Path path = Path();
    //   if (stroke.points.isNotEmpty) {
    //     path.moveTo(stroke.points.first.dx, stroke.points.first.dy);
    //     for (var i = 1; i < stroke.points.length; i++) {
    //       path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
    //     }
    //     canvas.drawPath(path, paint);
    //   }
    // }
  }

  @override
  bool shouldRepaint(StrokePainter oldDelegate) => true;
}


class MultiStrokePainter extends CustomPainter {
  final List<Stroke> strokes;

  MultiStrokePainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {


    for (final stroke in strokes) {
      // pen mode
      if (stroke.mode == PointerMode.pen){
        final paint = _getPaint(stroke.style);

        final pointVectors = stroke.points.whereType<PointVector>().toList();
        if (pointVectors.isNotEmpty) {
          final path = generatePath(pointVectors, stroke.options);
          canvas.drawPath(path, paint);
        }

        final dots = stroke.points.whereType<Dot>().toList();
        for (final dot in dots) {
          canvas.drawCircle(Offset(dot.x, dot.y), dot.radius, paint);
        }
      }
      // brush
      //   if (stroke.mode == PointerMode.brush) {
      //     PointVector? previousPoint;
      //     for (final point in stroke.points.whereType<PointVector>()) {
      //       // Calculate the "speed" based on the distance between points
      //       double speed = previousPoint != null ?
      //       sqrt(pow(point.x - previousPoint.x, 2) + pow(point.y - previousPoint.y, 2)) : 0;
      //
      //       // Adjust the radius based on the speed
      //       double radius = stroke.style.size * (1 - min(speed / 10, 1));
      //
      //       // Ensure the radius does not get too small or inversely grow too large
      //       radius = max(min(radius, stroke.style.size * 2), stroke.style.size * 0.5);
      //
      //       final paint = Paint()
      //         ..shader = RadialGradient(
      //           colors: [stroke.style.color, stroke.style.color.withOpacity(0)],
      //           stops: [0.3, 1.0],  // Adjust the stops for a more pronounced gradient
      //         ).createShader(Rect.fromCircle(center: Offset(point.x, point.y), radius: radius))
      //         ..style = PaintingStyle.fill;
      //
      //       // Draw the circle at each point with the gradient effect
      //       canvas.drawCircle(Offset(point.x, point.y), radius, paint);
      //
      //       previousPoint = point;
      //     }
      //   }
    }}

  @override
  bool shouldRepaint(MultiStrokePainter oldDelegate) => true;
}

Paint _getPaint(StrokeStyle style) {
  return Paint()
    ..color = style.color
    ..style = PaintingStyle.fill
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..strokeWidth = style.size;
}

Path generatePath(List<PointVector> points, StrokeOptions options) {
  final path = Path();
  final data = getStroke(points, options: options);

  if (data.isEmpty) return path;

  path.moveTo(data.first.dx, data.first.dy);
  for (var i = 0; i < data.length - 1; i++) {
    final currentPoint = data[i];
    final nextPoint = data[i + 1];
    final controlPoint = Offset(
      (currentPoint.dx + nextPoint.dx) / 2,
      (currentPoint.dy + nextPoint.dy) / 2,
    );
    path.quadraticBezierTo(
      currentPoint.dx,
      currentPoint.dy,
      controlPoint.dx,
      controlPoint.dy,
    );
  }
  return path;
}