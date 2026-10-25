import 'package:flutter/material.dart';

import '../config.dart';
import 'glassy_view.dart';

/// Shape of a [GlassProgressIndicator].
enum GlassProgressStyle {
  /// A horizontal bar.
  linear,

  /// A ring with the percentage in the middle.
  circular,
}

/// A native progress bar or ring. Without a [value] it is a spinner.
/// Falls back to Material progress indicators.
///
/// ```dart
/// GlassProgressIndicator(value: 0.4, label: 'Uploading')
/// GlassProgressIndicator(value: 0.4, style: GlassProgressStyle.circular)
/// const GlassProgressIndicator() // spinner
/// ```
class GlassProgressIndicator extends StatelessWidget {
  /// Creates a progress indicator.
  const GlassProgressIndicator({
    super.key,
    this.value,
    this.style = GlassProgressStyle.linear,
    this.label,
    this.width,
    this.height,
    this.nativeStyle,
    this.fallback,
  });

  /// Progress from 0 to 1; `null` shows a spinner.
  final double? value;

  /// Bar or ring.
  final GlassProgressStyle style;

  /// Text above a linear bar.
  final String? label;

  /// Width of the native view; defaults to the available width for a bar, 64
  /// for a ring or spinner.
  final double? width;

  /// Height of the native view; defaults to fit the style.
  final double? height;

  /// Appearance. `tintColor` colors the progress.
  final NativeStyle? nativeStyle;

  /// Shown on platforms other than iOS. Defaults to a Material indicator.
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    final round = value == null || style == GlassProgressStyle.circular;
    return GlassyView(
      id: 'glassy-progress',
      width: width ?? (round ? 64 : null),
      height: height ?? (round ? 64 : (label == null ? 24 : 48)),
      style: nativeStyle,
      fallback: fallback ??
          (round
              ? Center(child: CircularProgressIndicator(value: value))
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (label != null) Text(label!),
                    LinearProgressIndicator(value: value),
                  ],
                )),
      config: NativeComponentConfig(
        title: label,
        value: value,
        extra: {'style': style.name},
      ),
    );
  }
}

/// A glass play / pause button with an animated symbol swap.
/// Falls back to a Material `IconButton`.
///
/// ```dart
/// GlassPlayPauseButton(
///   isPlaying: playing,
///   onChanged: (v) => setState(() => playing = v),
/// )
/// ```
class GlassPlayPauseButton extends StatelessWidget {
  /// Creates a play / pause button.
  const GlassPlayPauseButton({
    super.key,
    required this.isPlaying,
    required this.onChanged,
    this.size = 64,
    this.style,
    this.fallback,
  });

  /// Whether playback is running.
  final bool isPlaying;

  /// Called with the new playing state.
  final ValueChanged<bool> onChanged;

  /// Diameter of the button.
  final double size;

  /// Appearance. Tint and color scheme default to the app's [Theme].
  final NativeStyle? style;

  /// Shown on platforms other than iOS. Defaults to an `IconButton`.
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    return GlassyView(
      id: 'glassy-play-pause',
      width: size,
      height: size,
      style: style,
      fallback: fallback ??
          IconButton.filledTonal(
            iconSize: size * 0.45,
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: () => onChanged(!isPlaying),
          ),
      config: NativeComponentConfig(value: isPlaying),
      onEvent: (event) {
        if (event.name == 'change') onChanged(event.value == true);
      },
    );
  }
}

/// Previous / play-pause / next controls in a glass capsule.
/// Falls back to Material icon buttons.
///
/// ```dart
/// GlassMediaControls(
///   isPlaying: playing,
///   onPlayPause: (v) => setState(() => playing = v),
///   onPrevious: player.previous,
///   onNext: player.next,
/// )
/// ```
class GlassMediaControls extends StatelessWidget {
  /// Creates media controls.
  const GlassMediaControls({
    super.key,
    required this.isPlaying,
    required this.onPlayPause,
    this.onPrevious,
    this.onNext,
    this.width = 260,
    this.height = 72,
    this.style,
    this.fallback,
  });

  /// Whether playback is running.
  final bool isPlaying;

  /// Called with the new playing state.
  final ValueChanged<bool> onPlayPause;

  /// Called when "previous" is tapped.
  final VoidCallback? onPrevious;

  /// Called when "next" is tapped.
  final VoidCallback? onNext;

  /// Width of the native view.
  final double width;

  /// Height of the native view.
  final double height;

  /// Appearance. Tint and color scheme default to the app's [Theme].
  final NativeStyle? style;

  /// Shown on platforms other than iOS. Defaults to Material icon buttons.
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    return GlassyView(
      id: 'glassy-media-controls',
      width: width,
      height: height,
      style: style,
      fallback: fallback ??
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                  icon: const Icon(Icons.skip_previous), onPressed: onPrevious),
              IconButton.filledTonal(
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: () => onPlayPause(!isPlaying),
              ),
              IconButton(icon: const Icon(Icons.skip_next), onPressed: onNext),
            ],
          ),
      config: NativeComponentConfig(value: isPlaying),
      onEvent: (event) {
        switch (event.name) {
          case 'change':
            onPlayPause(event.value == true);
          case 'previous':
            onPrevious?.call();
          case 'next':
            onNext?.call();
        }
      },
    );
  }
}
