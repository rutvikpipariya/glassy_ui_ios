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
    NativeComponentRegistry.register(EmbeddableComponents.all)

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
    case "showAlert":
      Self.showAlert(call.arguments as? [String: Any] ?? [:], result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  /// Presents a `UIAlertController` from the top-most controller and replies
  /// with the id of the chosen action (`nil` if nothing could be presented).
  private static func showAlert(_ arguments: [String: Any], result: @escaping FlutterResult) {
    guard let presenter = UIApplication.shared.topViewController else {
      result(nil)
      return
    }
    let style: UIAlertController.Style = arguments["style"] as? String == "actionSheet" ? .actionSheet : .alert
    let alert = UIAlertController(
      title: arguments["title"] as? String,
      message: arguments["message"] as? String,
      preferredStyle: style
    )
    var actions = (arguments["actions"] as? [Any] ?? []).compactMap { NativeItem($0) }
    if actions.isEmpty { actions = [NativeItem(title: "OK", role: .cancel)] }
    for item in actions {
      let actionStyle: UIAlertAction.Style = switch item.role {
      case .destructive: .destructive
      case .cancel: .cancel
      case .normal: .default
      }
      let action = UIAlertAction(title: item.title, style: actionStyle) { _ in result(item.id) }
      action.isEnabled = item.isEnabled
      alert.addAction(action)
    }
    // Action sheets on iPad need an anchor; center it on the presenter.
    if let popover = alert.popoverPresentationController {
      popover.sourceView = presenter.view
      popover.sourceRect = CGRect(x: presenter.view.bounds.midX, y: presenter.view.bounds.midY, width: 0, height: 0)
      popover.permittedArrowDirections = []
    }
    presenter.present(alert, animated: true)
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
