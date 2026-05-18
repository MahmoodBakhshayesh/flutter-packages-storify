import 'dart:io';

import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../theme/stories_theme_data.dart';
import '../viewer/story_playback_scope.dart';

/// Cached network/file/asset video slide; pauses when the story viewer pauses.
///
/// Uses [cached_video_player_plus] for network caching.
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
  CachedVideoPlayerPlus? _player;
  StoryPlaybackScope? _playbackScope;

  @override
  void initState() {
    super.initState();
    _init();
  }

  CachedVideoPlayerPlus _createPlayer() {
    if (widget.url != null) {
      return CachedVideoPlayerPlus.networkUrl(
        Uri.parse(widget.url!),
        httpHeaders: widget.httpHeaders,
        formatHint: widget.formatHint,
      );
    }
    if (widget.file != null) {
      return CachedVideoPlayerPlus.file(widget.file!);
    }
    return CachedVideoPlayerPlus.asset(
      widget.assetPath!,
      package: widget.package,
    );
  }

  Future<void> _init() async {
    final player = _createPlayer();
    await player.initialize();
    if (!mounted) return;

    final theme = StoriesTheme.of(context);
    await player.controller.setLooping(widget.looping ?? theme.videoLooping);
    _player = player;
    _syncWithPlayback();
    await player.controller.play();
    setState(() {});
  }

  void _onPlaybackChanged() {
    _syncWithPlayback();
  }

  void _syncWithPlayback() {
    final player = _player;
    if (player == null || !player.isInitialized) return;

    final controller = player.controller;
    final paused = _playbackScope?.playback.paused ?? false;
    if (paused && controller.value.isPlaying) {
      controller.pause();
    } else if (!paused && !controller.value.isPlaying) {
      controller.play();
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
    _player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = StoriesTheme.of(context);
    final fit = widget.fit ?? theme.videoFit;
    final player = _player;

    if (player == null || !player.isInitialized) {
      final builder = widget.loadingBuilder ?? theme.videoLoadingBuilder;
      if (builder != null) return builder(context);
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    final controller = player.controller;
    final size = controller.value.size;

    return FittedBox(
      fit: fit,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: VideoPlayer(controller),
      ),
    );
  }
}
