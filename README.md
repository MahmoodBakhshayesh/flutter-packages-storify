# storify

[![pub package](https://img.shields.io/pub/v/storify.svg)](https://pub.dev/packages/storify)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A Flutter package for **Instagram-like stories**: scrollable thumbnail tray, full-screen viewer, RTL support, theming, transitions, and cached video.

<p align="center">
  <strong>Tray → tap → full viewer → gestures → next user</strong>
</p>

---

## Table of contents

- [Features](#features)
- [Installation](#installation)
- [Migrating](#migrating)
- [Quick start](#quick-start)
- [Seen state](#seen-state)
- [Widgets](#widgets)
- [Models](#models)
- [Theming](#theming)
- [Transitions](#transitions)
- [Story content helpers](#story-content-helpers)
- [Gestures](#gestures)
- [RTL](#rtl)
- [Video setup](#video-setup)
- [API reference](#api-reference)
- [Example app](#example-app)
- [Comparison](#comparison)
- [Contributing](#contributing)
- [License](#license)

---

## Features

| Feature | Description |
|---------|-------------|
| **StoriesTray** | Horizontal scrollable row of avatars with gradient (unseen) or gray (seen) rings |
| **StoriesPanel** | Tray wired to open the viewer and mark users as seen |
| **StoryViewer** | Full-screen viewer with progress bars, header, captions, title/subtitle overlay |
| **RTL** | Directional padding, progress fill, tap zones, and tray scroll |
| **Theming** | `StoriesThemeData` via `ThemeData.extensions` or `StoriesScope` |
| **Transitions** | Configurable animations for slides and users (fade, slide, cube, …) |
| **Hold to pause** | Progress freezes; video pauses in sync |
| **Per-user seen** | `onUserSeen` callback with `StoryUser.id` (you own persistence) |
| **Per-story seen** | `onSeenStory` callback with `StoryItem.id` (you own persistence) |
| **Custom slides** | Any widget per slide via `StoryItem.builder` |
| **Cached video** | `StoryItem.videoUrl` / `StoryVideoSlide` via `cached_video_player_plus` |

---

## Installation

Add to `pubspec.yaml`:

```yaml
dependencies:
  storify: ^0.3.0
```

Then:

```bash
flutter pub get
```

**Requirements:** Dart `^3.5.0`, Flutter `>=3.24.0`. Supports Android, iOS, Web, Windows, macOS, and Linux.

Import:

```dart
import 'package:storify/storify.dart';
```

See [CHANGELOG.md](CHANGELOG.md) for release notes.

---

## Migrating

### From 0.2.0 → 0.3.0

No breaking API changes. Video slides without `duration` now match the video length automatically. To keep a fixed timer, pass `duration` explicitly.

### From 0.1.0 → 0.2.0+

| Change | Action |
|--------|--------|
| **Story ids** | Add `id: '…'` to every `StoryItem` and factory (`imageUrl`, `videoUrl`, etc.). |
| **Video backend** | Storify uses `cached_video_player_plus`. Remove `cached_video_player` from your app if unused elsewhere. |
| **Seen tracking** | Optional: use `onUserSeen` / `onSeenStory` instead of only `onUsersChanged`. |

```dart
// 0.1.0
StoryItem.imageUrl('https://example.com/1.jpg')

// 0.2.0+
StoryItem.imageUrl('https://example.com/1.jpg', id: 'story_1')
```

---

## Quick start

```dart
import 'package:flutter/material.dart';
import 'package:storify/storify.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        extensions: [StoriesThemeData.light],
      ),
      home: Scaffold(
        body: StoriesPanel(
          users: [
            StoryUser(
              id: '1',
              name: 'Alex',
              avatar: NetworkImage('https://example.com/avatar.jpg'),
              stories: [
                StoryItem.imageUrl(
                  'https://example.com/story1.jpg',
                  id: 'alex_story_1',
                  title: 'Alex',
                  subtitle: '2h ago',
                  caption: 'Hello!',
                ),
              ],
            ),
          ],
          onUserSeen: (userId) {
            // Persist per-user seen state (tray ring)
          },
          onSeenStory: (storyId) {
            // Persist per-slide seen state
          },
          onUsersChanged: (users) {
            // Optional: sync tray when the panel updates seen rings
          },
        ),
      ),
    );
  }
}
```

---

## Seen state

Storify does **not** keep a global list of seen users or stories. You persist ids in callbacks:

| Callback | Id type | When it fires |
|----------|---------|----------------|
| `onUserSeen` | `StoryUser.id` | User finishes **all** slides (once per user per viewer session) |
| `onSeenStory` | `StoryItem.id` | Slide is viewed — timer ends, tap next, swipe user, or close (once per story per session) |
| `onUsersChanged` | full `List<StoryUser>` | `StoriesPanel` updates tray rings internally (optional sync) |

```dart
StoriesPanel(
  users: users,
  onUserSeen: (userId) async {
    await prefs.setBool('user_seen_$userId', true);
    setState(() => /* rebuild tray with StoryUser.seen */);
  },
  onSeenStory: (storyId) async {
    await prefs.setBool('story_seen_$storyId', true);
  },
)
```

Set `StoryUser.seen: true` on users you have already marked seen so the tray shows gray rings on launch.

---

## Widgets

### `StoriesPanel`

Combines **tray + viewer**. Tapping a user opens `StoryViewer`; completing their stories marks them **seen**.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `users` | `List<StoryUser>` | required | Users shown in the tray |
| `onUserSeen` | `ValueChanged<String>?` | null | Called with `StoryUser.id` when all slides are viewed |
| `onSeenStory` | `ValueChanged<String>?` | null | Called with `StoryItem.id` when a slide is viewed |
| `onUsersChanged` | `ValueChanged<List<StoryUser>>?` | null | Called when the panel updates its user list (e.g. tray ring) |
| `showAddButton` | `bool` | `false` | Show “Your story” tile first |
| `onAddStoryTap` | `VoidCallback?` | null | Add-button callback |
| `trayHeight` | `double?` | theme | Tray height |
| `trayPadding` | `EdgeInsetsGeometry?` | theme | Tray horizontal padding |
| `storyItemTransition` | `StoryItemTransition?` | theme | Slide-to-slide animation |
| `userTransition` | `StoryUserTransition?` | theme | User-to-user animation |
| `transitionDuration` | `Duration?` | theme | Animation duration |
| `transitionCurve` | `Curve?` | theme | Animation curve |
| `progressBar` | custom builder | null | Custom progress widget |
| `headerBuilder` | custom builder | null | Custom header row |

### `StoriesTray`

Thumbnail strip only (no viewer). Use `onUserTap` to open your own flow or `StoryViewer.show`.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `users` | `List<StoryUser>` | required | Users in the tray |
| `onUserTap` | `void Function(int, StoryUser)?` | null | Tap callback with index |
| `height` | `double?` | theme `trayHeight` | Row height |
| `avatarSize` | `double?` | theme `trayAvatarSize` | Avatar diameter |
| `itemSpacing` | `double?` | theme | Space between tiles |
| `padding` | `EdgeInsetsGeometry?` | theme | List padding |
| `labelStyle` | `TextStyle?` | theme | Username text style |
| `labelSpacing` | `double?` | theme | Gap below avatar |
| `showAddButton` | `bool` | `false` | “Your story” tile |
| `addButtonLabel` | `String?` | theme | Add tile label |
| `addButtonBuilder` | `WidgetBuilder?` | null | Fully custom add tile |

### `StoryViewer`

Full-screen story player.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `users` | `List<StoryUser>` | required | All users |
| `initialUserIndex` | `int` | `0` | User to open first |
| `onClose` | `VoidCallback?` | pop route | When viewer closes |
| `onUserSeen` | `ValueChanged<String>?` | null | Called with `StoryUser.id` when all slides are viewed |
| `onSeenStory` | `ValueChanged<String>?` | null | Called with `StoryItem.id` when a slide is viewed |
| `onStoryChanged` | `void Function(int, int)?` | null | `(userIndex, storyIndex)` |
| `backgroundColor` | `Color?` | theme | Viewer background |
| `storyItemTransition` | `StoryItemTransition?` | theme | Slide animation |
| `userTransition` | `StoryUserTransition?` | theme | User animation |
| `captionStyle` | `TextStyle?` | theme | Bottom caption style |
| `titleStyle` | `TextStyle?` | theme | Slide title override |
| `subtitleStyle` | `TextStyle?` | theme | Slide subtitle override |
| `progressBar` | builder | null | Custom progress bar |
| `headerBuilder` | builder | null | Custom header |

**Static method:** `StoryViewer.show(context, users: …)` opens a full-screen route.

### `StoryAvatar`

Standalone circular avatar with seen/unseen ring (used inside `StoriesTray`).

### `StoryProgressBar`

Segmented top progress indicators.

| Parameter | Type | Description |
|-----------|------|-------------|
| `count` | `int` | Number of segments |
| `activeIndex` | `int` | Current slide index |
| `activeProgress` | `double` | `0.0`–`1.0` on active segment |
| `height` | `double?` | Bar thickness |
| `spacing` | `double?` | Gap between segments |
| `backgroundColor` | `Color?` | Unfilled color |
| `foregroundColor` | `Color?` | Filled color |
| `padding` | `EdgeInsetsGeometry?` | Outer padding |

### `StoriesScope`

Wraps a subtree with optional `textDirection` and/or `StoriesThemeData`.

### `StoryGestureLayer`

Low-level gesture overlay (tap start/end, hold pause). Usually used internally.

### `StorySlideOverlay`

Renders `StoryItem.title` and `StoryItem.subtitle` at the top of a slide.

### `StoryVideoSlide`

Video slide widget with caching; syncs pause with `StoryPlaybackScope`.

---

## Models

### `StoryUser`

| Field | Type | Description |
|-------|------|-------------|
| `id` | `String` | Unique id |
| `name` | `String` | Shown under tray avatar and in header |
| `stories` | `List<StoryItem>` | Slides for this user |
| `avatar` | `ImageProvider?` | Tray and header avatar |
| `seen` | `bool` | `true` = gray ring on tray |

`copyWith()` updates seen state after viewing.

### `StoryItem`

| Field | Type | Description |
|-------|------|-------------|
| `id` | `String` | Unique slide id (used by `onSeenStory`) |
| `builder` | `WidgetBuilder` | Slide content |
| `duration` | `Duration?` | Override slide length; see video behavior below |
| `isVideo` | `bool` | `true` for video factories |
| `title` | `String?` | Top overlay title |
| `subtitle` | `String?` | Top overlay subtitle |
| `caption` | `String?` | Bottom caption in viewer |

**Factories:** `imageUrl`, `imageAsset`, `videoUrl`, `videoFile`, `videoAsset`, `widget` — each requires `id`.

`resolveDuration(BuildContext)` returns effective duration from theme.

---

## Theming

Use `StoriesThemeData` as a `ThemeExtension` or via `StoriesScope(theme: …)`.

```dart
MaterialApp(
  theme: ThemeData(
    extensions: [
      StoriesThemeData.light.copyWith(
        trayAvatarSize: 72,
        unseenRingGradient: LinearGradient(
          colors: [Color(0xFF833AB4), Color(0xFFE1306C)],
        ),
        defaultStoryDuration: Duration(seconds: 6),
        storyItemTransition: StoryItemTransition.slide,
        userTransition: StoryUserTransition.cube,
      ),
    ],
  ),
);
```

### Tray

| Property | Default | Description |
|----------|---------|-------------|
| `trayHeight` | `104` | Tray row height |
| `trayAvatarSize` | `68` | Avatar diameter |
| `trayItemSpacing` | `12` | Horizontal gap |
| `trayPadding` | horizontal `8` | List padding |
| `trayLabelSpacing` | `4` | Below avatar |
| `trayLabelStyle` | `null` | Uses `labelSmall` if null |

### Avatar ring

| Property | Default | Description |
|----------|---------|-------------|
| `unseenRingGradient` | Instagram-like | Gradient ring |
| `seenRingColor` | `#BDBDBD` | Gray ring when seen |
| `ringWidth` | `2.5` | Ring thickness |
| `ringGap` | `2` | White gap before photo |
| `avatarPlaceholder` | person icon | No image |
| `avatarBackgroundColor` | `#E0E0E0` | Placeholder fill |

### Slides

| Property | Default | Description |
|----------|---------|-------------|
| `defaultStoryDuration` | `5s` | When `StoryItem.duration` is null |
| `storyImageFit` | `cover` | Image factory fit |
| `storyPlaceholder` | loading/error widget | Image loading |

### Progress bar

| Property | Default |
|----------|---------|
| `progressBarHeight` | `2.5` |
| `progressBarSpacing` | `4` |
| `progressBarBackgroundColor` | white 35% |
| `progressBarForegroundColor` | white |
| `progressBarPadding` | top `8` |

### Viewer

| Property | Default |
|----------|---------|
| `viewerBackgroundColor` | black |
| `captionStyle` | white 15px |
| `storyTitleStyle` | white bold 18px |
| `storySubtitleStyle` | white70 14px |
| `storyOverlayPadding` | 16,12,16,24 |
| `headerNameStyle` | white semibold 14px |
| `headerAvatarRadius` | `16` |
| `headerPadding` | 8 |
| `closeIcon` | `Icons.close` |
| `closeIconColor` | white |

### Add story tile

| Property | Default |
|----------|---------|
| `addStoryLabel` | `Your story` |
| `addButtonColor` | `#0095F6` |
| `addButtonIconSize` | `16` |

### Video

| Property | Default |
|----------|---------|
| `videoFit` | `cover` |
| `videoLooping` | `false` |
| `videoLoadingBuilder` | null (spinner) |

### Transitions

| Property | Default |
|----------|---------|
| `storyItemTransition` | `StoryItemTransition.none` |
| `userTransition` | `StoryUserTransition.page` |
| `transitionDuration` | `280ms` |
| `transitionCurve` | `easeOutCubic` |

Presets: `StoriesThemeData.light`, `StoriesThemeData.dark`.

---

## Transitions

### Story slides — `StoryItemTransition`

| Value | Effect |
|-------|--------|
| `none` | Instant (**default**) |
| `fade` | Cross-fade |
| `slide` | Horizontal (RTL-aware) |
| `slideVertical` | Vertical |
| `scale` | Scale + fade |
| `zoom` | Zoom in |

### Users — `StoryUserTransition`

| Value | Effect |
|-------|--------|
| `page` | Standard PageView (**default**) |
| `fade` | Fade while paging |
| `scale` | Scale while paging |
| `cube` | 3D cube |
| `slideVertical` | Vertical parallax |

---

## Story content helpers

```dart
// Every slide needs a stable id (used by onSeenStory)
StoryItem.imageUrl('https://…/photo.jpg', id: 'news_1', title: 'News')

StoryItem.imageAsset('assets/story.png', id: 'local_1')

// Uses video length for progress (override with duration: …)
StoryItem.videoUrl('https://…/clip.mp4', id: 'clip_1', caption: 'Watch')

// Fixed 8s even if the file is longer
StoryItem.videoUrl('https://…/clip.mp4', id: 'clip_2', duration: Duration(seconds: 8))

StoryItem.widget(MySlide(), id: 'poll_1', title: 'Poll')

StoryItem(
  id: 'custom_1',
  duration: Duration(seconds: 3),
  builder: (context) => MyCustomContent(),
)
```

---

## Gestures

| Gesture | Action |
|---------|--------|
| Tap **start** (left in LTR) | Previous slide / previous user on first slide |
| Tap **end** (right in LTR) | Next slide / next user on last slide |
| **Hold** anywhere | Pause progress and video |
| **Swipe down** | Close viewer |
| **Swipe horizontal** | Change user (PageView) |

Tap zones mirror automatically in **RTL**.

---

## RTL

Wrap the app or a subtree:

```dart
Directionality(
  textDirection: TextDirection.rtl,
  child: StoriesPanel(users: users),
)
```

Or:

```dart
StoriesScope(
  textDirection: TextDirection.rtl,
  child: StoriesPanel(users: users),
)
```

---

## Video setup

This package uses [`cached_video_player_plus`](https://pub.dev/packages/cached_video_player_plus) for network video caching.

1. Follow the [video_player installation](https://pub.dev/packages/video_player#installation) for Android and iOS (required by the player).
2. Use `StoryItem.videoUrl`, `videoFile`, or `videoAsset`.
3. Video pauses when the user holds to pause stories.

### Story duration for video

| `duration` on `StoryItem` | `looping` | Progress timer |
|---------------------------|-----------|----------------|
| omitted | `false` (default) | **Video length** (loaded after init) |
| set | any | **Your `duration`** |
| omitted | `true` | Theme `defaultStoryDuration` |

Progress waits until the video is initialized so the bar matches the real length. Set `duration` to cap or extend how long a slide stays open.

Network videos are cached via `flutter_cache_manager`. Asset and file sources play directly without caching.

---

## API reference

Full API docs: [pub.dev/documentation/storify](https://pub.dev/documentation/storify/latest/)

Generate locally:

```bash
dart doc .
open doc/api/index.html
```

---

## Example app

```bash
cd example
flutter run
```

The example includes transition pickers, RTL toggle, and themed tray. See [example/README.md](example/README.md).

---

## Comparison

| | story_view | **storify** |
|---|------------|-------------|
| Thumbnail tray | DIY | Built-in `StoriesTray` |
| RTL | Limited | Full directional layout |
| Theming | Partial | `StoriesThemeData` |
| Transitions | — | Slide + user animations |
| Seen state on tray | DIY | `StoryUser.seen` + `onUserSeen` |
| Per-slide seen callback | — | `onSeenStory` |
| Title/subtitle overlay | — | Per slide |
| Cached video | — | `cached_video_player_plus` via `StoryItem.videoUrl` |

---

## Contributing

Issues and pull requests are welcome on [GitHub](https://github.com/MahmoodBakhshayesh/flutter-packages-storify).

---

## License

MIT — see [LICENSE](LICENSE).
