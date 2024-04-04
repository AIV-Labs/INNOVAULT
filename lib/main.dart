import 'package:flutter/material.dart';
import 'package:innovault/Components/AppStructure/app_frame.dart';
import 'package:innovault/Functions/Providers/app_multi_provider.dart';

void main() {
  runApp(AppMultiProvider(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Innovault Demo',

      home: const AppFrame(),
    );
  }
}
