import 'package:flutter/material.dart';

/// Instagram-style tap zones and hold-to-pause, RTL-aware via [AlignmentDirectional].
class StoryGestureLayer extends StatefulWidget {
  const StoryGestureLayer({
    super.key,
    required this.onNext,
    required this.onPrevious,
    required this.onPause,
    required this.onResume,
    this.child,
  });

  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final Widget? child;

  @override
  State<StoryGestureLayer> createState() => _StoryGestureLayerState();
}

class _StoryGestureLayerState extends State<StoryGestureLayer> {
  bool _holding = false;
  bool _suppressTap = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (widget.child != null) widget.child!,
        Row(
          children: [
            Expanded(
              child: _TapZone(
                onTap: _handlePrevious,
                onLongPressStart: _onHoldStart,
                onLongPressEnd: _onHoldEnd,
              ),
            ),
            Expanded(
              child: _TapZone(
                onTap: () {},
                onLongPressStart: _onHoldStart,
                onLongPressEnd: _onHoldEnd,
              ),
            ),
            Expanded(
              child: _TapZone(
                onTap: _handleNext,
                onLongPressStart: _onHoldStart,
                onLongPressEnd: _onHoldEnd,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handlePrevious() {
    if (_suppressTap || _holding) return;
    widget.onPrevious();
  }

  void _handleNext() {
    if (_suppressTap || _holding) return;
    widget.onNext();
  }

  void _onHoldStart() {
    if (_holding) return;
    _holding = true;
    _suppressTap = false;
    widget.onPause();
  }

  void _onHoldEnd() {
    if (!_holding) return;
    _holding = false;
    _suppressTap = true;
    widget.onResume();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _suppressTap = false);
      }
    });
  }
}

class _TapZone extends StatelessWidget {
  const _TapZone({
    required this.onTap,
    required this.onLongPressStart,
    required this.onLongPressEnd,
  });

  final VoidCallback onTap;
  final VoidCallback onLongPressStart;
  final VoidCallback onLongPressEnd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      onLongPressStart: (_) => onLongPressStart(),
      onLongPressEnd: (_) => onLongPressEnd(),
      onLongPressCancel: onLongPressEnd,
    );
  }
}
