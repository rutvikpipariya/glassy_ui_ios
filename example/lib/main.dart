import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glassy_ui_ios/glassy_ui_ios.dart';

import 'component_page.dart';
import 'widgets_gallery.dart';

void main() => runApp(const NativeComponentsApp());

/// Whether the app was launched to capture screenshots (collapses the event log).
bool screenshotMode = false;

/// Launch environment provided by the example's AppDelegate.
abstract final class LaunchEnvironment {
  static const _channel = MethodChannel('glassy_ui_ios_example/launch');

  static Future<Map<String, String>> read() async {
    try {
      final map = await _channel.invokeMapMethod<String, String?>(
        'environment',
      );
      return {
        for (final entry in (map ?? {}).entries)
          if (entry.value != null) entry.key: entry.value!,
      };
    } on MissingPluginException {
      return const {};
    }
  }
}

class NativeComponentsApp extends StatelessWidget {
  const NativeComponentsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iOS Native Components',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

/// Two tabs: the `Glass…` widgets and the 90-component catalog.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _tab,
        children: const [WidgetsGalleryPage(), CatalogPage()],
      ),
      bottomNavigationBar: GlassTabBar(
        items: const [
          NativeItem.symbol('Widgets', 'square.grid.2x2.fill'),
          NativeItem.symbol('Catalog', 'books.vertical.fill'),
        ],
        selectedIndex: _tab,
        onChanged: (i) => setState(() => _tab = i),
        fallback: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (i) => setState(() => _tab = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.widgets), label: 'Widgets'),
            NavigationDestination(
              icon: Icon(Icons.menu_book),
              label: 'Catalog',
            ),
          ],
        ),
      ),
    );
  }
}

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  static const _categoryIcons = {
    NativeComponentCategory.navigation: Icons.view_agenda_outlined,
    NativeComponentCategory.buttons: Icons.smart_button_outlined,
    NativeComponentCategory.controls: Icons.tune,
    NativeComponentCategory.structure: Icons.dashboard_outlined,
    NativeComponentCategory.presentation: Icons.layers_outlined,
    NativeComponentCategory.menus: Icons.menu_open,
    NativeComponentCategory.input: Icons.keyboard_outlined,
    NativeComponentCategory.progress: Icons.donut_large,
    NativeComponentCategory.media: Icons.play_circle_outline,
    NativeComponentCategory.glass: Icons.blur_on,
  };

  NativeSystemInfo? _info;
  String _query = '';

  @override
  void initState() {
    super.initState();
    NativeSystem.info().then((info) {
      if (mounted) setState(() => _info = info);
    });
    _openInitialComponent();
  }

  /// Opens a component directly when launched with `--dart-define=COMPONENT=<id>`
  /// or the `COMPONENT` launch environment variable (used for screenshots).
  Future<void> _openInitialComponent() async {
    const defined = String.fromEnvironment('COMPONENT');
    var id = defined;
    if (id.isEmpty) {
      final environment = await LaunchEnvironment.read();
      id = environment['COMPONENT'] ?? '';
      screenshotMode = environment['SCREENSHOT'] == '1';
    }
    final type = NativeComponentType.byId(id);
    if (type == null) return;
    // Never push while the first frame is still building.
    await WidgetsBinding.instance.endOfFrame;
    if (mounted) _open(type);
  }

  void _open(NativeComponentType type) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            ComponentPage(type: type, liquidGlass: _info?.liquidGlass ?? false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.toLowerCase();
    final filtered = NativeComponentType.values
        .where(
          (t) =>
              query.isEmpty ||
              t.title.toLowerCase().contains(query) ||
              t.nativeApi.toLowerCase().contains(query),
        )
        .toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(
              '${NativeComponentType.values.length} Native Components',
            ),
          ),
          SliverToBoxAdapter(child: _SystemBanner(info: _info)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: SearchBar(
                hintText: 'Search components',
                leading: const Icon(Icons.search),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
          ),
          for (final category in NativeComponentCategory.values)
            ..._section(
              category,
              filtered.where((t) => t.category == category).toList(),
            ),
          // Room for the floating glass tab bar.
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  List<Widget> _section(
    NativeComponentCategory category,
    List<NativeComponentType> types,
  ) {
    if (types.isEmpty) return const [];
    final theme = Theme.of(context);
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
          child: Row(
            children: [
              Icon(
                _categoryIcons[category],
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(category.title, style: theme.textTheme.titleSmall),
              const Spacer(),
              Text('${types.length}', style: theme.textTheme.labelMedium),
            ],
          ),
        ),
      ),
      SliverList.builder(
        itemCount: types.length,
        itemBuilder: (context, index) {
          final type = types[index];
          return ListTile(
            leading: CircleAvatar(
              radius: 16,
              child: Text(
                '${type.index + 1}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
            title: Text(type.title),
            subtitle: Text(
              type.nativeApi,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              NativeSystem.haptic();
              _open(type);
            },
          );
        },
      ),
    ];
  }
}

class _SystemBanner extends StatelessWidget {
  const _SystemBanner({required this.info});

  final NativeSystemInfo? info;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final info = this.info;
    final glass = info?.liquidGlass ?? false;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: glass ? scheme.primaryContainer : scheme.secondaryContainer,
      child: ListTile(
        leading: Icon(glass ? Icons.blur_on : Icons.layers),
        title: Text(
          info == null
              ? 'Connecting to native…'
              : glass
              ? 'Liquid Glass active'
              : 'Classic iOS styling',
        ),
        subtitle: Text(
          info == null
              ? 'Native info is available on iOS only'
              : '${info.systemName} ${info.systemVersion} · ${info.model} · '
                    '${info.components.length} native components registered',
        ),
      ),
    );
  }
}
