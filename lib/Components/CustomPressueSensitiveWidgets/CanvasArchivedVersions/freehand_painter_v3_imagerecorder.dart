import 'dart:ui' as ui;


import 'package:flutter/material.dart';
import 'package:innovault/Components/CustomPressueSensitiveWidgets/CanvasArchivedVersions/toolbar_freehand.dart';
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

  final lines = ValueNotifier(<Stroke>[]);
  final line = ValueNotifier<Stroke?>(null);
  ui.Image? cachedImage; // Cached image for completed strokes

  void clear() {
    lines.value = [];
    line.value = null;
    cachedImage?.dispose();
    cachedImage = null;
    redrawCanvas(); // Redraw the canvas to update the cache
  }


  Path generatePath(List<PointVector> points, StrokeOptions options) {
    final path = Path();
    // TODO: if no stylus use simulator of stroke
    // Use perfect_freehand's getStroke method to create a smoothed path from the points
    final data = getStroke(points, options: options);

    if (data.isNotEmpty) {
      path.moveTo(data.first.dx, data.first.dy);
      for (final point in data.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
    }

    return path;
  }
  @override
  void didUpdateWidget(covariant FreehandDrawingCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    redrawCanvas(); // Redraw when the widget updates
  }


  void onPointerDown(PointerDownEvent details) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.localPosition);
    final point = PointVector(
      localPosition.dx,
      localPosition.dy,
      details.pressure ?? 0.5, // Default pressure value if not available
    );

    // Set the current line with the new point
    line.value = Stroke(points:[point], color:Colors.black); // TODO: color
  }

  void onPointerMove(PointerMoveEvent details) {
    if (line.value == null) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.localPosition);
    final point = PointVector(
      localPosition.dx,
      localPosition.dy,
      details.pressure ?? 0.5, // Default pressure value if not available
    );

    // Add the new point to the current line
    final newPoints = List<PointVector>.from(line.value!.points)..add(point);
    line.value = Stroke(points: newPoints, color: line.value!.color);
  }

  void onPointerUp(PointerUpEvent details) {
    if (line.value != null) {
      lines.value = List.from(lines.value)..add(line.value!); // Add the current line to the lines list
      redrawCanvas(); // Redraw the off-screen canvas including the new line
      line.value = null; // Clear the current line
    }
  }

  void redrawCanvas() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Draw each stroke on the off-screen canvas
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final stroke in lines.value) {
      debugPrint('line: ${line.value}');
      final path = generatePath(stroke.points, options);
      paint.color = stroke.color;
      paint.strokeWidth = options.size;
      canvas.drawPath(path, paint);
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(context.size!.width.toInt(), context.size!.height.toInt());
    setState(() {
      cachedImage?.dispose(); // Dispose the old image
      cachedImage = img; // Update the cached image
    });
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
              child: CustomPaint(
                painter: CachedImagePainter(image: cachedImage), // Render the cached image
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
    cachedImage?.dispose();
    super.dispose();
  }
}

// CachedImagePainter to render the cached image
class CachedImagePainter extends CustomPainter {
  final ui.Image? image;

  CachedImagePainter({this.image});

  @override
  void paint(Canvas canvas, Size size) {
    if (image != null) {
      canvas.drawImage(image!, Offset.zero, Paint());
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
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
    final paint = Paint()..color = Colors.black;

    for (final line in lines) {
      final outlinePoints = getStroke(line.points, options: options);

      if (outlinePoints.isEmpty) {
        continue;
      } else if (outlinePoints.length < 2) {
        // If the path only has one point, draw a dot.
        canvas.drawCircle(
          outlinePoints.first,
          options.size / 2,
          paint,
        );
      } else {
        final path = Path();
        path.moveTo(outlinePoints.first.dx, outlinePoints.first.dy);
        for (int i = 0; i < outlinePoints.length - 1; ++i) {
          final p0 = outlinePoints[i];
          final p1 = outlinePoints[i + 1];
          path.quadraticBezierTo(
            p0.dx,
            p0.dy,
            (p0.dx + p1.dx) / 2,
            (p0.dy + p1.dy) / 2,
          );
        }
        // You'll see performance improvements if you cache this Path
        // instead of creating a new one every paint.
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class Stroke {
  final List<PointVector> points;
  final Color color;
  Stroke({required this.points, required this.color});
}
