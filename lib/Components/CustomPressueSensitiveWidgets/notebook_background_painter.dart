import 'package:flutter/material.dart';


enum BackgroundType {
  none,
  verticalLines,
  horizontalLines,
  grid,
}
class NotebookBackgroundPainter extends CustomPainter {
  final BackgroundType backgroundType;

  NotebookBackgroundPainter({this.backgroundType = BackgroundType.none});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueGrey
      ..strokeWidth = 0.5;

    if (backgroundType == BackgroundType.verticalLines ||
        backgroundType == BackgroundType.grid) {
      for (var i = 0; i < size.width; i += 20) {
        canvas.drawLine(Offset(i.toDouble(), 0), Offset(i.toDouble(), size.height), paint);
      }
    }

    if (backgroundType == BackgroundType.horizontalLines ||
        backgroundType == BackgroundType.grid) {
      for (var i = 0; i < size.height; i += 20) {
        canvas.drawLine(Offset(0, i.toDouble()), Offset(size.width, i.toDouble()), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}