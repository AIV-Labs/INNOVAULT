import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:innovault/Components/CustomPressueSensitiveWidgets/CanvasArchivedVersions/toolbar_freehand.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

import 'notebook_background_painter.dart';


// Assuming Toolbar is defined in the same file or imported

//Todo: ADD Mechanism to automatically create a new stroke after a stroke has more than x points to prevent stuttering
// TODO: if there is no line and it is jsut one point make it a circle
// if the line is still going the last stroke should end with a cap
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
    streamline: 0.34,
    easing: (double t) => t/2,
    start: StrokeEndOptions.start(
      taperEnabled: true,
      cap: true,
      customTaper: 20,
    ),
    end: StrokeEndOptions.end(
      taperEnabled: true,
      cap: true,
      customTaper: 20,
    ),
    simulatePressure: true,
    isComplete: false,
  );

  final lines = ValueNotifier<List<Stroke>>([]);
  final line = ValueNotifier<Stroke?>(null);

// Stroke Style
  // Stoke Size
  StrokeStyle currentStrokeStyle = StrokeStyle(size: 2, color: Colors.black);
  void updateStrokeSize(double newSize) {
    setState(() {

      // Update the streamline and smoothing
      // Linear interpolation between the minimum and maximum values
      options = options.copyWith(
        size: newSize,
        streamline: 0.3 + (newSize - 2 >0 ? newSize - 2:1 ) * (1 - 0.6) / (20 - 2),
        smoothing: 1- (newSize - 2 >0 ? newSize - 2:1 ) * (1 - 0) / (20 - 2),
      );
    });
  }
  void updateStrokeThinning(double newThinning) {
    setState(() {
      options = options.copyWith(thinning: newThinning);
    });
  }
  // Stroke Color
  Color _currentColor = Colors.black;
  void updateStrokeColor(Color newColor) {
    setState(() {
      currentStrokeStyle.color = newColor;
    });

  }
// erasing functionality
  bool isEraserMode = false;

  void eraseStrokeAtPoint(Offset point) {
    lines.value = lines.value.where((stroke) {
      return !doesStrokeContainPoint(stroke, point);
    }).toList();
  }
  bool doesStrokeContainPoint(Stroke stroke, Offset point) {
    final path = Path();
    if (stroke.points.isNotEmpty) {
      path.moveTo(stroke.points.first.x, stroke.points.first.y);
      for (final point in stroke.points.skip(1)) {
        path.lineTo(point.x, point.y);
      }
    }
    return path.contains(point);
  }
  void toggleEraserMode() {
    setState(() {
      isEraserMode = !isEraserMode;
    });
  }


  void clear() {
    lines.value = [];
    line.value = null;
    pointCount = 0;
  }

  void onPointerDown(PointerDownEvent details) {
    if (isEraserMode) {
      eraseStrokeAtPoint(details.localPosition);
    } else {
      final supportsPressure = details.kind == PointerDeviceKind.stylus;
      options = options.copyWith(simulatePressure: !supportsPressure);

      final localPosition = details.localPosition;
      final point = PointVector(
        localPosition.dx,
        localPosition.dy,
        supportsPressure ? details.pressure : null,
      );

      // Create a new StrokeStyle for the new stroke
      // Use dotSize for the size of the stroke
      final strokeStyle = StrokeStyle(size: currentStrokeStyle.size*10, color: currentStrokeStyle.color);

      // Use the current color and size when creating a new stroke
      // Add the same point twice to the new stroke
      line.value = Stroke([point, point], options, strokeStyle);

      // Add this line to draw a circle at the tap location
      lines.value = [...lines.value, line.value!];
      line.value = null;
    }
  }
  static const int MAX_POINTS = 750; // Define your own threshold here
  int pointCount = 0;


  void onPointerMove(PointerMoveEvent details) {
    if (isEraserMode) {
      eraseStrokeAtPoint(details.localPosition);
    } else {
      final supportsPressure = details.pressureMin < 1;
      final localPosition = details.localPosition;
      final point = PointVector(
        localPosition.dx,
        localPosition.dy,
        supportsPressure ? details.pressure : null,
      );

      if (line.value != null) {
        // Use the same StrokeStyle when adding a point to the stroke
        line.value = Stroke([...line.value!.points, point], options, line.value!.style);
        pointCount++;

        if (pointCount >= MAX_POINTS) {
          // If the current stroke has reached the maximum points, start a new stroke from the last two points of the previous stroke
          lines.value = [...lines.value, line.value!];
          int startIndex = line.value!.points.length - (currentStrokeStyle.size.round()*2.5).toInt();
          startIndex = startIndex >= 0 ? startIndex : 0; // Ensure the startIndex is not negative
          line.value = Stroke([line.value!.points[startIndex], line.value!.points.last], options, currentStrokeStyle);
          pointCount = 2; // Reset the count to 2 as the new stroke already has two points
        }
      } else {
        // If no stroke is in progress, start a new stroke
        line.value = Stroke([point], options, currentStrokeStyle);
        pointCount = 1;
      }
    }
  }

// v1: onpointerUp
//   void onPointerUp(PointerUpEvent details) {
//     if (line.value != null) {
//       lines.value = [...lines.value, line.value!];
//       line.value = null;
//       // buffer = []; // Clear the buffer
//     }
//   }

  // v2: adding multiple points instead

//   void onPointerUp(PointerUpEvent details) {
//   if (line.value != null) {
//     debugPrint('onPointerUp: line.value!.points.length = ${line.value!.points.length}');
//
//     // If the current line only has one point, add additional points within a circle of radius 2 around it
//     if (line.value!.points.length <=8) {
//       debugPrint('Adding additional points');
//       final originalPoint = line.value!.points.first;
//       final additionalPoints = <PointVector>[];
//
//       // Create a new StrokeStyle for the additional points with a size of 1
//       final dotStyle = StrokeStyle(size: 1, color: currentStrokeStyle.color,);
//
//       // Create a new StrokeOptions with the desired taper and cap settings
//       final dotOptions = StrokeOptions(
//         start: StrokeEndOptions.start(taperEnabled: false, cap: false),
//         end: StrokeEndOptions.end(taperEnabled: false, cap: false),
//         // Copy other options from the current options
//         size: options.size,
//         thinning: options.thinning,
//         smoothing: options.smoothing,
//         streamline: options.streamline,
//         easing: options.easing,
//         simulatePressure: options.simulatePressure,
//         isComplete: options.isComplete,
//       );
//
//       // Calculate additional points within a circle of radius 2 around the original point
//       for (var r = 0; r <= 2; r += currentStrokeStyle.size.toInt()) { // Change the step size to control the number of points
//         for (var i = 0; i < 360; i += currentStrokeStyle.size.toInt()) { // Change the step size to control the number of points
//           final radian = i * (pi / 180);
//           final dx = originalPoint.x + r * cos(radian);
//           final dy = originalPoint.y + r * sin(radian);
//           additionalPoints.add(PointVector(dx, dy, 1));
//           debugPrint('Adding additional points ${additionalPoints.length}');
//         }
//       }
//
//       // Add the additional points to the current line
//       line.value = Stroke([...line.value!.points, ...additionalPoints], dotOptions, dotStyle);
//     }
//
//     lines.value = [...lines.value, line.value!];
//     line.value = null;
//     pointCount = 0;
//   }
//
//
// }

  // v3
void onPointerUp(PointerUpEvent details) {
  if (line.value != null) {
    if (line.value!.points.length <= 8) {
      // If the stroke only has one point, create a circle
      final point = line.value!.points.first;

      // Create a new StrokeStyle for the circle with a size of 1
      final circleStyle = StrokeStyle(size: currentStrokeStyle.size, color: currentStrokeStyle.color,);

      // Create a new StrokeOptions with the desired taper and cap settings
      final circleOptions = StrokeOptions(
        start: StrokeEndOptions.start(taperEnabled: false, cap: false),
        end: StrokeEndOptions.end(taperEnabled: false, cap: false),
        // Copy other options from the current options
        size: options.size,
        thinning: options.thinning,
        smoothing: options.smoothing,
        streamline: options.streamline,
        easing: options.easing,
        simulatePressure: options.simulatePressure,
        isComplete: options.isComplete,
      );

      // Create a new Stroke for the circle and add it to the lines list
      final circleStroke = Stroke([point, point], circleOptions, circleStyle);
      lines.value = [...lines.value, circleStroke];
    } else {
      // If the stroke has more than one point, add it to the lines list as usual
      lines.value = [...lines.value, line.value!];
    }

    line.value = null;
    pointCount = 0;
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

            CustomPaint(
              size: Size.infinite,
              painter: NotebookBackgroundPainter(backgroundType: BackgroundType_OLD.grid),
            ),
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

            Positioned(
              bottom: 0,
              right: 0,
              child: UserToolbar(
                currentSize: currentStrokeStyle.size,
                currentColor: _currentColor,
                currentSensitivity: 0.7,
                onSizeChange: updateStrokeSize,
                onSensitivityChange: updateStrokeThinning,
                onColorChange: updateStrokeColor,
                clear: clear,
                onToggleEraserMode: toggleEraserMode,
                onTogglePartialEraserMode: toggleEraserMode,
                onTogglePenMode: toggleEraserMode,
              ),
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
      final paint = _getPaint(stroke.style);
      final path = generatePath(stroke.points, stroke.options);
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
    final paint = _getPaint(stroke.style); // Use the style of the stroke

    if (stroke.points.length <= 8) {
      // If the stroke only has one point, draw a circle
      // drawing a circle
      debugPrint  ('Drawing circle');
      final point = stroke.points.first;
      canvas.drawCircle(Offset(point.x, point.y), stroke.style.size, paint);
    } else {
      // If the stroke has more than one point, draw a path
      final path = generatePath(stroke.points, stroke.options);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(StrokePainter oldDelegate) => true;
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

class Stroke {
  List<PointVector> points;
  final StrokeOptions options;
  final StrokeStyle style; // Add this line

  Stroke(this.points, this.options, this.style); // Modify this line
}

class UserToolbar extends StatefulWidget {
  final double currentSize;
  final Color currentColor;
  final double currentSensitivity;
  final Function(double) onSizeChange;
  final Function(Color) onColorChange;
  final Function(double) onSensitivityChange;
  final VoidCallback clear;
  final VoidCallback onToggleEraserMode; // Callback for toggling eraser mode
  final VoidCallback onTogglePartialEraserMode; // Callback for toggling partial eraser mode
  final VoidCallback onTogglePenMode; // Callback for toggling pen mode


  const UserToolbar({
    Key? key,
    required this.currentSize,
    required this.currentColor,
    required this.currentSensitivity,
    required this.onSizeChange,
    required this.onColorChange,
    required this.clear,
    required this.onToggleEraserMode,
    required this.onTogglePartialEraserMode,
    required this.onTogglePenMode,
    required this.onSensitivityChange,
  }) : super(key: key);

  @override
  State<UserToolbar> createState() => _UserToolbarState();
}

class _UserToolbarState extends State<UserToolbar> {
  late double _currentSize;
  late Color _currentColor;
  late double _currentSensitivity;

  @override
  void initState() {
    super.initState();
    _currentSize = widget.currentSize;
    _currentColor = widget.currentColor;
    _currentSensitivity = 0.7;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          // Size Slider
          Row(
            children: [
              Text('Size:'),
              Slider(
                min: 1.0,
                max: 20.0,
                value: _currentSize,
                onChanged: (value) {
                  setState(() {
                    _currentSize = value;
                  });
                  widget.onSizeChange(value);
                },
              ),
              // Color picker
              DropdownButton<Color>(
                value: _currentColor,
                onChanged: (Color? newColor) {
                  setState(() {
                    if (newColor != null) {
                      _currentColor = newColor;
                      widget.onColorChange(newColor);
                    }
                  });
                },
                items: <Color>[Colors.black, Colors.red, Colors.green, Colors.blue]
                    .map<DropdownMenuItem<Color>>((Color value) {
                  return DropdownMenuItem<Color>(
                    value: value,
                    child: Container(
                      width: 20,
                      height: 20,
                      color: value,
                    ),
                  );
                }).toList(),
              ),

            ],
          ),
          // Thinning Slider
          Row(children: [
            Text('Sensitiity'),
            Slider(
              min: 0.0,
              max: 1.0,
              value: _currentSensitivity,
              onChanged: (value) {
                setState(() {
                  _currentSensitivity = value;
                });
                widget.onSensitivityChange(value);
              },
            ),
          ],),
          ElevatedButton(
            onPressed: widget.onToggleEraserMode,
            child: Text('Eraser Mode'),
          ),
          ElevatedButton(
            onPressed: widget.onTogglePartialEraserMode,
            child: Text('Partial Eraser Mode'),
          ),
          ElevatedButton(
            onPressed: widget.onTogglePenMode,
            child: Text('Pen Mode'),
          ),

          ElevatedButton(
            onPressed: widget.clear,
            child: Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class StrokeStyle {
  double size;
  Color color;

  StrokeStyle({required this.size, required this.color});
}
