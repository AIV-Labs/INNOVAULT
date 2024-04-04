
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';


class TextBoxSettings extends StatefulWidget {
  final ValueListenable<QuillController?> quillController;
  const TextBoxSettings({super.key,required this.quillController});

  @override
  State<TextBoxSettings> createState() => _TextBoxSettingsState();
}

class _TextBoxSettingsState extends State<TextBoxSettings> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<QuillController?>(
      valueListenable: widget.quillController,
      builder: (context, activeController, child) {

      return QuillToolbar.simple(
          configurations: QuillSimpleToolbarConfigurations(
            axis: Axis.horizontal,
            showCodeBlock: true,
            multiRowsDisplay: true,
            showSubscript: false,
            showSuperscript: false,
            sectionDividerSpace: 8,
            controller: activeController!,
            sharedConfigurations: const QuillSharedConfigurations(
              locale: Locale('en'),
            ),
          ));});

  }
}
