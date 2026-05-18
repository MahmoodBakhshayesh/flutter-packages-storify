import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storify/storify.dart';

void main() {
  group('StoriesTray', () {
    testWidgets('renders user names', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [StoriesThemeData.light]),
          home: const StoriesTray(
            users: [
              StoryUser(
                id: 'a',
                name: 'Alice',
                stories: [],
              ),
              StoryUser(
                id: 'b',
                name: 'Bob',
                stories: [],
              ),
            ],
          ),
        ),
      );

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
    });
  });

  group('StoryProgressBar', () {
    testWidgets('renders segments', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 300,
            child: StoryProgressBar(
              count: 3,
              activeIndex: 1,
              activeProgress: 0.5,
            ),
          ),
        ),
      );

      expect(find.byType(StoryProgressBar), findsOneWidget);
    });
  });

  group('StoryItemTransitionBuilder', () {
    testWidgets('fade builds FadeTransition', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: StoryItemTransitionBuilder.build(
            type: StoryItemTransition.fade,
            child: const Text('slide'),
            animation: const AlwaysStoppedAnimation(1),
            forward: true,
            textDirection: TextDirection.ltr,
          ),
        ),
      );
      expect(find.byType(FadeTransition), findsOneWidget);
    });
  });
}
