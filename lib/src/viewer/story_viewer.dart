import 'package:flutter/material.dart';

import '../animations/story_transitions.dart';
import '../controller/story_playback_controller.dart';
import '../models/story_item.dart';
import '../models/story_user.dart';
import '../theme/stories_theme_data.dart';
import 'story_gesture_layer.dart';
import 'story_playback_scope.dart';
import 'story_progress_bar.dart';
import 'story_slide_overlay.dart';

/// Full-screen Instagram-like story viewer.
///
/// Shows segmented progress, header, gestures (tap, hold, swipe down), and
/// optional title/subtitle overlays. Prefer [StoriesPanel] for tray + viewer,
/// or call [StoryViewer.show] to open as a route.
class StoryViewer extends StatefulWidget {
  /// Creates a viewer. Usually opened via [show].
  const StoryViewer({
    super.key,
    required this.users,
    this.initialUserIndex = 0,
    this.onClose,
    this.onUserSeen,
    this.onStoryChanged,
    this.backgroundColor,
    this.progressBar,
    this.headerBuilder,
    this.captionStyle,
    this.titleStyle,
    this.subtitleStyle,
    this.storyItemTransition,
    this.userTransition,
    this.transitionDuration,
    this.transitionCurve,
  });

  /// All users that can be paged horizontally.
  final List<StoryUser> users;

  /// Which user to show first.
  final int initialUserIndex;

  /// Called when the viewer should close. Defaults to popping the route.
  final VoidCallback? onClose;

  /// Called when a user has viewed all of their slides.
  final void Function(int userIndex, StoryUser user)? onUserSeen;

  /// Called when the active slide changes.
  final void Function(int userIndex, int storyIndex)? onStoryChanged;
  final Color? backgroundColor;
  final StoryProgressBar Function(
    BuildContext context,
    int userIndex,
    int storyIndex,
    double progress,
    int storyCount,
  )? progressBar;
  final Widget Function(
    BuildContext context,
    StoryUser user,
    int userIndex,
    VoidCallback onClose,
  )? headerBuilder;
  final TextStyle? captionStyle;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  /// Overrides [StoriesThemeData.storyItemTransition].
  final StoryItemTransition? storyItemTransition;

  /// Overrides [StoriesThemeData.userTransition].
  final StoryUserTransition? userTransition;
  final Duration? transitionDuration;
  final Curve? transitionCurve;

  /// Pushes a full-screen route containing this viewer.
  static Future<void> show(
    BuildContext context, {
    required List<StoryUser> users,
    int initialUserIndex = 0,
    void Function(int userIndex, StoryUser user)? onUserSeen,
    void Function(int userIndex, int storyIndex)? onStoryChanged,
    StoryProgressBar Function(
      BuildContext context,
      int userIndex,
      int storyIndex,
      double progress,
      int storyCount,
    )? progressBar,
    Widget Function(
      BuildContext context,
      StoryUser user,
      int userIndex,
      VoidCallback onClose,
    )? headerBuilder,
    StoryItemTransition? storyItemTransition,
    StoryUserTransition? userTransition,
    Duration? transitionDuration,
    Curve? transitionCurve,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: true,
        barrierColor: Colors.black,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: StoryViewer(
              users: users,
              initialUserIndex: initialUserIndex,
              onClose: () => Navigator.of(context).pop(),
              onUserSeen: onUserSeen,
              onStoryChanged: onStoryChanged,
              progressBar: progressBar,
              headerBuilder: headerBuilder,
              storyItemTransition: storyItemTransition,
              userTransition: userTransition,
              transitionDuration: transitionDuration,
              transitionCurve: transitionCurve,
            ),
          );
        },
      ),
    );
  }

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer> {
  late final PageController _userPageController;
  late int _userIndex;
  StoryPlaybackController? _playback;
  double _dragOffset = 0;
  bool _playbackInitialized = false;
  bool _isClosing = false;
  int? _lastNotifiedStoryIndex;

  @override
  void initState() {
    super.initState();
    _userIndex = widget.initialUserIndex.clamp(0, widget.users.length - 1);
    _userPageController = PageController(initialPage: _userIndex);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_playbackInitialized) {
      _playbackInitialized = true;
      _initPlaybackForCurrentUser();
    }
  }

  StoryUser get _currentUser => widget.users[_userIndex];

  StoriesThemeData get _theme => StoriesTheme.of(context);

  StoryItemTransition get _storyItemTransition =>
      widget.storyItemTransition ?? _theme.storyItemTransition;

  StoryUserTransition get _userTransition =>
      widget.userTransition ?? _theme.userTransition;

  Duration get _transitionDuration =>
      widget.transitionDuration ?? _theme.transitionDuration;

  Curve get _transitionCurve =>
      widget.transitionCurve ?? _theme.transitionCurve;

  void _initPlaybackForCurrentUser() {
    _playback?.dispose();
    final durations = _currentUser.stories
        .map((s) => s.resolveDuration(context))
        .toList();
    _playback = StoryPlaybackController(
      durations: durations,
      onUserCompleted: _onUserStoriesCompleted,
    )..addListener(_onPlaybackTick);
    _playback!.start();
    _lastNotifiedStoryIndex = 0;
    widget.onStoryChanged?.call(_userIndex, 0);
  }

  void _onPlaybackTick() {
    final playback = _playback;
    if (playback == null) return;

    if (_lastNotifiedStoryIndex != playback.index) {
      _lastNotifiedStoryIndex = playback.index;
      widget.onStoryChanged?.call(_userIndex, playback.index);
    }
  }

  void _onUserStoriesCompleted() {
    if (_isClosing) return;
    widget.onUserSeen?.call(_userIndex, _currentUser);
    if (_userIndex < widget.users.length - 1) {
      _goToUser(_userIndex + 1);
    } else {
      _close();
    }
  }

  /// Animates to [index]; playback resets in [onPageChanged] when the page settles.
  void _goToUser(int index) {
    if (_isClosing) return;
    if (index < 0 || index >= widget.users.length) return;
    if (!_userPageController.hasClients) return;
    final page = _userPageController.page?.round() ?? _userIndex;
    if (page == index) {
      _applyUserIndex(index);
      return;
    }
    _userPageController.animateToPage(
      index,
      duration: _transitionDuration,
      curve: _transitionCurve,
    );
  }

  void _applyUserIndex(int index) {
    if (_isClosing) return;
    if (index < 0 || index >= widget.users.length) return;
    if (index == _userIndex && _playback != null) return;
    setState(() => _userIndex = index);
    _initPlaybackForCurrentUser();
  }

  void _close() {
    if (_isClosing) return;
    _isClosing = true;
    _playback?.pause();
    if (widget.onClose != null) {
      widget.onClose!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  void dispose() {
    _playback?.dispose();
    _userPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = StoriesTheme.of(context);
    final bg = widget.backgroundColor ?? theme.viewerBackgroundColor;
    final playback = _playback;

    return Material(
      color: bg.withValues(
        alpha: 1 - (_dragOffset / 400).clamp(0.0, 0.5),
      ),
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.delta.dy > 0) {
            setState(() => _dragOffset += details.delta.dy);
          }
        },
        onVerticalDragEnd: (details) {
          if (_dragOffset > 120) {
            _close();
          } else {
            setState(() => _dragOffset = 0);
          }
        },
        child: Transform.translate(
          offset: Offset(0, _dragOffset),
          child: SafeArea(
            child: Column(
              children: [
                if (playback != null)
                  ListenableBuilder(
                    listenable: playback,
                    builder: (context, _) => _buildProgress(playback),
                  )
                else
                  const SizedBox.shrink(),
                _buildHeader(),
                Expanded(
                  child: playback == null
                      ? const SizedBox.shrink()
                      : _buildBody(playback),
                ),
                if (playback != null)
                  ListenableBuilder(
                    listenable: playback,
                    builder: (context, _) => _buildCaption(playback),
                  )
                else
                  const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgress(StoryPlaybackController playback) {
    if (_currentUser.stories.isEmpty) {
      return const SizedBox.shrink();
    }

    if (widget.progressBar != null) {
      return widget.progressBar!(
        context,
        _userIndex,
        playback.index,
        playback.progress,
        _currentUser.stories.length,
      );
    }

    return StoryProgressBar(
      count: _currentUser.stories.length,
      activeIndex: playback.index,
      activeProgress: playback.progress,
    );
  }

  Widget _buildHeader() {
    if (widget.headerBuilder != null) {
      return widget.headerBuilder!(context, _currentUser, _userIndex, _close);
    }

    final theme = StoriesTheme.of(context);

    return Padding(
      padding: theme.headerPadding,
      child: Row(
        children: [
          if (_currentUser.avatar != null)
            CircleAvatar(
              radius: theme.headerAvatarRadius,
              backgroundImage: _currentUser.avatar,
            )
          else
            CircleAvatar(
              radius: theme.headerAvatarRadius,
              child: Icon(Icons.person, size: theme.headerAvatarRadius),
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _currentUser.name,
              style: theme.headerNameStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(theme.closeIcon, color: theme.closeIconColor),
            onPressed: _close,
          ),
        ],
      ),
    );
  }

  Widget _buildBody(StoryPlaybackController playback) {
    final userTransition = _userTransition;

    return LayoutBuilder(
      builder: (context, constraints) {
        final pageSize = Size(constraints.maxWidth, constraints.maxHeight);

        return PageView.builder(
          controller: _userPageController,
          itemCount: widget.users.length,
          onPageChanged: _applyUserIndex,
          itemBuilder: (context, userIndex) {
            final page = _UserStoryPage(
              user: widget.users[userIndex],
              isActive: userIndex == _userIndex,
              playback: playback,
              storyItemTransition: _storyItemTransition,
              transitionDuration: _transitionDuration,
              transitionCurve: _transitionCurve,
              titleStyle: widget.titleStyle,
              subtitleStyle: widget.subtitleStyle,
              onNext: () {
                if (!playback.next()) {
                  _onUserStoriesCompleted();
                }
              },
              onPrevious: () {
                if (!playback.previous()) {
                  if (_userIndex > 0) {
                    _goToUser(_userIndex - 1);
                  }
                }
              },
            );

            if (userTransition == StoryUserTransition.page) {
              return page;
            }

            return AnimatedBuilder(
              animation: _userPageController,
              builder: (context, child) {
                final scrollPage = _userPageController.hasClients
                    ? (_userPageController.page ?? _userIndex.toDouble())
                    : _userIndex.toDouble();
                final offset = userIndex - scrollPage;
                return StoryUserTransitionBuilder.wrap(
                  type: userTransition,
                  offset: offset,
                  pageSize: pageSize,
                  child: child!,
                );
              },
              child: page,
            );
          },
        );
      },
    );
  }

  Widget _buildCaption(StoryPlaybackController playback) {
    if (_currentUser.stories.isEmpty) {
      return const SizedBox(height: 24);
    }

    final index = playback.index.clamp(0, _currentUser.stories.length - 1);
    final caption = _currentUser.stories[index].caption;
    if (caption == null || caption.isEmpty) {
      return const SizedBox(height: 24);
    }

    final theme = StoriesTheme.of(context);

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 16),
      child: Text(
        caption,
        style: widget.captionStyle ?? theme.captionStyle,
        textAlign: TextAlign.start,
      ),
    );
  }
}

class _UserStoryPage extends StatefulWidget {
  const _UserStoryPage({
    required this.user,
    required this.isActive,
    required this.playback,
    required this.onNext,
    required this.onPrevious,
    required this.storyItemTransition,
    required this.transitionDuration,
    required this.transitionCurve,
    this.titleStyle,
    this.subtitleStyle,
  });

  final StoryUser user;
  final bool isActive;
  final StoryPlaybackController playback;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final StoryItemTransition storyItemTransition;
  final Duration transitionDuration;
  final Curve transitionCurve;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  @override
  State<_UserStoryPage> createState() => _UserStoryPageState();
}

class _UserStoryPageState extends State<_UserStoryPage> {
  int _lastIndex = 0;
  bool _forward = true;

  @override
  void initState() {
    super.initState();
    _lastIndex = widget.playback.index;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user.stories.isEmpty) {
      return const Center(
        child: Text('No stories', style: TextStyle(color: Colors.white70)),
      );
    }

    if (!widget.isActive) {
      return _StorySlideContent(
        item: widget.user.stories.first,
        titleStyle: widget.titleStyle,
        subtitleStyle: widget.subtitleStyle,
      );
    }

    final transition = widget.storyItemTransition;
    final duration = transition == StoryItemTransition.none
        ? Duration.zero
        : widget.transitionDuration;
    final textDirection = Directionality.of(context);

    return StoryPlaybackScope(
      playback: widget.playback,
      child: StoryGestureLayer(
        onNext: widget.onNext,
        onPrevious: widget.onPrevious,
        onPause: widget.playback.pause,
        onResume: widget.playback.resume,
        child: ListenableBuilder(
          listenable: widget.playback,
          builder: (context, _) {
            final index =
                widget.playback.index.clamp(0, widget.user.stories.length - 1);
            if (index != _lastIndex) {
              _forward = index > _lastIndex;
              _lastIndex = index;
            }

            final slide = _StorySlideContent(
              key: ValueKey('${widget.user.id}_$index'),
              item: widget.user.stories[index],
              titleStyle: widget.titleStyle,
              subtitleStyle: widget.subtitleStyle,
            );

            if (transition == StoryItemTransition.none) {
              return slide;
            }

            return AnimatedSwitcher(
              duration: duration,
              switchInCurve: widget.transitionCurve,
              switchOutCurve: widget.transitionCurve,
              layoutBuilder: (currentChild, previousChildren) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ...previousChildren,
                    if (currentChild != null) currentChild,
                  ],
                );
              },
              transitionBuilder: (child, animation) {
                return StoryItemTransitionBuilder.build(
                  type: transition,
                  child: child,
                  animation: animation,
                  forward: _forward,
                  textDirection: textDirection,
                );
              },
              child: slide,
            );
          },
        ),
      ),
    );
  }
}

class _StorySlideContent extends StatelessWidget {
  const _StorySlideContent({
    super.key,
    required this.item,
    this.titleStyle,
    this.subtitleStyle,
  });

  final StoryItem item;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        item.builder(context),
        StorySlideOverlay(
          item: item,
          titleStyle: titleStyle,
          subtitleStyle: subtitleStyle,
        ),
      ],
    );
  }
}
