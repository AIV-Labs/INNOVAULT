import 'dart:math' as math;
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

enum PointerMode { pen,
  eraser,
  // brush,
  pin,
  none }
class DraggableFab extends StatefulWidget {
  final ValueChanged<PointerMode> onModeChange;
  final PointerMode currentMode;
  final Function toggleSettingsON;
  final Function toggleSettingsOFF;
  final isSettingsVisible;

  const DraggableFab({
    required this.onModeChange,
    required this.currentMode,
    required this.toggleSettingsON,
    required this.toggleSettingsOFF,
    required this.isSettingsVisible,
    Key? key,
  }) : super(key: key);

  @override
  _DraggableFabState createState() => _DraggableFabState();
}

class _DraggableFabState extends State<DraggableFab> with SingleTickerProviderStateMixin {
  Offset position = Offset(50, 50);
  bool isFabOpen = false;
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

  void _toggleFab() {
    setState(() {
      isFabOpen = !isFabOpen;
      if (isFabOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  // global key for main fab
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Positioned(
      left: position.dx,
      top: position.dy,
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
                      position += details.delta;
                    });
                  }
                },
                onLongPress: () {
                  if( widget.isSettingsVisible == false ){
                    if (isFabOpen == true ){
                      _toggleFab();
                    }
                    widget.toggleSettingsON();
                  }
                  else {
                    widget.toggleSettingsOFF();

                  }
                //   showModalBottomSheet<void>(
                //     context: context,isDismissible: false,
                //     enableDrag: true,
                //     barrierColor: Colors.transparent,showDragHandle: true,
                //
                //     builder: (BuildContext context) {
                //       return Container(
                //           height: 200,
                //           color: Colors.amber,
                //           child: Center(
                //             child: Column(
                //               mainAxisAlignment: MainAxisAlignment.center,
                //               mainAxisSize: MainAxisSize.min,
                //               children: <Widget>[
                //                 const Text('Long Press Menu'),
                //                 ElevatedButton(
                //                   onPressed: () => Navigator.pop(context),
                //                   child: const Text('Close'),
                //                 ),
                //               ],
                //             ),
                //           ));
                // },);

                  },
                onTap: () {
                  widget.toggleSettingsOFF();
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
                      FloatingActionButton(
                        heroTag: 'mainfab',
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      onPressed: null, // Null disables the default onPressed behavior
                      child: isFabOpen ? Icon(Icons.close) : _getIconForMode(widget.currentMode),
                    ),]
                  ),
                ),
              ),

          ],
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
    var details = calculateBestStartAngle(screenSize, position);
    var overlayDetails = calculateOverlayDetails(screenSize, position, distance);

    double startAngle = details.startAngle;  // Use the calculated start angle
    double angleIncrement = math.pi / 4; // Modify this to change the spread of buttons

    for (int i = 0; i < PointerMode.values.length; i++) {
      final mode = PointerMode.values[i];
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  mini: true,
                  onPressed: isFabOpen ? () => _selectMode(mode) : null,
                  backgroundColor: _getColorForMode(mode),
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
    _toggleFab();

  }

  Icon _getIconForMode(PointerMode mode) {
    switch (mode) {
      case PointerMode.pen:
        return Icon(Icons.edit);
      case PointerMode.eraser:
        return Icon(Icons.delete);
      // case PointerMode.brush:
      //   return Icon(Icons.brush);
      case PointerMode.pin:
        return Icon(Icons.push_pin);
      case PointerMode.none:
        return Icon(Icons.pan_tool_alt);
      default:
        return Icon(Icons.edit); // Default case, should not happen
    }
  }

  Color _getColorForMode(PointerMode mode) {
    switch (mode) {
      case PointerMode.pen:
        return Colors.blue;
      case PointerMode.eraser:
        return Colors.red;
      // case PointerMode.brush:
      //   return Colors.green;
      default:
        return Colors.blue; // Default case, should not happen
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



