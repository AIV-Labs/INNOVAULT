import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

class Toolbar extends StatelessWidget {
  const Toolbar({
    super.key,
    required this.options,
    required this.updateOptions,
    required this.clear,
  });

  final StrokeOptions options;
  final void Function(void Function()) updateOptions;
  final void Function() clear;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      right: 0,
      width: 200,
      child: Card(
        margin: const EdgeInsets.all(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                'Size',
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              Slider(
                value: options.size,
                min: 1,
                max: 50,
                divisions: 100,
                label: options.size.round().toString(),
                onChanged: (double value) => {
                  updateOptions(() {
                    options.size = value;
                  })
                },
              ),
              const Text(
                'Thinning',
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              Slider(
                value: options.thinning,
                min: -1,
                max: 1,
                divisions: 100,
                label: options.thinning.toStringAsFixed(2),
                onChanged: (double value) => {
                  updateOptions(() {
                    options.thinning = value;
                  })
                },
              ),
              const Text(
                'Streamline',
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              Slider(
                value: options.streamline,
                min: 0,
                max: 1,
                divisions: 100,
                label: options.streamline.toStringAsFixed(2),
                onChanged: (double value) => {
                  updateOptions(() {
                    options.streamline = value;
                  })
                },
              ),
              const Text(
                'Smoothing',
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              Slider(
                value: options.smoothing,
                min: 0,
                max: 1,
                divisions: 100,
                label: options.smoothing.toStringAsFixed(2),
                onChanged: (double value) => {
                  updateOptions(() {
                    options.smoothing = value;
                  })
                },
              ),
              const Text(
                'Taper Start',
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              // Slider(
              //   value: options.start.customTaper!,
              //   min: 0,
              //   max: 100,
              //   divisions: 100,
              //   // options.start.customTaper! can be null
              //   label: options.start.customTaper!.toStringAsFixed(2),
              //   onChanged: (double value) => {
              //     updateOptions(() {
              //       options.start.customTaper = value;
              //     })
              //   },
              // ),
              const Text(
                'Taper End',
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              // Slider(
              //   value: options.end.customTaper!,
              //   min: 0,
              //   max: 100,
              //   divisions: 100,
              //   label: options.end.customTaper!.toStringAsFixed(2),
              //   onChanged: (double value) => {
              //     updateOptions(() {
              //       options.end.customTaper = value;
              //     })
              //   },
              // ),
              const Text(
                'Clear',
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              IconButton(
                icon: const Icon(Icons.replay),
                onPressed: clear,
              ),
            ],
          ),
        ),
      ),
    );
  }
}




class UserToolbar extends StatelessWidget {
  const UserToolbar({
    super.key,
    required this.options,
    required this.updateOptions,
    required this.clear,
    required this.changeColor,
    required this.isEraserActive,
    required this.toggleEraser,
  });

  final StrokeOptions options;
  final void Function(void Function()) updateOptions;
  final void Function() clear;
  final void Function(Color color) changeColor;
  final bool isEraserActive;
  final void Function() toggleEraser;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      right: 0,
      width: 200,
      child: Card(
        margin: const EdgeInsets.all(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Size Slider
              const Text(
                'Size',
                textAlign: TextAlign.start,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              Slider(
                value: options.size,
                min: 1,
                max: 50,
                divisions: 49,
                label: options.size.round().toString(),
                onChanged: (double value) => {
                  updateOptions(() {
                    options.size = value;
                  })
                },
              ),
              // Color Picker
              const Text(
                'Color',
                textAlign: TextAlign.start,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              IconButton(
                icon: const Icon(Icons.color_lens),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Pick a color'),
                        content: SingleChildScrollView(
                          child: BlockPicker(
                            pickerColor: Colors.black, // Default color
                            onColorChanged: changeColor,
                          ),
                        ),
                        actions: <Widget>[
                          ElevatedButton(
                            child: const Text('Close'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              // Eraser Toggle
              SwitchListTile(
                title: const Text(
                  'Eraser',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                value: isEraserActive,
                onChanged: (bool value) {
                  toggleEraser();
                },
              ),
              // Clear Button
              ElevatedButton(
                onPressed: clear,
                child: const Text('Clear'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
