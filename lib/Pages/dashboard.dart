
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../Components/CustomPressueSensitiveWidgets/AIV_freehand_multi_tool_canvas.dart';






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
        const Positioned.fill( child: FreehandMultiDrawingCanvas()),


      ],
    );
  }
}
