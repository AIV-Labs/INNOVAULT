


import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:innovault/Components/CustomPressueSensitiveWidgets/CanvasRefactored/ToolsWidgets/text_box_widgets.dart';

import 'package:provider/provider.dart';


import '../../../Functions/Providers/canvas_provider.dart';
import '../../../Functions/Providers/pen_options_provider.dart';
import '../../AppStructure/hero_routes.dart';
import 'AIV_Draggable_FAB_RV1.dart';
import '../ToolsWidgets/ToolBarSettings/expanded_pin.dart';
import 'notebook_background_painter.dart';
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
  bool isSettingsLocked =false;

  late AnimationController floatingToolbarController;
  late Animation<Offset> slideAnimation;
  late Animation<double> opacityAnimation;
  GlobalKey mainFabKey = GlobalKey();

  bool isImageLoaded = false;


  @override
  initState() {
    super.initState();
        Provider.of<CanvasProvider>(context,listen:false).createDraggableTextBoxes(context);
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
  ValueNotifier<Offset> fabPositionNotifier = ValueNotifier(const Offset(50,50));

  ValueNotifier<Offset> settingsPosition = ValueNotifier(Offset.zero);
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

  void toggleLockSettings() {
    setState(() {
      isSettingsLocked = !isSettingsLocked;
    });

  }
  void updateSettingsPosition(Offset position) {
    setState(() {
      settingsPosition.value = Offset(position.dx - 30 , position.dy + 160 );
    });
  }

  // Canvas  GlobalKey
  final canvasKey = GlobalKey();



  @override
  void dispose() {
    super.dispose();
    floatingToolbarController.dispose();
  }
  // if image
  double top = 0;
  double left = 0;

  double canvasWidth = 0;
  @override
  Widget build(BuildContext context) {
    fabPositionNotifier.addListener(() {
      if (!isSettingsLocked) {
        updateSettingsPosition(fabPositionNotifier.value);
      }
    });


    return DrawingOptionsProvider(
      child: ChangeNotifierProvider(
        //todo make it create from selected canvas
        create: (context) => CanvasProvider(context: context, canvasKey: canvasKey),
        child: Consumer<CanvasProvider>(
            builder: (context, provider, child) {


              // Update the image path in the provider if it has changed
              if (provider.imagePath != widget.imagePath) {
                provider.updateImagePath(widget.imagePath);
              }
                        return LayoutBuilder(
                            builder: (context, constraints) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  // settings location
                                  if (!isSettingsLocked) {
                  updateSettingsPosition(fabPositionNotifier.value);
                }

                // image size and position
                              final RenderBox canvasBox = canvasKey.currentContext!.findRenderObject() as RenderBox;
                              final canvasSize = canvasBox.size;
                              final canvasCenter = Offset(canvasSize.width / 2, canvasSize.height / 2);
                              if (provider.initialImageSize == null) {
                                double factor = 0.9;
                                debugPrint('Canvas size: $canvasSize width: ${canvasSize.width} height: ${canvasSize.height}');
                                provider.updateImageSize(Size(
                                    canvasSize.width * factor,
                                    canvasSize.height * factor));
                                debugPrint ('Image size: ${provider.initialImageSize} width: ${provider.initialImageSize!.width} height: ${provider.initialImageSize!.height}');
                                debugPrint('Canvas center: $canvasCenter dx: ${canvasCenter.dx} dy: ${canvasCenter.dy}');
                                final imageCenter = Offset(
                                    canvasCenter.dx - provider.initialImageSize!.width / 2,
                                    canvasCenter.dy - provider.initialImageSize!.height / 2);
                                debugPrint('Image center: $imageCenter dx: ${imageCenter.dx} dy: ${imageCenter.dy}');
                                provider.updateImagePosition( imageCenter);

                             setState(() {
                               top = provider.initialImagePosition!.dy;
                               left = provider.initialImagePosition!.dx;
                               canvasWidth = canvasSize.width;
                             });
                            }});
                              return ClipRRect(
                                child: Container(
                                  decoration: BoxDecoration(
                                   border: Border.all(color: Colors.black, width: 1.0),
                                  ),
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

                                                ((provider.imagePath != null&& provider.imagePath != '') && provider.initialImagePosition != null && provider.initialImageSize != null ) ?
                                                Positioned.fromRect(
                                                  rect: Rect.fromLTWH(
                                                      provider.initialImagePosition!.dx,
                                                      provider.initialImagePosition!.dy,
                                                      provider.initialImageSize!.width,
                                                      provider.initialImageSize!.height),
                                                  child: SizedBox(
                                                    width: provider.initialImageSize!.width,
                                                    height: provider.initialImageSize!.height,
                                                    child: Image(

                                                        image: AssetImage(
                                                            provider
                                                                .imagePath!,
                                                        ),
                                                    ),
                                                  ),
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

                                      DraggableFab(
                                          key: mainFabKey,
                                          onModeChange: provider.handleModeChange,
                                          currentMode: provider.currentMode,
                                          toggleSettingsON: openFloatingToolbar,
                                          toggleSettingsOFF: closeFloatingToolbar,
                                          fabPositionNotifier: fabPositionNotifier,
                                          isSettingsLocked: isSettingsLocked,
                                          isSettingsVisible: isFloatingToolbarVisible),

                                      // gets the top-left position of the FAB

                                      ValueListenableBuilder(
                                        valueListenable: settingsPosition,
                                        builder: (context, Offset settingsPosition,
                                            _) {
                                          // Define the animation controller and animations

                                          return Positioned(
                                            top: settingsPosition.dy,
                                            left: settingsPosition.dx,
                                            child: RepaintBoundary(
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

                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              Flexible(
                                                                  child: Container(
                                                                    margin: const EdgeInsets
                                                                        .symmetric(

                                                                        horizontal: 10),
                                                                    child: Row(
                                                                      mainAxisAlignment: MainAxisAlignment
                                                                          .spaceBetween,
                                                                      children: [
                                                                        // two button to lock an get dragged with fab and another one to close the settings
                                                                       // circular button with dynamic icon`; attached , deattached
                                                                        SizedBox(
                                                                          height: 30,
                                                                          width: 30,
                                                                          child: ElevatedButton(
                                                                            style: ElevatedButton.styleFrom(
                                                                              backgroundColor: Colors.blueGrey,
                                                                              padding: EdgeInsets.zero
                                                                            ),
                                                                            child: Icon(
                                                                                isSettingsLocked
                                                                                    ? Icons
                                                                                    .lock_open
                                                                                    : Icons
                                                                                    .lock , color: Colors.white, size: 17,),
                                                                            onPressed: () {
                                                                              toggleLockSettings();
                                                                            },
                                                                          ),
                                                                        ),

                                                                        // close button
                                                                        SizedBox(
                                                                          height: 30,
                                                                          width: 30,
                                                                          child: ElevatedButton(
                                                                            style: ElevatedButton.styleFrom(
                                                                                backgroundColor: Color(0xFFce4257),
                                                                                padding: EdgeInsets.zero
                                                                            ),
                                                                            child: Icon(
                                                                                Icons
                                                                                    .close , color: Colors.white, size: 17,),
                                                                            onPressed: () {
                                                                              closeFloatingToolbar();
                                                                            },
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  )


                                                              ),
                                                              Flexible(
                                                                flex: 12,
                                                                child: Container(
                                                                  decoration: BoxDecoration(
                                                                      border: Border.all(
                                                                          color: Colors
                                                                              .grey,
                                                                          width: 1.0),
                                                                      borderRadius: BorderRadius
                                                                          .circular(
                                                                          10)),
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical: 5,
                                                                      horizontal: 5),
                                                                    margin: const EdgeInsets
                                                                        .symmetric(
                                                                        vertical: 10,
                                                                        horizontal: 10),
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
                                                                        ))),
                                                              ),
                                                            ],
                                                          )
                                                        // Define the content and styling for your long-press menu here
                                                      ),
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
