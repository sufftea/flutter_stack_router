import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hyper_router/srs/base/root_hyper_controller.dart';
import 'package:hyper_router/srs/route/hyper_route.dart';
import 'package:hyper_router/srs/route/named_route.dart';
import 'package:hyper_router/srs/route/shell_covering_route.dart';
import 'package:hyper_router/srs/route/shell_route/shell_node.dart';
import 'package:hyper_router/srs/route/shell_route/shell_route.dart';
import 'package:hyper_router/srs/value/route_key.dart';
import 'package:hyper_router/srs/value/route_name.dart';

import 'utils/extensions.dart';

void main() {
  final shellKey = RouteKey();
  final routeTree = NamedRoute(
    screenBuilder: (context) => const Scaffold(),
    name: RouteName('a'),
    children: [
      ShellRoute(
        shellBuilder: (context, controller, child) => Scaffold(),
        key: shellKey,
        tabs: [
          NamedRoute(
            screenBuilder: (context) => Scaffold(),
            name: RouteName('tab_a'),
          ),
          NamedRoute(
            screenBuilder: (context) => Scaffold(),
            name: RouteName('tab_b'),
          ),
          NamedRoute(
            screenBuilder: (context) => Scaffold(),
            name: RouteName('tab_c'),
            children: [
              ShellCoveringRoute(
                shellKey: shellKey,
                children: [
                  NamedRoute(
                    screenBuilder: (context) => Scaffold(),
                    name: RouteName('shell-covering'),
                  ),
                ],
              ),
            ],
          ),
        ],
      )
    ],
  );

  routeTree.parent = null;
  final routeMap = <Object, HyperRoute>{};
  routeTree.forEach((r) {
    routeMap[r.key] = r;
  });

  final controller = RootHyperController(
    routeMap: routeMap,
    initialRoute: RouteName('a'),
    redirect: (context, state) => null,
  );

  test(
    'createStack',
    () {
      final stack = controller.createStack(RouteName('tab_c'));

      expect(stack, isA<NamedNode>());
      expect(stack.next, isA<ShellNode>());

      if (stack case final ShellNode shellNode) {}
    },
  );
}
