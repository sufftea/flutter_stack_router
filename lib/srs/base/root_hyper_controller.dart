import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyper_router/srs/base/entities.dart';
import 'package:hyper_router/srs/base/hyper_router.dart';
import 'package:hyper_router/srs/base/hyper_controller.dart';
import 'package:hyper_router/srs/base/nested_navigator.dart';
import 'package:hyper_router/srs/base/exceptions.dart';
import 'package:hyper_router/srs/route/hyper_route.dart';
import 'package:hyper_router/srs/value/route_value.dart';

class RootHyperController extends ChangeNotifier implements HyperController {
  RootHyperController({
    required RouteValue initialRoute,
    required RouteValue? Function(BuildContext context, RedirectState state)
        redirect,
    required this.routeMap,
  }) {
    _redirect = (stack) {
      if (_redirectContext case final context?) {
        if (redirect(context, RedirectState(stack: stack)) case final target?) {
          return createStack(target);
        }
      }

      return stack;
    };

    _stack = createStack(initialRoute);
  }

  final rootNavigatorNode = NavigatorNode(GlobalKey<NavigatorState>());

  BuildContext? _redirectContext;
  late final RouteNode Function(RouteNode stack) _redirect;

  RouteNode? _stack;
  @override
  RouteNode get stack => _stack!;
  void setStack(RouteNode value, {bool notify = true}) {
    _stack = _redirect(value);
    if (notify) {
      notifyListeners();
    }
  }

  final Map<Object, HyperRoute> routeMap;

  @override
  Future navigate(RouteValue target, [Set<RouteValue> values = const {}]) {
    setStack(createStack(target, values));
    return stack.last().popCompleter.future;
  }

  @override
  void pop<T>([T? result]) {
    if (!rootNavigatorNode.pop(result)) {
      SystemNavigator.pop();
    }
  }

  void popRoute<T>(T? result) {
    stack.last().popCompleter.complete(result);

    if (stack.pop() case final popped?) {
      setStack(popped);
    } else {
      SystemNavigator.pop();
    }
  }

  List<Page> createPages(BuildContext context) {
    return stack.createPages(context).toList();
  }

  RouteNode createStack(
    RouteValue target, [
    Set<RouteValue> values = const {},
  ]) {
    final HyperRoute? targetRoute = routeMap[target.key];

    if (targetRoute == null) {
      throw HyperError(
          "Route tree doesn't contain route with the provided key: ${target.key}");
    }

    final valuesMap = getCurrentValues(combineWith: {
      target,
      ...values,
    });

    final popCompleters = getCurrentCompleters();

    return targetRoute.createStack(
      values: valuesMap,
      popCompleters: popCompleters,
    )!;
  }

  Map<Object, Completer> getCurrentCompleters() {
    final popCompleters = <Object, Completer>{};
    _stack?.forEach((node) {
      popCompleters[node.key] = node.popCompleter;
    });

    return popCompleters;
  }

  Map<Object, RouteValue> getCurrentValues({
    Set<RouteValue> combineWith = const {},
  }) {
    final valuesMap = <Object, RouteValue>{};

    _stack?.forEach((builder) {
      valuesMap[builder.value.key] = builder.value;
    });
    valuesMap.addAll(Map.fromIterable(
      combineWith,
      key: (element) => element.key,
    ));

    return valuesMap;
  }
}

class RedirectWatcher extends StatefulWidget {
  const RedirectWatcher({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<RedirectWatcher> createState() => _RedirectWatcherState();
}

class _RedirectWatcherState extends State<RedirectWatcher> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    context.dependOnInheritedWidgetOfExactType<InheritedHyperTree>()!.router;
    final controller = HyperRouter.configOf(context).rootController;
    controller._redirectContext = context;
    controller._stack = controller._redirect(controller._stack!);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
