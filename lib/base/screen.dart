import 'package:flutter/material.dart';

abstract class Screen extends StatefulWidget {
  final ScreenEvents events = ScreenEvents();

  Screen({
    Key? key,
  }) : super(key: key);
}

abstract class ScreenState<T extends Screen> extends State<T> {
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
    widget.events[ScreenEvent.update] = (data) => updateByNewScreen(data as T);
    widget.events[ScreenEvent.backPressed] = (_) => onBackPressed();
    widget.events[ScreenEvent.pushMessage] = handlePushMessage;
  }

  @override
  void dispose() {
    super.dispose();
    widget.events.clear();
  }

  // return true means the event has been consumed
  Future<bool> updateByNewScreen(T newScreen) async {
    return false;
  }

  // return true means the event has been consumed
  Future<bool> handlePushMessage(dynamic) async {
    return false;
  }

  // return true means the event has been consumed
  Future<bool> onBackPressed() async {
    return false;
  }
}

enum ScreenEvent { backPressed, pushMessage, update }

// return true means the event has been consumed
typedef ScreenEvents = Map<ScreenEvent, Future<bool> Function(dynamic)>;
