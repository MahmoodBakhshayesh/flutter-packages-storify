import 'package:flutter/material.dart';

import 'theme/stories_theme_data.dart';

/// Wraps stories UI with optional [textDirection] and [StoriesThemeData].
///
/// By default, stories follow [Directionality] and [ThemeData.extensions] from
/// [MaterialApp]. Use this to override direction or theme for a subtree.
class StoriesScope extends StatelessWidget {
  const StoriesScope({
    super.key,
    required this.child,
    this.textDirection,
    this.theme,
  });

  /// Child widget tree.
  final Widget child;

  /// Overrides layout direction for stories (e.g. [TextDirection.rtl]).
  final TextDirection? textDirection;

  /// Optional theme override for this subtree.
  final StoriesThemeData? theme;

  @override
  Widget build(BuildContext context) {
    Widget result = child;

    if (theme != null) {
      result = StoriesTheme(data: theme!, child: result);
    }

    if (textDirection != null) {
      result = Directionality(textDirection: textDirection!, child: result);
    }

    return result;
  }
}
