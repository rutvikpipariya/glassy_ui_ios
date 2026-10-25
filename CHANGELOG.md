## 0.3.1

* README: a **Widget examples** section with copy-paste code for every
  `Glass…` widget and native presenter, grouped by section, plus a full
  screen example.

## 0.3.0

* Typed `Glass…` widgets for every everyday control, sized like normal
  widgets and themed from the app:
  * Navigation: `GlassToolbar`, `GlassBackButton`, `GlassCloseButton`;
    `GlassTabBar` gains `expandable` and `safeArea`.
  * Buttons: `GlassButton`, `GlassFloatingActionButton`, `GlassAvatarButton`,
    `GlassImageButton`; `GlassIconButton` gains `semanticLabel`.
  * Menus: `GlassPopupButton`; `GlassMenuButton` gains `showChevron` for
    icon-only (overflow) menus.
  * Controls: `GlassSegmentedControl`, `GlassSwitch`, `GlassStepper`,
    `GlassSlider`, `GlassPageIndicator`, `GlassCheckbox`.
  * Input: `GlassTextField`, `GlassSearchBar` (with
    `GlassTextFieldController`), `GlassDatePicker`, `GlassWheelPicker`,
    `GlassColorPicker`.
  * Progress & media: `GlassProgressIndicator`, `GlassPlayPauseButton`,
    `GlassMediaControls`.
* Most widgets fall back to their Material equivalent on other platforms.
* Inside scroll views the widgets claim only taps (sliders also claim
  horizontal drags; wheels and calendars all drags), so lists still scroll.
* New native presenters: `NativeDialog.prompt`, `NativeSheet.show`,
  `NativeToast.show` and `NativeShare.share`. With a `context:` they follow
  the app's light/dark theme and show Material equivalents off iOS.
* Example app: a **Widgets** tab with every widget and presenter, next to the
  component catalog, behind a `GlassTabBar`.

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
