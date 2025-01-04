import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hyper_router/srs/base/exceptions.dart';
import 'package:hyper_router/srs/route/hyper_route.dart';
import 'package:hyper_router/srs/route/named_route.dart';
import 'package:hyper_router/srs/route/shell_covering_route.dart';
import 'package:hyper_router/srs/route/shell_route/shell_route.dart';
import 'package:hyper_router/srs/route/shell_route/shell_value.dart';
import 'package:hyper_router/srs/route/value_route.dart';
import 'package:hyper_router/srs/value/route_key.dart';
import 'package:hyper_router/srs/value/route_name.dart';
import 'package:hyper_router/srs/value/route_value.dart';

import 'utils/create_test_node.dart';

class _CustomRouteValue1 extends RouteValue {}

class _CustomRouteValue2 extends RouteValue {}

void main() {
  final shellKey = RouteKey();
  final shellCoveringKey = RouteKey();

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
            children: [
              NamedRoute(
                screenBuilder: (context) => Scaffold(),
                name: RouteName('b'),
              ),
              ValueRoute<_CustomRouteValue1>(
                screenBuilder: (context, value) => Scaffold(),
                children: [
                  ValueRoute<_CustomRouteValue2>(
                    screenBuilder: (context, value) => Scaffold(),
                  ),
                  NamedRoute(
                    screenBuilder: (context) => Scaffold(),
                    name: RouteName('c'),
                  ),
                ],
              ),
            ],
          ),
          NamedRoute(
            screenBuilder: (context) => Scaffold(),
            name: RouteName('tab_c'),
            children: [
              ShellCoveringRoute(
                shellKey: shellKey,
                key: shellCoveringKey,
                children: [
                  NamedRoute(
                    screenBuilder: (context) => Scaffold(),
                    name: RouteName('under-shell-covering'),
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

  group(
    'createStack',
    () {
      test(
        'navigate to a route under ShellCoveringRoute',
        () {
          final targetValue = RouteName('under-shell-covering');
          final targetRoute = routeMap[targetValue.key]!;

          final expectedStack = CreateTestNode.namedNode(
            value: RouteName('a'),
            routeMap: routeMap,
            next: CreateTestNode.shellNode(
              value: ShellValue(
                tabIndex: 2,
                key: shellKey,
                tabNodes: [
                  CreateTestNode.namedNode(
                    value: RouteName('tab_a'),
                    routeMap: routeMap,
                    next: null,
                  ),
                  CreateTestNode.namedNode(
                    value: RouteName('tab_b'),
                    routeMap: routeMap,
                    next: null,
                  ),
                  CreateTestNode.namedNode(
                    value: RouteName('tab_c'),
                    routeMap: routeMap,
                    next: CreateTestNode.shellCoveringNode(
                      value: ShellCoveringRouteValue(shellCoveringKey),
                      routeMap: routeMap,
                      shellKey: shellKey,
                      next: CreateTestNode.namedNode(
                        value: RouteName('under-shell-covering'),
                        routeMap: routeMap,
                        next: null,
                      ),
                    ),
                  ),
                ],
              ),
              routeMap: routeMap,
              next: CreateTestNode.namedNode(
                value: RouteName('tab_c'),
                routeMap: routeMap,
                next: CreateTestNode.shellCoveringNode(
                  value: ShellCoveringRouteValue(shellCoveringKey),
                  routeMap: routeMap,
                  shellKey: shellKey,
                  next: CreateTestNode.namedNode(
                    value: RouteName('under-shell-covering'),
                    routeMap: routeMap,
                    next: null,
                  ),
                ),
              ),
            ),
          );

          final actualStack = targetRoute.createStack(values: {
            targetValue.key: targetValue,
          });

          expect(actualStack.toString(), equals(expectedStack.toString()));
        },
      );

      test(
        'navigate to a route under shellRoute',
        () {
          final expectedStack = CreateTestNode.namedNode(
            value: RouteName('a'),
            routeMap: routeMap,
            next: CreateTestNode.shellNode(
              value: ShellValue(
                tabIndex: 1,
                key: shellKey,
                tabNodes: [
                  CreateTestNode.namedNode(
                    value: RouteName('tab_a'),
                    routeMap: routeMap,
                    next: null,
                  ),
                  CreateTestNode.namedNode(
                    value: RouteName('tab_b'),
                    routeMap: routeMap,
                    next: null,
                  ),
                  CreateTestNode.namedNode(
                    value: RouteName('tab_c'),
                    routeMap: routeMap,
                    next: null,
                  ),
                ],
              ),
              routeMap: routeMap,
              next: CreateTestNode.namedNode(
                value: RouteName('tab_b'),
                routeMap: routeMap,
                next: null,
              ),
            ),
          );

          final targetValue = RouteName('tab_b');
          final targetRoute = routeMap[targetValue.key]!;
          final actualStack = targetRoute.createStack(values: {
            targetValue.key: targetValue,
          });

          expect(actualStack.toString(), equals(expectedStack.toString()));
        },
      );

      test(
        'createStack retains the old RouteValues',
        () {
          final expectedRouteValue1 = _CustomRouteValue1();
          final expectedRouteValue2 = _CustomRouteValue2();

          final expectedShellValue = ShellValue(
            tabIndex: 1,
            key: shellKey,
            tabNodes: [
              CreateTestNode.namedNode(
                value: RouteName('tab_a'),
                routeMap: routeMap,
                next: null,
              ),
              CreateTestNode.namedNode(
                value: RouteName('tab_b'),
                routeMap: routeMap,
                next: CreateTestNode.valueNode(
                  value: expectedRouteValue1,
                  routeMap: routeMap,
                  next: CreateTestNode.valueNode(
                    value: expectedRouteValue2,
                    routeMap: routeMap,
                    next: null,
                  ),
                ),
              ),
              CreateTestNode.namedNode(
                value: RouteName('tab_c'),
                routeMap: routeMap,
                next: CreateTestNode.shellCoveringNode(
                  value: ShellCoveringRouteValue(shellCoveringKey),
                  routeMap: routeMap,
                  shellKey: shellKey,
                  next: CreateTestNode.namedNode(
                    value: RouteName('under-shell-covering'),
                    routeMap: routeMap,
                    next: null,
                  ),
                ),
              ),
            ],
          );

          final expectedStack = CreateTestNode.namedNode(
            value: RouteName('a'),
            routeMap: routeMap,
            next: CreateTestNode.shellNode(
              value: expectedShellValue,
              routeMap: routeMap,
              next: CreateTestNode.namedNode(
                value: RouteName('tab_b'),
                routeMap: routeMap,
                next: CreateTestNode.valueNode(
                  value: expectedRouteValue1,
                  routeMap: routeMap,
                  next: CreateTestNode.valueNode(
                    value: expectedRouteValue2,
                    routeMap: routeMap,
                    next: null,
                  ),
                ),
              ),
            ),
          );

          final targetRoute = routeMap[expectedRouteValue2.key]!;
          final actualStack = targetRoute.createStack(values: {
            expectedRouteValue1.key: expectedRouteValue1,
            expectedRouteValue2.key: expectedRouteValue2,
            expectedShellValue.key: expectedShellValue,
          });

          expect(actualStack.toString(), equals(expectedStack.toString()));
        },
      );
    },
  );

  group(
    'cut',
    () {
      final initialStack = CreateTestNode.namedNode(
        value: RouteName('a'),
        routeMap: routeMap,
        next: CreateTestNode.shellNode(
          value: ShellValue(
            tabIndex: 2,
            key: shellKey,
            tabNodes: [
              CreateTestNode.namedNode(
                value: RouteName('tab_a'),
                routeMap: routeMap,
                next: null,
              ),
              CreateTestNode.namedNode(
                value: RouteName('tab_b'),
                routeMap: routeMap,
                next: null,
              ),
              CreateTestNode.namedNode(
                value: RouteName('tab_c'),
                routeMap: routeMap,
                next: CreateTestNode.shellCoveringNode(
                  value: ShellCoveringRouteValue(shellCoveringKey),
                  routeMap: routeMap,
                  shellKey: shellKey,
                  next: CreateTestNode.namedNode(
                    value: RouteName('under-shell-covering'),
                    routeMap: routeMap,
                    next: null,
                  ),
                ),
              ),
            ],
          ),
          routeMap: routeMap,
          next: CreateTestNode.namedNode(
            value: RouteName('tab_c'),
            routeMap: routeMap,
            next: CreateTestNode.shellCoveringNode(
              value: ShellCoveringRouteValue(shellCoveringKey),
              routeMap: routeMap,
              shellKey: shellKey,
              next: CreateTestNode.namedNode(
                value: RouteName('under-shell-covering'),
                routeMap: routeMap,
                next: null,
              ),
            ),
          ),
        ),
      );

      test(
        'cut ShellCoveringNode',
        () {
          final expectedStack = CreateTestNode.namedNode(
            value: RouteName('a'),
            routeMap: routeMap,
            next: CreateTestNode.shellNode(
              value: ShellValue(
                tabIndex: 2,
                key: shellKey,
                tabNodes: [
                  CreateTestNode.namedNode(
                    value: RouteName('tab_a'),
                    routeMap: routeMap,
                    next: null,
                  ),
                  CreateTestNode.namedNode(
                    value: RouteName('tab_b'),
                    routeMap: routeMap,
                    next: null,
                  ),
                  CreateTestNode.namedNode(
                    value: RouteName('tab_c'),
                    routeMap: routeMap,
                    next: null,
                  ),
                ],
              ),
              routeMap: routeMap,
              next: CreateTestNode.namedNode(
                value: RouteName('tab_c'),
                routeMap: routeMap,
                next: null,
              ),
            ),
          );

          final actualStack = initialStack.cut(shellCoveringKey);

          expect(actualStack.toString(), equals(expectedStack.toString()));
        },
      );
      test(
        'cut ShellNode',
        () {
          final expectedStack = CreateTestNode.namedNode(
            value: RouteName('a'),
            routeMap: routeMap,
            next: null,
          );

          final actualStack = initialStack.cut(shellKey);

          expect(actualStack.toString(), equals(expectedStack.toString()));
        },
      );

      test(
        'cutting the child of the ShellNode throws an error',
        () {
          expect(
            () {
              initialStack.cut(RouteName('tab_c').key);
            },
            throwsA(isA<HyperError>()),
          );
        },
      );
      test(
        'cutting the child of the ShellCoveringNode throws an error',
        () {
          expect(
            () {
              initialStack.cut(RouteName('under-shell-covering').key);
            },
            throwsA(isA<HyperError>()),
          );
        },
      );
      test(
        'cut the first node',
        () {
          final actualStack = initialStack.cut(RouteName('a').key);
          expect(actualStack, isNull);
        },
      );
    },
  );
}
