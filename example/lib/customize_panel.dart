import 'package:flutter/material.dart';
import 'package:glassy_ui_ios/glassy_ui_ios.dart';

/// Background choices offered by the customize panel.
enum BackgroundChoice { backdrop, system, solid, gradient }

/// Editable subset of [NativeComponentConfig] used by the example app.
class Customization {
  const Customization({
    this.title = '',
    this.symbol = '',
    this.tint,
    this.background = BackgroundChoice.backdrop,
    this.cornerRadius,
    this.glass = NativeGlass.regular,
    this.colorScheme,
    this.fontDesign,
  });

  final String title;
  final String symbol;
  final Color? tint;
  final BackgroundChoice background;
  final double? cornerRadius;
  final NativeGlass glass;
  final NativeColorScheme? colorScheme;
  final NativeFontDesign? fontDesign;

  Customization copyWith({
    String? title,
    String? symbol,
    Color? Function()? tint,
    BackgroundChoice? background,
    double? Function()? cornerRadius,
    NativeGlass? glass,
    NativeColorScheme? Function()? colorScheme,
    NativeFontDesign? Function()? fontDesign,
  }) {
    return Customization(
      title: title ?? this.title,
      symbol: symbol ?? this.symbol,
      tint: tint != null ? tint() : this.tint,
      background: background ?? this.background,
      cornerRadius: cornerRadius != null ? cornerRadius() : this.cornerRadius,
      glass: glass ?? this.glass,
      colorScheme: colorScheme != null ? colorScheme() : this.colorScheme,
      fontDesign: fontDesign != null ? fontDesign() : this.fontDesign,
    );
  }

  NativeComponentConfig toConfig() {
    return NativeComponentConfig(
      title: title.isEmpty ? null : title,
      image: symbol.isEmpty ? null : NativeImage.symbol(symbol),
      style: NativeStyle(
        tintColor: tint,
        cornerRadius: cornerRadius,
        glass: glass,
        colorScheme: colorScheme,
        fontDesign: fontDesign,
        showBackdrop: background == BackgroundChoice.backdrop,
        backgroundColor: background == BackgroundChoice.solid
            ? const Color(0xFF0F766E)
            : null,
        backgroundGradient: background == BackgroundChoice.gradient
            ? const [Color(0xFF0EA5E9), Color(0xFF6366F1), Color(0xFFEC4899)]
            : null,
      ),
    );
  }
}

/// Bottom sheet that edits a [Customization] live.
class CustomizePanel extends StatefulWidget {
  const CustomizePanel({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final Customization value;
  final ValueChanged<Customization> onChanged;

  @override
  State<CustomizePanel> createState() => _CustomizePanelState();
}

class _CustomizePanelState extends State<CustomizePanel> {
  static const _tints = <Color?>[
    null,
    Colors.blue,
    Colors.teal,
    Colors.orange,
    Colors.pink,
    Colors.purple,
    Colors.red,
  ];

  late Customization _value = widget.value;

  void _set(Customization value) {
    setState(() => _value = value);
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        children: [
          Text('Customize from Dart', style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Changes are sent to the native view live via NativeComponentConfig.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _value.title,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
            onChanged: (text) => _set(_value.copyWith(title: text)),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: _value.symbol,
            decoration: const InputDecoration(
              labelText: 'Image (SF Symbol name)',
              hintText: 'e.g. star.fill',
              border: OutlineInputBorder(),
            ),
            onChanged: (text) => _set(_value.copyWith(symbol: text.trim())),
          ),
          _label('Tint color'),
          Wrap(
            spacing: 10,
            children: [
              for (final color in _tints)
                ChoiceChip(
                  label: color == null
                      ? const Text('Default')
                      : const SizedBox(width: 4),
                  avatar: color == null
                      ? null
                      : CircleAvatar(backgroundColor: color),
                  selected: _value.tint == color,
                  onSelected: (_) => _set(_value.copyWith(tint: () => color)),
                ),
            ],
          ),
          _label('Background'),
          SegmentedButton<BackgroundChoice>(
            segments: const [
              ButtonSegment(
                value: BackgroundChoice.backdrop,
                label: Text('Backdrop'),
              ),
              ButtonSegment(
                value: BackgroundChoice.system,
                label: Text('System'),
              ),
              ButtonSegment(
                value: BackgroundChoice.solid,
                label: Text('Solid'),
              ),
              ButtonSegment(
                value: BackgroundChoice.gradient,
                label: Text('Gradient'),
              ),
            ],
            selected: {_value.background},
            onSelectionChanged: (s) =>
                _set(_value.copyWith(background: s.first)),
          ),
          _label('Glass'),
          SegmentedButton<NativeGlass>(
            segments: [
              for (final glass in NativeGlass.values)
                ButtonSegment(value: glass, label: Text(glass.name)),
            ],
            selected: {_value.glass},
            onSelectionChanged: (s) => _set(_value.copyWith(glass: s.first)),
          ),
          _label('Corner radius: ${_value.cornerRadius?.round() ?? 'default'}'),
          Slider(
            value: _value.cornerRadius ?? 26,
            max: 60,
            onChanged: (v) => _set(_value.copyWith(cornerRadius: () => v)),
          ),
          _label('Appearance'),
          SegmentedButton<NativeColorScheme?>(
            segments: const [
              ButtonSegment(value: null, label: Text('System')),
              ButtonSegment(
                value: NativeColorScheme.light,
                label: Text('Light'),
              ),
              ButtonSegment(value: NativeColorScheme.dark, label: Text('Dark')),
            ],
            selected: {_value.colorScheme},
            onSelectionChanged: (s) =>
                _set(_value.copyWith(colorScheme: () => s.first)),
          ),
          _label('Font design'),
          SegmentedButton<NativeFontDesign?>(
            segments: const [
              ButtonSegment(value: null, label: Text('Default')),
              ButtonSegment(
                value: NativeFontDesign.rounded,
                label: Text('Rounded'),
              ),
              ButtonSegment(
                value: NativeFontDesign.serif,
                label: Text('Serif'),
              ),
              ButtonSegment(
                value: NativeFontDesign.monospaced,
                label: Text('Mono'),
              ),
            ],
            selected: {_value.fontDesign},
            onSelectionChanged: (s) =>
                _set(_value.copyWith(fontDesign: () => s.first)),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _set(const Customization()),
            icon: const Icon(Icons.restart_alt),
            label: const Text('Reset to defaults'),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(top: 18, bottom: 8),
    child: Text(text, style: Theme.of(context).textTheme.labelLarge),
  );
}
