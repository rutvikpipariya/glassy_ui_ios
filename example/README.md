# glassy_ui_ios example

Catalog of all 90 `glassy_ui_ios` components, each rendered natively.

- Open any component from the list.
- **Customize** (top-right) edits title, SF Symbol, tint, background, glass, corner radius, appearance and font live through `NativeComponentConfig`.
- **Trigger** / **Reset** call `NativeComponentController.trigger()` / `reset()`.
- The bottom panel logs every `NativeEvent` sent from Swift.

```sh
cd example
flutter run
```

Requires iOS 17+ (Liquid Glass on iOS 26+) and Swift Package Manager (enabled in this example's `pubspec.yaml`).

To open one component directly: `flutter run --dart-define=COMPONENT=glass-morphing`.
