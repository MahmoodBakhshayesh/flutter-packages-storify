# stories

Instagram-like stories for Flutter: scrollable thumbnail tray, full-screen viewer, RTL support, theming, and cached video.

## Features

- **StoriesTray** — horizontal scrollable row of avatars with seen/unseen rings
- **StoriesPanel** — tray wired to open the viewer on tap
- **StoriesThemeData** — tray size, ring gradient/colors, default duration, progress bar, viewer colors, video options
- **StoryItem** helpers — `imageUrl`, `imageAsset`, `videoUrl`, `videoFile`, `videoAsset` (via `cached_video_player`)
- **RTL** — directional layout throughout

## Theming

Apply globally via `ThemeData.extensions` or per-subtree with `StoriesScope` / `StoriesTheme`:

```dart
MaterialApp(
  theme: ThemeData(
    extensions: [
      StoriesThemeData.light.copyWith(
        trayAvatarSize: 72,
        ringWidth: 3,
        unseenRingGradient: LinearGradient(
          colors: [Color(0xFF833AB4), Color(0xFFE1306C)],
        ),
        seenRingColor: Color(0xFFBDBDBD),
        defaultStoryDuration: Duration(seconds: 6),
        progressBarHeight: 3,
        progressBarForegroundColor: Colors.white,
        addStoryLabel: 'Your story',
        addButtonColor: Color(0xFF0095F6),
        videoFit: BoxFit.cover,
        videoLooping: false,
      ),
    ],
  ),
);
```

### Theme properties

| Group | Properties |
|-------|------------|
| Tray | `trayHeight`, `trayAvatarSize`, `trayItemSpacing`, `trayPadding`, `trayLabelSpacing`, `trayLabelStyle` |
| Ring | `unseenRingGradient`, `seenRingColor`, `ringWidth`, `ringGap`, `avatarPlaceholder`, `avatarBackgroundColor` |
| Slides | `defaultStoryDuration`, `storyImageFit`, `storyPlaceholder` |
| Progress | `progressBarHeight`, `progressBarSpacing`, `progressBarBackgroundColor`, `progressBarForegroundColor`, `progressBarPadding` |
| Viewer | `viewerBackgroundColor`, `captionStyle`, `headerNameStyle`, `headerAvatarRadius`, `headerPadding`, `closeIcon`, `closeIconColor` |
| Add tile | `addStoryLabel`, `addButtonColor`, `addButtonIconSize` |
| Video | `videoFit`, `videoLooping`, `videoLoadingBuilder` |
| Transitions | `storyItemTransition`, `userTransition`, `transitionDuration`, `transitionCurve` |

Widget-level params (e.g. `StoriesTray(avatarSize: 80)`) override theme when set.

## Transitions

**Story slides** (`StoryItemTransition`) — when tapping or auto-advancing between slides of the same user:

| Value | Effect |
|-------|--------|
| `none` | Instant swap (**default**) |
| `fade` | Cross-fade |
| `slide` | Horizontal slide (RTL-aware) |
| `slideVertical` | Vertical slide |
| `scale` | Scale + fade |
| `zoom` | Zoom in |

**Users** (`StoryUserTransition`) — when swiping between users:

| Value | Effect |
|-------|--------|
| `page` | Standard horizontal PageView (**default**) |
| `fade` | Fade while paging |
| `scale` | Scale while paging |
| `cube` | 3D cube rotation |
| `slideVertical` | Vertical parallax |

```dart
StoriesThemeData.light.copyWith(
  storyItemTransition: StoryItemTransition.slide,
  userTransition: StoryUserTransition.cube,
  transitionDuration: Duration(milliseconds: 300),
)

// Or per viewer:
StoryViewer.show(
  context,
  users: users,
  storyItemTransition: StoryItemTransition.fade,
  userTransition: StoryUserTransition.scale,
);
```

## Story slides

```dart
StoryUser(
  id: '1',
  name: 'Alex',
  avatar: NetworkImage('https://…'),
  stories: [
    StoryItem.imageUrl('https://…/photo.jpg', caption: 'Hello'),
    StoryItem.videoUrl(
      'https://…/clip.mp4',
      duration: const Duration(seconds: 15),
    ),
    StoryItem(
      duration: const Duration(seconds: 3),
      builder: (_) => MyCustomSlide(),
    ),
  ],
)
```

`duration` is optional on every slide; omitted values use `defaultStoryDuration` from theme.

Video slides use [cached_video_player](https://pub.dev/packages/cached_video_player) and pause/resume with the story viewer (hold to pause).

## Quick start

```dart
StoriesPanel(
  users: users,
  onUsersChanged: (u) => setState(() => users = u),
)
```

## Example

```bash
cd example
flutter run
```

Toggle **LTR / RTL** in the app bar. Tray uses a customized theme (72px avatars, purple gradient).

## Platform notes (video)

`cached_video_player` supports caching on Android and iOS. Configure Android/iOS per the [video_player installation guide](https://pub.dev/packages/video_player#installation). Desktop is not supported by the plugin.
