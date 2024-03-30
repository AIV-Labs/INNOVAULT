import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:innovault/Components/CustomPressueSensitiveWidgets/ToolsWidgets/ToolBarSettings/EraserSettings.dart';
import 'package:innovault/Components/CustomPressueSensitiveWidgets/toolbar_freehand.dart';
import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:provider/provider.dart';

import '../../Functions/Providers/pen_options_provider.dart';
import '../AppStructure/hero_routes.dart';
import 'ToolsWidgets/AIV_Draggable_FAB_V1.dart';
import 'ToolsWidgets/ToolBarSettings/PanSettings.dart';
import 'ToolsWidgets/ToolBarSettings/PenSettings.dart';
import 'ToolsWidgets/ToolBarSettings/PinSettings.dart';
import 'ToolsWidgets/ToolBarSettings/expanded_pin.dart';
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

  bool isFloatingToolbarVisible = false;
  late AnimationController floatingToolbarController;
  late Animation<Offset> slideAnimation;
  late Animation<double> opacityAnimation;

  GlobalKey mainFabKey = GlobalKey();
  PointerMode currentMode = PointerMode.none;



  final lines = ValueNotifier<List<Stroke>>([]);
  final line = ValueNotifier<Stroke?>(null);
  // pin logic
  List<Pin> pins = [];
  void handleTap(PointerDownEvent details) {
  if (currentMode == PointerMode.pin) {
    bool isOutsideExistingPins = true;
    for (Pin pin in pins) {
      double distanceToPinCenter = (details.localPosition - pin.position).distance;
      if (distanceToPinCenter <= pin.size ) { // Multiply the pin size by 10
        isOutsideExistingPins = false;
        break;
      }
    }
    if (isOutsideExistingPins) {
      setState(() {
        // Create a new pin and add it to the list
        pins.add(
            Pin(position: details.localPosition,
                shape: Provider.of<PinOptionsProvider>(context, listen: false).shape,
                size: Provider.of<PinOptionsProvider>(context, listen: false).size,
                color: Provider.of<PinOptionsProvider>(context, listen: false).color,
                history: [],
                id: UniqueKey().toString(),
                tooltip: 'Pin #: ${pins.length}'));
      });
    }
  }
}

// erasing functionality
  ValueNotifier<Offset> pointerPosition = ValueNotifier(Offset.zero);
  ValueNotifier<bool> isCursorVisible = ValueNotifier(false);
  // v1 object eraser : functioning on pointer down (pins and strokes)
  // void objectErase(Offset point) {
  //   lines.value = lines.value.where((stroke) {
  //     if (doesStrokeContainPoint(stroke, point)) {
  //       return false;
  //     }
  //
  //     // Check if the stroke is a dot and if it's within a certain distance of the eraser point
  //     if (stroke.points.length <= 8) {
  //       final dotPoint = stroke.points.first;
  //       final distance = sqrt(pow(dotPoint.x - point.dx, 2) + pow(dotPoint.y - point.dy, 2));
  //       if (distance <= stroke.style.size) {
  //         return false;
  //       }
  //     }
  //
  //     return true;
  //   }).toList();
  //
  //   // Add this block to remove pins with empty history
  //   setState(() {
  //     pins = pins.where((pin) {
  //       double distanceToPinCenter = (point - pin.position).distance;
  //       if (distanceToPinCenter <= pin.size) {
  //         if (pin.history.isEmpty) {
  //           return false;
  //         } else {
  //           // Show dialog to confirm deletion
  //           showDialog(
  //             context: context,
  //             builder: (BuildContext context) {
  //               return AlertDialog(
  //                 title: Text('Confirm Deletion'),
  //                 content: Text('This pin has a history. Are you sure you want to delete it?'),
  //                 actions: <Widget>[
  //                   TextButton(
  //                     child: Text('Cancel'),
  //                     onPressed: () {
  //                       Navigator.of(context).pop();
  //                     },
  //                   ),
  //                   TextButton(
  //                     child: Text('Delete'),
  //                     onPressed: () {
  //                       // Delete the pin
  //                       setState(() {
  //                         pins.remove(pin);
  //                       });
  //                       Navigator.of(context).pop();
  //                     },
  //                   ),
  //                 ],
  //               );
  //             },
  //           );
  //         }
  //       }
  //       return true;
  //     }).toList();
  //   });
  // }
  // v2
  void objectErase(Offset point) {
  double eraserSize = Provider.of<EraserOptionsProvider>(context, listen: false).size;

  lines.value = lines.value.where((stroke) {
    for (var strokePoint in stroke.points) {
      final distance = sqrt(pow(strokePoint.x - point.dx, 2) + pow(strokePoint.y - point.dy, 2));
      if (distance <= eraserSize/2) {
        return false;
      }
    }
    return true;
  }).toList();

  // Add this block to remove pins with empty history
  setState(() {
    pins = pins.where((pin) {
      double distanceToPinCenter = (point - pin.position).distance;
      if (distanceToPinCenter <= eraserSize) {
        if (pin.history.isEmpty) {
          return false;
        } else {
          // Show dialog to confirm deletion
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Confirm Deletion'),
                content: Text('This pin has a history. Are you sure you want to delete it?'),
                actions: <Widget>[
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text('Delete'),
                    onPressed: () {
                      // Delete the pin
                      setState(() {
                        pins.remove(pin);
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      }
      return true;
    }).toList();
  });
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

  // v1: point eraser no splitting
  // void pointErase(Offset point) {
  //   debugPrint('pointErasing point at $point');
  //   double eraserSize = Provider.of<EraserOptionsProvider>(context, listen: false).size;
  //
  //
  //   lines.value = lines.value.map((stroke) {
  //     // Remove points within the eraser circle
  //     stroke.points = stroke.points.where((strokePoint) {
  //       final distance = sqrt(pow(strokePoint.x - point.dx, 2) + pow(strokePoint.y - point.dy, 2));
  //       return distance > eraserSize/2;
  //     }).toList();
  //
  //     return stroke;
  //   }).toList();
  //
  //   // Remove pins within the eraser circle
  //   setState(() {
  //     pins = pins.where((pin) {
  //       final distanceToPinCenter = (point - pin.position).distance;
  //       return distanceToPinCenter > eraserSize;
  //     }).toList();
  //   });
  // }

  // v2: point eraser with splitting
    // Initialize an empty list of strokes.
    // Iterate over each stroke in lines.value.
    // For each stroke, initialize an empty list of points.
    // Iterate over each point in the stroke.
    // If the point is within the eraser's circle, add it to the list of points.
    // If the point is not within the eraser's circle and the list of points is not empty, create a new stroke with the list of points and add it to the list of strokes. Then, clear the list of points.
    // After iterating over all points in the stroke, if the list of points is not empty, create a new stroke with the list of points and add it to the list of strokes.
    // After iterating over all strokes in lines.value, update lines.value with the list of strokes.
  void pointErase(Offset point) {
  debugPrint('pointErasing point at $point');
  double eraserSize = Provider.of<EraserOptionsProvider>(context, listen: false).size;

  List<Stroke> newStrokes = [];

  for (Stroke stroke in lines.value) {
    List<dynamic> newPoints = []; // Change PointVector to dynamic

    for (var strokePoint in stroke.points) {
      if (strokePoint is PointVector) {
        final distance = sqrt(pow(strokePoint.x - point.dx, 2) + pow(strokePoint.y - point.dy, 2));

        if (distance > eraserSize/2) {
          newPoints.add(strokePoint);
        } else if (newPoints.isNotEmpty) {
          newStrokes.add(Stroke(newPoints, stroke.options, stroke.style, stroke.mode));
          newPoints = [];
        }
      } else if (strokePoint is Dot) {
        final distance = sqrt(pow(strokePoint.x - point.dx, 2) + pow(strokePoint.y - point.dy, 2));

        if (distance > eraserSize/2) {
          newPoints.add(strokePoint);
        }
      }
    }

    if (newPoints.isNotEmpty) {
      newStrokes.add(Stroke(newPoints, stroke.options, stroke.style, stroke.mode));
    }
  }

  lines.value = newStrokes;

  // Remove pins within the eraser circle
  setState(() {
    pins = pins.where((pin) {
      final distanceToPinCenter = (point - pin.position).distance;
      return distanceToPinCenter > eraserSize/2;
    }).toList();
  });
}


//

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
      default:
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
  void clearStrokes() {
    setState(() {
      lines.value = [];
      line.value = null;
      pointCount = 0;
    });
  }
  void clearPins() {
    setState(() {
      pins = [];
    });
  }


  void closeFloatingToolbar([bool animate = true]) {
    debugPrint('ACTIVATED CLOSING SETTINGS IN 450ms');

    if (animate) {
      floatingToolbarController.reverse();
// reverse the animation
      Future.delayed(const Duration(milliseconds: 450), () {
        setState(() {
          isFloatingToolbarVisible = false;
        });
      });
    }
    else {
      setState(() {
        isFloatingToolbarVisible = false;
        floatingToolbarController.reverse();
      });
    }
  }
  void openFloatingToolbar() {
    setState(() {
      isFloatingToolbarVisible = true;
      floatingToolbarController.forward();
    });
  }

  // #### pointer Logic ####
  void onPointerDown(PointerDownEvent details) {
    pointerPosition.value = details.localPosition;
    isCursorVisible.value = true;
    // eraser mode
    EraserMode currentEraserMode = Provider.of<EraserOptionsProvider>(context, listen: false).currentEraserMode;

    if (currentMode == PointerMode.eraser) {
      switch (currentEraserMode) {
        case EraserMode.objectEraser:
          objectErase(details.localPosition);
          break;
        case EraserMode.pointEraser:
          pointErase(details.localPosition);
          break;
        case EraserMode.transparency:
        // Handle transparency eraser mode
          break;
      }
    }


    final newStrokeStyle = Provider.of<PenOptionsProvider>(context, listen: false).currentStrokeStyle;
    // compare stroke options with provider's
    // pen mode
    if (currentMode == PointerMode.pen){
      final supportsPressure = details.kind == PointerDeviceKind.stylus;
      // TODO: with provider options = options.copyWith(simulatePressure: !supportsPressure);

      final localPosition = details.localPosition;
      final point = PointVector(
        localPosition.dx,
        localPosition.dy,
        supportsPressure ? details.pressure : null,
      );

      // Use the current color and size when creating a new stroke
      line.value = Stroke([point, point], Provider.of<PenOptionsProvider>(context, listen: false).strokeOptions, newStrokeStyle,currentMode);

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


  static const int MAX_POINTS = 750; // Define your own threshold here
  int pointCount = 0;

  void onPointerMove(PointerMoveEvent details) {
  pointerPosition.value = details.localPosition;
  // eraser mode
  EraserMode currentEraserMode = Provider.of<EraserOptionsProvider>(context, listen: false).currentEraserMode;
  if (currentMode == PointerMode.eraser) {
    switch (currentEraserMode) {
      case EraserMode.objectEraser:
        objectErase(details.localPosition);
        break;
      case EraserMode.pointEraser:
        pointErase(details.localPosition);
        break;
      case EraserMode.transparency:
      // Handle transparency eraser mode
        break;
    }
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
      // If the stroke has reached the maximum points, continue the existing stroke
      if (line.value!.points.length >= MAX_POINTS) {
        // Store the last point of the first stroke
        final lastPoint = line.value!.points.last;

        // Continue the existing stroke by adding the new point to it
        line.value = Stroke([...line.value!.points, point], Provider.of<PenOptionsProvider>(context, listen: false).strokeOptions, line.value!.style, currentMode);
      } else {
        // Otherwise, add the point to the current stroke
        line.value = Stroke([...line.value!.points, point], Provider.of<PenOptionsProvider>(context, listen: false).strokeOptions, line.value!.style, currentMode);
      }
    } else {
      // If no stroke is in progress, start a new stroke
      line.value = Stroke([point],
          Provider.of<PenOptionsProvider>(context, listen: false).strokeOptions,
          Provider.of<PenOptionsProvider>(context, listen: false).currentStrokeStyle,
          currentMode);
    }
  }
}


  void onPointerUp(PointerUpEvent details) {
    // toggle eraser cursor visibility off
    isCursorVisible.value = false;
    if (currentMode == PointerMode.eraser || currentMode == PointerMode.pen) {
      if (line.value != null) {
        if (line.value!.points.length <= 8) {
          final point = line.value!.points.first;
          final dot = Dot(point.x, point.y, Provider.of<PenOptionsProvider>(context, listen: false).strokeOptions.size / 1.5);
          lines.value = [
            ...lines.value,
            Stroke([dot], Provider.of<PenOptionsProvider>(context, listen: false).strokeOptions, Provider.of<PenOptionsProvider>(context, listen: false).currentStrokeStyle,currentMode)
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
    duration: const Duration(milliseconds: 350),
    vsync: this,
  );
  slideAnimation = Tween<Offset>(
    begin: const Offset(0, -0.1),
    end: const Offset(0, 0.01),
  ).animate(CurvedAnimation(
    parent: floatingToolbarController,
    curve: Curves.decelerate,
  ));
  opacityAnimation = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(floatingToolbarController);
//

}

  @override
  void dispose() {
    super.dispose();
    floatingToolbarController.dispose();
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
      body:
           Stack(
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
                 return Positioned.fromRect(
              rect: Rect.fromCenter(center: pin.position, width: pin.size, height: pin.size),
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
                      height: 600,  // Change as per your requirement
                      width: 600,
                      child: Hero(
                        tag: ValueKey(pin.id),
                        child: Material(
                          borderRadius: BorderRadius.circular(30),
                          child: ExpandedPin(pin: pin),  // Replace with your detailed view
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
                    message: 'Pin id: ${pin.id} tooltip: ${pin.tooltip}',
                    triggerMode: TooltipTriggerMode.tap,
                    child:
                    Container(
                      child: ShapeMaker(shapeType: pin.shape, color: pin.color)
                    ),
                  ),
                ),
              ),
            ),
          ),
              );
                  }),

// pointer position notifier
                      ValueListenableBuilder<bool>(
                        valueListenable: isCursorVisible,
                        builder: (context, isVisible, _) {
                          return ValueListenableBuilder<Offset>(
                            valueListenable: pointerPosition,
                            builder: (context, position, _) {
                              return Visibility(
                                visible: isVisible && (currentMode == PointerMode.eraser ),
                                child: CustomCursor(position: position),
                              );
                            },
                          );
                        },
                      )

                    ],
                  ),
                ),
              ),



              DraggableFab(
                  key: mainFabKey,
                  onModeChange: handleModeChange,
                  currentMode: currentMode,
                  toggleSettingsON: openFloatingToolbar,
                  toggleSettingsOFF: closeFloatingToolbar,
                  isSettingsVisible: isFloatingToolbarVisible),

               // gets the top-left position of the FAB

              ValueListenableBuilder(
              valueListenable: fabPositionNotifier,
              builder: (context, Offset fabPosition, _) {
              // Define the animation controller and animations

              return Positioned(
              left: fabPosition.dx -60, // change this as needed
              top: fabPosition.dy+ 160, // change this as needed
              child: SizedBox(
                height: 400,
                width: 300,
                child: Visibility(
                visible: isFloatingToolbarVisible,
                  // TODO: tofix reverse animation
                  child: FadeTransition(
                  opacity: opacityAnimation,
                  // child: AnimatedOpacity(
                  // opacity: isFloatingToolbarVisible ? 1.0 : 0.0,
                  // duration: const Duration(milliseconds: 350),
                  child: SlideTransition(
                  position: slideAnimation,
                  child:  Card(
                
                  child: Padding(padding:EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                      child: SingleChildScrollView(
                          child: PenSettingsLayoutBuilder(
                              currentMode: currentMode,
                              clearStrokes: clearStrokes,
                              clearPins: clearPins,
                            onModeChanged: handleModeChange,
                          )))
                  // Define the content and styling for your long-press menu here
                  ),
                  ),
                  ),
                ),
              ),
              );
              },
              )
            ],
          )

    );
  }
}

class PenSettingsLayoutBuilder extends StatelessWidget {
  final Function() clearStrokes;
  final Function() clearPins;
  final Function(PointerMode) onModeChanged;
  const PenSettingsLayoutBuilder({
    super.key,
    required this.currentMode,
    required this.clearStrokes,
    required this.clearPins,
    required this.onModeChanged,
  });

  final PointerMode currentMode;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
    builder: (context, constraints) {
      switch (currentMode){
        case PointerMode.pen:
          return const PenSettings();


            case PointerMode.eraser:
              return  EraserSettings(
                  initialMode: PointerMode.eraser,
                  clearAllStrokes: clearStrokes,
                  clearAllPins: clearPins,
                  onModeChanged: onModeChanged,);
            case PointerMode.pin:
              return  PinSettings();

            case PointerMode.none:
              return const PanSettings();
            default :
              return const Center(child: Text('No mode selected'));

      }
    }
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



class CustomCursor extends StatelessWidget {
  final Offset position;

  CustomCursor({required this.position});

  @override
  Widget build(BuildContext context) {
    // Get the eraser size from the provider
    double eraserSize = Provider.of<EraserOptionsProvider>(context, listen: false).size;

    return Positioned(
      left: position.dx - eraserSize / 2,
      top: position.dy - eraserSize / 2,
      child: Container(
        width: eraserSize,
        height: eraserSize,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// TODO: good painter for drawing maybe without using perfect freehand
// class StrokePainter extends CustomPainter {
//   final Stroke stroke;
//   final PointerMode strokeStyle;
//
//   StrokePainter({required this.stroke, required this.strokeStyle});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = stroke.style.color
//       ..style = PaintingStyle.stroke
//       ..strokeCap = StrokeCap.round
//       ..strokeJoin = StrokeJoin.round
//       ..strokeWidth = stroke.style.size;
//
//     if (stroke.points.isNotEmpty) {
//       for (var i = 0; i < stroke.points.length - 1; i++) {
//         final p1 = stroke.points[i];
//         final p2 = stroke.points[i + 1];
//         canvas.drawLine(Offset(p1.x, p1.y), Offset(p2.x, p2.y), paint);
//       }
//     }
//   }
//
//   @override
//   bool shouldRepaint(StrokePainter oldDelegate) => true;
// }