import 'package:flutter/material.dart';

import 'navigator.dart';

abstract class PageObserver {
  void onPagePush(BuildContext context, Widget child);
}