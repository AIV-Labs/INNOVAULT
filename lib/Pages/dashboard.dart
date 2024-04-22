
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:innovault/Components/CustomPressueSensitiveWidgets/CanvasRefactored/aiv_canvas.dart';
import 'package:innovault/Functions/Providers/canvas_provider.dart';
import 'package:provider/provider.dart';

import '../Functions/Providers/multi_view_provider.dart';






class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: AIVCanvas(
            // Pass other properties of selectedCanvas to AIVCanvas as needed
          ),
        ),
      ],
    );
  }
}
