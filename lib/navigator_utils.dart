import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hl_core/base/screen.dart';
import 'package:hl_core/common/brightness.dart';
import 'package:hl_core/utils/print.dart';
import 'package:hl_core/extension/standard.dart';
import 'package:hl_core/extension/list_ext.dart';

import 'navigator.dart';
import 'page_state_mapping.dart';

class NavigatorUtils {

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
        state: pageState,
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

  static bool handleBackPressed(BuildContext context) {
    final Widget? currentWidget = getCurrentWidget(context);
    if (currentWidget is! Screen) {
      return false;
    }

    return currentWidget.events[ScreenEvent.backPressed]?.run(null) ?? false;
  }

  static bool handlePushEvent<T>(BuildContext context, T data) {
    final Widget? currentWidget = getCurrentWidget(context);
    if (currentWidget is! Screen) {
      return false;
    }

    return currentWidget.events[ScreenEvent.pushMessage]?.run(data) ?? false;
  }

  static Widget? getCurrentWidget(BuildContext context) {
    final AppRouterDelegate delegate = AppRouterDelegate.of(context);
    return delegate.pages.lastOrNull()?.pageConfiguration.child;
  }

}
