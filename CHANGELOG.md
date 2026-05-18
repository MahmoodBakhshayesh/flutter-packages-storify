# Changelog

All notable changes to the **storify** package are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
- `StoryVideoSlide` with `cached_video_player` and hold-to-pause sync.
- `StoryAvatar`, `StoryProgressBar`, `StorySlideOverlay`, `StoryGestureLayer`.
- Example app with transition pickers and RTL toggle.

[0.1.0]: https://github.com/MahmoodBakhshayesh/flutter-packages-stories/releases/tag/v0.1.0
