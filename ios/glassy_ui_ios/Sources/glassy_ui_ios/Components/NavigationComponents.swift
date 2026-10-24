import SwiftUI

// Navigation bars and toolbars.
//
// Common config: `title` (navigation title) and `items` (list rows or
// toolbar actions, as documented on each component).

/// Navigation bar with leading/trailing actions.
///
/// - `title`: bar title (default "Inbox")
/// - `items`: list rows
/// - `extra.leading` / `extra.trailing`: button titles or SF Symbols
/// - Events: `tap(String)`, `select(itemId)`
struct NavigationBarComponent: NativeComponent {
  static let componentId = "nav-bar"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config

  var body: some View {
    NavigationStack {
      ItemList()
        .navigationTitle(config.title ?? "Inbox")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .topBarLeading) {
            Button(config.extra("leading", or: "Edit")) { context.emit("tap", "leading") }
          }
          ToolbarItem(placement: .topBarTrailing) {
            Button { context.emit("tap", "trailing") } label: {
              NativeIcon(config.image, fallback: "square.and.pencil")
            }
          }
        }
    }
  }
}

/// Pushed page with the system back button.
///
/// - `title`: root title (default "Library"); `subtitle`: pushed page title
/// - Commands: `trigger` pushes a page
/// - Events: `push(String)`, `back(String)`
struct BackButtonComponent: NativeComponent {
  static let componentId = "back-button"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @State private var path: [String] = []

  var body: some View {
    NavigationStack(path: $path) {
      ItemList(count: 20, links: true)
        .navigationTitle(config.title ?? "Library")
        .navigationDestination(for: String.self) { name in
          DetailPage(title: name, message: config.message ?? "Use the back button or swipe from the edge.")
            .navigationTitle(name)
        }
    }
    .task {
      // Push once the navigation bar has laid out, so the pushed page gets
      // the correct large-title margins.
      try? await Task.sleep(for: .milliseconds(300))
      if path.isEmpty { path = [config.subtitle ?? "Details"] }
    }
    .onChange(of: path) { old, new in
      if new.count < old.count {
        context.emit("back", old.last ?? "")
      } else if let last = new.last {
        context.emit("push", last)
      }
    }
    .onNativeCommand { _ in path.append(config.subtitle ?? "Details") }
  }
}

/// Close buttons: system close role, glass and prominent glass.
///
/// - `title`: modal title (default "Modal"); `message`: modal body text
/// - Commands: `trigger` opens the modal
/// - Events: `close(String source)`
struct CloseButtonComponent: NativeComponent {
  static let componentId = "close-button"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @State private var showSheet = false

  var body: some View {
    ComponentScaffold {
      GlassCard("Close buttons") {
        HStack(spacing: 20) {
          CloseButton { context.emit("close", "system") }
          GlassIconButton(image: config.image ?? .system("xmark")) { context.emit("close", "glass") }
          GlassIconButton(image: config.image ?? .system("xmark"), prominent: true) { context.emit("close", "prominent") }
        }
        Button("Open modal with close button") { showSheet = true }
          .nativeButtonStyle()
      }
    }
    .sheet(isPresented: $showSheet) {
      NavigationStack {
        ComponentScaffold {
          GlassCard { Text(config.message ?? "Dismiss with the close button in the toolbar.") }
        }
        .navigationTitle(config.title ?? "Modal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .topBarTrailing) {
            CloseButton {
              showSheet = false
              context.emit("close", "toolbar")
            }
          }
        }
      }
    }
    .onNativeCommand { _ in showSheet = true }
  }
}

/// Inline title with a subtitle and a title menu.
///
/// - `title`: initial title; `subtitle`: caption under the title
/// - `extra.menu`: title menu options (default folders)
/// - Events: `titleMenu(String)`
struct NavigationTitleComponent: NativeComponent {
  static let componentId = "nav-title"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style
  @State private var title = ""

  var body: some View {
    NavigationStack {
      ItemList()
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarTitleMenu {
          ForEach(config.extra("menu", or: ["Favorites", "Recents", "Shared", "Archive"]), id: \.self) { name in
            Button(name) {
              title = name
              context.emit("titleMenu", name)
            }
          }
        }
        .toolbar {
          ToolbarItem(placement: .principal) {
            VStack(spacing: 0) {
              Text(title).font(style.titleFont(.headline)).foregroundStyle(style.foreground ?? .primary)
              Text(config.subtitle ?? "Tap for title menu").font(.caption2).foregroundStyle(.secondary)
            }
          }
        }
    }
    .seed($title, from: config.title ?? "Favorites")
  }
}

/// Large title that collapses on scroll.
///
/// - `title` (default "Large Title"), `image`: trailing button icon
/// - Events: `tap("add")`, `select(itemId)`
struct LargeNavigationTitleComponent: NativeComponent {
  static let componentId = "large-nav-title"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config

  var body: some View {
    NavigationStack {
      ItemList(count: 40)
        .navigationTitle(config.title ?? "Large Title")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
          ToolbarItem(placement: .topBarTrailing) {
            Button { context.emit("tap", "add") } label: { NativeIcon(config.image, fallback: "plus") }
          }
        }
    }
  }
}

/// Toolbar with grouped trailing actions separated by a `ToolbarSpacer` (iOS 26).
///
/// - `title`; `items`: grouped trailing actions (default share / favorite)
/// - Events: `tap(itemId)`, `menu(String)`
struct ToolbarComponent: NativeComponent {
  static let componentId = "toolbar"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config

  private var actions: [NativeItem] {
    config.items(or: [.symbol("Share", "square.and.arrow.up"), .symbol("Favorite", "heart")])
  }

  var body: some View {
    NavigationStack {
      List(Array(SampleItems.make(30).enumerated()), id: \.element.id) { index, item in ItemRow(item, index: index) }
        .navigationTitle(config.title ?? "Toolbar")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .topBarLeading) {
            Button { context.emit("tap", "sidebar") } label: { Image(systemName: "sidebar.left") }
          }
          ToolbarItemGroup(placement: .topBarTrailing) {
            ForEach(actions) { item in
              Button { context.emit("tap", item.id) } label: { NativeIcon(item.image, fallback: "circle") }
            }
          }
          if #available(iOS 26.0, *) {
            ToolbarSpacer(.fixed, placement: .topBarTrailing)
          }
          ToolbarItem(placement: .topBarTrailing) {
            Menu {
              Button("Rename") { context.emit("menu", "Rename") }
              Button("Duplicate") { context.emit("menu", "Duplicate") }
            } label: {
              Image(systemName: "ellipsis")
            }
          }
        }
    }
  }
}

/// Floating glass toolbar with toggleable tools, split into two glass groups.
///
/// - `items`: tools (default text formatting). Items with `selected` start on.
/// - `extra.split`: how many tools go in the first group (default 4)
/// - Events: `toggle({tool, on})`
struct FloatingToolbarComponent: NativeComponent {
  static let componentId = "floating-toolbar"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style
  @State private var active: Set<String> = []

  private var tools: [NativeItem] {
    config.items(or: ["bold", "italic", "underline", "strikethrough", "list.bullet", "paintbrush"].map { .symbol($0, $0) })
  }

  var body: some View {
    let split = min(tools.count, Int(config.extra("split", or: 4.0)))
    ZStack(alignment: .bottom) {
      ComponentBackground()
      AdaptiveGlassContainer(spacing: style.spacing ?? 12) {
        HStack(spacing: style.spacing ?? 12) {
          group(Array(tools.prefix(split)))
          if split < tools.count { group(Array(tools.suffix(from: split))) }
        }
      }
      .padding(.bottom, style.padding ?? 30)
    }
    .seed($active, from: Set(tools.filter(\.isSelected).map(\.id)))
  }

  private func group(_ items: [NativeItem]) -> some View {
    HStack(spacing: 4) {
      ForEach(items) { item in
        let isOn = active.contains(item.id)
        Button {
          if isOn { active.remove(item.id) } else { active.insert(item.id) }
          context.emit("toggle", ["tool": item.id, "on": !isOn])
        } label: {
          NativeIcon(item.image, size: 17)
            .frame(width: 40, height: 40)
            .foregroundStyle(isOn ? AnyShapeStyle(.tint) : AnyShapeStyle(style.foreground ?? .primary))
            .background(isOn ? Color.accentColor.opacity(0.18) : .clear, in: Circle())
        }
        .buttonStyle(.plain)
      }
    }
    .padding(6)
    .nativeGlass()
  }
}

/// Bottom toolbar with a status label.
///
/// - `title`, `subtitle`: status text (default "30 Notes")
/// - `items`: first two items become the leading/trailing buttons
/// - Events: `tap(itemId)`
struct BottomToolbarComponent: NativeComponent {
  static let componentId = "bottom-toolbar"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config

  var body: some View {
    let buttons = config.items(or: [.symbol("Folder", "folder"), .symbol("Compose", "square.and.pencil")])
    NavigationStack {
      List(Array(SampleItems.make(30).enumerated()), id: \.element.id) { index, item in ItemRow(item, index: index) }
        .navigationTitle(config.title ?? "Notes")
        .toolbar {
          ToolbarItem(placement: .bottomBar) {
            Button { context.emit("tap", buttons[0].id) } label: { NativeIcon(buttons[0].image, fallback: "folder") }
          }
          ToolbarItem(placement: .status) {
            Text(config.subtitle ?? "30 Notes").font(.caption)
          }
          if buttons.count > 1 {
            ToolbarItem(placement: .bottomBar) {
              Button { context.emit("tap", buttons[1].id) } label: { NativeIcon(buttons[1].image, fallback: "square.and.pencil") }
            }
          }
        }
    }
  }
}

/// Form with Cancel and a prominent confirm action.
///
/// - `title` (default "New Event"), `value`: initial text, `placeholder`
/// - `image`: confirm icon (default checkmark)
/// - Events: `cancel`, `save(String)`
struct ToolbarActionButtonComponent: NativeComponent {
  static let componentId = "toolbar-action-button"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @State private var text = ""
  @State private var date = Date()

  var body: some View {
    NavigationStack {
      Form {
        TextField(config.placeholder ?? "Title", text: $text)
        DatePicker("Date", selection: $date, displayedComponents: .date)
      }
      .navigationTitle(config.title ?? "New Event")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") { context.emit("cancel") }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button { context.emit("save", text) } label: { NativeIcon(config.image, fallback: "checkmark") }
            .nativeButtonStyle(prominent: true)
        }
      }
    }
    .seed($text, from: config.string(or: "Weekend trip"))
  }
}
