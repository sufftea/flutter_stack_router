import 'package:hyper_router/hyper_router.dart';
import 'package:hyper_router/srs/route/shell_route/shell_node.dart';
import 'package:hyper_router/srs/route/shell_route/shell_value.dart';

class CreateTestNode {
  CreateTestNode._();

  static RouteNode namedNode({
    required RouteName value,
    required Map<Object, HyperRoute> routeMap,
    required RouteNode? next,
  }) {
    return NamedNode(
      next: next,
      value: value,
      buildPage: (context) => throw UnimplementedError(),
      route: routeMap[value.key]!,
    );
  }

  static RouteNode valueNode<T extends RouteValue>({
    required T value,
    required Map<Object, HyperRoute> routeMap,
    required RouteNode? next,
  }) {
    return ValueNode<T>(
      next: next,
      value: value,
      buildPage: (context) => throw UnimplementedError(),
      route: routeMap[value.key]!,
    );
  }

  static RouteNode shellNode({
    required ShellValue value,
    required Map<Object, HyperRoute> routeMap,
    required RouteNode? next,
  }) {
    return ShellNode(
      value: value,
      shellBuilder: (context, controller, child) => throw UnimplementedError(),
      route: routeMap[value.key]!,
    );
  }

  static RouteNode shellCoveringNode({
    required ShellCoveringRouteValue value,
    required Map<Object, HyperRoute> routeMap,
    required RouteKey shellKey,
    required RouteNode next,
  }) {
    final route = routeMap[value.key]!;
    return ShellCoveringNode(
      next: next,
      value: value,
      route: route,
      shellKey: shellKey,
    );
  }
}
