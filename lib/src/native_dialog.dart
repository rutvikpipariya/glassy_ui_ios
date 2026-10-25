import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'config.dart';

/// Native `UIAlertController` dialogs, presented without a native view.
abstract final class NativeDialog {
  static const _channel = MethodChannel('glassy_ui_ios/system');

  /// Shows a native alert and returns the id of the tapped action
  /// (`NativeItem.id`, or its title).
  ///
  /// [actions] default to a single "OK". Roles map to alert action styles
  /// (`destructive` is red, `cancel` is bold). Returns `null` on platforms
  /// other than iOS.
  ///
  /// ```dart
  /// final choice = await NativeDialog.alert(
  ///   title: 'Delete photo?',
  ///   message: 'This cannot be undone.',
  ///   actions: const [
  ///     NativeItem(title: 'Delete', role: NativeItemRole.destructive),
  ///     NativeItem(title: 'Cancel', role: NativeItemRole.cancel),
  ///   ],
  /// );
  /// ```
  static Future<String?> alert({
    String? title,
    String? message,
    List<NativeItem> actions = const [],
  }) =>
      _show('alert', title, message, actions);

  /// Shows a native action sheet. See [alert] for [actions] and the result.
  static Future<String?> actionSheet({
    String? title,
    String? message,
    List<NativeItem> actions = const [],
  }) =>
      _show('actionSheet', title, message, actions);

  static Future<String?> _show(
    String style,
    String? title,
    String? message,
    List<NativeItem> actions,
  ) async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return null;
    return _channel.invokeMethod<String>('showAlert', {
      'style': style,
      'title': title,
      'message': message,
      'actions': actions.map((action) => action.toMap()).toList(),
    });
  }
}
