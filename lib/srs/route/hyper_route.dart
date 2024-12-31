import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hyper_router/srs/base/exceptions.dart';
import 'package:hyper_router/srs/url/url_data.dart';

import 'package:hyper_router/srs/value/route_value.dart';

abstract class HyperRoute<T extends RouteValue> {
  HyperRoute({
    this.children = const [],
  }) {
    for (final child in children) {
      child.parent = this;
    }
  }

  final List<HyperRoute> children;
  late final HyperRoute? parent;

  /// Same as [RouteValue.key]
  Object get key;

  RouteNode createNode({
    RouteNode? next,
    T? value,
    Completer? popCompleter,
  });

  /// Prioritizes [value] over [next].
  /// - [next] is what the node is currently pointing towards.
  /// - [value] is the value the returned node is expected to contain.
  RouteNode updateWithValue({
    RouteNode? next,
    required T value,
    Completer? popCompleter,
  }) {
    return createNode(
      next: next,
      value: value,
      popCompleter: popCompleter,
    );
  }

  /// Prioritizes [next] over [value].
  /// - [value] is the current value of the node.
  /// - [next] is what the returned node is expected to be pointing to.
  RouteNode updateWithNext({
    RouteNode? next,
    required T value,
    Completer? popCompleter,
  }) {
    return createNode(
      next: next,
      value: value,
      popCompleter: popCompleter,
    );
  }

  /// Receives a list of url segments and returns the stack parsed from them.
  /// The first segment in the list is matched against this route. If it does
  /// not correspond to this route, returns null.
  ///
  /// A segment is a part of the url separated by slashes ('/'). The slashes are
  /// not included into the segment.
  RouteNode? createFromUrl(UrlData url);

  /// Finds a route that matches the url among its children and returns a stack
  /// created from it.
  RouteNode? nextNodeFromUrl(UrlData url) {
    if (url.segments.isEmpty) {
      return null;
    }

    final next = HyperRoute.matchUrl(url: url, routes: children);
    if (next == null) {
      throw UrlParsingException(url: url);
    }
    return next;
  }

  /// Finds a route that matches the url and creates a stack from it.
  static RouteNode? matchUrl({
    required UrlData url,
    required List<HyperRoute> routes,
  }) {
    if (url.segments.isEmpty) {
      return null;
    }

    for (final route in routes) {
      final node = route.createFromUrl(url);
      if (node != null) {
        return node;
      }
    }

    return null;
  }

  /// Performs depth-first traversal and applies `action` to each child on the way
  void forEach(void Function(HyperRoute r) action) {
    for (final child in children) {
      child.forEach(action);
    }
    action(this);
  }

  /// Creates a stack of [RouteNode]s from this route to the root.
  RouteNode? createStack({
    RouteNode? next,
    required Map<Object, RouteValue> values,
    Map<Object, Completer> popCompleters = const {},
  }) {
    final node = createNode(
      next: next,
      value: values[key] as T?,
      popCompleter: popCompleters[key],
    );

    if (parent case final parent?) {
      return parent.createStack(
        next: node,
        values: values,
        popCompleters: popCompleters,
      );
    } else {
      return node;
    }
  }
}

/// A linked list representing the navigation stack. Each [RouteNode]
/// corresponds to a route.
abstract class RouteNode<T extends RouteValue> {
  RouteNode({
    required this.route,
    Completer? popCompleter,
  }) : popCompleter = popCompleter ?? Completer();

  /// [RouteNode] that follows this one.
  RouteNode? get next;

  /// The [RouteValue] of this route
  T get value;

  /// The route configuration (from the tree)
  final HyperRoute route;

  /// Same as [RouteValue.key]
  Object get key => value.key;
  final Completer popCompleter;

  /// True if this is the last node in the list
  bool get isTop => next == null;

  Iterable<Page> createPages(BuildContext context);

  RouteNode? pop() {
    if (next case final next?) {
      return route.updateWithNext(
        next: next.pop(),
        value: value,
        popCompleter: popCompleter,
      );
    }
    return null;
  }

  UrlData toUrl();

  /// Returns a copy of the list from the node it's called on, up to the node
  /// with the provided [key] (excluding the node with the [key])
  RouteNode? cut(Object key) {
    if (key == this.key) {
      return null;
    }
    return route.updateWithNext(
      next: next?.cut(key),
      value: value,
      popCompleter: popCompleter,
    );
  }

  /// Returns the last node in the list
  RouteNode last() {
    RouteNode curr = this;

    while (curr.next != null) {
      curr = curr.next!;
    }

    return curr;
  }

  /// Returns a copy of the stack where the node with [key] is replaced with a
  /// node containing the provided value.
  RouteNode withUpdatedValue(Object key, RouteValue value) {
    if (key == this.key) {
      return route.updateWithValue(
        next: next,
        value: value,
        popCompleter: popCompleter,
      );
    }
    return route.updateWithNext(
      next: next?.withUpdatedValue(key, value),
      value: this.value,
      popCompleter: popCompleter,
    );
  }

  RouteNode copyStack() {
    return route.updateWithNext(
      value: value,
      next: next?.copyStack(),
    );
  }

  /// Check if the stack contains a node with the provided [key]
  bool containsNode(Object key) {
    if (this.key == key) {
      return true;
    } else if (next case final next?) {
      return next.containsNode(key);
    }

    return false;
  }

  void forEach(void Function(RouteNode node) action) {
    RouteNode? curr = this;
    while (curr != null) {
      action(curr);
      curr = curr.next;
    }
  }

  @override
  bool operator ==(Object other) {
    return other is RouteNode && other.hashCode == this.hashCode;
  }

  @override
  int get hashCode => super.hashCode + next.hashCode;
}
