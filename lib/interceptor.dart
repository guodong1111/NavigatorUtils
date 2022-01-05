import 'package:flutter/material.dart';

import 'navigator.dart';

abstract class PageInterceptor {
  Future<Widget> interceptor(BuildContext context, Widget child);
}
