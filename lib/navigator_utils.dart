import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hl_core/common/brightness.dart';
import 'package:hl_core/utils/print.dart';

import 'navigator.dart';
import 'page_state_mapping.dart';

class NavigatorUtils {

  static PageStateMapping? _stateMapping;

  static setStateMapping(PageStateMapping stateMapping) {
    _stateMapping = stateMapping;
  }

  static Future<dynamic> push(
    BuildContext context,
    Widget child, {
    PageState? pageState,
    bool fullscreenDialog = false,
    bool maintainState = true,
    TransitionType transitionType = TransitionType.none,
    RouteTransitionsBuilder? transition,
    Brightness? brightness,
  }) {
    printD('[Navigator] NavigatorUtils => push');
    brightness ??= (child is BrightnessMixin)
        ? child.brightness
        : Theme.of(context).brightness;

    final AppRouterDelegate delegate = AppRouterDelegate.of(context);

    final PageParameter pageParameter = PageParameter(
        state: pageState ??
            _stateMapping?.getState(child, delegate.isExist) ??
            PageState.none,
        fullscreenDialog: fullscreenDialog,
        maintainState: maintainState,
        transitionType: transitionType,
        transition: transition,
        brightness: brightness);

    return delegate.push(child, pageParameter: pageParameter);
  }

  static bool canPop(BuildContext context) {
    final AppRouterDelegate delegate = AppRouterDelegate.of(context);
    return delegate.canPop();
  }

  static void pop(BuildContext context, {dynamic result}) {
    printD('[Navigator] NavigatorUtils => pop');
    final AppRouterDelegate delegate = AppRouterDelegate.of(context);

    if (canPop(context)) {
      delegate.pop(result);
    }
  }

  //pop之后会走进WillPopScope的回调中
  static void mayBePop(BuildContext context, {dynamic result}) {
    printD('[Navigator] NavigatorUtils => pop');
    final AppRouterDelegate delegate = AppRouterDelegate.of(context);

    if (canPop(context)) {
      delegate.mayBePop(result);
    }
  }

}
