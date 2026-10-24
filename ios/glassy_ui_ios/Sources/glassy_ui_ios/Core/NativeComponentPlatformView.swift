import Flutter
import SwiftUI
import UIKit

extension FlutterStandardTypedData: FlutterStandardTypedDataProtocol {
  var payload: Data { data }
}

/// Creates a `NativeComponentPlatformView` for every Dart `UiKitView`.
final class NativeComponentFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
    NativeComponentPlatformView(frame: frame, viewId: viewId, arguments: args as? [String: Any] ?? [:], messenger: messenger)
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }
}

/// One hosted SwiftUI component plus its per-view method channel
/// `glassy_ui_ios/view_<id>`.
///
/// Dart → native: `update(config)`, `command({name, arguments})`
/// Native → Dart: `onEvent({component, event, value})`
final class NativeComponentPlatformView: NSObject, FlutterPlatformView {
  private let container: HostingContainerView
  private let channel: FlutterMethodChannel
  private let context: ComponentContext

  init(frame: CGRect, viewId: Int64, arguments: [String: Any], messenger: FlutterBinaryMessenger) {
    let id = arguments["id"] as? String ?? ""
    let config = NativeConfig(arguments["config"] as? [String: Any] ?? [:])
    channel = FlutterMethodChannel(name: "glassy_ui_ios/view_\(viewId)", binaryMessenger: messenger)
    context = ComponentContext(componentId: id, config: config, channel: channel)

    let root = ComponentRoot(context: context, content: NativeComponentRegistry.makeView(for: id))
    let hosting = UIHostingController(rootView: root)
    hosting.view.backgroundColor = .clear
    hosting.overrideUserInterfaceStyle = config.style.userInterfaceStyle
    // Flutter creates platform views with a zero frame. Starting from a real
    // size lets navigation bars compute their layout margins correctly
    // (otherwise large titles can end up flush with the leading edge).
    let initialFrame = frame.isEmpty ? CGRect(origin: .zero, size: UIScreen.main.bounds.size) : frame
    container = HostingContainerView(frame: initialFrame, hosting: hosting)
    super.init()

    channel.setMethodCallHandler { [weak self] call, result in
      self?.handle(call, result: result)
    }
  }

  deinit {
    channel.setMethodCallHandler(nil)
  }

  func view() -> UIView { container }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "update":
      let config = NativeConfig(call.arguments as? [String: Any] ?? [:])
      if config != context.config {
        context.config = config
        container.hosting.overrideUserInterfaceStyle = config.style.userInterfaceStyle
      }
      result(nil)
    case "command":
      let map = call.arguments as? [String: Any] ?? [:]
      let command = NativeCommand(name: map["name"] as? String ?? "trigger", arguments: NativeValue(map["arguments"]))
      context.commands.send(command)
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

/// Hosts the SwiftUI tree and attaches its controller to the nearest Flutter
/// view controller so sheets, alerts, popovers and menus present natively.
final class HostingContainerView: UIView {
  let hosting: UIHostingController<ComponentRoot>

  init(frame: CGRect, hosting: UIHostingController<ComponentRoot>) {
    self.hosting = hosting
    super.init(frame: frame)
    hosting.view.frame = bounds
    hosting.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    addSubview(hosting.view)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  override func didMoveToWindow() {
    super.didMoveToWindow()
    if window != nil, hosting.parent == nil, let parent = nearestViewController() {
      parent.addChild(hosting)
      hosting.didMove(toParent: parent)
      // Navigation bars resolve their layout margins (e.g. large title
      // insets) from the window; re-layout now that one is available.
      hosting.view.setNeedsLayout()
      hosting.view.layoutIfNeeded()
    } else if window == nil, hosting.parent != nil {
      hosting.willMove(toParent: nil)
      hosting.removeFromParent()
    }
  }

  private var lastLayoutSize = CGSize.zero

  override func layoutSubviews() {
    super.layoutSubviews()
    guard bounds.size != lastLayoutSize else { return }
    lastLayoutSize = bounds.size
    hosting.view.setNeedsLayout()
  }

  private func nearestViewController() -> UIViewController? {
    var responder: UIResponder? = superview
    while let current = responder {
      if let controller = current as? UIViewController { return controller }
      responder = current.next
    }
    return window?.rootViewController
  }
}

extension UIApplication {
  /// Top-most presented controller of the key window, used by UIKit components.
  var topViewController: UIViewController? {
    let scenes = connectedScenes.compactMap { $0 as? UIWindowScene }
    let window = scenes.flatMap(\.windows).first(where: \.isKeyWindow) ?? scenes.first?.windows.first
    var top = window?.rootViewController
    while let presented = top?.presentedViewController { top = presented }
    return top
  }
}
