import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../content/story_video_slide.dart';
import '../theme/stories_theme_data.dart';

/// A single story slide belonging to a [StoryUser].
///
/// Use factories such as [imageUrl], [videoUrl], or [widget] for common cases.
class StoryItem {
  /// Creates a slide with a custom [builder].
  const StoryItem({
    required this.id,
    required this.builder,
    this.duration,
    this.isVideo = false,
    this.title,
    this.subtitle,
    this.caption,
  });

  /// Unique id for this slide; passed to [StoriesPanel.onSeenStory].
  final String id;

  /// Builds the story content (image, video wrapper, text, etc.).
  final WidgetBuilder builder;

  /// Slide duration.
  ///
  /// When null, images and widgets use [StoriesThemeData.defaultStoryDuration].
  /// Video slides ([isVideo]) use the loaded video length unless [duration] is set.
  final Duration? duration;

  /// Whether this slide is a video (see video factories).
  final bool isVideo;

  /// True when playback should follow the loaded video length.
  bool get usesVideoDuration => isVideo && duration == null;

  /// Shown at the top of the slide (below the header row).
  final String? title;

  /// Shown under [title] at the top of the slide.
  final String? subtitle;

  /// Optional caption shown at the bottom of the viewer.
  final String? caption;

  /// Network image story slide.
  factory StoryItem.imageUrl(
    String url, {
    required String id,
    Duration? duration,
    String? title,
    String? subtitle,
    String? caption,
    BoxFit? fit,
    Map<String, String>? headers,
  }) {
    return StoryItem(
      id: id,
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
    required String id,
    Duration? duration,
    String? title,
    String? subtitle,
    String? caption,
    BoxFit? fit,
    String? package,
  }) {
    return StoryItem(
      id: id,
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
    required String id,
    Duration? duration,
    String? title,
    String? subtitle,
    String? caption,
  }) {
    return StoryItem(
      id: id,
      duration: duration,
      title: title,
      subtitle: subtitle,
      caption: caption,
      builder: (_) => child,
    );
  }

  /// Cached network video ([cached_video_player_plus]).
  factory StoryItem.videoUrl(
    String url, {
    required String id,
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
      id: id,
      duration: duration,
      isVideo: true,
      title: title,
      subtitle: subtitle,
      caption: caption,
      builder: (context) => StoryVideoSlide.network(
        url,
        storyDuration: duration,
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
    required String id,
    Duration? duration,
    String? title,
    String? subtitle,
    String? caption,
    BoxFit? fit,
    bool? looping,
  }) {
    return StoryItem(
      id: id,
      duration: duration,
      isVideo: true,
      title: title,
      subtitle: subtitle,
      caption: caption,
      builder: (context) => StoryVideoSlide.file(
        file,
        storyDuration: duration,
        fit: fit,
        looping: looping,
      ),
    );
  }

  /// Asset video story slide.
  factory StoryItem.videoAsset(
    String asset, {
    required String id,
    Duration? duration,
    String? title,
    String? subtitle,
    String? caption,
    String? package,
    BoxFit? fit,
    bool? looping,
  }) {
    return StoryItem(
      id: id,
      duration: duration,
      isVideo: true,
      title: title,
      subtitle: subtitle,
      caption: caption,
      builder: (context) => StoryVideoSlide.asset(
        asset,
        storyDuration: duration,
        package: package,
        fit: fit,
        looping: looping,
      ),
    );
  }

  /// Resolves slide duration for playback bootstrap.
  ///
  /// Video slides without an explicit [duration] return the theme default until
  /// [StoryVideoSlide] reports the real video length.
  Duration resolveDuration(BuildContext context) {
    if (duration != null) return duration!;
    return StoriesThemeData.resolve(context).defaultStoryDuration;
  }
}
