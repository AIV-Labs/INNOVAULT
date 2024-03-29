import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../../Functions/Providers/pen_options_provider.dart';
class PinSettings extends StatefulWidget {
  @override
  _PinSettingsState createState() => _PinSettingsState();
}

class _PinSettingsState extends State<PinSettings> {

  @override
  Widget build(BuildContext context) {

    return Consumer<PinOptionsProvider>(
        builder: (context, pinOptionsProvider, child) {
        return Column(
          children: [

            // Size slider
            Row(
              children: [
                Flexible(child: const Text('Size '),),
                Flexible(
                  flex: 5,
                  child: Slider(
                    // round and remove one 0 digit from the right
                    label: (pinOptionsProvider.size /10 ).toStringAsFixed(0),
                    min: 1.0,
                    max: 10.0,
                    divisions: 9,

                    value: pinOptionsProvider.size /10,
                    onChanged: (value) {
                      pinOptionsProvider.updateSize(value*10);
                    },
                  ),
                ),
              ],
            ),


            // Shapes grid
            Row(
              children: [
                Flexible(child: Container(
                  height: 40,
                  width: 40,
                  padding: const EdgeInsets.all(5),

                  child: ShapeMaker(
                    color: pinOptionsProvider.color,
                      shapeType: PinShape.values.firstWhere((shape) => shape.toString() == pinOptionsProvider.shape.toString())),
                )),
const SizedBox(width: 10),
                Flexible(
                  flex: 5,
                  child: Container(
                    height: 120,
                    width: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey,width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: GridView.count(
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 10,
                      crossAxisCount: 4,
                      children: PinShape.values.map((shape){
                        return GestureDetector(
                          onTap: () {
                            pinOptionsProvider.updateShape(shape);
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: ShapeMaker(shapeType: shape, color: pinOptionsProvider.color))
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // color picker
            Row(

              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                // chosen color
                Container(
                  decoration: BoxDecoration(
                    color: pinOptionsProvider.color,
                    border: Border.all(
                      color: Colors.black26,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: 30,
                  width: 30,
                  padding: const EdgeInsets.all(10),

                ),
                const SizedBox(width: 20),
                // color picker
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(10),


                  ),
                  height: 100,
                  width: 250,
                  padding: EdgeInsets.all(10),
                  child: PinColorPicker(),),
              ],
            ),
          ],
        );
      }
    );
  }
}



class ShapeMaker extends StatelessWidget {
  final PinShape shapeType;
final Color color;
  ShapeMaker({required this.shapeType,required this.color});

  @override
  Widget build(BuildContext context) {
    switch (shapeType) {
      case PinShape.circle_filled:
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,

          ),
        );
      case PinShape.circle_stroke:
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color,width: 2),

          ),
        );


      case PinShape.square_filled:
        return Container(

          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        );

      case PinShape.square_stroke:
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: color,width: 2),
            borderRadius: BorderRadius.circular(2),

          ),
        );

      case PinShape.triangle_filled:
        return CustomPaint(
          painter: TrianglePainter(color: color, paintingStyle: PaintingStyle.fill),
        );
      case PinShape.triangle_stroke:
        return CustomPaint(
          painter: TrianglePainter(color: color, paintingStyle: PaintingStyle.stroke),
        );
      case PinShape.hexagon_filled:
        return CustomPaint(
          painter: HexagonPainter(color: color, paintingStyle: PaintingStyle.fill),
        );
      case PinShape.hexagon_stroke:
        return CustomPaint(
          painter: HexagonPainter(color: color, paintingStyle: PaintingStyle.stroke),
        );
      default:
        return Container();
    }
  }
}
class TrianglePainter extends CustomPainter {
  final Color color;
  final PaintingStyle paintingStyle;

  TrianglePainter({required this.color, required this.paintingStyle});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = paintingStyle
      ..strokeWidth = 2.0;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(TrianglePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
class HexagonPainter extends CustomPainter {
  final Color color;
  final PaintingStyle paintingStyle;

  HexagonPainter({required this.color, required this.paintingStyle});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = paintingStyle
      ..strokeWidth = 2.0;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height / 4);
    path.lineTo(size.width, 3 * size.height / 4);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(0, 3 * size.height / 4);
    path.lineTo(0, size.height / 4);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(HexagonPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}


class PinColorPicker extends StatelessWidget {
  final List<Color> defaultColors = [
    Colors.black,
    Color(0xFF0b090a),
    Color(0xFF161a1d),
    Color(0xFF001427),
    Color(0xFF2b2d42),
    Color(0xFF495867),

    Color(0xFFf8f9fa),
    Color(0xFFf2e9e4),
    Color(0xFFced4da),
    Color(0xFFadb5bd),
    Color(0xFFe3d0d8),
    Color(0xFFd6e5e3),


    Colors.red,
    Color(0xFF540b0e),
    Color(0xFFff0000),
    Color(0xFFef233c),
    Color(0xFFbc4749),
    Color(0xFFce4257),

    Colors.green,
    Color(0xFF00ff00),
    Color(0xFF52b788),
    Color(0xFF06a77d),
    Color(0xFF34a0a4),
    Color(0xFF99d98c),



    Colors.blue,
    Color(0xFF03045e),
    Color(0xFF023e8a),
    Color(0xFF0077b6),
    Color(0xFF00b2ca),
    Color(0xFF42bfdd),

    Colors.yellow,
    Color(0xFFfca311),
    Color(0xFFcca43b),
    Color(0xFFfdca40),
    Color(0xFFffe066),
    Color(0xFFffd60a),



  ];

   PinColorPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PinOptionsProvider>(
      builder: (context, pinOptionsProvider, child) {
        return GridView.count(
          crossAxisCount: 6, // Change this number as per your requirement
          padding: EdgeInsets.zero,
          scrollDirection: Axis.vertical,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,

          children: defaultColors.map((color) {
            return GestureDetector(
              onTap: () {
                debugPrint('Color selected: $color');
                pinOptionsProvider.updateColor(color);
              },
              child: Container(
margin: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: pinOptionsProvider.color == color ? [
                    BoxShadow(
                      color: color.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ] : [],
                ),

              ),
            );
          }).toList(),
        );
      },
    );
  }
}