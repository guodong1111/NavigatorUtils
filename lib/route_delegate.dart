import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hl_core/utils/print.dart';

import 'navigator_manager.dart';
import 'route_page.dart';

/// Signature for the [AppRouterDelegate.popUntil] predicate argument.
typedef PagePredicate = bool Function(RoutePage<dynamic> page);

class AppRouterDelegate extends RouterDelegate<PageConfiguration>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<PageConfiguration> {
  AppRouterDelegate({
    this.observers,
    this.transitionDelegate = const DefaultTransitionDelegate<dynamic>(),
  }) : navigatorKey = GlobalKey<NavigatorState>();

  static const String PATH_HOME = '/';

  final TransitionDelegate<dynamic> transitionDelegate;

  final List<NavigatorObserver>? observers;
  final NavigatorManager navigatorManager = NavigatorManager.getInstance();

  List<RoutePage<dynamic>> get pages => navigatorManager.pages;

  @override
  final GlobalKey<NavigatorState> navigatorKey;

  NavigatorState? get navigatorState => navigatorKey.currentState;

  @override
  PageConfiguration? get currentConfiguration =>
      pages.isNotEmpty ? pages.last.pageConfiguration : null;

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

  Future<void> setRootWidget(Widget rootWidget) async {
    printD('[Navigator] setRootWidget $rootWidget');
    final PageConfiguration configuration = PageConfiguration(path: PATH_HOME, child: rootWidget);
    setNewRoutePath(configuration);
  }

  @override
  Future<void> setNewRoutePath(PageConfiguration configuration) async {
    printD('[Navigator] setNewRoutePath ${configuration.path}');
    if (pages.isNotEmpty) {
      return;
    }

    pages
      ..clear()
      ..add(configuration.toPage());
  }

  bool isExist(Widget child) {
    final Key? key = child.key;
    final String path = getPath(child);
    return pages.indexWhere((RoutePage<dynamic> element) =>
            element.pageConfiguration.key == key &&
            element.pageConfiguration.path == path) >=
        0;
  }

  Future<T?> push<T extends Object?>(Widget routeWidget,
      {Map<String, dynamic>? arguments, PageParameter? pageParameter}) {
    printD(
        '[Navigator] AppRouterDelegate => push, pageParameter: $pageParameter');
    RoutePage<T?> page =
        _getConfig(routeWidget, pageParameter: pageParameter).toPage();
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
      if (predicate(candidate))
        return;
      pop();
      candidate = pages.lastWhereIndexedOrNull(
          (int index, RoutePage<dynamic>? e) =>
              e != null && index == pages.length - 1);
    }
  }

  RoutePage<T?> _navigatePage<T extends Object?>(RoutePage<T?> page) {
    final PageState pageState = page.pageConfiguration.pageParameter.state;
    switch (pageState) {
      case PageState.replace:
        pages.removeLast();
        return page;
      case PageState.clearStack:
        pages.clear();
        return page;
      case PageState.popOnTop:
        return _popOnTop(page);
      default:
        return page;
    }
  }

  RoutePage<T?> _popOnTop<T extends Object?>(RoutePage<T?> page) {
    final int index = pages.lastIndexWhere((RoutePage<dynamic> e) =>
        e.pageConfiguration.path == page.pageConfiguration.path);

    printD('[Navigator] delegate popOnTop $index');
    if (index > 0) {
      pages.removeRange(index, pages.length);
    } else if (index == 0) {
      pages.clear();
    }

    return page;
  }

  PageConfiguration _getConfig(Widget child, {PageParameter? pageParameter}) {
    final Key? childKey = child.key;
    final PageConfiguration configuration = PageConfiguration(
      key: (childKey is LocalKey) ? childKey : null,
      path: getPath(child),
      child: child,
      pageParameter: pageParameter ?? const PageParameter(),
    );

    return configuration;
  }

  String getPath(Widget child) {
    return '/${child.runtimeType}';
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
}
