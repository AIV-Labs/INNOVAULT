import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:innovault/Components/CustomPressueSensitiveWidgets/ToolsWidgets/ToolBarSettings/EraserSettings.dart';

import 'package:flutter/material.dart';
import 'package:innovault/constants.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:provider/provider.dart';

import '../../../Functions/Providers/pen_options_provider.dart';
import '../../AppStructure/hero_routes.dart';
import '../ToolsWidgets/AIV_Draggable_FAB_V1.dart';
import '../ToolsWidgets/ToolBarSettings/PanSettings.dart';
import '../ToolsWidgets/ToolBarSettings/PenSettings.dart';
import '../ToolsWidgets/ToolBarSettings/PinSettings.dart';
import '../ToolsWidgets/ToolBarSettings/TextBoxSettings.dart';
import '../ToolsWidgets/ToolBarSettings/expanded_pin.dart';

import 'package:flutter_quill/flutter_quill.dart' as quill;

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

  // Text boxes
  List<DraggableTextBox> draggableTextBoxes = [];
  ValueNotifier<bool> isDraggingTextBox = ValueNotifier<bool>(false);
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

// Define the maximum number of empty boxes
  static const int MAX_EMPTY_BOXES = 10;
  void createTextBox(Offset position) {

    // making sure you can't add inifinite amount of empty textboxes
    // Get the TextBoxProvider
    var textBoxProvider = Provider.of<TextBoxProvider>(context, listen: false);

    // Check if the maximum limit of empty boxes has been reached
    int emptyBoxCount = textBoxProvider.textBoxes.where((box) => box.controller.document.isEmpty()).length;
    if (emptyBoxCount >= MAX_EMPTY_BOXES) {

      // show alert to user that they can't add more empty textboxes
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Maximum Limit Reached'),
            content: Text('You have reached the maximum limit of empty text boxes.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    TextBox newTextBox = TextBox(
      id: UniqueKey().toString(),
      position: position,
      controller: quill.QuillController.basic(),
      creator: 'User',
      lastEditor: 'User',
      activeUsers: ['User'],
      creationDate: DateTime.now(),
      lastUpdateDate: DateTime.now(),
    );

    Provider.of<TextBoxProvider>(context, listen: false).addTextBox(newTextBox);
    // Create a new GlobalKey for each DraggableTextBox widget
    final GlobalKey key = GlobalKey(debugLabel: newTextBox.id);
    setState(() {
      draggableTextBoxes.add(
        DraggableTextBox(
          key : key,
          id: newTextBox.id,
          canvasKey: canvasKey,
          textBox: newTextBox,
          activeQuillController: activeQuillController,
          onRemove: removeTextBox, isDraggingTextBox: isDraggingTextBox,
        ),
      );
    });
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
      case PointerMode.textBox:
        setState(() {
          currentMode = PointerMode.textBox;
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
  void clearTextBoxes() {
    setState(() {
      draggableTextBoxes = [];
    });
    // clear the provider
    Provider.of<TextBoxProvider>(context, listen: false).clearTextBoxes();
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
    if (isDraggingTextBox.value) {
      // delete the current line
      line.value = null;
      return;
    }
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
    // TextBox mode
      // Get the RenderBox of the FreehandMultiDrawingCanvas widget
      final RenderBox renderBox = context.findRenderObject() as RenderBox;

      // Convert the global position to the local position
      final localPosition = renderBox.globalToLocal(details.position);

    // TextBox mode
    if (currentMode == PointerMode.textBox) {
      bool isInsideExistingTextBox = false;

      for (var textBox in draggableTextBoxes) {
        final RenderBox renderBox = textBox.containerKey.currentContext!.findRenderObject() as RenderBox;
        final textBoxSize = renderBox.size;
        final textBoxPosition = renderBox.localToGlobal(Offset.zero);

        if (details.position.dx >= textBoxPosition.dx &&
            details.position.dx <= textBoxPosition.dx + textBoxSize.width &&
            details.position.dy >= textBoxPosition.dy &&
            details.position.dy <= textBoxPosition.dy + textBoxSize.height) {
          isInsideExistingTextBox = true;
          break;
        }
      }

      if (!isInsideExistingTextBox) {
        createTextBox(details.localPosition);
      }
    }

  }


  static const int MAX_POINTS = 750; // Define your own threshold here
  int pointCount = 0;

  void onPointerMove(PointerMoveEvent details) {
    if (isDraggingTextBox.value) {
      // delete the current line
      line.value = null;
      return;
    }
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
    if (isDraggingTextBox.value) {
      // delete the current line
      line.value = null;
      return;
    }
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

  draggableTextBoxes = Provider.of<TextBoxProvider>(context, listen: false)
      .textBoxes
      .map((e) {
    GlobalKey key = GlobalKey();
    return DraggableTextBox(
      key: key,
      id: e.id,
      canvasKey: canvasKey,
      textBox: e,
      activeQuillController: activeQuillController,
      isDraggingTextBox: isDraggingTextBox,
      onRemove: removeTextBox,
    );
  }).toList();
}

void removeTextBox(String id) {
  setState(() {
    // Remove the text box from the list
    draggableTextBoxes.removeWhere((element) => element.id == id);
    // Remove the text box from the provider
    Provider.of<TextBoxProvider>(context, listen: false).removeTextBox(id);
  });
}

  // Canvas  GlobalKey
  final canvasKey = GlobalKey();
  ValueNotifier<Offset> fabPositionNotifier = ValueNotifier(Offset.zero);
  ValueNotifier<quill.QuillController?> activeQuillController = ValueNotifier(quill.QuillController.basic());

  BackgroundType_OLD backgroundType = BackgroundType_OLD.grid;

  void updateBackgroundType(BackgroundType_OLD type) {
    debugPrint('updateBackgroundType called with type: $type');
    setState(() {
      backgroundType = type;
    });
  }


  @override
  void dispose() {
    super.dispose();
    floatingToolbarController.dispose();
  }

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
             key: canvasKey,
            children: [
              Positioned.fill(
                child: Listener(
                  onPointerDown: onPointerDown,
                  onPointerMove: onPointerMove,
                  onPointerUp: onPointerUp,
                  child: GestureDetector(
                    // for unfocusing textboxes
                    onTap: () {
                    //   setState(() {
                    //     for (var element in draggableTextBoxes) {
                    //       element.currentState!.focusNode.unfocus();
                    //   }
                    //
                    // });
                      // FocusScope.of(context).unfocus();
                      },
                    child: Stack(
                      children: [

                        CustomPaint(
                          size: Size.infinite,
                          painter: NotebookBackgroundPainter(backgroundType: backgroundType),
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

                        // TextBoxes
                        ...draggableTextBoxes,

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
                              activeQuillController: activeQuillController,
                              clearStrokes: clearStrokes,
                              clearPins: clearPins,
                              clearTextBoxes: clearTextBoxes,
                            onModeChanged: handleModeChange, backgroundType: backgroundType,updateBackgroundType: updateBackgroundType,
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
  final Function() clearTextBoxes;
  final Function(PointerMode) onModeChanged;
  final ValueListenable<QuillController?>  activeQuillController;

  //pan settings
  final BackgroundType_OLD backgroundType;
  final Function(BackgroundType_OLD) updateBackgroundType;
  const PenSettingsLayoutBuilder({
    super.key,
    required this.activeQuillController,
    required this.currentMode,
    required this.clearStrokes,
    required this.clearPins,
    required this.onModeChanged,
    required this.clearTextBoxes,
    required this.backgroundType,
    required this.updateBackgroundType,
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
                  clearAllTextBoxes: clearTextBoxes,
                  onModeChanged: onModeChanged,);
        case PointerMode.pin:
            return  PinSettings();
            case PointerMode.none:
              // return  PanSettings( backgroundType: backgroundType, updateBackgroundType: updateBackgroundType);

              case PointerMode.textBox:
              return  TextBoxSettings(quillController:activeQuillController);

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

class DraggableTextBox extends StatefulWidget {
  String id;
   GlobalKey canvasKey;
   GlobalKey key;
   GlobalKey containerKey = GlobalKey();
   TextBox textBox;
   Function onRemove;
   // activeQuillController
   ValueNotifier<quill.QuillController?> activeQuillController;
  ValueNotifier<bool> isDraggingTextBox;
  DraggableTextBox({ required this.id, required this.key, required this.canvasKey, required this.textBox, required this.activeQuillController, required this.onRemove, required this.isDraggingTextBox});


  @override
  _DraggableTextBoxState createState() => _DraggableTextBoxState(key, containerKey); // Pass the new GlobalKey to the state



}



class _DraggableTextBoxState extends State<DraggableTextBox> {
  Offset position = Offset.zero;
  // quill.QuillController _controller = quill.QuillController.basic();
  GlobalKey key;
  GlobalKey containerKey; // Define a new GlobalKey for the Container
  final FocusNode _focusNode = FocusNode();
  FocusScopeNode _focusScopeNode = FocusScopeNode();
  bool _isDragging = false;


  _DraggableTextBoxState(this.key, this.containerKey);

  void _showMenu(BuildContext context, Offset tapPosition) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(
          tapPosition,
          tapPosition,
        ),
        Offset.zero & overlay.size,
      ),
      constraints: BoxConstraints(
        minWidth: 100,
        maxWidth: 200,
      ),
      items: <PopupMenuEntry>[
        PopupMenuItem(
          child: TextButton(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(CupertinoIcons.info, size: 18,),
                const SizedBox(width: 10),
                Text('Info'),
              ],
            ),
            onPressed: () {
              Navigator.pop(context);
              _showInfoDialog();
            },
          ),
        ),
        PopupMenuItem(
          child: TextButton(
            child: Row(
              children: [
                Icon(Icons.delete,  color: Colors.redAccent, size: 18),
                const SizedBox(width: 10),
                Text('Delete'),
              ],
            ),
            onPressed: () {
              Navigator.pop(context);
              _showDeleteConfirmationDialog();
            },
          ),
        ),
      ],
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Info'),
          content:
              SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ID: ${widget.textBox.id}'),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(child: Text('Creator: ${widget.textBox.creator}', overflow: TextOverflow.ellipsis,)),
                        Flexible(child: Text('${widget.textBox.creationDate}')),
                      ],
                    ),

                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(child: Text('Last Editor: ${widget.textBox.lastEditor}', overflow: TextOverflow.ellipsis,)),
                        Flexible(child: Text('${widget.textBox.lastUpdateDate}'),),
                      ],
                    ),

                    const SizedBox(height: 10),
                    // color piker + always visible checkbox
                    Flexible(child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(

                          height: 100,
                          width: 300,
                          padding: EdgeInsets.all(10),
                          child: BannerColorPicker(id: widget.textBox.id,),),
                        const SizedBox(width: 10),
                        // always visible checkbox
                        Row(
                          children: [
                            const Text('Banner Always Visible'),
          Consumer<TextBoxProvider>(
            builder: (context, textBoxProvider, child) {
              return Checkbox(
                value: widget.textBox.bannerVisible,
                onChanged: (bool? value) {
                  textBoxProvider.updateBannerVisibility(widget.textBox.id, value!);
                  setState(() {
                    widget.textBox.bannerVisible = value;
                  });
                },
              );
            },
          )
                                                ],
                                              )
                  ],
                ),),]),
              ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this text box?'),
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
                widget.onRemove(widget.textBox.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    position = widget.textBox.position;
    _focusScopeNode = FocusScopeNode();
    _focusNode.requestFocus();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        widget.activeQuillController.value = widget.textBox.controller;
      }
    });

    // _focusScopeNode.addListener(_handleScopeFocusChange);

  }
  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      widget.activeQuillController.value = widget.textBox.controller;
    }
    // Trigger a rebuild whenever focus changes
    setState(() {});
  }
  // void _handleScopeFocusChange() {
  //   if (_focusScopeNode.hasFocus) {
  //     print('Focus gained');
  //   } else {
  //     print('Focus lost');
  //   }
  //   // Trigger a rebuild whenever focus changes
  //   setState(() {});
  // }
  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusScopeNode.dispose();
    super.dispose();
  }
  ValueNotifier<bool> isBorderVisible = ValueNotifier<bool>(true);
  @override
  Widget build(BuildContext context) {
  return Positioned(
    left: position.dx,
    top: position.dy,
    child: GestureDetector(
      onTap: () {
        // setState(() {
        //   _focusNode.requestFocus();
        // });
        // Request focus for the current text box
        _focusScopeNode.requestFocus(_focusNode);
        debugPrint('tapped on text box with content:'
            ' ${widget.textBox.controller.document.toPlainText()} '
            'and focus node has focus: ${_focusNode.hasFocus}'
            'and focus scope node has focus: ${_focusScopeNode.hasFocus}');
      },
      child: SizedBox(
       width: widget.textBox.size.width,
        height: widget.textBox.size.height,
        child: Stack(
          children: [

          // Rich Text Editor
            Positioned.fill(
              child: FocusScope(
                node: _focusScopeNode,
                child: Container(
                  key: containerKey,
                  decoration: BoxDecoration(
                   //all borders but top
                    border:  Border(
                      bottom: BorderSide(
                        // check if document s empty
                        color: _focusScopeNode.hasFocus || widget.textBox.controller.document.isEmpty() ? Colors.black : Colors.transparent,

                      ),
                      left: BorderSide(
                        color: _focusScopeNode.hasFocus || widget.textBox.controller.document.isEmpty() ? Colors.black : Colors.transparent,

                      ),
                      right: BorderSide(
                        color: _focusScopeNode.hasFocus || widget.textBox.controller.document.isEmpty() ? Colors.black : Colors.transparent,

                      ),
                    ),
                    borderRadius: BorderRadius.circular(5),),

                  padding: const EdgeInsets.fromLTRB(8, 30, 8, 8),
                  child: Column(
                    children: [
                      // quill Text Box
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          quill.QuillEditor.basic(
                            focusNode: _focusNode,
                            configurations: quill.QuillEditorConfigurations(
                              controller: widget.textBox.controller,
                              autoFocus: false,
                              // readOnly: false,
                              sharedConfigurations: const quill.QuillSharedConfigurations(
                                locale: Locale('en'),
                              ),
                            ),
                          ),
                        ],
                      ),



                    ],
                  ),
                ),
              ),
            ),
            // drag and option bar
            Positioned.fromRect(
              rect: Rect.fromLTWH(0, 0, widget.textBox.size.width, 20),
              child:  Visibility(
                visible: widget.textBox.bannerVisible? true :_focusScopeNode.hasFocus || widget.textBox.controller.document.isEmpty(),
                child: GestureDetector(
                    onPanUpdate: (details) {
                      // consider using localPosition instead of details.delta
                      // final RenderBox renderBox = widget.canvasKey.currentContext!.findRenderObject() as RenderBox;
                      // final localPosition = renderBox.globalToLocal(details.offset);
                      widget.isDraggingTextBox.value = true;
                      setState(() {
                        position += details.delta;
                      });
                    },
                    onPanEnd: (details) {
                      widget.isDraggingTextBox.value = false;
                    },
                    onLongPressEnd: (details) {
                      _focusScopeNode.requestFocus(_focusNode);
                      _showMenu(context, details.globalPosition);
                    },


                    child: Container(
                      decoration:  BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5),
                        ),
                        // color: Color(0xFFEBEBEB),
                        color: widget.textBox.bannerColor,
                      ),
                      height: 20,
                      width: double.infinity,
                    )),
              ),),
            // resize handle
            Positioned(
              bottom: 2,
              right: 2,
              child: Visibility(
                visible: _focusScopeNode.hasFocus || widget.textBox.controller.document.isEmpty(),
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      // Update the size of the widget
                      // minimum of 200x200
                      widget.isDraggingTextBox.value = true;
                      Provider.of<TextBoxProvider>(context, listen: false).
                      updateBoxSize(widget.textBox.id,
                          Size(
                            max(200, widget.textBox.size.width + details.delta.dx),
                            max(200, widget.textBox.size.height + details.delta.dy),
                          ));
                    });
                  },
                  onPanEnd: (details) {
                    widget.isDraggingTextBox.value = false;
                  },
                  child: Icon(Icons.zoom_out_map, size: 20,), // Replace with your resize handle widget
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}


class BannerColorPicker extends StatelessWidget {
  final List<Color> defaultColors = defaultColorsList;
  final String id;
  BannerColorPicker({required this.id});

  @override
  Widget build(BuildContext context) {
    return Consumer<TextBoxProvider>(
      builder: (context, textBoxProvider, child) {
        final textbox = Provider.of<TextBoxProvider>(context, listen: false).textBoxes.firstWhere((element) => element.id == id);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(

              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: textbox.bannerColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 20),
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: GridView.count(
                  crossAxisCount: 6,
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.vertical,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 15,
                  children: defaultColors.map((color) {
                    return GestureDetector(
                      onTap: () {
                        Provider.of<TextBoxProvider>(context, listen: false).updateBannerColor(id,color);
                      },
                      child: Container(
                        margin: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: textbox.bannerColor == color ? [
                            BoxShadow(
                              color: color.withOpacity(0.8),
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ] : [],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      }
    );
  }
}


// v1 _draggable text box state

// class _DraggableTextBoxState extends State<DraggableTextBox> {
//   Offset position = Offset.zero;
//   quill.QuillController _controller = quill.QuillController.basic();
//   GlobalKey key;
//   GlobalKey containerKey; // Define a new GlobalKey for the Container
//   FocusNode _focusNode = FocusNode();
//
//   _DraggableTextBoxState(this.key, this.containerKey);
//
//   @override
//   void initState() {
//     super.initState();
//     position = widget.position;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       left: position.dx,
//       top: position.dy,
//       child: Draggable(
//         onDragEnd: (details) {
//           final RenderBox renderBox = widget.canvasKey.currentContext!.findRenderObject() as RenderBox;
//           final localPosition = renderBox.globalToLocal(details.offset);
//           setState(() {
//             position = localPosition;
//           });
//         },
//         feedback: Material(
//           elevation: 6,
//           child: Container(
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.black),
//               borderRadius: BorderRadius.circular(5),
//               color: Colors.white,
//
//             ),
//             width: widget.size.width,
//             height: widget.size.height,
//             padding: const EdgeInsets.all(8),
//           ),
//         ),
//         childWhenDragging: Container(),
//         child: Container(
//           key: containerKey,
//           decoration: BoxDecoration(
//             border: Border.all(
//
//               color: _controller.document.length == 0 || !_focusNode.hasFocus ? Colors.black : Colors.transparent,),
//             borderRadius: BorderRadius.circular(5),
//           ),
//           width: widget.size.width,
//           padding: const EdgeInsets.all(8),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               quill.QuillEditor.basic(
//                 focusNode: _focusNode,
//                 configurations: quill.QuillEditorConfigurations(
//                   controller: _controller,
//
//                   readOnly: false,
//                   sharedConfigurations: const quill.QuillSharedConfigurations(
//                     locale: Locale('en'),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
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