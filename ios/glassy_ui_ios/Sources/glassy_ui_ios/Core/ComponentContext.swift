import Combine
import Flutter
import SwiftUI

/// A command sent from Dart with `NativeComponentController.send`.
public struct NativeCommand {
  /// Command name. Built-in components understand `"trigger"` and `"reset"`.
  public let name: String
  /// Optional codec value sent along with the command.
  public let arguments: NativeValue?
}

/// The two-way link between one SwiftUI component and its Dart widget.
///
/// Injected as an `EnvironmentObject`; components call `emit` to deliver
/// callbacks to Dart and observe `commands` (via `onNativeCommand`).
public final class ComponentContext: ObservableObject {
  public let componentId: String
  /// Latest configuration received from Dart.
  @Published public internal(set) var config: NativeConfig
  /// Stream of commands sent from Dart.
  public let commands = PassthroughSubject<NativeCommand, Never>()

  private let channel: FlutterMethodChannel

  init(componentId: String, config: NativeConfig, channel: FlutterMethodChannel) {
    self.componentId = componentId
    self.config = config
    self.channel = channel
  }

  /// Sends an event to Dart. `value` must be codec compatible
  /// (`Bool`, numbers, `String`, arrays, dictionaries or `nil`).
  public func emit(_ event: String, _ value: Any? = nil) {
    let payload: [String: Any] = [
      "component": componentId,
      "event": event,
      "value": value ?? NSNull(),
    ]
    if Thread.isMainThread {
      channel.invokeMethod("onEvent", arguments: payload)
    } else {
      DispatchQueue.main.async { [channel] in channel.invokeMethod("onEvent", arguments: payload) }
    }
  }
}

/// Root of every hosted component: publishes the context, configuration and
/// style into the environment and applies global style values.
struct ComponentRoot: View {
  @ObservedObject var context: ComponentContext
  let content: AnyView

  var body: some View {
    let config = context.config
    let style = config.style
    content
      .environmentObject(context)
      .environment(\.nativeConfig, config)
      .environment(\.nativeStyle, style)
      .tint(style.tint)
      .fontDesign(style.fontDesign)
      .controlSize(style.controlSize ?? .regular)
      .disabled(!config.isEnabled)
  }
}

// MARK: - View helpers

private struct NativeCommandModifier: ViewModifier {
  @EnvironmentObject private var context: ComponentContext
  let handler: (NativeCommand) -> Void

  func body(content: Content) -> some View {
    content.onReceive(context.commands, perform: handler)
  }
}

extension View {
  /// Calls `handler` for every command Dart sends to this component.
  public func onNativeCommand(_ handler: @escaping (NativeCommand) -> Void) -> some View {
    modifier(NativeCommandModifier(handler: handler))
  }

  /// Keeps local `@State` in sync with a value configured from Dart: applied
  /// on appear and whenever the configured value changes.
  public func seed<Value: Equatable>(_ state: Binding<Value>, from value: Value) -> some View {
    onAppear { state.wrappedValue = value }
      .onChange(of: value) { _, newValue in state.wrappedValue = newValue }
  }

  /// Like `seed(_:from:)`, but leaves the state untouched while no value is
  /// configured. Use it when the fallback is not stable across renders
  /// (e.g. `Date()`), which would otherwise re-seed on every update.
  public func seed<Value: Equatable>(_ state: Binding<Value>, from value: Value?) -> some View {
    onAppear { if let value { state.wrappedValue = value } }
      .onChange(of: value) { _, newValue in if let newValue { state.wrappedValue = newValue } }
  }
}
