import 'package:flutter/material.dart';
import 'package:hyper_router/srs/base/hyper_router.dart';

class NestedNavigator extends StatefulWidget {
  const NestedNavigator({
    required this.pages,
    super.key,
  });

  final List<Page> pages;

  @override
  State<NestedNavigator> createState() => _NestedNavigatorState();
}

class _NestedNavigatorState extends State<NestedNavigator> {
  final node = NavigatorNode(GlobalKey<NavigatorState>());
  NavigatorNode? parent;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    parent = NavigatorNode.of(context);
    parent!.activateChild(node);
  }

  @override
  void dispose() {
    super.dispose();

    parent!.removeChild(node);
  }

  @override
  Widget build(BuildContext context) {
    final rootController = HyperRouter.rootOf(context);

    return InheritedNavigatorNode(
      node: node,
      child: Navigator(
        pages: widget.pages,
        key: node.key,
        // TODO: https://github.com/flutter/flutter/issues/153122
        // ignore: deprecated_member_use
        onPopPage: (route, result) {
          rootController.popRoute(result);
          return false;
        },
      ),
    );
  }
}

class NavigatorNode {
  NavigatorNode(this.key);

  static NavigatorNode of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<InheritedNavigatorNode>()!
        .node;
  }

  final GlobalKey<NavigatorState> key;
  final _children = <NavigatorNode>[];

  void activateChild(NavigatorNode child) {
    _children.remove(child);
    _children.add(child);
  }

  void removeChild(NavigatorNode child) {
    _children.remove(child);
  }

  bool pop<T>(T? result) {
    return _pop(result) == _NavigatorNodePop.popped;
  }

  _NavigatorNodePop _pop<T>(T? result) {
    final navState = key.currentState;

    if (navState != null &&
        navState.mounted &&
        (ModalRoute.of(navState.context)?.isCurrent ?? true)) {
      for (final child in _children.reversed) {
        switch (child._pop(result)) {
          case _NavigatorNodePop.unavailable:
            continue;
          case _NavigatorNodePop.popped:
            return _NavigatorNodePop.popped;
          case _NavigatorNodePop.passedUp:
            if (navState.canPop()) {
              navState.pop(result);
              return _NavigatorNodePop.popped;
            } else {
              return _NavigatorNodePop.passedUp;
            }
        }
      }

      if (navState.canPop()) {
        navState.pop(result);
        return _NavigatorNodePop.popped;
      } else {
        return _NavigatorNodePop.passedUp;
      }
    }

    return _NavigatorNodePop.unavailable;
  }
}

enum _NavigatorNodePop {
  unavailable,
  popped,
  passedUp,
}

class InheritedNavigatorNode extends InheritedWidget {
  const InheritedNavigatorNode({
    required this.node,
    required super.child,
    super.key,
  });

  final NavigatorNode node;

  @override
  bool updateShouldNotify(InheritedNavigatorNode oldWidget) {
    return oldWidget.node != node;
  }
}
