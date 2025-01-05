import 'package:example/features/utils/context_x.dart';
import 'package:example/features/utils/material_match.dart';
import 'package:flutter/material.dart';

class VerticalBannerButton extends StatelessWidget {
  const VerticalBannerButton({
    required this.onPressed,
    required this.title,
    required this.image,
    this.caption,
    super.key,
  });

  final String title;
  final Widget? caption;
  final String image;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: FilledButton(
        onPressed: onPressed,
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll(EdgeInsets.zero),
          shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(32))),
          backgroundColor: materialMatch(
            all: context.col.surfaceContainerHighest,
            hovered: context.col.secondaryContainer,
          ),
          foregroundColor: materialMatch(all: context.col.onSurfaceVariant),
          splashFactory: InkSparkle.splashFactory,
          elevation: materialMatch(
            all: 0,
            hovered: 5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 200,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Image.asset(
                image,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (caption case final caption?) caption,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HorizontalBannerButton extends StatelessWidget {
  const HorizontalBannerButton({
    required this.onPressed,
    required this.title,
    required this.image,
    this.caption,
    super.key,
  });

  final String title;
  final Widget? caption;
  final String? image;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: FilledButton(
        onPressed: onPressed,
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll(EdgeInsets.zero),
          shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(32))),
          backgroundColor: materialMatch(
            all: context.col.surfaceContainerHighest,
            hovered: context.col.secondaryContainer,
          ),
          foregroundColor: materialMatch(all: context.col.onSurfaceVariant),
          splashFactory: InkSparkle.splashFactory,
          elevation: materialMatch(
            all: 0,
            hovered: 5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (image != null)
              SizedBox(
                height: 128,
                width: 128,
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(32)),
                  child: Image.asset(
                    image!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 32,
                  top: 32,
                  bottom: 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (caption case final caption?) caption,
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
