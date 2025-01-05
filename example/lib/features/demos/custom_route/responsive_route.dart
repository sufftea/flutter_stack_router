import 'dart:async';

import 'package:example/features/utils/context_x.dart';
import 'package:example/features/utils/screen_sizes.dart';
import 'package:flutter/material.dart';
import 'package:hyper_router/srs/base/nested_navigator.dart';
import 'package:hyper_router/hyper_router.dart';

class ResponsiveRoute extends NamedRoute {
  ResponsiveRoute({
    required super.screenBuilder,
    required super.name,
    super.children,
  });

  @override
  RouteNode<RouteValue> createNode({
    RouteNode<RouteValue>? next,
    RouteName? value,
    Completer? popCompleter,
  }) {
    return ResponsiveNode(
      next: next,
      value: name,
      buildPage: (context) => buildPage(context, name),
      buildScreen: (context) => screenBuilder(context, name),
      route: this,
    );
  }
}

class ResponsiveNode extends NamedNode {
  ResponsiveNode({
    required super.buildPage,
    required super.next,
    required super.value,
    required this.buildScreen,
    required super.route,
  });

  final Widget Function(BuildContext context) buildScreen;

  @override
  Iterable<Page> createPages(BuildContext context) {
    return switch (context.width) {
      < mediumWidth => <Page>[
          MaterialPage(child: buildScreen(context)),
        ].followedByOptional(next?.createPages(context)),
      _ => [
          MaterialPage(
            child: Container(
              color: context.col.surface,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 400,
                    child: buildScreen(context),
                  ),
                  VerticalDivider(
                    color: context.col.onSurface,
                    thickness: 0.5,
                  ),
                  Expanded(
                    child: NestedNavigator(
                      pages: [
                        const MaterialPage(
                          child: Scaffold(
                            body: Center(
                              child: Text(
                                'empty',
                                style: TextStyle(
                                  fontSize: 16,
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        ...next?.createPages(context) ?? [],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
    };
  }
}
