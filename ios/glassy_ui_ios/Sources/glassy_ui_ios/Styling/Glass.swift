import SwiftUI

/// Runtime check for Liquid Glass (iOS 26+).
public enum GlassSupport {
  public static var isAvailable: Bool {
    if #available(iOS 26.0, *) { return true }
    return false
  }
}

// MARK: - Explicit glass

extension View {
  /// Applies glass in `shape`: `.glassEffect` on iOS 26+, a material with a
  /// hairline stroke on iOS 17–18, or a solid `surface` for `.none`.
  @ViewBuilder
  public func adaptiveGlass<S: Shape>(
    _ shape: S,
    variant: NativeGlassVariant = .regular,
    tint: Color? = nil,
    interactive: Bool = false,
    surface: Color? = nil
  ) -> some View {
    if variant == .none {
      background(tint?.opacity(0.35) ?? Color.clear, in: shape)
        .background(surface ?? Color(.secondarySystemBackground), in: shape)
    } else if #available(iOS 26.0, *) {
      glassEffect((variant == .clear ? Glass.clear : Glass.regular).tint(tint).interactive(interactive), in: shape)
    } else {
      background(tint?.opacity(0.35) ?? Color.clear, in: shape)
        .background(variant == .clear ? Material.ultraThin : Material.regular, in: shape)
        .overlay(shape.stroke(Color.white.opacity(0.3), lineWidth: 0.5))
        .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
    }
  }

  /// `glassEffectID` morphing on iOS 26+, `matchedGeometryEffect` otherwise.
  @ViewBuilder
  public func adaptiveGlassID<ID: Hashable & Sendable>(_ id: ID, in namespace: Namespace.ID) -> some View {
    if #available(iOS 26.0, *) {
      glassEffectID(id, in: namespace)
    } else {
      matchedGeometryEffect(id: id, in: namespace)
    }
  }

  /// Merges glass shapes sharing `id` into one surface (iOS 26+ only).
  @ViewBuilder
  public func adaptiveGlassUnion<ID: Hashable & Sendable>(_ id: ID, in namespace: Namespace.ID) -> some View {
    if #available(iOS 26.0, *) {
      glassEffectUnion(id: id, namespace: namespace)
    } else {
      self
    }
  }

  /// iOS 26 scroll-edge effect under bars; no-op on older systems.
  @ViewBuilder
  public func adaptiveScrollEdge(hard: Bool = false) -> some View {
    if #available(iOS 26.0, *) {
      scrollEdgeEffectStyle(hard ? .hard : .soft, for: .all)
    } else {
      self
    }
  }
}

// MARK: - Style-aware glass

/// Glass that follows the component's `NativeStyle` (variant, tint, interactivity, surface).
struct StyledGlass<S: Shape>: ViewModifier {
  @Environment(\.nativeStyle) private var style
  let shape: S
  let tint: Color?
  let interactive: Bool?

  func body(content: Content) -> some View {
    content.adaptiveGlass(
      shape,
      variant: style.glass,
      tint: tint ?? style.glassTint,
      interactive: interactive ?? style.interactive,
      surface: style.surface
    )
  }
}

/// `.glass` / `.glassProminent` on iOS 26+, `.bordered` / `.borderedProminent`
/// on older systems or when the style disables glass.
struct StyledButton: ViewModifier {
  @Environment(\.nativeStyle) private var style
  let prominent: Bool

  func body(content: Content) -> some View {
    if #available(iOS 26.0, *), style.glass != .none {
      if prominent { content.buttonStyle(.glassProminent) } else { content.buttonStyle(.glass) }
    } else {
      if prominent { content.buttonStyle(.borderedProminent) } else { content.buttonStyle(.bordered) }
    }
  }
}

extension View {
  /// Style-aware glass in `shape`.
  public func nativeGlass<S: Shape>(_ shape: S, tint: Color? = nil, interactive: Bool? = nil) -> some View {
    modifier(StyledGlass(shape: shape, tint: tint, interactive: interactive))
  }

  /// Style-aware glass in a capsule.
  public func nativeGlass(tint: Color? = nil, interactive: Bool? = nil) -> some View {
    modifier(StyledGlass(shape: Capsule(), tint: tint, interactive: interactive))
  }

  /// Style-aware glass button style.
  public func nativeButtonStyle(prominent: Bool = false) -> some View {
    modifier(StyledButton(prominent: prominent))
  }
}

/// `GlassEffectContainer` on iOS 26+, a passthrough otherwise.
public struct AdaptiveGlassContainer<Content: View>: View {
  private let spacing: CGFloat?
  private let content: Content

  public init(spacing: CGFloat? = nil, @ViewBuilder content: () -> Content) {
    self.spacing = spacing
    self.content = content()
  }

  public var body: some View {
    if #available(iOS 26.0, *) {
      GlassEffectContainer(spacing: spacing) { content }
    } else {
      content
    }
  }
}
