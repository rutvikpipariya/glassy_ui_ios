import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../config.dart';
import '../native_component.dart';
import 'glassy_view.dart';

/// Commands for a [GlassTextField] or [GlassSearchBar].
class GlassTextFieldController {
  NativeComponentController? _native;
  final _fallback = TextEditingController();
  final _focus = FocusNode();

  /// Clears the text (and reports `''` through `onChanged`).
  Future<void> clear() async {
    _fallback.clear();
    await _native?.send('clear');
  }

  /// Shows the keyboard.
  Future<void> focus() async {
    _focus.requestFocus();
    await _native?.send('focus');
  }

  /// Hides the keyboard.
  Future<void> unfocus() async {
    _focus.unfocus();
    await _native?.send('unfocus');
  }

  /// Releases the fallback resources.
  void dispose() {
    _fallback.dispose();
    _focus.dispose();
  }
}

/// Keyboard shown by a [GlassTextField].
enum GlassKeyboardType {
  /// Regular text.
  text,

  /// Email address.
  email,

  /// Decimal number pad.
  number,

  /// Phone pad.
  phone,

  /// URL.
  url,
}

/// A native text field in a glass rounded rectangle: single line, secure
/// ([obscureText]) or [multiline]. Falls back to a Material `TextField`.
///
/// ```dart
/// GlassTextField(
///   placeholder: 'Email',
///   keyboardType: GlassKeyboardType.email,
///   onChanged: (text) => email = text,
///   onSubmitted: (_) => submit(),
/// )
/// ```
class GlassTextField extends StatefulWidget {
  /// Creates a text field.
  const GlassTextField({
    super.key,
    this.placeholder,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.controller,
    this.obscureText = false,
    this.multiline = false,
    this.keyboardType = GlassKeyboardType.text,
    this.width,
    this.height,
    this.style,
    this.fallback,
  });

  /// Hint shown while empty.
  final String? placeholder;

  /// Text when the field appears.
  final String? initialValue;

  /// Called on every edit.
  final ValueChanged<String>? onChanged;

  /// Called when the user presses return.
  final ValueChanged<String>? onSubmitted;

  /// Clears, focuses or unfocuses the field.
  final GlassTextFieldController? controller;

  /// Hide the text (passwords).
  final bool obscureText;

  /// Grow to several lines.
  final bool multiline;

  /// Keyboard layout.
  final GlassKeyboardType keyboardType;

  /// Width of the native view; defaults to the available width.
  final double? width;

  /// Height of the native view; defaults to 52 (120 when [multiline]).
  final double? height;

  /// Appearance. `cornerRadius` shapes the glass.
  final NativeStyle? style;

  /// Shown on platforms other than iOS. Defaults to a Material `TextField`.
  final Widget? fallback;

  @override
  State<GlassTextField> createState() => _GlassTextFieldState();
}

class _GlassTextFieldState extends State<GlassTextField> {
  late final _ownController =
      widget.controller == null ? GlassTextFieldController() : null;

  GlassTextFieldController get _controller =>
      widget.controller ?? _ownController!;

  @override
  void initState() {
    super.initState();
    _controller._fallback.text = widget.initialValue ?? '';
  }

  @override
  void dispose() {
    _ownController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassyView(
      id: 'glassy-text-field',
      gestureRecognizers: widget.multiline ? allGestures : const {},
      width: widget.width,
      height: widget.height ?? (widget.multiline ? 120 : 52),
      style: widget.style,
      fallback: widget.fallback ??
          TextField(
            controller: _controller._fallback,
            focusNode: _controller._focus,
            obscureText: widget.obscureText,
            maxLines: widget.multiline ? null : 1,
            minLines: widget.multiline ? 3 : null,
            keyboardType: switch (widget.keyboardType) {
              GlassKeyboardType.email => TextInputType.emailAddress,
              GlassKeyboardType.number =>
                const TextInputType.numberWithOptions(decimal: true),
              GlassKeyboardType.phone => TextInputType.phone,
              GlassKeyboardType.url => TextInputType.url,
              GlassKeyboardType.text =>
                widget.multiline ? TextInputType.multiline : TextInputType.text,
            },
            decoration: InputDecoration(
              hintText: widget.placeholder,
              border: const OutlineInputBorder(),
            ),
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
          ),
      config: NativeComponentConfig(
        placeholder: widget.placeholder,
        value: widget.initialValue,
        extra: {
          'secure': widget.obscureText,
          'multiline': widget.multiline,
          'keyboard': widget.keyboardType.name,
        },
      ),
      onCreated: (native) => _controller._native = native,
      onEvent: (event) {
        final text = event.value as String? ?? '';
        if (event.name == 'change') widget.onChanged?.call(text);
        if (event.name == 'submit') widget.onSubmitted?.call(text);
      },
    );
  }
}

/// A glass search capsule with a clear button.
/// Falls back to a Material `SearchBar`.
///
/// ```dart
/// GlassSearchBar(
///   placeholder: 'Search photos',
///   onChanged: (query) => setState(() => this.query = query),
/// )
/// ```
class GlassSearchBar extends StatefulWidget {
  /// Creates a search bar.
  const GlassSearchBar({
    super.key,
    this.placeholder = 'Search',
    this.onChanged,
    this.onSubmitted,
    this.controller,
    this.width,
    this.height = 50,
    this.style,
    this.fallback,
  });

  /// Hint shown while empty.
  final String placeholder;

  /// Called on every edit (and with `''` when cleared).
  final ValueChanged<String>? onChanged;

  /// Called when the user presses search.
  final ValueChanged<String>? onSubmitted;

  /// Clears, focuses or unfocuses the field.
  final GlassTextFieldController? controller;

  /// Width of the native view; defaults to the available width.
  final double? width;

  /// Height of the native view.
  final double height;

  /// Appearance. Tint and color scheme default to the app's [Theme].
  final NativeStyle? style;

  /// Shown on platforms other than iOS. Defaults to a Material `SearchBar`.
  final Widget? fallback;

  @override
  State<GlassSearchBar> createState() => _GlassSearchBarState();
}

class _GlassSearchBarState extends State<GlassSearchBar> {
  late final _ownController =
      widget.controller == null ? GlassTextFieldController() : null;

  GlassTextFieldController get _controller =>
      widget.controller ?? _ownController!;

  @override
  void dispose() {
    _ownController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassyView(
      id: 'glassy-search-bar',
      width: widget.width,
      height: widget.height,
      style: widget.style,
      fallback: widget.fallback ??
          SearchBar(
            controller: _controller._fallback,
            focusNode: _controller._focus,
            hintText: widget.placeholder,
            leading: const Icon(Icons.search),
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
          ),
      config: NativeComponentConfig(placeholder: widget.placeholder),
      onCreated: (native) => _controller._native = native,
      onEvent: (event) {
        final text = event.value as String? ?? '';
        if (event.name == 'change') widget.onChanged?.call(text);
        if (event.name == 'submit') widget.onSubmitted?.call(text);
      },
    );
  }
}

/// What a [GlassDatePicker] picks.
enum GlassDatePickerMode {
  /// Calendar date.
  date,

  /// Hour and minute.
  time,

  /// Both.
  dateAndTime,
}

/// How a [GlassDatePicker] looks.
enum GlassDatePickerStyle {
  /// A tappable field that opens a popover.
  compact,

  /// Spinning wheels.
  wheel,

  /// An inline calendar.
  graphical,
}

/// A native date and/or time picker. Falls back to a button that opens the
/// Material date or time picker.
///
/// ```dart
/// GlassDatePicker(
///   value: date,
///   style: GlassDatePickerStyle.graphical,
///   onChanged: (d) => setState(() => date = d),
/// )
/// ```
class GlassDatePicker extends StatelessWidget {
  /// Creates a date picker.
  const GlassDatePicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.mode = GlassDatePickerMode.date,
    this.style = GlassDatePickerStyle.compact,
    this.label,
    this.firstDate,
    this.lastDate,
    this.width,
    this.height,
    this.nativeStyle,
    this.fallback,
  });

  /// Selected date.
  final DateTime value;

  /// Called with the new date.
  final ValueChanged<DateTime> onChanged;

  /// Date, time or both.
  final GlassDatePickerMode mode;

  /// Compact field, wheels or calendar.
  final GlassDatePickerStyle style;

  /// Text in front of a compact picker.
  final String? label;

  /// Earliest selectable date.
  final DateTime? firstDate;

  /// Latest selectable date.
  final DateTime? lastDate;

  /// Width of the native view; defaults to the available width.
  final double? width;

  /// Height of the native view; defaults to fit [style].
  final double? height;

  /// Appearance. Tint and color scheme default to the app's [Theme].
  final NativeStyle? nativeStyle;

  /// Shown on platforms other than iOS. Defaults to a Material picker button.
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    return GlassyView(
      id: 'glassy-date-picker',
      gestureRecognizers:
          style == GlassDatePickerStyle.compact ? const {} : allGestures,
      width: width,
      height: height ??
          switch (style) {
            GlassDatePickerStyle.compact => 44,
            GlassDatePickerStyle.wheel => 216,
            GlassDatePickerStyle.graphical => 380,
          },
      style: nativeStyle,
      fallback: fallback ?? _MaterialDateButton(picker: this),
      config: NativeComponentConfig(
        title: label,
        value: value,
        extra: {
          'mode': mode.name,
          'style': style.name,
          if (firstDate != null) 'minDate': firstDate,
          if (lastDate != null) 'maxDate': lastDate,
        },
      ),
      onEvent: (event) {
        if (event.name != 'change' || event.value is! String) return;
        final date = DateTime.tryParse(event.value as String);
        if (date != null) onChanged(date.toLocal());
      },
    );
  }
}

class _MaterialDateButton extends StatelessWidget {
  const _MaterialDateButton({required this.picker});

  final GlassDatePicker picker;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final value = picker.value;
    final time = TimeOfDay.fromDateTime(value);
    final text = switch (picker.mode) {
      GlassDatePickerMode.date => localizations.formatMediumDate(value),
      GlassDatePickerMode.time => localizations.formatTimeOfDay(time),
      GlassDatePickerMode.dateAndTime =>
        '${localizations.formatMediumDate(value)} ${localizations.formatTimeOfDay(time)}',
    };

    Future<void> pick() async {
      var result = value;
      if (picker.mode != GlassDatePickerMode.time) {
        final date = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: picker.firstDate ?? DateTime(1900),
          lastDate: picker.lastDate ?? DateTime(2100),
        );
        if (date == null) return;
        result =
            DateTime(date.year, date.month, date.day, value.hour, value.minute);
      }
      if (picker.mode != GlassDatePickerMode.date && context.mounted) {
        final picked =
            await showTimePicker(context: context, initialTime: time);
        if (picked == null) return;
        result = DateTime(
            result.year, result.month, result.day, picked.hour, picked.minute);
      }
      picker.onChanged(result);
    }

    final button = OutlinedButton(onPressed: pick, child: Text(text));
    if (picker.label == null) return button;
    return Row(children: [Text(picker.label!), const Spacer(), button]);
  }
}

/// A native wheel picker. Falls back to a `CupertinoPicker`.
///
/// ```dart
/// GlassWheelPicker(
///   items: const [NativeItem(title: 'Small'), NativeItem(title: 'Large')],
///   selectedIndex: size,
///   onChanged: (i) => setState(() => size = i),
/// )
/// ```
class GlassWheelPicker extends StatelessWidget {
  /// Creates a wheel picker.
  const GlassWheelPicker({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    this.width,
    this.height = 180,
    this.style,
    this.fallback,
  });

  /// Options.
  final List<NativeItem> items;

  /// Index of the selected option.
  final int selectedIndex;

  /// Called with the index of the option the wheel settles on.
  final ValueChanged<int> onChanged;

  /// Width of the native view; defaults to the available width.
  final double? width;

  /// Height of the native view.
  final double height;

  /// Appearance. Tint and color scheme default to the app's [Theme].
  final NativeStyle? style;

  /// Shown on platforms other than iOS. Defaults to a `CupertinoPicker`.
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    return GlassyView(
      id: 'glassy-wheel-picker',
      gestureRecognizers: allGestures,
      width: width,
      height: height,
      style: style,
      fallback: fallback ??
          SizedBox(
            height: height,
            child: CupertinoPicker(
              itemExtent: 36,
              scrollController:
                  FixedExtentScrollController(initialItem: selectedIndex),
              onSelectedItemChanged: onChanged,
              children: [
                for (final item in items) Center(child: Text(item.title))
              ],
            ),
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

/// A native color well that opens the system color picker, optionally with a
/// [label]. iOS only: [fallback] defaults to nothing.
///
/// ```dart
/// GlassColorPicker(
///   label: 'Accent',
///   value: accent,
///   onChanged: (c) => setState(() => accent = c),
/// )
/// ```
class GlassColorPicker extends StatelessWidget {
  /// Creates a color picker.
  const GlassColorPicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.supportsOpacity = true,
    this.width,
    this.height = 44,
    this.style,
    this.fallback,
  });

  /// Selected color.
  final Color value;

  /// Called with the new color.
  final ValueChanged<Color> onChanged;

  /// Text in front of the color well (the row then fills the width).
  final String? label;

  /// Offer an opacity slider.
  final bool supportsOpacity;

  /// Width of the native view; defaults to 44 without a label, otherwise the
  /// available width.
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
      id: 'glassy-color-picker',
      width: width ?? (label == null ? 44 : null),
      height: height,
      style: style,
      fallback: fallback,
      config: NativeComponentConfig(
        title: label,
        value: value,
        extra: {'supportsOpacity': supportsOpacity},
      ),
      onEvent: (event) {
        if (event.name == 'change') {
          onChanged(Color((event.value as num).toInt()));
        }
      },
    );
  }
}
