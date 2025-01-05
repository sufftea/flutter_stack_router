import 'package:hyper_router/srs/route/hyper_route.dart';
import 'package:hyper_router/srs/value/route_value.dart';

abstract class HyperController {
  /// Updates the navigation stack to the path from [target] to the root of the
  /// navigation tree. The target route will receive [target] as its value.
  ///
  /// All the routes that have been in the stack before will preserve their
  /// values in the new stack. If the new stack contains routes that weren't
  /// present in the old stack (apart from the target route), those routes will
  /// have to rely on their default values. The [values] parameter can override
  /// the old values, or provide the values for the new routes.
  ///
  /// Returned future completes with the value popped from the target route.
  Future navigate(RouteValue target, [Set<RouteValue> values = const {}]);

  /// Removes the top-most route from the stack.
  ///
  /// Works with routes pushed with flutter's Navigator too.
  void pop<T>([T? value]);

  /// The current state of the router.
  /// The state is a linked list of [RouteNode]s. Each [RouteNode] corresponds
  /// to a [HyperRoute], and stores the value of that route.
  RouteNode get stack;
}
