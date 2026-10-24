<p align="center">
  <img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/banner.png" alt="glassy_ui_ios: 90 native iOS components for Flutter" width="100%">
</p>

<p align="center">
  <a href="https://pub.dev/packages/glassy_ui_ios"><img src="https://img.shields.io/pub/v/glassy_ui_ios.svg?label=pub.dev&color=0175C2" alt="pub version"></a>
  <a href="https://pub.dev/packages/glassy_ui_ios/score"><img src="https://img.shields.io/pub/likes/glassy_ui_ios?color=ff4f8b" alt="pub likes"></a>
  <a href="https://pub.dev/packages/glassy_ui_ios/score"><img src="https://img.shields.io/pub/points/glassy_ui_ios?color=2ea44f" alt="pub points"></a>
  <a href="https://pub.dev/packages/glassy_ui_ios"><img src="https://img.shields.io/pub/dm/glassy_ui_ios?color=8a2be2" alt="downloads"></a>
  <img src="https://img.shields.io/badge/platform-iOS%2017%2B-black?logo=apple" alt="iOS 17+">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT license"></a>
</p>

<h3 align="center">Real SwiftUI &amp; UIKit components in your Flutter app.<br>Apple's Liquid Glass on iOS 26, automatic fallbacks on iOS 17–18.</h3>

<p align="center">
  <a href="#installation">Installation</a> ·
  <a href="#quick-start">Quick start</a> ·
  <a href="#component-gallery">All 90 components</a> ·
  <a href="#faq">FAQ</a>
</p>

## See it in action

<table>
  <tr>
    <td align="center"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/demo/glass-morphing.gif" width="190" alt="Glass morphing"><br><sub><b>Glass morphing</b><br><code>glassMorphing</code></sub></td>
    <td align="center"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/demo/floating-action-button.gif" width="190" alt="Floating action button"><br><sub><b>Floating action button</b><br><code>floatingActionButton</code></sub></td>
    <td align="center"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/demo/glass-transition.gif" width="190" alt="Glass transition"><br><sub><b>Glass transition</b><br><code>glassTransition</code></sub></td>
    <td align="center"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/demo/download-progress.gif" width="190" alt="Download progress"><br><sub><b>App Store download</b><br><code>downloadProgress</code></sub></td>
  </tr>
</table>

<p align="center">
  <img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/catalog.png" width="200" alt="Catalog">
  <img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/glass_container.png" width="200" alt="Glass effect container">
  <img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/media_controls.png" width="200" alt="Media controls">
  <img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/toolbar.png" width="200" alt="Toolbar">
</p>

## Why glassy_ui_ios?

Flutter draws every pixel itself, so Cupertino-style widgets can only *imitate* iOS. Liquid Glass is rendered by the system, with real-time refraction and morphing, and can't be faithfully recreated in Flutter. **glassy_ui_ios embeds Apple's own components instead.**

| | **glassy_ui_ios** | Flutter look-alike widgets |
| --- | :---: | :---: |
| Rendering | ✅ Real SwiftUI / UIKit | Recreated in Flutter |
| Liquid Glass (refraction, morphing) | ✅ Native `glassEffect` | ❌ Blur approximation |
| Matches every iOS update | ✅ Automatically | Needs a package update |
| System sheets, menus, popovers, haptics | ✅ Native behavior | Imitated |
| VoiceOver &amp; Dynamic Type | ✅ Built in | Partial |
| iOS 17–18 support | ✅ Classic materials fallback | ✅ |
| Customizable from Dart | ✅ Colors, images, radius, fonts, glass | ✅ |

## Features

- **90 components**: navigation bars, toolbars, glass buttons, tab bars, sidebars, split views, sheets, alerts, menus, pickers, progress, media and camera controls, and Liquid Glass effects. See the [gallery](#component-gallery) below.
- **Truly native**: SwiftUI and UIKit render each component, so system sheets, menus, popovers and haptics behave exactly like iOS.
- **Adaptive design**: `glassEffect`, `.glass` / `.glassProminent`, `GlassEffectContainer` and glass morphing on iOS 26+, with material fallbacks on iOS 17–18.
- **Configurable from Dart**: title, images (SF Symbols, assets, bytes), items, values, colors, background, corner radius, glass variant, fonts and light/dark. Changes apply **live**.
- **Two-way communication**: every interaction comes back to Dart as a `NativeEvent`, and Dart drives components with `trigger()`, `reset()` and custom commands.
- **Extensible**: register your own SwiftUI views and use them from Dart.
- **Copy-paste examples**: every component comes with ready-to-use Dart code in the example app.
- **Fully documented**: every public API has dartdoc, including each component's config fields, commands and events.
- **Swift Package Manager** and a privacy manifest are included.

## Requirements

| | Minimum |
| --- | --- |
| iOS | 17.0 (Liquid Glass needs iOS 26) |
| Flutter | 3.27 |
| Xcode | 26 (to compile the Liquid Glass APIs) |
| Integration | Swift Package Manager |

## Installation

```sh
flutter pub add glassy_ui_ios
```

or add it to `pubspec.yaml` yourself:

```yaml
dependencies:
  glassy_ui_ios: ^0.1.2
```

This plugin is distributed with **Swift Package Manager**, so turn it on for your app in `pubspec.yaml`:

```yaml
flutter:
  config:
    enable-swift-package-manager: true
```

You can also turn it on globally with `flutter config --enable-swift-package-manager`.

Then set the iOS deployment target to **17.0**: in Xcode, select Runner → General → Minimum Deployments. If your app still has a `Podfile`, set `platform :ios, '17.0'` there as well.

## Quick start

```dart
import 'package:glassy_ui_ios/glassy_ui_ios.dart';

SizedBox(
  height: 400,
  child: NativeComponent(
    type: NativeComponentType.prominentGlassButton,
    config: const NativeComponentConfig(
      title: 'Continue',
      image: NativeImage.symbol('arrow.right'),
      style: NativeStyle(
        tintColor: Colors.teal,
        cornerRadius: 20,
        backgroundGradient: [Colors.indigo, Colors.pink],
      ),
    ),
    onEvent: (event) => debugPrint('${event.name}: ${event.value}'),
  ),
);
```

`NativeComponent` sizes itself to its parent, like any platform view. Give it bounded constraints: an `Expanded`, a `SizedBox`, or a full page.

### Controlling a component from Dart

```dart
late NativeComponentController controller;

NativeComponent(
  type: NativeComponentType.halfSheet,
  onCreated: (c) => controller = c,
);

await controller.trigger();          // primary action: present, toggle, next…
await controller.reset();            // back to the initial state
await controller.send('custom', 42); // custom commands for your own components
controller.events.listen(print);     // stream of NativeEvent
```

`NativeComponentType.triggerLabel` describes what `trigger()` does for each component.

### Live updates

Put the config in state and change it. The native view updates in place without being recreated:

```dart
setState(() {
  config = config.copyWith(
    title: 'Updated',
    style: config.style.copyWith(tintColor: Colors.orange, glass: NativeGlass.clear),
  );
});
```

## Configuration

Every component reads the same `NativeComponentConfig`. Each one documents the fields it uses in its Swift source (`ios/glassy_ui_ios/Sources/glassy_ui_ios/Components/`).

| Field | Purpose |
| --- | --- |
| `title`, `subtitle`, `message`, `placeholder` | Text content |
| `image` | Main icon or artwork: `NativeImage.symbol('star.fill')`, `NativeImage.asset('assets/cover.jpg')`, `NativeImage.bytes(data)` |
| `items` | Tabs, menu actions, segments, options, rows (`List<NativeItem>`; nest with `children` for submenus and columns) |
| `value`, `min`, `max`, `step` | Initial value and range. `DateTime` and `Color` values are encoded automatically |
| `enabled` | Disables the whole component |
| `extra` | Component-specific options, e.g. `{'detents': ['0.25', 'medium', 'large']}` |
| `style` | A `NativeStyle` (see below) |

### `NativeStyle`

| Property | Description |
| --- | --- |
| `tintColor` | Accent color for buttons, switches, sliders and selection |
| `foregroundColor` | Primary text and icon color |
| `backgroundColor` / `backgroundGradient` | Background behind the component |
| `showBackdrop` | Colorful default backdrop that makes glass refraction visible |
| `surfaceColor` | Card color when glass is disabled |
| `cornerRadius` | Corner radius of cards, sheets and rounded glass |
| `glass` | `NativeGlass.regular`, `.clear` or `.none` |
| `glassTint`, `interactive` | Glass tint and touch reaction |
| `padding`, `spacing` | Layout |
| `fontSize`, `fontWeight`, `fontDesign` | Title typography |
| `colorScheme` | Force `light` or `dark` |
| `controlSize` | `mini` … `extraLarge` |

### `NativeItem`

```dart
const NativeItem.symbol('Inbox', 'tray', badge: '3');
const NativeItem(id: 'delete', title: 'Delete', symbol: 'trash', role: NativeItemRole.destructive);
const NativeItem(title: 'Export', children: [NativeItem(title: 'PDF'), NativeItem(title: 'PNG')]);
```

### Images from assets

Declare the asset in your app's `pubspec.yaml` and pass its path:

```dart
NativeComponentConfig(image: const NativeImage.asset('assets/album.jpg'));
```

## Events

`NativeEvent` has a `name`, a `value` and a `time`. The names are consistent across components:

| Event | Sent when |
| --- | --- |
| `change` | A value changed (slider, toggle, picker, tab…) |
| `select` | An item, row or menu entry was chosen (`value` = item id) |
| `tap` / `action` | A button or action was pressed |
| `presented` / `dismissed` | A sheet or overlay appeared or disappeared |
| `complete` | A progress indicator finished |

## Custom native components

Any SwiftUI view in your app can become a component. Make it conform to `NativeComponent` and register it:

```swift
import glassy_ui_ios
import SwiftUI

struct RatingView: NativeComponent {
  static let componentId = "rating"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @State private var rating = 0

  var body: some View {
    ComponentScaffold {
      GlassCard(config.title ?? "Rate") {
        HStack {
          ForEach(1...5, id: \.self) { star in
            Button {
              rating = star
              context.emit("change", star)
            } label: {
              Image(systemName: star <= rating ? "star.fill" : "star")
            }
          }
        }
      }
    }
    .seed($rating, from: config.int(or: 0))
    .onNativeCommand { if $0.name == "reset" { rating = 0 } }
  }
}

// AppDelegate, after GeneratedPluginRegistrant.register(...)
NativeComponentRegistry.register(RatingView.self)
```

```dart
NativeComponent.custom(id: 'rating', config: const NativeComponentConfig(title: 'Rate us'));
```

These building blocks are available to your views: `adaptiveGlass`, `nativeGlass`, `nativeButtonStyle`, `AdaptiveGlassContainer`, `adaptiveGlassID`, `adaptiveGlassUnion`, `ComponentScaffold`, `ComponentBackground`, `GlassCard`, `NativeIcon`, `NativeArtwork`, `NativeItemLabel`, `NativeItemButton`, `CloseButton`, `GlassIconButton` and `GlassSupport.isAvailable`.

## System helpers

```dart
final info = await NativeSystem.info(); // iOS version, liquidGlass, registered ids
await NativeSystem.haptic(NativeHaptic.success);
```

## Component gallery

Screenshots were taken on an iPhone simulator running iOS 27 (Liquid Glass), using each component's default configuration.
The [example app](example) contains all 90 components, a live **Customize** panel, and a **Code** button with copy-paste ready code for each component (also in [`example/lib/snippets.dart`](example/lib/snippets.dart)).

### Navigation & Toolbars (9)

<table>
<tr><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/nav-bar.jpg" width="220" alt="Navigation Bar / App Bar"><br><b>Navigation Bar / App Bar</b><br><code>NativeComponentType.navBar</code><br><sub>NavigationStack + .toolbar — glass bar on iOS 26</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/back-button.jpg" width="220" alt="Back Button"><br><b>Back Button</b><br><code>NativeComponentType.backButton</code><br><sub>NavigationStack(path:) system back button</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/close-button.jpg" width="220" alt="Close Button"><br><b>Close Button</b><br><code>NativeComponentType.closeButton</code><br><sub>Button(role: .close) / xmark.circle.fill</sub></td></tr>
<tr><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/nav-title.jpg" width="220" alt="Navigation Title"><br><b>Navigation Title</b><br><code>NativeComponentType.navTitle</code><br><sub>.navigationTitle + .toolbarTitleMenu</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/large-nav-title.jpg" width="220" alt="Large Navigation Title"><br><b>Large Navigation Title</b><br><code>NativeComponentType.largeNavTitle</code><br><sub>.navigationBarTitleDisplayMode(.large)</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/toolbar.jpg" width="220" alt="Toolbar"><br><b>Toolbar</b><br><code>NativeComponentType.toolbar</code><br><sub>ToolbarItemGroup + ToolbarSpacer (iOS 26)</sub></td></tr>
<tr><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/floating-toolbar.jpg" width="220" alt="Floating Toolbar"><br><b>Floating Toolbar</b><br><code>NativeComponentType.floatingToolbar</code><br><sub>GlassEffectContainer + .glassEffect / material capsule</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/bottom-toolbar.jpg" width="220" alt="Bottom Toolbar"><br><b>Bottom Toolbar</b><br><code>NativeComponentType.bottomToolbar</code><br><sub>ToolbarItem(placement: .bottomBar)</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/toolbar-action-button.jpg" width="220" alt="Toolbar Action Button"><br><b>Toolbar Action Button</b><br><code>NativeComponentType.toolbarActionButton</code><br><sub>.confirmationAction + .glassProminent</sub></td></tr>
</table>

### Buttons (9)

<table>
<tr><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/glass-button.jpg" width="220" alt="Glass Button"><br><b>Glass Button</b><br><code>NativeComponentType.glassButton</code><br><sub>.buttonStyle(.glass) / .bordered</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/prominent-glass-button.jpg" width="220" alt="Prominent Glass Button"><br><b>Prominent Glass Button</b><br><code>NativeComponentType.prominentGlassButton</code><br><sub>.buttonStyle(.glassProminent) / .borderedProminent</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/image-button.jpg" width="220" alt="Image Button"><br><b>Image Button</b><br><code>NativeComponentType.imageButton</code><br><sub>Button with image label + custom ButtonStyle</sub></td></tr>
<tr><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/circular-icon-button.jpg" width="220" alt="Circular Icon Button"><br><b>Circular Icon Button</b><br><code>NativeComponentType.circularIconButton</code><br><sub>.buttonBorderShape(.circle) + glass</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/sf-symbols-button.jpg" width="220" alt="SF Symbols Button"><br><b>SF Symbols Button</b><br><code>NativeComponentType.sfSymbolsButton</code><br><sub>.symbolEffect, rendering modes, variableValue</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/plus-button.jpg" width="220" alt="Plus Button"><br><b>Plus Button</b><br><code>NativeComponentType.plusButton</code><br><sub>Glass circle + .numericText transition</sub></td></tr>
<tr><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/minus-button.jpg" width="220" alt="Minus Button"><br><b>Minus Button</b><br><code>NativeComponentType.minusButton</code><br><sub>Glass circle + .numericText transition</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/floating-action-button.jpg" width="220" alt="Floating Action Button"><br><b>Floating Action Button</b><br><code>NativeComponentType.floatingActionButton</code><br><sub>Glass morphing with glassEffectID</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/avatar-action-button.jpg" width="220" alt="Avatar Action Button"><br><b>Avatar Action Button</b><br><code>NativeComponentType.avatarActionButton</code><br><sub>Toolbar Menu with avatar label</sub></td></tr>
</table>

### Controls (7)

<table>
<tr><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/segmented-control.jpg" width="220" alt="Segmented Control"><br><b>Segmented Control</b><br><code>NativeComponentType.segmentedControl</code><br><sub>Picker(.segmented)</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/toggle.jpg" width="220" alt="Toggle / Switch"><br><b>Toggle / Switch</b><br><code>NativeComponentType.toggle</code><br><sub>Toggle(.switch)</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/stepper.jpg" width="220" alt="Stepper"><br><b>Stepper</b><br><code>NativeComponentType.stepper</code><br><sub>Stepper(value:in:step:)</sub></td></tr>
<tr><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/slider.jpg" width="220" alt="Slider"><br><b>Slider</b><br><code>NativeComponentType.slider</code><br><sub>Slider with min/max value labels</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/slider-ticks.jpg" width="220" alt="Slider with Tick Marks"><br><b>Slider with Tick Marks</b><br><code>NativeComponentType.sliderTicks</code><br><sub>Slider(tick:) iOS 26 / drawn ticks</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/page-indicator.jpg" width="220" alt="Page Indicator"><br><b>Page Indicator</b><br><code>NativeComponentType.pageIndicator</code><br><sub>TabView(.page) + .indexViewStyle</sub></td></tr>
<tr><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/checkbox.jpg" width="220" alt="Checkbox-Style Control"><br><b>Checkbox-Style Control</b><br><code>NativeComponentType.checkbox</code><br><sub>Custom ToggleStyle with SF Symbols</sub></td></tr>
</table>

### Tabs & Structure (10)

<table>
<tr><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/tab-bar.jpg" width="220" alt="Tab Bar"><br><b>Tab Bar</b><br><code>NativeComponentType.tabBar</code><br><sub>TabView + .tabItem</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/floating-tab-bar.jpg" width="220" alt="Floating Tab Bar"><br><b>Floating Tab Bar</b><br><code>NativeComponentType.floatingTabBar</code><br><sub>.tabBarMinimizeBehavior(.onScrollDown) / custom capsule</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/tab-bar-item.jpg" width="220" alt="Tab Bar Item"><br><b>Tab Bar Item</b><br><code>NativeComponentType.tabBarItem</code><br><sub>.tabItem + .badge</sub></td></tr>
<tr><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/expandable-tab-bar.jpg" width="220" alt="Expandable Tab Bar"><br><b>Expandable Tab Bar</b><br><code>NativeComponentType.expandableTabBar</code><br><sub>Glass capsules that expand with glassEffectID</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/search-tab.jpg" width="220" alt="Search Tab"><br><b>Search Tab</b><br><code>NativeComponentType.searchTab</code><br><sub>Tab(role: .search) iOS 18+ / tabItem</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/sidebar.jpg" width="220" alt="Sidebar"><br><b>Sidebar</b><br><code>NativeComponentType.sidebar</code><br><sub>NavigationSplitView + .listStyle(.sidebar)</sub></td></tr>
<tr><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/navigation-stack.jpg" width="220" alt="Navigation Stack"><br><b>Navigation Stack</b><br><code>NativeComponentType.navigationStack</code><br><sub>NavigationStack(path:) + navigationDestination</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/split-view.jpg" width="220" alt="Split View"><br><b>Split View</b><br><code>NativeComponentType.splitView</code><br><sub>Three-column NavigationSplitView</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/floating-accessory.jpg" width="220" alt="Floating Accessory View"><br><b>Floating Accessory View</b><br><code>NativeComponentType.floatingAccessory</code><br><sub>.tabViewBottomAccessory (iOS 26) / safeAreaInset</sub></td></tr>
<tr><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/inspector.jpg" width="220" alt="Inspector Panel"><br><b>Inspector Panel</b><br><code>NativeComponentType.inspector</code><br><sub>.inspector(isPresented:)</sub></td></tr>
</table>

### Sheets, Dialogs & Overlays (11)

<table>
<tr><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/bottom-sheet.jpg" width="220" alt="Bottom Sheet"><br><b>Bottom Sheet</b><br><code>NativeComponentType.bottomSheet</code><br><sub>Sheet with .height detent + background interaction</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/half-sheet.jpg" width="220" alt="Half-Screen Sheet"><br><b>Half-Screen Sheet</b><br><code>NativeComponentType.halfSheet</code><br><sub>.presentationDetents([.medium])</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/full-sheet.jpg" width="220" alt="Full-Screen Sheet"><br><b>Full-Screen Sheet</b><br><code>NativeComponentType.fullSheet</code><br><sub>.fullScreenCover</sub></td></tr>
<tr><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/detented-sheet.jpg" width="220" alt="Detented Sheet"><br><b>Detented Sheet</b><br><code>NativeComponentType.detentedSheet</code><br><sub>Detents with selection binding</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/drag-indicator.jpg" width="220" alt="Sheet Drag Indicator"><br><b>Sheet Drag Indicator</b><br><code>NativeComponentType.dragIndicator</code><br><sub>.presentationDragIndicator</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/alert.jpg" width="220" alt="Alert Dialog"><br><b>Alert Dialog</b><br><code>NativeComponentType.alert</code><br><sub>.alert with roles + text field</sub></td></tr>
<tr><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/confirmation-dialog.jpg" width="220" alt="Confirmation Dialog"><br><b>Confirmation Dialog</b><br><code>NativeComponentType.confirmationDialog</code><br><sub>.confirmationDialog — popover on iOS 26</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/action-sheet.jpg" width="220" alt="Action Sheet"><br><b>Action Sheet</b><br><code>NativeComponentType.actionSheet</code><br><sub>UIKit UIAlertController(.actionSheet)</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/popover.jpg" width="220" alt="Popover"><br><b>Popover</b><br><code>NativeComponentType.popover</code><br><sub>.popover + .presentationCompactAdaptation</sub></td></tr>
<tr><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/toast.jpg" width="220" alt="Toast / Notification Overlay"><br><b>Toast / Notification Overlay</b><br><code>NativeComponentType.toast</code><br><sub>Glass capsule overlay with transition</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/confirmation-popup.jpg" width="220" alt="Confirmation Popup"><br><b>Confirmation Popup</b><br><code>NativeComponentType.confirmationPopup</code><br><sub>Custom glass card modal</sub></td></tr>
</table>

### Menus (7)

<table>
<tr><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/popup-menu.jpg" width="220" alt="Popup Menu"><br><b>Popup Menu</b><br><code>NativeComponentType.popupMenu</code><br><sub>Menu + Picker (pop-up button)</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/dropdown-menu.jpg" width="220" alt="Dropdown Menu"><br><b>Dropdown Menu</b><br><code>NativeComponentType.dropdownMenu</code><br><sub>Menu with sections, Picker and Toggle</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/context-menu.jpg" width="220" alt="Context Menu"><br><b>Context Menu</b><br><code>NativeComponentType.contextMenu</code><br><sub>.contextMenu with preview</sub></td></tr>
<tr><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/overflow-menu.jpg" width="220" alt="Overflow Menu"><br><b>Overflow Menu</b><br><code>NativeComponentType.overflowMenu</code><br><sub>Toolbar Menu with ellipsis</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/nested-submenu.jpg" width="220" alt="Nested Submenu"><br><b>Nested Submenu</b><br><code>NativeComponentType.nestedSubmenu</code><br><sub>Menu inside Menu</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/share-menu.jpg" width="220" alt="Share Menu"><br><b>Share Menu</b><br><code>NativeComponentType.shareMenu</code><br><sub>ShareLink + UIActivityViewController</sub></td></tr>
<tr><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/text-selection-menu.jpg" width="220" alt="Text Selection Menu"><br><b>Text Selection Menu</b><br><code>NativeComponentType.textSelectionMenu</code><br><sub>UITextView editMenuForTextIn</sub></td></tr>
</table>

### Input & Pickers (10)

<table>
<tr><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/text-field.jpg" width="220" alt="Text Field"><br><b>Text Field</b><br><code>NativeComponentType.textField</code><br><sub>TextField styles + glass field</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/secure-field.jpg" width="220" alt="Secure Password Field"><br><b>Secure Password Field</b><br><code>NativeComponentType.secureField</code><br><sub>SecureField with reveal + strength</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/search-field.jpg" width="220" alt="Search Field"><br><b>Search Field</b><br><code>NativeComponentType.searchField</code><br><sub>.searchable + .searchSuggestions</sub></td></tr>
<tr><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/text-editor.jpg" width="220" alt="Multiline Text Editor"><br><b>Multiline Text Editor</b><br><code>NativeComponentType.textEditor</code><br><sub>TextEditor + FocusState</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/date-picker.jpg" width="220" alt="Date Picker"><br><b>Date Picker</b><br><code>NativeComponentType.datePicker</code><br><sub>DatePicker(.graphical / .compact)</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/time-picker.jpg" width="220" alt="Time Picker"><br><b>Time Picker</b><br><code>NativeComponentType.timePicker</code><br><sub>DatePicker(.hourAndMinute, .wheel)</sub></td></tr>
<tr><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/wheel-picker.jpg" width="220" alt="Wheel Picker"><br><b>Wheel Picker</b><br><code>NativeComponentType.wheelPicker</code><br><sub>Picker(.wheel) multi-column</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/menu-picker.jpg" width="220" alt="Menu Picker"><br><b>Menu Picker</b><br><code>NativeComponentType.menuPicker</code><br><sub>Picker(.menu)</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/color-picker.jpg" width="220" alt="Color Picker"><br><b>Color Picker</b><br><code>NativeComponentType.colorPicker</code><br><sub>ColorPicker (returns hex to Dart)</sub></td></tr>
<tr><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/floating-search-bar.jpg" width="220" alt="Floating Search Bar"><br><b>Floating Search Bar</b><br><code>NativeComponentType.floatingSearchBar</code><br><sub>Glass search capsule over content</sub></td></tr>
</table>

### Progress (7)

<table>
<tr><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/circular-progress.jpg" width="220" alt="Circular Progress Indicator"><br><b>Circular Progress Indicator</b><br><code>NativeComponentType.circularProgress</code><br><sub>Gauge(.accessoryCircularCapacity) + ring</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/linear-progress.jpg" width="220" alt="Linear Progress Bar"><br><b>Linear Progress Bar</b><br><code>NativeComponentType.linearProgress</code><br><sub>ProgressView(value:)</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/determinate-progress.jpg" width="220" alt="Determinate Progress Bar"><br><b>Determinate Progress Bar</b><br><code>NativeComponentType.determinateProgress</code><br><sub>ProgressView(value:total:) + Gauge</sub></td></tr>
<tr><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/indeterminate-loading.jpg" width="220" alt="Indeterminate Loading Indicator"><br><b>Indeterminate Loading Indicator</b><br><code>NativeComponentType.indeterminateLoading</code><br><sub>ProgressView() + animated bar</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/download-progress.jpg" width="220" alt="Download Progress Indicator"><br><b>Download Progress Indicator</b><br><code>NativeComponentType.downloadProgress</code><br><sub>App Store-style ring button</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/upload-progress.jpg" width="220" alt="Upload Progress Indicator"><br><b>Upload Progress Indicator</b><br><code>NativeComponentType.uploadProgress</code><br><sub>Per-file ProgressView</sub></td></tr>
<tr><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/activity-indicator.jpg" width="220" alt="Activity Indicator"><br><b>Activity Indicator</b><br><code>NativeComponentType.activityIndicator</code><br><sub>UIKit UIActivityIndicatorView</sub></td></tr>
</table>

### Media & Camera (11)

<table>
<tr><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/gallery-toolbar.jpg" width="220" alt="Gallery Toolbar"><br><b>Gallery Toolbar</b><br><code>NativeComponentType.galleryToolbar</code><br><sub>Grid + bottomBar selection toolbar</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/photo-viewer-toolbar.jpg" width="220" alt="Photo Viewer Toolbar"><br><b>Photo Viewer Toolbar</b><br><code>NativeComponentType.photoViewerToolbar</code><br><sub>Glass top/bottom chrome</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/media-controls.jpg" width="220" alt="Media Playback Controls"><br><b>Media Playback Controls</b><br><code>NativeComponentType.mediaControls</code><br><sub>Now Playing glass card</sub></td></tr>
<tr><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/play-pause.jpg" width="220" alt="Play / Pause Button"><br><b>Play / Pause Button</b><br><code>NativeComponentType.playPause</code><br><sub>.contentTransition(.symbolEffect(.replace))</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/skip-buttons.jpg" width="220" alt="Skip Forward / Backward Button"><br><b>Skip Forward / Backward Button</b><br><code>NativeComponentType.skipButtons</code><br><sub>gobackward.15 / goforward.30 + bounce</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/volume-slider.jpg" width="220" alt="Volume Slider"><br><b>Volume Slider</b><br><code>NativeComponentType.volumeSlider</code><br><sub>Slider + MPVolumeView</sub></td></tr>
<tr><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/media-close.jpg" width="220" alt="Full-Screen Media Close Button"><br><b>Full-Screen Media Close Button</b><br><code>NativeComponentType.mediaClose</code><br><sub>Glass xmark over media</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/pip-controls.jpg" width="220" alt="Picture-in-Picture Controls"><br><b>Picture-in-Picture Controls</b><br><code>NativeComponentType.pipControls</code><br><sub>Draggable mini player + AVKit support check</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/camera-controls.jpg" width="220" alt="Camera Controls"><br><b>Camera Controls</b><br><code>NativeComponentType.cameraControls</code><br><sub>Shutter, modes, flash, flip</sub></td></tr>
<tr><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/zoom-controls.jpg" width="220" alt="Zoom Controls"><br><b>Zoom Controls</b><br><code>NativeComponentType.zoomControls</code><br><sub>Zoom pills + MagnifyGesture</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/crop-controls.jpg" width="220" alt="Crop Controls"><br><b>Crop Controls</b><br><code>NativeComponentType.cropControls</code><br><sub>Aspect ratios, straighten dial, rotate</sub></td></tr>
</table>

### Liquid Glass (9)

<table>
<tr><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/scroll-edge.jpg" width="220" alt="Scroll-Edge Glass Effect"><br><b>Scroll-Edge Glass Effect</b><br><code>NativeComponentType.scrollEdge</code><br><sub>.scrollEdgeEffectStyle(.soft / .hard)</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/glass-background.jpg" width="220" alt="Glass Background"><br><b>Glass Background</b><br><code>NativeComponentType.glassBackground</code><br><sub>Glass.regular / .clear / .tint</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/custom-glass-shape.jpg" width="220" alt="Custom Glass Shape"><br><b>Custom Glass Shape</b><br><code>NativeComponentType.customGlassShape</code><br><sub>.glassEffect(in: customShape)</sub></td></tr>
<tr><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/glass-button-group.jpg" width="220" alt="Glass Button Group"><br><b>Glass Button Group</b><br><code>NativeComponentType.glassButtonGroup</code><br><sub>.glassEffectUnion</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/glass-container.jpg" width="220" alt="Glass Effect Container"><br><b>Glass Effect Container</b><br><code>NativeComponentType.glassContainer</code><br><sub>GlassEffectContainer(spacing:) blending</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/glass-morphing.jpg" width="220" alt="Glass Morphing Animation"><br><b>Glass Morphing Animation</b><br><code>NativeComponentType.glassMorphing</code><br><sub>.glassEffectID morphing</sub></td></tr>
<tr><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/glass-transition.jpg" width="220" alt="Glass Transition"><br><b>Glass Transition</b><br><code>NativeComponentType.glassTransition</code><br><sub>.glassEffectTransition(.materialize)</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/app-icon.jpg" width="220" alt="App Icon with Layered Glass Styling"><br><b>App Icon with Layered Glass Styling</b><br><code>NativeComponentType.appIcon</code><br><sub>Layered icon: default / dark / clear / tinted</sub></td><td align="center" valign="top" width="33%"><img src="https://raw.githubusercontent.com/rutvikpipariya/glassy_ui_ios/main/screenshots/components/widget-appearance.jpg" width="220" alt="Widget with Clear or Tinted Appearance"><br><b>Widget with Clear or Tinted Appearance</b><br><code>NativeComponentType.widgetAppearance</code><br><sub>Full colour / clear / tinted rendering</sub></td></tr>
</table>

## Limitations

- Glass refracts only native content inside the platform view, not the Flutter widgets behind it. That's why components draw their own backdrop (`NativeStyle.showBackdrop`).
- iOS only. On other platforms `NativeComponent` shows its `fallback` widget.
- Picture-in-picture and camera controls are UI only: no video asset and no camera session are used. `MPVolumeView` renders only on physical devices.
- Every component is a platform view, so prefer a few large components per screen over many small ones.

## FAQ

<details>
<summary><b>Does it work on Android, web or desktop?</b></summary>

No. The components are Apple's own, so they only exist on iOS. On other platforms `NativeComponent` renders its `fallback` widget, so you can show a Material version there.
</details>

<details>
<summary><b>Do my users need iOS 26?</b></summary>

No. The minimum is iOS 17. On iOS 26+ components use Liquid Glass. On iOS 17–18 the same components use classic materials (`.regularMaterial`, `.bordered`…) automatically. Check at runtime with `NativeSystem.info()` → `liquidGlass`.
</details>

<details>
<summary><b>My app still uses CocoaPods. Can I use this package?</b></summary>

Yes. Turn on Swift Package Manager for your app (see [Installation](#installation)). Flutter then integrates this plugin through SPM, while your other CocoaPods plugins keep working.
</details>

<details>
<summary><b>How do I get the code for a specific component?</b></summary>

Run the [example app](example) and tap the **Code** button on any component, or browse [`example/lib/snippets.dart`](example/lib/snippets.dart). Every snippet is compiled and tested against the current API.
</details>

<details>
<summary><b>What about performance?</b></summary>

Each component is a platform view. That's fine for whole screens, bars, sheets and cards. Prefer a few larger components per screen over dozens of tiny ones in a scrolling list.
</details>

<details>
<summary><b>Can I add my own SwiftUI views?</b></summary>

Yes. See [Custom native components](#custom-native-components).
</details>

## Support the project

If glassy_ui_ios saves you time, please **give it a 👍 on [pub.dev](https://pub.dev/packages/glassy_ui_ios)** and a **⭐ on [GitHub](https://github.com/rutvikpipariya/glassy_ui_ios)**. It helps other Flutter developers find it.

Found a bug or want a component? [Open an issue](https://github.com/rutvikpipariya/glassy_ui_ios/issues/new/choose). Pull requests are welcome; see [CONTRIBUTING](CONTRIBUTING.md).

## License

MIT. See [LICENSE](LICENSE).
