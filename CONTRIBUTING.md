# Contributing

Thanks for helping improve glassy_ui_ios! Bug reports, component requests and pull requests are all welcome.

## Setup

```sh
git clone https://github.com/rutvikpipariya/glassy_ui_ios.git
cd glassy_ui_ios/example
flutter run   # iOS simulator or device, Xcode 26+
```

Open one component directly with `flutter run --dart-define=COMPONENT=glass-morphing`.

## Project layout

| Path | Contents |
| --- | --- |
| `lib/` | Dart API: `NativeComponent`, config types, `NativeComponentType` |
| `ios/glassy_ui_ios/Sources/glassy_ui_ios/` | Swift package: core, styling and the 90 components |
| `example/` | Catalog app with live customization and copy-paste code |
| `tool/` | README, snippet and banner generators |

## Adding a component

1. Write a SwiftUI view conforming to `NativeComponent` in `Components/`, with a doc comment listing the config fields, commands and events it uses.
2. Register it in `BuiltInComponents.swift`.
3. Add a `NativeComponentType` value in `lib/src/component_type.dart` with the same doc comment.
4. Add its snippet to `tool/generate_snippets.py` and run `python3 tool/generate_snippets.py`.
5. Add a screenshot to `screenshots/components/<id>.jpg` and run `python3 tool/generate_readme.py`.

## Before opening a pull request

```sh
dart format lib test example/lib example/test
flutter analyze && flutter test
(cd example && flutter analyze && flutter test)
```

Glass APIs need an `if #available(iOS 26, *)` path and an iOS 17–18 fallback. Use the helpers in `Styling/Glass.swift`.
