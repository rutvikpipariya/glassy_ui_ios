import SwiftUI
import UIKit

// Menus. Menu entries come from `items`; an item with `children` becomes a
// submenu. Selecting an entry emits `select(itemId)`.

/// Recursively builds menu content from `NativeItem`s.
struct NativeMenuContent: View {
  let items: [NativeItem]
  let onSelect: (NativeItem) -> Void

  var body: some View {
    ForEach(items) { item in
      if item.children.isEmpty {
        NativeItemButton(item, action: onSelect)
      } else {
        Menu {
          NativeMenuContent(items: item.children, onSelect: onSelect)
        } label: {
          NativeItemLabel(item)
        }
      }
    }
  }
}

/// Pop-up button showing the current choice.
///
/// - `title`: row label (default "Repeat"); `items`: options; `value`: selected id
/// - Events: `change(itemId)`
struct PopupMenuComponent: NativeComponent {
  static let componentId = "popup-menu"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @State private var selection = ""

  var body: some View {
    let options = config.items(or: ["Never", "Daily", "Weekly", "Monthly"].map { NativeItem(title: $0) })
    ComponentScaffold {
      GlassCard(config.subtitle ?? "Pop-up button") {
        HStack {
          Text(config.title ?? "Repeat")
          Spacer()
          Menu {
            Picker(config.title ?? "Repeat", selection: $selection) {
              ForEach(options) { NativeItemLabel($0).tag($0.id) }
            }
          } label: {
            HStack(spacing: 4) {
              Text(options.first { $0.id == selection }?.title ?? "")
              Image(systemName: "chevron.up.chevron.down").font(.caption)
            }
          }
          .nativeButtonStyle()
        }
      }
    }
    .seed($selection, from: config.value?.string ?? options[0].id)
    .onChange(of: selection) { _, value in context.emit("change", value) }
  }
}

/// Dropdown with a sort picker section and an "ascending" toggle.
///
/// - `title` (default "Sort"), `image`, `items`: sort options; `value`: selected id
/// - Events: `change(itemId)`, `ascending(Bool)`
struct DropdownMenuComponent: NativeComponent {
  static let componentId = "dropdown-menu"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @State private var selection = ""
  @State private var ascending = false

  var body: some View {
    let options = config.items(or: [.symbol("Date", "calendar"), .symbol("Name", "textformat"), .symbol("Size", "internaldrive")])
    ComponentScaffold {
      GlassCard(config.subtitle ?? "Dropdown with sections") {
        Menu {
          Section(config.extra("sectionTitle", or: "Sort by")) {
            Picker(config.title ?? "Sort", selection: $selection) {
              ForEach(options) { NativeItemLabel($0).tag($0.id) }
            }
          }
          Section {
            Toggle(config.extra("toggleTitle", or: "Ascending"), isOn: $ascending)
          }
        } label: {
          Label {
            Text("\(config.title ?? "Sort"): \(options.first { $0.id == selection }?.title ?? "")")
          } icon: {
            NativeIcon(config.image, fallback: "line.3.horizontal.decrease")
          }
        }
        .nativeButtonStyle()
        .menuOrder(.fixed)
      }
    }
    .seed($selection, from: config.value?.string ?? options[0].id)
    .onChange(of: selection) { _, value in context.emit("change", value) }
    .onChange(of: ascending) { _, value in context.emit("ascending", value) }
  }
}

/// Long-press context menu with preview on image tiles.
///
/// - `title`: hint text; `items`: tiles (their `image` is the artwork)
/// - `extra.actions`: action titles (default Copy/Favorite/Delete; "Delete" is destructive)
/// - Events: `action({item, action})`
struct ContextMenuComponent: NativeComponent {
  static let componentId = "context-menu"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style

  var body: some View {
    let tiles = config.items(or: (1...4).map { NativeItem(title: "Photo \($0)") })
    let actions = config.extra("actions", or: ["Copy", "Favorite", "Delete"])
    ComponentScaffold {
      Text(config.title ?? "Long-press a photo").font(style.titleFont(.headline)).foregroundStyle(style.foreground ?? .white)
      LazyVGrid(columns: [GridItem(), GridItem()], spacing: style.spacing ?? 16) {
        ForEach(Array(tiles.enumerated()), id: \.element.id) { index, item in
          NativeArtwork(item.image, index: index)
            .aspectRatio(1, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: style.radius(20), style: .continuous))
            .contextMenu {
              ForEach(actions, id: \.self) { action in
                Button(action, role: action.lowercased() == "delete" ? .destructive : nil) {
                  context.emit("action", ["item": item.id, "action": action])
                }
              }
            } preview: {
              NativeArtwork(item.image, index: index).frame(width: 300, height: 300)
            }
        }
      }
    }
  }
}

/// Toolbar overflow (ellipsis) menu.
///
/// - `title`: navigation title; `items`: menu entries; `image`: menu icon
/// - Events: `select(itemId)`
struct OverflowMenuComponent: NativeComponent {
  static let componentId = "overflow-menu"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config

  var body: some View {
    let entries = config.items(or: [
      .symbol("Select", "checkmark.circle"), .symbol("New Folder", "folder.badge.plus"),
      .symbol("Scan Documents", "doc.viewfinder"), .symbol("View Options", "slider.horizontal.3"),
    ])
    NavigationStack {
      List(Array(SampleItems.make(30).enumerated()), id: \.element.id) { index, item in ItemRow(item, index: index) }
        .navigationTitle(config.title ?? "Projects")
        .toolbar {
          ToolbarItem(placement: .topBarTrailing) {
            Menu {
              NativeMenuContent(items: entries) { context.emit("select", $0.id) }
            } label: {
              NativeIcon(config.image, fallback: "ellipsis")
            }
          }
        }
    }
  }
}

/// Menu with nested submenus built from `items[].children`.
///
/// - `title` (default "File"), `image`, `items` (nest with `children`)
/// - Events: `select(itemId)`
struct NestedSubmenuComponent: NativeComponent {
  static let componentId = "nested-submenu"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config

  var body: some View {
    let entries = config.items(or: [
      NativeItem(title: "New File", image: .system("doc.badge.plus")),
      NativeItem(title: "Export As", image: .system("square.and.arrow.up"), children: [
        NativeItem(title: "PDF"), NativeItem(title: "PNG"),
        NativeItem(title: "Code", children: [NativeItem(title: "Swift"), NativeItem(title: "Dart")]),
      ]),
      NativeItem(title: "Tags", image: .system("tag"), children: [NativeItem(title: "Red"), NativeItem(title: "Blue")]),
    ])
    ComponentScaffold {
      GlassCard(config.subtitle ?? "Nested menus") {
        Menu {
          NativeMenuContent(items: entries) { context.emit("select", $0.id) }
        } label: {
          Label { Text(config.title ?? "File") } icon: { NativeIcon(config.image, fallback: "doc") }
        }
        .nativeButtonStyle()
      }
    }
  }
}

/// SwiftUI `ShareLink` plus UIKit `UIActivityViewController` with a completion callback.
///
/// - `title`: share text; `message`: subject; `extra.url`: URL to share
/// - Commands: `trigger` opens the activity sheet
/// - Events: `shareLink`, `completed({activity, completed})`
struct ShareMenuComponent: NativeComponent {
  static let componentId = "share-menu"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config

  private var url: URL {
    URL(string: config.extra("url", or: "https://developer.apple.com/design/human-interface-guidelines/materials"))
      ?? URL(string: "https://apple.com")!
  }

  var body: some View {
    ComponentScaffold {
      GlassCard("ShareLink (SwiftUI)") {
        ShareLink(item: url, subject: Text(config.message ?? "Liquid Glass"), message: Text(config.title ?? "Check this out")) {
          Label { Text("Share link") } icon: { NativeIcon(config.image, fallback: "square.and.arrow.up") }
        }
        .nativeButtonStyle()
        .simultaneousGesture(TapGesture().onEnded { context.emit("shareLink") })
      }
      GlassCard("UIActivityViewController (UIKit)") {
        Button(action: presentActivity) {
          Label("Share with callback", systemImage: "square.and.arrow.up.on.square")
        }
        .nativeButtonStyle(prominent: true)
      }
    }
    .onNativeCommand { _ in presentActivity() }
  }

  private func presentActivity() {
    var items: [Any] = [url]
    if let text = config.title { items.insert(text, at: 0) }
    let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
    controller.completionWithItemsHandler = { type, completed, _, _ in
      context.emit("completed", ["activity": type?.rawValue ?? "none", "completed": completed])
    }
    guard let top = UIApplication.shared.topViewController else { return }
    controller.popoverPresentationController?.sourceView = top.view
    top.present(controller, animated: true)
  }
}

/// `UITextView` whose edit menu has custom actions sending the selection to Dart.
///
/// - `message`: the text; `items`: custom menu actions (default Send / Highlight)
/// - Events: `<itemId>(String selectedText)`
struct TextSelectionMenuComponent: NativeComponent {
  static let componentId = "text-selection-menu"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style

  var body: some View {
    ComponentScaffold {
      GlassCard(config.title ?? "UITextView edit menu") {
        SelectableTextView(
          text: config.message ?? "Select any words in this paragraph. The edit menu includes custom actions that send the selected text back to Flutter through the method channel.",
          fontSize: style.fontSize,
          actions: config.items(or: [
            NativeItem(id: "send", title: "Send to Flutter", image: .system("paperplane")),
            NativeItem(id: "highlight", title: "Highlight", image: .system("highlighter")),
          ])
        ) { action, text in context.emit(action, text) }
        .frame(height: 260)
      }
    }
  }
}

private struct SelectableTextView: UIViewRepresentable {
  let text: String
  let fontSize: CGFloat?
  let actions: [NativeItem]
  let onAction: (String, String) -> Void

  func makeUIView(context: Context) -> UITextView {
    let view = UITextView()
    view.isEditable = false
    view.backgroundColor = .clear
    view.delegate = context.coordinator
    return view
  }

  func updateUIView(_ view: UITextView, context: Context) {
    view.text = text
    view.font = fontSize.map { .systemFont(ofSize: $0) } ?? .preferredFont(forTextStyle: .title3)
    context.coordinator.parent = self
  }

  func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

  final class Coordinator: NSObject, UITextViewDelegate {
    var parent: SelectableTextView

    init(parent: SelectableTextView) {
      self.parent = parent
    }

    func textView(_ textView: UITextView, editMenuForTextIn range: NSRange, suggestedActions: [UIMenuElement]) -> UIMenu? {
      let selected = (textView.text as NSString).substring(with: range)
      let custom = parent.actions.map { item in
        UIAction(title: item.title, image: item.image.flatMap(Self.uiImage)) { [parent] _ in parent.onAction(item.id, selected) }
      }
      return UIMenu(children: [UIMenu(title: "", options: .displayInline, children: custom)] + suggestedActions)
    }

    private static func uiImage(_ source: NativeImageSource) -> UIImage? {
      if case .system(let name) = source { return UIImage(systemName: name) }
      return source.uiImage
    }
  }
}
