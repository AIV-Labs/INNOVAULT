import 'package:flutter/material.dart';
import 'package:realm/realm.dart';


import '../Realms/canvas_realm.dart';
import 'canvas_provider.dart';


class CanvasListProvider with ChangeNotifier {
  late Realm realm;
  RealmResults<CanvasRM>? realmCanvases;


  CanvasListProvider(Realm realm) {
    realm = realm;
    initCanvasRealmList();

  }

  List<CanvasProvider> _canvases = [];

  List<CanvasProvider> get canvases => _canvases;


  void initCanvasRealmList() {
    // Load the canvas list from Realm
    // insure that the realm is initialized

    realmCanvases = realm.all<CanvasRM>();

    // subscribe to changes in the realmCanvases
    realmCanvases!.changes.listen((event) {
      event.isCleared;
      event.deleted;
      event.inserted;
      event.modified;
      event.moved;
      event.newModified;
    });

  }

  void loadCanvasList(List<CanvasProvider> canvases) {
    _canvases = canvases;
    // Load canvases from Realm
    notifyListeners();

  }

  void addBlankCanvas(BuildContext context, String canvasName, GlobalKey<State<StatefulWidget>> canvasKey) {
    _canvases.add(CanvasProvider(context: context, canvasKey: canvasKey));
    notifyListeners();
  }

  void addCanvas(CanvasProvider canvas) {
    _canvases.add(canvas);
    notifyListeners();
  }
  void loadCanvas(CanvasProvider canvas) {
    _canvases.add(canvas);
    notifyListeners();
  }


  // If i use realm


  CanvasRM loadCanvasFromRealm(String canvasId) {
    // Load the canvas from Realm
     return realmCanvases!.query('id == \$0', [canvasId]).first;

  }


}


class DashboardCanvasProvider with ChangeNotifier {
  late Realm realm;
  late CanvasProvider selectedCanvas;
  final CanvasListProvider canvasListProvider;

  // constructor invokes the super class constructor and initializes the selectedCanvas
  DashboardCanvasProvider({required this.realm, required this.canvasListProvider, required this.selectedCanvas });


  void createBlankCanvas(BuildContext context, String canvasName, GlobalKey<State<StatefulWidget>> canvasKey) {
    selectedCanvas =CanvasProvider(context: context, canvasKey: canvasKey);
    notifyListeners();
  }

  void changeSelectedCanvas(CanvasProvider canvas) {
    selectedCanvas = canvas;
    notifyListeners();
  }

  CanvasRM loadCanvasFromRealm(String canvasId) {
    // Load the canvas from Realm
    return canvasListProvider.realmCanvases!.query('id == \$0', [canvasId]).first;

  }
  void switchCanvas(String canvasId, BuildContext context, GlobalKey<State<StatefulWidget>> canvasKey) {

    // Save the current canvas before switching
    selectedCanvas.saveCanvasToRealm(realm);

    // Load the canvas from Realm
    final canvasRM = loadCanvasFromRealm(canvasId);
    CanvasProvider newCanvas = CanvasProvider(context: context, canvasKey: canvasKey).fromRealm(canvasRM);
    selectedCanvas = newCanvas;
    notifyListeners();
  }
  void saveCurrentCanvas() {
    selectedCanvas.saveCanvasToRealm(realm);
  }


}

class TasksCanvasProvider with ChangeNotifier{
  final Realm realm;
  TasksCanvasProvider({required this.realm});

  // Add methods for tasks-specific functionalities here
}

class VaultCanvasProvider with ChangeNotifier{
  final Realm realm;
  VaultCanvasProvider({required this.realm});
  // Add methods for vault-specific functionalities here
}