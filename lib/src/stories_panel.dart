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

  final List<StoryUser> users;
  final ValueChanged<List<StoryUser>>? onUsersChanged;
  final bool showAddButton;
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
  final StoryItemTransition? storyItemTransition;
  final StoryUserTransition? userTransition;
  final Duration? transitionDuration;
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

  void _markSeen(int userIndex, StoryUser user) {
    setState(() {
      _users[userIndex] = _users[userIndex].copyWith(seen: true);
    });
    widget.onUsersChanged?.call(_users);
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
          onUserSeen: _markSeen,
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
