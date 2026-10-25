import 'package:flutter/material.dart';
import 'package:glassy_ui_ios/glassy_ui_ios.dart';

/// Every `Glass…` widget and native presenter, grouped like the catalog.
/// Each section is a standalone widget so apps can show them separately.
class WidgetsGalleryPage extends StatelessWidget {
  const WidgetsGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(title: Text('Glass Widgets')),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
            sliver: SliverList.list(
              children: const [
                NavigationDemo(),
                ButtonsDemo(),
                MenusDemo(),
                ControlsDemo(),
                InputDemo(),
                ProgressMediaDemo(),
                PresentersDemo(),
              ],
            ),
          ),
        ],
      ),
      // Lift the button above a floating tab bar the page scrolls under
      // (`Scaffold.extendBody` adds the bar's height to the bottom padding).
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom:
              MediaQuery.paddingOf(context).bottom -
              MediaQuery.viewPaddingOf(context).bottom,
        ),
        child: GlassFloatingActionButton(
          actions: const [
            NativeItem.symbol('Photo', 'photo'),
            NativeItem.symbol('Note', 'note.text'),
            NativeItem.symbol('Reminder', 'checklist'),
          ],
          onActionSelected: (index) => report(context, 'FAB action $index'),
          fallback: FloatingActionButton(
            onPressed: () => report(context, 'FAB'),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}

/// Shows what happened as a native toast (a snack bar elsewhere).
void report(BuildContext context, String message) {
  NativeToast.show(message, icon: 'hand.tap.fill', context: context);
}

/// A titled group of demos.
class DemoSection extends StatelessWidget {
  const DemoSection({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < children.length; i++) ...[
                    if (i > 0) const Divider(height: 32),
                    children[i],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A demo with the widget's name above it.
class DemoTile extends StatelessWidget {
  const DemoTile({
    super.key,
    required this.name,
    required this.child,
    this.center = true,
  });

  final String name;
  final Widget child;
  final bool center;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          name,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontFamily: 'Menlo',
          ),
        ),
        const SizedBox(height: 10),
        center ? Center(child: child) : child,
      ],
    );
  }
}

// MARK: - Navigation

class NavigationDemo extends StatefulWidget {
  const NavigationDemo({super.key});

  @override
  State<NavigationDemo> createState() => _NavigationDemoState();
}

class _NavigationDemoState extends State<NavigationDemo> {
  int _tab = 0;
  bool _expandable = false;

  static const _tabs = [
    NativeItem.symbol('Home', 'house.fill'),
    NativeItem.symbol('Search', 'magnifyingglass'),
    NativeItem.symbol('Inbox', 'tray.fill', badge: '3'),
    NativeItem.symbol('Profile', 'person.crop.circle.fill'),
  ];

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'Navigation',
      children: [
        DemoTile(
          name: 'GlassTabBar',
          center: false,
          child: Column(
            children: [
              GlassTabBar(
                items: _tabs,
                selectedIndex: _tab,
                expandable: _expandable,
                safeArea: false,
                onChanged: (i) => setState(() => _tab = i),
                fallback: NavigationBar(
                  selectedIndex: _tab,
                  onDestinationSelected: (i) => setState(() => _tab = i),
                  destinations: [
                    for (final tab in _tabs)
                      NavigationDestination(
                        icon: const Icon(Icons.circle_outlined),
                        label: tab.title,
                      ),
                  ],
                ),
              ),
              GlassSwitch(
                label: 'expandable',
                value: _expandable,
                onChanged: (v) => setState(() => _expandable = v),
              ),
            ],
          ),
        ),
        DemoTile(
          name: 'GlassToolbar',
          child: GlassToolbar(
            width: 240,
            items: const [
              NativeItem.symbol('Share', 'square.and.arrow.up'),
              NativeItem.symbol('Favorite', 'heart'),
              NativeItem.symbol('Info', 'info.circle'),
              NativeItem.symbol(
                'Delete',
                'trash',
                role: NativeItemRole.destructive,
              ),
            ],
            onPressed: (i) => report(context, 'Toolbar button $i'),
          ),
        ),
        DemoTile(
          name: 'GlassBackButton · GlassCloseButton',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GlassBackButton(onPressed: () => report(context, 'Back')),
              const SizedBox(width: 16),
              GlassCloseButton(onPressed: () => report(context, 'Close')),
            ],
          ),
        ),
      ],
    );
  }
}

// MARK: - Buttons

class ButtonsDemo extends StatelessWidget {
  const ButtonsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'Buttons',
      children: [
        DemoTile(
          name: 'GlassButton',
          child: Row(
            children: [
              Expanded(
                child: GlassButton(
                  label: 'Glass',
                  onPressed: () => report(context, 'Glass button'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlassButton(
                  label: 'Continue',
                  icon: const NativeImage.symbol('arrow.right'),
                  prominent: true,
                  onPressed: () => report(context, 'Prominent button'),
                ),
              ),
            ],
          ),
        ),
        DemoTile(
          name: 'GlassIconButton',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final symbol in ['heart.fill', 'message.fill', 'phone.fill'])
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: GlassIconButton(
                    icon: NativeImage.symbol(symbol),
                    semanticLabel: symbol,
                    onPressed: () => report(context, symbol),
                  ),
                ),
              GlassIconButton(
                icon: const NativeImage.symbol('plus'),
                prominent: true,
                onPressed: () => report(context, 'Prominent icon'),
              ),
            ],
          ),
        ),
        DemoTile(
          name: 'GlassImageButton',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GlassImageButton(
                image: const NativeImage.symbol('mountain.2.fill'),
                width: 140,
                height: 140,
                onPressed: () => report(context, 'Play video'),
              ),
              const SizedBox(width: 12),
              GlassImageButton(
                image: const NativeImage.symbol('music.note'),
                badge: 'headphones',
                width: 140,
                height: 140,
                onPressed: () => report(context, 'Play album'),
              ),
            ],
          ),
        ),
        DemoTile(
          name: 'GlassAvatarButton',
          child: GlassAvatarButton(
            initials: 'RP',
            size: 56,
            items: const [
              NativeItem.symbol('Profile', 'person'),
              NativeItem.symbol('Settings', 'gear'),
              NativeItem.symbol(
                'Sign Out',
                'rectangle.portrait.and.arrow.right',
                role: NativeItemRole.destructive,
              ),
            ],
            onSelected: (id) => report(context, id),
          ),
        ),
        const DemoTile(
          name: 'GlassFloatingActionButton',
          child: Text('Bottom-right corner of this page.'),
        ),
      ],
    );
  }
}

// MARK: - Menus

class MenusDemo extends StatefulWidget {
  const MenusDemo({super.key});

  @override
  State<MenusDemo> createState() => _MenusDemoState();
}

class _MenusDemoState extends State<MenusDemo> {
  int _repeat = 1;

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'Menus',
      children: [
        DemoTile(
          name: 'GlassMenuButton',
          child: GlassMenuButton(
            title: 'File',
            width: 140,
            items: const [
              NativeItem.symbol('New File', 'doc.badge.plus'),
              NativeItem(
                title: 'Export As',
                symbol: 'square.and.arrow.up',
                children: [
                  NativeItem(title: 'PDF'),
                  NativeItem(title: 'PNG'),
                ],
              ),
              NativeItem.symbol(
                'Delete',
                'trash',
                role: NativeItemRole.destructive,
              ),
            ],
            onSelected: (id) => report(context, id),
          ),
        ),
        DemoTile(
          name: 'GlassMenuButton (overflow)',
          child: GlassMenuButton(
            icon: const NativeImage.symbol('ellipsis'),
            showChevron: false,
            prominent: false,
            width: 52,
            items: const [
              NativeItem.symbol('Select', 'checkmark.circle'),
              NativeItem.symbol('View Options', 'slider.horizontal.3'),
            ],
            onSelected: (id) => report(context, id),
          ),
        ),
        DemoTile(
          name: 'GlassPopupButton',
          child: GlassPopupButton(
            label: 'Repeat',
            items: const [
              NativeItem(title: 'Never'),
              NativeItem(title: 'Daily'),
              NativeItem(title: 'Weekly'),
              NativeItem(title: 'Monthly'),
            ],
            selectedIndex: _repeat,
            onChanged: (i) => setState(() => _repeat = i),
          ),
        ),
      ],
    );
  }
}

// MARK: - Controls

class ControlsDemo extends StatefulWidget {
  const ControlsDemo({super.key});

  @override
  State<ControlsDemo> createState() => _ControlsDemoState();
}

class _ControlsDemoState extends State<ControlsDemo> {
  int _segment = 1;
  bool _wifi = true;
  double _guests = 2;
  double _brightness = 0.6;
  double _rating = 3;
  int _page = 0;
  bool _terms = false;

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'Controls',
      children: [
        DemoTile(
          name: 'GlassSegmentedControl',
          child: GlassSegmentedControl(
            items: const [
              NativeItem(title: 'Day'),
              NativeItem(title: 'Week'),
              NativeItem(title: 'Month'),
            ],
            selectedIndex: _segment,
            onChanged: (i) => setState(() => _segment = i),
          ),
        ),
        DemoTile(
          name: 'GlassSwitch',
          child: GlassSwitch(
            label: 'Wi-Fi',
            value: _wifi,
            onChanged: (v) => setState(() => _wifi = v),
          ),
        ),
        DemoTile(
          name: 'GlassStepper',
          child: GlassStepper(
            label: 'Guests',
            value: _guests,
            min: 1,
            max: 10,
            onChanged: (v) => setState(() => _guests = v),
          ),
        ),
        DemoTile(
          name: 'GlassSlider',
          child: Column(
            children: [
              GlassSlider(
                value: _brightness,
                minIcon: 'sun.min',
                maxIcon: 'sun.max.fill',
                onChanged: (v) => setState(() => _brightness = v),
              ),
              GlassSlider(
                value: _rating,
                min: 1,
                max: 5,
                divisions: 4,
                onChanged: (v) => setState(() => _rating = v),
              ),
              Text(
                'Brightness ${(_brightness * 100).round()}% · '
                'Rating ${_rating.round()}',
              ),
            ],
          ),
        ),
        DemoTile(
          name: 'GlassPageIndicator',
          child: GlassPageIndicator(
            count: 4,
            currentIndex: _page,
            onChanged: (i) => setState(() => _page = i),
          ),
        ),
        DemoTile(
          name: 'GlassCheckbox',
          child: GlassCheckbox(
            label: 'I agree to the terms',
            value: _terms,
            onChanged: (v) => setState(() => _terms = v),
          ),
        ),
      ],
    );
  }
}

// MARK: - Input

class InputDemo extends StatefulWidget {
  const InputDemo({super.key});

  @override
  State<InputDemo> createState() => _InputDemoState();
}

class _InputDemoState extends State<InputDemo> {
  final _search = GlassTextFieldController();
  String _query = '';
  DateTime _date = DateTime.now();
  int _size = 1;
  Color _accent = Colors.indigo;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'Input & Pickers',
      children: [
        DemoTile(
          name: 'GlassSearchBar',
          child: Column(
            children: [
              GlassSearchBar(
                placeholder: 'Search photos',
                controller: _search,
                onChanged: (q) => setState(() => _query = q),
                onSubmitted: (q) => report(context, 'Search "$q"'),
              ),
              const SizedBox(height: 6),
              Text(_query.isEmpty ? 'Type to search' : 'Query: $_query'),
            ],
          ),
        ),
        DemoTile(
          name: 'GlassTextField',
          child: Column(
            children: [
              GlassTextField(
                placeholder: 'Email',
                keyboardType: GlassKeyboardType.email,
                onSubmitted: (text) => report(context, text),
              ),
              const SizedBox(height: 10),
              const GlassTextField(placeholder: 'Password', obscureText: true),
              const SizedBox(height: 10),
              const GlassTextField(placeholder: 'Notes', multiline: true),
            ],
          ),
        ),
        DemoTile(
          name: 'GlassDatePicker',
          child: Column(
            children: [
              GlassDatePicker(
                label: 'Date',
                value: _date,
                onChanged: (d) => setState(() => _date = d),
              ),
              GlassDatePicker(
                label: 'Time',
                value: _date,
                mode: GlassDatePickerMode.time,
                onChanged: (d) => setState(() => _date = d),
              ),
              GlassDatePicker(
                value: _date,
                style: GlassDatePickerStyle.graphical,
                onChanged: (d) => setState(() => _date = d),
              ),
            ],
          ),
        ),
        DemoTile(
          name: 'GlassWheelPicker',
          child: GlassWheelPicker(
            items: const [
              NativeItem(title: 'Small'),
              NativeItem(title: 'Medium'),
              NativeItem(title: 'Large'),
              NativeItem(title: 'Extra Large'),
            ],
            selectedIndex: _size,
            onChanged: (i) => setState(() => _size = i),
          ),
        ),
        DemoTile(
          name: 'GlassColorPicker',
          child: Row(
            children: [
              Expanded(
                child: GlassColorPicker(
                  label: 'Accent colour',
                  value: _accent,
                  onChanged: (c) => setState(() => _accent = c),
                  fallback: const Text('Colour picker is iOS only'),
                ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(backgroundColor: _accent, radius: 14),
            ],
          ),
        ),
      ],
    );
  }
}

// MARK: - Progress & media

class ProgressMediaDemo extends StatefulWidget {
  const ProgressMediaDemo({super.key});

  @override
  State<ProgressMediaDemo> createState() => _ProgressMediaDemoState();
}

class _ProgressMediaDemoState extends State<ProgressMediaDemo> {
  double _progress = 0.4;
  bool _playing = false;
  int _track = 1;

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'Progress & Media',
      children: [
        DemoTile(
          name: 'GlassProgressIndicator',
          child: Column(
            children: [
              GlassProgressIndicator(value: _progress, label: 'Uploading'),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GlassProgressIndicator(
                    value: _progress,
                    style: GlassProgressStyle.circular,
                  ),
                  const GlassProgressIndicator(),
                ],
              ),
              GlassSlider(
                value: _progress,
                onChanged: (v) => setState(() => _progress = v),
              ),
            ],
          ),
        ),
        DemoTile(
          name: 'GlassPlayPauseButton',
          child: GlassPlayPauseButton(
            isPlaying: _playing,
            onChanged: (v) => setState(() => _playing = v),
          ),
        ),
        DemoTile(
          name: 'GlassMediaControls',
          child: Column(
            children: [
              GlassMediaControls(
                isPlaying: _playing,
                onPlayPause: (v) => setState(() => _playing = v),
                onPrevious: () =>
                    setState(() => _track = (_track - 1).clamp(1, 12)),
                onNext: () =>
                    setState(() => _track = (_track + 1).clamp(1, 12)),
              ),
              const SizedBox(height: 6),
              Text('Track $_track · ${_playing ? 'Playing' : 'Paused'}'),
            ],
          ),
        ),
      ],
    );
  }
}

// MARK: - Presenters

class PresentersDemo extends StatelessWidget {
  const PresentersDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'Alerts, Sheets & Toasts',
      children: [
        DemoTile(
          name: 'NativeDialog.alert',
          child: GlassButton(
            label: 'Delete photo…',
            width: 220,
            onPressed: () async {
              final id = await NativeDialog.alert(
                title: 'Delete photo?',
                message: 'This photo will be deleted from all your devices.',
                actions: const [
                  NativeItem(title: 'Delete', role: NativeItemRole.destructive),
                  NativeItem(title: 'Cancel', role: NativeItemRole.cancel),
                ],
                context: context,
              );
              if (id != null && context.mounted) report(context, id);
            },
          ),
        ),
        DemoTile(
          name: 'NativeDialog.actionSheet',
          child: GlassButton(
            label: 'Discard changes…',
            width: 220,
            onPressed: () async {
              final id = await NativeDialog.actionSheet(
                title: 'You have unsaved changes',
                actions: const [
                  NativeItem(
                    title: 'Discard',
                    role: NativeItemRole.destructive,
                  ),
                  NativeItem(title: 'Save Draft'),
                  NativeItem(title: 'Cancel', role: NativeItemRole.cancel),
                ],
                context: context,
              );
              if (id != null && context.mounted) report(context, id);
            },
          ),
        ),
        DemoTile(
          name: 'NativeDialog.prompt',
          child: GlassButton(
            label: 'Rename…',
            width: 220,
            onPressed: () async {
              final name = await NativeDialog.prompt(
                title: 'Rename',
                placeholder: 'Name',
                initialValue: 'Holiday.jpg',
                confirmLabel: 'Save',
                context: context,
              );
              if (name != null && context.mounted) report(context, name);
            },
          ),
        ),
        DemoTile(
          name: 'NativeSheet.show',
          child: GlassButton(
            label: 'Share to…',
            width: 220,
            onPressed: () async {
              final id = await NativeSheet.show(
                title: 'Share to',
                message: 'Choose where to send the photo.',
                items: const [
                  NativeItem.symbol('Messages', 'message.fill'),
                  NativeItem.symbol('Mail', 'envelope.fill'),
                  NativeItem(
                    title: 'AirDrop',
                    subtitle: 'Nearby devices',
                    symbol: 'airplayaudio',
                  ),
                ],
                context: context,
              );
              if (id != null && context.mounted) report(context, id);
            },
          ),
        ),
        DemoTile(
          name: 'NativeToast.show',
          child: GlassButton(
            label: 'Show toast',
            width: 220,
            onPressed: () => NativeToast.show(
              'Copied to clipboard',
              icon: 'doc.on.doc.fill',
              context: context,
            ),
          ),
        ),
        DemoTile(
          name: 'NativeShare.share',
          child: GlassButton(
            label: 'Share link',
            icon: const NativeImage.symbol('square.and.arrow.up'),
            width: 220,
            onPressed: () => NativeShare.share(
              text: 'glassy_ui_ios',
              url: 'https://pub.dev/packages/glassy_ui_ios',
            ),
          ),
        ),
      ],
    );
  }
}
