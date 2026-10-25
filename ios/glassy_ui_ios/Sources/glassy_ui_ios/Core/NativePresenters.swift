import Flutter
import SwiftUI
import UIKit

/// Native UI presented from Dart without a platform view: alerts, prompts,
/// sheets, toasts and the share sheet. Backs `NativeDialog`, `NativeSheet`,
/// `NativeToast` and `NativeShare`.
enum NativePresenters {
  // MARK: Alerts

  /// `UIAlertController` alert or action sheet. Replies with the chosen action id.
  static func showAlert(_ arguments: [String: Any], result: @escaping FlutterResult) {
    guard let presenter = UIApplication.shared.topViewController else { return result(nil) }
    let style: UIAlertController.Style = arguments["style"] as? String == "actionSheet" ? .actionSheet : .alert
    let alert = UIAlertController(title: arguments.string("title"), message: arguments.string("message"), preferredStyle: style)
    alert.overrideUserInterfaceStyle = interfaceStyle(arguments)
    var actions = (arguments["actions"] as? [Any] ?? []).compactMap { NativeItem($0) }
    if actions.isEmpty { actions = [NativeItem(title: "OK", role: .cancel)] }
    for item in actions {
      let action = UIAlertAction(title: item.title, style: item.role.alertStyle) { _ in result(item.id) }
      action.isEnabled = item.isEnabled
      alert.addAction(action)
    }
    present(alert, from: presenter)
  }

  /// Alert with a text field. Replies with the text, or `nil` when cancelled.
  static func showPrompt(_ arguments: [String: Any], result: @escaping FlutterResult) {
    guard let presenter = UIApplication.shared.topViewController else { return result(nil) }
    let alert = UIAlertController(title: arguments.string("title"), message: arguments.string("message"), preferredStyle: .alert)
    alert.overrideUserInterfaceStyle = interfaceStyle(arguments)
    alert.addTextField { field in
      field.placeholder = arguments.string("placeholder")
      field.text = arguments.string("value")
      field.isSecureTextEntry = arguments.bool("secure") ?? false
      field.clearButtonMode = .whileEditing
    }
    alert.addAction(UIAlertAction(title: arguments.string("cancel") ?? "Cancel", style: .cancel) { _ in result(nil) })
    let confirm = UIAlertAction(title: arguments.string("confirm") ?? "OK", style: .default) { [weak alert] _ in
      result(alert?.textFields?.first?.text ?? "")
    }
    alert.addAction(confirm)
    alert.preferredAction = confirm
    present(alert, from: presenter)
  }

  // MARK: Sheet

  /// SwiftUI sheet with a title, message and a list of options. Replies with
  /// the chosen id, or `nil` when dismissed.
  static func showSheet(_ arguments: [String: Any], result: @escaping FlutterResult) {
    guard let presenter = UIApplication.shared.topViewController else { return result(nil) }
    let reply = OnceReply(result)
    let items = (arguments["items"] as? [Any] ?? []).compactMap { NativeItem($0) }
    let controller = UIHostingController(rootView: AnyView(EmptyView()))
    controller.rootView = AnyView(
      NativeSheetView(
        title: arguments.string("title"),
        message: arguments.string("message"),
        items: items
      ) { id in
        reply.send(id)
        controller.dismiss(animated: true)
      }
      .onDisappear { reply.send(nil) }
      .tint(arguments.color("tintColor"))
    )
    controller.overrideUserInterfaceStyle = interfaceStyle(arguments)
    if let sheet = controller.sheetPresentationController {
      let detents = arguments["detents"] as? [String] ?? ["medium", "large"]
      sheet.detents = detents.map { $0 == "large" ? .large() : .medium() }
      sheet.prefersGrabberVisible = true
    }
    presenter.present(controller, animated: true)
  }

  // MARK: Toast

  /// Glass capsule that slides in over the app and dismisses itself.
  /// Touches pass through it.
  static func showToast(_ arguments: [String: Any], result: @escaping FlutterResult) {
    guard let window = UIApplication.shared.topViewController?.view.window else { return result(nil) }
    let bottom = arguments.string("position") == "bottom"
    let host = UIHostingController(
      rootView: NativeToastView(
        message: arguments.string("message") ?? "",
        symbol: arguments.string("symbol"),
        tint: arguments.color("tintColor")
      )
    )
    host.view.backgroundColor = .clear
    host.overrideUserInterfaceStyle = interfaceStyle(arguments)
    host.view.isUserInteractionEnabled = false
    host.view.translatesAutoresizingMaskIntoConstraints = false
    window.addSubview(host.view)
    NSLayoutConstraint.activate([
      host.view.centerXAnchor.constraint(equalTo: window.centerXAnchor),
      host.view.widthAnchor.constraint(lessThanOrEqualTo: window.widthAnchor, constant: -32),
      bottom
        ? host.view.bottomAnchor.constraint(equalTo: window.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        : host.view.topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.topAnchor, constant: 8),
    ])
    let offset: CGFloat = bottom ? 120 : -120
    host.view.transform = CGAffineTransform(translationX: 0, y: offset)
    host.view.alpha = 0
    UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {
      host.view.transform = .identity
      host.view.alpha = 1
    }
    let duration = arguments.double("duration") ?? 2.2
    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
      UIView.animate(withDuration: 0.3) {
        host.view.transform = CGAffineTransform(translationX: 0, y: offset)
        host.view.alpha = 0
      } completion: { _ in
        host.view.removeFromSuperview()
        result(nil)
      }
    }
  }

  // MARK: Share

  /// `UIActivityViewController`. Replies with whether the user completed an action.
  static func share(_ arguments: [String: Any], result: @escaping FlutterResult) {
    guard let presenter = UIApplication.shared.topViewController else { return result(false) }
    var items: [Any] = []
    if let text = arguments.string("text") { items.append(text) }
    if let url = arguments.string("url").flatMap(URL.init(string:)) { items.append(url) }
    let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
    controller.completionWithItemsHandler = { _, completed, _, _ in result(completed) }
    present(controller, from: presenter)
  }

  /// Light or dark from the Dart `colorScheme` argument; the system setting otherwise.
  private static func interfaceStyle(_ arguments: [String: Any]) -> UIUserInterfaceStyle {
    switch arguments.string("colorScheme") {
    case "light": .light
    case "dark": .dark
    default: .unspecified
    }
  }

  /// Presents `controller`, anchoring popovers (iPad) to the presenter's center.
  private static func present(_ controller: UIViewController, from presenter: UIViewController) {
    if let popover = controller.popoverPresentationController {
      popover.sourceView = presenter.view
      popover.sourceRect = CGRect(x: presenter.view.bounds.midX, y: presenter.view.bounds.midY, width: 0, height: 0)
      popover.permittedArrowDirections = []
    }
    presenter.present(controller, animated: true)
  }
}

/// Calls a `FlutterResult` at most once.
private final class OnceReply {
  private var result: FlutterResult?

  init(_ result: @escaping FlutterResult) {
    self.result = result
  }

  func send(_ value: Any?) {
    result?(value)
    result = nil
  }
}

private extension NativeItem.Role {
  var alertStyle: UIAlertAction.Style {
    switch self {
    case .destructive: .destructive
    case .cancel: .cancel
    case .normal: .default
    }
  }
}

private struct NativeSheetView: View {
  let title: String?
  let message: String?
  let items: [NativeItem]
  let onSelect: (String) -> Void

  var body: some View {
    NavigationStack {
      List {
        if let message {
          Section { Text(message).foregroundStyle(.secondary) }
        }
        Section {
          ForEach(items) { item in
            Button(role: item.role.buttonRole) { onSelect(item.id) } label: {
              HStack(spacing: 12) {
                if item.image != nil { NativeIcon(item.image).frame(width: 28) }
                VStack(alignment: .leading, spacing: 2) {
                  Text(item.title)
                  if let subtitle = item.subtitle {
                    Text(subtitle).font(.footnote).foregroundStyle(.secondary)
                  }
                }
              }
              .foregroundStyle(item.role == .destructive ? AnyShapeStyle(Color.red) : AnyShapeStyle(.tint))
            }
            .disabled(!item.isEnabled)
          }
        }
      }
      .navigationTitle(title ?? "")
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}

private struct NativeToastView: View {
  let message: String
  let symbol: String?
  let tint: Color?

  var body: some View {
    HStack(spacing: 10) {
      if let symbol {
        Image(systemName: symbol).foregroundStyle(tint ?? .green)
      }
      Text(message).font(.subheadline.weight(.semibold))
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 14)
    .adaptiveGlass(Capsule())
    .padding(8)
    .accessibilityElement(children: .combine)
  }
}
