


import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:provider/provider.dart';


import '../../../Functions/Providers/canvas_provider.dart';
import '../../../Functions/Providers/pen_options_provider.dart';
import '../../AppStructure/hero_routes.dart';
import 'AIV_Draggable_FAB_RV1.dart';
import '../ToolsWidgets/ToolBarSettings/expanded_pin.dart';
import '../notebook_background_painter.dart';
import 'ToolBarSettings/PinSettings.dart';
import 'ToolBarSettings/settings_layout_builder.dart';
import 'ToolsWidgets/eraser_cursor.dart';
import 'ToolsWidgets/stroke_painting_functions.dart';

class AIVCanvas extends StatefulWidget  {
  String imagePath;
   AIVCanvas({Key? key, this.imagePath =''}) : super(key: key);

  @override
  _AIVCanvasState createState() => _AIVCanvasState();
}
class _AIVCanvasState extends State<AIVCanvas> with TickerProviderStateMixin{

  bool isFloatingToolbarVisible = false;
  late AnimationController floatingToolbarController;
  late Animation<Offset> slideAnimation;
  late Animation<double> opacityAnimation;
  GlobalKey mainFabKey = GlobalKey();

  bool isImageLoaded = false;



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

  // Canvas  GlobalKey
  final canvasKey = GlobalKey();
  ValueNotifier<Offset> fabPositionNotifier = ValueNotifier(Offset.zero);


  @override
  void dispose() {
    super.dispose();
    floatingToolbarController.dispose();
  }
  // if image
  double top = 0;
  double left = 0;
  @override
  Widget build(BuildContext context) {

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mainFabKey.currentContext != null) {
        final RenderBox fabRenderBox = mainFabKey.currentContext!.findRenderObject() as RenderBox;
        final Offset fabPosition = fabRenderBox.localToGlobal(Offset.zero);
        fabPositionNotifier.value = fabPosition;
      }
    });


    return DrawingOptionsProvider(
      child: ChangeNotifierProvider(
        create: (context) => CanvasProvider(context: context, canvasKey: canvasKey),
        child: Consumer<CanvasProvider>(
            builder: (context, provider, child) {
              provider.draggableTextBoxes =
                  provider.createDraggableTextBoxes(context);

              // Update the image path in the provider if it has changed
              if (provider.imagePath != widget.imagePath) {
                provider.updateImagePath(widget.imagePath);
              }
                        return LayoutBuilder(
                            builder: (context, constraints) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                              final RenderBox canvasBox = canvasKey.currentContext!.findRenderObject() as RenderBox;
                              final canvasSize = canvasBox.size;
                              if (provider.initialImageSize == null) {
                                double factor = 0.85;
                                provider.updateImageSize(Size(
                                    canvasSize.width * factor,
                                    canvasSize.height * factor));
                              if (provider.initialImagePosition == null) {
                                final canvasCenter = Offset(
                                    canvasSize.width / 2,
                                    canvasSize.height / 2);
                                provider.updateImagePosition( Offset(
                                canvasCenter.dx - provider.initialImageSize!.width / 2,
                                canvasCenter.dy - provider.initialImageSize!.height / 2));
                              }
                              top = provider.initialImagePosition!.dy;
                              left = provider.initialImagePosition!.dx;
                            }});
                              return ClipRRect(
                                child: Stack(
                                  key: canvasKey,
                                  children: [
                                    Positioned.fill(
                                      child: Listener(
                                        onPointerDown: (details) =>
                                            provider.onPointerDown(details,),
                                        onPointerMove: (details) =>
                                            provider.onPointerMove(details),
                                        onPointerUp: (details) =>
                                            provider.onPointerUp(details),
                                        onPointerCancel: (details) =>
                                            provider.onPointerCancel(details),
                                        child: GestureDetector(
                                          // for un-focusing text boxes
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
                                                painter: NotebookBackgroundPainter(
                                                    backgroundType: provider
                                                        .backgroundType,
                                                    bgColor: provider
                                                        .backgroundColor,
                                                    lineColor: provider
                                                        .backgroundLinesColor),
                                              ),

                                              // Add this Positioned widget to draw the image
                                              ///In summary, this code is used to display an image at the center of a canvas ,
                                              /// with the image's size and position being managed by a CanvasProvider.
                                              /// after first initialization, the image size and position are stored in the provider for future use.
                                              /// this will make sure the pins and textboxes are drawn on top of the image always in the correct position.

                                              (provider.imagePath != null) ?
                                              Positioned(
                                                top: top,
                                                left: left,

                                                child: SizedBox(
                                                    width: provider
                                                        .initialImageSize!
                                                        .width,
                                                    height: provider
                                                        .initialImageSize!
                                                        .height,
                                                    child: Image(
                                                        image: AssetImage(
                                                            provider
                                                                .imagePath!,
                                                        ),
                                                    height: provider.initialImageSize!.height,
                                                    width: provider.initialImageSize!.width,
                                                      fit: BoxFit.contain,
                                                    )),
                                              ) : const SizedBox(),

                                              // Previous lines
                                              Positioned.fill(
                                                child: RepaintBoundary(
                                                  child: ValueListenableBuilder<
                                                      List<Stroke>>(
                                                    valueListenable: provider
                                                        .lines,
                                                    builder: (_, strokes, __) {
                                                      return RepaintBoundary(
                                                        child: CustomPaint(
                                                          willChange: false,
                                                          painter: MultiStrokePainter(
                                                              strokes: strokes),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                              // Current line
                                              Positioned.fill(
                                                child: ValueListenableBuilder<
                                                    Stroke?>(
                                                  valueListenable: provider
                                                      .line,
                                                  builder: (_, currentStroke,
                                                      __) {
                                                    return RepaintBoundary(
                                                      child: CustomPaint(

                                                        painter: currentStroke !=
                                                            null
                                                            ? StrokePainter(
                                                            stroke: currentStroke,
                                                            strokeStyle: provider
                                                                .currentMode)
                                                            : null,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),

                                              // TextBoxes
                                              ...provider.draggableTextBoxes,

                                              // Pins
                                              ...provider.pins.map((pin) {
                                                return Positioned.fromRect(
                                                  rect: Rect.fromCenter(
                                                      center: pin.position,
                                                      width: pin.size,
                                                      height: pin.size),
                                                  child: MouseRegion(
                                                    cursor: SystemMouseCursors
                                                        .click,
                                                    onEnter: (_) {
                                                      debugPrint(
                                                          'Pin entered pin id: ${pin
                                                              .id} location: ${pin
                                                              .position}');
                                                    },
                                                    onExit: (_) {
                                                      debugPrint(
                                                          'Pin exited pin id: ${pin
                                                              .id} location: ${pin
                                                              .position}');
                                                    },
                                                    child: GestureDetector(
                                                      onLongPress: () {
                                                        debugPrint(
                                                            'Long pressed pin id: ${pin
                                                                .id} location: ${pin
                                                                .position}');
                                                        debugPrint(
                                                            'number of pins: ${provider
                                                                .pins
                                                                .length}, pins are not unique ${provider
                                                                .pins.map((
                                                                pin) =>
                                                            pin.id)}');
                                                        Navigator.of(context)
                                                            .push(
                                                            HeroDialogRoute(
                                                              builder: (
                                                                  context) =>
                                                                  Center(
                                                                    child: SizedBox(
                                                                      height: 600,
                                                                      // Change as per your requirement
                                                                      width: 600,
                                                                      child: Hero(
                                                                        tag: ValueKey(
                                                                            pin
                                                                                .id),
                                                                        child: Material(
                                                                          borderRadius: BorderRadius
                                                                              .circular(
                                                                              30),
                                                                          child: ExpandedPin(
                                                                              pin: pin), // Replace with your detailed view
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                            ));
                                                      },
                                                      child: Hero(
                                                        tag: ValueKey(pin.id),
                                                        child: Material(
                                                          borderRadius: BorderRadius
                                                              .circular(10),
                                                          color: Colors
                                                              .transparent,
                                                          child: Tooltip(
                                                            message: 'Pin id: ${pin
                                                                .id} tooltip: ${pin
                                                                .tooltip}',
                                                            triggerMode: TooltipTriggerMode
                                                                .tap,
                                                            child:
                                                            Container(
                                                                child: ShapeMaker(
                                                                    shapeType: pin
                                                                        .shape,
                                                                    color: pin
                                                                        .color)
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
                                                valueListenable: provider
                                                    .isCursorVisible,
                                                builder: (context, isVisible,
                                                    _) {
                                                  return ValueListenableBuilder<
                                                      Offset>(
                                                    valueListenable: provider
                                                        .pointerPosition,
                                                    builder: (context, position,
                                                        _) {
                                                      return Visibility(
                                                        visible: isVisible &&
                                                            (provider
                                                                .currentMode ==
                                                                PointerMode
                                                                    .eraser),
                                                        child: CustomCursor(
                                                            position: position),
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


                                    //TODO: check whether i should pass function in constructor or not
                                    DraggableFab(
                                        key: mainFabKey,
                                        onModeChange: provider.handleModeChange,
                                        currentMode: provider.currentMode,
                                        toggleSettingsON: openFloatingToolbar,
                                        toggleSettingsOFF: closeFloatingToolbar,
                                        isSettingsVisible: isFloatingToolbarVisible),

                                    // gets the top-left position of the FAB

                                    ValueListenableBuilder(
                                      valueListenable: fabPositionNotifier,
                                      builder: (context, Offset fabPosition,
                                          _) {
                                        // Define the animation controller and animations

                                        return Positioned(
                                          left: fabPosition.dx - 60,
                                          // change this as needed
                                          top: fabPosition.dy + 160,
                                          // change this as needed
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
                                                  child: Card(

                                                      child: Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                              vertical: 10,
                                                              horizontal: 5),
                                                          child: SingleChildScrollView(
                                                              child: PenSettingsLayoutBuilder(
                                                                currentMode: provider
                                                                    .currentMode,
                                                                activeQuillController: provider
                                                                    .activeQuillController,
                                                                clearStrokes: provider
                                                                    .clearStrokes,
                                                                clearPins: provider
                                                                    .clearPins,
                                                                clearTextBoxes: provider
                                                                    .clearTextBoxes,
                                                                onModeChanged: provider
                                                                    .handleModeChange,
                                                                backgroundType: provider
                                                                    .backgroundType,
                                                                updateBackgroundType: provider
                                                                    .updateBackgroundType,
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

                                ),
                              );
                            }
                        );
              }
            )
      ),
    );
  }
}
