import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Glass appearance for glass surfaces.
enum NativeGlass {
  /// `Glass.regular` on iOS 26+, `.regularMaterial` on iOS 17–18.
  regular,

  /// `Glass.clear` on iOS 26+, `.ultraThinMaterial` on iOS 17–18.
  clear,

  /// No glass: solid surfaces using [NativeStyle.surfaceColor].
  none,
}

/// Forces the native light or dark appearance.
enum NativeColorScheme {
  /// Light appearance.
  light,

  /// Dark appearance.
  dark,
}

/// SwiftUI `ControlSize`.
enum NativeControlSize {
  /// `ControlSize.mini`.
  mini,

  /// `ControlSize.small`.
  small,

  /// `ControlSize.regular`, the system default.
  regular,

  /// `ControlSize.large`.
  large,

  /// `ControlSize.extraLarge`.
  extraLarge,
}

/// SwiftUI `Font.Weight`.
enum NativeFontWeight {
  /// `Font.Weight.ultraLight`.
  ultraLight,

  /// `Font.Weight.thin`.
  thin,

  /// `Font.Weight.light`.
  light,

  /// `Font.Weight.regular`.
  regular,

  /// `Font.Weight.medium`.
  medium,

  /// `Font.Weight.semibold`.
  semibold,

  /// `Font.Weight.bold`.
  bold,

  /// `Font.Weight.heavy`.
  heavy,

  /// `Font.Weight.black`.
  black,
}

/// SwiftUI `Font.Design`.
enum NativeFontDesign {
  /// The default system font (San Francisco).
  standard,

  /// SF Pro Rounded.
  rounded,

  /// New York.
  serif,

  /// SF Mono.
  monospaced,
}

/// Role of a [NativeItem] in menus, alerts and dialogs.
enum NativeItemRole {
  /// A regular action.
  normal,

  /// A destructive action, shown in red.
  destructive,

  /// The cancel action of an alert, dialog or action sheet.
  cancel,
}

/// An image shown natively: an SF Symbol, a Flutter asset or raw bytes.
@immutable
class NativeImage {
  const NativeImage._(this._type, this._value);

  /// An SF Symbol, e.g. `NativeImage.symbol('heart.fill')`.
  const NativeImage.symbol(String name) : this._('symbol', name);

  /// A Flutter asset declared in `pubspec.yaml`, e.g. `assets/cover.jpg`.
  const NativeImage.asset(String path) : this._('asset', path);

  /// Encoded image bytes (PNG, JPEG, HEIC…).
  const NativeImage.bytes(Uint8List bytes) : this._('bytes', bytes);

  final String _type;
  final Object _value;

  /// Encodes the image for the platform channel.
  Map<String, Object?> toMap() => {'type': _type, 'value': _value};
}

/// Visual customization shared by every component.
///
/// Every field is optional; `null` keeps the component's native default.
@immutable
class NativeStyle {
  /// Creates a style. Every argument is optional.
  const NativeStyle({
    this.tintColor,
    this.foregroundColor,
    this.backgroundColor,
    this.backgroundGradient,
    this.showBackdrop = true,
    this.surfaceColor,
    this.cornerRadius,
    this.glass = NativeGlass.regular,
    this.glassTint,
    this.interactive = true,
    this.padding,
    this.spacing,
    this.fontSize,
    this.fontWeight,
    this.fontDesign,
    this.colorScheme,
    this.controlSize,
  });

  /// Accent color (`.tint`) for buttons, toggles, sliders and selection.
  final Color? tintColor;

  /// Primary text and icon color.
  final Color? foregroundColor;

  /// Solid background; replaces the decorative backdrop.
  final Color? backgroundColor;

  /// Gradient background (top-leading → bottom-trailing); replaces the backdrop.
  final List<Color>? backgroundGradient;

  /// Shows the colorful backdrop that makes glass refraction visible.
  /// When `false` and no background is given, the system background is used.
  final bool showBackdrop;

  /// Color of solid surfaces when [glass] is [NativeGlass.none].
  final Color? surfaceColor;

  /// Corner radius of cards, sheets and rounded glass shapes.
  final double? cornerRadius;

  /// Glass variant used for glass surfaces.
  final NativeGlass glass;

  /// Tint mixed into glass surfaces.
  final Color? glassTint;

  /// Whether glass reacts to touches (`Glass.interactive()`).
  final bool interactive;

  /// Content padding in points.
  final double? padding;

  /// Spacing between elements in points.
  final double? spacing;

  /// Title font size; `null` keeps Dynamic Type text styles.
  final double? fontSize;

  /// Title font weight.
  final NativeFontWeight? fontWeight;

  /// Title font design.
  final NativeFontDesign? fontDesign;

  /// Forces light or dark; `null` follows the system.
  final NativeColorScheme? colorScheme;

  /// Size of buttons and other controls.
  final NativeControlSize? controlSize;

  /// Returns a copy with the given fields replaced.
  NativeStyle copyWith({
    Color? tintColor,
    Color? foregroundColor,
    Color? backgroundColor,
    List<Color>? backgroundGradient,
    bool? showBackdrop,
    Color? surfaceColor,
    double? cornerRadius,
    NativeGlass? glass,
    Color? glassTint,
    bool? interactive,
    double? padding,
    double? spacing,
    double? fontSize,
    NativeFontWeight? fontWeight,
    NativeFontDesign? fontDesign,
    NativeColorScheme? colorScheme,
    NativeControlSize? controlSize,
  }) {
    return NativeStyle(
      tintColor: tintColor ?? this.tintColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
      showBackdrop: showBackdrop ?? this.showBackdrop,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      glass: glass ?? this.glass,
      glassTint: glassTint ?? this.glassTint,
      interactive: interactive ?? this.interactive,
      padding: padding ?? this.padding,
      spacing: spacing ?? this.spacing,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      fontDesign: fontDesign ?? this.fontDesign,
      colorScheme: colorScheme ?? this.colorScheme,
      controlSize: controlSize ?? this.controlSize,
    );
  }

  /// Encodes this object for the platform channel.
  Map<String, Object?> toMap() => _compact({
        'tintColor': tintColor?.toARGB32(),
        'foregroundColor': foregroundColor?.toARGB32(),
        'backgroundColor': backgroundColor?.toARGB32(),
        'backgroundGradient':
            backgroundGradient?.map((c) => c.toARGB32()).toList(),
        'showBackdrop': showBackdrop,
        'surfaceColor': surfaceColor?.toARGB32(),
        'cornerRadius': cornerRadius,
        'glass': glass.name,
        'glassTint': glassTint?.toARGB32(),
        'interactive': interactive,
        'padding': padding,
        'spacing': spacing,
        'fontSize': fontSize,
        'fontWeight': fontWeight?.name,
        'fontDesign': switch (fontDesign) {
          NativeFontDesign.standard => 'default',
          final design? => design.name,
          null => null,
        },
        'colorScheme': colorScheme?.name,
        'controlSize': controlSize?.name,
      });
}

/// A generic entry: tab, menu action, segment, option, toolbar button or row.
/// Nest [children] for submenus, split-view items and wheel picker columns.
@immutable
class NativeItem {
  /// Creates an item. Only [title] is required.
  const NativeItem({
    this.id,
    required this.title,
    this.subtitle,
    this.image,
    this.symbol,
    this.role = NativeItemRole.normal,
    this.badge,
    this.selected = false,
    this.enabled = true,
    this.children = const [],
  });

  /// Shorthand for an item with an SF Symbol: `NativeItem.symbol('Home', 'house')`.
  const NativeItem.symbol(
    this.title,
    String this.symbol, {
    this.id,
    this.subtitle,
    this.role = NativeItemRole.normal,
    this.badge,
    this.selected = false,
    this.enabled = true,
    this.children = const [],
  }) : image = null;

  /// Identifier sent back in events. Defaults to [title].
  final String? id;

  /// Visible title.
  final String title;

  /// Secondary text, shown under the title where supported.
  final String? subtitle;

  /// Icon or artwork. Takes precedence over [symbol].
  final NativeImage? image;

  /// SF Symbol name, a shorthand for `image: NativeImage.symbol(…)`.
  final String? symbol;

  /// Role in menus, alerts and dialogs.
  final NativeItemRole role;

  /// Badge text (tab badges, list accessories).
  final String? badge;

  /// Initial selected / checked / on state.
  final bool selected;

  /// Whether the item can be interacted with.
  final bool enabled;

  /// Nested items: submenus, split-view rows or wheel picker rows.
  final List<NativeItem> children;

  /// Encodes this object for the platform channel.
  Map<String, Object?> toMap() => _compact({
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'image':
            (image ?? (symbol == null ? null : NativeImage.symbol(symbol!)))
                ?.toMap(),
        'role': role == NativeItemRole.normal ? null : role.name,
        'badge': badge,
        'selected': selected ? true : null,
        'enabled': enabled ? null : false,
        'children':
            children.isEmpty ? null : children.map((c) => c.toMap()).toList(),
      });
}

/// Content and appearance of a native component.
///
/// The same vocabulary is shared by all components; each component documents
/// which fields it reads (see `NativeComponentType`). Unknown fields are ignored.
@immutable
class NativeComponentConfig {
  /// Creates a configuration. Every argument is optional; components fall
  /// back to their own native defaults.
  const NativeComponentConfig({
    this.title,
    this.subtitle,
    this.message,
    this.placeholder,
    this.image,
    this.items,
    this.value,
    this.min,
    this.max,
    this.step,
    this.enabled = true,
    this.extra = const {},
    this.style = const NativeStyle(),
  });

  /// Main text: navigation title, button label, alert title…
  final String? title;

  /// Secondary text.
  final String? subtitle;

  /// Body text of alerts, sheets and cards.
  final String? message;

  /// Placeholder of text and search fields.
  final String? placeholder;

  /// Main icon or artwork.
  final NativeImage? image;

  /// Tabs, actions, segments, options or rows.
  final List<NativeItem>? items;

  /// Initial value: `bool`, `num`, `String`, `List`, or a `DateTime`
  /// (sent as ISO-8601). Colors may be passed as `Color`.
  final Object? value;

  /// Lower bound of sliders, steppers and progress.
  final double? min;

  /// Upper bound of sliders, steppers and progress.
  final double? max;

  /// Step of sliders and steppers.
  final double? step;

  /// Whether the whole component accepts interaction.
  final bool enabled;

  /// Component-specific options (codec-compatible values).
  final Map<String, Object?> extra;

  /// Visual customization.
  final NativeStyle style;

  /// Returns a copy with the given fields replaced.
  NativeComponentConfig copyWith({
    String? title,
    String? subtitle,
    String? message,
    String? placeholder,
    NativeImage? image,
    List<NativeItem>? items,
    Object? value,
    double? min,
    double? max,
    double? step,
    bool? enabled,
    Map<String, Object?>? extra,
    NativeStyle? style,
  }) {
    return NativeComponentConfig(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      message: message ?? this.message,
      placeholder: placeholder ?? this.placeholder,
      image: image ?? this.image,
      items: items ?? this.items,
      value: value ?? this.value,
      min: min ?? this.min,
      max: max ?? this.max,
      step: step ?? this.step,
      enabled: enabled ?? this.enabled,
      extra: extra ?? this.extra,
      style: style ?? this.style,
    );
  }

  /// Encodes this object for the platform channel.
  Map<String, Object?> toMap() => _compact({
        'title': title,
        'subtitle': subtitle,
        'message': message,
        'placeholder': placeholder,
        'image': image?.toMap(),
        'items': items?.map((i) => i.toMap()).toList(),
        'value': encodeNativeValue(value),
        'min': min,
        'max': max,
        'step': step,
        'enabled': enabled,
        'extra': extra.isEmpty
            ? null
            : extra.map((k, v) => MapEntry(k, encodeNativeValue(v))),
        'style': style.toMap(),
      });
}

/// Converts Dart values into codec-friendly ones (`DateTime`, `Color`, enums).
Object? encodeNativeValue(Object? value) => switch (value) {
      DateTime() => value.toUtc().toIso8601String(),
      Color() => value.toARGB32(),
      Enum() => value.name,
      List() => value.map(encodeNativeValue).toList(),
      Map() =>
        value.map((k, v) => MapEntry(k.toString(), encodeNativeValue(v))),
      _ => value,
    };

Map<String, Object?> _compact(Map<String, Object?> map) =>
    map..removeWhere((_, value) => value == null);
