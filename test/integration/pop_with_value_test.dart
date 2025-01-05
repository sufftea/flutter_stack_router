import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hyper_router/hyper_router.dart';

import 'base/screens/home_screen.dart';

void main() async {
  testWidgets(
    'Pop with value',
    (widgetTester) async {
      final router = _createRouter();

      await widgetTester.pumpWidget(MaterialApp.router(
        routerConfig: router,
      ));

      await widgetTester.pumpAndSettle();

      const popResult = 'pop result';
      final homeContext = widgetTester.firstElement(find.byType(HomeScreen));
      final dialogResult = homeContext.hyper.navigate(_DialogScreen.name);
      expect(
        dialogResult,
        completion(popResult),
        reason:
            'The future returned from .navigate completes with the value passed into pop()',
      );
      await widgetTester.pumpAndSettle();

      final dialogContext =
          widgetTester.firstElement(find.byType(_DialogScreen));
      dialogContext.hyper.pop(popResult);

      await widgetTester.pumpAndSettle();
    },
  );

  testWidgets(
    'Pop with value after an intermediate navigation',
    (widgetTester) async {
      final router = _createRouter();

      await widgetTester.pumpWidget(MaterialApp.router(
        routerConfig: router,
      ));

      await widgetTester.pumpAndSettle();

      const popValue = 'pop result';
      final homeContext = widgetTester.firstElement(find.byType(HomeScreen));
      final dialogResult = homeContext.hyper.navigate(_DialogScreen.name);
      await widgetTester.pumpAndSettle();

      final dialogContext =
          widgetTester.firstElement(find.byType(_DialogScreen));
      dialogContext.hyper.navigate(_SubdialogScreen.name);
      await widgetTester.pumpAndSettle();

      final subdialogContext =
          widgetTester.firstElement(find.byType(_SubdialogScreen));
      subdialogContext.hyper.pop();
      await widgetTester.pumpAndSettle();

      dialogContext.hyper.pop(popValue);
      await widgetTester.pumpAndSettle();

      await expectLater(
        dialogResult,
        completion(popValue),
        reason:
            'The future returned from .navigate completes with the value passed into pop()',
      );
    },
    timeout: const Timeout(Duration(seconds: 4)),
  );
}

HyperRouter _createRouter() {
  return HyperRouter(
    initialRoute: HomeScreen.routeName,
    routes: [
      NamedRoute(
        screenBuilder: (context) => const HomeScreen(),
        name: HomeScreen.routeName,
        children: [
          NamedRoute(
            name: _DialogScreen.name,
            screenBuilder: (context) => const _DialogScreen(),
            children: [
              NamedRoute(
                screenBuilder: (context) => _SubdialogScreen(),
                name: _SubdialogScreen.name,
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class _DialogScreen extends StatelessWidget {
  const _DialogScreen();

  static const name = RouteName('dialogScreen');

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}

class _SubdialogScreen extends StatelessWidget {
  const _SubdialogScreen();

  static const name = RouteName('subdialogScreen');

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
