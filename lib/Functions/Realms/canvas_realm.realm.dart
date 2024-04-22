// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'canvas_realm.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class CanvasListRM extends $CanvasListRM
    with RealmEntity, RealmObjectBase, RealmObject {
  CanvasListRM(
    String id, {
    Iterable<CanvasRM> canvases = const [],
  }) {
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set<RealmList<CanvasRM>>(
        this, 'canvases', RealmList<CanvasRM>(canvases));
  }

  CanvasListRM._();

  @override
  String get id => RealmObjectBase.get<String>(this, '_id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, '_id', value);

  @override
  RealmList<CanvasRM> get canvases =>
      RealmObjectBase.get<CanvasRM>(this, 'canvases') as RealmList<CanvasRM>;
  @override
  set canvases(covariant RealmList<CanvasRM> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<CanvasListRM>> get changes =>
      RealmObjectBase.getChanges<CanvasListRM>(this);

  @override
  CanvasListRM freeze() => RealmObjectBase.freezeObject<CanvasListRM>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      '_id': id.toEJson(),
      'canvases': canvases.toEJson(),
    };
  }

  static EJsonValue _toEJson(CanvasListRM value) => value.toEJson();
  static CanvasListRM _fromEJson(EJsonValue ejson) {
    return switch (ejson) {
      {
        '_id': EJsonValue id,
        'canvases': EJsonValue canvases,
      } =>
        CanvasListRM(
          fromEJson(id),
          canvases: fromEJson(canvases),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(CanvasListRM._);
    register(_toEJson, _fromEJson);
    return SchemaObject(ObjectType.realmObject, CanvasListRM, 'CanvasListRM', [
      SchemaProperty('id', RealmPropertyType.string,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('canvases', RealmPropertyType.object,
          linkTarget: 'CanvasRM', collectionType: RealmCollectionType.list),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class CanvasRM extends $CanvasRM
    with RealmEntity, RealmObjectBase, RealmObject {
  CanvasRM(
    String id,
    String imagePath,
    double initialImagePositionX,
    double initialImagePositionY,
    double initialImageWidth,
    double initialImageHeight,
    String backgroundType,
    int backgroundColor,
    int backgroundLinesColor, {
    Iterable<StrokeRM> lines = const [],
    StrokeRM? line,
    Iterable<TextBoxRM> textBoxes = const [],
    Iterable<PinRM> pins = const [],
  }) {
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'imagePath', imagePath);
    RealmObjectBase.set(this, 'initialImagePositionX', initialImagePositionX);
    RealmObjectBase.set(this, 'initialImagePositionY', initialImagePositionY);
    RealmObjectBase.set(this, 'initialImageWidth', initialImageWidth);
    RealmObjectBase.set(this, 'initialImageHeight', initialImageHeight);
    RealmObjectBase.set(this, 'backgroundType', backgroundType);
    RealmObjectBase.set(this, 'backgroundColor', backgroundColor);
    RealmObjectBase.set(this, 'backgroundLinesColor', backgroundLinesColor);
    RealmObjectBase.set<RealmList<StrokeRM>>(
        this, 'lines', RealmList<StrokeRM>(lines));
    RealmObjectBase.set(this, 'line', line);
    RealmObjectBase.set<RealmList<TextBoxRM>>(
        this, 'textBoxes', RealmList<TextBoxRM>(textBoxes));
    RealmObjectBase.set<RealmList<PinRM>>(this, 'pins', RealmList<PinRM>(pins));
  }

  CanvasRM._();

  @override
  String get id => RealmObjectBase.get<String>(this, '_id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, '_id', value);

  @override
  String get imagePath =>
      RealmObjectBase.get<String>(this, 'imagePath') as String;
  @override
  set imagePath(String value) => RealmObjectBase.set(this, 'imagePath', value);

  @override
  double get initialImagePositionX =>
      RealmObjectBase.get<double>(this, 'initialImagePositionX') as double;
  @override
  set initialImagePositionX(double value) =>
      RealmObjectBase.set(this, 'initialImagePositionX', value);

  @override
  double get initialImagePositionY =>
      RealmObjectBase.get<double>(this, 'initialImagePositionY') as double;
  @override
  set initialImagePositionY(double value) =>
      RealmObjectBase.set(this, 'initialImagePositionY', value);

  @override
  double get initialImageWidth =>
      RealmObjectBase.get<double>(this, 'initialImageWidth') as double;
  @override
  set initialImageWidth(double value) =>
      RealmObjectBase.set(this, 'initialImageWidth', value);

  @override
  double get initialImageHeight =>
      RealmObjectBase.get<double>(this, 'initialImageHeight') as double;
  @override
  set initialImageHeight(double value) =>
      RealmObjectBase.set(this, 'initialImageHeight', value);

  @override
  String get backgroundType =>
      RealmObjectBase.get<String>(this, 'backgroundType') as String;
  @override
  set backgroundType(String value) =>
      RealmObjectBase.set(this, 'backgroundType', value);

  @override
  int get backgroundColor =>
      RealmObjectBase.get<int>(this, 'backgroundColor') as int;
  @override
  set backgroundColor(int value) =>
      RealmObjectBase.set(this, 'backgroundColor', value);

  @override
  int get backgroundLinesColor =>
      RealmObjectBase.get<int>(this, 'backgroundLinesColor') as int;
  @override
  set backgroundLinesColor(int value) =>
      RealmObjectBase.set(this, 'backgroundLinesColor', value);

  @override
  RealmList<StrokeRM> get lines =>
      RealmObjectBase.get<StrokeRM>(this, 'lines') as RealmList<StrokeRM>;
  @override
  set lines(covariant RealmList<StrokeRM> value) =>
      throw RealmUnsupportedSetError();

  @override
  StrokeRM? get line =>
      RealmObjectBase.get<StrokeRM>(this, 'line') as StrokeRM?;
  @override
  set line(covariant StrokeRM? value) =>
      RealmObjectBase.set(this, 'line', value);

  @override
  RealmList<TextBoxRM> get textBoxes =>
      RealmObjectBase.get<TextBoxRM>(this, 'textBoxes') as RealmList<TextBoxRM>;
  @override
  set textBoxes(covariant RealmList<TextBoxRM> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<PinRM> get pins =>
      RealmObjectBase.get<PinRM>(this, 'pins') as RealmList<PinRM>;
  @override
  set pins(covariant RealmList<PinRM> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<CanvasRM>> get changes =>
      RealmObjectBase.getChanges<CanvasRM>(this);

  @override
  CanvasRM freeze() => RealmObjectBase.freezeObject<CanvasRM>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      '_id': id.toEJson(),
      'imagePath': imagePath.toEJson(),
      'initialImagePositionX': initialImagePositionX.toEJson(),
      'initialImagePositionY': initialImagePositionY.toEJson(),
      'initialImageWidth': initialImageWidth.toEJson(),
      'initialImageHeight': initialImageHeight.toEJson(),
      'backgroundType': backgroundType.toEJson(),
      'backgroundColor': backgroundColor.toEJson(),
      'backgroundLinesColor': backgroundLinesColor.toEJson(),
      'lines': lines.toEJson(),
      'line': line.toEJson(),
      'textBoxes': textBoxes.toEJson(),
      'pins': pins.toEJson(),
    };
  }

  static EJsonValue _toEJson(CanvasRM value) => value.toEJson();
  static CanvasRM _fromEJson(EJsonValue ejson) {
    return switch (ejson) {
      {
        '_id': EJsonValue id,
        'imagePath': EJsonValue imagePath,
        'initialImagePositionX': EJsonValue initialImagePositionX,
        'initialImagePositionY': EJsonValue initialImagePositionY,
        'initialImageWidth': EJsonValue initialImageWidth,
        'initialImageHeight': EJsonValue initialImageHeight,
        'backgroundType': EJsonValue backgroundType,
        'backgroundColor': EJsonValue backgroundColor,
        'backgroundLinesColor': EJsonValue backgroundLinesColor,
        'lines': EJsonValue lines,
        'line': EJsonValue line,
        'textBoxes': EJsonValue textBoxes,
        'pins': EJsonValue pins,
      } =>
        CanvasRM(
          fromEJson(id),
          fromEJson(imagePath),
          fromEJson(initialImagePositionX),
          fromEJson(initialImagePositionY),
          fromEJson(initialImageWidth),
          fromEJson(initialImageHeight),
          fromEJson(backgroundType),
          fromEJson(backgroundColor),
          fromEJson(backgroundLinesColor),
          lines: fromEJson(lines),
          line: fromEJson(line),
          textBoxes: fromEJson(textBoxes),
          pins: fromEJson(pins),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(CanvasRM._);
    register(_toEJson, _fromEJson);
    return SchemaObject(ObjectType.realmObject, CanvasRM, 'CanvasRM', [
      SchemaProperty('id', RealmPropertyType.string,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('imagePath', RealmPropertyType.string),
      SchemaProperty('initialImagePositionX', RealmPropertyType.double),
      SchemaProperty('initialImagePositionY', RealmPropertyType.double),
      SchemaProperty('initialImageWidth', RealmPropertyType.double),
      SchemaProperty('initialImageHeight', RealmPropertyType.double),
      SchemaProperty('backgroundType', RealmPropertyType.string),
      SchemaProperty('backgroundColor', RealmPropertyType.int),
      SchemaProperty('backgroundLinesColor', RealmPropertyType.int),
      SchemaProperty('lines', RealmPropertyType.object,
          linkTarget: 'StrokeRM', collectionType: RealmCollectionType.list),
      SchemaProperty('line', RealmPropertyType.object,
          optional: true, linkTarget: 'StrokeRM'),
      SchemaProperty('textBoxes', RealmPropertyType.object,
          linkTarget: 'TextBoxRM', collectionType: RealmCollectionType.list),
      SchemaProperty('pins', RealmPropertyType.object,
          linkTarget: 'PinRM', collectionType: RealmCollectionType.list),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class PinRM extends _PinRM with RealmEntity, RealmObjectBase, EmbeddedObject {
  PinRM(
    String id,
    double positionX,
    double positionY,
    String tooltip,
    String shape,
    String color,
    double size, {
    Iterable<PinHistoryRM> history = const [],
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'positionX', positionX);
    RealmObjectBase.set(this, 'positionY', positionY);
    RealmObjectBase.set(this, 'tooltip', tooltip);
    RealmObjectBase.set<RealmList<PinHistoryRM>>(
        this, 'history', RealmList<PinHistoryRM>(history));
    RealmObjectBase.set(this, 'shape', shape);
    RealmObjectBase.set(this, 'color', color);
    RealmObjectBase.set(this, 'size', size);
  }

  PinRM._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  double get positionX =>
      RealmObjectBase.get<double>(this, 'positionX') as double;
  @override
  set positionX(double value) => RealmObjectBase.set(this, 'positionX', value);

  @override
  double get positionY =>
      RealmObjectBase.get<double>(this, 'positionY') as double;
  @override
  set positionY(double value) => RealmObjectBase.set(this, 'positionY', value);

  @override
  String get tooltip => RealmObjectBase.get<String>(this, 'tooltip') as String;
  @override
  set tooltip(String value) => RealmObjectBase.set(this, 'tooltip', value);

  @override
  RealmList<PinHistoryRM> get history =>
      RealmObjectBase.get<PinHistoryRM>(this, 'history')
          as RealmList<PinHistoryRM>;
  @override
  set history(covariant RealmList<PinHistoryRM> value) =>
      throw RealmUnsupportedSetError();

  @override
  String get shape => RealmObjectBase.get<String>(this, 'shape') as String;
  @override
  set shape(String value) => RealmObjectBase.set(this, 'shape', value);

  @override
  String get color => RealmObjectBase.get<String>(this, 'color') as String;
  @override
  set color(String value) => RealmObjectBase.set(this, 'color', value);

  @override
  double get size => RealmObjectBase.get<double>(this, 'size') as double;
  @override
  set size(double value) => RealmObjectBase.set(this, 'size', value);

  @override
  Stream<RealmObjectChanges<PinRM>> get changes =>
      RealmObjectBase.getChanges<PinRM>(this);

  @override
  PinRM freeze() => RealmObjectBase.freezeObject<PinRM>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'positionX': positionX.toEJson(),
      'positionY': positionY.toEJson(),
      'tooltip': tooltip.toEJson(),
      'history': history.toEJson(),
      'shape': shape.toEJson(),
      'color': color.toEJson(),
      'size': size.toEJson(),
    };
  }

  static EJsonValue _toEJson(PinRM value) => value.toEJson();
  static PinRM _fromEJson(EJsonValue ejson) {
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'positionX': EJsonValue positionX,
        'positionY': EJsonValue positionY,
        'tooltip': EJsonValue tooltip,
        'history': EJsonValue history,
        'shape': EJsonValue shape,
        'color': EJsonValue color,
        'size': EJsonValue size,
      } =>
        PinRM(
          fromEJson(id),
          fromEJson(positionX),
          fromEJson(positionY),
          fromEJson(tooltip),
          fromEJson(shape),
          fromEJson(color),
          fromEJson(size),
          history: fromEJson(history),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(PinRM._);
    register(_toEJson, _fromEJson);
    return SchemaObject(ObjectType.embeddedObject, PinRM, 'PinRM', [
      SchemaProperty('id', RealmPropertyType.string),
      SchemaProperty('positionX', RealmPropertyType.double),
      SchemaProperty('positionY', RealmPropertyType.double),
      SchemaProperty('tooltip', RealmPropertyType.string),
      SchemaProperty('history', RealmPropertyType.object,
          linkTarget: 'PinHistoryRM', collectionType: RealmCollectionType.list),
      SchemaProperty('shape', RealmPropertyType.string),
      SchemaProperty('color', RealmPropertyType.string),
      SchemaProperty('size', RealmPropertyType.double),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class PinHistoryRM extends _PinHistoryRM
    with RealmEntity, RealmObjectBase, EmbeddedObject {
  PinHistoryRM(
    DateTime date,
    String data,
  ) {
    RealmObjectBase.set(this, 'date', date);
    RealmObjectBase.set(this, 'data', data);
  }

  PinHistoryRM._();

  @override
  DateTime get date => RealmObjectBase.get<DateTime>(this, 'date') as DateTime;
  @override
  set date(DateTime value) => RealmObjectBase.set(this, 'date', value);

  @override
  String get data => RealmObjectBase.get<String>(this, 'data') as String;
  @override
  set data(String value) => RealmObjectBase.set(this, 'data', value);

  @override
  Stream<RealmObjectChanges<PinHistoryRM>> get changes =>
      RealmObjectBase.getChanges<PinHistoryRM>(this);

  @override
  PinHistoryRM freeze() => RealmObjectBase.freezeObject<PinHistoryRM>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'date': date.toEJson(),
      'data': data.toEJson(),
    };
  }

  static EJsonValue _toEJson(PinHistoryRM value) => value.toEJson();
  static PinHistoryRM _fromEJson(EJsonValue ejson) {
    return switch (ejson) {
      {
        'date': EJsonValue date,
        'data': EJsonValue data,
      } =>
        PinHistoryRM(
          fromEJson(date),
          fromEJson(data),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(PinHistoryRM._);
    register(_toEJson, _fromEJson);
    return SchemaObject(
        ObjectType.embeddedObject, PinHistoryRM, 'PinHistoryRM', [
      SchemaProperty('date', RealmPropertyType.timestamp),
      SchemaProperty('data', RealmPropertyType.string),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class TextBoxRM extends _TextBoxRM
    with RealmEntity, RealmObjectBase, EmbeddedObject {
  TextBoxRM(
    String id,
    String creator,
    String lastEditor,
    DateTime creationDate,
    DateTime lastUpdateDate,
    double positionX,
    double positionY,
    String serializedContent,
    int bannerColor,
    bool bannerVisible,
    double width,
    double height,
  ) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'creator', creator);
    RealmObjectBase.set(this, 'lastEditor', lastEditor);
    RealmObjectBase.set(this, 'creationDate', creationDate);
    RealmObjectBase.set(this, 'lastUpdateDate', lastUpdateDate);
    RealmObjectBase.set(this, 'positionX', positionX);
    RealmObjectBase.set(this, 'positionY', positionY);
    RealmObjectBase.set(this, 'serializedContent', serializedContent);
    RealmObjectBase.set(this, 'bannerColor', bannerColor);
    RealmObjectBase.set(this, 'bannerVisible', bannerVisible);
    RealmObjectBase.set(this, 'width', width);
    RealmObjectBase.set(this, 'height', height);
  }

  TextBoxRM._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get creator => RealmObjectBase.get<String>(this, 'creator') as String;
  @override
  set creator(String value) => RealmObjectBase.set(this, 'creator', value);

  @override
  String get lastEditor =>
      RealmObjectBase.get<String>(this, 'lastEditor') as String;
  @override
  set lastEditor(String value) =>
      RealmObjectBase.set(this, 'lastEditor', value);

  @override
  DateTime get creationDate =>
      RealmObjectBase.get<DateTime>(this, 'creationDate') as DateTime;
  @override
  set creationDate(DateTime value) =>
      RealmObjectBase.set(this, 'creationDate', value);

  @override
  DateTime get lastUpdateDate =>
      RealmObjectBase.get<DateTime>(this, 'lastUpdateDate') as DateTime;
  @override
  set lastUpdateDate(DateTime value) =>
      RealmObjectBase.set(this, 'lastUpdateDate', value);

  @override
  double get positionX =>
      RealmObjectBase.get<double>(this, 'positionX') as double;
  @override
  set positionX(double value) => RealmObjectBase.set(this, 'positionX', value);

  @override
  double get positionY =>
      RealmObjectBase.get<double>(this, 'positionY') as double;
  @override
  set positionY(double value) => RealmObjectBase.set(this, 'positionY', value);

  @override
  String get serializedContent =>
      RealmObjectBase.get<String>(this, 'serializedContent') as String;
  @override
  set serializedContent(String value) =>
      RealmObjectBase.set(this, 'serializedContent', value);

  @override
  int get bannerColor => RealmObjectBase.get<int>(this, 'bannerColor') as int;
  @override
  set bannerColor(int value) => RealmObjectBase.set(this, 'bannerColor', value);

  @override
  bool get bannerVisible =>
      RealmObjectBase.get<bool>(this, 'bannerVisible') as bool;
  @override
  set bannerVisible(bool value) =>
      RealmObjectBase.set(this, 'bannerVisible', value);

  @override
  double get width => RealmObjectBase.get<double>(this, 'width') as double;
  @override
  set width(double value) => RealmObjectBase.set(this, 'width', value);

  @override
  double get height => RealmObjectBase.get<double>(this, 'height') as double;
  @override
  set height(double value) => RealmObjectBase.set(this, 'height', value);

  @override
  Stream<RealmObjectChanges<TextBoxRM>> get changes =>
      RealmObjectBase.getChanges<TextBoxRM>(this);

  @override
  TextBoxRM freeze() => RealmObjectBase.freezeObject<TextBoxRM>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'creator': creator.toEJson(),
      'lastEditor': lastEditor.toEJson(),
      'creationDate': creationDate.toEJson(),
      'lastUpdateDate': lastUpdateDate.toEJson(),
      'positionX': positionX.toEJson(),
      'positionY': positionY.toEJson(),
      'serializedContent': serializedContent.toEJson(),
      'bannerColor': bannerColor.toEJson(),
      'bannerVisible': bannerVisible.toEJson(),
      'width': width.toEJson(),
      'height': height.toEJson(),
    };
  }

  static EJsonValue _toEJson(TextBoxRM value) => value.toEJson();
  static TextBoxRM _fromEJson(EJsonValue ejson) {
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'creator': EJsonValue creator,
        'lastEditor': EJsonValue lastEditor,
        'creationDate': EJsonValue creationDate,
        'lastUpdateDate': EJsonValue lastUpdateDate,
        'positionX': EJsonValue positionX,
        'positionY': EJsonValue positionY,
        'serializedContent': EJsonValue serializedContent,
        'bannerColor': EJsonValue bannerColor,
        'bannerVisible': EJsonValue bannerVisible,
        'width': EJsonValue width,
        'height': EJsonValue height,
      } =>
        TextBoxRM(
          fromEJson(id),
          fromEJson(creator),
          fromEJson(lastEditor),
          fromEJson(creationDate),
          fromEJson(lastUpdateDate),
          fromEJson(positionX),
          fromEJson(positionY),
          fromEJson(serializedContent),
          fromEJson(bannerColor),
          fromEJson(bannerVisible),
          fromEJson(width),
          fromEJson(height),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(TextBoxRM._);
    register(_toEJson, _fromEJson);
    return SchemaObject(ObjectType.embeddedObject, TextBoxRM, 'TextBoxRM', [
      SchemaProperty('id', RealmPropertyType.string),
      SchemaProperty('creator', RealmPropertyType.string),
      SchemaProperty('lastEditor', RealmPropertyType.string),
      SchemaProperty('creationDate', RealmPropertyType.timestamp),
      SchemaProperty('lastUpdateDate', RealmPropertyType.timestamp),
      SchemaProperty('positionX', RealmPropertyType.double),
      SchemaProperty('positionY', RealmPropertyType.double),
      SchemaProperty('serializedContent', RealmPropertyType.string),
      SchemaProperty('bannerColor', RealmPropertyType.int),
      SchemaProperty('bannerVisible', RealmPropertyType.bool),
      SchemaProperty('width', RealmPropertyType.double),
      SchemaProperty('height', RealmPropertyType.double),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class StrokeRM extends _StrokeRM
    with RealmEntity, RealmObjectBase, EmbeddedObject {
  StrokeRM({
    Iterable<PointRM> points = const [],
    StrokeOptionsRM? options,
    StrokeStyleRM? style,
  }) {
    RealmObjectBase.set<RealmList<PointRM>>(
        this, 'points', RealmList<PointRM>(points));
    RealmObjectBase.set(this, 'options', options);
    RealmObjectBase.set(this, 'style', style);
  }

  StrokeRM._();

  @override
  RealmList<PointRM> get points =>
      RealmObjectBase.get<PointRM>(this, 'points') as RealmList<PointRM>;
  @override
  set points(covariant RealmList<PointRM> value) =>
      throw RealmUnsupportedSetError();

  @override
  StrokeOptionsRM? get options =>
      RealmObjectBase.get<StrokeOptionsRM>(this, 'options') as StrokeOptionsRM?;
  @override
  set options(covariant StrokeOptionsRM? value) =>
      RealmObjectBase.set(this, 'options', value);

  @override
  StrokeStyleRM? get style =>
      RealmObjectBase.get<StrokeStyleRM>(this, 'style') as StrokeStyleRM?;
  @override
  set style(covariant StrokeStyleRM? value) =>
      RealmObjectBase.set(this, 'style', value);

  @override
  Stream<RealmObjectChanges<StrokeRM>> get changes =>
      RealmObjectBase.getChanges<StrokeRM>(this);

  @override
  StrokeRM freeze() => RealmObjectBase.freezeObject<StrokeRM>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'points': points.toEJson(),
      'options': options.toEJson(),
      'style': style.toEJson(),
    };
  }

  static EJsonValue _toEJson(StrokeRM value) => value.toEJson();
  static StrokeRM _fromEJson(EJsonValue ejson) {
    return switch (ejson) {
      {
        'points': EJsonValue points,
        'options': EJsonValue options,
        'style': EJsonValue style,
      } =>
        StrokeRM(
          points: fromEJson(points),
          options: fromEJson(options),
          style: fromEJson(style),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(StrokeRM._);
    register(_toEJson, _fromEJson);
    return SchemaObject(ObjectType.embeddedObject, StrokeRM, 'StrokeRM', [
      SchemaProperty('points', RealmPropertyType.object,
          linkTarget: 'PointRM', collectionType: RealmCollectionType.list),
      SchemaProperty('options', RealmPropertyType.object,
          optional: true, linkTarget: 'StrokeOptionsRM'),
      SchemaProperty('style', RealmPropertyType.object,
          optional: true, linkTarget: 'StrokeStyleRM'),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class PointRM extends _PointRM
    with RealmEntity, RealmObjectBase, EmbeddedObject {
  PointRM(
    String type,
    double x,
    double y, {
    double? pressure,
    double? radius,
  }) {
    RealmObjectBase.set(this, 'type', type);
    RealmObjectBase.set(this, 'x', x);
    RealmObjectBase.set(this, 'y', y);
    RealmObjectBase.set(this, 'pressure', pressure);
    RealmObjectBase.set(this, 'radius', radius);
  }

  PointRM._();

  @override
  String get type => RealmObjectBase.get<String>(this, 'type') as String;
  @override
  set type(String value) => RealmObjectBase.set(this, 'type', value);

  @override
  double get x => RealmObjectBase.get<double>(this, 'x') as double;
  @override
  set x(double value) => RealmObjectBase.set(this, 'x', value);

  @override
  double get y => RealmObjectBase.get<double>(this, 'y') as double;
  @override
  set y(double value) => RealmObjectBase.set(this, 'y', value);

  @override
  double? get pressure =>
      RealmObjectBase.get<double>(this, 'pressure') as double?;
  @override
  set pressure(double? value) => RealmObjectBase.set(this, 'pressure', value);

  @override
  double? get radius => RealmObjectBase.get<double>(this, 'radius') as double?;
  @override
  set radius(double? value) => RealmObjectBase.set(this, 'radius', value);

  @override
  Stream<RealmObjectChanges<PointRM>> get changes =>
      RealmObjectBase.getChanges<PointRM>(this);

  @override
  PointRM freeze() => RealmObjectBase.freezeObject<PointRM>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'type': type.toEJson(),
      'x': x.toEJson(),
      'y': y.toEJson(),
      'pressure': pressure.toEJson(),
      'radius': radius.toEJson(),
    };
  }

  static EJsonValue _toEJson(PointRM value) => value.toEJson();
  static PointRM _fromEJson(EJsonValue ejson) {
    return switch (ejson) {
      {
        'type': EJsonValue type,
        'x': EJsonValue x,
        'y': EJsonValue y,
        'pressure': EJsonValue pressure,
        'radius': EJsonValue radius,
      } =>
        PointRM(
          fromEJson(type),
          fromEJson(x),
          fromEJson(y),
          pressure: fromEJson(pressure),
          radius: fromEJson(radius),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(PointRM._);
    register(_toEJson, _fromEJson);
    return SchemaObject(ObjectType.embeddedObject, PointRM, 'PointRM', [
      SchemaProperty('type', RealmPropertyType.string),
      SchemaProperty('x', RealmPropertyType.double),
      SchemaProperty('y', RealmPropertyType.double),
      SchemaProperty('pressure', RealmPropertyType.double, optional: true),
      SchemaProperty('radius', RealmPropertyType.double, optional: true),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class StrokeStyleRM extends _StrokeStyleRM
    with RealmEntity, RealmObjectBase, EmbeddedObject {
  StrokeStyleRM(
    double size,
    String color,
    bool taper,
    String cap,
  ) {
    RealmObjectBase.set(this, 'size', size);
    RealmObjectBase.set(this, 'color', color);
    RealmObjectBase.set(this, 'taper', taper);
    RealmObjectBase.set(this, 'cap', cap);
  }

  StrokeStyleRM._();

  @override
  double get size => RealmObjectBase.get<double>(this, 'size') as double;
  @override
  set size(double value) => RealmObjectBase.set(this, 'size', value);

  @override
  String get color => RealmObjectBase.get<String>(this, 'color') as String;
  @override
  set color(String value) => RealmObjectBase.set(this, 'color', value);

  @override
  bool get taper => RealmObjectBase.get<bool>(this, 'taper') as bool;
  @override
  set taper(bool value) => RealmObjectBase.set(this, 'taper', value);

  @override
  String get cap => RealmObjectBase.get<String>(this, 'cap') as String;
  @override
  set cap(String value) => RealmObjectBase.set(this, 'cap', value);

  @override
  Stream<RealmObjectChanges<StrokeStyleRM>> get changes =>
      RealmObjectBase.getChanges<StrokeStyleRM>(this);

  @override
  StrokeStyleRM freeze() => RealmObjectBase.freezeObject<StrokeStyleRM>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'size': size.toEJson(),
      'color': color.toEJson(),
      'taper': taper.toEJson(),
      'cap': cap.toEJson(),
    };
  }

  static EJsonValue _toEJson(StrokeStyleRM value) => value.toEJson();
  static StrokeStyleRM _fromEJson(EJsonValue ejson) {
    return switch (ejson) {
      {
        'size': EJsonValue size,
        'color': EJsonValue color,
        'taper': EJsonValue taper,
        'cap': EJsonValue cap,
      } =>
        StrokeStyleRM(
          fromEJson(size),
          fromEJson(color),
          fromEJson(taper),
          fromEJson(cap),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(StrokeStyleRM._);
    register(_toEJson, _fromEJson);
    return SchemaObject(
        ObjectType.embeddedObject, StrokeStyleRM, 'StrokeStyleRM', [
      SchemaProperty('size', RealmPropertyType.double),
      SchemaProperty('color', RealmPropertyType.string),
      SchemaProperty('taper', RealmPropertyType.bool),
      SchemaProperty('cap', RealmPropertyType.string),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class StrokeOptionsRM extends _StrokeOptionsRM
    with RealmEntity, RealmObjectBase, EmbeddedObject {
  StrokeOptionsRM({
    double? size,
    double? thinning,
    double? smoothing,
    double? streamline,
    bool? simulatePressure,
    StrokeEndOptionsRM? start,
    StrokeEndOptionsRM? end,
    bool? isComplete,
  }) {
    RealmObjectBase.set(this, 'size', size);
    RealmObjectBase.set(this, 'thinning', thinning);
    RealmObjectBase.set(this, 'smoothing', smoothing);
    RealmObjectBase.set(this, 'streamline', streamline);
    RealmObjectBase.set(this, 'simulatePressure', simulatePressure);
    RealmObjectBase.set(this, 'start', start);
    RealmObjectBase.set(this, 'end', end);
    RealmObjectBase.set(this, 'isComplete', isComplete);
  }

  StrokeOptionsRM._();

  @override
  double? get size => RealmObjectBase.get<double>(this, 'size') as double?;
  @override
  set size(double? value) => RealmObjectBase.set(this, 'size', value);

  @override
  double? get thinning =>
      RealmObjectBase.get<double>(this, 'thinning') as double?;
  @override
  set thinning(double? value) => RealmObjectBase.set(this, 'thinning', value);

  @override
  double? get smoothing =>
      RealmObjectBase.get<double>(this, 'smoothing') as double?;
  @override
  set smoothing(double? value) => RealmObjectBase.set(this, 'smoothing', value);

  @override
  double? get streamline =>
      RealmObjectBase.get<double>(this, 'streamline') as double?;
  @override
  set streamline(double? value) =>
      RealmObjectBase.set(this, 'streamline', value);

  @override
  bool? get simulatePressure =>
      RealmObjectBase.get<bool>(this, 'simulatePressure') as bool?;
  @override
  set simulatePressure(bool? value) =>
      RealmObjectBase.set(this, 'simulatePressure', value);

  @override
  StrokeEndOptionsRM? get start =>
      RealmObjectBase.get<StrokeEndOptionsRM>(this, 'start')
          as StrokeEndOptionsRM?;
  @override
  set start(covariant StrokeEndOptionsRM? value) =>
      RealmObjectBase.set(this, 'start', value);

  @override
  StrokeEndOptionsRM? get end =>
      RealmObjectBase.get<StrokeEndOptionsRM>(this, 'end')
          as StrokeEndOptionsRM?;
  @override
  set end(covariant StrokeEndOptionsRM? value) =>
      RealmObjectBase.set(this, 'end', value);

  @override
  bool? get isComplete =>
      RealmObjectBase.get<bool>(this, 'isComplete') as bool?;
  @override
  set isComplete(bool? value) => RealmObjectBase.set(this, 'isComplete', value);

  @override
  Stream<RealmObjectChanges<StrokeOptionsRM>> get changes =>
      RealmObjectBase.getChanges<StrokeOptionsRM>(this);

  @override
  StrokeOptionsRM freeze() =>
      RealmObjectBase.freezeObject<StrokeOptionsRM>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'size': size.toEJson(),
      'thinning': thinning.toEJson(),
      'smoothing': smoothing.toEJson(),
      'streamline': streamline.toEJson(),
      'simulatePressure': simulatePressure.toEJson(),
      'start': start.toEJson(),
      'end': end.toEJson(),
      'isComplete': isComplete.toEJson(),
    };
  }

  static EJsonValue _toEJson(StrokeOptionsRM value) => value.toEJson();
  static StrokeOptionsRM _fromEJson(EJsonValue ejson) {
    return switch (ejson) {
      {
        'size': EJsonValue size,
        'thinning': EJsonValue thinning,
        'smoothing': EJsonValue smoothing,
        'streamline': EJsonValue streamline,
        'simulatePressure': EJsonValue simulatePressure,
        'start': EJsonValue start,
        'end': EJsonValue end,
        'isComplete': EJsonValue isComplete,
      } =>
        StrokeOptionsRM(
          size: fromEJson(size),
          thinning: fromEJson(thinning),
          smoothing: fromEJson(smoothing),
          streamline: fromEJson(streamline),
          simulatePressure: fromEJson(simulatePressure),
          start: fromEJson(start),
          end: fromEJson(end),
          isComplete: fromEJson(isComplete),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(StrokeOptionsRM._);
    register(_toEJson, _fromEJson);
    return SchemaObject(
        ObjectType.embeddedObject, StrokeOptionsRM, 'StrokeOptionsRM', [
      SchemaProperty('size', RealmPropertyType.double, optional: true),
      SchemaProperty('thinning', RealmPropertyType.double, optional: true),
      SchemaProperty('smoothing', RealmPropertyType.double, optional: true),
      SchemaProperty('streamline', RealmPropertyType.double, optional: true),
      SchemaProperty('simulatePressure', RealmPropertyType.bool,
          optional: true),
      SchemaProperty('start', RealmPropertyType.object,
          optional: true, linkTarget: 'StrokeEndOptionsRM'),
      SchemaProperty('end', RealmPropertyType.object,
          optional: true, linkTarget: 'StrokeEndOptionsRM'),
      SchemaProperty('isComplete', RealmPropertyType.bool, optional: true),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class StrokeEndOptionsRM extends _StrokeEndOptionsRM
    with RealmEntity, RealmObjectBase, EmbeddedObject {
  StrokeEndOptionsRM(
    bool cap,
    bool taperEnabled,
    double customTaper,
  ) {
    RealmObjectBase.set(this, 'cap', cap);
    RealmObjectBase.set(this, 'taperEnabled', taperEnabled);
    RealmObjectBase.set(this, 'customTaper', customTaper);
  }

  StrokeEndOptionsRM._();

  @override
  bool get cap => RealmObjectBase.get<bool>(this, 'cap') as bool;
  @override
  set cap(bool value) => RealmObjectBase.set(this, 'cap', value);

  @override
  bool get taperEnabled =>
      RealmObjectBase.get<bool>(this, 'taperEnabled') as bool;
  @override
  set taperEnabled(bool value) =>
      RealmObjectBase.set(this, 'taperEnabled', value);

  @override
  double get customTaper =>
      RealmObjectBase.get<double>(this, 'customTaper') as double;
  @override
  set customTaper(double value) =>
      RealmObjectBase.set(this, 'customTaper', value);

  @override
  Stream<RealmObjectChanges<StrokeEndOptionsRM>> get changes =>
      RealmObjectBase.getChanges<StrokeEndOptionsRM>(this);

  @override
  StrokeEndOptionsRM freeze() =>
      RealmObjectBase.freezeObject<StrokeEndOptionsRM>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'cap': cap.toEJson(),
      'taperEnabled': taperEnabled.toEJson(),
      'customTaper': customTaper.toEJson(),
    };
  }

  static EJsonValue _toEJson(StrokeEndOptionsRM value) => value.toEJson();
  static StrokeEndOptionsRM _fromEJson(EJsonValue ejson) {
    return switch (ejson) {
      {
        'cap': EJsonValue cap,
        'taperEnabled': EJsonValue taperEnabled,
        'customTaper': EJsonValue customTaper,
      } =>
        StrokeEndOptionsRM(
          fromEJson(cap),
          fromEJson(taperEnabled),
          fromEJson(customTaper),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(StrokeEndOptionsRM._);
    register(_toEJson, _fromEJson);
    return SchemaObject(
        ObjectType.embeddedObject, StrokeEndOptionsRM, 'StrokeEndOptionsRM', [
      SchemaProperty('cap', RealmPropertyType.bool),
      SchemaProperty('taperEnabled', RealmPropertyType.bool),
      SchemaProperty('customTaper', RealmPropertyType.double),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
