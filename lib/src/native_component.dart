import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'component_type.dart';
import 'config.dart';

/// A callback delivered from the native component.
@immutable
class NativeEvent {
  NativeEvent(
      {required this.component, required this.name, this.value, DateTime? time})
      : time = time ?? DateTime.now();

  /// Component id that emitted the event.
  final String component;

  /// Event name, e.g. `change`, `select`, `tap`, `presented`.
  final String name;

  /// Payload: `null`, `bool`, `num`, `String`, `List` or `Map`.
  final Object? value;
  final DateTime time;

  @override
  String toString() => 'NativeEvent($component.$name: $value)';
}

/// Controls one embedded native component.
///
/// Obtain it from [NativeComponent.onCreated], which fires once the native
/// view exists. Calls after the widget is disposed are ignored.
class NativeComponentController {
  NativeComponentController._(this._channel);

  final MethodChannel _channel;
  final _events = StreamController<NativeEvent>.broadcast();
  bool _disposed = false;

  /// Every event emitted by the native component.
  Stream<NativeEvent> get events => _events.stream;

  /// Performs the component's primary action (present, toggle, next…).
  /// See [NativeComponentType.triggerLabel].
  Future<void> trigger([Object? arguments]) => send('trigger', arguments);

  /// Restores the component's initial state where supported.
  Future<void> reset() => send('reset');

  /// Sends a named command. Custom components receive it in `onNativeCommand`.
  Future<void> send(String name, [Object? arguments]) async {
    if (_disposed) return;
    await _channel.invokeMethod<void>('command', {
      'name': name,
      'arguments': encodeNativeValue(arguments),
    });
  }

  /// Replaces the configuration. [NativeComponent] calls this automatically
  /// when its `config` changes.
  Future<void> update(NativeComponentConfig config) async {
    if (_disposed) return;
    await _channel.invokeMethod<void>('update', config.toMap());
  }

  void _dispose() {
    _disposed = true;
    _channel.setMethodCallHandler(null);
    _events.close();
  }
}

/// Embeds a native SwiftUI / UIKit component (iOS only).
///
/// ```dart
/// NativeComponent(
///   type: NativeComponentType.glassButton,
///   config: NativeComponentConfig(
///     title: 'Continue',
///     image: NativeImage.symbol('arrow.right'),
///     style: NativeStyle(tintColor: Colors.teal, cornerRadius: 20),
///   ),
///   onEvent: (event) => debugPrint('$event'),
/// )
/// ```
///
/// Changing [config] updates the native view in place, without recreating it.
class NativeComponent extends StatefulWidget {
  /// Shows a built-in component.
  NativeComponent({
    super.key,
    required NativeComponentType type,
    this.config = const NativeComponentConfig(),
    this.onEvent,
    this.onCreated,
    this.gestureRecognizers,
    this.fallback,
  }) : componentId = type.id;

  /// Shows a component registered from Swift with
  /// `NativeComponentRegistry.register(MyView.self)`.
  const NativeComponent.custom({
    super.key,
    required String id,
    this.config = const NativeComponentConfig(),
    this.onEvent,
    this.onCreated,
    this.gestureRecognizers,
    this.fallback,
  }) : componentId = id;

  /// Native identifier of the component.
  final String componentId;
  final NativeComponentConfig config;

  /// Called for every event the native component emits.
  final ValueChanged<NativeEvent>? onEvent;

  /// Called once the native view exists.
  final ValueChanged<NativeComponentController>? onCreated;

  /// Gestures the native view should win. Defaults to all gestures, which suits
  /// full-screen components; pass an empty set inside Flutter scroll views.
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  /// Shown on platforms other than iOS.
  final Widget? fallback;

  /// The platform view type registered by the plugin.
  static const viewType = 'glassy_ui_ios/view';

  @override
  State<NativeComponent> createState() => _NativeComponentState();
}

class _NativeComponentState extends State<NativeComponent> {
  NativeComponentController? _controller;

  @override
  void didUpdateWidget(NativeComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.config, widget.config)) {
      _controller?.update(widget.config);
    }
  }

  @override
  void dispose() {
    _controller?._dispose();
    super.dispose();
  }

  void _onPlatformViewCreated(int id) {
    final controller =
        NativeComponentController._(MethodChannel('glassy_ui_ios/view_$id'));
    controller._channel.setMethodCallHandler((call) async {
      if (call.method != 'onEvent') return;
      final args = Map<String, Object?>.from(call.arguments as Map);
      final event = NativeEvent(
        component: args['component'] as String? ?? widget.componentId,
        name: args['event'] as String? ?? '',
        value: args['value'],
      );
      if (!controller._events.isClosed) controller._events.add(event);
      widget.onEvent?.call(event);
    });
    _controller = controller;
    widget.onCreated?.call(controller);
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return widget.fallback ??
          const Center(
              child: Text('Native components are available on iOS only.'));
    }
    return UiKitView(
      viewType: NativeComponent.viewType,
      creationParams: {
        'id': widget.componentId,
        'config': widget.config.toMap()
      },
      creationParamsCodec: const StandardMessageCodec(),
      gestureRecognizers: widget.gestureRecognizers ??
          <Factory<OneSequenceGestureRecognizer>>{
            Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
          },
      onPlatformViewCreated: _onPlatformViewCreated,
    );
  }
}
