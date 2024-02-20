
import 'package:star/srs/route/star_route.dart';
import 'package:star/srs/value/route_key.dart';
import 'package:star/srs/value/route_value.dart';

class ShellValue extends RouteValue {
  ShellValue({
    required this.tabIndex,
    required this.key,
    required this.tabNodes,
  });

  factory ShellValue.def({
    required RouteKey key,
    required List<StarRoute> tabs,
  }) {
    return ShellValue(
      tabIndex: 0,
      key: key,
      tabNodes: tabs.map((e) => e.createNode()!).toList(),
    );
  }

  factory ShellValue.fromNext({
    required RouteKey key,
    required List<StarRoute> tabRoutes,
    required RouteNode next,
  }) {
    final tabIndex = tabRoutes.indexWhere((e) => e.key == next.key);

    return ShellValue(
      tabIndex: tabIndex,
      key: key,
      tabNodes: tabRoutes.map((e) {
        if (e.key == next.key) {
          return next;
        }
        return e.createNode()!;
      }).toList(),
    );
  }

  final List<RouteNode> tabNodes;
  final int tabIndex;

  RouteNode get currTab => tabNodes[tabIndex];

  @override
  final RouteKey key;

  ShellValue withIndex(int index) {
    return ShellValue(
      tabIndex: index,
      key: key,
      tabNodes: tabNodes,
    );
  }

  ShellValue withNext(RouteNode next) {
    return ShellValue(
      key: key,
      tabIndex: tabNodes.indexWhere((tab) => tab.value.key == next.value.key),
      tabNodes: tabNodes
          .map((e) => e.value.key == next.value.key ? next : e)
          .toList(),
    );
  }

  bool containsTab(Object key) {
    return tabNodes.any((tab) => tab.value.key == key);
  }

  @override
  String toString() {
    final stacks = [
      for (final tab in tabNodes)
        () {
          final stack = [];
          tab.forEach((node) {
            stack.add(node.value.toString());
          });
          return stack;
        }(),
    ];
    return 'ShellValue(tabIndex: $tabIndex, tabStacks: $stacks)';
  }
}
