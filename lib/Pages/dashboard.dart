
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:innovault/Components/CustomPressueSensitiveWidgets/CanvasRefactored/aiv_canvas.dart';






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
         Positioned.fill( child: AIVCanvas( imagePath: 'assets/CF_bodymodel/female/woman_front_face.png',)),


      ],
    );
  }
}
