import 'package:flutter/material.dart';

abstract class PageObserver {
  void onPagePush(BuildContext context, Widget child);
  void onPagePop(BuildContext context, Widget child);
}
