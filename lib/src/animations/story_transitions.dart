import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Animation when advancing between slides of the same user.
enum StoryItemTransition {
  /// Instant swap (default).
  none,

  /// Cross-fade.
  fade,

  /// Horizontal slide in navigation direction (RTL-aware).
  slide,

  /// Vertical slide.
  slideVertical,

  /// Scale in / out.
  scale,

  /// Zoom fade.
  zoom,
}

/// Animation when swiping between users in the viewer.
enum StoryUserTransition {
  /// Standard horizontal [PageView] scroll (default).
  page,

  /// Cross-fade while paging.
  fade,

  /// Scale down when leaving, up when entering.
  scale,

  /// 3D cube rotation while paging.
  cube,

  /// Vertical parallax while paging horizontally.
  slideVertical,
}

/// Builds [AnimatedSwitcher] transitions for story slides.
class StoryItemTransitionBuilder {
  const StoryItemTransitionBuilder._();

  static Widget build({
    required StoryItemTransition type,
    required Widget child,
    required Animation<double> animation,
    required bool forward,
    required TextDirection textDirection,
  }) {
    switch (type) {
      case StoryItemTransition.none:
        return child;
      case StoryItemTransition.fade:
        return FadeTransition(opacity: animation, child: child);
      case StoryItemTransition.slide:
        return _slide(
          child: child,
          animation: animation,
          forward: forward,
          textDirection: textDirection,
          vertical: false,
        );
      case StoryItemTransition.slideVertical:
        return _slide(
          child: child,
          animation: animation,
          forward: forward,
          textDirection: textDirection,
          vertical: true,
        );
      case StoryItemTransition.scale:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        );
      case StoryItemTransition.zoom:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.85, end: 1).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.5, end: 1).animate(animation),
            child: child,
          ),
        );
    }
  }

  static Widget _slide({
    required Widget child,
    required Animation<double> animation,
    required bool forward,
    required TextDirection textDirection,
    required bool vertical,
  }) {
    final rtl = textDirection == TextDirection.rtl;
    late Offset begin;
    if (vertical) {
      begin = forward ? const Offset(0, 1) : const Offset(0, -1);
    } else {
      final sign = forward ? 1.0 : -1.0;
      final dx = rtl ? -sign : sign;
      begin = Offset(dx, 0);
    }

    return SlideTransition(
      position: Tween<Offset>(begin: begin, end: Offset.zero).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      ),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.6, end: 1).animate(animation),
        child: child,
      ),
    );
  }
}

/// Applies parallax / effects on [PageView] children from page [offset].
class StoryUserTransitionBuilder {
  const StoryUserTransitionBuilder._();

  /// Page index minus current scroll position (e.g. -0.5 when halfway to next).
  static Widget wrap({
    required StoryUserTransition type,
    required double offset,
    required Widget child,
    required Size pageSize,
  }) {
    if (type == StoryUserTransition.page) return child;

    final t = offset.abs().clamp(0.0, 1.0);

    switch (type) {
      case StoryUserTransition.page:
        return child;
      case StoryUserTransition.fade:
        return Opacity(
          opacity: (1 - t * 0.85).clamp(0.15, 1.0),
          child: child,
        );
      case StoryUserTransition.scale:
        final scale = 1 - (t * 0.12);
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: (1 - t * 0.4).clamp(0.4, 1.0),
            child: child,
          ),
        );
      case StoryUserTransition.cube:
        final angle = offset * math.pi / 2;
        return Transform(
          alignment: offset > 0
              ? Alignment.centerRight
              : Alignment.centerLeft,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: Opacity(
            opacity: (1 - t * 0.3).clamp(0.5, 1.0),
            child: child,
          ),
        );
      case StoryUserTransition.slideVertical:
        return Transform.translate(
          offset: Offset(0, offset * pageSize.height * 0.25),
          child: Opacity(
            opacity: (1 - t * 0.5).clamp(0.5, 1.0),
            child: child,
          ),
        );
    }
  }
}
