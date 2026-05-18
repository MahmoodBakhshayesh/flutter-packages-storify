import 'package:flutter/material.dart';

import '../theme/stories_theme_data.dart';

/// Circular avatar with Instagram-style gradient ring for unseen stories.
class StoryAvatar extends StatelessWidget {
  const StoryAvatar({
    super.key,
    required this.seen,
    this.image,
    this.size,
    this.ringWidth,
    this.unseenGradient,
    this.seenRingColor,
    this.ringGap,
    this.placeholder,
    this.backgroundColor,
  });

  final bool seen;
  final ImageProvider? image;
  final double? size;
  final double? ringWidth;
  final Gradient? unseenGradient;
  final Color? seenRingColor;
  final double? ringGap;
  final Widget? placeholder;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = StoriesTheme.of(context);
    final avatarSize = size ?? theme.trayAvatarSize;
    final borderWidth = ringWidth ?? theme.ringWidth;
    final gap = ringGap ?? theme.ringGap;
    final inner = avatarSize - borderWidth * 2 - gap * 2;
    final ringColor = seenRingColor ?? theme.seenRingColor;

    return SizedBox(
      width: avatarSize,
      height: avatarSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: seen
              ? null
              : (unseenGradient ?? theme.unseenRingGradient),
          color: seen ? ringColor : null,
        ),
        child: Padding(
          padding: EdgeInsets.all(borderWidth),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Padding(
              padding: EdgeInsets.all(gap),
              child: ClipOval(
                child: SizedBox(
                  width: inner,
                  height: inner,
                  child: image != null
                      ? Image(image: image!, fit: BoxFit.cover)
                      : placeholder ??
                          theme.avatarPlaceholder ??
                          ColoredBox(
                            color: backgroundColor ?? theme.avatarBackgroundColor,
                            child: Icon(
                              Icons.person,
                              size: inner * 0.5,
                              color: Colors.grey.shade600,
                            ),
                          ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
