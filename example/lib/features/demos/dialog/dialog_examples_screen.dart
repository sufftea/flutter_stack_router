import 'package:example/features/demos/dialog/dialog_screen.dart';
import 'package:example/features/demos/dialog/text_dialog.dart';
import 'package:example/features/utils/context_x.dart';
import 'package:example/features/widgets/limit_width.dart';
import 'package:flutter/material.dart';
import 'package:hyper_router/hyper_router.dart';
import 'package:toastification/toastification.dart';

class DialogExamplesScreen extends StatefulWidget {
  const DialogExamplesScreen({super.key});

  static const routeName = RouteName('dialog-examples');

  @override
  State<DialogExamplesScreen> createState() => _DialogExamplesScreenState();
}

class _DialogExamplesScreenState extends State<DialogExamplesScreen> {
  void showResult(dynamic result) {
    if (!mounted) {
      return;
    }

    final col = context.col;

    if (result is String?) {
      toastification.show(
        context: context,
        title: const Text(
          'Result',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        description: Text(
          result.toString(),
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        borderRadius: BorderRadius.circular(16),
        primaryColor: col.primary,
        backgroundColor: col.surfaceContainerHighest,
        foregroundColor: col.onSurfaceVariant,
        style: ToastificationStyle.flatColored,
        type: ToastificationType.info,
        alignment: Alignment.bottomCenter,
        animationDuration: const Duration(milliseconds: 400),
        padding: const EdgeInsets.all(16),
        autoCloseDuration: const Duration(seconds: 4),
      );
    } else {
      toastification.show(
        context: context,
        title: const Text(
          'Something went wrong...',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        type: ToastificationType.error,
        borderRadius: BorderRadius.circular(16),
        primaryColor: col.error,
        backgroundColor: col.surfaceContainerHighest,
        foregroundColor: col.onSurfaceVariant,
        style: ToastificationStyle.flatColored,
        alignment: Alignment.bottomCenter,
        animationDuration: const Duration(milliseconds: 400),
        padding: const EdgeInsets.all(16),
        autoCloseDuration: const Duration(seconds: 4),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: LimitWidth(
        maxWidth: 256,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: () async {
                final result = await showDialog(
                  context: context,
                  builder: (context) => const TextDialog(),
                );

                showResult(result);
              },
              child: const Text('Open a dialog'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () async {
                final result =
                    await context.hyper.navigate(DialogScreen.routeName);
                showResult(result);
              },
              child: const Text('Open a page'),
            ),
          ],
        ),
      ),
    );
  }
}
