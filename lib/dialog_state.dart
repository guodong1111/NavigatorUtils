import 'package:flutter/material.dart';

import 'route_page.dart';

class DialogState extends NavigatorObserver {
  DialogState(this.currentPage);

  final RoutePage<dynamic>? Function() currentPage;
  final Map<RoutePage<dynamic>?, Widget?> dialogStateMap = Map<RoutePage<dynamic>, Widget?>();

  bool isDialogShowing(RoutePage<dynamic>? page) {
    return null != dialogStateMap[page];
  }

  Widget? getWidget(RoutePage<dynamic>? page) {
    return dialogStateMap[page];
  }

  void onPushModalBottomSheet(Widget child) {
    print('[Navigator] push ModalBottomSheet in ${currentPage()?.name}');
    dialogStateMap[currentPage()] = child;
  }

  void onPushDialog(Widget child) {
    print('[Navigator] push Dialog in ${currentPage()?.name}');
    dialogStateMap[currentPage()] = child;
  }

  void removeState(RoutePage<dynamic> routePage) {
    print('[Navigator] removeState ${routePage.name}');
    dialogStateMap[routePage] = null;
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (null == route.settings.name) {
      print('[Navigator] pop Dialog/ModalBottomSheet in ${currentPage()?.name}');
      dialogStateMap[currentPage()] = null;
    }
  }
}
