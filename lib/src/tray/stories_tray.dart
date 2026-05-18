import 'package:flutter/material.dart';

import '../models/story_user.dart';
import '../theme/stories_theme_data.dart';
import 'story_avatar.dart';

/// Horizontal scrollable strip of story thumbnails (Instagram home row).
class StoriesTray extends StatelessWidget {
  const StoriesTray({
    super.key,
    required this.users,
    this.onUserTap,
    this.onAddStoryTap,
    this.height,
    this.avatarSize,
    this.padding,
    this.itemSpacing,
    this.labelStyle,
    this.labelSpacing,
    this.showAddButton = false,
    this.addButtonLabel,
    this.addButtonBuilder,
  });

  final List<StoryUser> users;
  final void Function(int index, StoryUser user)? onUserTap;
  final VoidCallback? onAddStoryTap;

  /// Overrides [StoriesThemeData.trayHeight] when set.
  final double? height;

  /// Overrides [StoriesThemeData.trayAvatarSize] when set.
  final double? avatarSize;
  final EdgeInsetsGeometry? padding;
  final double? itemSpacing;
  final TextStyle? labelStyle;
  final double? labelSpacing;
  final bool showAddButton;
  final String? addButtonLabel;
  final Widget Function(BuildContext context)? addButtonBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = StoriesTheme.of(context);
    final trayHeight = height ?? theme.trayHeight;
    final size = avatarSize ?? theme.trayAvatarSize;
    final spacing = itemSpacing ?? theme.trayItemSpacing;
    final labelGap = labelSpacing ?? theme.trayLabelSpacing;
    final resolvedLabelStyle = labelStyle ??
        theme.trayLabelStyle ??
        Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 11);
    final trayPadding = padding ?? theme.trayPadding;
    final addLabel = addButtonLabel ?? theme.addStoryLabel;

    return SizedBox(
      height: trayHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: trayPadding,
        itemCount: itemCount,
        separatorBuilder: (context, index) => SizedBox(width: spacing),
        itemBuilder: (context, index) {
          if (showAddButton && index == 0) {
            return _AddStoryTile(
              size: size,
              label: addLabel,
              labelStyle: resolvedLabelStyle,
              labelSpacing: labelGap,
              onTap: onAddStoryTap,
              builder: addButtonBuilder,
            );
          }

          final userIndex = showAddButton ? index - 1 : index;
          final user = users[userIndex];
          return _StoryTrayTile(
            user: user,
            avatarSize: size,
            labelStyle: resolvedLabelStyle,
            labelSpacing: labelGap,
            onTap: () => onUserTap?.call(userIndex, user),
          );
        },
      ),
    );
  }

  int get itemCount => users.length + (showAddButton ? 1 : 0);
}

class _StoryTrayTile extends StatelessWidget {
  const _StoryTrayTile({
    required this.user,
    required this.avatarSize,
    required this.labelSpacing,
    required this.onTap,
    this.labelStyle,
  });

  final StoryUser user;
  final double avatarSize;
  final double labelSpacing;
  final VoidCallback? onTap;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: avatarSize + 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StoryAvatar(
              seen: user.seen,
              image: user.avatar,
              size: avatarSize,
            ),
            SizedBox(height: labelSpacing),
            Text(
              user.name,
              style: labelStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddStoryTile extends StatelessWidget {
  const _AddStoryTile({
    required this.size,
    required this.label,
    required this.labelSpacing,
    this.labelStyle,
    this.onTap,
    this.builder,
  });

  final double size;
  final String label;
  final double labelSpacing;
  final TextStyle? labelStyle;
  final VoidCallback? onTap;
  final Widget Function(BuildContext context)? builder;

  @override
  Widget build(BuildContext context) {
    if (builder != null) {
      return GestureDetector(onTap: onTap, child: builder!(context));
    }

    final theme = StoriesTheme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size + 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  StoryAvatar(seen: true, size: size),
                  PositionedDirectional(
                    end: 0,
                    bottom: 0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: theme.addButtonColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Icon(
                          Icons.add,
                          size: theme.addButtonIconSize,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: labelSpacing),
            Text(
              label,
              style: labelStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
