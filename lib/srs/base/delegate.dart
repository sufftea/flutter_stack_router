import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hyper_router/srs/base/nested_navigator.dart';
import 'package:hyper_router/srs/base/root_hyper_controller.dart';
import 'package:hyper_router/srs/base/hyper_router.dart';
import 'package:hyper_router/srs/route/hyper_route.dart';
import 'package:hyper_router/srs/value/route_value.dart';

class HyperRouterDelegate extends RouterDelegate<RouteNode>
    with ChangeNotifier {
  HyperRouterDelegate({
    required this.routerConfig,
    required this.initialRoute,
  }) {
    routerConfig.rootController.addListener(notifyListeners);
  }

  @override
  void dispose() {
    super.dispose();

    routerConfig.rootController.removeListener(notifyListeners);
  }

  final RouteValue initialRoute;
  final HyperRouter routerConfig;

  @override
  Widget build(BuildContext context) {
    final rootController = routerConfig.rootController;
    return InheritedHyperTree(
      router: routerConfig,
      child: RedirectWatcher(
        child: InheritedNavigatorNode(
          node: rootController.rootNavigatorNode,
          child: Builder(builder: (context) {
            return Navigator(
              pages: rootController.stack.createPages(context).toList(),
              key: rootController.rootNavigatorNode.key,
              // TODO: https://github.com/flutter/flutter/issues/153122
              // ignore: deprecated_member_use
              onPopPage: (route, result) {
                rootController.popRoute(result);
                return false;
              },
            );
          }),
        ),
      ),
    );
  }

  @override
  Future<bool> popRoute() async {
    routerConfig.rootController.pop();
    return SynchronousFuture(true);
  }

  @override
  RouteNode<RouteValue>? get currentConfiguration =>
      routerConfig.rootController.stack;

  @override
  Future<void> setNewRoutePath(RouteNode<RouteValue> configuration) async {
    routerConfig.rootController.setStack(configuration, notify: false);

    return SynchronousFuture(null);
  }
}
