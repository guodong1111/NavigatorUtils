import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hl_core/utils/print.dart';

import 'interceptor.dart';
import 'navigator.dart';

class NavigatorUtils {

  static Future<dynamic> push(
    BuildContext context,
    Widget child, {
    PageState? pageState,
    bool fullscreenDialog = false,
    bool maintainState = true,
    TransitionType transitionType = TransitionType.none,
    RouteTransitionsBuilder? transition,
  }) async {
    printD('[Navigator] NavigatorUtils => push');

    final AppRouterDelegate delegate = AppRouterDelegate.of(context);

    PageInterceptor? interceptor = delegate.pageInterceptor;
    if (null != interceptor) {
      Widget? newChild = await interceptor.interceptor(context, child);
      if (null == newChild) {
        printD('[Navigator] NavigatorUtils => interceptor(${child.runtimeType})');
        return;
      }
      child = newChild;
    }

    final PageParameter pageParameter = PageParameter(
        state: pageState,
        fullscreenDialog: fullscreenDialog,
        maintainState: maintainState,
        transitionType: transitionType,
        transition: transition);

    dynamic result = await delegate.push(child, pageParameter: pageParameter);

    if (null != interceptor) {
      await interceptor.afterInterceptor(context, child);
    }

    return result;
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

  static Future<bool> handleBackPressed(BuildContext context) async {
    final AppRouterDelegate delegate = AppRouterDelegate.of(context);
    return delegate.handleBackPressed();
  }

  static Future<bool> handlePushEvent<T>(BuildContext context, T data) async {
    final AppRouterDelegate delegate = AppRouterDelegate.of(context);
    return delegate.handlePushEvent(data);
  }
}
