
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../Functions/Providers/pen_options_provider.dart';
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