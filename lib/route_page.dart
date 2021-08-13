import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hl_core/common/brightness.dart';
import 'package:hl_core/common/theme_wrapper.dart';
import 'package:hl_core/extension/standard.dart';
import 'package:hl_core/utils/print.dart';

enum PageState { none, replace, clearStack, popOnTop }
enum TransitionType {
  none,
  inFromLeft,
  inFromTop,
  inFromRight,
  inFromBottom,
  fadeIn,
  custom
}

class PageParameter {
  const PageParameter(
      {this.state = PageState.none,
      this.fullscreenDialog = false,
      this.maintainState = true,
      this.transitionType = TransitionType.none,
      this.transition,
      this.brightness});

  final PageState state;
  final bool fullscreenDialog;
  final Brightness? brightness;
  final bool maintainState;
  final TransitionType transitionType;
  final RouteTransitionsBuilder? transition;
}

class PageConfiguration {
  PageConfiguration(
      {LocalKey? key,
      required this.path,
      required this.child,
      this.pageParameter = const PageParameter()})
      : key = key ?? ObjectKey(child);

  final LocalKey key;
  final String path;
  final Widget child;
  final PageParameter pageParameter;

  RoutePage<T?> toPage<T extends Object?>() {
    return RoutePage<T>(this);
  }
}

class RoutePage<T> extends Page<T> {
  RoutePage(this.pageConfiguration)
      : super(
          key: pageConfiguration.key,
          name: pageConfiguration.path,
          arguments: pageConfiguration,
        );

  final PageConfiguration pageConfiguration;

  /// A future that completes when this route is popped off the navigator.
  ///
  /// The future completes with the value given to [Navigator.pop], if any, or
  /// else the value of [null].
  Future<T> get popped => _popCompleter.future;
  final Completer<T> _popCompleter = Completer<T>();

  bool get isCompleted => _popCompleter.isCompleted;

  /// pop this route
  bool didPop([T? result]) {
    if (!_popCompleter.isCompleted) {
      _popCompleter.complete(result);
    }
    return true;
  }

  @override
  Route<T> createRoute(BuildContext context) {
    final Route<T> route = _createRoute(context);
    return route
      ..popped.then((T? value) {
        if (!isCompleted) {
          _popCompleter.complete(value);
        }
      });
  }

  Route<T> _createRoute(BuildContext context) {
    final PageParameter pageParameter = pageConfiguration.pageParameter;

    Brightness? brightness = pageParameter.brightness;
    brightness ??= pageConfiguration.child.let<Brightness>((Widget widget) {
      return (widget is BrightnessMixin)
          ? widget.brightness
          : Theme.of(context).brightness;
    });

    final Widget child =
        ThemeWrapper(brightness: brightness, child: pageConfiguration.child);

    final TransitionType transitionType = pageParameter.transitionType;

    if (transitionType != TransitionType.none) {
      assert(
          (transitionType == TransitionType.custom &&
                  pageParameter.transition != null) ||
              transitionType != TransitionType.custom,
          'transitionsBuilder not set');
      printD('[Navigator] transition routePage $transitionType');

      return PageRouteBuilder<T>(
        settings: this,
        maintainState: pageParameter.maintainState,
        fullscreenDialog: pageParameter.fullscreenDialog,
        pageBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secondaryAnimation) =>
            child,
        transitionsBuilder: transitionType == TransitionType.custom
            ? pageParameter.transition!
            : _transitionsBuilder(transitionType),
      );
    } else {
      return MaterialPageRoute<T>(
        settings: this,
        builder: (BuildContext context) {
          return child;
        },
        fullscreenDialog: pageParameter.fullscreenDialog,
        maintainState: pageParameter.maintainState,
      );
    }
  }

  RouteTransitionsBuilder _transitionsBuilder(TransitionType transitionType) {
    return (BuildContext context, Animation<double> animation,
        Animation<double> secondaryAnimation, Widget child) {
      if (transitionType == TransitionType.fadeIn) {
        return FadeTransition(opacity: animation, child: child);
      } else {
        const Offset topLeft = Offset(0.0, 0.0);
        const Offset topRight = Offset(1.0, 0.0);
        const Offset bottomLeft = Offset(0.0, 1.0);

        Offset startOffset = bottomLeft;
        Offset endOffset = topLeft;
        if (transitionType == TransitionType.inFromLeft) {
          startOffset = const Offset(-1.0, 0.0);
          endOffset = topLeft;
        } else if (transitionType == TransitionType.inFromRight) {
          startOffset = topRight;
          endOffset = topLeft;
        } else if (transitionType == TransitionType.inFromBottom) {
          startOffset = bottomLeft;
          endOffset = topLeft;
        } else if (transitionType == TransitionType.inFromTop) {
          startOffset = const Offset(0.0, -1.0);
          endOffset = topLeft;
        }

        return SlideTransition(
          position: Tween<Offset>(
            begin: startOffset,
            end: endOffset,
          ).animate(animation),
          child: child,
        );
      }
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoutePage &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          name == other.name;

  @override
  int get hashCode => key.hashCode ^ name.hashCode;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'arguments': arguments,
        'key': key,
      };
}
