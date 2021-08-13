import 'package:flutter/material.dart';

import 'navigator.dart';

abstract class PageStateMapping {
  PageState getState(Widget child, bool Function(Widget) isExist);
}
