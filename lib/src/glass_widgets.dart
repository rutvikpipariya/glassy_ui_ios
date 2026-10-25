import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'config.dart';
import 'native_component.dart';

/// Fills in the colors a native view cannot read from Flutter: the app's
/// brightness (glass would otherwise guess from the empty view behind it) and
/// the theme's primary color as the tint.
NativeStyle _themed(BuildContext context, NativeStyle? style) {
  final theme = Theme.of(context);
  final base = style ?? const NativeStyle();
  return base.copyWith(
    tintColor: base.tintColor ?? theme.colorScheme.primary,
    colorScheme: base.colorScheme ??
        (theme.brightness == Brightness.dark
            ? NativeColorScheme.dark
            : NativeColorScheme.light),
  );
}

String _idOf(NativeItem item) => item.id ?? item.title;

bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;

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
///       NativeItem.symbol('Profile', 'person.crop.circle.fill'),
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

  /// Height of the bar, excluding the bottom safe area.
  final double height;

  /// Appearance. Tint and color scheme default to the app's [Theme].
  final NativeStyle? style;

  /// Shown on platforms other than iOS, e.g. a Material `NavigationBar`.
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    if (!_isIOS) return fallback ?? const SizedBox.shrink();
    return SafeArea(
      top: false,
      child: SizedBox(
        height: height,
        child: NativeComponent.custom(
          id: 'glassy-tab-bar',
          config: NativeComponentConfig(
            items: items,
            value: _idOf(items[selectedIndex]),
            style: _themed(context, style),
          ),
          onEvent: (event) {
            if (event.name != 'change') return;
            final index = items.indexWhere((item) => _idOf(item) == event.value);
            if (index != -1) onChanged(index);
          },
        ),
      ),
    );
  }
}

/// A circular glass icon button, e.g. for `AppBar.actions`.
///
/// ```dart
/// GlassIconButton(
///   icon: const NativeImage.symbol('person.crop.circle'),
///   onPressed: openProfile,
/// )
/// ```
class GlassIconButton extends StatelessWidget {
  /// Creates a glass icon button.
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 44,
    this.iconSize = 18,
    this.prominent = false,
    this.style,
    this.fallback,
  });

  /// Icon, usually an SF Symbol.
  final NativeImage icon;

  /// Called when the button is tapped.
  final VoidCallback onPressed;

  /// Width and height of the tappable area.
  final double size;

  /// Point size of the icon.
  final double iconSize;

  /// Filled (`.glassProminent`) instead of clear glass.
  final bool prominent;

  /// Appearance. Tint and color scheme default to the app's [Theme].
  final NativeStyle? style;

  /// Shown on platforms other than iOS, e.g. an `IconButton`.
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    if (!_isIOS) return fallback ?? const SizedBox.shrink();
    return SizedBox.square(
      dimension: size,
      child: NativeComponent.custom(
        id: 'glassy-icon-button',
        config: NativeComponentConfig(
          image: icon,
          extra: {'prominent': prominent, 'iconSize': iconSize},
          style: _themed(context, style),
        ),
        onEvent: (event) {
          if (event.name == 'tap') onPressed();
        },
      ),
    );
  }
}

/// A glass button that opens a native iOS menu.
///
/// Items support roles and nested `children` (submenus). Platform views
/// cannot size themselves, so give the button a [width] that fits its title.
///
/// ```dart
/// GlassMenuButton(
///   title: 'Sort',
///   items: const [NativeItem(title: 'Name'), NativeItem(title: 'Date')],
///   onSelected: (id) => debugPrint(id),
/// )
/// ```
class GlassMenuButton extends StatelessWidget {
  /// Creates a glass menu button.
  const GlassMenuButton({
    super.key,
    required this.items,
    required this.onSelected,
    this.title,
    this.icon,
    this.width = 220,
    this.height = 52,
    this.prominent = true,
    this.style,
    this.fallback,
  });

  /// Menu entries.
  final List<NativeItem> items;

  /// Called with the id of the chosen entry (`NativeItem.id`, or its title).
  final ValueChanged<String> onSelected;

  /// Button text.
  final String? title;

  /// Optional leading icon.
  final NativeImage? icon;

  /// Width of the native view.
  final double width;

  /// Height of the native view.
  final double height;

  /// Filled (`.glassProminent`) instead of clear glass.
  final bool prominent;

  /// Appearance. Tint and color scheme default to the app's [Theme].
  final NativeStyle? style;

  /// Shown on platforms other than iOS, e.g. a Material `MenuAnchor`.
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    if (!_isIOS) return fallback ?? const SizedBox.shrink();
    return SizedBox(
      width: width,
      height: height,
      child: NativeComponent.custom(
        id: 'glassy-menu-button',
        config: NativeComponentConfig(
          title: title,
          image: icon,
          items: items,
          extra: {'prominent': prominent},
          style: _themed(context, style),
        ),
        onEvent: (event) {
          if (event.name == 'select') onSelected(event.value as String);
        },
      ),
    );
  }
}
