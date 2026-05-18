import 'dart:io';

import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/material.dart';

import '../content/story_video_slide.dart';
import '../theme/stories_theme_data.dart';

/// A single story slide belonging to a [StoryUser].
///
/// Use factories such as [imageUrl], [videoUrl], or [widget] for common cases.
class StoryItem {
  /// Creates a slide with a custom [builder].
  const StoryItem({
    required this.builder,
    this.duration,
    this.title,
    this.subtitle,
    this.caption,
  });

  /// Builds the story content (image, video wrapper, text, etc.).
  final WidgetBuilder builder;

  /// Slide duration; when null, [StoriesThemeData.defaultStoryDuration] is used.
  final Duration? duration;

  /// Shown at the top of the slide (below the header row).
  final String? title;

  /// Shown under [title] at the top of the slide.
  final String? subtitle;

  /// Optional caption shown at the bottom of the viewer.
  final String? caption;

  /// Network image story slide.
  factory StoryItem.imageUrl(
    String url, {
    Duration? duration,
    String? title,
    String? subtitle,
    String? caption,
    BoxFit? fit,
    Map<String, String>? headers,
  }) {
    return StoryItem(
      duration: duration,
      title: title,
      subtitle: subtitle,
      caption: caption,
      builder: (context) {
        final theme = StoriesTheme.of(context);
        return Image.network(
          url,
          headers: headers,
          fit: fit ?? theme.storyImageFit,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            final placeholder = theme.storyPlaceholder;
            if (placeholder != null) return placeholder;
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return theme.storyPlaceholder ??
                const Center(
                  child: Icon(Icons.broken_image, color: Colors.white54),
                );
          },
        );
      },
    );
  }

  /// Asset image story slide.
  factory StoryItem.imageAsset(
    String asset, {
    Duration? duration,
    String? title,
    String? subtitle,
    String? caption,
    BoxFit? fit,
    String? package,
  }) {
    return StoryItem(
      duration: duration,
      title: title,
      subtitle: subtitle,
      caption: caption,
      builder: (context) {
        final theme = StoriesTheme.of(context);
        return Image.asset(
          asset,
          package: package,
          fit: fit ?? theme.storyImageFit,
          errorBuilder: (context, error, stackTrace) {
            return theme.storyPlaceholder ??
                const Center(
                  child: Icon(Icons.broken_image, color: Colors.white54),
                );
          },
        );
      },
    );
  }

  /// Solid color or custom widget story slide.
  factory StoryItem.widget(
    Widget child, {
    Duration? duration,
    String? title,
    String? subtitle,
    String? caption,
  }) {
    return StoryItem(
      duration: duration,
      title: title,
      subtitle: subtitle,
      caption: caption,
      builder: (_) => child,
    );
  }

  /// Cached network video ([cached_video_player]).
  factory StoryItem.videoUrl(
    String url, {
    Duration? duration,
    String? title,
    String? subtitle,
    String? caption,
    BoxFit? fit,
    Map<String, String> httpHeaders = const {},
    VideoFormat? formatHint,
    bool? looping,
  }) {
    return StoryItem(
      duration: duration,
      title: title,
      subtitle: subtitle,
      caption: caption,
      builder: (context) => StoryVideoSlide.network(
        url,
        httpHeaders: httpHeaders,
        formatHint: formatHint,
        fit: fit,
        looping: looping,
      ),
    );
  }

  /// Local file video story slide.
  factory StoryItem.videoFile(
    File file, {
    Duration? duration,
    String? title,
    String? subtitle,
    String? caption,
    BoxFit? fit,
    bool? looping,
  }) {
    return StoryItem(
      duration: duration,
      title: title,
      subtitle: subtitle,
      caption: caption,
      builder: (context) => StoryVideoSlide.file(
        file,
        fit: fit,
        looping: looping,
      ),
    );
  }

  /// Asset video story slide.
  factory StoryItem.videoAsset(
    String asset, {
    Duration? duration,
    String? title,
    String? subtitle,
    String? caption,
    String? package,
    BoxFit? fit,
    bool? looping,
  }) {
    return StoryItem(
      duration: duration,
      title: title,
      subtitle: subtitle,
      caption: caption,
      builder: (context) => StoryVideoSlide.asset(
        asset,
        package: package,
        fit: fit,
        looping: looping,
      ),
    );
  }

  /// Resolves slide duration from theme. Safe to call after [State.initState].
  Duration resolveDuration(BuildContext context) =>
      duration ?? StoriesThemeData.resolve(context).defaultStoryDuration;
}
