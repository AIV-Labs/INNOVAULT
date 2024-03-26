
/// this version mightbe building the the ignore pointers in the correct quadrants but the the current stack is being compleetly cropped for some reason

import 'dart:math' as math;
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
            top: 0,
            left: 0,
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
  // Widget _buildActionButtons(Size screenSize) {
  //   final double distance = 100.0;
  //   List<Widget> buttons = [];
  //   // Use the start angle calculated based on the FAB's position
  //   var details = calculateBestStartAngle(screenSize, position);
  //   var overlayDetails = calculateOverlayDetails(screenSize, position, distance);
  //
  //   double startAngle = details.startAngle;  // Use the calculated start angle
  //   double angleIncrement = math.pi / 4; // Modify this to change the spread of buttons
  //
  //   for (int i = 0; i < FabMode.values.length; i++) {
  //     final mode = FabMode.values[i];
  //     // Calculate the angle for each button based on the start angle and their index
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
  //           double minSize = 100; // Adjust if your FAB size is different
  //           double containerWidth = max(minSize, overlayDetails.width * _controller.value);
  //           double containerHeight = max(minSize, overlayDetails.height * _controller.value);
  //
  //           return IgnorePointer(
  //             ignoring: !isFabOpen,
  //             child: Container(
  //               width: containerWidth,
  //               height: containerHeight,
  //               color: Colors.black.withOpacity(0.5 * _controller.value),
  //             ),
  //           );
  //         },
  //       ),
  //       ...buttons
  //     ],
  //   );
  // }




  // four ignore pointers activated according to the quadrant




  // more elegant single ignore pointer moves within a quadrant for: needs to proplery adjsut the translations within a quadrant
  // Widget _buildActionButtons(Size screenSize) {
  //   final double distance = 100.0;
  //   List<Widget> buttons = [];
  //   var details = calculateBestStartAngle(screenSize, position);
  //
  //   for (int i = 0; i < FabMode.values.length; i++) {
  //     final mode = FabMode.values[i];
  //     double angle = details.startAngle + (math.pi / 4) * i;
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
  //           double containerWidth = max(56, distance * 2 * _controller.value);
  //           double containerHeight = max(56, distance * 2 * _controller.value);
  //
  //           // Adjust x and y based on the quadrant
  //           double offsetX = (details.startAngle == math.pi * 2 || details.startAngle == 3 * math.pi / 2) ?
  //           position.dx - containerWidth + (56 / 2) : position.dx - (56 / 2);
  //           double offsetY = (details.startAngle == math.pi || details.startAngle == math.pi * 2) ?
  //           position.dy - containerHeight + (56 / 2) : position.dy - (56 / 2);
  //
  //           return IgnorePointer(
  //             ignoring: !isFabOpen,
  //             child: Container(
  //               width: containerWidth,
  //               height: containerHeight,
  //               color: Colors.black.withOpacity(0.5 * _controller.value),
  //               transform: Matrix4.translationValues(offsetX, offsetY, 0.0),
  //             ),
  //           );
  //         },
  //       ),
  //       ...buttons
  //     ],
  //   );
  // }







  // v2 : TODO: 3x3 grid based


  // Widget _buildActionButtons(Size screenSize) {
  //   final double distance = 100.0;
  //   List<Widget> buttons = [];
  //
  //   double startAngle = calculateBestStartAngle(screenSize, position);
  //   double angleIncrement = math.pi / 4; // Modify this to change the spread of buttons
  //
  //   for (int i = 0; i < FabMode.values.length; i++) {
  //     final mode = FabMode.values[i];
  //     double angle = startAngle + angleIncrement * i;  // Adjust this if buttons overlap or don't fill the space as expected
  //
  //     buttons.add(
  //       AnimatedBuilder(
  //         animation: _controller,
  //         builder: (context, child) {
  //           return Transform.translate(
  //             offset: Offset(math.cos(angle) * distance * _animation.value,
  //                 math.sin(angle) * distance * _animation.value),
  //             child: IgnorePointer(
  //               ignoring: !isFabOpen,  // Only ignore when FAB is not open
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
  //     alignment: Alignment.center,
  //     children: buttons,
  //   );
  // }

// Widget _buildActionButtons(Size screenSize) {
//     final double distance = 100.0;
//     List<Widget> buttons = [];
//     // Use the start angle calculated based on the FAB's position
//     var details = calculateBestStartAngle(screenSize, position);
//     var overlayDetails = calculateOverlayDetails(screenSize, position, distance);
//
//     double startAngle = details.startAngle;  // Use the calculated start angle
//     double angleIncrement = math.pi / 4; // Modify this to change the spread of buttons
//
//     for (int i = 0; i < FabMode.values.length; i++) {
//       final mode = FabMode.values[i];
//       // Calculate the angle for each button based on the start angle and their index
//       double angle = startAngle + angleIncrement * i;
//
//       buttons.add(
//         AnimatedBuilder(
//           animation: _controller,
//           builder: (context, child) {
//             return Transform.translate(
//               offset: Offset(math.cos(angle) * distance * _controller.value,
//                   math.sin(angle) * distance * _controller.value),
//               child: IgnorePointer(
//                 ignoring: !isFabOpen,
//                 child: FloatingActionButton(
//                   mini: true,
//                   onPressed: isFabOpen ? () => _selectMode(mode) : null,
//                   backgroundColor: _getColorForMode(mode),
//                   child: _getIconForMode(mode),
//                 ),
//               ),
//             );
//           },
//         ),
//       );
//     }
//
//     return Stack(
//       children: [
//         // top left quadrant ignore pointer
//        Positioned.fromRect(
//          rect: Rect.fromLTWH(overlayDetails.offset.dx, overlayDetails.offset.dy, overlayDetails.width, overlayDetails.height),
//          child: IgnorePointer(
//                 ignoring: !isFabOpen,
//                 child: Container(
//                   width: overlayDetails.width,
//                   height: overlayDetails.height,
//                   color: Colors.black.withOpacity(0.5 * _controller.value),
//                 ),
//               ),
//        ),
//
//
//
//         ...buttons
//       ],
//     );
//   }

  Widget _buildActionButtons(Size screenSize) {
    final double distance = 100.0;
    List<Widget> buttons = [];
    var details = calculateBestStartAngle(screenSize, position);
    var overlayDetails = calculateOverlayDetails(screenSize, position, distance);

    double startAngle = details.startAngle;
    double angleIncrement = math.pi / 4;

    for (int i = 0; i < FabMode.values.length; i++) {
      final mode = FabMode.values[i];
      double angle = startAngle + angleIncrement * i;

      buttons.add(
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(math.cos(angle) * distance * _controller.value,
                  math.sin(angle) * distance * _controller.value),
              child: IgnorePointer(
                ignoring: !isFabOpen,
                child: FloatingActionButton(
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

    return Stack(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            double containerWidth = max(56, overlayDetails.width * _controller.value);
            double containerHeight = max(56, overlayDetails.height * _controller.value);

            // Adjust the position based on the start angle and quadrant
            double offsetX = startAngle == math.pi || startAngle == (3 * math.pi / 2) ?
            position.dx - containerWidth : position.dx;
            double offsetY = startAngle == (3 * math.pi / 2) || startAngle == (2 * math.pi) ?
            position.dy - containerHeight : position.dy;

            return IgnorePointer(
              ignoring: !isFabOpen,
              child: Container(
                width: containerWidth,
                height: containerHeight,
                color: Colors.black.withOpacity(0.5 * _controller.value),
                transform: Matrix4.translationValues(offsetX, offsetY, 0.0),
              ),
            );
          },
        ),
        ...buttons
      ],
    );
  }



  // Widget buildQuadrantIgnorePointer(Quadrant quadrant, FabExpansionDetails details, double containerSize, Size screenSize) {
  //   bool isActive = determineActiveQuadrant(details.startAngle) == quadrant;
  //   return Positioned(
  //     left: (quadrant == Quadrant.topRight || quadrant == Quadrant.bottomRight) ? screenSize.width / 2 : 0,
  //     top: (quadrant == Quadrant.bottomLeft || quadrant == Quadrant.bottomRight) ? screenSize.height / 2 : 0,
  //     child: IgnorePointer(
  //       ignoring: !isActive || !isFabOpen,  // Ensure it's active only when FAB is open and it's the correct quadrant
  //       child: Opacity(
  //         opacity: isActive ? 1.0 : 0.0,  // Make inactive quadrants fully transparent
  //         child: Container(
  //           width: screenSize.width / 2,
  //           height: screenSize.height / 2,
  //           color: isActive ? Colors.black45 : Colors.transparent,  // Use transparent color for inactive quadrants
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget buildQuadrantIgnorePointer(Quadrant quadrant, FabExpansionDetails details, double containerSize, Size screenSize) {
    bool isActive = determineActiveQuadrant(details.startAngle) == quadrant;
    // Adjust the size of the IgnorePointer containers to prevent them from covering the FAB.
    double adjustedWidth = screenSize.width / 2 - (isActive ? 0 : 100 / 2);
    double adjustedHeight = screenSize.height / 2 - (isActive ? 0 : 100 / 2);

    return Positioned(
      left: (quadrant == Quadrant.topRight || quadrant == Quadrant.bottomRight) ? screenSize.width / 2 : 0,
      top: (quadrant == Quadrant.bottomLeft || quadrant == Quadrant.bottomRight) ? screenSize.height / 2 : 0,
      child: IgnorePointer(
        ignoring: !isActive || !isFabOpen,
        child: Opacity(
          opacity: isActive ? 1.0 : 0.0,
          child: Container(
            width: adjustedWidth,
            height: adjustedHeight,
            color: isActive ? Colors.black45 : Colors.transparent,
          ),
        ),
      ),
    );
  }

  Quadrant determineActiveQuadrant(double startAngle) {
    if (startAngle == math.pi * 2) return Quadrant.topLeft;
    if (startAngle == 3 * math.pi / 2) return Quadrant.topRight;
    if (startAngle == math.pi / 2) return Quadrant.bottomLeft;
    if (startAngle == math.pi) return Quadrant.bottomRight;
    return Quadrant.topLeft; // Default case
  }

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



