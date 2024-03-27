import 'dart:async';

import 'package:flutter/material.dart';

class HeroDialogRoute<T> extends PageRoute<T> {
  /// {@macro hero_dialog_route}
  HeroDialogRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
    super.fullscreenDialog = true,
  }) : _builder = builder;

  final WidgetBuilder _builder;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  bool get maintainState => true;

  @override
  Color get barrierColor => Colors.black54;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return child;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return _builder(context);
  }

  @override
  String get barrierLabel => 'Popup dialog open';
}

class HeroTransparentDialogRoute<T> extends PageRoute<T> {
  /// {@macro hero_dialog_route}
  HeroTransparentDialogRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
    super.fullscreenDialog = true,
  }) : _builder = builder;

  final WidgetBuilder _builder;
  late AnimationController _controller;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  bool get maintainState => true;

  @override
  Color get barrierColor => Colors.black26;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return child;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return _builder(context);
  }

  @override
  String get barrierLabel => 'Popup dialog open';
}

class DelayedHeroDialogRoute<T> extends PageRoute<T> {
  DelayedHeroDialogRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
    super.fullscreenDialog = true,
  }) : _builder = builder;

  final WidgetBuilder _builder;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  bool get maintainState => true;

  @override
  Color get barrierColor => Colors.black54;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return child;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: transitionDuration,
      child: ValueListenableBuilder<double>(
        valueListenable: animation,
        builder: (context, value, child) {
          // Only render the content of the new page when the animation is complete
          if (value == 1.0) {
            return _builder(context);
          } else {
            return Container(); // Return an empty container during the transition
          }
        },
      ),
    );
  }

  @override
  String get barrierLabel => 'Popup dialog open';
}

class DelayedHeroTransparentDialogRoute<T> extends PageRoute<T> {
  DelayedHeroTransparentDialogRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
    super.fullscreenDialog = true,
  }) : _builder = builder;

  final WidgetBuilder _builder;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  bool get maintainState => true;

  @override
  Color get barrierColor => Colors.black26;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return child;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return ValueListenableBuilder<double>(
      valueListenable: animation,
      builder: (context, value, child) {
        // Only render the content of the new page when the animation is complete
        if (value == 1.0) {
          return _builder(context);
        } else {
          return Container(); // Return an empty container during the transition
        }
      },
    );
  }

  @override
  String get barrierLabel => 'Popup dialog open';
}

class FutureHeroTransparentDialogRoute<T> extends PageRoute<T> {
  late RouteObserver _routeObserver;
  final Completer<void> _completer = Completer<void>();
  final VoidCallback onRouteChanged;

  FutureHeroTransparentDialogRoute(
      this._routeObserver, {
        required WidgetBuilder builder,
        required this.onRouteChanged,
        RouteSettings? settings,
        super.fullscreenDialog = true,
      }) : _builder = builder {
    _routeObserver = RouteObserver(onRouteChanged: () {
      onRouteChanged();
      if (!_completer.isCompleted) {
        _completer.complete();
      }
    });
    WidgetsBinding.instance.addObserver(_routeObserver);
  }

  final WidgetBuilder _builder;
  Future<void> get finishedBuilding => _completer.future;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_routeObserver);
    super.dispose();
  }

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  bool get maintainState => true;

  @override
  Color get barrierColor => Colors.black26;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return child;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return _builder(context);
  }

  @override
  String get barrierLabel => 'Popup dialog open';
}

class SlideFromRightHeroTransparentDialogRoute<T> extends PageRoute<T> {
  SlideFromRightHeroTransparentDialogRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
    super.fullscreenDialog = true,
  }) : _builder = builder;

  final WidgetBuilder _builder;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  bool get maintainState => true;

  @override
  Color get barrierColor => Colors.black26;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
      opacity: Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(animation),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return _builder(context);
  }

  @override
  String get barrierLabel => 'Popup dialog open';
}

class RouteObserver extends WidgetsBindingObserver {
  final VoidCallback onRouteChanged;

  RouteObserver({required this.onRouteChanged});

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (WidgetsBinding.instance!.window.viewInsets.bottom == 0.0) {
      onRouteChanged();
    }
  }
}
