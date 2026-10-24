import 'package:flutter/material.dart';
import 'package:glassy_ui_ios/glassy_ui_ios.dart';

import 'customize_panel.dart';
import 'code_sheet.dart';
import 'main.dart' show screenshotMode;

/// Hosts one native component with a live customize panel and an event log.
class ComponentPage extends StatefulWidget {
  const ComponentPage({
    super.key,
    required this.type,
    required this.liquidGlass,
  });

  final NativeComponentType type;
  final bool liquidGlass;

  @override
  State<ComponentPage> createState() => _ComponentPageState();
}

class _ComponentPageState extends State<ComponentPage> {
  final _events = <NativeEvent>[];
  NativeComponentController? _controller;
  Customization _customization = const Customization();
  late NativeComponentConfig _config = _customization.toConfig();
  // Collapsed when launched for screenshots.
  bool _logExpanded = !screenshotMode;

  void _onEvent(NativeEvent event) {
    setState(() {
      _events.insert(0, event);
      if (_events.length > 100) _events.removeLast();
    });
  }

  void _customize() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.75,
        child: CustomizePanel(
          value: _customization,
          onChanged: (value) => setState(() {
            _customization = value;
            _config = value.toConfig();
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.type;
    final scheme = Theme.of(context).colorScheme;
    final controller = _controller;

    return Scaffold(
      appBar: AppBar(
        title: Text(type.title),
        actions: [
          IconButton(
            tooltip: 'Code',
            icon: const Icon(Icons.code),
            onPressed: () => CodeSheet.show(context, type),
          ),
          IconButton(
            tooltip: 'Customize',
            icon: const Icon(Icons.tune),
            onPressed: _customize,
          ),
          if (type.triggerLabel != null)
            IconButton(
              tooltip: 'Reset',
              icon: const Icon(Icons.restart_alt),
              onPressed: controller?.reset,
            ),
        ],
      ),
      body: Column(
        children: [
          Material(
            color: scheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              child: Row(
                children: [
                  Icon(
                    widget.liquidGlass ? Icons.blur_on : Icons.layers,
                    size: 18,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      type.nativeApi,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (type.triggerLabel != null)
                    FilledButton.tonalIcon(
                      onPressed: controller == null
                          ? null
                          : () => controller.trigger(),
                      icon: const Icon(Icons.send, size: 16),
                      label: Text(type.triggerLabel!),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: NativeComponent(
              type: type,
              config: _config,
              onEvent: _onEvent,
              onCreated: (controller) =>
                  setState(() => _controller = controller),
            ),
          ),
          _EventLog(
            events: _events,
            expanded: _logExpanded,
            onToggle: () => setState(() => _logExpanded = !_logExpanded),
            onClear: () => setState(_events.clear),
          ),
        ],
      ),
    );
  }
}

class _EventLog extends StatelessWidget {
  const _EventLog({
    required this.events,
    required this.expanded,
    required this.onToggle,
    required this.onClear,
  });

  final List<NativeEvent> events;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainer,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.call_received,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Native → Dart events (${events.length})',
                      style: theme.textTheme.labelLarge,
                    ),
                    const Spacer(),
                    if (events.isNotEmpty)
                      TextButton(
                        onPressed: onClear,
                        child: const Text('Clear'),
                      ),
                    Icon(expanded ? Icons.expand_more : Icons.expand_less),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: SizedBox(
                height: expanded ? 130 : 0,
                child: events.isEmpty
                    ? Center(
                        child: Text(
                          'Interact with the native component…',
                          style: theme.textTheme.bodySmall,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];
                          final time = TimeOfDay.fromDateTime(event.time)
                              .format(context);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '$time  ',
                                    style: TextStyle(
                                      color: theme.colorScheme.outline,
                                    ),
                                  ),
                                  TextSpan(
                                    text: event.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  if (event.value != null)
                                    TextSpan(text: '  ${event.value}'),
                                ],
                              ),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontFamily: 'Menlo',
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
