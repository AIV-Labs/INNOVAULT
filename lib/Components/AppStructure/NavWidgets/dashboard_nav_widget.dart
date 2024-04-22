import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../Functions/Providers/canvas_provider.dart';
import '../../../Functions/Providers/multi_view_provider.dart';

class DashboardNavWidget extends StatefulWidget {
  const DashboardNavWidget({super.key});

  @override
  State<DashboardNavWidget> createState() => _DashboardNavWidgetState();
}

class _DashboardNavWidgetState extends State<DashboardNavWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.45,
      child: Consumer<DashboardCanvasProvider>(
        builder: (context, dashboardCanvasProvider, child) {
          if (dashboardCanvasProvider.canvasListProvider.canvases.isEmpty) {
            return  Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Icon(Icons.brush, size: 50), // Replace with your preferred icon
                  const Text("You don't have any saved canvases"),
                  ElevatedButton(
                    onPressed: () {
                      final canvasName = 'Canvas ${dashboardCanvasProvider.canvasListProvider.canvases.length + 1}';
                      final canvasKey = GlobalKey();
                      dashboardCanvasProvider.canvasListProvider.addBlankCanvas(context, canvasName, canvasKey);
                    },
                    child: const Text('Create new canvas'),
                  ),
                ],
              ),
            );
          } else {
            return Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                  flex: 4,
                  child: ListView.builder(
reverse: true,
                    itemCount: dashboardCanvasProvider.canvasListProvider.canvases.length,
                    itemBuilder: (context, index) {
                      final canvas = dashboardCanvasProvider.canvasListProvider.canvases[index];
                      // Replace with your actual canvas display widget
                      return ListTile(
                        style: ListTileStyle.drawer,
                        enableFeedback: true,
                        // selected: dashboardCanvasProvider.selectedCanvas == canvas,
                        title: Text('Canvas ${index + 1}'),
                        onTap: () {
                          dashboardCanvasProvider.changeSelectedCanvas(canvas);
                          // Provider.of<DashboardCanvasProvider>(context,listen: false).switchCanvas(canvas.canvasKey.toString(), context, canvas.canvasKey);
                          Provider.of<CanvasProvider>(context,listen: false).switchCanvasTo(dashboardCanvasProvider.selectedCanvas);

                          debugPrint('Switched to canvas ${index + 1}, ${dashboardCanvasProvider.selectedCanvas.canvasKey}');
                          debugPrint('There are ${dashboardCanvasProvider.canvasListProvider.canvases.length} canvases');
                        },
                      );
                    },
                  ),
                ),
                Flexible(
                  child: ElevatedButton(
                    onPressed: () {
                      final canvasName = 'Canvas ${dashboardCanvasProvider.canvasListProvider.canvases.length + 1}';
                      final canvasKey = GlobalKey();
                      dashboardCanvasProvider.canvasListProvider.addBlankCanvas(context, canvasName, canvasKey);
                      Provider.of<CanvasProvider>(context,listen: false).switchCanvasTo(dashboardCanvasProvider.selectedCanvas);

                    },
                    child: const Text('Create new canvas'),
                  ),
                ),

                const SizedBox(height: 10),
                // button to save current canvas
                Flexible(child: ElevatedButton(
                  onPressed: () {
                    dashboardCanvasProvider.saveCurrentCanvas();
                  },
                  child: const Text('Save current canvas'),
                )),
              ],
            );
          }
        },
      ),
    );
  }
}