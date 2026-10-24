import Flutter
import UIKit

/// Flutter entry point. Registers the `glassy_ui_ios/view` platform
/// view, the `glassy_ui_ios/system` channel and all built-in components.
public final class GlassyUiIosPlugin: NSObject, FlutterPlugin {
  /// View type used by `UiKitView` in Dart.
  public static let viewType = "glassy_ui_ios/view"

  public static func register(with registrar: FlutterPluginRegistrar) {
    NativeAssets.lookupKey = { registrar.lookupKey(forAsset: $0) }
    NativeComponentRegistry.register(BuiltInComponents.all)

    let messenger = registrar.messenger()
    registrar.register(NativeComponentFactory(messenger: messenger), withId: viewType)

    let system = FlutterMethodChannel(name: "glassy_ui_ios/system", binaryMessenger: messenger)
    registrar.addMethodCallDelegate(GlassyUiIosPlugin(), channel: system)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getInfo":
      result([
        "systemName": UIDevice.current.systemName,
        "systemVersion": UIDevice.current.systemVersion,
        "model": UIDevice.current.model,
        "liquidGlass": GlassSupport.isAvailable,
        "components": NativeComponentRegistry.registeredIds,
      ])
    case "haptic":
      Self.playHaptic(call.arguments as? String ?? "light")
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private static func playHaptic(_ style: String) {
    switch style {
    case "success": UINotificationFeedbackGenerator().notificationOccurred(.success)
    case "warning": UINotificationFeedbackGenerator().notificationOccurred(.warning)
    case "error": UINotificationFeedbackGenerator().notificationOccurred(.error)
    case "selection": UISelectionFeedbackGenerator().selectionChanged()
    case "medium": UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    case "heavy": UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    default: UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
  }
}
