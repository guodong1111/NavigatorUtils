import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hl_core/base/screen.dart';
import 'package:hl_core/extension/list_ext.dart';
import 'package:hl_core/extension/standard.dart';
import 'package:hl_core/utils/print.dart';

import 'interceptor.dart';
import 'navigator.dart';
import 'page_observer.dart';

/// Signature for the [AppRouterDelegate.popUntil] predicate argument.
typedef PagePredicate = bool Function(RoutePage<dynamic> page);

AppRouterDelegate? currentRouterDelegate;

class AppRouterDelegate extends RouterDelegate<PageMatchList>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<PageMatchList> {
  AppRouterDelegate({
    GlobalKey<NavigatorState>? navigatorKey,
    this.observers,
    this.pageObserver,
    this.pagePathMapping,
    this.stateMapping,
    this.pageInterceptor,
    this.transitionDelegate = const DefaultTransitionDelegate<dynamic>(),
  }) : this.navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>() {
    currentRouterDelegate = this;
  }

  static const String PATH_HOME = '/';

  final TransitionDelegate<dynamic> transitionDelegate;

  final List<NavigatorObserver>? observers;

  final PageObserver? pageObserver;
  final PagePathMapping? pagePathMapping;
  final PageStateMapping? stateMapping;
  final PageInterceptor? pageInterceptor;

  final List<RoutePage<dynamic>> pages = <RoutePage<dynamic>>[];

  @override
  final GlobalKey<NavigatorState> navigatorKey;

  NavigatorState? get navigatorState => navigatorKey.currentState;

  @override
  PageMatchList? get currentConfiguration => pages.isNotEmpty
      ? PageMatchList(pages.map((e) => e.pageConfiguration).toList())
      : null;

  static AppRouterDelegate of(BuildContext context) {
    final RouterDelegate<dynamic> delegate = Router.of(context).routerDelegate;
    assert(delegate is RouterDelegate, 'Delegate type must match');
    return delegate as AppRouterDelegate;
  }

  @override
  Widget build(BuildContext context) {
    printD(
        '[Navigator] delegate path ${pages.map((RoutePage<dynamic> e) => e.pageConfiguration.path).toList()}');
    printD(
        '[Navigator] delegate ${pages.map((RoutePage<dynamic> e) => e.pageConfiguration.key).toList()}');
    if (pages.isEmpty) {
      return Container();
    }

    final Navigator navigator = Navigator(
      pages: pages.toList(),
      key: navigatorKey,
      reportsRouteUpdateToEngine: false,
      onPopPage: (Route<dynamic> route, dynamic result) {
        if (pages.length > 1 && route.settings is RoutePage) {
          final RoutePage<dynamic>? removed = pages.lastWhereIndexedOrNull(
            (int index, RoutePage<dynamic> element) =>
                element.name == route.settings.name,
          );
          if (removed != null) {
            pages.remove(removed);
            _updatePages();
          }
        }
        return route.didPop(result);
      },
      observers: <NavigatorObserver>[if (observers != null) ...observers!],
    );
    return navigator;
  }

  void setPages(List<RoutePage<dynamic>> newPages) {
    pages
      ..clear()
      ..addAll(newPages);
    _updatePages();
  }

  Future<void> setRootWidget(Widget rootWidget) async {
    printD('[Navigator] setRootWidget $rootWidget');
    final PageMatchList pageMatchList = PageMatchList(
        [PageConfiguration(path: getPath(rootWidget), child: rootWidget)]);
    setNewRoutePath(pageMatchList);
  }

  Future<void> setRootWidgets(List<Widget> rootWidgets) async {
    printD('[Navigator] setRootWidgets $rootWidgets');
    final PageMatchList pageMatchList = PageMatchList(rootWidgets
        .map((e) => PageConfiguration(path: getPath(e), child: e))
        .toList());
    setNewRoutePath(pageMatchList);
  }

  @override
  Future<void> setNewRoutePath(PageMatchList pageMatchList) async {
    printD(
        '[Navigator] setNewRoutePath ${pageMatchList.configurations.map((e) => e.path).join()}');
    if (pages.isNotEmpty) {
      return;
    }

    pages
      ..clear()
      ..addAll(pageMatchList.configurations.map((e) => e.toPage<dynamic>()));
  }

  bool isExist(Widget child) {
    final Key? key = child.key;
    final String path = getPath(child);
    return pages.indexWhere((RoutePage<dynamic> element) =>
            element.pageConfiguration.path == path &&
            element.pageConfiguration.key == key) >=
        0;
  }

  Future<T?> push<T extends Object?>(Widget routeWidget,
      {Map<String, dynamic>? arguments, PageParameter? pageParameter}) {
    printD(
        '[Navigator] AppRouterDelegate => push, pageParameter: $pageParameter');
    RoutePage<T?> page =
        _getConfig(routeWidget, pageParameter: pageParameter).toPage<T>();
    page = _navigatePage(page);
    return _pushAndUpdate(page);
  }

  @override
  Future<bool> popRoute() async {
    printD('[Navigator] AppRouterDelegate => popRoute');
    return super.popRoute();
  }

  /// Whether the navigator can be popped.
  bool canPop() => navigatorState?.canPop() ?? false;

  void pop<T extends Object?>([T? result]) {
    navigatorState?.pop<T>(result);
  }

  void mayBePop<T extends Object?>([T? result]) {
    printD('[Navigator] AppRouterDelegate => mayBePop: $result');
    navigatorState?.maybePop<T>(result);
  }

  Future<T?> popAndPushWidget<T extends Object?>(Widget routeWidget,
      {T? result,
      Map<String, dynamic>? arguments,
      PageParameter? pageParameter}) {
    pop<T>(result);
    return push<T>(routeWidget,
        arguments: arguments, pageParameter: pageParameter);
  }

  Future<T?> popUntilAndPushWidget<T extends Object?>(
      PagePredicate predicate, Widget routeWidget,
      {Map<String, dynamic>? arguments, PageParameter? pageParameter}) {
    _popUntil(predicate);
    return push<T>(routeWidget, pageParameter: pageParameter);
  }

  /// Calls [pop] repeatedly on the navigator that most tightly encloses the
  /// given context until the predicate returns true.
  void popUntil(PagePredicate predicate) {
    _popUntil(predicate);
  }

  void _popUntil(PagePredicate predicate) {
    RoutePage<dynamic>? candidate = pages.lastWhereIndexedOrNull(
        (int index, RoutePage<dynamic>? e) =>
            e != null && index == pages.length - 1);
    while (candidate != null) {
      if (predicate(candidate)) return;

      pop();
      candidate = pages.lastWhereIndexedOrNull(
          (int index, RoutePage<dynamic>? e) =>
              e != null && index == pages.length - 1);
    }
  }

  RoutePage<T?> _navigatePage<T extends Object?>(RoutePage<T?> page) {
    final Widget child = page.pageConfiguration.child;
    final PageState pageState = page.pageConfiguration.pageParameter.state ??
        stateMapping?.getState(child, isExist) ??
        PageState.none;

    updateWidgetIfNeed(page);

    RoutePage<T?>? oldRoutePage = findOldRoutePage(page);

    switch (pageState) {
      case PageState.replace:
        pages.removeLast();
        return oldRoutePage ?? page;
      case PageState.clearStack:
        pages.clear();
        return oldRoutePage ?? page;
      case PageState.popOnTop:
        _popOnTop(page);
        return oldRoutePage ?? page;
      default:
        return oldRoutePage ?? page;
    }
  }

  _popOnTop<T extends Object?>(RoutePage<T?> page) {
    final int index = pages.indexOf(page);

    printD('[Navigator] delegate popOnTop $index');
    if (index > 0) {
      pages.removeRange(index, pages.length);
    } else if (index == 0) {
      pages.clear();
    }
  }

  RoutePage<T?>? findOldRoutePage<T extends Object?>(RoutePage<T?> page) {
    return pages
        .whereType<RoutePage<T?>>()
        .singleWhereOrNull((RoutePage<T?> element) => element.key == page.key);
  }

  PageConfiguration _getConfig(Widget child, {PageParameter? pageParameter}) {
    final PageConfiguration configuration = PageConfiguration(
      path: getPath(child),
      child: child,
      pageParameter: pageParameter ?? const PageParameter(),
    );

    return configuration;
  }

  String getPath(Widget child) {
    return pagePathMapping?.getPath(child) ?? '/${child.runtimeType}';
  }

  /// Push the given page onto the navigator.
  Future<T?> _pushAndUpdate<T extends Object?>(
    RoutePage<T?> page,
  ) {
    if (pages.contains(page)) {
      throw Exception(
          '${page.name}${page.key} was already exists in the pages, '
          'please change the key or PageState. '
          'Ensure that your keys do not exist at the same time.');
    }

    pages.add(page);
    _updatePages();
    return page.popped;
  }

  /// call this after you change pages
  void _updatePages() {
    notifyListeners();
  }

  Future<bool> updateWidgetIfNeed<T>(RoutePage<T?> page) async {
    final RoutePage? oldRoutePage = pages
        .whereType<RoutePage<T?>>()
        .singleWhereOrNull((element) => element.key == page.key);
    final Widget? oldWidget = oldRoutePage?.pageConfiguration.child;
    if (oldWidget is! Screen) {
      return false;
    }

    final Widget newWidget = page.pageConfiguration.child;
    if (oldWidget.runtimeType != newWidget.runtimeType) {
      return false;
    }

    return await oldWidget.events[ScreenEvent.update]?.run(newWidget) ??
        false;
  }

  Future<bool> handleBackPressed() async {
    final Widget? currentWidget = getCurrentWidget();
    if (currentWidget is! Screen) {
      return false;
    }

    return await currentWidget.events[ScreenEvent.backPressed]?.run(null) ??
        false;
  }

  Future<bool> handlePushEvent<T>(T data) async {
    final Widget? currentWidget = getCurrentWidget();
    if (currentWidget is! Screen) {
      return false;
    }

    return await currentWidget.events[ScreenEvent.pushMessage]?.run(data) ??
        false;
  }

  Widget? getCurrentWidget() {
    return pages.lastOrNull()?.pageConfiguration.child;
  }
}
