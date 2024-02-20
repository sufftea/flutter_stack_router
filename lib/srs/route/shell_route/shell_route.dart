import 'package:flutter/material.dart';
import 'package:star/srs/route/shell_covering_route.dart';
import 'package:star/srs/route/shell_route/shell_controller.dart';
import 'package:star/srs/route/shell_route/shell_node.dart';
import 'package:star/srs/route/shell_route/shell_value.dart';
import 'package:star/srs/url/url_data.dart';
import 'package:star/srs/value/route_key.dart';
import 'package:star/star.dart';

typedef ShellBuilder = Widget Function(
  BuildContext context,
  ShellController controller,
  Widget child,
);

class ShellRoute extends StarRoute<ShellValue> {
  ShellRoute({
    required this.shellBuilder,
    required this.tabs,

    /// Usually, you don't need to provide this. Use this for
    /// [ShellCoveringRoute]
    RouteKey? key,
  })  : key = key ?? RouteKey(),
        super(children: tabs);

  final Widget Function(
    BuildContext context,
    ShellController controller,
    Widget child,
  ) shellBuilder;

  final List<StarRoute> tabs;

  @override
  final RouteKey key;

  @override
  RouteNode createNode({RouteNode? next, ShellValue? value}) {
    return ShellNode(
      shellBuilder: shellBuilder,
      value: switch ((next, value)) {
        (final next?, final value?) => value.withNext(next),
        (final next?, null) => ShellValue.fromNext(
            key: key,
            tabRoutes: tabs,
            next: next,
          ),
        (null, final value?) => value,
        (null, null) => value = ShellValue.def(key: key, tabs: tabs),
      },
      route: this,
    );
  }

  @override
  RouteNode<RouteValue> updateWithValue({
    RouteNode<RouteValue>? next,
    required ShellValue value,
  }) {
    return ShellNode(
      shellBuilder: shellBuilder,
      value: value,
      route: this,
    );
  }

  @override
  RouteNode<RouteValue> updateWithNext({
    RouteNode<RouteValue>? next,
    required ShellValue value,
  }) {
    return ShellNode(
      shellBuilder: shellBuilder,
      value: value.withNext(next!),
      route: this,
    );
  }

  @override
  RouteNode<RouteValue>? createFromUrl(
    UrlData url,
  ) {
    final next = StarRoute.matchUrl(
      url: url,
      routes: children,
    );

    if (next == null) {
      return null;
    }

    return createNode(
      next: next,
    );
  }
}