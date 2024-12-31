import 'package:hyper_router/srs/route/hyper_route.dart';

extension RouteNodeX on RouteNode {
  List<RouteNode> toList() {
    final result = <RouteNode>[];
    forEach(
      (node) {
        result.add(node);
      },
    );

    return result;
  }
}
