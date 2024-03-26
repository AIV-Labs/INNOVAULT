import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

enum FabMode { pen, eraser, brush }

class DraggableFab extends StatefulWidget {
  final ValueChanged<FabMode> onModeChange;

  DraggableFab({required this.onModeChange});

  @override
  _DraggableFabState createState() => _DraggableFabState();
}

class _DraggableFabState extends State<DraggableFab> with SingleTickerProviderStateMixin {
  double xPosition = 50;
  double yPosition = 50;
  FabMode currentMode = FabMode.pen;
  bool isFabOpen = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: yPosition,
      left: xPosition,
      child: GestureDetector(
        onPanUpdate: (tapInfo) {
          setState(() {
            isFabOpen = false;
            xPosition += tapInfo.delta.dx;
            yPosition += tapInfo.delta.dy;
          });
        },
        onTap: () {
          if (isFabOpen) {
            _controller.reverse();
          } else {
            _controller.forward();
          }
          isFabOpen = !isFabOpen;
        },
        child:  AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Action buttons
              if (isFabOpen) ...[
                _buildActionButton(FabMode.pen, pi / 4), // 45 degrees
                _buildActionButton(FabMode.eraser, pi / 2), // 90 degrees
                _buildActionButton(FabMode.brush, 3 * pi / 4), // 135 degrees
              ],
              // Main FAB
              Transform.scale(
                scale: _scaleAnimation.value,
                child: FloatingActionButton(
                  onPressed: () {
                    if (_controller.isDismissed) {
                      _controller.forward();
                    } else {
                      _controller.reverse();
                    }
                  },
                  child: _getIconForMode(currentMode),
                  backgroundColor: _getColorForMode(currentMode),
                ),
              ),
            ],
          );
        },
      ),
    ),
    );
  }

  Widget _buildActionButton(FabMode mode, double angle) {
    double offsetX = cos(angle) * 100; // Adjust distance to suit your design
    double offsetY = sin(angle) * 100; // Adjust distance to suit your design

    return Transform.translate(
      offset: Offset(offsetX, offsetY),
      child: FloatingActionButton(
        mini: true,
        onPressed: () {
          setState(() {
            currentMode = mode;
            widget.onModeChange(mode);
            _controller.reverse();
          });
        },
        backgroundColor: _getColorForMode(mode),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black,
          ),
          child: _getIconForMode(mode),
        ),
      ),
    );
  }



  Icon _getIconForMode(FabMode mode) {
    switch (mode) {
      case FabMode.pen:
        return Icon(Icons.edit);
      case FabMode.eraser:
        return Icon(Icons.deblur);
      case FabMode.brush:
        return Icon(Icons.brush);
      default:
        return Icon(Icons.edit);
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
        return Colors.blue;
    }
  }
}