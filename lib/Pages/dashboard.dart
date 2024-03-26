
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:innovault/Components/CustomPressueSensitiveWidgets/freehand_painter_v12.dart';

import '../Components/CustomPressueSensitiveWidgets/ToolsWidgets/AI_draggable_fab.dart';
// import '../Components/CustomPressueSensitiveWidgets/ToolsWidgets/AIV_draggable_Fab.dart';


class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  FabMode currentMode = FabMode.pen;

  void handleModeChange(FabMode mode) {
    setState(() {
      currentMode = mode;
    });
    // Handle your logic here for when the mode is changed
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill( child: FreehandDrawingCanvas()),
        DraggableFab(onModeChange: handleModeChange, currentMode: currentMode),

      ],
    );
  }
}
