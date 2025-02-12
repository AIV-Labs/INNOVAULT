import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:innovault/Functions/Providers/canvas_provider.dart';
import 'package:provider/provider.dart';

import '../../../AppStructure/UnderContruction.dart';
import 'package:innovault/constants.dart';

import '../notebook_background_painter.dart';
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

              Flexible(
                flex: 5,
                child: Container(

                  height: 300,
                  width: 420,
                  padding: EdgeInsets.all(10),
                  child: BackgroundColorPicker(),),
              ),

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


class BackgroundColorPicker extends StatefulWidget {
  const BackgroundColorPicker({super.key});

  @override
  State<BackgroundColorPicker> createState() => _BackgroundColorPickerState();
}

class _BackgroundColorPickerState extends State<BackgroundColorPicker> {

  String selectedColorMode = 'bgColor';
  void changeColorMode(int i) {
    if (i == 0) {
      setState(() {
        selectedColorMode = 'bgColor';
      });
    } else {
      setState(() {
        selectedColorMode = 'lineColor';
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<CanvasProvider>(
        builder: (context, textBoxProvider, child) {
          Color bgColor = Provider.of<CanvasProvider>(context, listen: false).backgroundColor;
          Color lineColor = Provider.of<CanvasProvider>(context, listen: false).backgroundLinesColor;


          return Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              // carousel to switch between modes of color selection
              SizedBox(
                width: 93,
                height: 100,
                child: Column(
                  children: [
                    // change mode
                    Flexible(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          // back icon
                          SizedBox(
                              width: 20,
                              child: Visibility(
                                  visible: selectedColorMode == 'lineColor',
                                  child: Icon(EvaIcons.arrow_left, size : 20, color: Colors.black))),


                          Flexible(
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: PageView(
reverse: true,
                                pageSnapping: true,
                                onPageChanged: (int page) => changeColorMode(page),
                                children: <Widget>[
                                Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),),
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: lineColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),),
                                ],
                              ),
                            ),
                          ),

                          // forward icon
                          SizedBox(
                              width: 20,
                              child: Visibility(
                                  visible: selectedColorMode == 'bgColor',
                                  child: Icon(EvaIcons.arrow_right, size : 20, color: Colors.black))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // text selected mode
                    Flexible(
                      child: Text(
                        selectedColorMode == 'bgColor' ? 'Background Color' : 'Lines Color',
                        textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: GridView.count(
                    crossAxisCount: 6,
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.vertical,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 15,
                    children: defaultColorsList.map((color) {
                      return GestureDetector(
                        onTap: () {
                         if (selectedColorMode == 'bgColor') {
                           textBoxProvider.changeBackgroundColor(color);
                         } else {
                           textBoxProvider.changeBackgroundLinesColor(color);
                         }
                        },
                        child: Container(
                          margin: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow:  (selectedColorMode =='bgColor'&& bgColor == color) ||
                                (selectedColorMode == 'lineColor'&& lineColor == color)? [
                              BoxShadow(
                                color: color.withOpacity(0.8),
                                spreadRadius: 1,
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ] : [],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          );
        }
    );
  }
}


