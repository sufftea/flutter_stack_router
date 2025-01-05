import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'base/screens/second_tab_screen.dart';
import 'base/screens/tabs_shell.dart';
import 'base/screens/value_screen.dart';
import 'base/screens/home_screen.dart';
import 'base/screens/login_screen.dart';
import 'package:hyper_router/hyper_router.dart';

void main() {
  testWidgets(
    'Redirect callback',
    (widgetTester) async {
      final router = _createRouter();

      await widgetTester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ValueNotifier(AuthState(false)),
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await widgetTester.pumpAndSettle();
      expect(
        find.byType(LoginScreen).hitTestable(),
        findsOneWidget,
        reason: 'Redirects to login screen on initialization',
      );

      final loginContext = widgetTester.firstElement(find.byType(LoginScreen));

      loginContext.read<ValueNotifier<AuthState>>().value = AuthState(true);
      loginContext.hyper.navigate(HomeScreen.routeName);

      await widgetTester.pumpAndSettle();
      expect(find.byType(HomeScreen).hitTestable(), findsOneWidget,
          reason: 'Navigate to home screen after authentication');
    },
  );
}

HyperRouter _createRouter() {
  return HyperRouter(
    initialRoute: HomeScreen.routeName,
    redirect: (context, state) {
      final authenticated =
          context.read<ValueNotifier<AuthState>>().value.authenticated;

      if (!authenticated) {
        return LoginScreen.routeName;
      }

      return null;
    },
    routes: [
      ShellRoute(
        shellBuilder: (context, controller, child) => TabsShell(
          controller: controller,
          child: child,
        ),
        tabs: [
          NamedRoute(
              screenBuilder: (context) => const HomeScreen(),
              name: HomeScreen.routeName,
              children: [
                ValueRoute<SomeValue>(
                  screenBuilder: (context, value) => ValueScreen(value: value),
                ),
              ]),
          NamedRoute(
            screenBuilder: (context) => const SecondTabScreen(),
            name: SecondTabScreen.routeName,
          ),
        ],
      ),
      NamedRoute(
        screenBuilder: (context) => const LoginScreen(),
        name: LoginScreen.routeName,
      ),
    ],
  );
}

class AuthState {
  AuthState(this.authenticated);

  final bool authenticated;
}
