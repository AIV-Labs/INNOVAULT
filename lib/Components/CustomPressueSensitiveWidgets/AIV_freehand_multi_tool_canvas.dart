import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:innovault/Components/CustomPressueSensitiveWidgets/toolbar_freehand.dart';
import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

import '../AppStructure/hero_routes.dart';
import 'ToolsWidgets/AIV_Draggable_FAB_V1.dart';
import 'notebook_background_painter.dart';
// Assuming Toolbar is defined in the same file or imported
// todo: make sure the drawing doesn;t ever expand beyond the canvas
// if the line is still going the last stroke should end with a cap


class FreehandMultiDrawingCanvas extends StatefulWidget  {
  const FreehandMultiDrawingCanvas({Key? key}) : super(key: key);

  @override
  _FreehandMultiDrawingCanvasState createState() => _FreehandMultiDrawingCanvasState();
}
class _FreehandMultiDrawingCanvasState extends State<FreehandMultiDrawingCanvas> with TickerProviderStateMixin{

  bool isfloatingToolbarVisible = false;
  late AnimationController floatingToolbarController;
  late Animation<Offset> slideAnimation;

  GlobalKey mainFabKey = GlobalKey();
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
  // pin logic
  List<Pin> pins = [];
  void handleTap(PointerDownEvent details) {
    if (currentMode == PointerMode.pin) {
      setState(() {
        // Create a new pin and add it to the list
        pins.add(Pin(position: details.localPosition, id: UniqueKey().toString(), tooltip: 'Pin #: ${pins.length}'));
      });
    }
  }


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
        break;
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

    setState(() {
      lines.value = [];
      line.value = null;
      pins = [];
      pointCount = 0;
    });
  }


  void closeFloatingToolbar() {
    setState(() {
      isfloatingToolbarVisible = false;
      floatingToolbarController.reverse();
    });
  }
  void openFloatingToolbar() {
    setState(() {
      isfloatingToolbarVisible = true;
      floatingToolbarController.forward();
    });
  }

  void onPointerDown(PointerDownEvent details) {
    if (currentMode == PointerMode.eraser) {
      eraseStrokeAtPoint(details.localPosition);
    }

    // Create a new StrokeStyle for the new stroke
    final newStrokeStyle = StrokeStyle(size: currentStrokeStyle.size, color: currentStrokeStyle.color);

    // pen mode
    if (currentMode == PointerMode.pen){
      final supportsPressure = details.kind == PointerDeviceKind.stylus;
      options = options.copyWith(simulatePressure: !supportsPressure);

      final localPosition = details.localPosition;
      final point = PointVector(
        localPosition.dx,
        localPosition.dy,
        supportsPressure ? details.pressure : null,
      );

      // Use the current color and size when creating a new stroke
      line.value = Stroke([point, point], options, newStrokeStyle,currentMode);

      // Add this line to draw a circle at the tap location
      lines.value = [...lines.value, line.value!];
      line.value = null;
    }

    // brush mode
    // if (currentMode == PointerMode.brush){
    //   final point = _createBrushPoint(details);
    //
    //   line.value = Stroke([point], options, currentStrokeStyle,currentMode);
    // }

    // pin mode
    if (currentMode == PointerMode.pin) {
      handleTap(details);
    }

  }
  void onPointerMove(PointerMoveEvent details) {
    if (currentMode == PointerMode.eraser) {
      eraseStrokeAtPoint(details.localPosition);
    }
    // pen mode
    if (currentMode == PointerMode.pen){
      final supportsPressure = details.pressureMin < 1;
      final localPosition = details.localPosition;
      final point = PointVector(
        localPosition.dx,
        localPosition.dy,
        supportsPressure ? details.pressure : null,
      );

      if (line.value != null) {
        // Use the same StrokeStyle when adding a point to the stroke
        line.value = Stroke([...line.value!.points, point], options, line.value!.style, currentMode);
        pointCount++;

        if (pointCount >= MAX_POINTS) {
          // If the current stroke has reached the maximum points, start a new stroke from the last two points of the previous stroke
          lines.value = [...lines.value, line.value!];
          int startIndex = line.value!.points.length - (currentStrokeStyle.size.round()*2.5).toInt();
          startIndex = startIndex >= 0 ? startIndex : 0; // Ensure the startIndex is not negative
          line.value = Stroke([line.value!.points[startIndex], line.value!.points.last], options, currentStrokeStyle, currentMode);
          pointCount = 2; // Reset the count to 2 as the new stroke already has two points
        }
      } else {
        // If no stroke is in progress, start a new stroke
        line.value = Stroke([point], options, currentStrokeStyle, currentMode);
        pointCount = 1;
      }
    }

    // brush mode
    // if (currentMode == PointerMode.brush) {
    //   final point = _createBrushPoint(details);
    //   if (line.value != null) {
    //     var updatedPoints = List<PointVector>.from(line.value!.points)..add(point);
    //     line.value = Stroke(updatedPoints, options, currentStrokeStyle, currentMode);
    //     // Notify listeners to trigger a repaint.
    //     line.notifyListeners();
    //   }
    // }
  }
  static const int MAX_POINTS = 750; // Define your own threshold here
  int pointCount = 0;

  void onPointerUp(PointerUpEvent details) {
    if (currentMode == PointerMode.eraser || currentMode == PointerMode.pen) {
      if (line.value != null) {
        if (line.value!.points.length <= 8) {
          final point = line.value!.points.first;
          final dot = Dot(point.x, point.y, options.size / 1.5);
          lines.value = [
            ...lines.value,
            Stroke([dot], options, currentStrokeStyle,currentMode)
          ];
        } else {
          lines.value = [...lines.value, line.value!];
        }

        line.value = null;
        pointCount = 0;
      }
    }
    // brush mode
    // if (currentMode == PointerMode.brush){
    //   if (line.value != null) {
    //     lines.value = [...lines.value, line.value!];
    //     line.value = null;
    //   }
    // }
  }


  PointVector _createBrushPoint(PointerEvent details) {
    final supportsPressure = details.kind == PointerDeviceKind.stylus;
    return PointVector(
      details.localPosition.dx,
      details.localPosition.dy,
      supportsPressure ? details.pressure : null,
    );
  }


@override
initState() {
  super.initState();
  floatingToolbarController = AnimationController(
    duration: const Duration(milliseconds: 150),
    vsync: this,
  );
  slideAnimation = Tween<Offset>(
    begin: const Offset(0, -0.1),
    end: const Offset(0, 0.01),
  ).animate(CurvedAnimation(
    parent: floatingToolbarController,
    curve: Curves.decelerate,
  ));


}
  ValueNotifier<Offset> fabPositionNotifier = ValueNotifier(Offset.zero);
  @override
  Widget build(BuildContext context) {

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mainFabKey.currentContext != null) {
        final RenderBox fabRenderBox = mainFabKey.currentContext!.findRenderObject() as RenderBox;
        final Offset fabPosition = fabRenderBox.localToGlobal(Offset.zero);
        fabPositionNotifier.value = fabPosition;
      }
    });
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

                            painter: currentStroke != null ? StrokePainter(stroke: currentStroke,strokeStyle: currentMode) : null,
                          ),
                        );
                      },
                    ),
                  ),

          ...pins.map((pin) {
             return Positioned(
    left: pin.position.dx,
      top: pin.position.dy,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) {
          debugPrint('Pin entered pin id: ${pin.id} location: ${pin.position}');
        },
        onExit: (_) {
          debugPrint('Pin exited pin id: ${pin.id} location: ${pin.position}');
        },
        child: GestureDetector(
          onLongPress: () {
            debugPrint('Long pressed pin id: ${pin.id} location: ${pin.position}');
            debugPrint('number of pins: ${pins.length}, pins are not unique ${pins.map((pin) => pin.id)}');
            Navigator.of(context).push(HeroDialogRoute(
              builder: (context) => Center(
                child: SizedBox(
                  height: 200,  // Change as per your requirement
                  width: 200,
                  child: Hero(
                    tag: ValueKey(pin.id),
                    child: Material(
                      borderRadius: BorderRadius.circular(30),
                      child: Placeholder(),  // Replace with your detailed view
                    ),
                  ),
                ),
              ),
            ));
          },
          child: Hero(
            tag: ValueKey(pin.id),
            child: Material(
              borderRadius: BorderRadius.circular(10),
              color: Colors.transparent,
              child: Tooltip(
                message: 'Pin id: ${pin.id} metadata: ${pin.metadata}',
                triggerMode: TooltipTriggerMode.tap,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,  // Or BoxShape.rectangle for squares, etc.
                    color: Colors.red,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
              }),



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

          DraggableFab(key: mainFabKey, onModeChange: handleModeChange, currentMode: currentMode, toggleSettingsON: openFloatingToolbar, toggleSettingsOFF: closeFloatingToolbar, isSettingsVisible: isfloatingToolbarVisible),

     // gets the top-left position of the FAB

    ValueListenableBuilder(
    valueListenable: fabPositionNotifier,
    builder: (context, Offset fabPosition, _) {
    // Define the animation controller and animations

    return Positioned(
    left: fabPosition.dx -60, // change this as needed
    top: fabPosition.dy+ 160, // change this as needed
    child: AnimatedOpacity(
    opacity: isfloatingToolbarVisible ? 1.0 : 0.0,
    duration: const Duration(milliseconds: 150),
    child: SlideTransition(
    position: slideAnimation,
    child: Container(
    height: 200,
    width: 200,
    color: Colors.black,
    // Define the content and styling for your long-press menu here
    ),
    ),
    ),
    );
    },
    )
        ],
      ),
    );
  }
}

class StrokePainter extends CustomPainter {
  final Stroke stroke;
  final PointerMode strokeStyle;
  StrokePainter({required this.stroke, required this.strokeStyle});

  @override
  void paint(Canvas canvas, Size size) {
    if (strokeStyle == PointerMode.pen){
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
    // brush
    // if (strokeStyle == PointerMode.brush) {
    //   final paint = Paint()
    //     ..color = stroke.style.color
    //     ..style = PaintingStyle.stroke
    //     ..strokeCap = StrokeCap.round
    //     ..strokeJoin = StrokeJoin.round
    //     ..strokeWidth = stroke.style.size; // Adjust for brush size
    //
    //   Path path = Path();
    //   if (stroke.points.isNotEmpty) {
    //     path.moveTo(stroke.points.first.dx, stroke.points.first.dy);
    //     for (var i = 1; i < stroke.points.length; i++) {
    //       path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
    //     }
    //     canvas.drawPath(path, paint);
    //   }
    // }
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
      // pen mode
      if (stroke.mode == PointerMode.pen){
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
    // brush
    //   if (stroke.mode == PointerMode.brush) {
    //     PointVector? previousPoint;
    //     for (final point in stroke.points.whereType<PointVector>()) {
    //       // Calculate the "speed" based on the distance between points
    //       double speed = previousPoint != null ?
    //       sqrt(pow(point.x - previousPoint.x, 2) + pow(point.y - previousPoint.y, 2)) : 0;
    //
    //       // Adjust the radius based on the speed
    //       double radius = stroke.style.size * (1 - min(speed / 10, 1));
    //
    //       // Ensure the radius does not get too small or inversely grow too large
    //       radius = max(min(radius, stroke.style.size * 2), stroke.style.size * 0.5);
    //
    //       final paint = Paint()
    //         ..shader = RadialGradient(
    //           colors: [stroke.style.color, stroke.style.color.withOpacity(0)],
    //           stops: [0.3, 1.0],  // Adjust the stops for a more pronounced gradient
    //         ).createShader(Rect.fromCircle(center: Offset(point.x, point.y), radius: radius))
    //         ..style = PaintingStyle.fill;
    //
    //       // Draw the circle at each point with the gradient effect
    //       canvas.drawCircle(Offset(point.x, point.y), radius, paint);
    //
    //       previousPoint = point;
    //     }
    //   }
  }}

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
  final PointerMode mode;
  Stroke(this.points, this.options, this.style,  this.mode);
}
class Dot {
  final double x;
  final double y;
  final double radius;

  Dot(this.x, this.y, this.radius);
}

class Pin {
  final Offset position;
  final String id;
  final dynamic metadata; // Can be used to store additional information
  final String tooltip;

  Pin({required this.position, required this.id, this.metadata, this.tooltip = ''});
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

  StrokeStyle copyWith({double? size, Color? color}) {
    return StrokeStyle(
      size: size ?? this.size,
      color: color ?? this.color,
    );
  }
}


class CustomTooltip extends StatelessWidget {
  final String message;
  final Offset position;

  const CustomTooltip({
    Key? key,
    required this.message,
    required this.position,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          message,
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }
}
