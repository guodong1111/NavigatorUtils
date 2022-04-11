import 'package:flutter/material.dart';

import 'navigator.dart';

abstract class PageInterceptor {
  Future<Widget?> interceptor(Widget child);
  Future<void> afterInterceptor(Widget child);
}
