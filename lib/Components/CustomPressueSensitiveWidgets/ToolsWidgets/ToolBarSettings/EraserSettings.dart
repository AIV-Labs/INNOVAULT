import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

enum EraserMode { objectEraser, pointEraser, transparency }

class EraserSettings extends StatefulWidget {
  final EraserMode initialMode;
  final Function(EraserMode) onModeChanged;
  final Function() clearAllStrokes;
  final Function() clearAllPins;

  const EraserSettings({
    required this.initialMode,
    required this.onModeChanged,
    required this.clearAllStrokes,
    required this.clearAllPins,
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
    EraserMode _currentMode = widget.initialMode;
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CupertinoSlidingSegmentedControl<EraserMode>(
          children: const <EraserMode, Widget>{
            EraserMode.objectEraser: Text('Object Eraser'),
            EraserMode.pointEraser: Text('Point Eraser'),
            EraserMode.transparency: Text('Transparency'),
          },
          groupValue: _currentMode,
          onValueChanged: (EraserMode? value) {
            if (value != null) {
              setState(() {
                _currentMode = value;
              });
            }
          },
        ),
        const SizedBox(height: 20),
        Container(
          width: 150,
          height: 150,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey,width: 2),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _getModeSettings(_currentMode),
                ),
              ),
              Positioned.fill(child: Placeholder())
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () {
           widget.clearAllStrokes();
          },
          child: const Text('Clear All Strokes'),
        ),
        ElevatedButton(
          onPressed: () {
           widget.clearAllPins();
          },
          child: const Text('Clear All Pins'),
        ),
      ],
    );
  }

  Widget _getModeSettings(EraserMode mode) {
    Color color;
    switch (mode) {
      case EraserMode.objectEraser:
        color = Colors.red;
        break;
      case EraserMode.pointEraser:
        color = Colors.green;
        break;
      case EraserMode.transparency:
        color = Colors.blue;
        break;
    }
    return Container(
      key: ValueKey<EraserMode>(mode),
      width: 100,
      height: 100,
      color: color,
    );
  }
}