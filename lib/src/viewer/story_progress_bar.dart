import 'package:flutter/material.dart';

import '../theme/stories_theme_data.dart';

/// Segmented progress indicators at the top of the story viewer.
class StoryProgressBar extends StatelessWidget {
  /// Creates a row of [count] segments; [activeProgress] fills the active one.
  const StoryProgressBar({
    super.key,
    required this.count,
    required this.activeIndex,
    required this.activeProgress,
    this.height,
    this.spacing,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
  });

  final int count;
  final int activeIndex;
  final double activeProgress;
  final double? height;
  final double? spacing;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    final theme = StoriesTheme.of(context);
    final barHeight = height ?? theme.progressBarHeight;
    final barSpacing = spacing ?? theme.progressBarSpacing;
    final bg = backgroundColor ?? theme.progressBarBackgroundColor;
    final fg = foregroundColor ?? theme.progressBarForegroundColor;
    final barPadding = padding ?? theme.progressBarPadding;

    return Padding(
      padding: barPadding,
      child: Row(
        children: List.generate(count, (i) {
          final progress = i < activeIndex
              ? 1.0
              : i == activeIndex
                  ? activeProgress.clamp(0.0, 1.0)
                  : 0.0;

          return Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                start: i == 0 ? 0 : barSpacing / 2,
                end: i == count - 1 ? 0 : barSpacing / 2,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(barHeight),
                child: SizedBox(
                  height: barHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColoredBox(color: bg),
                      FractionallySizedBox(
                        alignment: AlignmentDirectional.centerStart,
                        widthFactor: progress,
                        child: ColoredBox(color: fg),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
