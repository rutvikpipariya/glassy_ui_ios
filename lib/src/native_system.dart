import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Device information reported by the plugin.
@immutable
class NativeSystemInfo {
  /// Creates device information.
  const NativeSystemInfo({
    required this.systemName,
    required this.systemVersion,
    required this.model,
    required this.liquidGlass,
    required this.components,
  });

  /// Operating system name, e.g. `iOS`.
  final String systemName;

  /// Operating system version, e.g. `26.0`.
  final String systemVersion;

  /// Device model, e.g. `iPhone`.
  final String model;

  /// `true` on iOS 26+, where components render with Liquid Glass.
  final bool liquidGlass;

  /// Ids of all registered components, including custom ones.
  final List<String> components;
}

/// Haptic feedback styles.
enum NativeHaptic {
  /// Light impact.
  light,

  /// Medium impact.
  medium,

  /// Heavy impact.
  heavy,

  /// Selection change.
  selection,

  /// Success notification.
  success,

  /// Warning notification.
  warning,

  /// Error notification.
  error,
}

/// System-level helpers of the plugin.
abstract final class NativeSystem {
  static const _channel = MethodChannel('glassy_ui_ios/system');

  /// Returns `null` on platforms other than iOS.
  static Future<NativeSystemInfo?> info() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return null;
    final map = await _channel.invokeMapMethod<String, Object?>('getInfo');
    if (map == null) return null;
    return NativeSystemInfo(
      systemName: map['systemName'] as String? ?? 'iOS',
      systemVersion: map['systemVersion'] as String? ?? '',
      model: map['model'] as String? ?? '',
      liquidGlass: map['liquidGlass'] as bool? ?? false,
      components: (map['components'] as List?)?.cast<String>() ?? const [],
    );
  }

  /// Plays native haptic feedback.
  static Future<void> haptic([NativeHaptic style = NativeHaptic.light]) async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return;
    await _channel.invokeMethod<void>('haptic', style.name);
  }
}
