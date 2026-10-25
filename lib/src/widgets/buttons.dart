import 'package:flutter/material.dart';

import '../config.dart';
import 'glassy_view.dart';

/// A glass button with a label and/or icon.
///
/// Falls back to a Material `FilledButton` (prominent) or `OutlinedButton`.
///
/// ```dart
/// GlassButton(
///   label: 'Continue',
///   icon: const NativeImage.symbol('arrow.right'),
///   prominent: true,
///   onPressed: next,
/// )
/// ```
class GlassButton extends StatelessWidget {
  /// Creates a glass button.
  const GlassButton({
    super.key,
    required this.onPressed,
    this.label,
    this.icon,
    this.prominent = false,
    this.size,
    this.width,
    this.height = 50,
    this.style,
    this.fallback,
  }) : assert(label != null || icon != null);

  /// Called when the button is tapped.
  final VoidCallback onPressed;

  /// Button text.
  final String? label;

  /// Optional icon, usually an SF Symbol.
  final NativeImage? icon;

  /// Filled (`.glassProminent`) instead of clear glass.
  final bool prominent;

  /// Native control size; defaults to regular.
  final NativeControlSize? size;

  /// Width of the native view; defaults to the available width.
  final double? width;

  /// Height of the native view.
  final double height;

  /// Appearance. Tint and color scheme default to the app's [Theme].
  final NativeStyle? style;

  /// Shown on platforms other than iOS. Defaults to a Material button.
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    final text = Text(label ?? '');
    return GlassyView(
      id: 'glassy-button',
      width: width,
      height: height,
      style: (style ?? const NativeStyle()).copyWith(controlSize: size),
      fallback: fallback ??
          (prominent
              ? FilledButton(onPressed: onPressed, child: text)
              : OutlinedButton(onPressed: onPressed, child: text)),
      config: NativeComponentConfig(
        title: label,
        image: icon,
        extra: {'prominent': prominent},
      ),
      onEvent: (event) {
        if (event.name == 'tap') onPressed();
      },
    );
  }
}

/// A circular glass icon button, e.g. for `AppBar.actions`.
///
/// ```dart
/// GlassIconButton(
///   icon: const NativeImage.symbol('person.crop.circle'),
///   semanticLabel: 'Profile',
///   onPressed: openProfile,
/// )
/// ```
class GlassIconButton extends StatelessWidget {
  /// Creates a glass icon button.
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.semanticLabel,
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

  /// VoiceOver label.
  final String? semanticLabel;

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
    return GlassyView(
      id: 'glassy-icon-button',
      width: size,
      height: size,
      style: style,
      fallback: fallback,
      config: NativeComponentConfig(
        image: icon,
        extra: {
          'prominent': prominent,
          'iconSize': iconSize,
          if (semanticLabel != null) 'label': semanticLabel,
        },
      ),
      onEvent: (event) {
        if (event.name == 'tap') onPressed();
      },
    );
  }
}

/// A glass back button (`chevron.backward`). Pops the current route unless
/// [onPressed] is given. Falls back to a Material `BackButton`.
class GlassBackButton extends StatelessWidget {
  /// Creates a glass back button.
  const GlassBackButton({super.key, this.onPressed, this.style});

  /// Called when tapped; defaults to `Navigator.maybePop`.
  final VoidCallback? onPressed;

  /// Appearance. Tint and color scheme default to the app's [Theme].
  final NativeStyle? style;

  @override
  Widget build(BuildContext context) {
    void back() =>
        onPressed != null ? onPressed!() : Navigator.maybePop(context);
    return GlassIconButton(
      icon: const NativeImage.symbol('chevron.backward'),
      semanticLabel: 'Back',
      onPressed: back,
      style: style,
      fallback: BackButton(onPressed: back),
    );
  }
}

/// A glass close button (`xmark`). Pops the current route unless
/// [onPressed] is given. Falls back to a Material `CloseButton`.
class GlassCloseButton extends StatelessWidget {
  /// Creates a glass close button.
  const GlassCloseButton({super.key, this.onPressed, this.style});

  /// Called when tapped; defaults to `Navigator.maybePop`.
  final VoidCallback? onPressed;

  /// Appearance. Tint and color scheme default to the app's [Theme].
  final NativeStyle? style;

  @override
  Widget build(BuildContext context) {
    void close() =>
        onPressed != null ? onPressed!() : Navigator.maybePop(context);
    return GlassIconButton(
      icon: const NativeImage.symbol('xmark'),
      semanticLabel: 'Close',
      onPressed: close,
      style: style,
      fallback: CloseButton(onPressed: close),
    );
  }
}

/// A tinted glass floating action button for `Scaffold.floatingActionButton`.
///
/// Give it [actions] and it expands into a column of labelled glass actions
/// instead of calling [onPressed].
///
/// ```dart
/// GlassFloatingActionButton(
///   actions: const [
///     NativeItem.symbol('Photo', 'photo'),
///     NativeItem.symbol('Note', 'note.text'),
///   ],
///   onActionSelected: (index) => create(index),
/// )
/// ```
class GlassFloatingActionButton extends StatefulWidget {
  /// Creates a glass floating action button.
  const GlassFloatingActionButton({
    super.key,
    this.icon = const NativeImage.symbol('plus'),
    this.onPressed,
    this.actions = const [],
    this.onActionSelected,
    this.semanticLabel,
    this.style,
    this.fallback,
  });

  /// Icon of the main button.
  final NativeImage icon;

  /// Called when tapped (only without [actions]).
  final VoidCallback? onPressed;

  /// Actions shown above the button when it expands.
  final List<NativeItem> actions;

  /// Called with the index of the chosen action.
  final ValueChanged<int>? onActionSelected;

  /// VoiceOver label of the main button.
  final String? semanticLabel;

  /// Appearance. Tint and color scheme default to the app's [Theme].
  final NativeStyle? style;

  /// Shown on platforms other than iOS, e.g. a `FloatingActionButton`.
  final Widget? fallback;

  @override
  State<GlassFloatingActionButton> createState() =>
      _GlassFloatingActionButtonState();
}

class _GlassFloatingActionButtonState extends State<GlassFloatingActionButton> {
  static const double _buttonSize = 64;
  static const double _actionHeight = 56;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    // Platform views take every touch in their bounds, so the view only grows
    // while the actions are showing.
    return GlassyView(
      id: 'glassy-fab',
      width: _expanded ? 240 : _buttonSize,
      height: _expanded
          ? _buttonSize + widget.actions.length * _actionHeight
          : _buttonSize,
      style: widget.style,
      fallback: widget.fallback,
      config: NativeComponentConfig(
        title: widget.semanticLabel,
        image: widget.icon,
        items: indexedItems(widget.actions),
      ),
      onEvent: (event) {
        switch (event.name) {
          case 'tap':
            widget.onPressed?.call();
          case 'select':
            final index = indexOf(event);
            if (index != null) widget.onActionSelected?.call(index);
          case 'expanded':
            setState(() => _expanded = event.value == true);
        }
      },
    );
  }
}

/// A circular avatar (initials or photo) that opens a native menu.
///
/// ```dart
/// GlassAvatarButton(
///   initials: 'RP',
///   items: const [
///     NativeItem.symbol('Profile', 'person'),
///     NativeItem.symbol('Sign Out', 'rectangle.portrait.and.arrow.right',
///         role: NativeItemRole.destructive),
///   ],
///   onSelected: (id) => debugPrint(id),
/// )
/// ```
class GlassAvatarButton extends StatelessWidget {
  /// Creates an avatar menu button.
  const GlassAvatarButton({
    super.key,
    required this.items,
    required this.onSelected,
    this.initials,
    this.image,
    this.size = 40,
    this.style,
    this.fallback,
  });

  /// Menu entries (roles and nested `children` supported).
  final List<NativeItem> items;

  /// Called with the id of the chosen entry (`NativeItem.id`, or its title).
  final ValueChanged<String> onSelected;

  /// Initials shown on a tinted gradient when there is no [image].
  final String? initials;

  /// Profile photo (`NativeImage.asset` or `.bytes`).
  final NativeImage? image;

  /// Diameter of the avatar.
  final double size;

  /// Appearance. `tintColor` colors the gradient.
  final NativeStyle? style;

  /// Shown on platforms other than iOS, e.g. a `CircleAvatar`.
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    return GlassyView(
      id: 'glassy-avatar-button',
      width: size,
      height: size,
      style: style,
      fallback: fallback,
      config:
          NativeComponentConfig(title: initials, image: image, items: items),
      onEvent: (event) {
        if (event.name == 'select') onSelected(event.value as String);
      },
    );
  }
}

/// An artwork tile with a glass badge, e.g. a video or album cover.
///
/// ```dart
/// GlassImageButton(
///   image: const NativeImage.asset('assets/cover.jpg'),
///   onPressed: play,
/// )
/// ```
class GlassImageButton extends StatelessWidget {
  /// Creates an image button.
  const GlassImageButton({
    super.key,
    required this.image,
    required this.onPressed,
    this.badge = 'play.fill',
    this.semanticLabel,
    this.width = 160,
    this.height = 160,
    this.cornerRadius = 18,
    this.style,
    this.fallback,
  });

  /// Artwork (`NativeImage.asset` / `.bytes`; a symbol draws a gradient tile).
  final NativeImage image;

  /// Called when the tile is tapped.
  final VoidCallback onPressed;

  /// SF Symbol of the glass badge; `null` hides it.
  final String? badge;

  /// VoiceOver label.
  final String? semanticLabel;

  /// Width of the tile.
  final double width;

  /// Height of the tile.
  final double height;

  /// Corner radius of the tile.
  final double cornerRadius;

  /// Appearance. Tint and color scheme default to the app's [Theme].
  final NativeStyle? style;

  /// Shown on platforms other than iOS.
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    return GlassyView(
      id: 'glassy-image-button',
      width: width,
      height: height,
      style:
          (style ?? const NativeStyle()).copyWith(cornerRadius: cornerRadius),
      fallback: fallback,
      config: NativeComponentConfig(
        title: semanticLabel,
        image: image,
        extra: {'badge': badge ?? ''},
      ),
      onEvent: (event) {
        if (event.name == 'tap') onPressed();
      },
    );
  }
}
