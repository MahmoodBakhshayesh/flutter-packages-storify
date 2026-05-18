import 'dart:async';

import 'package:flutter/foundation.dart';

/// Drives timed progression through story slides.
class StoryPlaybackController extends ChangeNotifier {
  StoryPlaybackController({
    required this.durations,
    this.onCompleted,
    this.onUserCompleted,
  });

  final List<Duration> durations;
  final VoidCallback? onCompleted;
  final VoidCallback? onUserCompleted;

  int _index = 0;
  bool _paused = false;
  bool _disposed = false;
  Timer? _timer;
  Timer? _tickTimer;
  DateTime? _segmentStartedAt;
  Duration _elapsedBeforePause = Duration.zero;

  int get index => _index;
  bool get paused => _paused;
  bool get isLast => _index >= durations.length - 1;

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
    return _elapsedBeforePause +
        DateTime.now().difference(_segmentStartedAt!);
  }

  void start({int index = 0}) {
    _index = index.clamp(0, durations.isEmpty ? 0 : durations.length - 1);
    _elapsedBeforePause = Duration.zero;
    _segmentStartedAt = DateTime.now();
    _scheduleTick();
    _startProgressTicker();
    _notify();
  }

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

  void resume() {
    if (!_paused) return;
    _paused = false;
    _segmentStartedAt = DateTime.now();
    _scheduleTick();
    _startProgressTicker();
    _notify();
  }

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

  void jumpTo(int index) {
    if (durations.isEmpty) return;
    _goTo(index.clamp(0, durations.length - 1));
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
