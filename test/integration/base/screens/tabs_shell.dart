import 'package:flutter/material.dart';
import 'package:hyper_router/srs/route/shell_route/shell_controller.dart';

class TabsShell extends StatelessWidget {
  const TabsShell({
    required this.controller,
    required this.child,
    super.key,
  });

  final Widget child;
  final ShellController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: child);
  }
}
