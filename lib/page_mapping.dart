import 'package:flutter/material.dart';

import 'navigator.dart';

abstract class PagePathMapping {
  String getPath(Widget child);
}

abstract class PageStateMapping {
  PageState getState(Widget child, bool Function(Widget) isExist);
}
