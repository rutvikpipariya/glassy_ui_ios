import 'package:flutter/material.dart';

import '../config.dart';
import 'glassy_view.dart';

/// A glass button that opens a native iOS menu.
///
/// Items support roles and nested `children` (submenus). Without a [title]
/// and with [showChevron] off it is a circular icon button, e.g. an overflow
/// (`ellipsis`) menu. Falls back to a Material `MenuAnchor`.
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
    this.showChevron = true,
    this.prominent = true,
    this.width = 220,
    this.height = 52,
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

  /// Show a chevron after the title.
  final bool showChevron;

  /// Filled (`.glassProminent`) instead of clear glass.
  final bool prominent;

  /// Width of the native view. Platform views cannot size themselves, so pick
  /// one that fits the title.
  final double width;

  /// Height of the native view.
  final double height;

  /// Appearance. Tint and color scheme default to the app's [Theme].
  final NativeStyle? style;

  /// Shown on platforms other than iOS. Defaults to a Material `MenuAnchor`.
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    return GlassyView(
      id: 'glassy-menu-button',
      width: width,
      height: height,
      style: style,
      fallback: fallback ?? _materialMenu(),
      config: NativeComponentConfig(
        title: title,
        image: icon,
        items: items,
        extra: {'prominent': prominent, 'chevron': showChevron},
      ),
      onEvent: (event) {
        if (event.name == 'select') onSelected(event.value as String);
      },
    );
  }

  Widget _materialMenu() {
    List<Widget> entries(List<NativeItem> items) => [
          for (final item in items)
            if (item.children.isEmpty)
              MenuItemButton(
                onPressed: item.enabled
                    ? () => onSelected(item.id ?? item.title)
                    : null,
                child: Text(item.title),
              )
            else
              SubmenuButton(
                menuChildren: entries(item.children),
                child: Text(item.title),
              ),
        ];
    return MenuAnchor(
      menuChildren: entries(items),
      builder: (context, controller, child) {
        void toggle() =>
            controller.isOpen ? controller.close() : controller.open();
        if (title == null) {
          return IconButton(
              onPressed: toggle, icon: const Icon(Icons.more_horiz));
        }
        final label = Text(title!);
        const chevron = Icon(Icons.arrow_drop_down);
        return prominent
            ? FilledButton.icon(onPressed: toggle, icon: chevron, label: label)
            : OutlinedButton.icon(
                onPressed: toggle, icon: chevron, label: label);
      },
    );
  }
}

/// A pop-up button that shows the current choice and opens a native picker
/// menu (`Menu` + `Picker`). Falls back to a Material `DropdownButton`.
///
/// ```dart
/// GlassPopupButton(
///   label: 'Repeat',
///   items: const [NativeItem(title: 'Never'), NativeItem(title: 'Daily')],
///   selectedIndex: repeat,
///   onChanged: (i) => setState(() => repeat = i),
/// )
/// ```
class GlassPopupButton extends StatelessWidget {
  /// Creates a pop-up button.
  const GlassPopupButton({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    this.label,
    this.width,
    this.height = 50,
    this.style,
    this.fallback,
  });

  /// Options.
  final List<NativeItem> items;

  /// Index of the selected option.
  final int selectedIndex;

  /// Called with the index of the chosen option.
  final ValueChanged<int> onChanged;

  /// Optional label in front of the button (the row then fills the width).
  final String? label;

  /// Width of the native view; defaults to the available width.
  final double? width;

  /// Height of the native view.
  final double height;

  /// Appearance. Tint and color scheme default to the app's [Theme].
  final NativeStyle? style;

  /// Shown on platforms other than iOS. Defaults to a `DropdownButton`.
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    final dropdown = DropdownButton<int>(
      value: selectedIndex,
      onChanged: (index) => index != null ? onChanged(index) : null,
      items: [
        for (var i = 0; i < items.length; i++)
          DropdownMenuItem(value: i, child: Text(items[i].title)),
      ],
    );
    return GlassyView(
      id: 'glassy-popup-button',
      width: width,
      height: height,
      style: style,
      fallback: fallback ??
          (label == null
              ? dropdown
              : Row(children: [Text(label!), const Spacer(), dropdown])),
      config: NativeComponentConfig(
        title: label,
        items: indexedItems(items),
        value: '$selectedIndex',
      ),
      onEvent: (event) {
        final index = indexOf(event);
        if (event.name == 'change' && index != null) onChanged(index);
      },
    );
  }
}
