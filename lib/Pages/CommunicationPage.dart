import 'package:flutter/material.dart';

import '../Components/AppStructure/UnderContruction.dart';


class CommunicationPage extends StatefulWidget {
  const CommunicationPage({super.key});

  @override
  State<CommunicationPage> createState() => _CommunicationPageState();
}

class _CommunicationPageState extends State<CommunicationPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body:Column(
        children: [
          Expanded(child: UnderConstruction()),
          Text('Communication Page',),
        ],
      ),

    );
  }
}
