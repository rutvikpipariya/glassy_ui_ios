import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glassy_ui_ios/glassy_ui_ios.dart';

import 'snippets.dart';

/// Shows the copy-paste ready Dart code for a component.
class CodeSheet extends StatelessWidget {
  const CodeSheet({super.key, required this.type, required this.code});

  final NativeComponentType type;
  final String code;

  static Future<void> show(BuildContext context, NativeComponentType type) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.8,
        child: CodeSheet(type: type, code: componentSnippets[type.id] ?? ''),
      ),
    );
  }

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Code copied to clipboard')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ScaffoldMessenger(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(type.title, style: theme.textTheme.titleMedium),
                        Text(
                          "import 'package:glassy_ui_ios/glassy_ui_ios.dart';",
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'Menlo',
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Builder(
                    builder: (context) => FilledButton.tonalIcon(
                      onPressed: () => _copy(context),
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy'),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SelectableText(
                      code,
                      style: const TextStyle(
                        fontFamily: 'Menlo',
                        fontSize: 12.5,
                        height: 1.45,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
