

import 'dart:async';
import 'dart:math';
import 'dart:ui'as ui;



import 'package:flutter/material.dart';
import 'package:innovault/Functions/Providers/pen_options_provider.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:provider/provider.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import '../../Components/CustomPressueSensitiveWidgets/AIV_freehand_multi_tool_canvas.dart';
import '../../Components/CustomPressueSensitiveWidgets/notebook_background_painter.dart';

class CanvasProvider with ChangeNotifier {

  BuildContext context;
  PointerMode currentMode = PointerMode.pen;
  GlobalKey canvasKey ;

  // image background details
  ui.Image? image;
  String? imagePath;
  Offset? initialImagePosition;
  Size? initialImageSize;

  CanvasProvider({required this.context, required this.canvasKey}) {
    // Initialize the canvas provider with the pen mode
  }

  Future<void> _loadImage() async {
  if (imagePath != null) {
    final imageProvider = AssetImage(imagePath!);
    final completer = Completer<ImageInfo>();
    final listener = ImageStreamListener((ImageInfo info, bool _) {
      if (!completer.isCompleted) {
        completer.complete(info);
      }
    });
    imageProvider.resolve(ImageConfiguration()).addListener(listener);
    final imageInfo = await completer.future;
    imageProvider.resolve(ImageConfiguration()).removeListener(listener);
    image = imageInfo.image;
    initialImageSize = Size(image!.width.toDouble(), image!.height.toDouble());
    notifyListeners();
  }
}
 void updateImagePosition(Offset newPosition) {
    initialImagePosition = newPosition;
    notifyListeners();
  }
  void updateImageSize(Size newSize) {
    initialImageSize = newSize;
    notifyListeners();
  }

  // Add a method to update the image path
  void updateImagePath(String newPath) {
    imagePath = newPath;
    _loadImage();
  }


  // make sure to init the boxes with this function everytime:
  List<DraggableTextBox> createDraggableTextBoxes(BuildContext context) {
    return Provider.of<TextBoxProvider>(context, listen: false)
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
// another named constructor without canvasKey

  // background colors
  // Background color
  Color backgroundColor = Colors.white;

  // Background lines color
  Color backgroundLinesColor = Colors.blueGrey;


  // line drawing
  ValueNotifier<List<Stroke>> lines = ValueNotifier<List<Stroke>>([]);
  ValueNotifier<Stroke?> line = ValueNotifier<Stroke?>(null);
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
      final supportsPressure = details.kind == ui.PointerDeviceKind.stylus;
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

  void onPointerCancel(PointerCancelEvent details) {
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

  }


  PointVector _createBrushPoint(PointerEvent details) {
    final supportsPressure = details.kind == ui.PointerDeviceKind.stylus;
    return PointVector(
      details.localPosition.dx,
      details.localPosition.dy,
      supportsPressure ? details.pressure : null,
    );
  }


  // Text boxes
  ValueNotifier<quill.QuillController?> activeQuillController = ValueNotifier(quill.QuillController.basic());
  List<DraggableTextBox> draggableTextBoxes = [];
  ValueNotifier<bool> isDraggingTextBox = ValueNotifier<bool>(false);
  static const int MAX_EMPTY_BOXES = 10;
  void createTextBox(Offset position) {

    // making sure you can't add infinite amount of empty text boxes
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
      notifyListeners();

  }
  void removeTextBox(String id) {

      // Remove the text box from the list
      draggableTextBoxes.removeWhere((element) => element.id == id);
      // Remove the text box from the provider
      Provider.of<TextBoxProvider>(context, listen: false).removeTextBox(id);
      notifyListeners();
  }

  // Pins
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

          // Create a new pin and add it to the list
          pins.add(
              Pin(position: details.localPosition,
                  shape: Provider.of<PinOptionsProvider>(context, listen: false).shape,
                  size: Provider.of<PinOptionsProvider>(context, listen: false).size,
                  color: Provider.of<PinOptionsProvider>(context, listen: false).color,
                  history: [],
                  id: UniqueKey().toString(),
                  tooltip: 'Pin #: ${pins.length}'));
          notifyListeners();
      }
    }
  }

  // erasing
  ValueNotifier<Offset> pointerPosition = ValueNotifier(Offset.zero);
  ValueNotifier<bool> isCursorVisible = ValueNotifier(false);

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
                          pins.remove(pin);
                          notifyListeners();
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
      notifyListeners();
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

      pins = pins.where((pin) {
        final distanceToPinCenter = (point - pin.position).distance;
        return distanceToPinCenter > eraserSize/2;
      }).toList();
      notifyListeners();
  }
  void clear() {


      lines.value = [];
      line.value = null;
      pins = [];
      pointCount = 0;
      notifyListeners();
  }
  void clearStrokes() {

      lines.value = [];
      line.value = null;
      pointCount = 0;
      notifyListeners();
  }
  void clearPins() {

      pins = [];
      notifyListeners();
  }
  void clearTextBoxes() {

      draggableTextBoxes = [];
      notifyListeners();
    // clear the provider
    Provider.of<TextBoxProvider>(context, listen: false).clearTextBoxes();
  }

  // background
  BackgroundType backgroundType = BackgroundType.grid;
  ValueNotifier<Offset> fabPositionNotifier = ValueNotifier(Offset.zero);

  void updateBackgroundType(BackgroundType type) {
    debugPrint('updateBackgroundType called with type: $type');

      backgroundType = type;
      notifyListeners();
  }
//todo update background line and bg colors
  // Method to change background color
  void changeBackgroundColor(Color newColor) {
    backgroundColor = newColor;
    notifyListeners();
  }

  // Method to change background lines color
  void changeBackgroundLinesColor(Color newColor) {
    backgroundLinesColor = newColor;
    notifyListeners();
  }

  void handleModeChange(PointerMode mode) {
  switch (mode) {
    case PointerMode.pen:
      currentMode = PointerMode.pen;
      break;
    case PointerMode.eraser:
      currentMode = PointerMode.eraser;
      break;
    case PointerMode.none:
      currentMode = PointerMode.none;
      break;
    case PointerMode.textBox:
      currentMode = PointerMode.textBox;
      break;
    case PointerMode.pin:
      currentMode = PointerMode.pin;
      break;
    default:
      break;
  }
  notifyListeners(); // Notify all listeners about the change
}




  // TODO: Add methods for undo, redo, and infinite canvas here
}
