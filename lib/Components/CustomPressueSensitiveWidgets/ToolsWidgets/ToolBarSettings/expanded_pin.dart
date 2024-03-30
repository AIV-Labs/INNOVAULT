


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../Functions/Providers/pen_options_provider.dart';

class ExpandedPin extends StatefulWidget {
  final Pin pin;

  const ExpandedPin({
    required this.pin,
  });

  @override
  State<ExpandedPin> createState() => _ExpandedPinState();
}

class _ExpandedPinState extends State<ExpandedPin> {
  int selectedEventIndex = 0;
  String content = '';
  @override
  void initState() {

    super.initState();
    if (widget.pin.history.isNotEmpty) {
      content = widget.pin.history[selectedEventIndex].values.toString();
    }

  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        // Left side
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Scrollable list of history
              Flexible(
                flex: 5,
                child: Container(
                  height: 200, // Adjust this value as needed
                  child: ListView.builder(
                    itemCount: widget.pin.history.length,
                    itemBuilder: (context, index) {
                      DateTime date = widget.pin.history[selectedEventIndex].keys.first;
                      String formattedDate = DateFormat('MM-dd-yyyy hh:mm:ss').format(date);
                      return ListTile(
                        onTap: () {
                          setState(() {
                            selectedEventIndex = index;
                            content = widget.pin.history[selectedEventIndex].values.toString();
                          });
                        },
                        title: Text(formattedDate),
                      );
                    },
                  ),
                ),
              ),
              // Button to add new event
              Flexible(
                child: ElevatedButton(
                  onPressed:  () {
                    Provider.of<PinOptionsProvider>(context, listen: false).addEvent(widget.pin, DateTime.now(), 'New Value');
                  },
                  child: Text('Add New Event'),
                ),
              ),
            ],
          ),
        ),
        // Right side
        Expanded(
          child: Text(
            content,
            style: TextStyle(fontSize: 24), // Adjust this value as needed
          ),
        ),
      ],
    );
  }
}