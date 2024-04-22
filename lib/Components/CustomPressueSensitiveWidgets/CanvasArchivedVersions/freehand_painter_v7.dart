import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

import 'notebook_background_painter.dart';

// Assuming Toolbar is defined in the same file or imported

class FreehandDrawingCanvas extends StatefulWidget {
  const FreehandDrawingCanvas({Key? key}) : super(key: key);

  @override
  _FreehandDrawingCanvasState createState() => _FreehandDrawingCanvasState();
}
class _FreehandDrawingCanvasState extends State<FreehandDrawingCanvas> {
  StrokeOptions options = StrokeOptions(
    size: 2,
    thinning: 0.7,
    smoothing: 0.6,
    streamline: 0.6,
    start: StrokeEndOptions.start(
      taperEnabled: true,
      customTaper: 0.0,
      cap: true,
    ),
    end: StrokeEndOptions.end(
      taperEnabled: true,
      customTaper: 0.0,
      cap: true,
    ),
    simulatePressure: true,
    isComplete: false,
  );

  List<ValueNotifier<Stroke?>> strokeNotifiers = [];
  final ValueNotifier<Stroke?> currentStrokeNotifier = ValueNotifier<Stroke?>(null);



  void onPointerDown(PointerDownEvent details) {
    final supportsPressure = details.kind == PointerDeviceKind.stylus;
    options = options.copyWith(simulatePressure: !supportsPressure);

    final localPosition = details.localPosition;
    final point = PointVector(
      localPosition.dx,
      localPosition.dy,
      supportsPressure ? details.pressure : null,
    );
    debugPrint('point: $point');

    final newStroke = Stroke([point], options);
    final strokeNotifier = ValueNotifier<Stroke?>(newStroke);
    setState(() {
      strokeNotifiers.add(strokeNotifier);
    });
    currentStrokeNotifier.value = newStroke;
  }

  void onPointerMove(PointerMoveEvent details) {
    if (currentStrokeNotifier.value != null) {
      final supportsPressure = details.pressureMin < 1;
      final localPosition = details.localPosition;
      final point = PointVector(
        localPosition.dx,
        localPosition.dy,
        supportsPressure ? details.pressure : null,
      );

      final updatedPoints = List<PointVector>.from(currentStrokeNotifier.value!.points)
        ..add(point);
      debugPrint('updatedPoints: $updatedPoints');
      currentStrokeNotifier.value = Stroke(updatedPoints, currentStrokeNotifier.value!.options);
    }
  }

  @override
  void onPointerUp(PointerUpEvent details) {
    // Ensure the complete stroke is added to strokeNotifiers
    if (currentStrokeNotifier.value != null) {
      strokeNotifiers.add(ValueNotifier<Stroke?>(currentStrokeNotifier.value));
      currentStrokeNotifier.value = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Listener(
        onPointerDown: onPointerDown,
        onPointerMove: onPointerMove,
        onPointerUp: onPointerUp,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            CustomPaint(
              size: Size.infinite,
              painter: NotebookBackgroundPainter(backgroundType: BackgroundType_OLD.grid),
            ),
            // Render each stroke with its own painter
            ...strokeNotifiers.map(
                  (notifier) => ValueListenableBuilder<Stroke?>(
                valueListenable: notifier,
                builder: (_, stroke, __) => stroke != null ? CustomPaint(painter: StrokePainter(stroke: stroke)) : const SizedBox.shrink(),
              ),
            ),
            // Current stroke
            ValueListenableBuilder<Stroke?>(
              valueListenable: currentStrokeNotifier,
              builder: (_, stroke, __) => stroke != null ? CustomPaint(painter: StrokePainter(stroke: stroke)) : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    strokeNotifiers.forEach((notifier) => notifier.dispose());
    currentStrokeNotifier.dispose();
  }
}

class StrokePainter extends CustomPainter {
  final Stroke stroke;

  StrokePainter({required this.stroke});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill // Use stroke but with a thick width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = stroke.options.size *3; // Example of a thicker line

    final path = generatePath(stroke.points, stroke.options);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(StrokePainter oldDelegate) => oldDelegate.stroke != stroke;
}


Path generatePath(List<PointVector> points, StrokeOptions options) {
  final path = Path();
  final data = getStroke(points, options: options);

  if (data.isEmpty) return path;

  path.moveTo(data.first.dx, data.first.dy);
  for (final point in data.skip(1)) {
    path.lineTo(point.dx, point.dy);
  }
  return path;
}

class Stroke {
  List<PointVector> points;
  final StrokeOptions options;
  Stroke(this.points, this.options);
}
