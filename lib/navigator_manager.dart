import 'package:flutter/material.dart';
import 'package:hl_core/base/screen.dart';
import 'package:hl_core/extension/list_ext.dart';
import 'package:hl_core/extension/standard.dart';

import 'route_page.dart';

class NavigatorManager extends BackButtonDispatcher {
  NavigatorManager._internal();

  static NavigatorManager? _singleton;

  static NavigatorManager getInstance() {
    _singleton ??= NavigatorManager._internal();
    return _singleton!;
  }

  final List<RoutePage<dynamic>> pages = <RoutePage<dynamic>>[];

  bool handleBackPressed() {
    final Widget? currentWidget = getCurrentWidget();
    if (currentWidget is! Screen) {
      return false;
    }

    return currentWidget.events[ScreenEvent.backPressed]?.run(null) ?? false;
  }

  bool handlePushEvent<T>(T data) {
    final Widget? currentWidget = getCurrentWidget();
    if (currentWidget is! Screen) {
      return false;
    }

    return currentWidget.events[ScreenEvent.pushMessage]?.run(data) ?? false;
  }

  Widget? getCurrentWidget() {
    return pages.lastOrNull()?.pageConfiguration.child;
  }

}
