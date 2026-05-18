import 'package:flutter/material.dart';

import '../animations/story_transitions.dart';

/// Styling defaults for tray, rings, viewer, and story slides.
@immutable
class StoriesThemeData extends ThemeExtension<StoriesThemeData> {
  const StoriesThemeData({
    required this.trayHeight,
    required this.trayAvatarSize,
    required this.trayItemSpacing,
    required this.trayPadding,
    required this.trayLabelSpacing,
    required this.trayLabelStyle,
    required this.unseenRingGradient,
    required this.seenRingColor,
    required this.ringWidth,
    required this.ringGap,
    required this.avatarPlaceholder,
    required this.avatarBackgroundColor,
    required this.defaultStoryDuration,
    required this.storyImageFit,
    required this.storyPlaceholder,
    required this.progressBarHeight,
    required this.progressBarSpacing,
    required this.progressBarBackgroundColor,
    required this.progressBarForegroundColor,
    required this.progressBarPadding,
    required this.viewerBackgroundColor,
    required this.captionStyle,
    required this.storyTitleStyle,
    required this.storySubtitleStyle,
    required this.storyOverlayPadding,
    required this.headerNameStyle,
    required this.headerAvatarRadius,
    required this.headerPadding,
    required this.closeIcon,
    required this.closeIconColor,
    required this.addStoryLabel,
    required this.addButtonColor,
    required this.addButtonIconSize,
    required this.videoFit,
    required this.videoLooping,
    required this.videoLoadingBuilder,
    required this.storyItemTransition,
    required this.userTransition,
    required this.transitionDuration,
    required this.transitionCurve,
  });

  // --- Tray ---

  final double trayHeight;
  final double trayAvatarSize;
  final double trayItemSpacing;
  final EdgeInsetsGeometry trayPadding;
  final double trayLabelSpacing;
  final TextStyle? trayLabelStyle;

  // --- Avatar ring ---

  final Gradient unseenRingGradient;
  final Color seenRingColor;
  final double ringWidth;
  final double ringGap;
  final Widget? avatarPlaceholder;
  final Color avatarBackgroundColor;

  // --- Story slides ---

  final Duration defaultStoryDuration;
  final BoxFit storyImageFit;
  final Widget? storyPlaceholder;

  // --- Progress bar ---

  final double progressBarHeight;
  final double progressBarSpacing;
  final Color progressBarBackgroundColor;
  final Color progressBarForegroundColor;
  final EdgeInsetsGeometry progressBarPadding;

  // --- Viewer ---

  final Color viewerBackgroundColor;
  final TextStyle captionStyle;
  final TextStyle storyTitleStyle;
  final TextStyle storySubtitleStyle;
  final EdgeInsetsGeometry storyOverlayPadding;
  final TextStyle headerNameStyle;
  final double headerAvatarRadius;
  final EdgeInsetsGeometry headerPadding;
  final IconData closeIcon;
  final Color closeIconColor;

  // --- Add story tile ---

  final String addStoryLabel;
  final Color addButtonColor;
  final double addButtonIconSize;

  // --- Video ---

  final BoxFit videoFit;
  final bool videoLooping;
  final WidgetBuilder? videoLoadingBuilder;

  // --- Transitions ---

  /// Between slides of the same user. Default [StoryItemTransition.none].
  final StoryItemTransition storyItemTransition;

  /// Between users in the viewer. Default [StoryUserTransition.page].
  final StoryUserTransition userTransition;

  final Duration transitionDuration;
  final Curve transitionCurve;

  static const unseenGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color(0xFFFA8F21),
      Color(0xFFE1306C),
      Color(0xFFC13584),
      Color(0xFF833AB4),
    ],
  );

  static StoriesThemeData get defaults => light;

  static StoriesThemeData get light => StoriesThemeData(
        trayHeight: 104,
        trayAvatarSize: 68,
        trayItemSpacing: 12,
        trayPadding: const EdgeInsetsDirectional.symmetric(horizontal: 8),
        trayLabelSpacing: 4,
        trayLabelStyle: null,
        unseenRingGradient: unseenGradient,
        seenRingColor: const Color(0xFFBDBDBD),
        ringWidth: 2.5,
        ringGap: 2,
        avatarPlaceholder: null,
        avatarBackgroundColor: const Color(0xFFE0E0E0),
        defaultStoryDuration: const Duration(seconds: 5),
        storyImageFit: BoxFit.cover,
        storyPlaceholder: null,
        progressBarHeight: 2.5,
        progressBarSpacing: 4,
        progressBarBackgroundColor: const Color(0x59FFFFFF),
        progressBarForegroundColor: Colors.white,
        progressBarPadding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 0),
        viewerBackgroundColor: Colors.black,
        captionStyle: const TextStyle(color: Colors.white, fontSize: 15),
        storyTitleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          shadows: [Shadow(color: Colors.black45, blurRadius: 6)],
        ),
        storySubtitleStyle: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          shadows: [Shadow(color: Colors.black45, blurRadius: 6)],
        ),
        storyOverlayPadding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 24),
        headerNameStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        headerAvatarRadius: 16,
        headerPadding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 0),
        closeIcon: Icons.close,
        closeIconColor: Colors.white,
        addStoryLabel: 'Your story',
        addButtonColor: const Color(0xFF0095F6),
        addButtonIconSize: 16,
        videoFit: BoxFit.cover,
        videoLooping: false,
        videoLoadingBuilder: null,
        storyItemTransition: StoryItemTransition.none,
        userTransition: StoryUserTransition.page,
        transitionDuration: const Duration(milliseconds: 280),
        transitionCurve: Curves.easeOutCubic,
      );

  static StoriesThemeData get dark => light.copyWith(
        seenRingColor: const Color(0xFF616161),
        avatarBackgroundColor: const Color(0xFF424242),
        viewerBackgroundColor: Colors.black,
      );

  @override
  StoriesThemeData copyWith({
    double? trayHeight,
    double? trayAvatarSize,
    double? trayItemSpacing,
    EdgeInsetsGeometry? trayPadding,
    double? trayLabelSpacing,
    TextStyle? trayLabelStyle,
    Gradient? unseenRingGradient,
    Color? seenRingColor,
    double? ringWidth,
    double? ringGap,
    Widget? avatarPlaceholder,
    Color? avatarBackgroundColor,
    Duration? defaultStoryDuration,
    BoxFit? storyImageFit,
    Widget? storyPlaceholder,
    double? progressBarHeight,
    double? progressBarSpacing,
    Color? progressBarBackgroundColor,
    Color? progressBarForegroundColor,
    EdgeInsetsGeometry? progressBarPadding,
    Color? viewerBackgroundColor,
    TextStyle? captionStyle,
    TextStyle? storyTitleStyle,
    TextStyle? storySubtitleStyle,
    EdgeInsetsGeometry? storyOverlayPadding,
    TextStyle? headerNameStyle,
    double? headerAvatarRadius,
    EdgeInsetsGeometry? headerPadding,
    IconData? closeIcon,
    Color? closeIconColor,
    String? addStoryLabel,
    Color? addButtonColor,
    double? addButtonIconSize,
    BoxFit? videoFit,
    bool? videoLooping,
    WidgetBuilder? videoLoadingBuilder,
    StoryItemTransition? storyItemTransition,
    StoryUserTransition? userTransition,
    Duration? transitionDuration,
    Curve? transitionCurve,
  }) {
    return StoriesThemeData(
      trayHeight: trayHeight ?? this.trayHeight,
      trayAvatarSize: trayAvatarSize ?? this.trayAvatarSize,
      trayItemSpacing: trayItemSpacing ?? this.trayItemSpacing,
      trayPadding: trayPadding ?? this.trayPadding,
      trayLabelSpacing: trayLabelSpacing ?? this.trayLabelSpacing,
      trayLabelStyle: trayLabelStyle ?? this.trayLabelStyle,
      unseenRingGradient: unseenRingGradient ?? this.unseenRingGradient,
      seenRingColor: seenRingColor ?? this.seenRingColor,
      ringWidth: ringWidth ?? this.ringWidth,
      ringGap: ringGap ?? this.ringGap,
      avatarPlaceholder: avatarPlaceholder ?? this.avatarPlaceholder,
      avatarBackgroundColor:
          avatarBackgroundColor ?? this.avatarBackgroundColor,
      defaultStoryDuration: defaultStoryDuration ?? this.defaultStoryDuration,
      storyImageFit: storyImageFit ?? this.storyImageFit,
      storyPlaceholder: storyPlaceholder ?? this.storyPlaceholder,
      progressBarHeight: progressBarHeight ?? this.progressBarHeight,
      progressBarSpacing: progressBarSpacing ?? this.progressBarSpacing,
      progressBarBackgroundColor:
          progressBarBackgroundColor ?? this.progressBarBackgroundColor,
      progressBarForegroundColor:
          progressBarForegroundColor ?? this.progressBarForegroundColor,
      progressBarPadding: progressBarPadding ?? this.progressBarPadding,
      viewerBackgroundColor:
          viewerBackgroundColor ?? this.viewerBackgroundColor,
      captionStyle: captionStyle ?? this.captionStyle,
      storyTitleStyle: storyTitleStyle ?? this.storyTitleStyle,
      storySubtitleStyle: storySubtitleStyle ?? this.storySubtitleStyle,
      storyOverlayPadding: storyOverlayPadding ?? this.storyOverlayPadding,
      headerNameStyle: headerNameStyle ?? this.headerNameStyle,
      headerAvatarRadius: headerAvatarRadius ?? this.headerAvatarRadius,
      headerPadding: headerPadding ?? this.headerPadding,
      closeIcon: closeIcon ?? this.closeIcon,
      closeIconColor: closeIconColor ?? this.closeIconColor,
      addStoryLabel: addStoryLabel ?? this.addStoryLabel,
      addButtonColor: addButtonColor ?? this.addButtonColor,
      addButtonIconSize: addButtonIconSize ?? this.addButtonIconSize,
      videoFit: videoFit ?? this.videoFit,
      videoLooping: videoLooping ?? this.videoLooping,
      videoLoadingBuilder: videoLoadingBuilder ?? this.videoLoadingBuilder,
      storyItemTransition:
          storyItemTransition ?? this.storyItemTransition,
      userTransition: userTransition ?? this.userTransition,
      transitionDuration: transitionDuration ?? this.transitionDuration,
      transitionCurve: transitionCurve ?? this.transitionCurve,
    );
  }

  @override
  StoriesThemeData lerp(ThemeExtension<StoriesThemeData>? other, double t) {
    if (other is! StoriesThemeData) return this;
    return t < 0.5 ? this : other;
  }

  /// Resolves theme without registering a dependency (safe in [State.initState]).
  static StoriesThemeData resolve(BuildContext context) {
    final inherited = StoriesTheme.maybeOf(context);
    if (inherited != null) return inherited;
    return Theme.of(context).extension<StoriesThemeData>() ?? defaults;
  }
}

/// Provides [StoriesThemeData] to descendant story widgets.
class StoriesTheme extends InheritedWidget {
  const StoriesTheme({
    super.key,
    required this.data,
    required super.child,
  });

  final StoriesThemeData data;

  /// Registers a dependency; use in [State.build], not [State.initState].
  static StoriesThemeData of(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<StoriesTheme>();
    if (inherited != null) return inherited.data;
    return Theme.of(context).extension<StoriesThemeData>() ??
        StoriesThemeData.defaults;
  }

  /// Lookup only; does not register a dependency.
  static StoriesThemeData? maybeOf(BuildContext context) {
    return context.getInheritedWidgetOfExactType<StoriesTheme>()?.data;
  }

  @override
  bool updateShouldNotify(StoriesTheme oldWidget) => data != oldWidget.data;
}
