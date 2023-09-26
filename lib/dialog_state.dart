
import 'package:flutter/material.dart';

import 'route_page.dart';

class DialogState extends NavigatorObserver {

  DialogState(this.currentPage);

  final RoutePage<dynamic>? Function() currentPage;
  final Map<RoutePage<dynamic>?, bool> dialogStateMap = Map<RoutePage<dynamic>, bool>();

  bool isDialogShowing(RoutePage<dynamic>? page) {
    return dialogStateMap[page] ?? false;
  }

  void onPushModalBottomSheet() {
    print('[Navigator] push ModalBottomSheet in ${currentPage()?.name}');
    dialogStateMap[currentPage()] = true;
  }

  void onPushDialog() {
    print('[Navigator] push Dialog in ${currentPage()?.name}');
    dialogStateMap[currentPage()] = true;
  }

  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (null == route.settings.name) {
      print('[Navigator] pop Dialog/ModalBottomSheet in ${currentPage()?.name}');
      dialogStateMap[currentPage()] = false;
    }
  }

}