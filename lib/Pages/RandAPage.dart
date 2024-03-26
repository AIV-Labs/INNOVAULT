import 'package:flutter/material.dart';
import '../Components/AppStructure/UnderContruction.dart';


class RandAPage extends StatefulWidget {
  const RandAPage({super.key});

  @override
  State<RandAPage> createState() => _RandAPageState();
}

class _RandAPageState extends State<RandAPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body:

        Column(
          children: [
            Expanded(child: UnderConstruction()),
            Text('Reports & Analytics Page',),
          ],
        ),

        );
  }
}
