import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'config.dart';

const _channel = MethodChannel('glassy_ui_ios/system');

bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;

String _idOf(NativeItem item) => item.id ?? item.title;

/// The app's light/dark mode, so native UI matches it rather than the system.
String? _colorScheme(BuildContext? context) => context == null
    ? null
    : Theme.of(context).brightness == Brightness.dark
        ? 'dark'
        : 'light';

/// Native `UIAlertController` alerts, action sheets and prompts.
///
/// Pass a [BuildContext] to get the Material equivalent on other platforms;
/// without one these return `null` there.
abstract final class NativeDialog {
  /// Shows a native alert and returns the id of the tapped action
  /// (`NativeItem.id`, or its title).
  ///
  /// [actions] default to a single "OK". Roles map to alert action styles
  /// (`destructive` is red, `cancel` is bold).
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
    BuildContext? context,
  }) async {
    if (_isIOS) return _show('alert', title, message, actions, context);
    if (context == null) return null;
    final buttons = actions.isEmpty ? const [NativeItem(title: 'OK')] : actions;
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: title == null ? null : Text(title),
        content: message == null ? null : Text(message),
        actions: [
          for (final action in buttons)
            TextButton(
              onPressed: action.enabled
                  ? () => Navigator.pop(context, _idOf(action))
                  : null,
              style: action.role == NativeItemRole.destructive
                  ? TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error)
                  : null,
              child: Text(action.title),
            ),
        ],
      ),
    );
  }

  /// Shows a native action sheet. See [alert] for [actions] and the result.
  /// Falls back to a Material bottom sheet when given a [context].
  static Future<String?> actionSheet({
    String? title,
    String? message,
    List<NativeItem> actions = const [],
    BuildContext? context,
  }) async {
    if (_isIOS) {
      return _show('actionSheet', title, message, actions, context);
    }
    if (context == null) return null;
    return NativeSheet._material(context, title, message, actions);
  }

  /// Shows an alert with a text field and returns the entered text, or
  /// `null` when cancelled.
  ///
  /// ```dart
  /// final name = await NativeDialog.prompt(
  ///   title: 'Rename',
  ///   placeholder: 'Name',
  ///   initialValue: file.name,
  /// );
  /// ```
  static Future<String?> prompt({
    String? title,
    String? message,
    String? placeholder,
    String? initialValue,
    bool obscureText = false,
    String confirmLabel = 'OK',
    String cancelLabel = 'Cancel',
    BuildContext? context,
  }) async {
    if (_isIOS) {
      return _channel.invokeMethod<String>('showPrompt', {
        'colorScheme': _colorScheme(context),
        'title': title,
        'message': message,
        'placeholder': placeholder,
        'value': initialValue,
        'secure': obscureText,
        'confirm': confirmLabel,
        'cancel': cancelLabel,
      });
    }
    if (context == null) return null;
    final controller = TextEditingController(text: initialValue);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: title == null ? null : Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message != null) Text(message),
            TextField(
              controller: controller,
              autofocus: true,
              obscureText: obscureText,
              decoration: InputDecoration(hintText: placeholder),
              onSubmitted: (text) => Navigator.pop(context, text),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(cancelLabel)),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  static Future<String?> _show(
    String style,
    String? title,
    String? message,
    List<NativeItem> actions,
    BuildContext? context,
  ) =>
      _channel.invokeMethod<String>('showAlert', {
        'style': style,
        'colorScheme': _colorScheme(context),
        'title': title,
        'message': message,
        'actions': actions.map((action) => action.toMap()).toList(),
      });
}

/// Height a [NativeSheet] can rest at.
enum NativeSheetDetent {
  /// About half the screen.
  medium,

  /// Full height.
  large,
}

/// A native sheet listing options.
abstract final class NativeSheet {
  /// Presents a sheet with a [title], an optional [message] and [items]
  /// (icon, title, subtitle, role). Returns the id of the tapped item, or
  /// `null` when the sheet is dismissed.
  ///
  /// Falls back to a Material bottom sheet when given a [context].
  ///
  /// ```dart
  /// final id = await NativeSheet.show(
  ///   title: 'Share to',
  ///   items: const [
  ///     NativeItem.symbol('Messages', 'message.fill'),
  ///     NativeItem.symbol('Mail', 'envelope.fill'),
  ///   ],
  /// );
  /// ```
  static Future<String?> show({
    String? title,
    String? message,
    required List<NativeItem> items,
    List<NativeSheetDetent> detents = const [
      NativeSheetDetent.medium,
      NativeSheetDetent.large
    ],
    Color? tintColor,
    BuildContext? context,
  }) async {
    if (_isIOS) {
      return _channel.invokeMethod<String>('showSheet', {
        'colorScheme': _colorScheme(context),
        'title': title,
        'message': message,
        'items': items.map((item) => item.toMap()).toList(),
        'detents': detents.map((detent) => detent.name).toList(),
        'tintColor': (tintColor ??
                (context == null
                    ? null
                    : Theme.of(context).colorScheme.primary))
            ?.toARGB32(),
      });
    }
    if (context == null) return null;
    return _material(context, title, message, items);
  }

  static Future<String?> _material(
    BuildContext context,
    String? title,
    String? message,
    List<NativeItem> items,
  ) =>
      showModalBottomSheet<String>(
        context: context,
        showDragHandle: true,
        builder: (context) => SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              if (title != null)
                ListTile(
                    title: Text(title,
                        style: Theme.of(context).textTheme.titleMedium)),
              if (message != null) ListTile(subtitle: Text(message)),
              for (final item in items)
                ListTile(
                  enabled: item.enabled,
                  title: Text(
                    item.title,
                    style: item.role == NativeItemRole.destructive
                        ? TextStyle(color: Theme.of(context).colorScheme.error)
                        : null,
                  ),
                  subtitle: item.subtitle == null ? null : Text(item.subtitle!),
                  onTap: () => Navigator.pop(context, _idOf(item)),
                ),
            ],
          ),
        ),
      );
}

/// Where a [NativeToast] appears.
enum NativeToastPosition {
  /// Below the status bar.
  top,

  /// Above the home indicator.
  bottom,
}

/// A glass capsule toast over the whole app. Touches pass through it.
abstract final class NativeToast {
  /// Shows [message] with an optional SF Symbol [icon] for [duration].
  /// Completes when the toast is gone.
  ///
  /// Falls back to a `SnackBar` when given a [context].
  ///
  /// ```dart
  /// NativeToast.show('Copied to clipboard', icon: 'doc.on.doc.fill');
  /// ```
  static Future<void> show(
    String message, {
    String? icon = 'checkmark.circle.fill',
    NativeToastPosition position = NativeToastPosition.top,
    Duration duration = const Duration(milliseconds: 2200),
    Color? tintColor,
    BuildContext? context,
  }) async {
    if (_isIOS) {
      await _channel.invokeMethod<void>('showToast', {
        'colorScheme': _colorScheme(context),
        'message': message,
        'symbol': icon,
        'position': position.name,
        'duration': duration.inMilliseconds / 1000,
        'tintColor': tintColor?.toARGB32(),
      });
      return;
    }
    if (context == null) return;
    await ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message), duration: duration))
        .closed;
  }
}

/// The native share sheet (`UIActivityViewController`).
abstract final class NativeShare {
  /// Shares [text] and/or [url]. Returns whether the user completed an
  /// action; `false` on platforms other than iOS.
  ///
  /// ```dart
  /// NativeShare.share(text: 'Check this out', url: 'https://pub.dev');
  /// ```
  static Future<bool> share({String? text, String? url}) async {
    if (!_isIOS) return false;
    return await _channel
            .invokeMethod<bool>('share', {'text': text, 'url': url}) ??
        false;
  }
}
