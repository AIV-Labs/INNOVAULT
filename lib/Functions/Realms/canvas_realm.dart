
import 'package:realm/realm.dart';

part 'canvas_realm.realm.dart';



// canvas List Realm Model

@RealmModel()
class $CanvasListRM {
  @PrimaryKey()
  @MapTo('_id')
  late String id;
  late List<$CanvasRM> canvases;
}



@RealmModel()
class $CanvasRM {
  @PrimaryKey()
  @MapTo('_id')
  late String id;

  // image related
  late String imagePath;
  // Consider storing as two separate double values
  late double initialImagePositionX;
  late double initialImagePositionY;
  // Consider storing as two separate double values
  late double initialImageWidth;
  late double initialImageHeight;

  late String backgroundType; // Store as String
  late int backgroundColor; // Store color as int
  late int backgroundLinesColor; // Store color as int

  // line drawing
  late List<_StrokeRM>lines;
  late _StrokeRM? line;

  // boxes
  // late ValueNotifier<quill.QuillController?> activeQuillController = ValueNotifier(quill.QuillController.basic());
  // late List<DraggableTextBox> draggableTextBoxes = [];
  late List<_TextBoxRM> textBoxes;
  //pins
  late List<_PinRM> pins;
}



@RealmModel(ObjectType.embeddedObject)
class _PinRM {
  late String id;
  late double positionX;
  late double positionY;
  late String tooltip;
  late List<_PinHistoryRM> history;
  late String shape;
  late String color;
  late double size;
}

@RealmModel(ObjectType.embeddedObject)
class _PinHistoryRM {
  late DateTime date;
  late String data;
}

@RealmModel(ObjectType.embeddedObject)
class _TextBoxRM {
  late String id;
  late String creator;
  late String lastEditor;
  late DateTime creationDate;
  late DateTime lastUpdateDate;
  // Consider storing active users as a list of strings or IDs
  late double positionX;
  late double positionY;
  late String serializedContent; // Serialize Quill content
  late int bannerColor; // Store color as int
  late bool bannerVisible;
  // storing size as two separate double values
  late double width;
  late double height;
}



@RealmModel(ObjectType.embeddedObject)
class _StrokeRM {
  // points can be pointVector or dots so it should be a list of a union type or dynamic
  late List<_PointRM> points;
  late _StrokeOptionsRM? options;
  late _StrokeStyleRM? style;

}

@RealmModel(ObjectType.embeddedObject)
class _PointRM {
  late String type; // "PointVector" or "Dot"
  late double x;
  late double y;
  late double? pressure; // if type is "PointVector"
  late double? radius; // if type is "Dot"
}


@RealmModel(ObjectType.embeddedObject)
class _StrokeStyleRM {
  late double size;
  late String color;
  late bool taper;
  late String cap; // string in DB {round, square, butt}
}

@RealmModel(ObjectType.embeddedObject)
class _StrokeOptionsRM{
  double? size;
  double? thinning;
  double? smoothing;
  double? streamline;
  // double Function(double)? easing;
  bool? simulatePressure;
  _StrokeEndOptionsRM? start;
  _StrokeEndOptionsRM? end;
  bool? isComplete;
}

@RealmModel(ObjectType.embeddedObject)
class _StrokeEndOptionsRM {
  late bool cap;
  late bool taperEnabled;
  late double customTaper;
}

