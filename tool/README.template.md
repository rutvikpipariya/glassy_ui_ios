<p align="center">
  <img src="{{RAW}}/screenshots/banner.png" alt="glassy_ui_ios: 90 native iOS components for Flutter" width="100%">
</p>

<p align="center">
  <a href="https://pub.dev/packages/glassy_ui_ios"><img src="https://img.shields.io/pub/v/glassy_ui_ios.svg?label=pub.dev&color=0175C2" alt="pub version"></a>
  <a href="https://pub.dev/packages/glassy_ui_ios/score"><img src="https://img.shields.io/pub/likes/glassy_ui_ios?color=ff4f8b" alt="pub likes"></a>
  <a href="https://pub.dev/packages/glassy_ui_ios/score"><img src="https://img.shields.io/pub/points/glassy_ui_ios?color=2ea44f" alt="pub points"></a>
  <a href="https://pub.dev/packages/glassy_ui_ios"><img src="https://img.shields.io/pub/dm/glassy_ui_ios?color=8a2be2" alt="downloads"></a>
  <a href="https://github.com/rutvikpipariya/glassy_ui_ios/actions/workflows/ci.yml"><img src="https://github.com/rutvikpipariya/glassy_ui_ios/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
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
    <td align="center"><img src="{{RAW}}/screenshots/demo/glass-morphing.gif" width="190" alt="Glass morphing"><br><sub><b>Glass morphing</b><br><code>glassMorphing</code></sub></td>
    <td align="center"><img src="{{RAW}}/screenshots/demo/floating-action-button.gif" width="190" alt="Floating action button"><br><sub><b>Floating action button</b><br><code>floatingActionButton</code></sub></td>
    <td align="center"><img src="{{RAW}}/screenshots/demo/glass-transition.gif" width="190" alt="Glass transition"><br><sub><b>Glass transition</b><br><code>glassTransition</code></sub></td>
    <td align="center"><img src="{{RAW}}/screenshots/demo/download-progress.gif" width="190" alt="Download progress"><br><sub><b>App Store download</b><br><code>downloadProgress</code></sub></td>
  </tr>
</table>

<p align="center">
  <img src="{{RAW}}/screenshots/catalog.png" width="200" alt="Catalog">
  <img src="{{RAW}}/screenshots/glass_container.png" width="200" alt="Glass effect container">
  <img src="{{RAW}}/screenshots/media_controls.png" width="200" alt="Media controls">
  <img src="{{RAW}}/screenshots/toolbar.png" width="200" alt="Toolbar">
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
  glassy_ui_ios: ^{{VERSION}}
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

{{GALLERY}}

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

Run the [example app](example) and tap the **Code** button on any component, or browse [`example/lib/snippets.dart`](example/lib/snippets.dart). Every snippet is compiled in CI.
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
