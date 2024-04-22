import 'package:flutter/material.dart';


enum BackgroundType_OLD {
  none,
  verticalLines,
  horizontalLines,
  grid,
  color
}
class NotebookBackgroundPainter extends CustomPainter {
  final BackgroundType_OLD backgroundType;
  final Color bgColor;
  final Color lineColor;

  NotebookBackgroundPainter({
    this.backgroundType = BackgroundType_OLD.none,
    this.bgColor = Colors.white,
    this.lineColor = Colors.blueGrey,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (backgroundType != BackgroundType_OLD.none || backgroundType == BackgroundType_OLD.color) {
      final backgroundPaint = Paint()..color = bgColor;
      canvas.drawRect(Offset.zero & size, backgroundPaint);
    }

    // Then draw the lines
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 0.5;

    if (backgroundType == BackgroundType_OLD.verticalLines || backgroundType == BackgroundType_OLD.grid) {
      for (var i = 0; i < size.width; i += 20) {
        canvas.drawLine(Offset(i.toDouble(), 0), Offset(i.toDouble(), size.height), linePaint);
      }
    }

    if (backgroundType == BackgroundType_OLD.horizontalLines || backgroundType == BackgroundType_OLD.grid) {

      for (var i = 0; i < size.height; i += 20) {
        canvas.drawLine(Offset(0, i.toDouble()), Offset(size.width, i.toDouble()), linePaint);
      }
    }

    // if (backgroundType == BackgroundType.color) {
    //   paint.color = bgColor;
    //   canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), linePaint);
    // }
    if (backgroundType == BackgroundType_OLD.color) {
      final backgroundPaint = Paint()..color = bgColor;
      canvas.drawRect(Offset.zero & size, backgroundPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // consider type and color
    return oldDelegate is! NotebookBackgroundPainter ||
        oldDelegate.backgroundType != backgroundType ||
        oldDelegate.bgColor != bgColor ||
        oldDelegate.lineColor != lineColor;
  }
}