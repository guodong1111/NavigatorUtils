import 'package:flutter/material.dart';

abstract class PageInterceptor {
  Future<Widget?> interceptor(BuildContext context, Widget child);
  Future<void> afterInterceptor(BuildContext context, Widget child);
}
