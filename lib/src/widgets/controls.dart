import 'package:flutter/material.dart';

import '../config.dart';
import 'glassy_view.dart';

/// A native segmented control. Falls back to a Material `SegmentedButton`.
///
/// ```dart
/// GlassSegmentedControl(
///   items: const [NativeItem(title: 'Day'), NativeItem(title: 'Week')],
///   selectedIndex: range,
///   onChanged: (i) => setState(() => range = i),
/// )
/// ```
class GlassSegmentedControl extends StatelessWidget {
  /// Creates a segmented control.
  const GlassSegmentedControl({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    this.width,
    this.height = 40,
    this.style,
    this.fallback,
  });

  /// Segments: titles and/or SF Symbols.
  final List<NativeItem> items;

  /// Index of the selected segment.
  final int selectedIndex;

  /// Called with the index of the chosen segment.
  final ValueChanged<int> onChanged;

  /// Width of the native view; defaults to the available width.
  final double? width;

  /// Height of the native view.
  final double height;

  /// Appearance. Tint and color scheme default to the app's [Theme].
  final NativeStyle? style;

  /// Shown on platforms other than iOS. Defaults to a `SegmentedButton`.
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    return GlassyView(
      id: 'glassy-segmented-control',
      width: width,
      height: height,
      style: style,
      fallback: fallback ??
          SegmentedButton<int>(
            showSelectedIcon: false,
            segments: [
              for (var i = 0; i < items.length; i++)
                ButtonSegment(value: i, label: Text(items[i].title)),
            ],
            selected: {selectedIndex},
            onSelectionChanged: (selection) => onChanged(selection.first),
          ),
      config: NativeComponentConfig(
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

/// A native switch, optionally with a [label] (the row then fills the width).
/// Falls back to a Material `Switch` / `SwitchListTile`.
///
/// ```dart
/// GlassSwitch(
///   label: 'Notifications',
///   value: enabled,
///   onChanged: (v) => setState(() => enabled = v),
/// )
/// ```
class GlassSwitch extends StatelessWidget {
  /// Creates a switch.
  const GlassSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.width,
    this.height = 44,
    this.style,
    this.fallback,
  });

  /// Whether the switch is on.
  final bool value;

  /// Called with the new value.
  final ValueChanged<bool> onChanged;

  /// Text in front of the switch.
  final String? label;

  /// Width of the native view; defaults to 64 without a label, otherwise the
  /// available width.
  final double? width;

  /// Height of the native view.
  final double height;

  /// Appearance. Tint and color scheme default to the app's [Theme].
  final NativeStyle? style;

  /// Shown on platforms other than iOS. Defaults to a Material switch.
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    return GlassyView(
      id: 'glassy-switch',
      width: width ?? (label == null ? 64 : null),
      height: height,
      style: style,
      fallback: fallback ??
          (label == null
              ? Switch(value: value, onChanged: onChanged)
              : SwitchListTile(
                  title: Text(label!),
                  value: value,
                  onChanged: onChanged,
                  contentPadding: EdgeInsets.zero,
                )),
      config: NativeComponentConfig(title: label, value: value),
      onEvent: (event) {
        if (event.name == 'change') onChanged(event.value == true);
      },
    );
  }
}

/// Glass minus / value / plus stepper.
///
/// ```dart
/// GlassStepper(
///   label: 'Guests',
///   value: guests,
///   min: 1,
///   max: 10,
///   onChanged: (v) => setState(() => guests = v),
/// )
/// ```
class GlassStepper extends StatelessWidget {
  /// Creates a stepper.
  const GlassStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 100,
    this.step = 1,
    this.label,
    this.width,
    this.height = 52,
    this.style,
    this.fallback,
  });

  /// Current value.
  final double value;

  /// Called with the new value.
  final ValueChanged<double> onChanged;

  /// Lowest value.
  final double min;

  /// Highest value.
  final double max;

  /// Amount added or removed per tap.
  final double step;

  /// Text in front of the stepper (the row then fills the width).
  final String? label;

  /// Width of the native view; defaults to 180 without a label, otherwise the
  /// available width.
  final double? width;

  /// Height of the native view.
  final double height;

  /// Appearance. Tint and color scheme default to the app's [Theme].
  final NativeStyle? style;

  /// Shown on platforms other than iOS. Defaults to Material icon buttons.
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    final number =
        value == value.roundToDouble() ? '${value.toInt()}' : '$value';
    return GlassyView(
      id: 'glassy-stepper',
      width: width ?? (label == null ? 180 : null),
      height: height,
      style: style,
      fallback: fallback ??
          Row(
            mainAxisSize: label == null ? MainAxisSize.min : MainAxisSize.max,
            children: [
              if (label != null) ...[Text(label!), const Spacer()],
              IconButton.outlined(
                icon: const Icon(Icons.remove),
                onPressed: value > min
                    ? () => onChanged((value - step).clamp(min, max))
                    : null,
              ),
              SizedBox(
                  width: 48, child: Text(number, textAlign: TextAlign.center)),
              IconButton.outlined(
                icon: const Icon(Icons.add),
                onPressed: value < max
                    ? () => onChanged((value + step).clamp(min, max))
                    : null,
              ),
            ],
          ),
      config: NativeComponentConfig(
        title: label,
        value: value,
        min: min,
        max: max,
        step: step,
      ),
      onEvent: (event) {
        if (event.name == 'change') onChanged((event.value as num).toDouble());
      },
    );
  }
}

/// A native slider with optional SF Symbols at both ends.
/// Falls back to a Material `Slider`.
///
/// ```dart
/// GlassSlider(
///   value: volume,
///   minIcon: 'speaker.fill',
///   maxIcon: 'speaker.wave.3.fill',
///   onChanged: (v) => setState(() => volume = v),
/// )
/// ```
class GlassSlider extends StatelessWidget {
  /// Creates a slider.
  const GlassSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.onChangeEnd,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.minIcon,
    this.maxIcon,
    this.width,
    this.height = 44,
    this.style,
    this.fallback,
  });

  /// Current value.
  final double value;

  /// Called continuously while dragging.
  final ValueChanged<double> onChanged;

  /// Called when the user lets go.
  final ValueChanged<double>? onChangeEnd;

  /// Lowest value.
  final double min;

  /// Highest value.
  final double max;

  /// Number of discrete steps; `null` is continuous.
  final int? divisions;

  /// SF Symbol at the low end.
  final String? minIcon;

  /// SF Symbol at the high end.
  final String? maxIcon;

  /// Width of the native view; defaults to the available width.
  final double? width;

  /// Height of the native view.
  final double height;

  /// Appearance. Tint and color scheme default to the app's [Theme].
  final NativeStyle? style;

  /// Shown on platforms other than iOS. Defaults to a Material `Slider`.
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    return GlassyView(
      id: 'glassy-slider',
      gestureRecognizers: horizontalDrags,
      width: width,
      height: height,
      style: style,
      fallback: fallback ??
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
            onChangeEnd: onChangeEnd,
          ),
      config: NativeComponentConfig(
        value: value,
        min: min,
        max: max,
        step: divisions == null ? null : (max - min) / divisions!,
        extra: {
          if (minIcon != null) 'minImage': minIcon,
          if (maxIcon != null) 'maxImage': maxIcon,
        },
      ),
      onEvent: (event) {
        final number = (event.value as num?)?.toDouble();
        if (number == null) return;
        if (event.name == 'change') onChanged(number);
        if (event.name == 'changeEnd') onChangeEnd?.call(number);
      },
    );
  }
}

/// Page dots in a glass capsule; the current page stretches into a pill.
///
/// ```dart
/// GlassPageIndicator(
///   count: 4,
///   currentIndex: page,
///   onChanged: (i) => controller.animateToPage(i, ...),
/// )
/// ```
class GlassPageIndicator extends StatelessWidget {
  /// Creates a page indicator.
  const GlassPageIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
    this.onChanged,
    this.width = 200,
    this.height = 44,
    this.style,
    this.fallback,
  });

  /// Number of pages.
  final int count;

  /// Index of the current page.
  final int currentIndex;

  /// Called with the index of a tapped dot.
  final ValueChanged<int>? onChanged;

  /// Width of the native view.
  final double width;

  /// Height of the native view.
  final double height;

  /// Appearance. `tintColor` colors the current page.
  final NativeStyle? style;

  /// Shown on platforms other than iOS. Defaults to Material dots.
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return GlassyView(
      id: 'glassy-page-indicator',
      width: width,
      height: height,
      style: style,
      fallback: fallback ??
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < count; i++)
                GestureDetector(
                  onTap: () => onChanged?.call(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.all(4),
                    width: i == currentIndex ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == currentIndex
                          ? color
                          : color.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
            ],
          ),
      config:
          NativeComponentConfig(value: currentIndex, extra: {'count': count}),
      onEvent: (event) {
        if (event.name == 'change') {
          onChanged?.call((event.value as num).toInt());
        }
      },
    );
  }
}

/// A round checkbox with an animated checkmark, optionally with a [label].
/// Falls back to a Material `Checkbox` / `CheckboxListTile`.
///
/// ```dart
/// GlassCheckbox(
///   label: 'Remember me',
///   value: remember,
///   onChanged: (v) => setState(() => remember = v),
/// )
/// ```
class GlassCheckbox extends StatelessWidget {
  /// Creates a checkbox.
  const GlassCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.width,
    this.height = 44,
    this.style,
    this.fallback,
  });

  /// Whether the box is checked.
  final bool value;

  /// Called with the new value.
  final ValueChanged<bool> onChanged;

  /// Text after the checkbox.
  final String? label;

  /// Width of the native view; defaults to 44 without a label, otherwise the
  /// available width.
  final double? width;

  /// Height of the native view.
  final double height;

  /// Appearance. Tint and color scheme default to the app's [Theme].
  final NativeStyle? style;

  /// Shown on platforms other than iOS. Defaults to a Material checkbox.
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    return GlassyView(
      id: 'glassy-checkbox',
      width: width ?? (label == null ? 44 : null),
      height: height,
      style: style,
      fallback: fallback ??
          (label == null
              ? Checkbox(value: value, onChanged: (v) => onChanged(v ?? false))
              : CheckboxListTile(
                  title: Text(label!),
                  value: value,
                  onChanged: (v) => onChanged(v ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                )),
      config: NativeComponentConfig(title: label, value: value),
      onEvent: (event) {
        if (event.name == 'change') onChanged(event.value == true);
      },
    );
  }
}
