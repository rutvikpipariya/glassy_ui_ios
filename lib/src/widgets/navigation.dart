import 'package:flutter/material.dart';

import '../config.dart';
import 'glassy_view.dart';

/// A floating glass tab bar for `Scaffold.bottomNavigationBar`.
///
/// Only the bar is native; your pages stay Flutter widgets. Set
/// `Scaffold.extendBody: true` so the pages scroll under the glass.
///
/// ```dart
/// Scaffold(
///   extendBody: true,
///   body: pages[index],
///   bottomNavigationBar: GlassTabBar(
///     items: const [
///       NativeItem.symbol('Home', 'house.fill'),
///       NativeItem.symbol('Profile', 'person.crop.circle.fill', badge: '2'),
///     ],
///     selectedIndex: index,
///     onChanged: (i) => setState(() => index = i),
///   ),
/// );
/// ```
class GlassTabBar extends StatelessWidget {
  /// Creates a glass tab bar.
  const GlassTabBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    this.expandable = false,
    this.safeArea = true,
    this.height = 64,
    this.style,
    this.fallback,
  });

  /// Tabs: title, SF Symbol and optional `badge`.
  final List<NativeItem> items;

  /// Index of the selected tab.
  final int selectedIndex;

  /// Called with the index of the tab the user tapped.
  final ValueChanged<int> onChanged;

  /// Show only the selected tab's title; the others are icons.
  final bool expandable;

  /// Pad the bar above the home indicator. Turn off when the bar is not at
  /// the bottom of the screen.
  final bool safeArea;

  /// Height of the bar, excluding the bottom safe area.
  final double height;

  /// Appearance. Tint and color scheme default to the app's [Theme].
  final NativeStyle? style;

  /// Shown on platforms other than iOS, e.g. a Material `NavigationBar`.
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    if (!isNativePlatform) return fallback ?? const SizedBox.shrink();
    return SafeArea(
      top: false,
      bottom: safeArea,
      child: GlassyView(
        id: 'glassy-tab-bar',
        height: height,
        style: style,
        fallback: fallback,
        config: NativeComponentConfig(
          items: indexedItems(items),
          value: '$selectedIndex',
          extra: {'expandable': expandable},
        ),
        onEvent: (event) {
          final index = indexOf(event);
          if (event.name == 'change' && index != null) onChanged(index);
        },
      ),
    );
  }
}

/// A floating glass capsule of buttons: toolbars, button groups, photo actions.
///
/// Items with an icon show the icon (their title is the VoiceOver label);
/// items without one show their title. `NativeItemRole.destructive` is red.
///
/// ```dart
/// GlassToolbar(
///   items: const [
///     NativeItem.symbol('Share', 'square.and.arrow.up'),
///     NativeItem.symbol('Favorite', 'heart'),
///     NativeItem.symbol('Delete', 'trash', role: NativeItemRole.destructive),
///   ],
///   onPressed: (index) => debugPrint('$index'),
/// )
/// ```
class GlassToolbar extends StatelessWidget {
  /// Creates a glass toolbar.
  const GlassToolbar({
    super.key,
    required this.items,
    required this.onPressed,
    this.width,
    this.height = 56,
    this.style,
    this.fallback,
  });

  /// Buttons.
  final List<NativeItem> items;

  /// Called with the index of the tapped button.
  final ValueChanged<int> onPressed;

  /// Width of the native view; defaults to the available width.
  final double? width;

  /// Height of the native view.
  final double height;

  /// Appearance. Tint and color scheme default to the app's [Theme].
  final NativeStyle? style;

  /// Shown on platforms other than iOS.
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    return GlassyView(
      id: 'glassy-toolbar',
      width: width,
      height: height,
      style: style,
      fallback: fallback,
      config: NativeComponentConfig(items: indexedItems(items)),
      onEvent: (event) {
        final index = indexOf(event);
        if (event.name == 'tap' && index != null) onPressed(index);
      },
    );
  }
}
