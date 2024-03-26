import 'dart:math' as math;
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

enum FabMode { pen, eraser, brush }
enum Quadrant { topLeft, topRight, bottomLeft, bottomRight }


class DraggableFab extends StatefulWidget {
  final ValueChanged<FabMode> onModeChange;
  final FabMode currentMode;

  DraggableFab({required this.onModeChange, required this.currentMode});

  @override
  _DraggableFabState createState() => _DraggableFabState();
}

class _DraggableFabState extends State<DraggableFab> with SingleTickerProviderStateMixin {
  Offset position = Offset(50, 50);
  bool isFabOpen = false;
  bool isLongPressMenuVisible = false; // State to track visibility of the long-press menu

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
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
                if (!isFabOpen && !isLongPressMenuVisible) {
                  setState(() {
                    position += details.delta;
                  });
                }
              },
              onLongPress: () {
                setState(() {
                  isLongPressMenuVisible = true;
                });
              },
              onTap: () {
                if (!isLongPressMenuVisible) {
                  _toggleFab();
                } else {
                  setState(() {
                    isLongPressMenuVisible = false;
                  });
                }
              },
              // Main FAB
              child: FloatingActionButton(
                onPressed: null, // Null disables the default onPressed behavior
                child: isFabOpen ? Icon(Icons.close) : _getIconForMode(widget.currentMode),
              ),
            ),
          ),

          // Display the long-press menu if it's visible
          if (isLongPressMenuVisible)
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              // Define the content and styling for your long-press menu here
            ),
        ],
      ),
    );
  }



  // v1 : quadrant based
  // double calculateBestStartAngle(Size screenSize, Offset fabPosition) {
  //   // Calculate available space in all directions
  //   double availableLeft = fabPosition.dx;
  //   double availableRight = screenSize.width - fabPosition.dx;
  //   double availableTop = fabPosition.dy;
  //   double availableBottom = screenSize.height - fabPosition.dy;
  //
  //   // Determine the quadrant where the FAB is positioned
  //   // and set the starting angle to expand towards the opposite direction
  //   if (availableRight > availableLeft && availableBottom > availableTop) {
  //     // FAB is in the top-left quadrant, expand towards bottom-right
  //     // Starting slightly above π to ensure expansion towards bottom-right
  //     return math.pi *2;
  //   } else if (availableRight > availableLeft && availableTop >= availableBottom) {
  //     // FAB is in the bottom-left quadrant, expand towards top-right
  //     // This quadrant is correct; no change needed
  //     return 3 * math.pi / 2;
  //   } else if (availableLeft >= availableRight && availableBottom > availableTop) {
  //     // FAB is in the top-right quadrant, expand towards bottom-left
  //     // This quadrant is correct; no change needed
  //     return math.pi / 2;
  //   } else {
  //     // FAB is in the bottom-right quadrant, expand towards top-left
  //     // Starting slightly above 0 to ensure expansion towards top-left
  //     return math.pi;
  //   }
  // }

// v1.2: calculate with surface area for ignore pointer
  FabExpansionDetails calculateBestStartAngle(Size screenSize, Offset fabPosition) {
    double availableLeft = fabPosition.dx;
    double availableRight = screenSize.width - fabPosition.dx;
    double availableTop = fabPosition.dy;
    double availableBottom = screenSize.height - fabPosition.dy;

    double startAngle;

    if (availableRight > availableLeft && availableBottom > availableTop) {
      startAngle = math.pi * 2;  // Expanding towards bottom-right
    } else if (availableRight > availableLeft && availableTop >= availableBottom) {
      startAngle = 3 * math.pi / 2;  // Expanding towards top-right
    } else if (availableLeft >= availableRight && availableBottom > availableTop) {
      startAngle = math.pi / 2;  // Expanding towards bottom-left
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

    for (int i = 0; i < FabMode.values.length; i++) {
      final mode = FabMode.values[i];
      // Calculate the angle for each button based on the start angle and their index
      double angle = startAngle + angleIncrement * i;

      buttons.add(
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(math.cos(angle) * distance * _controller.value,
                  math.sin(angle) * distance * _controller.value),
              child: FloatingActionButton(
                mini: true,
                onPressed: isFabOpen ? () => _selectMode(mode) : null,
                backgroundColor: _getColorForMode(mode),
                child: _getIconForMode(mode),
              ),
            );
          },
        ),
      );
    }

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
                    color: Colors.black.withOpacity(0.3),
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

  // Widget _buildActionButtons(Size screenSize) {
  //   final double distance = 100.0;
  //   List<Widget> buttons = [];
  //   var details = calculateBestStartAngle(screenSize, position);
  //
  //   double startAngle = details.startAngle;  // Use the calculated start angle
  //   double angleIncrement = math.pi / 4; // Modify this to change the spread of buttons
  //
  //   for (int i = 0; i < FabMode.values.length; i++) {
  //     final mode = FabMode.values[i];
  //     double angle = startAngle + angleIncrement * i;
  //
  //     buttons.add(
  //       AnimatedBuilder(
  //         animation: _controller,
  //         builder: (context, child) {
  //           return Transform.translate(
  //             offset: Offset(math.cos(angle) * distance * _controller.value,
  //                 math.sin(angle) * distance * _controller.value),
  //             child: IgnorePointer(
  //               ignoring: !isFabOpen,
  //               child: FloatingActionButton(
  //                 mini: true,
  //                 onPressed: isFabOpen ? () => _selectMode(mode) : null,
  //                 backgroundColor: _getColorForMode(mode),
  //                 child: _getIconForMode(mode),
  //               ),
  //             ),
  //           );
  //         },
  //       ),
  //     );
  //   }
  //
  //   return Stack(
  //     children: [
  //       AnimatedBuilder(
  //         animation: _controller,
  //         builder: (context, child) {
  //           double diameter = max(100, distance * 2 * _controller.value);
  //           return Positioned(
  //             left: position.dx - diameter / 2,
  //             top: position.dy - diameter / 2,
  //             child: IgnorePointer(
  //               ignoring: !isFabOpen,
  //               child: Container(
  //                 width: diameter,
  //                 height: diameter,
  //                 decoration: BoxDecoration(
  //                   color: Colors.black.withOpacity(0.5 * _controller.value),
  //                   shape: BoxShape.circle,
  //                 ),
  //               ),
  //             ),
  //           );
  //         },
  //       ),
  //       ...buttons
  //     ],
  //   );
  // }


  void _selectMode(FabMode mode) {
    debugPrint('Selected mode: $mode');
    widget.onModeChange(mode);
    _toggleFab();

  }

  Icon _getIconForMode(FabMode mode) {
    switch (mode) {
      case FabMode.pen:
        return Icon(Icons.edit);
      case FabMode.eraser:
        return Icon(Icons.delete);
      case FabMode.brush:
        return Icon(Icons.brush);
      default:
        return Icon(Icons.edit); // Default case, should not happen
    }
  }

  Color _getColorForMode(FabMode mode) {
    switch (mode) {
      case FabMode.pen:
        return Colors.blue;
      case FabMode.eraser:
        return Colors.red;
      case FabMode.brush:
        return Colors.green;
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



