

import 'package:flutter/material.dart';
import 'package:innovault/Functions/Providers/pen_options_provider.dart';
import 'package:provider/provider.dart';
import 'app_state_provider.dart';

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

  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppStateProvider>(
          create: (_) => AppStateProvider(),
        ),
        ChangeNotifierProvider<PenOptionsProvider>(
          create: (_) => PenOptionsProvider(),
        ),
      ],
      child: DrawingOptionsProvider(child: widget.child),
    );
  }
}