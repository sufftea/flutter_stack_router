import 'package:example/features/guide/guide_screen.dart';
import 'package:example/features/internals/internal_screen.dart';
import 'package:example/features/tabs/navigation_tab.dart';
import 'package:example/features/utils/context_x.dart';
import 'package:example/features/utils/screen_sizes.dart';
import 'package:flutter/material.dart';
import 'package:hyper_router/hyper_router.dart';

class MainTabsShell extends StatelessWidget {
  const MainTabsShell({
    required this.controller,
    required this.child,
    super.key,
  });

  final ShellController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      NavigationTab(
        icon: const Icon(Icons.local_florist_outlined),
        selectedIcon: const Icon(Icons.local_florist),
        label: "Home",
        onClick: (BuildContext context) {
          controller.setTabIndex(0);
        },
      ),
      NavigationTab(
        icon: const Icon(Icons.developer_mode),
        selectedIcon: const Icon(Icons.developer_mode),
        label: "Guide",
        onClick: (BuildContext context) {
          context.hyper.navigate(GuideScreen.routeName);
        },
      ),
      NavigationTab(
        icon: const Icon(Icons.settings_applications_outlined),
        selectedIcon: const Icon(Icons.settings_applications),
        label: "Insides",
        onClick: (BuildContext context) {
          context.hyper.navigate(InsideScreen.routeName);
        },
      ),
    ];

    return switch (context.width) {
      < mediumWidth => _ShellWithAppBar(
          controller: controller,
          tabs: tabs,
          child: child,
        ),
      _ => _ShellWithNavRail(
          controller: controller,
          tabs: tabs,
          child: child,
        ),
    };
  }
}

class _ShellWithNavRail extends StatelessWidget {
  const _ShellWithNavRail({
    required this.child,
    required this.controller,
    required this.tabs,
  });

  final Widget child;
  final ShellController controller;
  final List<NavigationTab> tabs;

  @override
  Widget build(BuildContext context) {
    final col = context.col;

    return Scaffold(
      body: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: child,
          ),
          NavigationRail(
            backgroundColor: col.surfaceContainerHighest,
            selectedIndex: controller.tabIndex,
            onDestinationSelected: (index) {
              tabs[index].onClick(context);
            },
            labelType: NavigationRailLabelType.all,
            destinations: tabs.indexed.map((value) {
              final (i, e) = value;

              return NavigationRailDestination(
                icon: i == controller.tabIndex ? e.selectedIcon! : e.icon!,
                label: Text(e.label),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ShellWithAppBar extends StatelessWidget {
  _ShellWithAppBar({
    required this.controller,
    required this.child,
    required this.tabs,
  });

  final ShellController controller;
  final Widget child;
  final List<NavigationTab> tabs;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // key: ,
      appBar: AppBar(
        leading: Builder(builder: (context) {
          return IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: const Icon(Icons.menu),
          );
        }),
      ),
      drawer: Drawer(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: tabs.indexed.map((value) {
              final (_, e) = value;

              return Builder(builder: (context) {
                return TextButton(
                  onPressed: () {
                    e.onClick(context);
                    Scaffold.of(context).closeDrawer();
                  },
                  child: Row(
                    children: [
                      e.icon!,
                      const SizedBox(width: 16),
                      Text(e.label),
                    ],
                  ),
                );
              });
            }).toList(),
          ),
        ),
      ),
      body: child,
    );
  }
}
