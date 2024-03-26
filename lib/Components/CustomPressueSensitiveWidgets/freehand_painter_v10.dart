import 'dart:ui';

import 'package:innovault/Components/CustomPressueSensitiveWidgets/toolbar_freehand.dart';
import 'package:flutter/material.dart';
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
    streamline: 0.6,
    start: StrokeEndOptions.start(
      taperEnabled: false,
      customTaper: 0.0,
      cap: false,
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

// Stroke Style
  // Stoke Size
  StrokeStyle currentStrokeStyle = StrokeStyle(size: 2, color: Colors.black);
  void updateStrokeSize(double newSize) {
    setState(() {

      // Update the streamline and smoothing
      // Linear interpolation between the minimum and maximum values
      options = options.copyWith(
        size: newSize,
        streamline: 0.6 + (newSize - 2 >0 ? newSize - 2:1 ) * (1 - 0.6) / (20 - 2),
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
      // options = options.copyWith(simulatePressure: !supportsPressure);

      final localPosition = details.localPosition;
      final point = PointVector(
        localPosition.dx,
        localPosition.dy,
        supportsPressure ? details.pressure : null,
      );

      // Create a new StrokeStyle for the new stroke
      final strokeStyle = StrokeStyle(size: currentStrokeStyle.size, color: currentStrokeStyle.color);


      // Use the current color and size when creating a new stroke
      line.value = Stroke([point], options, strokeStyle);
    }
  }

  // v1 on pointer move
  // void onPointerMove(PointerMoveEvent details) {
  //   if (isEraserMode) {
  //     eraseStrokeAtPoint(details.localPosition);
  //   } else {
  //     final supportsPressure = details.pressureMin < 1;
  //     final localPosition = details.localPosition;
  //     final point = PointVector(
  //       localPosition.dx,
  //       localPosition.dy,
  //       supportsPressure ? details.pressure : null,
  //     );
  //
  //     if (line.value != null) {
  //       // Use the same StrokeStyle when adding a point to the stroke
  //       line.value = Stroke([...line.value!.points, point], options, line.value!.style);
  //
  //     }
  //
  //   }
  // }

  static const int MAX_POINTS = 750; // Define your own threshold here
  int pointCount = 0;
  // v2 on pointer move : threshold for adding new point to stroke

  // void onPointerMove(PointerMoveEvent details) {
  //   if (isEraserMode) {
  //     eraseStrokeAtPoint(details.localPosition);
  //   } else {
  //     final supportsPressure = details.pressureMin < 1;
  //     final localPosition = details.localPosition;
  //     final point = PointVector(
  //       localPosition.dx,
  //       localPosition.dy,
  //       supportsPressure ? details.pressure : null,
  //     );
  //
  //     if (line.value != null) {
  //       // Use the same StrokeStyle when adding a point to the stroke
  //       line.value = Stroke([...line.value!.points, point], options, line.value!.style);
  //       pointCount++;
  //
  //       if (pointCount >= MAX_POINTS) {
  //         // Start a new stroke and reset the count
  //         lines.value = [...lines.value, line.value!];
  //         line.value = null;
  //         pointCount = 0;
  //         // onPointerMove(details);
  //       }
  //     }
  //   }
  // }

  // v3 on pointer move : threshhold + resume


  // v4: no buffer no lag! just entering a bit earlier
//   void onPointerMove(PointerMoveEvent details) {
//   if (isEraserMode) {
//     eraseStrokeAtPoint(details.localPosition);
//   } else {
//     final supportsPressure = details.pressureMin < 1;
//     final localPosition = details.localPosition;
//     final point = PointVector(
//       localPosition.dx,
//       localPosition.dy,
//       supportsPressure ? details.pressure : null,
//     );
//
//     if (line.value != null) {
//       // Use the same StrokeStyle when adding a point to the stroke
//       line.value = Stroke([...line.value!.points, point], options, line.value!.style);
//       pointCount++;
//
//       if (pointCount >= MAX_POINTS) {
//         // If the current stroke has reached the maximum points, start a new stroke from the last two points of the previous stroke
//         lines.value = [...lines.value, line.value!];
//         line.value = Stroke([line.value!.points[line.value!.points.length - 5], line.value!.points.last], options, currentStrokeStyle); // Start a new stroke from the last two points of the previous stroke
//         pointCount = 2; // Reset the count to 2 as the new stroke already has two points
//       }
//     } else {
//       // If no stroke is in progress, start a new stroke
//       line.value = Stroke([point], options, currentStrokeStyle);
//       pointCount = 1;
//     }
//   }
// }

  // v5: v5+ dynamic Cap
//   void onPointerMove(PointerMoveEvent details) {
//   if (isEraserMode) {
//     eraseStrokeAtPoint(details.localPosition);
//   } else {
//     final supportsPressure = details.pressureMin < 1;
//     final localPosition = details.localPosition;
//     final point = PointVector(
//       localPosition.dx,
//       localPosition.dy,
//       supportsPressure ? details.pressure : null,
//     );
//
//     // Disable the start and end taper and cap when the stroke is in progress
//     options = options.copyWith(
//       // start: StrokeEndOptions.start(taperEnabled: false, cap: false),
//       // end: StrokeEndOptions.end(taperEnabled: false, cap: false),
//     );
//
//     if (line.value != null) {
//       // Use the same StrokeStyle when adding a point to the stroke
//       line.value = Stroke([...line.value!.points, point], options, line.value!.style);
//       pointCount++;
//
//       if (pointCount >= MAX_POINTS) {
//         // If the current stroke has reached the maximum points, start a new stroke from the last two points of the previous stroke
//         lines.value = [...lines.value, line.value!];
//         int startIndex = line.value!.points.length - ((currentStrokeStyle.size.round() * 3));
//         startIndex = startIndex >= 0 ? startIndex : 0; // Ensure the startIndex is not negative
//         line.value = Stroke([line.value!.points[startIndex], line.value!.points.last], options, currentStrokeStyle);        pointCount = 2; // Reset the count to 2 as the new stroke already has two points
//       }
//     } else {
//       // If no stroke is in progress, start a new stroke
//       line.value = Stroke([point], options, currentStrokeStyle);
//       pointCount = 1;
//     }
//   }
// }
// v6: split and reign
  Stroke joinStrokes(Stroke stroke1, Stroke stroke2) {
    // Get the last point of the first stroke
    PointVector lastPointOfStroke1 = stroke1.points.last;

    // Get the first point of the second stroke
    PointVector firstPointOfStroke2 = stroke2.points.first;

    // Create a new stroke that starts from the last point of the first stroke and ends at the first point of the second stroke
    Stroke newStroke = Stroke([lastPointOfStroke1, firstPointOfStroke2], stroke1.options, stroke1.style);

    return newStroke;
  }
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
        int startIndex = line.value!.points.length - ((currentStrokeStyle.size.round() * 3));
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

  // v2 dynamic cap
  // void onPointerUp(PointerUpEvent details) {
  //   if (line.value != null) {
  //     // Enable the end taper and cap when the stroke has ended
  //     options = options.copyWith(
  //       end: StrokeEndOptions.end(taperEnabled: true, cap: true),
  //     );
  //
  //
  //     lines.value = [...lines.value, line.value!];
  //     line.value = null;
  //   }
  // }
  //v3 circle makeing instead of do
  // void onPointerUp(PointerUpEvent details) {
  //   if (line.value != null) {
  //     // Enable the end taper and cap when the stroke has ended
  //     options = options.copyWith(
  //       end: StrokeEndOptions.end(taperEnabled: true, cap: true),
  //     );
  //
  //     // Add the current stroke to the list of strokes
  //     lines.value = [...lines.value, line.value!];
  //     line.value = null;
  //   }
  // }
 // v1
  void onPointerUp(PointerUpEvent details) {
    if (line.value != null) {
      lines.value = [...lines.value, line.value!];
      line.value = null;
      // buffer = []; // Clear the buffer
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
              painter: NotebookBackgroundPainter(backgroundType: BackgroundType.grid),
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

    if (stroke.points.length == 1) {
      // If the stroke only has one point, draw a circle
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