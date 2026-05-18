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
- [Quick start](#quick-start)
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
| **Custom slides** | Any widget per slide via `StoryItem.builder` |
| **Cached video** | `StoryItem.videoUrl` / `StoryVideoSlide` via `cached_video_player` |

---

## Installation

Add to `pubspec.yaml`:

```yaml
dependencies:
  storify: ^0.1.0
```

Then:

```bash
flutter pub get
```

Import:

```dart
import 'package:storify/storify.dart';
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
                  title: 'Alex',
                  subtitle: '2h ago',
                  caption: 'Hello!',
                ),
              ],
            ),
          ],
          onUsersChanged: (users) {
            // Persist seen state
          },
        ),
      ),
    );
  }
}
```

---

## Widgets

### `StoriesPanel`

Combines **tray + viewer**. Tapping a user opens `StoryViewer`; completing their stories marks them **seen**.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `users` | `List<StoryUser>` | required | Users shown in the tray |
| `onUsersChanged` | `ValueChanged<List<StoryUser>>?` | null | Called when seen state updates |
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
| `onUserSeen` | `void Function(int, StoryUser)?` | null | User finished all slides |
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
| `builder` | `WidgetBuilder` | Slide content |
| `duration` | `Duration?` | Slide length; uses theme default if null |
| `title` | `String?` | Top overlay title |
| `subtitle` | `String?` | Top overlay subtitle |
| `caption` | `String?` | Bottom caption in viewer |

**Factories:** `imageUrl`, `imageAsset`, `videoUrl`, `videoFile`, `videoAsset`, `widget`.

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
// Network image
StoryItem.imageUrl('https://…/photo.jpg', title: 'News', duration: Duration(seconds: 8))

// Asset image
StoryItem.imageAsset('assets/story.png')

// Cached video (see video setup)
StoryItem.videoUrl('https://…/clip.mp4', caption: 'Watch')

// Custom widget
StoryItem.widget(MySlide(), title: 'Poll', subtitle: 'Tap to vote')

// Manual builder
StoryItem(
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

This package uses [`cached_video_player`](https://pub.dev/packages/cached_video_player) (Android & iOS caching).

1. Follow the [video_player installation](https://pub.dev/packages/video_player#installation) for Android and iOS.
2. Use `StoryItem.videoUrl`, `videoFile`, or `videoAsset`.
3. Video pauses when the user holds to pause stories.

**Note:** Desktop is not supported by `cached_video_player`.

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
| Seen state on tray | DIY | `StoryUser.seen` |
| Title/subtitle overlay | — | Per slide |
| Cached video helper | — | `StoryItem.videoUrl` |

---

## Contributing

Issues and pull requests are welcome on [GitHub](https://github.com/MahmoodBakhshayesh/flutter-packages-stories).

---

## License

MIT — see [LICENSE](LICENSE).
