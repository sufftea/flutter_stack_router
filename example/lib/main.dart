import 'package:example/features/demos/guard/auth_screen.dart';
import 'package:example/features/demos/guard/authwalled_screen.dart';
import 'package:example/features/demos/guard/state/auth_cubit.dart';
import 'package:example/features/demos/guard/state/auth_state.dart';
import 'package:example/features/navigation/router.dart';
import 'package:example/features/utils/material_match.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit()),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          final c = router.controller;

          if (!state.authenticated &&
              c.stack.containsNode(AuthwalledScreen.routeName.key)) {
            c.navigate(AuthRouteValue(c.stack.last().value));
          }
        },
        child: MaterialApp.router(
          theme: _createTheme(),
          routerConfig: router,
        ),
      ),
    );
  }

  ThemeData _createTheme() {
    final theme = FlexColorScheme.dark(
      useMaterial3: true,
      scheme: FlexScheme.deepPurple,
    ).toTheme;

    return theme.copyWith(
      cardTheme: CardTheme(
        margin: const EdgeInsets.all(8),
        color: theme.colorScheme.surfaceContainerHighest,
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.circular(32),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 32),
        hoverColor: theme.colorScheme.tertiaryContainer,
        filled: true,
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          textStyle: materialMatch(
            all: const TextStyle(
              fontSize: 16,
            ),
          ),
          padding: materialMatch(all: const EdgeInsets.all(24)),
          splashFactory: InkSparkle.splashFactory,
        ),
      ),
      iconButtonTheme: const IconButtonThemeData(
        style: ButtonStyle(splashFactory: InkSparkle.splashFactory),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          textStyle: materialMatch(
            all: const TextStyle(
              fontSize: 16,
            ),
          ),
          padding: materialMatch(all: const EdgeInsets.all(24)),
          splashFactory: InkSparkle.splashFactory,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          textStyle: materialMatch(
            all: const TextStyle(
              fontSize: 16,
            ),
          ),
          padding: materialMatch(all: const EdgeInsets.all(24)),
          splashFactory: InkSparkle.splashFactory,
        ),
      ),
      dialogTheme: DialogTheme(
        actionsPadding: const EdgeInsets.all(32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
      ),
    );
  }
}
