import 'package:flutter_test/flutter_test.dart';
import 'package:stories/src/controller/story_playback_controller.dart';

void main() {
  group('StoryPlaybackController pause', () {
    test('preserves elapsed progress when paused', () async {
      final controller = StoryPlaybackController(
        durations: const [Duration(seconds: 10)],
      );
      controller.start();
      await Future<void>.delayed(const Duration(milliseconds: 200));

      final beforePause = controller.progress;
      expect(beforePause, greaterThan(0.01));

      controller.pause();
      final atPause = controller.progress;

      expect(atPause, closeTo(beforePause, 0.02));

      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(controller.progress, closeTo(atPause, 0.001));

      controller.dispose();
    });

    test('resumes from paused position', () async {
      final controller = StoryPlaybackController(
        durations: const [Duration(seconds: 10)],
      );
      controller.start();
      await Future<void>.delayed(const Duration(milliseconds: 150));
      controller.pause();
      final atPause = controller.progress;

      controller.resume();
      expect(controller.progress, greaterThanOrEqualTo(atPause - 0.01));

      controller.dispose();
    });
  });
}
