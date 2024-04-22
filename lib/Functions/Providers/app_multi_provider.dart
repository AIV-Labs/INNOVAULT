

import 'package:flutter/material.dart';
import 'package:innovault/Functions/Providers/multi_view_provider.dart';
import 'package:innovault/Functions/Providers/pen_options_provider.dart';
import 'package:innovault/constants.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';
import 'app_state_provider.dart';
import 'canvas_provider.dart';

class AppMultiProvider extends StatefulWidget {
  final Widget child;

  AppMultiProvider({
    super.key,
    required this.child,
  });

  @override
  State<AppMultiProvider> createState() => _AppMultiProviderState();
}
  class _AppMultiProviderState extends State<AppMultiProvider> {
  // late Realm realm;
  //
  // late App app = App(AppConfiguration(("application-0-ejbkn")));

    late Realm realm;
    late GlobalKey canvasKey;

    @override
    void initState() {
      super.initState();
      canvasKey = GlobalKey();
      final config = Configuration.local(realmSchemas);
      realm = Realm(config);
    }

    @override
    void dispose() {
      realm.close(); // Properly close the realm instance when the widget is disposed
      super.dispose();
    }

    @override
  Widget build(BuildContext context) {


    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppStateProvider>(
          create: (_) => AppStateProvider(),
        ),

        ChangeNotifierProvider<TextBoxProvider>(
          create: (_) => TextBoxProvider(),
        ),
        ChangeNotifierProvider<CanvasProvider>(
            create: (_) {
              return CanvasProvider(context: context, canvasKey: canvasKey);
            }
        ),

        // multiviews providers
        ChangeNotifierProvider<CanvasListProvider>(
          create: (_) => CanvasListProvider(realm),
        ),
        ChangeNotifierProvider<DashboardCanvasProvider>(
          create: (_) => DashboardCanvasProvider(
      realm:realm,
      canvasListProvider: Provider.of<CanvasListProvider>(context, listen: false),
      selectedCanvas: Provider.of<CanvasProvider>(context, listen: false))
        ),
        ChangeNotifierProvider<TasksCanvasProvider>(
          create: (_) => TasksCanvasProvider(realm:realm),
        ),
        ChangeNotifierProvider<VaultCanvasProvider>(
          create: (_) => VaultCanvasProvider(realm:realm),
        ),

      ],
      child: widget.child,
    );
  }
}

// TEst
// return MultiProvider(
// providers: [
// ChangeNotifierProvider<AppStateProvider>(
// create: (_) => AppStateProvider(),
// ),
//
// ChangeNotifierProvider<TextBoxProvider>(
// create: (_) => TextBoxProvider(),
// ),
// ChangeNotifierProvider<CanvasProvider>(
// create: (_) {
// return newCanvasProvider;
// }
// ),
//
// // multiviews providers
// ChangeNotifierProvider<CanvasListProvider>(
// create: (_) => canvasListProvider,
// ),
// ChangeNotifierProvider<DashboardCanvasProvider>(
// create: (_) => DashboardCanvasProvider(
// realm:realm,
// canvasListProvider: canvasListProvider,
// selectedCanvas: newCanvasProvider),
// ),
// ChangeNotifierProvider<TasksCanvasProvider>(
// create: (_) => TasksCanvasProvider(realm:realm),
// ),
// ChangeNotifierProvider<VaultCanvasProvider>(
// create: (_) => VaultCanvasProvider(realm:realm),
// ),
//
// ],
// child: widget.child,
// );