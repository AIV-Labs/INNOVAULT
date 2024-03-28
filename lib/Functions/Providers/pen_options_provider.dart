import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:provider/provider.dart';


enum PointerMode { pen,
  eraser,
  // brush,
  pin,
  none }
class StrokeStyle {
  double size;
  Color color;

  StrokeStyle({required this.size, required this.color});

  StrokeStyle copyWith({double? size, Color? color}) {
    return StrokeStyle(
      size: size ?? this.size,
      color: color ?? this.color,
    );
  }
}
class Stroke {
  List<dynamic> points;
  final StrokeOptions options;
  final StrokeStyle style;
  final PointerMode mode;
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
  StrokeStyle currentStrokeStyle = StrokeStyle(size: 2, color: Colors.black);

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
          customTaper: 1,
          cap: false,
        )
        ,
        end: StrokeEndOptions.end(
          taperEnabled: false,
          customTaper: 1,
          cap: false,
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
          customTaper: 1,
          cap: true,
        ),
        end:StrokeEndOptions.end(
          taperEnabled: false,
          customTaper: 1,
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
          customTaper: 1,
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
   List<Map<String, String>> history; // Each map contains a date and data
   String shape;
   Color color;
  double size;

  Pin({
    required this.position,
    required this.id,
     this.history = const [],
    required this.tooltip,
     this.shape = 'circle_filled',
     this.color = Colors.white,
     this.size = 1.0,
  });
}



class PinOptionsProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _defaultHistory = [];
  Widget _defaultShape = Container(); // Replace with your default shape
  Color _defaultColor = Colors.black;
  double _defaultSize = 1.0;

  List<Map<String, dynamic>> get defaultHistory => _defaultHistory;
  Widget get defaultShape => _defaultShape;
  Color get defaultColor => _defaultColor;
  double get defaultSize => _defaultSize;

  void updateDefaultHistory(List<Map<String, dynamic>> newHistory) {
    _defaultHistory = newHistory;
    notifyListeners();
  }

  void updateDefaultShape(Widget newShape) {
    _defaultShape = newShape;
    notifyListeners();
  }

  void updateDefaultColor(Color newColor) {
    _defaultColor = newColor;
    notifyListeners();
  }

  void updateDefaultSize(double newSize) {
    _defaultSize = newSize;
    notifyListeners();
  }

  void updatePinColor(Pin pin, Color color) {
    pin.color = color;
    notifyListeners();
  }

  void updatePinSize(Pin pin, double size) {
    pin.size = size;
    notifyListeners();
  }

  void updatePinShape(Pin pin, String shape) {
    pin.shape = shape;
    notifyListeners();
  }

  void updatePinHistory(Pin pin, List<Map<String, String>> history) {
    pin.history = history;
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
      ],
      child: child,
    );
  }
}