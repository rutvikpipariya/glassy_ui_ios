import SwiftUI
import UIKit

// Sheets, dialogs and overlays.
//
// Every presenter shows a screen with a "present" button
// (`extra.buttonTitle`). Commands: `trigger` presents. Events: `presented`,
// `dismissed` and the chosen action.

/// Screen with a single present button, shared by presentation components.
private struct PresenterScreen: View {
  @Environment(\.nativeConfig) private var config
  let caption: String
  let action: () -> Void

  var body: some View {
    ComponentScaffold {
      GlassCard(caption) {
        Text("Tap below or call `trigger()` from Dart to present natively.").foregroundStyle(.secondary)
        Button(action: action) {
          Label { Text(config.extra("buttonTitle", or: "Present")) } icon: {
            NativeIcon(config.image, fallback: "rectangle.portrait.on.rectangle.portrait")
          }
          .frame(maxWidth: .infinity)
        }
        .controlSize(.large)
        .nativeButtonStyle(prominent: true)
      }
    }
  }
}

/// Sheet body: a titled list of the configured `items`.
private struct SheetContent: View {
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  let fallbackTitle: String

  var body: some View {
    NavigationStack {
      List(Array(config.items(or: SampleItems.make(20)).enumerated()), id: \.element.id) { index, item in
        Button { context.emit("select", item.id) } label: { ItemRow(item, index: index) }.tint(.primary)
      }
      .navigationTitle(config.title ?? fallbackTitle)
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}

/// Applies `style.cornerRadius` and `style.backgroundColor` to a presented sheet.
private struct SheetStyle: ViewModifier {
  @Environment(\.nativeStyle) private var style

  func body(content: Content) -> some View {
    content
      .presentationCornerRadius(style.cornerRadius)
      .presentationBackground(style.background.map { AnyShapeStyle($0) } ?? AnyShapeStyle(.regularMaterial))
  }
}

/// Maps a detent name from Dart ("medium", "large", "0.25", "120pt").
private func detent(named name: String) -> PresentationDetent {
  switch name {
  case "medium": return .medium
  case "large": return .large
  default:
    if name.hasSuffix("pt"), let height = Double(name.dropLast(2)) { return .height(height) }
    if let fraction = Double(name) { return .fraction(fraction) }
    return .medium
  }
}

/// Persistent Maps-style sheet that allows interacting with the content behind it.
///
/// - `title`, `placeholder` (header text), `items`
/// - `extra.detents`: detent names (default ["120pt", "medium", "large"])
/// - Events: `presented`, `dismissed`, `detent(String)`, `select(itemId)`
struct BottomSheetComponent: NativeComponent {
  static let componentId = "bottom-sheet"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @State private var show = false
  @State private var selected = "120pt"

  var body: some View {
    let names = config.extra("detents", or: ["120pt", "medium", "large"])
    PresenterScreen(caption: config.subtitle ?? "Persistent bottom sheet") { show = true }
      .sheet(isPresented: $show) {
        VStack(alignment: .leading, spacing: 16) {
          HStack {
            Image(systemName: "magnifyingglass")
            Text(config.placeholder ?? "Search Maps").foregroundStyle(.secondary)
            Spacer()
            CloseButton { show = false }
          }
          .padding(.top, 20)
          ForEach(Array(config.items(or: SampleItems.make(6)).enumerated()), id: \.element.id) { index, item in
            ItemRow(item, index: index).onTapGesture { context.emit("select", item.id) }
          }
          Spacer()
        }
        .padding(.horizontal, 20)
        .presentationDetents(Set(names.map(detent(named:))), selection: Binding(
          get: { detent(named: selected) },
          set: { value in selected = names.first { detent(named: $0) == value } ?? selected }
        ))
        .presentationBackgroundInteraction(.enabled(upThrough: .medium))
        .modifier(SheetStyle())
      }
      .seed($selected, from: names.first ?? "medium")
      .onChange(of: show) { _, value in context.emit(value ? "presented" : "dismissed") }
      .onChange(of: selected) { _, value in context.emit("detent", value) }
      .onNativeCommand { _ in show.toggle() }
  }
}

/// Half-height sheet (`.medium` detent).
///
/// - `title`, `items`; Events: `presented`, `dismissed`, `select(itemId)`
struct HalfSheetComponent: NativeComponent {
  static let componentId = "half-sheet"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @State private var show = false

  var body: some View {
    PresenterScreen(caption: config.subtitle ?? "presentationDetents([.medium])") { show = true }
      .sheet(isPresented: $show) {
        SheetContent(fallbackTitle: "Half Sheet")
          .presentationDetents([.medium])
          .modifier(SheetStyle())
      }
      .onChange(of: show) { _, value in context.emit(value ? "presented" : "dismissed") }
      .onNativeCommand { _ in show = true }
  }
}

/// Full-screen cover with a close button.
///
/// - `title`, `message`; Events: `presented`, `dismissed`
struct FullSheetComponent: NativeComponent {
  static let componentId = "full-sheet"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @State private var show = false

  var body: some View {
    PresenterScreen(caption: config.subtitle ?? "fullScreenCover") { show = true }
      .fullScreenCover(isPresented: $show) {
        NavigationStack {
          ComponentScaffold {
            GlassCard(config.title ?? "Full screen") {
              Text(config.message ?? "Covers the whole Flutter app natively.")
            }
          }
          .toolbar {
            ToolbarItem(placement: .topBarTrailing) { CloseButton { show = false } }
          }
        }
      }
      .onChange(of: show) { _, value in context.emit(value ? "presented" : "dismissed") }
      .onNativeCommand { _ in show = true }
  }
}

/// Sheet with several detents and buttons to jump between them.
///
/// - `extra.detents` (default ["0.25", "medium", "large"])
/// - Events: `detent(String)`
struct DetentedSheetComponent: NativeComponent {
  static let componentId = "detented-sheet"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @State private var show = false
  @State private var selected = "medium"

  var body: some View {
    let names = config.extra("detents", or: ["0.25", "medium", "large"])
    PresenterScreen(caption: config.subtitle ?? "Custom detents") { show = true }
      .sheet(isPresented: $show) {
        VStack(spacing: 16) {
          Text("\(config.title ?? "Detent"): \(selected)").font(.headline).padding(.top, 24)
          HStack {
            ForEach(names, id: \.self) { name in
              Button(name) { withAnimation { selected = name } }
                .nativeButtonStyle(prominent: name == selected)
            }
          }
          Spacer()
        }
        .presentationDetents(Set(names.map(detent(named:))), selection: Binding(
          get: { detent(named: selected) },
          set: { value in selected = names.first { detent(named: $0) == value } ?? selected }
        ))
        .modifier(SheetStyle())
      }
      .seed($selected, from: names.count > 1 ? names[1] : names.first ?? "medium")
      .onChange(of: selected) { _, value in context.emit("detent", value) }
      .onNativeCommand { _ in show = true }
  }
}

/// Sheet with a configurable drag indicator.
///
/// - `value`: initial indicator visibility (default true); `title`, `message`
/// - Events: `indicator(Bool)`, `presented`, `dismissed`
struct DragIndicatorComponent: NativeComponent {
  static let componentId = "drag-indicator"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @State private var show = false
  @State private var visible = true

  var body: some View {
    ComponentScaffold {
      GlassCard(config.subtitle ?? "presentationDragIndicator") {
        Toggle("Show drag indicator", isOn: $visible)
        Button(config.extra("buttonTitle", or: "Present sheet")) { show = true }.nativeButtonStyle(prominent: true)
      }
    }
    .sheet(isPresented: $show) {
      VStack(spacing: 12) {
        Text(config.title ?? (visible ? "Grabber visible" : "Grabber hidden")).font(.headline)
        Text(config.message ?? "Drag the sheet between detents.").foregroundStyle(.secondary)
      }
      .presentationDetents([.medium, .large])
      .presentationDragIndicator(visible ? .visible : .hidden)
      .modifier(SheetStyle())
    }
    .seed($visible, from: config.bool(or: true))
    .onChange(of: visible) { _, value in context.emit("indicator", value) }
    .onChange(of: show) { _, value in context.emit(value ? "presented" : "dismissed") }
    .onNativeCommand { _ in show = true }
  }
}

/// Alert with role-aware buttons, plus an alert with a text field.
///
/// - `title`, `message`, `items`: alert buttons (roles supported)
/// - `placeholder`: text field prompt
/// - Events: `action(itemId)`, `rename(String)`
struct AlertComponent: NativeComponent {
  static let componentId = "alert"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @State private var show = false
  @State private var showInput = false
  @State private var text = ""

  var body: some View {
    let actions = config.items(or: [.symbol("Delete", role: .destructive), .symbol("Cancel", role: .cancel)])
    ComponentScaffold {
      GlassCard(config.subtitle ?? "Alerts") {
        Button(config.extra("buttonTitle", or: "Show alert")) { show = true }
          .nativeButtonStyle(prominent: true)
        Button("Alert with text field") { showInput = true }.nativeButtonStyle()
      }
    }
    .alert(config.title ?? "Delete photo?", isPresented: $show) {
      ForEach(actions) { item in
        Button(item.title, role: item.role.buttonRole) { context.emit("action", item.id) }
      }
    } message: {
      Text(config.message ?? "This photo will be deleted from all your devices.")
    }
    .alert(config.extra("inputTitle", or: "Rename"), isPresented: $showInput) {
      TextField(config.placeholder ?? "Name", text: $text)
      Button("Save") { context.emit("rename", text) }
      Button("Cancel", role: .cancel) {}
    }
    .onNativeCommand { _ in show = true }
  }
}

/// Confirmation dialog (a popover anchored to its button on iOS 26).
///
/// - `title`, `message`, `items` (roles supported); Events: `action(itemId)`
struct ConfirmationDialogComponent: NativeComponent {
  static let componentId = "confirmation-dialog"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @State private var show = false

  var body: some View {
    let actions = config.items(or: [
      .symbol("Discard", role: .destructive), .symbol("Save draft"), .symbol("Cancel", role: .cancel),
    ])
    ComponentScaffold {
      GlassCard(config.subtitle ?? "confirmationDialog") {
        Button(config.extra("buttonTitle", or: "Discard changes…"), role: .destructive) { show = true }
          .nativeButtonStyle()
          .confirmationDialog(config.title ?? "You have unsaved changes", isPresented: $show, titleVisibility: .visible) {
            ForEach(actions) { item in
              Button(item.title, role: item.role.buttonRole) { context.emit("action", item.id) }
            }
          } message: {
            Text(config.message ?? "On iOS 26 this anchors to the button as a glass popover.")
          }
      }
    }
    .onNativeCommand { _ in show = true }
  }
}

/// UIKit action sheet (`UIAlertController(.actionSheet)`).
///
/// - `title`, `message`, `items` (roles map to UIAlertAction styles)
/// - Events: `action(itemId)`
struct ActionSheetComponent: NativeComponent {
  static let componentId = "action-sheet"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style

  var body: some View {
    PresenterScreen(caption: config.subtitle ?? "UIAlertController(.actionSheet)") { present() }
      .onNativeCommand { _ in present() }
  }

  private func present() {
    let items = config.items(or: [
      .symbol("AirDrop"), .symbol("Messages"), .symbol("Mail"),
      .symbol("Delete", role: .destructive), .symbol("Cancel", role: .cancel),
    ])
    let sheet = UIAlertController(title: config.title ?? "Share photo", message: config.message ?? "Presented with UIKit", preferredStyle: .actionSheet)
    for item in items {
      let actionStyle: UIAlertAction.Style = switch item.role {
      case .normal: .default
      case .destructive: .destructive
      case .cancel: .cancel
      }
      let action = UIAlertAction(title: item.title, style: actionStyle) { _ in context.emit("action", item.id) }
      action.isEnabled = item.isEnabled
      if let image = item.image.flatMap({ source -> UIImage? in
        if case .system(let name) = source { return UIImage(systemName: name) }
        return source.uiImage
      }) {
        action.setValue(image, forKey: "image")
      }
      sheet.addAction(action)
    }
    if let tint = style.tint { sheet.view.tintColor = UIColor(tint) }
    guard let top = UIApplication.shared.topViewController else { return }
    if let popover = sheet.popoverPresentationController {
      popover.sourceView = top.view
      popover.sourceRect = CGRect(x: top.view.bounds.midX, y: top.view.bounds.midY, width: 0, height: 0)
    }
    top.present(sheet, animated: true)
  }
}

/// Popover that stays a popover on iPhone (`presentationCompactAdaptation`).
///
/// - `title`: button title, `image`: button icon, `items`: popover options
/// - Events: `select(itemId)`
struct PopoverComponent: NativeComponent {
  static let componentId = "popover"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @State private var show = false

  var body: some View {
    let options = config.items(or: ["Small", "Medium", "Large"].map { NativeItem(title: $0) })
    ComponentScaffold {
      GlassCard(config.subtitle ?? "popover + presentationCompactAdaptation") {
        Button { show = true } label: {
          Label { Text(config.title ?? "Text options") } icon: { NativeIcon(config.image, fallback: "textformat.size") }
        }
        .nativeButtonStyle()
        .popover(isPresented: $show, arrowEdge: .top) {
          VStack(alignment: .leading, spacing: 12) {
            ForEach(options) { item in
              NativeItemButton(item) {
                context.emit("select", $0.id)
                show = false
              }
            }
          }
          .padding(20)
          .presentationCompactAdaptation(.popover)
        }
      }
    }
    .onNativeCommand { _ in show = true }
  }
}

/// Glass toast that slides in from the top and auto-dismisses.
///
/// - `title`: message; `image`: icon (default checkmark.circle.fill)
/// - `extra.duration`: seconds on screen (default 2.2)
/// - `extra.position`: "top" | "bottom"
/// - Commands: `trigger` shows the toast (arguments: optional message)
/// - Events: `shown(String)`, `dismissed`
struct ToastComponent: NativeComponent {
  static let componentId = "toast"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style
  @State private var toast: String?

  var body: some View {
    let bottom = config.extra("position", or: "top") == "bottom"
    ZStack(alignment: bottom ? .bottom : .top) {
      PresenterScreen(caption: config.subtitle ?? "Toast overlay") { show(config.title ?? "Copied to clipboard") }
      if let toast {
        HStack(spacing: 10) {
          NativeIcon(config.image, fallback: "checkmark.circle.fill").foregroundStyle(style.tint ?? .green)
          Text(toast).font(.subheadline.weight(.semibold)).foregroundStyle(style.foreground ?? .primary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .nativeGlass()
        .padding(bottom ? .bottom : .top, 12)
        .transition(.move(edge: bottom ? .bottom : .top).combined(with: .opacity))
        .onTapGesture { dismiss() }
      }
    }
    .onNativeCommand { command in show(command.arguments?.string ?? config.title ?? "Sent from Flutter") }
  }

  private func show(_ message: String) {
    withAnimation(.spring(duration: 0.4)) { toast = message }
    context.emit("shown", message)
    DispatchQueue.main.asyncAfter(deadline: .now() + config.extra("duration", or: 2.2)) { dismiss() }
  }

  private func dismiss() {
    guard toast != nil else { return }
    withAnimation(.easeInOut) { toast = nil }
    context.emit("dismissed")
  }
}

/// Custom centered glass confirmation card with a dimmed backdrop.
///
/// - `title`, `message`, `image` (default checkmark.seal.fill)
/// - `items`: two buttons (cancel, confirm)
/// - Events: `result(itemId | "dismiss")`
struct ConfirmationPopupComponent: NativeComponent {
  static let componentId = "confirmation-popup"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style
  @State private var show = false

  var body: some View {
    let buttons = config.items(or: [NativeItem(id: "cancel", title: "Cancel", role: .cancel), NativeItem(id: "confirm", title: "Confirm")])
    ZStack {
      PresenterScreen(caption: config.subtitle ?? "Custom glass popup") { withAnimation(.bouncy) { show = true } }
      if show {
        Color.black.opacity(0.3).ignoresSafeArea()
          .onTapGesture { close("dismiss") }
          .transition(.opacity)
        VStack(spacing: 16) {
          NativeIcon(config.image, fallback: "checkmark.seal.fill", size: 48)
            .foregroundStyle(style.tint ?? .green)
            .symbolEffect(.bounce, value: show)
          Text(config.title ?? "Confirm order?").font(style.titleFont(.title3)).foregroundStyle(style.foreground ?? .primary)
          Text(config.message ?? "Your card will be charged ₹1,299.").foregroundStyle(.secondary).multilineTextAlignment(.center)
          HStack {
            ForEach(buttons) { item in
              Button(item.title, role: item.role.buttonRole) { close(item.id) }
                .nativeButtonStyle(prominent: item.id == buttons.last?.id)
            }
          }
          .controlSize(.large)
        }
        .padding(28)
        .nativeGlass(RoundedRectangle(cornerRadius: style.radius(32), style: .continuous), interactive: false)
        .padding(30)
        .transition(.scale(scale: 0.8).combined(with: .opacity))
      }
    }
    .onNativeCommand { _ in withAnimation(.bouncy) { show = true } }
  }

  private func close(_ result: String) {
    withAnimation(.snappy) { show = false }
    context.emit("result", result)
  }
}
