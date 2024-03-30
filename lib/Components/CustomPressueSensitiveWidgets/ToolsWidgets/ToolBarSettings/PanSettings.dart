import 'package:flutter/material.dart';

import '../../../AppStructure/UnderContruction.dart';

class PanSettings extends StatefulWidget {
  const PanSettings({super.key});

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

              // text with heading 1 style saying : "Pan Settings"
              Flexible(
                child: Text(
                  'Pan Settings',
                  style: Theme.of(context).textTheme.headline5,
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
