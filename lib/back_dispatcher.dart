
import 'package:flutter/material.dart';

import 'navigator.dart';
import 'navigator_manager.dart';

class AppBackButtonDispatcher extends RootBackButtonDispatcher {
  AppBackButtonDispatcher(this._routerDelegate) : super();

  final AppRouterDelegate _routerDelegate;
  final NavigatorManager navigatorManager = NavigatorManager.getInstance();

  @override
  Future<bool> didPopRoute() async {
    if (navigatorManager.handleBackPressed()) {
      return true;
    }

    return _routerDelegate.popRoute();
  }
}