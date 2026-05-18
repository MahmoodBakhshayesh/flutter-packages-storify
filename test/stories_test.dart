import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storify/storify.dart';

void main() {
  group('StoryPlaybackController', () {
    test('advances through slides', () {
      final controller = StoryPlaybackController(
        durations: const [
          Duration(milliseconds: 50),
          Duration(milliseconds: 50),
        ],
      );
      controller.start();
      expect(controller.index, 0);

      controller.next();
      expect(controller.index, 1);
      controller.dispose();
    });
  });

  group('StoriesThemeData', () {
    test('copyWith overrides tray size', () {
      final theme = StoriesThemeData.light.copyWith(trayAvatarSize: 80);
      expect(theme.trayAvatarSize, 80);
      expect(theme.trayHeight, StoriesThemeData.light.trayHeight);
    });

    testWidgets('resolve uses inherited theme', (tester) async {
      final custom = StoriesThemeData.light.copyWith(
        trayHeight: 120,
        defaultStoryDuration: const Duration(seconds: 7),
      );

      late StoriesThemeData resolved;
      await tester.pumpWidget(
        StoriesTheme(
          data: custom,
          child: Builder(
            builder: (context) {
              resolved = StoriesTheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(resolved.defaultStoryDuration, const Duration(seconds: 7));
      expect(resolved.trayHeight, 120);
    });
  });

  testWidgets('StoriesTray uses theme avatar size', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: [
            StoriesThemeData.light.copyWith(trayAvatarSize: 50),
          ],
        ),
        home: const StoriesTray(
          users: [
            StoryUser(id: 'a', name: 'Ali', stories: []),
          ],
        ),
      ),
    );

    expect(find.byType(StoryAvatar), findsOneWidget);
  });

  testWidgets('onUserSeen fires when user stories complete', (tester) async {
    final seenUserIds = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [StoriesThemeData.light]),
        home: StoryViewer(
          users: [
            StoryUser(
              id: 'user-a',
              name: 'Test',
              stories: [
                StoryItem(
                  id: 'only-story',
                  duration: const Duration(milliseconds: 80),
                  builder: (_) => const ColoredBox(color: Colors.red),
                ),
              ],
            ),
          ],
          onUserSeen: seenUserIds.add,
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    await tester.pump();

    expect(seenUserIds, ['user-a']);
  });

  testWidgets('onSeenStory fires when slide timer advances', (tester) async {
    final seenIds = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [StoriesThemeData.light]),
        home: StoryViewer(
          users: [
            StoryUser(
              id: 'u1',
              name: 'Test',
              stories: [
                StoryItem(
                  id: 'story-a',
                  duration: const Duration(milliseconds: 80),
                  builder: (_) => const ColoredBox(color: Colors.red),
                ),
                StoryItem(
                  id: 'story-b',
                  duration: const Duration(seconds: 5),
                  builder: (_) => const ColoredBox(color: Colors.blue),
                ),
              ],
            ),
          ],
          onSeenStory: seenIds.add,
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    await tester.pump();

    expect(seenIds, contains('story-a'));
  });

  testWidgets('StoryItem resolves default duration from theme', (tester) async {
    const item = StoryItem(
      id: 'test',
      builder: _placeholder,
    );

    late Duration resolved;
    await tester.pumpWidget(
      StoriesTheme(
        data: StoriesThemeData.light.copyWith(
          defaultStoryDuration: Duration(seconds: 9),
        ),
        child: Builder(
          builder: (context) {
            resolved = item.resolveDuration(context);
            return const SizedBox();
          },
        ),
      ),
    );

    expect(resolved, const Duration(seconds: 9));
  });
}

Widget _placeholder(BuildContext context) => const SizedBox();
