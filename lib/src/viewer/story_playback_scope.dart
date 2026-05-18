import 'package:flutter/material.dart';

import '../controller/story_playback_controller.dart';

/// Exposes the active [StoryPlaybackController] to slide content (e.g. video).
class StoryPlaybackScope extends InheritedWidget {
  const StoryPlaybackScope({
    super.key,
    required this.playback,
    required super.child,
  });

  final StoryPlaybackController playback;

  static StoryPlaybackController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<StoryPlaybackScope>();
    assert(scope != null, 'StoryPlaybackScope not found');
    return scope!.playback;
  }

  static StoryPlaybackController? maybeOf(BuildContext context) {
    return context
        .getInheritedWidgetOfExactType<StoryPlaybackScope>()
        ?.playback;
  }

  @override
  bool updateShouldNotify(StoryPlaybackScope oldWidget) =>
      playback != oldWidget.playback;
}
