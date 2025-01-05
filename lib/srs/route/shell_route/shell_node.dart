import 'package:flutter/material.dart';
import 'package:hyper_router/srs/base/nested_navigator.dart';
import 'package:hyper_router/srs/route/shell_route/shell_value.dart';
import 'package:hyper_router/srs/url/url_data.dart';
import 'package:hyper_router/hyper_router.dart';

class ShellNode extends RouteNode<ShellValue> {
  ShellNode({
    required this.shellBuilder,
    required this.value,
    required super.route,
    super.popCompleter,
  });

  final Widget Function(
    BuildContext context,
    ShellController controller,
    Widget child,
  ) shellBuilder;

  @override
  RouteNode<RouteValue> get next => value.currTab;
  @override
  final ShellValue value;
  @override
  RouteKey get key => value.key;

  @override
  Iterable<Page> createPages(BuildContext context) {
    final controller = HyperRouter.rootOf(context);
    final shellController = ShellController(
      value: value,
      controller: controller,
    );

    if (_isShellCovering(next, key)) {
      throw HyperError(
          "[ShellCoveringNode] can't be a direct child of [ShellRoute]");
    }

    ShellCoveringNode? coveringNode;
    next.next?.forEach((node) {
      if (node is ShellCoveringNode && node.shellKey == key) {
        coveringNode = node;
      }
    });

    late final RouteNode nextCut;
    if (coveringNode case final coveringNode?) {
      if (next.cut(coveringNode.key) case final next?) {
        nextCut = next;
      }
    } else {
      nextCut = next;
    }

    final page = MaterialPage(
      child: shellBuilder(
        context,
        shellController,
        Builder(builder: (context) {
          return NestedNavigator(
            pages: nextCut.createPages(context).toList(),
            key: ValueKey(shellController.tabIndex),
          );
        }),
      ),
    );

    return <Page>[page].followedByOptional(coveringNode?.createPages(context));
  }

  @override
  RouteNode<RouteValue>? pop() {
    if (value.currTab.pop() case final popped?) {
      return route.updateWithValue(
        next: popped,
        value: value.withNext(popped),
        popCompleter: popCompleter,
      );
    }

    return null;
  }

  @override
  UrlData toUrl() {
    return next.toUrl();
  }

  @override
  String toString() {
    return "$runtimeType(value: $value, next: $next)";
  }
}

bool _isShellCovering(RouteNode node, RouteKey key) {
  return node is ShellCoveringNode && node.shellKey == key;
}
