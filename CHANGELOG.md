## 0.2.0

* Embeddable widgets for use inside your own Flutter layouts:
  `GlassTabBar` (bar only, for `Scaffold.bottomNavigationBar`),
  `GlassIconButton` and `GlassMenuButton`. Each one is a single native
  control on a transparent background, and its tint and light/dark
  appearance come from the app's `Theme`. A `fallback` widget is shown on
  other platforms.
* `NativeDialog.alert` and `NativeDialog.actionSheet` present a native
  `UIAlertController` from Dart and return the id of the tapped action.

## 0.1.2

* Every public API is documented. Each `NativeComponentType` value lists the
  config fields, commands and events of its component.
* README redesign: banner, animated demos, comparison table and FAQ.
* pub.dev screenshots: banner and an animated Liquid Glass demo.

## 0.1.1

* Example app: a **Code** button on every component page with copy-paste
  ready Dart code (also in `example/lib/snippets.dart`). Every snippet is
  compiled and built by `example/test/snippets_test.dart`.
* Example app is Swift Package Manager only (removed leftover CocoaPods files).

## 0.1.0

* Initial release.
* 90 native SwiftUI / UIKit components across navigation, buttons, controls,
  tabs, sheets & dialogs, menus, input, progress, media and Liquid Glass.
* Liquid Glass on iOS 26+, classic materials on iOS 17–18.
* Typed Dart configuration (`NativeComponentConfig`, `NativeStyle`,
  `NativeItem`, `NativeImage`) with live updates.
* `NativeComponentController` with `trigger`, `reset`, `send` and an event stream.
* Custom Swift components via `NativeComponentRegistry`.
* Swift Package Manager integration and privacy manifest.
