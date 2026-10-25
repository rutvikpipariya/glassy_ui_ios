import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../config.dart';
import '../native_component.dart';

/// Whether the native views are available on this platform.
bool get isNativePlatform => defaultTargetPlatform == TargetPlatform.iOS;

/// Shared host for the `Glass…` widgets: shows the native control on iOS, at
/// a fixed size, with the app's [Theme] filled into [style]; shows [fallback]
/// everywhere else.
class GlassyView extends StatelessWidget {
  /// Creates the host for the native component registered as [id].
  const GlassyView({
    super.key,
    required this.id,
    required this.config,
    required this.fallback,
    this.style,
    this.width,
    this.height,
    this.onEvent,
    this.onCreated,
    this.gestureRecognizers = const {},
  });

  /// Native component id (`glassy-…`).
  final String id;

  /// Content; its style is replaced by the themed [style].
  final NativeComponentConfig config;

  /// Shown on platforms other than iOS.
  final Widget? fallback;

  /// Appearance before theming.
  final NativeStyle? style;

  /// Fixed width; `null` takes the available width.
  final double? width;

  /// Fixed height; `null` takes the available height.
  final double? height;

  /// Events from the native control.
  final ValueChanged<NativeEvent>? onEvent;

  /// Called once the native view exists.
  final ValueChanged<NativeComponentController>? onCreated;

  /// Gestures the native view claims. Empty by default: it gets taps, while
  /// drags still scroll a surrounding Flutter list.
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  @override
  Widget build(BuildContext context) {
    if (!isNativePlatform) return fallback ?? const SizedBox.shrink();
    return SizedBox(
      width: width,
      height: height,
      child: NativeComponent.custom(
        id: id,
        config: config.copyWith(style: themedStyle(context, style)),
        onEvent: onEvent,
        onCreated: onCreated,
        gestureRecognizers: gestureRecognizers,
      ),
    );
  }
}

/// Gives every drag to the native view (wheels, calendars).
final allGestures = <Factory<OneSequenceGestureRecognizer>>{
  Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
};

/// Gives horizontal drags to the native view (sliders).
final horizontalDrags = <Factory<OneSequenceGestureRecognizer>>{
  Factory<OneSequenceGestureRecognizer>(HorizontalDragGestureRecognizer.new),
};

/// Fills in what a native view cannot read from Flutter: the app's
/// brightness (glass would otherwise guess from the empty view behind it) and
/// the theme's primary color as the tint.
NativeStyle themedStyle(BuildContext context, NativeStyle? style) {
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

/// [items] with their index as id, so selections map back to an index even
/// when titles repeat.
List<NativeItem> indexedItems(List<NativeItem> items) => [
      for (var i = 0; i < items.length; i++)
        NativeItem(
          id: '$i',
          title: items[i].title,
          subtitle: items[i].subtitle,
          image: items[i].image,
          symbol: items[i].symbol,
          role: items[i].role,
          badge: items[i].badge,
          selected: items[i].selected,
          enabled: items[i].enabled,
          children: items[i].children,
        ),
    ];

/// Index sent back by a control built from [indexedItems].
int? indexOf(NativeEvent event) =>
    event.value is String ? int.tryParse(event.value as String) : null;
