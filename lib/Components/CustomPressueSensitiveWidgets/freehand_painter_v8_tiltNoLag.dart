import 'dart:ui';

import 'package:innovault/Components/CustomPressueSensitiveWidgets/toolbar_freehand.dart';
import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

// Assuming Toolbar is defined in the same file or imported

//Todo: ADD Mechanism to automatically create a new stroke after a stroke has more than x points to prevent stuttering

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

  final lines = ValueNotifier<List<Stroke>>([]);
  final line = ValueNotifier<Stroke?>(null);

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

    line.value = Stroke([point], options);
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
      line.value = Stroke([...line.value!.points, point], options);
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

            // Previous lines
            Positioned.fill(
              child: RepaintBoundary(
                child: ValueListenableBuilder<List<Stroke>>(
                  valueListenable: lines,
                  builder: (_, strokes, __) {
                    return RepaintBoundary(
                      child: CustomPaint(
                        willChange: false,
                        painter: MultiStrokePainter(strokes: strokes, options: options),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Current line
            Positioned.fill(
              child: ValueListenableBuilder<Stroke?>(
                valueListenable: line,
                builder: (_, currentStroke, __) {
                  return RepaintBoundary(
                    child: CustomPaint(

                      painter: currentStroke != null ? StrokePainter(stroke: currentStroke) : null,
                    ),
                  );
                },
              ),
            ),
            // Toolbar
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
}

class MultiStrokePainter extends CustomPainter {
  final List<Stroke> strokes;
  final StrokeOptions options;

  MultiStrokePainter({required this.strokes, required this.options});

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      final paint = _getPaint(options);
      final path = generatePath(stroke.points, options);
      canvas.drawPath(path, paint);
      debugPrint('Drawing stroke');
    }
  }

  @override
  bool shouldRepaint(MultiStrokePainter oldDelegate) => true;
}

class StrokePainter extends CustomPainter {
  final Stroke stroke;

  StrokePainter({required this.stroke});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = _getPaint(stroke.options);
    final path = generatePath(stroke.points, stroke.options);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(StrokePainter oldDelegate) => true;
}

Paint _getPaint(StrokeOptions options) {
  return Paint()
    ..color = Colors.black
    ..style = PaintingStyle.fill
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..strokeWidth = options.size;
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
