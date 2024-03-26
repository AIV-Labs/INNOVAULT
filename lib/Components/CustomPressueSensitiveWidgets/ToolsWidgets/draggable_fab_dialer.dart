import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

enum FabMode { pen, eraser, brush }

class DraggableFabDialer extends StatefulWidget {
  final ValueChanged<FabMode> onModeChange;

  DraggableFabDialer({required this.onModeChange});

  @override
  _DraggableFabDialerState createState() => _DraggableFabDialerState();
}

class _DraggableFabDialerState extends State<DraggableFabDialer> {
  double xPosition = 10;
  double yPosition = 50;
  FabMode currentMode = FabMode.pen;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (tapInfo) {
        setState(() {
          xPosition += tapInfo.delta.dx;
          yPosition += tapInfo.delta.dy;
        });
      },

        child: ExpandableFab(
        // key: _key,
        // duration: const Duration(milliseconds: 500),
        // distance: 200.0,
        // type: ExpandableFabType.up,
        // pos: ExpandableFabPos.left,
        // childrenOffset: const Offset(0, 20),
        // fanAngle: 40,
        // openButtonBuilder: RotateFloatingActionButtonBuilder(
        //   child: const Icon(Icons.abc),
        //   fabSize: ExpandableFabSize.large,
        //   foregroundColor: Colors.amber,
        //   backgroundColor: Colors.green,
        //   shape: const CircleBorder(),
        //   angle: 3.14 * 2,
        // ),
        // closeButtonBuilder: FloatingActionButtonBuilder(
        //   size: 56,
        //   builder: (BuildContext context, void Function()? onPressed,
        //       Animation<double> progress) {
        //     return IconButton(
        //       onPressed: onPressed,
        //       icon: const Icon(
        //         Icons.check_circle_outline,
        //         size: 40,
        //       ),
        //     );
        //   },
        // ),
        overlayStyle: ExpandableFabOverlayStyle(
        // color: Colors.black.withOpacity(0.5),
        blur: 5,
        ),
        onOpen: () {
        debugPrint('onOpen');
        },
        afterOpen: () {
        debugPrint('afterOpen');
        },
        onClose: () {
        debugPrint('onClose');
        },
        afterClose: () {
        debugPrint('afterClose');
        },
        children: [
        FloatingActionButton.small(
        // shape: const CircleBorder(),
        heroTag: null,
        child: const Icon(Icons.edit),
        onPressed: () {
        const SnackBar snackBar = SnackBar(
        content: Text("SnackBar"),
        );
        // scaffoldKey.currentState?.showSnackBar(snackBar);
        },
        ),
        FloatingActionButton.small(
        // shape: const CircleBorder(),
        heroTag: null,
        child: const Icon(Icons.search),
        onPressed: () {

        // MaterialPageRoute(builder: ((context) => const NextPage())));
        },
        ),
        FloatingActionButton.small(
        // shape: const CircleBorder(),
        heroTag: null,
        child: const Icon(Icons.share),
        onPressed: () {    },
        ),
        ],
        ),
        );
    } }

// /v1
        // child: ExpandableFab(
        //   distance: 112.0,
        //   children: [
        //     FloatingActionButton.small(
        //       onPressed: () {
        //         setState(() {
        //           currentMode = FabMode.pen;
        //         });
        //         widget.onModeChange(FabMode.pen);
        //       },
        //       child: const Icon(Icons.brush),
        //     ),
        //     FloatingActionButton.small(
        //       onPressed: () {
        //         setState(() {
        //           currentMode = FabMode.brush;
        //         });
        //         widget.onModeChange(FabMode.brush);
        //       },
        //       child: const Icon(Icons.format_color_fill),
        //     ),
        //     FloatingActionButton.small(
        //       onPressed: () {
        //         setState(() {
        //           currentMode = FabMode.eraser;
        //         });
        //         widget.onModeChange(FabMode.eraser);
        //       },
        //       child:  Icon(Icons.phonelink_erase_rounded),
        //     ),
        //   ],
        // ),
//       ),
//     );
//   }
// }