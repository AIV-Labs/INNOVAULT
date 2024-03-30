import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../../Functions/Providers/pen_options_provider.dart';

class PenSettings extends StatelessWidget {
  const PenSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PenOptionsProvider>(
      builder: (context, penOptionsProvider, child) {
        return Column(
          children: [
            OptionParameterSlider(
              label: 'Pen Stroke',
              value: penOptionsProvider.currentOptionIndex.toDouble(),
              onChanged: (double value) {
                penOptionsProvider.changePen(value.round());
              },
              onReset: () {
                penOptionsProvider.resetPenOptions();
              },
            min: 0,
            max: penOptionsProvider.defaultPSensOptionsList.length.toDouble()-1,
              divisions: penOptionsProvider.defaultPSensOptionsList.length-1,
            ),
            const SizedBox(height: 10),



            const SizedBox(height: 10),
            // color picker
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                // chosen color
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                      color: penOptionsProvider.currentStrokeStyle.color,
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
                ),
                const SizedBox(width: 10),
                // color picker
                Flexible(
                  flex: 5,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                  
                  
                    ),
                    height: 100,
                    width: 300,
                    padding: EdgeInsets.all(10),
                    child: ColorPicker(),),
                ),
              ],
            ),
            const SizedBox(height: 10),
        // Add more settings here

            Row(children: [
              Text('Pressure Sensitive (BETA)'),
              Checkbox(
                value: Provider.of<PenOptionsProvider>(context).isPressureSensitive,
                onChanged: (bool? value) {
                  Provider.of<PenOptionsProvider>(context, listen: false)
                      .togglePressureSensitivity(value!);
                },
              )
            ],),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child:  AdvancedStrokeOptions(penOptionsProvider: penOptionsProvider),
            ),


          ],
        );
      },
    );
  }

}

class AdvancedStrokeOptions extends StatelessWidget {
  final PenOptionsProvider penOptionsProvider;
  const AdvancedStrokeOptions({
    super.key,
    required this.penOptionsProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Size
        OptionParameterSlider(
          label: 'Stroke Size',
          value: penOptionsProvider.strokeOptions.size,
          onChanged: (double value) {
            penOptionsProvider.updateStrokeSize(value);
          },
          onReset: () {
            penOptionsProvider.updateStrokeSize(penOptionsProvider.defaultPSensOptionsList[penOptionsProvider.currentOptionIndex].size);
          },
        ),
        const SizedBox(height: 10),
        // Sensitivity
        OptionParameterSlider(
          value: penOptionsProvider.strokeOptions.thinning,
          onChanged: (double value) {
            penOptionsProvider.updateStrokeThinning(value);
          },
          onReset: () {
            penOptionsProvider.updateStrokeThinning(penOptionsProvider.defaultPSensOptionsList[penOptionsProvider.currentOptionIndex].thinning);
          },
          label: 'Sensitivity',
          min:0,
          max:1,
          isDecimalValue: true,
        ),
        const SizedBox(height: 10),
        // Assistance (smoothing)
        OptionParameterSlider(
          value: penOptionsProvider.strokeOptions.smoothing,
          onChanged: (double value) {
            penOptionsProvider.updateStrokeSmoothing(value);
          },
          onReset: () {
            penOptionsProvider.updateStrokeSmoothing(penOptionsProvider.defaultPSensOptionsList[penOptionsProvider.currentOptionIndex].smoothing);
          },
          label: 'Assistance',
          min: 0, max: 1,
          isDecimalValue: true,
        ),
        const SizedBox(height: 10),

        // Streamline
        OptionParameterSlider(
          value: penOptionsProvider.strokeOptions.streamline,
          onChanged: (double value) {
            penOptionsProvider.updateStrokeStreamline(value);
          },
          onReset: () {
            penOptionsProvider.updateStrokeStreamline(penOptionsProvider.defaultPSensOptionsList[penOptionsProvider.currentOptionIndex].streamline);
          },
          label: 'Streamline',min:0, max: 1,isDecimalValue: true,),
        // cap and taper start
        const SizedBox(height: 10),
        Row(
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  children: [
                    // Cap
                    Row(
                      children: [
                        Text('Cap '),
                        Switch(
                          value: penOptionsProvider.strokeOptions.start.cap,
                          onChanged: (value) {
                            penOptionsProvider.toggleStrokeStartCap(
                                value
                            );
                          },
                        ),
                      ],
                    ),
                    // Taper toggle
                    Row(
                      children: [
                        Text('Taper'),
                        Switch(
                          value: penOptionsProvider.strokeOptions.start.taperEnabled,
                          onChanged: (value) {
                            penOptionsProvider.toggleStrokeStartTaper(
                                value
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),


            Flexible(
              flex: 3,
              child: OptionParameterSlider(
                value: penOptionsProvider.strokeOptions.start.customTaper??1,
                onChanged: (value) {
                  penOptionsProvider.updateStrokeStartTaper(
                      value
                  );
                },
                onReset: () {
                  penOptionsProvider.updateStrokeStartTaper(
                      penOptionsProvider.defaultPSensOptionsList[penOptionsProvider.currentOptionIndex].start.customTaper??1
                  );
                },
                label: 'Taper Start',
                min:1, max: 10,),
            )
          ],
        ),

        const SizedBox(height: 10),
        // cap and taper end
        Row(
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  children: [
                    // Cap
                    Row(
                      children: [
                        Text('Cap '),
                        Switch(
                          value: penOptionsProvider.strokeOptions.end.cap,
                          onChanged: (value) {
                            penOptionsProvider.toggleStrokeEndCap(
                                value
                            );
                          },
                        ),
                      ],
                    ),
                    // Taper toggle
                    Row(
                      children: [
                        Text('Taper'),
                        Switch(
                          value: penOptionsProvider.strokeOptions.end.taperEnabled,
                          onChanged: (value) {
                            penOptionsProvider.toggleStrokeEndTaper(
                                value
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),


            Flexible(
              flex: 3,
              child: OptionParameterSlider(
                value: penOptionsProvider.strokeOptions.end.customTaper??1,
                onChanged: (value) {
                  penOptionsProvider.updateStrokeEndTaper(
                      value
                  );
                },
                onReset: () {
                  penOptionsProvider.updateStrokeEndTaper(
                      penOptionsProvider.defaultPSensOptionsList[penOptionsProvider.currentOptionIndex].end.customTaper??1
                  );
                },
                label: 'Taper End',
                min:1, max: 100,),
            )
          ],
        ),

      ],
    );
  }
}

class OptionParameterSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final VoidCallback onReset;
  final String label;
  final double min;
  final double max;
  final bool isDecimalValue;
  final int divisions;
  const OptionParameterSlider({
    super.key,
    required this.value,
    required this.onChanged,
    required this.onReset,
    required this.label,
    this.min = 1.0,
    this.max = 10.0,
    this.isDecimalValue = false,
    this.divisions = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      // label
    Flexible(
        child: FittedBox(fit:BoxFit.scaleDown,child: Text(label))
    ),
            // Slider
            Flexible(
              flex:3,
              child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              label: isDecimalValue? value.toString():value.round().toString() ,
              onChanged: onChanged,
              ),
            ),

            // Reset button
            Flexible(
              child: SizedBox(
    width: 20,
                child: ElevatedButton(
                  // rounded button
                  style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: CircleBorder(),
                          elevation: 5,
                                    ),
                onPressed: onReset,
                child: Icon(Icons.undo_rounded, size: 15,),
                ),
              ),
            ),
            ],
            );
  }
}


class ColorPicker extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    return Consumer<PenOptionsProvider>(
      builder: (context, penOptionsProvider, child) {
        return GridView.count(
          crossAxisCount: 6, // Change this number as per your requirement
          padding: EdgeInsets.zero,
          scrollDirection: Axis.vertical,
          crossAxisSpacing: 5,
          mainAxisSpacing: 15,

          children: defaultColors.map((color) {
            return GestureDetector(
              onTap: () {
                penOptionsProvider.updateStrokeStyle(penOptionsProvider.currentStrokeStyle.copyWith(color: color));
              },
              child: Container(
margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: penOptionsProvider.currentStrokeStyle.color == color ? [
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


