import 'package:flutter/material.dart';

import 'navigator.dart';

class AppBackButtonDispatcher extends RootBackButtonDispatcher {
  AppBackButtonDispatcher(this._routerDelegate) : super();

  final AppRouterDelegate _routerDelegate;

  @override
  Future<bool> didPopRoute() async {
    if (await _routerDelegate.handleBackPressed()) {
      return true;
    }

    return _routerDelegate.popRoute();
  }
}
