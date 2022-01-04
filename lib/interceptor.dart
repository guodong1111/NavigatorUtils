import 'package:flutter/material.dart';

import 'navigator.dart';

abstract class PageInterceptor {
  bool interceptor(Widget child);
}
