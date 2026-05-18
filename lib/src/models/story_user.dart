import 'package:flutter/material.dart';

import 'story_item.dart';

/// A user (or channel) shown in the tray with one or more story slides.
class StoryUser {
  const StoryUser({
    required this.id,
    required this.name,
    required this.stories,
    this.avatar,
    this.seen = false,
  });

  final String id;
  final String name;
  final ImageProvider? avatar;
  final List<StoryItem> stories;

  /// When true, the tray shows a muted ring instead of the gradient.
  final bool seen;

  StoryUser copyWith({
    String? id,
    String? name,
    ImageProvider? avatar,
    List<StoryItem>? stories,
    bool? seen,
  }) {
    return StoryUser(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      stories: stories ?? this.stories,
      seen: seen ?? this.seen,
    );
  }
}
