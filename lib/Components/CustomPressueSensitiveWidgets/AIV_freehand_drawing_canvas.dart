import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:innovault/Components/CustomPressueSensitiveWidgets/toolbar_freehand.dart';
import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import '../../Functions/Providers/pen_options_provider.dart';
import 'ToolsWidgets/AIV_Draggable_FAB_V1.dart';

import 'notebook_background_painter.dart';

// Assuming Toolbar is defined in the same file or imported
// todo: make sure the drawing doesn;t ever expand beyond the canvas
// if the line is still going the last stroke should end with a cap

class FreehandDrawingCanvas extends StatefulWidget {
  const FreehandDrawingCanvas({Key? key}) : super(key: key);

  @override
  _FreehandDrawingCanvasState createState() => _FreehandDrawingCanvasState();
}
class _FreehandDrawingCanvasState extends State<FreehandDrawingCanvas> {


  PointerMode currentMode = PointerMode.none;

  StrokeOptions options = StrokeOptions(
    size: 2,
    thinning: 0.7,
    smoothing: 0.6,
    streamline: 0.34,
    easing: (double t) => t/2,
    start: StrokeEndOptions.start(
      taperEnabled: false,
      cap: true,
      // customTaper: 2,
    ),
    end: StrokeEndOptions.end(
      taperEnabled: false,
      cap: true,
      // customTaper: 2,
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
      currentStrokeStyle = currentStrokeStyle.copyWith(color: newColor);
    });

  }
// erasing functionality


  void eraseStrokeAtPoint(Offset point) {
    lines.value = lines.value.where((stroke) {
      if (doesStrokeContainPoint(stroke, point)) {
        return false;
      }

      // Check if the stroke is a dot and if it's within a certain distance of the eraser point
      if (stroke.points.length <= 8) {
        final dotPoint = stroke.points.first;
        final distance = sqrt(pow(dotPoint.x - point.dx, 2) + pow(dotPoint.y - point.dy, 2));
        if (distance <= stroke.style.size) {
          return false;
        }
      }

      return true;
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


  // function to switch between modes
  void handleModeChange(PointerMode mode) {
    switch (mode) {
      case PointerMode.pen:
        setState(() {
         currentMode = PointerMode.pen;
        });
        break;
      case PointerMode.eraser:
        setState(() {
          currentMode = PointerMode.eraser;
        });
        break;
      // case PointerMode.brush:
      //   setState(() {
      //     currentMode = PointerMode.brush;
      //   });
      //   break;
      case PointerMode.none:
        setState(() {
          currentMode = PointerMode.none;
        });
        break;
      case PointerMode.pin:
        setState(() {
          currentMode = PointerMode.pin;
        });
        break;
    }
  }

  void clear() {
    lines.value = [];
    line.value = null;
    pointCount = 0;
  }

  void onPointerDown(PointerDownEvent details) {
    if (currentMode == PointerMode.eraser) {
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
      final newStrokeStyle = StrokeStyle(size: currentStrokeStyle.size, color: currentStrokeStyle.color);

      // Use the current color and size when creating a new stroke
      line.value = Stroke([point, point], options, newStrokeStyle);

      // Add this line to draw a circle at the tap location
      lines.value = [...lines.value, line.value!];
      line.value = null;
    }
  }
  void onPointerMove(PointerMoveEvent details) {
    if (currentMode == PointerMode.eraser) {
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
  static const int MAX_POINTS = 750; // Define your own threshold here
  int pointCount = 0;
  void onPointerUp(PointerUpEvent details) {
    if (line.value != null) {
      if (line.value!.points.length <= 8) {
        final point = line.value!.points.first;
        final dot = Dot(point.x, point.y, options.size/1.5);
        lines.value = [...lines.value, Stroke([dot], options, currentStrokeStyle)];
      } else {
        lines.value = [...lines.value, line.value!];
      }

      line.value = null;
      pointCount = 0;
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Listener(
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
                              painter: MultiStrokePainter(strokes: strokes),
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

                  // Positioned(
                  //   bottom: 0,
                  //   right: 0,
                  //   child: UserToolbar(
                  //     currentSize: currentStrokeStyle.size,
                  //     currentColor: _currentColor,
                  //     currentSensitivity: 0.7,
                  //     onSizeChange: updateStrokeSize,
                  //     onSensitivityChange: updateStrokeThinning,
                  //     onColorChange: updateStrokeColor,
                  //     clear: clear,
                  //     onToggleEraserMode: toggleEraserMode,
                  //     onTogglePartialEraserMode: toggleEraserMode,
                  //     onTogglePenMode: toggleEraserMode,
                  //   ),
                  // ),



                ],
              ),
            ),
          ),

          // DraggableFab(onModeChange: handleModeChange, currentMode: currentMode,),
        ],
      ),
    );
  }
}

class StrokePainter extends CustomPainter {
  final Stroke stroke;

  StrokePainter({required this.stroke});

  @override
  void paint(Canvas canvas, Size size) {
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

  @override
  bool shouldRepaint(StrokePainter oldDelegate) => true;
}

class MultiStrokePainter extends CustomPainter {
  final List<Stroke> strokes;

  MultiStrokePainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
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
  }

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

class Stroke {
  List<dynamic> points;
  final StrokeOptions options;
  final StrokeStyle style;

  Stroke(this.points, this.options, this.style);
}
class Dot {
  final double x;
  final double y;
  final double radius;

  Dot(this.x, this.y, this.radius);
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


