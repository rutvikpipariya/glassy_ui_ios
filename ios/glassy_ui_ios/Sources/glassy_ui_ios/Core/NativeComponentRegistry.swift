import SwiftUI

/// A SwiftUI view that can be created from Dart by its `componentId`.
///
/// Conform your own views to add custom components from the host app:
/// ```swift
/// struct RatingView: NativeComponent {
///   static let componentId = "rating"
///   @Environment(\.nativeConfig) private var config
///   @EnvironmentObject private var context: ComponentContext
///   var body: some View { … }
/// }
/// NativeComponentRegistry.register(RatingView.self)
/// ```
/// and in Dart: `NativeComponent.custom(id: 'rating')`.
public protocol NativeComponent: View {
  /// Identifier used by Dart (`NativeComponentType.id`).
  static var componentId: String { get }
  init()
}

/// Maps component identifiers to view builders.
public enum NativeComponentRegistry {
  private static var builders: [String: () -> AnyView] = [:]
  private static var order: [String] = []

  /// Registers a component type. Registering an existing id replaces it.
  public static func register<Component: NativeComponent>(_ type: Component.Type) {
    let id = Component.componentId
    if builders[id] == nil { order.append(id) }
    builders[id] = { AnyView(Component()) }
  }

  /// Registers several component types at once.
  public static func register(_ types: [any NativeComponent.Type]) {
    for type in types { register(type) }
  }

  /// Identifiers in registration order.
  public static var registeredIds: [String] { order }

  static func makeView(for id: String) -> AnyView {
    if let build = builders[id] { return build() }
    return AnyView(UnknownComponent(id: id))
  }
}

private struct UnknownComponent: View {
  let id: String

  var body: some View {
    ComponentScaffold {
      GlassCard("Unknown component") {
        Text("No native component is registered for “\(id)”.").foregroundStyle(.secondary)
      }
    }
  }
}
