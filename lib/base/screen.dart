import 'package:flutter/material.dart';

mixin Screen on StatefulWidget {
  final ScreenEvents events = ScreenEvents();
}

mixin ScreenState<T extends Screen> on State<T> {
  @override
  void initState() {
    super.initState();
    initWidgetEvents();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);

    oldWidget.events.clear();

    initWidgetEvents();
  }

  void initWidgetEvents() {
    widget.events[ScreenEvent.update] = (data) async {
      updateByNewScreen(data as T);
      return false;
    };
    widget.events[ScreenEvent.backPressed] = (_) => onBackPressed();
  }

  @override
  void dispose() {
    super.dispose();
    widget.events.clear();
  }

  // return true means the event has been consumed
  void updateByNewScreen(T newScreen) {}

  // return true means the event has been consumed
  Future<bool> onBackPressed() async {
    return false;
  }
}

enum ScreenEvent { backPressed, update }

// return true means the event has been consumed
typedef ScreenEvents = Map<ScreenEvent, Future<bool> Function(dynamic)>;
