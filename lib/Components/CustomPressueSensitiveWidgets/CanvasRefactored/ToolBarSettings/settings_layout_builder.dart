import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../../../Functions/Providers/pen_options_provider.dart';
import '../../notebook_background_painter.dart';
import 'EraserSettings.dart';
import 'PanSettings.dart';
import 'PenSettings.dart';
import 'PinSettings.dart';
import 'TextBoxSettings.dart';

class PenSettingsLayoutBuilder extends StatelessWidget {
  final Function() clearStrokes;
  final Function() clearPins;
  final Function() clearTextBoxes;
  final Function(PointerMode) onModeChanged;
  final ValueListenable<QuillController?>  activeQuillController;

  //pan settings
  final BackgroundType backgroundType;
  final Function(BackgroundType) updateBackgroundType;
  const PenSettingsLayoutBuilder({
    super.key,
    required this.activeQuillController,
    required this.currentMode,
    required this.clearStrokes,
    required this.clearPins,
    required this.onModeChanged,
    required this.clearTextBoxes,
    required this.backgroundType,
    required this.updateBackgroundType,
  });

  final PointerMode currentMode;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) {
          switch (currentMode){
            case PointerMode.pen:
              return const PenSettings();

            case PointerMode.eraser:
              return  EraserSettings(
                initialMode: PointerMode.eraser,
                clearAllStrokes: clearStrokes,
                clearAllPins: clearPins,
                clearAllTextBoxes: clearTextBoxes,
                onModeChanged: onModeChanged,);
            case PointerMode.pin:
              return  PinSettings();
            case PointerMode.none:
              return  PanSettings( backgroundType: backgroundType, updateBackgroundType: updateBackgroundType);

            case PointerMode.textBox:
              return  TextBoxSettings(quillController:activeQuillController);

            default :
              return const Center(child: Text('No mode selected'));

          }
        }
    );
  }
}