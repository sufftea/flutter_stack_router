import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hyper_router/srs/base/exceptions.dart';
import 'package:hyper_router/srs/route/hyper_route.dart';
import 'package:hyper_router/srs/url/url_data.dart';
import 'package:hyper_router/srs/value/route_key.dart';
import 'package:hyper_router/srs/value/route_value.dart';

/// {@template shell_covering_route}
/// The routes located below this one in the routing tree will be displayed on
/// top (rather than inside the nested navigator) of the [ShellRoute]  with the
/// corresponding [shellKey].
///
/// This is a "proxy" route: it doesn't have a page of its own and you can't
/// navigate to it directly. Must contain at least one child.
/// {@endtemplate}
class ShellCoveringRoute extends HyperRoute {
  /// {@macro shell_covering_route}
  ShellCoveringRoute({
    required this.shellKey,
    required super.children,
    @visibleForTesting RouteKey? key,
  })  : key = key ?? RouteKey(),
        assert(
          children.isNotEmpty,
          "[ShellCoveringRoute] serves as a proxy for its children and can't be displayed on its own. Provide at least one child",
        );

  /// The key of the [ShellRoute] that this route and its children should cover.
  final RouteKey shellKey;

  @override
  RouteNode<RouteValue> createNode({
    RouteNode<RouteValue>? next,
    RouteValue? value,
    Completer? popCompleter,
  }) {
    if (next == null) {
      throw HyperError(
        "Attempt to navigate to [ShellCoveringNode] directly.",
      );
    }

    return ShellCoveringNode(
      shellKey: shellKey,
      next: next,
      value: ShellCoveringRouteValue(key),
      route: this,
      popCompleter: popCompleter,
    );
  }

  @override
  RouteNode<RouteValue>? createFromUrl(UrlData url) {
    final next = HyperRoute.matchUrl(url: url, routes: children);

    if (next == null) {
      return null;
    }

    return createNode(
      next: next,
    );
  }

  @override
  final RouteKey key;
}

class ShellCoveringNode extends RouteNode<ShellCoveringRouteValue> {
  ShellCoveringNode({
    required this.shellKey,
    required this.value,
    required this.next,
    required super.route,
    super.popCompleter,
  });

  final RouteKey shellKey;

  @override
  final ShellCoveringRouteValue value;

  @override
  final RouteNode<RouteValue> next;

  @override
  Iterable<Page> createPages(BuildContext context) {
    return next.createPages(context);
  }

  @override
  RouteNode<RouteValue>? pop() {
    return next.pop();
  }

  @override
  UrlData toUrl() {
    return next.toUrl();
  }
}

class ShellCoveringRouteValue extends RouteValue {
  ShellCoveringRouteValue(this.key);

  @override
  final RouteKey key;
}
