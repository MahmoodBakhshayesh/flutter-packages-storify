# storify_example

Example app for the [storify](https://pub.dev/packages/storify) package.

## Run

```bash
flutter pub get
flutter run
```

## What it demonstrates

- `StoriesPanel` with add-story tile
- Custom `StoriesThemeData` (avatar size, gradient ring, duration)
- **Story slide** transition picker (`StoryItemTransition`)
- **User** transition picker (`StoryUserTransition`)
- **LTR / RTL** toggle
- Title, subtitle, and caption on slides

## Try

1. Pick slide transition (e.g. **Slide**) and user transition (e.g. **Cube**).
2. Tap a story ring to open the viewer.
3. Hold to pause — progress should freeze.
4. Tap sides to go next/previous; swipe horizontally between users.
5. Swipe down to close.
