import 'package:flutter/material.dart';

import '../../../AppStructure/UnderContruction.dart';
import '../../CanvasRefactored/notebook_background_painter.dart';

class PanSettings extends StatefulWidget {
  final BackgroundType backgroundType;
  final Function updateBackgroundType;

  const PanSettings({super.key, required this.backgroundType, required this.updateBackgroundType});

  @override
  State<PanSettings> createState() => _PanSettingsState();
}

class _PanSettingsState extends State<PanSettings> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          height: 500,
          width: 500,
          child: Column(

            children: [
              // background change options grid view of 4 containers with child of NotebookBackgroundPainter
              Container(
                height: 200,
                width: 400,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: GridView(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                  children:  [
                    TaggedContainer(
                      title: 'Grid',
                      changeFunction: () {
                        widget.updateBackgroundType(BackgroundType.grid);
                      },
                      child: CustomPaint(
                        size: Size(20, 20),
                        painter: NotebookBackgroundPainter(backgroundType: BackgroundType.grid),
                      ),
                    ),
                    TaggedContainer(
                      title: 'Horizontal Lines',
                      changeFunction: () {
                        widget.updateBackgroundType(BackgroundType.horizontalLines);
                      },
                      child: CustomPaint(
                        size: Size(20, 20),
                        painter: NotebookBackgroundPainter(backgroundType: BackgroundType.horizontalLines),
                      ),
                    ),
                    TaggedContainer(
                      title: 'Vertical Lines',
                      changeFunction: () {
                        widget.updateBackgroundType(BackgroundType.verticalLines);
                      },
                      child: CustomPaint(
                        size: Size(20, 20),
                        painter: NotebookBackgroundPainter(backgroundType: BackgroundType.verticalLines),
                      ),
                    ),

                    TaggedContainer(
                      title: 'Color',
                      changeFunction: () {
                        widget.updateBackgroundType(BackgroundType.color);
                      },
                      child: CustomPaint(
                        size: Size(20, 20),
                        painter: NotebookBackgroundPainter(backgroundType: BackgroundType.color, bgColor: Colors.blueGrey),
                      ),
                    ),

                    TaggedContainer(
                      title: 'None',
                      changeFunction: () {

                        widget.updateBackgroundType(BackgroundType.none);
                      },
                      child: CustomPaint(
                        size: Size(20, 20),
                        painter: NotebookBackgroundPainter(backgroundType: BackgroundType.none),
                      ),
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 20),

              // text with heading 1 style saying : "Pan Settings"
              Flexible(
                child: Text(
                  'Pan Settings',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 20),
              Flexible(child: UnderConstruction()),

            ],
          ),
        ),
      ),
    );
  }
}

class TaggedContainer extends StatelessWidget {
  String title;
  Function changeFunction;
  Widget child;
  TaggedContainer({required this.title, required this.changeFunction, required this.child});

  @override
  Widget build(BuildContext context) {
    // tooltip with container
    return Tooltip(
      message: title,
        child: GestureDetector(
          onTap: () {

            changeFunction();
          },
          child: Container(
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blueGrey,width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
          child: ClipRRect(
            borderRadius: title.toLowerCase() == 'color'? BorderRadius.circular(10): BorderRadius.circular(0),
              child: child),),
        ));
  }
}

