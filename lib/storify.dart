/// Instagram-like stories for Flutter.
///
/// Provides a scrollable story tray, full-screen viewer, RTL layout,
/// theming, transitions, and cached video slides.
///
/// ## Getting started
///
/// ```dart
/// import 'package:storify/storify.dart';
///
/// StoriesPanel(
///   users: [
///     StoryUser(
///       id: '1',
///       name: 'Alex',
///       stories: [
///         StoryItem.imageUrl(
///           'https://example.com/photo.jpg',
///           id: 'photo_1',
///         ),
///       ],
///     ),
///   ],
/// )
/// ```
///
/// See also:
///
/// * [StoriesPanel] — tray + viewer
/// * [StoriesThemeData] — global styling
/// * [StoryViewer] — full-screen player
library;

export 'src/animations/story_transitions.dart';
export 'src/content/story_video_slide.dart';
export 'src/controller/story_playback_controller.dart';
export 'src/models/story_item.dart';
export 'src/models/story_user.dart';
export 'src/stories_panel.dart';
export 'src/stories_scope.dart';
export 'src/theme/stories_theme_data.dart';
export 'src/tray/stories_tray.dart';
export 'src/tray/story_avatar.dart';
export 'src/viewer/story_gesture_layer.dart';
export 'src/viewer/story_playback_scope.dart';
export 'src/viewer/story_progress_bar.dart';
export 'src/viewer/story_slide_overlay.dart';
export 'src/viewer/story_viewer.dart';
