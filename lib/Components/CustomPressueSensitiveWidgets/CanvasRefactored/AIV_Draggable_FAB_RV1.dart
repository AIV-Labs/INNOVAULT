import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';

import '../../../Functions/Providers/pen_options_provider.dart';


class DraggableFab extends StatefulWidget {
  final ValueChanged<PointerMode> onModeChange;
  final PointerMode currentMode;
  final Function toggleSettingsON;
  final Function toggleSettingsOFF;
  final isSettingsVisible;
  final isSettingsLocked;
  // fab position notifiers
  ValueNotifier<Offset> fabPositionNotifier;

   DraggableFab({
    required this.onModeChange,
    required this.currentMode,
    required this.toggleSettingsON,
    required this.toggleSettingsOFF,
    required this.isSettingsVisible,
    required this.fabPositionNotifier,
    required this.isSettingsLocked,
    Key? key,
  }) : super(key: key);

  @override
  _DraggableFabState createState() => _DraggableFabState();
}

class _DraggableFabState extends State<DraggableFab> with SingleTickerProviderStateMixin {

  bool isFabOpen = false;
  bool isTooltipVisible = false;
  // State to track visibility of the long-press menu

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  bool wasSettingsVisibleBeforeFabOpened = false;

  void _toggleFab() {
  setState(() {
    isFabOpen = !isFabOpen;
    if (!widget.isSettingsLocked) {
      if (isFabOpen) {
        isTooltipVisible = false;
        wasSettingsVisibleBeforeFabOpened = widget.isSettingsVisible;
        _controller.forward();
      } else {
        if (wasSettingsVisibleBeforeFabOpened) {
          widget.toggleSettingsON();
        }
        // for tooltip to not show if the settings are visible
        isTooltipVisible = true;
        _controller.reverse();
      }
    }
    else {
      if (isFabOpen) {
        isTooltipVisible = false;
        _controller.forward();
      } else {
        isTooltipVisible = true;
        _controller.reverse();
      }
    }

  });
  Future.delayed(const Duration(seconds: 2), () {
    setState(() {
      isTooltipVisible = false;
    });
  });
}

  // global key for main fab
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Positioned(
        left: widget.fabPositionNotifier.value.dx,
        top: widget.fabPositionNotifier.value.dy,
        child: RepaintBoundary(
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              // If the FAB is open, display action buttons and ensure they're interactable
          
              _buildActionButtons(screenSize),
          
          
              // Main FAB handling drag, tap, and long-press
              Positioned(
          
                child: GestureDetector(
                  onPanUpdate: (details) {
                    // Allow dragging only if the FAB isn't open and no long-press menu is visible
                    if (!isFabOpen ) {
                      setState(() {
          
                        widget.fabPositionNotifier.value = Offset(
                          widget.fabPositionNotifier.value.dx + details.delta.dx,
                          widget.fabPositionNotifier.value.dy + details.delta.dy,
                        );
                      });
                    }
                  },
                  onLongPress: () {
          
                    if (isFabOpen) {
                      _toggleFab();
                    }
                    if (widget.isSettingsVisible) {
                      widget.toggleSettingsOFF();
                    } else {
                      widget.toggleSettingsON();
                    }
          
                    },
                  onTap: () {
                    if (!isFabOpen && !widget.isSettingsLocked) {
                      widget.toggleSettingsOFF(false);
                    }
                    _toggleFab();
                },
                  // Main FAB
                    child: Stack(
                      children:[
                        Positioned.fill(
                          child: const IgnorePointer(
                            ignoring: true,
                          ),
                        ),
                        Column(
                          children: [
                            FloatingActionButton(
                              heroTag: 'mainfab',
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              backgroundColor: Color(0xffebebeb),
                              onPressed: null, // Null disables the default onPressed behavior
                              child: isFabOpen ? Icon(Icons.close) : _getIconForMode(widget.currentMode),
                            ),
                            const SizedBox(height: 5),
                            // text
          
                            AnimatedOpacity(
                              // opacity: !isFabOpen && !widget.isSettingsVisible ? 1.0 : 0.0,
                              opacity: isTooltipVisible ? 1.0 : 0.0,
                              duration: Duration(milliseconds: 250),
                              curve: Curves.decelerate,
                              child: Text('Tap/Hold for more options',
                                style: TextStyle(fontSize: 12, color: Color(0xFF0b090a), fontFamily: 'Poppins', fontWeight: FontWeight.w500),),
                            )
                          ],
                        ),
                      ]
                    ),
                  ),
                ),
          
            ],
          ),
        ),
    );
  }




// v1.2: calculate with surface area for ignore pointer
  FabExpansionDetails calculateBestStartAngle(Size screenSize, Offset fabPosition) {
    double availableLeft = fabPosition.dx;
    double availableRight = screenSize.width - fabPosition.dx;
    double availableTop = fabPosition.dy;
    double availableBottom = screenSize.height - fabPosition.dy;

    double startAngle;

    if (availableRight > availableLeft && availableBottom > availableTop) {
      startAngle = math.pi +3;  // Expanding towards bottom-right
    } else if (availableRight > availableLeft && availableTop >= availableBottom) {
      startAngle = 3 * math.pi + 7.5;  // Expanding towards top-right
    } else if (availableLeft >= availableRight && availableBottom > availableTop) {
      startAngle = math.pi +4;  // Expanding towards bottom-left
    } else {
      startAngle = math.pi;  // Expanding towards top-left
    }

    // Start angle is enough from this function; width, height, and offset are not needed here
    return FabExpansionDetails(startAngle, 0, 0, Offset(0, 0));
  }


  // This method now calculates the size and position for the IgnorePointer based on the action buttons' layout
  FabExpansionDetails calculateOverlayDetails(Size screenSize, Offset fabPosition, double distance) {
    double width = distance * 1.5;
    double height = distance * 1.5;
    // Offset should position the IgnorePointer centered around the FAB
    double offsetX = fabPosition.dx - distance;
    double offsetY = fabPosition.dy - distance;

    return FabExpansionDetails(0.0, width, height, Offset(offsetX, offsetY));
  }

  // ignore pointer not opening in the appropriate quadrant for the buttons

  Widget _buildActionButtons(Size screenSize) {
    final double distance = 80.0;
    List<Widget> buttons = [];
    // Use the start angle calculated based on the FAB's position
    var details = calculateBestStartAngle(screenSize, widget.fabPositionNotifier.value);
    var overlayDetails = calculateOverlayDetails(screenSize, widget.fabPositionNotifier.value, distance);

    double startAngle = details.startAngle;  // Use the calculated start angle
    double angleIncrement = math.pi / 4; // Modify this to change the spread of buttons
    List<PointerMode> modes = [PointerMode.pen, PointerMode.textBox,PointerMode.pin,PointerMode.eraser,  PointerMode.none];
    for (int i = 0; i < modes.length; i++) {
  final mode = modes[i];
  // Calculate the angle for each button based on the start angle and their index
  double angle = startAngle + angleIncrement * i;

  buttons.add(
    AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(math.cos(angle) * distance * _controller.value,
              math.sin(angle) * distance * _controller.value),
          child: AnimatedOpacity(
            duration: Duration(milliseconds: 150),
            opacity: isFabOpen ? 1.0 : 0.0,
            child: FloatingActionButton(
              heroTag: mode.toString(),
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              mini: true,
              onPressed: isFabOpen ? () => _selectMode(mode) : null,
              backgroundColor: Colors.white,
              child: _getIconForMode(mode),
            ),
          ),
        );
      },
    ),
  );
}
    //test push
    return Stack(
      children: [
        // ignore Pointer
        Positioned(
          child: SizedBox(
            width: overlayDetails.width * 2,
            height: overlayDetails.height * 2,
            child: Align(
              alignment: Alignment.center,
              child: IgnorePointer(
                ignoring: !isFabOpen,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 150),  // Adjust the animation duration as needed
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  width: isFabOpen ? overlayDetails.width + 90 : 0,  // Expand or shrink based on isFabOpen
                  height: isFabOpen ? overlayDetails.height + 90 : 0,
                ),
              ),
            ),
          ),
        ),
        // align the bottom at the center of the of the size of the ignore pointer
        // SizedBox(
        //   width: overlayDetails.width * 2,
        //   height: overlayDetails.height * 2,
        //   child: Align(
        //     alignment: Alignment.center,
        //     child: Stack(
        //       children: [
        //         ...buttons
        //       ],
        //     ),
        //   ),
        // ),
        ...buttons.map((button) {
          return Positioned(
            left:overlayDetails.width -25,
            top:overlayDetails.height -25,
            child: button,
          );
        }),
      ],
    );
  }

  void _selectMode(PointerMode mode) {
    debugPrint('Selected mode: $mode');
    widget.onModeChange(mode);
    if (widget.isSettingsVisible) {
      widget.toggleSettingsON();
    }
    _toggleFab();
  }

  Icon _getIconForMode(PointerMode mode) {
    switch (mode) {
      case PointerMode.pen:
        return Icon(CupertinoIcons.pencil_outline, size: 20,
            color: Provider.of<PenOptionsProvider>(context).currentStrokeStyle.color);


      case PointerMode.eraser:
        return Icon(Bootstrap.eraser_fill,size: 20, color: Color(0xffdb7f8e));
      // case PointerMode.brush:
      //   return Icon(Icons.brush);
      case PointerMode.pin:
        return Icon(Bootstrap.hexagon_half, size: 20,color: Provider.of<PinOptionsProvider>(context).color);

      case PointerMode.textBox:
        return Icon(Bootstrap.text_paragraph, size: 20,color: Color(0xFF5A5766));
        case PointerMode.none:
        return Icon(Icons.pan_tool_alt, size: 20,color: Color(0xFF5A5766));
      default:
        return Icon(Icons.edit, size: 20,color: Color(0xFFadb5bd),); // Default case, should not happen
    }
  }


}

// v1.2: calculate with surface area for ignore pointer
// Define a new structure to hold both angle and size information
class FabExpansionDetails {
  final double startAngle;
  final double width;
  final double height;
  final Offset offset;  // Adding offset to the class

  FabExpansionDetails(this.startAngle, this.width, this.height, this.offset);
}



