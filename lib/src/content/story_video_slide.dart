import 'dart:io';

import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/material.dart';

import '../theme/stories_theme_data.dart';
import '../viewer/story_playback_scope.dart';

/// Cached network/file/asset video slide; pauses when the story viewer pauses.
class StoryVideoSlide extends StatefulWidget {
  const StoryVideoSlide.network(
    this.url, {
    super.key,
    this.httpHeaders = const {},
    this.formatHint,
    this.fit,
    this.looping,
    this.loadingBuilder,
  })  : assetPath = null,
        file = null,
        package = null;

  const StoryVideoSlide.file(
    this.file, {
    super.key,
    this.fit,
    this.looping,
    this.loadingBuilder,
  })  : url = null,
        assetPath = null,
        httpHeaders = const {},
        formatHint = null,
        package = null;

  const StoryVideoSlide.asset(
    this.assetPath, {
    super.key,
    this.package,
    this.fit,
    this.looping,
    this.loadingBuilder,
  })  : url = null,
        file = null,
        httpHeaders = const {},
        formatHint = null;

  final String? url;
  final File? file;
  final String? assetPath;
  final String? package;
  final Map<String, String> httpHeaders;
  final VideoFormat? formatHint;
  final BoxFit? fit;
  final bool? looping;
  final WidgetBuilder? loadingBuilder;

  @override
  State<StoryVideoSlide> createState() => _StoryVideoSlideState();
}

class _StoryVideoSlideState extends State<StoryVideoSlide> {
  late CachedVideoPlayerController _controller;
  StoryPlaybackScope? _playbackScope;

  @override
  void initState() {
    super.initState();
    _controller = _createController();
    _init();
  }

  CachedVideoPlayerController _createController() {
    if (widget.url != null) {
      return CachedVideoPlayerController.network(
        widget.url!,
        httpHeaders: widget.httpHeaders,
        formatHint: widget.formatHint,
      );
    }
    if (widget.file != null) {
      return CachedVideoPlayerController.file(widget.file!);
    }
    return CachedVideoPlayerController.asset(
      widget.assetPath!,
      package: widget.package,
    );
  }

  Future<void> _init() async {
    await _controller.initialize();
    if (!mounted) return;
    final theme = StoriesTheme.of(context);
    await _controller.setLooping(widget.looping ?? theme.videoLooping);
    _syncWithPlayback();
    await _controller.play();
    setState(() {});
  }

  void _onPlaybackChanged() {
    _syncWithPlayback();
  }

  void _syncWithPlayback() {
    if (!_controller.value.isInitialized) return;
    final paused = _playbackScope?.playback.paused ?? false;
    if (paused && _controller.value.isPlaying) {
      _controller.pause();
    } else if (!paused && !_controller.value.isPlaying) {
      _controller.play();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = context.getInheritedWidgetOfExactType<StoryPlaybackScope>();
    if (scope != _playbackScope) {
      _playbackScope?.playback.removeListener(_onPlaybackChanged);
      _playbackScope = scope;
      _playbackScope?.playback.addListener(_onPlaybackChanged);
      _syncWithPlayback();
    }
  }

  @override
  void dispose() {
    _playbackScope?.playback.removeListener(_onPlaybackChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = StoriesTheme.of(context);
    final fit = widget.fit ?? theme.videoFit;

    if (!_controller.value.isInitialized) {
      final builder = widget.loadingBuilder ?? theme.videoLoadingBuilder;
      if (builder != null) return builder(context);
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return FittedBox(
      fit: fit,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: _controller.value.size.width,
        height: _controller.value.size.height,
        child: CachedVideoPlayer(_controller),
      ),
    );
  }
}
