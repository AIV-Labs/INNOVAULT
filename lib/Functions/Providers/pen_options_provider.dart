import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:provider/provider.dart';


enum PointerMode { pen,
  eraser,
  textBox,
  // brush,
  pin,
  none }
class StrokeStyle {
  final double size;
  final Color color;
  final bool taper;
  final StrokeCap cap;

  StrokeStyle({
    required this.size,
    required this.color,
    this.taper = true,
    this.cap = StrokeCap.round, // Set a default value
  });

  StrokeStyle copyWith({double? size, Color? color, bool? taper, StrokeCap? cap}) {
    return StrokeStyle(
      size: size ?? this.size,
      color: color ?? this.color,
      taper: taper ?? this.taper,
      cap: cap ?? this.cap,
    );
  }
}
class Stroke {
  List<dynamic> points;
   StrokeOptions options;
   StrokeStyle style;
   PointerMode mode;
  Stroke(this.points, this.options, this.style,  this.mode);
}
class Dot {
  final double x;
  final double y;
  final double radius;

  Dot(this.x, this.y, this.radius);
}

// defaults

class PenOptionsProvider extends ChangeNotifier {

  bool isPressureSensitive = true;
  List<StrokeOptions> defaultPSensOptionsList = [];
  List<StrokeOptions> defaultPInSensOptionsList = [];
  int currentOptionIndex = 1;
  late StrokeOptions strokeOptions;
  StrokeStyle currentStrokeStyle = StrokeStyle(size: 2, color: const Color(0xFF495867));

  PenOptionsProvider() {
    init();
    strokeOptions = defaultPSensOptionsList[currentOptionIndex];
  }
  void init() {
    defaultPSensOptionsList = [

      //2
      StrokeOptions(
        size: 2,
        thinning: 0.4 ,
        // smoothing: 0.6,
        smoothing: 0.9,
        streamline: 0.3,
        easing: (double t) => t/2,
        start:
        StrokeEndOptions.start(
          taperEnabled: false,
          cap: true,
        )
        ,
        end: StrokeEndOptions.end(
          taperEnabled: false,
          cap: true,
        ),
        simulatePressure:  true,
        isComplete: false,
      ),

      //4 should be default
      StrokeOptions(
        size: 4,
        thinning: 0.45,
        // smoothing: 0.6,
        smoothing: 0.4,
        streamline: 0.1,
        easing: (double t) => t/2,
        start: StrokeEndOptions.start(
          taperEnabled: false,
          cap: true,
        ),
        end:StrokeEndOptions.end(
          taperEnabled: false,
          cap: true,
        ),
        simulatePressure:  true,
        isComplete: false,
      ),

      //6
      StrokeOptions(
        size: 6,
        thinning: 0.45 ,
        // smoothing: 0.6,
        smoothing: 0.1,
        streamline: 0.1,
        easing: (double t) => t/2,
        start:
        StrokeEndOptions.start(
          taperEnabled: false,
          customTaper: 1,
          cap: false,
        ),
        end: StrokeEndOptions.end(
          taperEnabled: false,
          customTaper: 1,
          cap: false,
        ),
        simulatePressure:  true,
        isComplete: false,
      ),

      //10
      StrokeOptions(
        size: 10,
        thinning:  1 ,
        // smoothing: 0.6,
        smoothing: 0.3,
        streamline: 0.1,
        easing: (double t) => t/2,
        start:
        StrokeEndOptions.start(
          taperEnabled: false,
          cap: true,
        ),
        end: StrokeEndOptions.end(
          taperEnabled: true,
          customTaper: 60,
          cap: false,
        ),
        simulatePressure:  true,
        isComplete: false,
      ),

    ];

    defaultPInSensOptionsList = [

      //2
      StrokeOptions(
        size: 2,
        thinning: 0 ,
        // smoothing: 0.6,
        smoothing: 0,
        streamline: 0,
        easing: (double t) => t/2,
        start:
        StrokeEndOptions.start(
          taperEnabled: false,
          cap: true,
        )
        ,
        end: StrokeEndOptions.end(
          taperEnabled: false,
          customTaper: 1,
          cap: true,
        ),
        simulatePressure:  true,
        isComplete: false,
      ),

      //4 should be default
      StrokeOptions(
        size: 4,
        thinning: 0.0,
        // smoothing: 0.6,
        smoothing: 0.0,
        streamline: 0.0,
        easing: (double t) => t/2,
        start: StrokeEndOptions.start(
          taperEnabled: false,

          cap: true,
        ),
        end:StrokeEndOptions.end(
          taperEnabled: false,
          cap: true,
        ),
        simulatePressure:  true,
        isComplete: false,
      ),

      //6
      StrokeOptions(
        size: 6,
        thinning: 0 ,
        // smoothing: 0.6,
        smoothing: 0,
        streamline: 0,
        easing: (double t) => t/2,
        start:
        StrokeEndOptions.start(
          taperEnabled: false,
          cap: true,
        ),
        end: StrokeEndOptions.end(
          taperEnabled: false,
          cap: true,
        ),
        simulatePressure:  true,
        isComplete: false,
      ),

      //10
      StrokeOptions(
        size: 10,
        thinning:  0 ,
        // smoothing: 0.6,
        smoothing: 0,
        streamline: 0.0,
        easing: (double t) => t/2,
        start:
        StrokeEndOptions.start(
          taperEnabled: false,
          cap: true,
        ),
        end: StrokeEndOptions.end(
          taperEnabled: false,
          customTaper: 60,
          cap: true,
        ),
        simulatePressure:  true,
        isComplete: false,
      ),

    ];

  }

  void changePen(int index){
    if (isPressureSensitive) {
      strokeOptions = defaultPSensOptionsList[index];
    } else {
      strokeOptions = defaultPInSensOptionsList[index];
    }
    currentOptionIndex = index;
    notifyListeners();
  }
  void resetPenOptions() {
    strokeOptions = defaultPSensOptionsList[currentOptionIndex];
    notifyListeners();
  }

  void updateStrokeSize(double newSize) {
    debugPrint('Stroke options $strokeOptions newSize: $newSize');

    strokeOptions = strokeOptions.copyWith(
      size: newSize,
      streamline: 0.3 + (newSize - 2 >0 ? newSize - 2:1 ) * (1 - 0.6) / (20 - 2),
      smoothing: 1- (newSize - 2 >0 ? newSize - 2:1 ) * (1 - 0) / (20 - 2),
    );
    debugPrint('strokeOptions $strokeOptions new size: ${strokeOptions.size}.');
    notifyListeners();
  }


  void updateStrokeStyle(StrokeStyle newStyle) {
    currentStrokeStyle = newStyle;
    notifyListeners();
  }

  void updateStrokeThinning(double newThinning) {
    strokeOptions = strokeOptions.copyWith(thinning: newThinning);
    notifyListeners();
  }


  void updateStrokeSmoothing(double newSmoothing) {
    strokeOptions = strokeOptions.copyWith(smoothing: newSmoothing);
    notifyListeners();
  }

  void updateStrokeStreamline(double newStreamline) {
    strokeOptions = strokeOptions.copyWith(streamline: newStreamline);
    notifyListeners();
  }

  // Start Taper options
  void updateStrokeStartTaper(double customTaper) {
    StrokeEndOptions start = strokeOptions.start;
    start.customTaper = customTaper;
    strokeOptions = strokeOptions.copyWith(start: start);
    notifyListeners();
  }
  void toggleStrokeStartTaper(bool newTaper) {
    StrokeEndOptions start = strokeOptions.start;
    if (newTaper) {
      // If taper is enabled, disable cap
      start.cap = false;
    }
    start.taperEnabled = newTaper;
    strokeOptions = strokeOptions.copyWith(start: start);
    notifyListeners();
  }
  void toggleStrokeStartCap(bool newCap) {
    StrokeEndOptions start = strokeOptions.start;
    if (newCap) {
      // If cap is enabled, disable taper
      start.taperEnabled = false;
    }
    start.cap = newCap;
    strokeOptions = strokeOptions.copyWith(start: start);
    notifyListeners();
  }

  // End Taper options
  void updateStrokeEndTaper(double customTaper) {
    StrokeEndOptions end = strokeOptions.end;
    end.customTaper = customTaper;
    strokeOptions = strokeOptions.copyWith(end: end);
    notifyListeners();
  }
  void toggleStrokeEndTaper(bool newTaper) {
    StrokeEndOptions end = strokeOptions.end;
    if (newTaper) {
      // If taper is enabled, disable cap
      end.cap = false;
    }
    end.taperEnabled = newTaper;
    strokeOptions = strokeOptions.copyWith(end: end);
    notifyListeners();
  }
  void toggleStrokeEndCap(bool newCap) {
    StrokeEndOptions end = strokeOptions.end;
    if (newCap) {
      // If cap is enabled, disable taper
      end.taperEnabled = false;
    }
    end.cap = newCap;
    strokeOptions = strokeOptions.copyWith(end: end);
    notifyListeners();
  }


  // simulatePressure
  void updateStrokeSimulatePressure(bool newSimulatePressure) {
    strokeOptions = strokeOptions.copyWith(simulatePressure: newSimulatePressure);
    notifyListeners();
  }

  void togglePressureSensitivity(bool newSimulatePressure) {
    isPressureSensitive = newSimulatePressure;

    if (isPressureSensitive) {
      strokeOptions = defaultPSensOptionsList[currentOptionIndex];
    } else {
      strokeOptions = defaultPInSensOptionsList[currentOptionIndex];
    }
    notifyListeners();
  }
}



class Pin {
   Offset position;
   String id;
   String tooltip;
   List<Map<DateTime, String>> history; // Each map contains a date and data
   PinShape shape;
   Color color;
  double size;

  Pin({
    required this.position,
    required this.id,
     this.history = const [],
    required this.tooltip,
     this.shape = PinShape.circle_filled,
     this.color = Colors.white,
     this.size = 10.0,
  });
}

enum PinShape {
  circle_filled,
  circle_stroke,

  square_filled,
  square_stroke,

  triangle_filled,
  triangle_stroke,

  hexagon_filled,
  hexagon_stroke }

class PinOptionsProvider extends ChangeNotifier {
  // defaults
  List<Map<String, dynamic>> defaultHistory = [];
  PinShape defaultShape = PinShape.circle_filled; // Replace with your default shape
  Color defaultColor = Color(0xFFbc4749);
  double defaultSize = 10.0;

  // new pin
  PinShape shape = PinShape.circle_filled;
  // Color color = Color(0xFF2b2d42);
  // Color color = Color(0xFFbc4749);
  Color color =  Color(0xFF5A5766);
  double size = 10.0;


  void updateShape(PinShape newShape) {
    shape = newShape;
    notifyListeners();
  }

  void updateColor(Color newColor) {
    color = newColor;
    notifyListeners();
  }

  void updateSize(double newSize) {
    size = newSize;
    notifyListeners();
  }
  addEvent(Pin pin, DateTime date, String data) {
    pin.history.add({date: data});
    notifyListeners();
  }


}

enum EraserMode {
  objectEraser,
  pointEraser,
  transparency,
}
class EraserOptionsProvider extends ChangeNotifier {
  EraserMode currentEraserMode = EraserMode.objectEraser;
  double size =100.0; // Default eraser size

  void updateSize(double newSize) {
    size = newSize;
    notifyListeners();
  }
  void updateEraserMode(EraserMode newMode) {
    currentEraserMode = newMode;
    notifyListeners();
  }
}


// Provider for Text box
class TextBox {
   String id;
   String creator;
   String lastEditor;
   DateTime creationDate;
   DateTime lastUpdateDate;
   List <String> activeUsers;
   Offset position;
   quill.QuillController controller;
   Color bannerColor = Colors.blue;
   bool bannerVisible;
   Size size;

  TextBox({
    required this.id,
    required this.creator,
    required this.lastEditor,
    required this.creationDate,
    required this.lastUpdateDate,
    required this.position,
    required this.controller,
    this.bannerColor = const Color(0xFF66666E),
    this.bannerVisible = false,
    this.size = const Size(200, 200),
    this.activeUsers = const [],
  });
}

class TextBoxProvider extends ChangeNotifier {
  List<TextBox> _textBoxes = [];

  List<TextBox> get textBoxes => _textBoxes;

  void addTextBox(TextBox textBox) {
    _textBoxes.add(textBox);
    notifyListeners();
  }

  void updateTextBox(TextBox textBox) {
    int index = _textBoxes.indexWhere((tb) => tb.id == textBox.id);
    if (index != -1) {
      _textBoxes[index] = textBox;
      notifyListeners();
    }
  }
  void updateTextBoxPosition(String id, Offset newPosition) {
    int index = _textBoxes.indexWhere((tb) => tb.id == id);
    if (index != -1) {
      _textBoxes[index].position = newPosition;
      notifyListeners();
    }
  }
  void updateBoxSize(String id, Size newSize) {
    int index = _textBoxes.indexWhere((tb) => tb.id == id);
    if (index != -1) {
      _textBoxes[index].size = newSize;
      notifyListeners();
    }
  }
  void updateTextBoxContent(String id, quill.QuillController newController) {
    int index = _textBoxes.indexWhere((tb) => tb.id == id);
    if (index != -1) {
      _textBoxes[index].controller = newController;
      notifyListeners();
    }
  }
  void updateBannerVisibility(String id, bool newVisibility) {
    int index = _textBoxes.indexWhere((tb) => tb.id == id);
    if (index != -1) {
      _textBoxes[index].bannerVisible = newVisibility;
      notifyListeners();
    }
  }
  void updateBannerColor(String id, Color newColor) {
    int index = _textBoxes.indexWhere((tb) => tb.id == id);
    if (index != -1) {
      _textBoxes[index].bannerColor = newColor;
      notifyListeners();
    }
  }

  void removeTextBox(String id) {
    _textBoxes.removeWhere((tb) => tb.id == id);
    notifyListeners();
  }

  void clearTextBoxes() {
    _textBoxes.clear();
    notifyListeners();
  }

}




class DrawingOptionsProvider extends StatelessWidget {
  final Widget child;

  DrawingOptionsProvider({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PenOptionsProvider>(
          create: (_) => PenOptionsProvider(),
        ),
        ChangeNotifierProvider<PinOptionsProvider>(
          create: (_) => PinOptionsProvider(),
        ),
        ChangeNotifierProvider<EraserOptionsProvider>(
          create: (_) => EraserOptionsProvider(),
        ),
        ChangeNotifierProvider<TextBoxProvider>(
          create: (_) => TextBoxProvider(),
        ),
      ],
      child: child,
    );
  }
}