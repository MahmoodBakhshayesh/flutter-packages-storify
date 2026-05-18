import 'dart:async';

import 'package:flutter/foundation.dart';

/// Drives timed progression through story slides for one [StoryUser].
///
/// Notifies listeners on progress ticks and index changes. Used internally
/// by [StoryViewer]; expose via [StoryPlaybackScope] for video slides.
class StoryPlaybackController extends ChangeNotifier {
  /// Creates a controller for the given slide [durations].
  StoryPlaybackController({
    required this.durations,
    this.onCompleted,
    this.onUserCompleted,
  });

  /// Per-slide durations in order.
  final List<Duration> durations;

  /// Called when the last slide timer completes (optional).
  final VoidCallback? onCompleted;

  /// Called when the last slide ends (timer or manual advance).
  final VoidCallback? onUserCompleted;

  int _index = 0;
  bool _paused = false;
  bool _disposed = false;
  Timer? _timer;
  Timer? _tickTimer;
  DateTime? _segmentStartedAt;
  Duration _elapsedBeforePause = Duration.zero;

  /// Index of the currently visible slide.
  int get index => _index;

  /// Whether playback is paused (e.g. user is holding).
  bool get paused => _paused;

  /// True if on the last slide.
  bool get isLast => _index >= durations.length - 1;

  /// Progress of the current slide from `0.0` to `1.0`.
  double get progress {
    if (durations.isEmpty) return 0;
    final total = durations[_index].inMilliseconds;
    if (total == 0) return 1;
    final elapsed = _currentElapsed().inMilliseconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  Duration _currentElapsed() {
    if (_segmentStartedAt == null) return _elapsedBeforePause;
    if (_paused) return _elapsedBeforePause;
    return _elapsedBeforePause + DateTime.now().difference(_segmentStartedAt!);
  }

  /// Starts (or restarts) playback from [index].
  void start({int index = 0}) {
    _index = index.clamp(0, durations.isEmpty ? 0 : durations.length - 1);
    _elapsedBeforePause = Duration.zero;
    _segmentStartedAt = DateTime.now();
    _scheduleTick();
    _startProgressTicker();
    _notify();
  }

  /// Pauses the current slide and freezes [progress].
  void pause() {
    if (_paused) return;
    // Capture elapsed time before flipping [_paused], otherwise
    // [_currentElapsed] returns stale [_elapsedBeforePause] only.
    final elapsed = _currentElapsed();
    _paused = true;
    _elapsedBeforePause = elapsed;
    _timer?.cancel();
    _tickTimer?.cancel();
    _notify();
  }

  /// Resumes from the paused position.
  void resume() {
    if (!_paused) return;
    _paused = false;
    _segmentStartedAt = DateTime.now();
    _scheduleTick();
    _startProgressTicker();
    _notify();
  }

  /// Toggles between [pause] and [resume].
  void togglePause() {
    if (_paused) {
      resume();
    } else {
      pause();
    }
  }

  /// Advances to the next slide. Returns false on the last slide (caller
  /// should switch user or close — do not call [onUserCompleted] here).
  bool next() {
    if (_paused) return false;
    if (durations.isEmpty) return false;
    if (_index < durations.length - 1) {
      _goTo(_index + 1);
      return true;
    }
    return false;
  }

  /// Goes to the previous slide. Returns false if already on the first.
  bool previous() {
    if (durations.isEmpty) return false;
    if (_index > 0) {
      _goTo(_index - 1);
      return true;
    }
    return false;
  }

  /// Jumps to [index] and resets that slide's elapsed time.
  void jumpTo(int index) {
    if (durations.isEmpty) return;
    _goTo(index.clamp(0, durations.length - 1));
  }

  /// Updates the duration for [index] (e.g. after a video loads its length).
  ///
  /// When [index] is the active slide, the current segment timer is reset.
  void updateDurationAt(int index, Duration newDuration) {
    if (index < 0 || index >= durations.length) return;
    if (newDuration <= Duration.zero) return;
    if (durations[index] == newDuration) return;

    durations[index] = newDuration;
    if (_index == index && !_paused) {
      _elapsedBeforePause = Duration.zero;
      _segmentStartedAt = DateTime.now();
      _scheduleTick();
    }
    _notify();
  }

  void _goTo(int index) {
    _index = index;
    _elapsedBeforePause = Duration.zero;
    _segmentStartedAt = DateTime.now();
    _paused = false;
    _scheduleTick();
    _startProgressTicker();
    _notify();
  }

  void _startProgressTicker() {
    _tickTimer?.cancel();
    if (_disposed || _paused || durations.isEmpty) return;
    _tickTimer = Timer.periodic(const Duration(milliseconds: 32), (_) {
      _notify();
    });
  }

  void _scheduleTick() {
    _timer?.cancel();
    if (_disposed || _paused || durations.isEmpty) return;

    final remaining = durations[_index] - _currentElapsed();
    final ms = remaining.inMilliseconds.clamp(1, 1 << 31);
    _timer = Timer(Duration(milliseconds: ms), _onSegmentEnd);
  }

  void _onSegmentEnd() {
    if (_disposed || _paused) return;
    if (!next()) {
      onUserCompleted?.call();
      onCompleted?.call();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _tickTimer?.cancel();
    super.dispose();
  }
}
