import 'package:flutter/material.dart';
import 'package:navigator_utils/extension/list_ext.dart';

import 'interceptor.dart';
import 'navigator.dart';

class NavigatorUtils {
  static Future<T?> push<T>(
    BuildContext context,
    Widget child, {
    PageState? pageState,
    bool fullscreenDialog = false,
    bool maintainState = true,
    TransitionType transitionType = TransitionType.none,
    RouteTransitionsBuilder? transition,
  }) {
    return _push<T>(
      context,
      child,
      block: (delegate) {
        final PageParameter pageParameter = PageParameter(
            state: pageState,
            fullscreenDialog: fullscreenDialog,
            maintainState: maintainState,
            transitionType: transitionType,
            transition: transition);

        return delegate.push<T>(child, pageParameter: pageParameter);
      },
    );
  }

  static Future<T?> pushModalBottomSheet<T>(
    BuildContext context,
    Widget child, {
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    BoxConstraints? constraints,
    Color? barrierColor,
    bool isScrollControlled = false,
    bool useRootNavigator = false,
    bool isDismissible = true,
    bool enableDrag = true,
    bool? showDragHandle,
    bool useSafeArea = false,
    RouteSettings? routeSettings,
    AnimationController? transitionAnimationController,
    Offset? anchorPoint,
  }) {
    return _push<T>(
      context,
      child,
      block: (_) {
        return showModalBottomSheet<T>(
          context: context,
          builder: (context) => child,
          backgroundColor: backgroundColor ?? Colors.transparent,
          elevation: elevation,
          shape: shape,
          clipBehavior: clipBehavior,
          constraints: constraints,
          barrierColor: barrierColor,
          isScrollControlled: isScrollControlled,
          useRootNavigator: useRootNavigator,
          isDismissible: isDismissible,
          enableDrag: enableDrag,
          showDragHandle: showDragHandle,
          useSafeArea: useSafeArea,
          routeSettings: routeSettings,
          transitionAnimationController: transitionAnimationController,
          anchorPoint: anchorPoint,
        );
      },
    );
  }

  static Future<T?> pushDialog<T>(
    BuildContext context,
    Widget child, {
    bool barrierDismissible = true,
    Color? barrierColor = Colors.black54,
    String? barrierLabel,
    bool useSafeArea = true,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
  }) {
    return _push<T>(
      context,
      child,
      block: (_) {
        return showDialog<T>(
          context: context,
          builder: (context) => child,
          barrierDismissible: barrierDismissible,
          barrierColor: barrierColor,
          barrierLabel: barrierLabel,
          useSafeArea: useSafeArea,
          useRootNavigator: useRootNavigator,
          routeSettings: routeSettings,
        );
      },
    );
  }

  static Future<T?> _push<T>(
    BuildContext context,
    Widget child, {
    required Future<T?> Function(AppRouterDelegate delegate) block,
  }) async {
    print('[Navigator] NavigatorUtils => push');
    final AppRouterDelegate delegate = _getAppRouterDelegate(context);

    PageInterceptor? interceptor = delegate.pageInterceptor;
    if (null != interceptor) {
      Widget? newChild = await interceptor.interceptor(context, child);
      if (null == newChild) {
        print(
            '[Navigator] NavigatorUtils => interceptor(${child.runtimeType})');
        return null;
      }
      child = newChild;
    }

    delegate.pageObserver?.onPagePush(context, child);
    T? result = await block(delegate);

    if (null != interceptor) {
      await interceptor.afterInterceptor(context, child);
    }

    return result;
  }

  static bool canPop(BuildContext context) {
    final AppRouterDelegate delegate = _getAppRouterDelegate(context);
    return delegate.canPop();
  }

  static void pop(BuildContext context, {dynamic result}) {
    print('[Navigator] NavigatorUtils => pop');
    final AppRouterDelegate delegate = _getAppRouterDelegate(context);

    if (canPop(context)) {
      delegate.pop(result);
    }
  }

  //pop之后会走进WillPopScope的回调中
  static void mayBePop(BuildContext context, {dynamic result}) {
    print('[Navigator] NavigatorUtils => mayBePop');
    final AppRouterDelegate delegate = _getAppRouterDelegate(context);

    if (canPop(context)) {
      delegate.mayBePop(result);
    }
  }

  static Widget getCurrentPage(BuildContext context) {
    final AppRouterDelegate delegate = _getAppRouterDelegate(context);
    return delegate.pages.last.pageConfiguration.child;
  }

  static Widget? getPreviousPage(BuildContext context) {
    final AppRouterDelegate delegate = _getAppRouterDelegate(context);
    return delegate.pages
        .getOrNull(delegate.pages.length - 2)
        ?.pageConfiguration
        .child;
  }

  static Future<bool> handleBackPressed(BuildContext context) async {
    final AppRouterDelegate delegate = _getAppRouterDelegate(context);

    if (await delegate.handleBackPressed()) {
      return true;
    }

    return delegate.popRoute();
  }

  static AppRouterDelegate _getAppRouterDelegate(BuildContext context) {
    return currentRouterDelegate ?? AppRouterDelegate.of(context);
  }
}
