# glassy_ui_ios

[![pub package](https://img.shields.io/pub/v/glassy_ui_ios.svg)](https://pub.dev/packages/glassy_ui_ios)
[![platform](https://img.shields.io/badge/platform-iOS%2017%2B-blue.svg)](https://pub.dev/packages/glassy_ui_ios)
[![license: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

**90 real native iOS components for Flutter**, written in SwiftUI and UIKit and embedded as platform views.
On **iOS 26+** they use Apple's **Liquid Glass**. On **iOS 17–18** they fall back to classic materials automatically.
Everything is configurable from Dart, with no Cupertino widgets involved.

<p align="center">
  <img src="{{RAW}}/screenshots/catalog.png" width="230" alt="Catalog">
  <img src="{{RAW}}/screenshots/glass_container.png" width="230" alt="Glass effect container">
  <img src="{{RAW}}/screenshots/media_controls.png" width="230" alt="Media controls">
</p>

## Features

- **90 components**: navigation bars, toolbars, glass buttons, tab bars, sidebars, split views, sheets, alerts, menus, pickers, progress, media and camera controls, and Liquid Glass effects. See the [gallery](#component-gallery) below.
- **Truly native**: SwiftUI and UIKit render each component, so system sheets, menus, popovers and haptics behave exactly like iOS.
- **Adaptive design**: `glassEffect`, `.glass` / `.glassProminent`, `GlassEffectContainer` and glass morphing on iOS 26+, with material fallbacks on iOS 17–18.
- **Configurable from Dart**: title, images (SF Symbols, assets, bytes), items, values, colors, background, corner radius, glass variant, fonts and light/dark. Changes apply **live**.
- **Two-way communication**: every interaction comes back to Dart as a `NativeEvent`, and Dart drives components with `trigger()`, `reset()` and custom commands.
- **Extensible**: register your own SwiftUI views and use them from Dart.
- **Swift Package Manager** and a privacy manifest are included.

## Requirements

| | Minimum |
| --- | --- |
| iOS | 17.0 (Liquid Glass needs iOS 26) |
| Flutter | 3.27 |
| Xcode | 26 (to compile the Liquid Glass APIs) |
| Integration | Swift Package Manager |

## Installation

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

## License

MIT. See [LICENSE](LICENSE).
