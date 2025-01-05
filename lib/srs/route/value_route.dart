import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hyper_router/srs/base/exceptions.dart';
import 'package:hyper_router/srs/route/hyper_route.dart';
import 'package:hyper_router/srs/url/url_data.dart';
import 'package:hyper_router/srs/url/url_parser.dart';
import 'package:hyper_router/srs/utils/hyper_iterable_x.dart';
import 'package:hyper_router/srs/value/route_value.dart';

/// {@template ValueRoute}
/// Use when you need to pass data to the route. `T` is the type you will use to
/// navigate to this route and pass data.
///
/// To declare the value type, extend [RouteValue]:
/// ```dart
/// class ProductRouteValue extends RouteValue {
///   const ProductRouteValue(this.product);
///   final Product product;
/// }
/// ```
/// To navigate to the route, pass a value of type `T` the to the navigator:
/// ```dart
/// context.hyper.navigate(ProductRouteValue(Product(/*...*/)));
/// ```
///
/// If you `enableUrl`, make sure to provide a `urlParser` for serializing the
/// value.
/// {@endtemplate}
class ValueRoute<T extends RouteValue> extends HyperRoute<T> {
  /// {@macro ValueRoute}
  ValueRoute({
    required this.screenBuilder,
    this.defaultValue,
    this.pageBuilder,
    this.urlParser,
    super.children,
  });

  final Page Function(BuildContext context, Widget child)? pageBuilder;
  final Widget Function(BuildContext context, T value) screenBuilder;

  /// During navigation, when a new stack is being composed, the values from the
  /// previous stack are reused. However, if the new stack contains routes (apart from
  /// the target route) that aren't present in the previous stack, those routes
  /// will have to rely on their default values.
  ///
  /// You can also use the `values` parameter in [HyperController.navigate] to
  /// provide values for such routes.
  final T? defaultValue;

  /// Provide if you've set [HyperRouter.enableUrl] to `true`.
  final UrlParser<T>? urlParser;

  @override
  Object get key => T;

  @override
  RouteNode createNode({
    RouteNode? next,
    T? value,
    Completer? popCompleter,
  }) {
    value ??= defaultValue;

    if (value == null) {
      throw HyperError("No value provided for ValueRoute<$key>");
    }

    return ValueNode(
      buildPage: (context) => buildPage(context, value!),
      next: next,
      value: value,
      urlParser: urlParser,
      route: this,
      popCompleter: popCompleter,
    );
  }

  Page buildPage(BuildContext context, T value) {
    final screen = screenBuilder(context, value);

    if (pageBuilder != null) {
      return pageBuilder!.call(context, screen);
    }

    return MaterialPage(child: screen);
  }

  @override
  RouteNode<RouteValue>? createFromUrl(UrlData url) {
    if (urlParser case final parser?) {
      if (parser.decode(url) case (final value, final remaining)?) {
        return createNode(
          next: nextNodeFromUrl(url.copyWith(remaining)),
          value: value,
        );
      } else {
        return null;
      }
    } else {
      return null;
    }
  }
}

class ValueNode<T extends RouteValue> extends RouteNode {
  ValueNode({
    required this.next,
    required this.value,
    required this.buildPage,
    required super.route,
    this.urlParser,
    super.popCompleter,
  });

  final Page Function(BuildContext context) buildPage;
  final UrlParser<T>? urlParser;

  @override
  final RouteNode<RouteValue>? next;

  @override
  final T value;

  @override
  Iterable<Page> createPages(BuildContext context) {
    final page = buildPage(context);
    return [page].followedByOptional(next?.createPages(context));
  }

  @override
  UrlData toUrl() {
    if (urlParser case final parser?) {
      final url = parser.encode(value);

      if (next case final next?) {
        return url.followedBy(next.toUrl());
      }

      return url;
    } else {
      throw HyperError(
          "Couldn't create url segment for $T. Please, provide a urlParser");
    }
  }
}
