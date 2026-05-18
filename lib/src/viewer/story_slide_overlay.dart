import 'package:flutter/material.dart';

import '../models/story_item.dart';
import '../theme/stories_theme_data.dart';

/// Title and subtitle shown at the top of a story slide.
class StorySlideOverlay extends StatelessWidget {
  const StorySlideOverlay({
    super.key,
    required this.item,
    this.titleStyle,
    this.subtitleStyle,
    this.padding,
  });

  final StoryItem item;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final title = item.title;
    final subtitle = item.subtitle;
    if ((title == null || title.isEmpty) &&
        (subtitle == null || subtitle.isEmpty)) {
      return const SizedBox.shrink();
    }

    final theme = StoriesTheme.of(context);
    final overlayPadding = padding ?? theme.storyOverlayPadding;

    return PositionedDirectional(
      top: 0,
      start: 0,
      end: 0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.55),
              Colors.black.withValues(alpha: 0),
            ],
          ),
        ),
        child: Padding(
          padding: overlayPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null && title.isNotEmpty)
                Text(
                  title,
                  style: titleStyle ?? theme.storyTitleStyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              if (subtitle != null && subtitle.isNotEmpty) ...[
                if (title != null && title.isNotEmpty)
                  const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: subtitleStyle ?? theme.storySubtitleStyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
