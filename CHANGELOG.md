# Changelog

All notable changes to the **storify** package are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-05-18

### Added

- **`onUserSeen`** on `StoriesPanel` and `StoryViewer` — `ValueChanged<String>` called with `StoryUser.id` when a user finishes all of their slides. The package does not store seen user ids; you persist them in the callback.
- **`onSeenStory`** on `StoriesPanel` and `StoryViewer` — `ValueChanged<String>` called with `StoryItem.id` when a slide is considered viewed. The package does not store seen story ids; you persist them in the callback.
- **`StoryItem.id`** — required unique id on every slide (all factories accept `required String id`).

### Changed

- **Breaking:** Replaced [`cached_video_player`](https://pub.dev/packages/cached_video_player) with [`cached_video_player_plus`](https://pub.dev/packages/cached_video_player_plus) for network video caching in `StoryVideoSlide` and `StoryItem.videoUrl`.
- **Breaking:** Added a direct [`video_player`](https://pub.dev/packages/video_player) dependency (`VideoPlayer` widget and `VideoFormat` on `StoryItem.videoUrl`).
- **Breaking:** `StoryItem` and all factories now require an `id` parameter.

### Migration from 0.1.0

1. **Add ids to every slide:**

   ```dart
   // Before
   StoryItem.imageUrl('https://example.com/1.jpg')

   // After
   StoryItem.imageUrl('https://example.com/1.jpg', id: 'story_1')
   ```

2. **Optional — track seen state with callbacks** (instead of only `onUsersChanged`):

   ```dart
   StoriesPanel(
     users: users,
     onUserSeen: (userId) => saveUserSeen(userId),
     onSeenStory: (storyId) => saveStorySeen(storyId),
   )
   ```

3. **Video:** Remove `cached_video_player` from your app if you added it only for stories; storify now uses `cached_video_player_plus` internally.

### Notes

- `onUserSeen` fires once per user id per viewer session when their last slide completes.
- `onSeenStory` fires once per story id per viewer session (timer end, tap next, swipe to another user, or close).
- `onUsersChanged` still updates the tray when `StoriesPanel` marks a user seen internally.
- Network videos are cached via `flutter_cache_manager`; asset and file sources are not cached.

## [0.1.0] - 2026-05-18

### Added

- `StoriesTray` — horizontal scrollable thumbnail row with seen/unseen rings.
- `StoriesPanel` — tray wired to open the full-screen viewer.
- `StoryViewer` — segmented progress, header, captions, gestures (tap, hold, swipe down).
- `StoryUser` and `StoryItem` models with title, subtitle, and caption support.
- `StoriesThemeData` — tray, rings, viewer, progress bar, video, and transition styling.
- `StoriesScope` for RTL and theme overrides.
- RTL support via directional layout throughout.
- `StoryItemTransition` and `StoryUserTransition` (fade, slide, scale, zoom, cube, and more).
- `StoryItem` helpers: `imageUrl`, `imageAsset`, `videoUrl`, `videoFile`, `videoAsset`, `widget`.
- `StoryVideoSlide` with cached network video and hold-to-pause sync.
- `StoryAvatar`, `StoryProgressBar`, `StorySlideOverlay`, `StoryGestureLayer`.
- Example app with transition pickers and RTL toggle.

[0.2.0]: https://github.com/MahmoodBakhshayesh/flutter-packages-storify/releases/tag/v0.2.0
[0.1.0]: https://github.com/MahmoodBakhshayesh/flutter-packages-storify/releases/tag/v0.1.0
