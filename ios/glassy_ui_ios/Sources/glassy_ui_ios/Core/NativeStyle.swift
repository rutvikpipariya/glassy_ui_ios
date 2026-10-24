import SwiftUI

/// Glass appearance requested from Dart.
public enum NativeGlassVariant: String {
  /// `Glass.regular` on iOS 26+, `.regularMaterial` before.
  case regular
  /// `Glass.clear` on iOS 26+, `.ultraThinMaterial` before.
  case clear
  /// No glass: a solid surface using the style's surface color.
  case none
}

/// Visual customization shared by every component (`NativeStyle` in Dart).
///
/// Every property is optional; `nil` means "use the component's default".
public struct NativeStyle: Equatable {
  /// Accent color applied with `.tint(_:)` (buttons, toggles, sliders…).
  public var tint: Color?
  /// Color of primary text and icons.
  public var foreground: Color?
  /// Solid background behind the component. Overrides the decorative backdrop.
  public var background: Color?
  /// Gradient background behind the component. Overrides the decorative backdrop.
  public var backgroundGradient: [Color]?
  /// Shows the colorful decorative backdrop when no background is set.
  public var showBackdrop = true
  /// Color of cards and glass-less surfaces.
  public var surface: Color?
  /// Corner radius of cards, sheets and rounded glass shapes.
  public var cornerRadius: CGFloat?
  /// Glass variant for glass surfaces.
  public var glass: NativeGlassVariant = .regular
  /// Optional tint mixed into glass surfaces.
  public var glassTint: Color?
  /// Whether glass reacts to touch (`Glass.interactive()`).
  public var interactive = true
  /// Outer padding of the component content.
  public var padding: CGFloat?
  /// Spacing between repeated elements.
  public var spacing: CGFloat?
  /// Font size of titles. `nil` keeps the semantic text style.
  public var fontSize: CGFloat?
  public var fontWeight: Font.Weight?
  public var fontDesign: Font.Design?
  /// Forces light or dark appearance. `nil` follows the system.
  public var colorScheme: ColorScheme?
  public var controlSize: ControlSize?

  public init() {}

  init(_ map: [String: Any]) {
    tint = map.color("tintColor")
    foreground = map.color("foregroundColor")
    background = map.color("backgroundColor")
    backgroundGradient = map.colors("backgroundGradient")
    showBackdrop = map.bool("showBackdrop") ?? true
    surface = map.color("surfaceColor")
    cornerRadius = map.cgFloat("cornerRadius")
    glass = map.string("glass").flatMap(NativeGlassVariant.init(rawValue:)) ?? .regular
    glassTint = map.color("glassTint")
    interactive = map.bool("interactive") ?? true
    padding = map.cgFloat("padding")
    spacing = map.cgFloat("spacing")
    fontSize = map.cgFloat("fontSize")
    fontWeight = map.string("fontWeight").flatMap(Self.weight)
    fontDesign = map.string("fontDesign").flatMap(Self.design)
    colorScheme = map.string("colorScheme").flatMap(Self.scheme)
    controlSize = map.string("controlSize").flatMap(Self.size)
  }

  /// Title font honoring `fontSize`, `fontWeight` and `fontDesign`.
  public func titleFont(_ fallback: Font) -> Font {
    guard let fontSize else { return fallback.weight(fontWeight ?? .semibold) }
    return .system(size: fontSize, weight: fontWeight ?? .semibold, design: fontDesign ?? .default)
  }

  /// Corner radius with a component-specific default.
  public func radius(_ fallback: CGFloat) -> CGFloat { cornerRadius ?? fallback }

  var userInterfaceStyle: UIUserInterfaceStyle {
    switch colorScheme {
    case .light: .light
    case .dark: .dark
    default: .unspecified
    }
  }

  private static func weight(_ name: String) -> Font.Weight? {
    ["ultraLight": .ultraLight, "thin": .thin, "light": .light, "regular": .regular, "medium": .medium,
     "semibold": .semibold, "bold": .bold, "heavy": .heavy, "black": .black][name]
  }

  private static func design(_ name: String) -> Font.Design? {
    ["default": .default, "rounded": .rounded, "serif": .serif, "monospaced": .monospaced][name]
  }

  private static func scheme(_ name: String) -> ColorScheme? {
    ["light": .light, "dark": .dark][name]
  }

  private static func size(_ name: String) -> ControlSize? {
    ["mini": .mini, "small": .small, "regular": .regular, "large": .large, "extraLarge": .extraLarge][name]
  }
}

// MARK: - Environment

private struct NativeStyleKey: EnvironmentKey {
  static let defaultValue = NativeStyle()
}

private struct NativeConfigKey: EnvironmentKey {
  static let defaultValue = NativeConfig()
}

extension EnvironmentValues {
  /// Style of the enclosing native component, set from Dart.
  public var nativeStyle: NativeStyle {
    get { self[NativeStyleKey.self] }
    set { self[NativeStyleKey.self] = newValue }
  }

  /// Full configuration of the enclosing native component, set from Dart.
  public var nativeConfig: NativeConfig {
    get { self[NativeConfigKey.self] }
    set { self[NativeConfigKey.self] = newValue }
  }
}
