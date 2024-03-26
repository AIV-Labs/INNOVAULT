import 'dart:ui' as ui;
import 'dart:ui';
import 'package:innovault/Components/CustomPressueSensitiveWidgets/toolbar_freehand.dart';
import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

class Stroke {
  List<PointVector> points;
  ui.Path path = ui.Path();
  StrokeOptions options;

  Stroke(this.points, this.options) {
    updatePath();
  }

  void addPoint(PointVector point) {
    points.add(point);
    updatePath();
  }

  void updatePath() {
    final pathData = getStroke(points, options: options);
    path = generatePath(pathData);
  }

  ui.Path generatePath(List<Offset> points) {
    final path = ui.Path();
    if (points.isNotEmpty) {
      path.moveTo(points.first.dx, points.first.dy);
      for (var point in points) {
        path.lineTo(point.dx, point.dy);
      }
    }
    return path;
  }
}

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
    streamline: 1,
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

  final lines = ValueNotifier(<Stroke>[]);
  final line = ValueNotifier<Stroke?>(null);

  void onPointerDown(PointerDownEvent details) {
    final point = _createPoint(details);
    line.value = Stroke([point],options);
  }

  void onPointerMove(PointerMoveEvent details) {
    final point = _createPoint(details);
    if (line.value != null) {
      line.value!.addPoint(point);
      // Trigger an update for the current line
      line.notifyListeners();
    }
  }
  PointVector _createPoint(PointerEvent details) {
    final supportsPressure = details.kind == PointerDeviceKind.stylus;
    return PointVector(
      details.localPosition.dx,
      details.localPosition.dy,
      supportsPressure ? details.pressure : null,
    );
  }

  void onPointerUp(PointerUpEvent details) {
    if (line.value != null) {
      lines.value = List<Stroke>.from(lines.value)..add(line.value!);
      line.value = null;
    }
  }
  void clear() {
    lines.value = [];
    line.value = null;
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
                  builder: (_, lines, __) => CustomPaint(
                    painter: StrokePainter(lines: lines, options: options),
                  ),
                ),
              ),
            ),
            // Current line
            Positioned.fill(
              child: ValueListenableBuilder<Stroke?>(
                valueListenable: line,
                builder: (_, line, __) => CustomPaint(
                  painter: StrokePainter(lines: line != null ? [line] : [], options: options),
                ),
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
}

class StrokePainter extends CustomPainter {
  final List<Stroke> lines;
  final StrokeOptions options;

  StrokePainter({required this.lines, required this.options});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = options.size;

    for (final stroke in lines) {
      canvas.drawPath(stroke.path, paint);
    }
  }

  @override
  bool shouldRepaint(StrokePainter oldDelegate) => true;
}
