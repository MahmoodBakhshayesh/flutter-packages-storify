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

  /// Unique identifier for this user.
  final String id;

  /// Display name under the tray avatar and in the viewer header.
  final String name;

  /// Avatar image for the tray ring and viewer header.
  final ImageProvider? avatar;

  /// Ordered list of story slides for this user.
  final List<StoryItem> stories;

  /// When true, the tray shows a muted ring instead of the gradient.
  final bool seen;

  /// Returns a copy with the given fields replaced.
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
