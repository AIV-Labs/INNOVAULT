import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:provider/provider.dart';

import '../../../../Functions/Providers/pen_options_provider.dart';
import '../../../../constants.dart';


class DraggableTextBox extends StatefulWidget {
  String id;
  GlobalKey canvasKey;
  GlobalKey key;
  GlobalKey containerKey = GlobalKey();
  TextBox textBox;
  Function onRemove;
  // activeQuillController
  ValueNotifier<quill.QuillController?> activeQuillController;
  ValueNotifier<bool> isDraggingTextBox;
  DraggableTextBox({ required this.id, required this.key, required this.canvasKey, required this.textBox, required this.activeQuillController, required this.onRemove, required this.isDraggingTextBox});


  @override
  _DraggableTextBoxState createState() => _DraggableTextBoxState(key, containerKey); // Pass the new GlobalKey to the state



}

class _DraggableTextBoxState extends State<DraggableTextBox> {
  Offset position = Offset.zero;
  // quill.QuillController _controller = quill.QuillController.basic();
  GlobalKey key;
  GlobalKey containerKey; // Define a new GlobalKey for the Container
  final FocusNode _focusNode = FocusNode();
  final FocusScopeNode _focusScopeNode = FocusScopeNode();
  // bool _isDragging = false;


  _DraggableTextBoxState(this.key, this.containerKey);

  void _showMenu(BuildContext context, Offset tapPosition) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(
          tapPosition,
          tapPosition,
        ),
        Offset.zero & overlay.size,
      ),
      constraints: BoxConstraints(
        minWidth: 100,
        maxWidth: 200,
      ),
      items: <PopupMenuEntry>[
        PopupMenuItem(
          child: TextButton(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(CupertinoIcons.info, size: 18,),
                const SizedBox(width: 10),
                Text('Info'),
              ],
            ),
            onPressed: () {
              Navigator.pop(context);
              _showInfoDialog();
            },
          ),
        ),
        PopupMenuItem(
          child: TextButton(
            child: Row(
              children: [
                Icon(Icons.delete,  color: Colors.redAccent, size: 18),
                const SizedBox(width: 10),
                Text('Delete'),
              ],
            ),
            onPressed: () {
              Navigator.pop(context);
              _showDeleteConfirmationDialog();
            },
          ),
        ),
      ],
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Info'),
          content:
          SizedBox(
            width: 400,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID: ${widget.textBox.id}'),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(child: Text('Creator: ${widget.textBox.creator}', overflow: TextOverflow.ellipsis,)),
                      Flexible(child: Text('${widget.textBox.creationDate}')),
                    ],
                  ),

                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(child: Text('Last Editor: ${widget.textBox.lastEditor}', overflow: TextOverflow.ellipsis,)),
                      Flexible(child: Text('${widget.textBox.lastUpdateDate}'),),
                    ],
                  ),

                  const SizedBox(height: 10),
                  // color piker + always visible checkbox
                  Flexible(child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(

                        height: 100,
                        width: 300,
                        padding: EdgeInsets.all(10),
                        child: BannerColorPicker(id: widget.textBox.id,),),
                      const SizedBox(width: 10),
                      // always visible checkbox
                      Row(
                        children: [
                          const Text('Banner Always Visible'),
                          Consumer<TextBoxProvider>(
                            builder: (context, textBoxProvider, child) {
                              return Checkbox(
                                value: widget.textBox.bannerVisible,
                                onChanged: (bool? value) {
                                  textBoxProvider.updateBannerVisibility(widget.textBox.id, value!);
                                  setState(() {
                                    widget.textBox.bannerVisible = value;
                                  });
                                },
                              );
                            },
                          )
                        ],
                      )
                    ],
                  ),),]),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this text box?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                widget.onRemove(widget.textBox.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    position = widget.textBox.position;
    _focusScopeNode.addListener(_handleScopeFocusChange);
    // _focusScopeNode.requestFocus(_focusNode);
    _focusNode.requestFocus();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        widget.activeQuillController.value = widget.textBox.controller;
      }
    });



  }

  void _handleScopeFocusChange() {
    if (_focusScopeNode.hasFocus) {
      debugPrint('Focus gained');
    } else {
      debugPrint('Focus lost');
    }
    // Trigger a rebuild whenever focus changes
    setState(() {});
  }
  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      widget.activeQuillController.value = widget.textBox.controller;
    }
    // Trigger a rebuild whenever focus changes
    setState(() {});
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
_focusScopeNode.removeListener(_handleFocusChange);
    _focusScopeNode.dispose();
    super.dispose();
  }
  ValueNotifier<bool> isBorderVisible = ValueNotifier<bool>(true);
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _focusNode.requestFocus();
          });
          // Request focus for the current text box
          _focusScopeNode.requestFocus(_focusNode);
          debugPrint('tapped on text box with content:'
              ' ${widget.textBox.controller.document.toPlainText()} '
              'and focus node has focus: ${_focusNode.hasFocus}'
              'and focus scope node has focus: ${_focusScopeNode.hasFocus}');
        },
        child: SizedBox(
          width: widget.textBox.size.width,
          height: widget.textBox.size.height,
          child: Stack(
            children: [

              // Rich Text Editor
              Positioned.fill(
                child: FocusScope(
                  node: _focusScopeNode,
                  child: Container(
                    key: containerKey,
                    decoration: BoxDecoration(
                      //all borders but top
                      border:  Border(
                        bottom: BorderSide(
                          // check if document s empty
                          color: _focusScopeNode.hasFocus || widget.textBox.controller.document.isEmpty() ? Colors.black : Colors.transparent,

                        ),
                        left: BorderSide(
                          color: _focusScopeNode.hasFocus || widget.textBox.controller.document.isEmpty() ? Colors.black : Colors.transparent,

                        ),
                        right: BorderSide(
                          color: _focusScopeNode.hasFocus || widget.textBox.controller.document.isEmpty() ? Colors.black : Colors.transparent,

                        ),
                      ),
                      borderRadius: BorderRadius.circular(5),),

                    padding: const EdgeInsets.fromLTRB(8, 30, 8, 8),
                    child: Column(
                      children: [
                        // quill Text Box
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            quill.QuillEditor.basic(
                              focusNode: _focusNode,
                              configurations: quill.QuillEditorConfigurations(
                                controller: widget.textBox.controller,
                                autoFocus: false,
                                readOnly: false,
                                sharedConfigurations: const quill.QuillSharedConfigurations(
                                  locale: Locale('en'),
                                ),
                              ),
                            ),
                          ],
                        ),



                      ],
                    ),
                  ),
                ),
              ),
              // drag and option bar
              Positioned.fromRect(
                rect: Rect.fromLTWH(0, 0, widget.textBox.size.width, 20),
                child:  Visibility(
                  visible: widget.textBox.bannerVisible? true :_focusScopeNode.hasFocus || widget.textBox.controller.document.isEmpty(),
                  child: GestureDetector(
                      onPanUpdate: (details) {
                        // consider using localPosition instead of details.delta
                        // final RenderBox renderBox = widget.canvasKey.currentContext!.findRenderObject() as RenderBox;
                        // final localPosition = renderBox.globalToLocal(details.offset);
                        widget.isDraggingTextBox.value = true;
                        setState(() {
                          position += details.delta;
                        });
                      },
                      onPanEnd: (details) {
                        widget.isDraggingTextBox.value = false;
                      },
                      onLongPressEnd: (details) {
                        _focusScopeNode.requestFocus(_focusNode);
                        _showMenu(context, details.globalPosition);
                      },


                      child: Container(
                        decoration:  BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(5),
                            topRight: Radius.circular(5),
                          ),
                          // color: Color(0xFFEBEBEB),
                          color: widget.textBox.bannerColor,
                        ),
                        height: 20,
                        width: double.infinity,
                      )),
                ),),
              // resize handle
              Positioned(
                bottom: 2,
                right: 2,
                child: Visibility(
                  visible: _focusScopeNode.hasFocus || widget.textBox.controller.document.isEmpty(),
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        // Update the size of the widget
                        // minimum of 200x200
                        debugPrint('resizing');
                        widget.isDraggingTextBox.value = true;
                        Provider.of<TextBoxProvider>(context, listen: false).
                        updateBoxSize(widget.textBox.id,
                            Size(
                              max(200, widget.textBox.size.width + details.delta.dx),
                              max(200, widget.textBox.size.height + details.delta.dy),
                            ));
                      });
                    },
                    onPanEnd: (details) {
                      widget.isDraggingTextBox.value = false;
                    },
                    child: Icon(Icons.zoom_out_map, size: 20,), // Replace with your resize handle widget
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class BannerColorPicker extends StatelessWidget {
  final List<Color> defaultColors = defaultColorsList;
  final String id;
  BannerColorPicker({required this.id});

  @override
  Widget build(BuildContext context) {
    return Consumer<TextBoxProvider>(
        builder: (context, textBoxProvider, child) {
          final textbox = Provider.of<TextBoxProvider>(context, listen: false).textBoxes.firstWhere((element) => element.id == id);
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(

                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: textbox.bannerColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 20),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: GridView.count(
                    crossAxisCount: 6,
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.vertical,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 15,
                    children: defaultColors.map((color) {
                      return GestureDetector(
                        onTap: () {
                          Provider.of<TextBoxProvider>(context, listen: false).updateBannerColor(id,color);
                        },
                        child: Container(
                          margin: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: textbox.bannerColor == color ? [
                              BoxShadow(
                                color: color.withOpacity(0.8),
                                spreadRadius: 1,
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ] : [],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          );
        }
    );
  }
}