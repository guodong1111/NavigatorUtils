import 'package:flutter/material.dart';

import 'navigator.dart';

abstract class PageInterceptor {
  Future<bool> interceptor(Widget child);
}
