import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../../Functions/Providers/pen_options_provider.dart';



class EraserSettings extends StatefulWidget {
  final PointerMode initialMode;
  final Function(PointerMode) onModeChanged;
  final Function() clearAllStrokes;
  final Function() clearAllPins;
  final Function() clearAllTextBoxes;

  const EraserSettings({
    required this.initialMode,
    required this.onModeChanged,
    required this.clearAllStrokes,
    required this.clearAllPins,
    required this.clearAllTextBoxes,
    Key? key,
  }) : super(key: key);

  @override
  _EraserSettingsState createState() => _EraserSettingsState();
}

class _EraserSettingsState extends State<EraserSettings> {
  EraserMode _currentMode = EraserMode.objectEraser;
@override
void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

    Row(
      children: [

     Text('Eraser Size:'),
      const SizedBox(width: 10),
      Slider(
        min: 10.0, // Minimum eraser size
        max: 200.0, // Maximum eraser size
        value: Provider.of<EraserOptionsProvider>(context).size,
        onChanged: (double newSize) {
          Provider.of<EraserOptionsProvider>(context, listen: false).updateSize(newSize);
          },
      ),
      ],
    ),
        CupertinoSlidingSegmentedControl<EraserMode>(
          children: const <EraserMode, Widget>{
            EraserMode.objectEraser: Text('Object Eraser'),
            EraserMode.pointEraser: Text('Point Eraser'),
            // EraserMode.transparency: Text('Transparency'),
          },
          groupValue: Provider.of<EraserOptionsProvider>(context).currentEraserMode,
          onValueChanged: (EraserMode? value) {
            if (value != null) {
              Provider.of<EraserOptionsProvider>(context, listen: false).updateEraserMode(value);
              setState(() {
                _currentMode = value;
              });
            }
          },
        ),
        const SizedBox(height: 20),
        // expalantion of the eraser mode
        Container(

          height: 100,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey,width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _getModeSettings(_currentMode),
                ),
              ),

            ],
          ),
        ),
        const SizedBox(height: 20),
       // container for both erase all strokes and erase all pins
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey,width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: widget.clearAllStrokes,
                child: const Text('Erase All Strokes'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: widget.clearAllPins,
                child: const Text('Erase All Pins'),
              ),
              ElevatedButton(
                  onPressed: widget.clearAllTextBoxes,
                  child: const Text('Remove All Text Boxes'),)
            ],
          ),
        ),
      ],
    );
  }

  Widget _getModeSettings(EraserMode mode) {
  List<TextSpan> explanation;
  switch (mode) {
    case EraserMode.objectEraser:
      explanation = [
        TextSpan(text: 'Object Eraser: ', style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
        TextSpan(text: 'This mode will erase the entire object when you touch any part of it. '),

      ];
      break;
    case EraserMode.pointEraser:
      explanation = [
        TextSpan(text: 'Point Eraser: ', style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
        TextSpan(text: 'This mode will erase only the points you touch. '),
        // TextSpan(text: '👆', style: TextStyle(fontSize: 24)),
      ];
      break;
    case EraserMode.transparency:
      explanation = [
        TextSpan(text: 'Transparency: ', style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
        TextSpan(text: 'This mode will make the touched points transparent. '),
        // TextSpan(text: '👆', style: TextStyle(fontSize: 24)),
      ];
      break;
    default:
      explanation = [TextSpan(text: 'Select an eraser mode to see its explanation here.')];
  }
  return Container(
    key: ValueKey<EraserMode>(mode),
    padding: const EdgeInsets.all(10),
    child: RichText(
      text: TextSpan(
        children: explanation,
        style: TextStyle(color: Colors.black, fontSize: 16),
      ),
    ),
  );
}
}


