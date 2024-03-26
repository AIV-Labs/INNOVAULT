import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

import 'notebook_background_painter.dart';

// Define a class to hold stroke style options.
class StrokeStyle {
  double size;
  Color color; // Add color attribute

  StrokeStyle({required this.size, required this.color});
}


class FreehandDrawingCanvas extends StatefulWidget {
  const FreehandDrawingCanvas({Key? key}) : super(key: key);

  @override
  _FreehandDrawingCanvasState createState() => _FreehandDrawingCanvasState();
}

class _FreehandDrawingCanvasState extends State<FreehandDrawingCanvas> {
  late StrokeOptions options;
  double currentStrokeSize; // Track the current stroke size
  Color _currentColor = Colors.black; // Track the current color
  late StrokeStyle currentStrokeStyle;
  final lines = ValueNotifier<List<Stroke>>([]);
  final line = ValueNotifier<Stroke?>(null);
  _FreehandDrawingCanvasState() : currentStrokeSize = 2.0; // Default stroke size

  @override
  void initState() {
    super.initState();
    options = defaultStrokeOptions();
    currentStrokeStyle = StrokeStyle(size: 2.0, color: _currentColor);
  }

  StrokeOptions defaultStrokeOptions() {
    return StrokeOptions(
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
  }

  bool isEraserMode = false;
  bool isPartialEraserMode = false;
  bool isPenMode = true;

  void toggleEraserMode() {
    setState(() {
      isEraserMode = true;
      isPartialEraserMode = false;
      isPenMode = false;
    });
  }

  void togglePartialEraserMode() {
    setState(() {
      isPartialEraserMode = true;
      isEraserMode = false;
      isPenMode = false;
    });
  }
  void togglePenMode() {
    setState(() {
      isPenMode = true;
      isEraserMode = false;
      isPartialEraserMode = false;
    });
  }


  void clear() {
    lines.value = [];
    line.value = null;
  }

  void onPointerDown(PointerDownEvent details) {
    final localPosition = details.localPosition;

    if (!isEraserMode && !isPartialEraserMode) {
      final point = PointVector(localPosition.dx, localPosition.dy, 1.0);
      StrokeStyle newStrokeStyle = StrokeStyle(size: currentStrokeSize, color: _currentColor);
      Stroke newStroke = Stroke([point], options.copyWith(size: currentStrokeSize), newStrokeStyle);
      lines.value = [...lines.value, newStroke];
    }
  }



  void onPointerMove(PointerMoveEvent details) {
    final supportsPressure = details.pressureMin < 1;
    final localPosition = details.localPosition;



    if (isEraserMode || isPartialEraserMode) {
      List<Stroke> newStrokes = [];
      for (Stroke stroke in lines.value) {
        bool isIntersecting = false;
        List<PointVector> firstHalf = [];
        List<PointVector> secondHalf = [];
        for (var point in stroke.points) {
          if ((Offset(point.x, point.y) - localPosition).distance <= currentStrokeSize) {
            isIntersecting = true;
          } else {
            if (!isIntersecting) {
              firstHalf.add(point);
            } else {
              secondHalf.add(point);
            }
          }
        }
        if (firstHalf.isNotEmpty) {
          newStrokes.add(Stroke(firstHalf, stroke.options, stroke.style));
        }
        if (secondHalf.isNotEmpty) {
          newStrokes.add(Stroke(secondHalf, stroke.options, stroke.style));
        }
      }
      lines.value = newStrokes;}
    else {
      // Standard drawing logic
      if (lines.value.isNotEmpty) {
        final supportsPressure = details.pressureMin < 1;
        Stroke lastStroke = lines.value.last;
        final point = PointVector(
          localPosition.dx,
          localPosition.dy,
          supportsPressure ? details.pressure : null,
        );

        if (line.value != null) {
          line.value = Stroke([...line.value!.points, point], lastStroke.options, lastStroke.style);
        }
      }

      }

  }


  void onPointerUp(PointerUpEvent details) {
    if (!isEraserMode && !isPartialEraserMode) {
      // Finalize the current stroke
      line.value = null;
    }
    // No specific action needed for eraser modes on pointer up
  }


  void updateStrokeSize(double size) {
    setState(() {
      currentStrokeSize = size; // Only update the current stroke size
    });
  }
  void updateStrokeColor(Color color) {
    setState(() {
      _currentColor = color; // Only update the current color
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
                    return CustomPaint(
                      painter: MultiStrokePainter(strokes: strokes),
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
                  return CustomPaint(
                    painter: currentStroke != null ? StrokePainter(stroke: currentStroke) : null,
                  );
                },
              ),
            ),
            // UserToolbar for stroke size adjustment
            Positioned(
              bottom: 0,
              right: 0,
              child: UserToolbar(
                currentSize: currentStrokeStyle.size,
                currentColor: _currentColor,
                onSizeChange: updateStrokeSize,
                onColorChange: updateStrokeColor,
                clear: clear,
                onToggleEraserMode: toggleEraserMode,
                onTogglePartialEraserMode: togglePartialEraserMode,
                onTogglePenMode: togglePenMode,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// UserToolbar with a functioning slider for stroke size adjustment
// UserToolbar with a functioning slider for stroke size and additional eraser buttons
class UserToolbar extends StatefulWidget {
  final double currentSize;
  final Color currentColor;
  final Function(double) onSizeChange;
  final Function(Color) onColorChange;
  final VoidCallback clear;
  final VoidCallback onToggleEraserMode; // Callback for toggling eraser mode
  final VoidCallback onTogglePartialEraserMode; // Callback for toggling partial eraser mode
  final VoidCallback onTogglePenMode; // Callback for toggling pen mode

  const UserToolbar({
    Key? key,
    required this.currentSize,
    required this.currentColor,
    required this.onSizeChange,
    required this.onColorChange,
    required this.clear,
    required this.onToggleEraserMode,
    required this.onTogglePartialEraserMode,
    required this.onTogglePenMode,
  }) : super(key: key);

  @override
  State<UserToolbar> createState() => _UserToolbarState();
}

class _UserToolbarState extends State<UserToolbar> {
  late double _currentSize;
  late Color _currentColor;

  @override
  void initState() {
    super.initState();
    _currentSize = widget.currentSize;
    _currentColor = widget.currentColor;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Row(
            children: [
              Text('Size:'),
              Slider(
                min: 1.0,
                max: 10.0,
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



// Include StrokeStyle in the Stroke class
class StrokePainter extends CustomPainter {
  final Stroke stroke;

  StrokePainter({required this.stroke});

  @override
  void paint(Canvas canvas, Size size) {
    // Use the stroke's own style
    final paint = _getPaint(stroke.style);
    final path = generatePath(stroke.points, stroke.options);
    canvas.drawPath(path, paint);
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
      // Use each stroke's individual style
      final paint = _getPaint(stroke.style);
      final path = generatePath(stroke.points, stroke.options);
      canvas.drawPath(path, paint);
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
  for (final point in data.skip(1)) {
    path.lineTo(point.dx, point.dy);
  }
  return path;
}

class Stroke {
  List<PointVector> points;
  late final StrokeOptions options;
  late final StrokeStyle style;

  Stroke(this.points, this.options, this.style);
}

