import 'package:flutter/material.dart';

import 'animations/story_transitions.dart';
import 'models/story_user.dart';
import 'tray/stories_tray.dart';
import 'viewer/story_progress_bar.dart';
import 'viewer/story_viewer.dart';

/// Tray + viewer wiring: tap a thumbnail to open the full story flow.
class StoriesPanel extends StatefulWidget {
  const StoriesPanel({
    super.key,
    required this.users,
    this.onUsersChanged,
    this.onUserSeen,
    this.onSeenStory,
    this.showAddButton = false,
    this.onAddStoryTap,
    this.trayHeight,
    this.trayPadding,
    this.progressBar,
    this.headerBuilder,
    this.storyItemTransition,
    this.userTransition,
    this.transitionDuration,
    this.transitionCurve,
  });

  /// Users displayed in the tray.
  final List<StoryUser> users;

  /// Called when the internal user list updates (e.g. tray seen ring).
  final ValueChanged<List<StoryUser>>? onUsersChanged;

  /// Called with a [StoryUser.id] when that user has viewed all of their slides.
  ///
  /// Use this to persist per-user seen state (the package does not keep a list).
  final ValueChanged<String>? onUserSeen;

  /// Called with a [StoryItem.id] when that slide is considered seen.
  ///
  /// Use this to persist per-story seen state (the package does not keep a list).
  final ValueChanged<String>? onSeenStory;

  /// Shows a "Your story" tile at the start of the tray.
  final bool showAddButton;

  /// Invoked when the add-story tile is tapped.
  final VoidCallback? onAddStoryTap;

  /// Overrides [StoriesThemeData.trayHeight].
  final double? trayHeight;
  final EdgeInsetsGeometry? trayPadding;
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

  /// Overrides [StoriesThemeData.storyItemTransition].
  final StoryItemTransition? storyItemTransition;

  /// Overrides [StoriesThemeData.userTransition].
  final StoryUserTransition? userTransition;

  /// Overrides [StoriesThemeData.transitionDuration].
  final Duration? transitionDuration;

  /// Overrides [StoriesThemeData.transitionCurve].
  final Curve? transitionCurve;

  @override
  State<StoriesPanel> createState() => _StoriesPanelState();
}

class _StoriesPanelState extends State<StoriesPanel> {
  late List<StoryUser> _users;

  @override
  void initState() {
    super.initState();
    _users = List<StoryUser>.from(widget.users);
  }

  @override
  void didUpdateWidget(StoriesPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.users != oldWidget.users) {
      _users = List<StoryUser>.from(widget.users);
    }
  }

  void _handleUserSeen(String userId) {
    final index = _users.indexWhere((u) => u.id == userId);
    if (index >= 0 && !_users[index].seen) {
      setState(() {
        _users[index] = _users[index].copyWith(seen: true);
      });
      widget.onUsersChanged?.call(_users);
    }
    widget.onUserSeen?.call(userId);
  }

  @override
  Widget build(BuildContext context) {
    return StoriesTray(
      users: _users,
      height: widget.trayHeight,
      padding: widget.trayPadding,
      showAddButton: widget.showAddButton,
      onAddStoryTap: widget.onAddStoryTap,
      onUserTap: (index, user) {
        StoryViewer.show(
          context,
          users: _users,
          initialUserIndex: index,
          onUserSeen: _handleUserSeen,
          onSeenStory: widget.onSeenStory,
          progressBar: widget.progressBar,
          headerBuilder: widget.headerBuilder,
          storyItemTransition: widget.storyItemTransition,
          userTransition: widget.userTransition,
          transitionDuration: widget.transitionDuration,
          transitionCurve: widget.transitionCurve,
        );
      },
    );
  }
}
