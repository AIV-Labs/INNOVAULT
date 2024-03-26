import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:innovault/Components/CustomPressueSensitiveWidgets/toolbar_freehand.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

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

  final lines = ValueNotifier(<Stroke>[]); // Previous lines drawn
  final line = ValueNotifier<Stroke?>(null); // The current line being drawn

  void clear() {
    lines.value = [];
    line.value = null;
  }

  void onPointerDown(PointerDownEvent details) {
    final supportsPressure = details.kind == PointerDeviceKind.stylus;
    options = options.copyWith(simulatePressure: !supportsPressure);

    final localPosition = details.localPosition;
    final point = PointVector(
      localPosition.dx,
      localPosition.dy,
      supportsPressure ? details.pressure : null,
    );

    line.value = Stroke([point]);
  }

  void onPointerMove(PointerMoveEvent details) {
    final supportsPressure = details.pressureMin < 1;
    final localPosition = details.localPosition;
    final point = PointVector(
      localPosition.dx,
      localPosition.dy,
      supportsPressure ? details.pressure : null,
    );

    if (line.value != null) {
      line.value = Stroke([...line.value!.points, point]);
    }
  }

  void onPointerUp(PointerUpEvent details) {
    if (line.value != null) {
      lines.value = [...lines.value, line.value!];
      line.value = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Listener(
        onPointerDown: onPointerDown,
        onPointerMove: onPointerMove,
        onPointerUp: onPointerUp,
        child: Stack(
          children: [
            Positioned.fill(
              child: ValueListenableBuilder<List<Stroke>>(
                valueListenable: lines,
                builder: (_, lines, __) {
                  return CustomPaint(
                    painter: StrokePainter(
                      lines: lines,
                      options: options,
                    ),
                  );
                },
              ),
            ),
            Positioned.fill(
              child: ValueListenableBuilder<Stroke?>(
                valueListenable: line,
                builder: (_, line, __) {
                  return CustomPaint(
                    painter: StrokePainter(
                      lines: line != null ? [line] : [],
                      options: options,
                    ),
                  );
                },
              ),
            ),
            Toolbar(
              options: options,
              updateOptions: (Function() update) => setState(update),
              clear: clear,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    lines.dispose();
    line.dispose();
    super.dispose();
  }
}

class StrokePainter extends CustomPainter {
  StrokePainter({
    required this.lines,
    required this.options,
  });

  final List<Stroke> lines;
  final StrokeOptions options;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final stroke in lines) {
      final points = stroke.points;
      if (points.isEmpty) continue;

      final path = generatePath(points, options);
      paint.strokeWidth = options.size;
      canvas.drawPath(path, paint);
    }
  }

  Path generatePath(List<PointVector> points, StrokeOptions options) {
    final path = Path();
    final data = getStroke(points, options: options);

    if (data.isEmpty) return path;

    final move = data.first;
    path.moveTo(move.dx, move.dy);

    for (final point in data.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }

    return path;
  }

  @override
  bool shouldRepaint(StrokePainter oldDelegate) {
    return oldDelegate.lines != lines || oldDelegate.options != options;
  }
}

class Stroke {
  final List<PointVector> points;
  Stroke(this.points);
}
