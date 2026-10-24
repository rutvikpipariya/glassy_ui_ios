import SwiftUI

// Tabs, sidebars, stacks and split views.
//
// Tab components take their tabs from `items` (title + image + badge) and
// report the selected tab id with `change`.

/// Default tabs used when Dart supplies no `items`.
private let defaultTabs: [NativeItem] = [
  .symbol("Home", "house"), .symbol("Browse", "square.grid.2x2"),
  .symbol("Radio", "dot.radiowaves.left.and.right"), .symbol("Library", "books.vertical"),
]

/// Content of a tab: a navigation stack with the tab title and sample rows.
private struct TabPage: View {
  let title: String

  var body: some View {
    NavigationStack {
      List(Array(SampleItems.make(40).enumerated()), id: \.element.id) { index, item in ItemRow(item, index: index) }
        .navigationTitle(title)
    }
  }
}

/// `.tabItem` label for a `NativeItem`, with its badge.
private struct TabItemModifier: ViewModifier {
  let item: NativeItem

  func body(content: Content) -> some View {
    content
      .tabItem { NativeItemLabel(item) }
      .badge(item.badge.map { Text($0) })
  }
}

extension View {
  fileprivate func tabItem(_ item: NativeItem) -> some View { modifier(TabItemModifier(item: item)) }
}

/// Standard tab bar.
///
/// - `items`: tabs; `value`: initial tab id
/// - Commands: `trigger` selects the next tab; Events: `change(itemId)`
struct TabBarComponent: NativeComponent {
  static let componentId = "tab-bar"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @State private var selection = ""

  var body: some View {
    let tabs = config.items(or: defaultTabs)
    TabView(selection: $selection) {
      ForEach(tabs) { tab in
        TabPage(title: tab.title).tabItem(tab).tag(tab.id)
      }
    }
    .seed($selection, from: config.value?.string ?? tabs[0].id)
    .onChange(of: selection) { _, value in context.emit("change", value) }
    .onNativeCommand { _ in
      let index = tabs.firstIndex { $0.id == selection } ?? 0
      selection = tabs[(index + 1) % tabs.count].id
    }
  }
}

/// Floating tab bar: native minimize-on-scroll on iOS 26, custom glass capsule before.
///
/// - `items`: tabs; Events: `change(itemId)`
struct FloatingTabBarComponent: NativeComponent {
  static let componentId = "floating-tab-bar"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style
  @State private var selection = ""

  var body: some View {
    let tabs = config.items(or: defaultTabs)
    Group {
      if #available(iOS 26.0, *) {
        TabView(selection: $selection) {
          ForEach(tabs) { tab in TabPage(title: tab.title).tabItem(tab).tag(tab.id) }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
      } else {
        ZStack(alignment: .bottom) {
          TabPage(title: tabs.first { $0.id == selection }?.title ?? "")
            .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 70) }
          HStack(spacing: 0) {
            ForEach(tabs) { tab in
              Button { selection = tab.id } label: {
                VStack(spacing: 2) {
                  NativeIcon(tab.image, size: 18)
                  Text(tab.title).font(.caption2)
                }
                .foregroundStyle(selection == tab.id ? AnyShapeStyle(.tint) : AnyShapeStyle(.primary))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
              }
              .buttonStyle(.plain)
            }
          }
          .padding(6)
          .nativeGlass()
          .padding(.horizontal, style.padding ?? 20)
          .padding(.bottom, 10)
        }
      }
    }
    .seed($selection, from: config.value?.string ?? tabs[0].id)
    .onChange(of: selection) { _, value in context.emit("change", value) }
  }
}

/// Tab items with symbols, titles and badges.
///
/// - `items`: tabs (use `badge`); `message`: body text of the first tab
/// - Events: `change(itemId)`, `badge(Int)`
struct TabBarItemComponent: NativeComponent {
  static let componentId = "tab-bar-item"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @State private var selection = ""
  @State private var unread = 3

  var body: some View {
    let tabs = config.items(or: [
      NativeItem(title: "Activity", image: .system("bell")),
      NativeItem(title: "Messages", image: .system("message"), badge: "New"),
      NativeItem(title: "Profile", image: .system("person.crop.circle")),
    ])
    TabView(selection: $selection) {
      ForEach(Array(tabs.enumerated()), id: \.element.id) { index, tab in
        ComponentScaffold {
          GlassCard(tab.title) {
            Text(config.message ?? "Each tab item has an image, a title and an optional badge.")
            if index == 0 {
              Button("Add notification") {
                unread += 1
                context.emit("badge", unread)
              }
              .nativeButtonStyle()
            }
          }
        }
        .tabItem { NativeItemLabel(tab) }
        .badge(index == 0 && unread > 0 ? Text("\(unread)") : tab.badge.map { Text($0) })
        .tag(tab.id)
      }
    }
    .seed($selection, from: tabs[0].id)
    .onChange(of: selection) { _, value in
      if value == tabs.first?.id { unread = 0 }
      context.emit("change", value)
    }
  }
}

/// Glass tab capsules where the selected tab expands to show its title.
///
/// - `items`: tabs; `value`: initial tab id; Events: `change(itemId)`
struct ExpandableTabBarComponent: NativeComponent {
  static let componentId = "expandable-tab-bar"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style
  @Namespace private var namespace
  @State private var selection = ""

  var body: some View {
    let tabs = config.items(or: defaultTabs)
    ZStack(alignment: .bottom) {
      ComponentBackground()
      Text(tabs.first { $0.id == selection }?.title ?? "")
        .font(style.titleFont(.largeTitle))
        .foregroundStyle(style.foreground ?? .white)
        .frame(maxHeight: .infinity)
      AdaptiveGlassContainer(spacing: style.spacing ?? 8) {
        HStack(spacing: style.spacing ?? 8) {
          ForEach(tabs) { tab in
            let isSelected = tab.id == selection
            Button {
              withAnimation(.bouncy) { selection = tab.id }
              context.emit("change", tab.id)
            } label: {
              HStack(spacing: 6) {
                NativeIcon(tab.image).symbolVariant(isSelected ? .fill : .none)
                if isSelected { Text(tab.title).fontWeight(.semibold) }
              }
              .padding(.horizontal, isSelected ? 18 : 14)
              .padding(.vertical, 14)
            }
            .buttonStyle(.plain)
            .nativeGlass(tint: isSelected ? (style.tint ?? .accentColor).opacity(0.5) : nil)
            .adaptiveGlassID(tab.id, in: namespace)
          }
        }
      }
      .padding(.bottom, style.padding ?? 30)
    }
    .seed($selection, from: config.value?.string ?? tabs[0].id)
  }
}

/// Tab bar with a dedicated search tab (`Tab(role: .search)` on iOS 18+).
///
/// - `items`: regular tabs; `placeholder`: search prompt
/// - `extra.results`: searchable strings
/// - Events: `change(itemId)`, `search(String)`
struct SearchTabComponent: NativeComponent {
  static let componentId = "search-tab"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @State private var query = ""
  @State private var selection = ""

  var body: some View {
    let tabs = config.items(or: [.symbol("Home", "house"), .symbol("Library", "books.vertical")])
    Group {
      if #available(iOS 18.0, *) {
        TabView(selection: $selection) {
          ForEach(tabs) { tab in
            Tab(value: tab.id) { TabPage(title: tab.title) } label: { NativeItemLabel(tab) }
          }
          Tab(value: "search", role: .search) { searchPage }
        }
      } else {
        TabView(selection: $selection) {
          ForEach(tabs) { tab in TabPage(title: tab.title).tabItem(tab).tag(tab.id) }
          searchPage.tabItem { Label("Search", systemImage: "magnifyingglass") }.tag("search")
        }
      }
    }
    .seed($selection, from: tabs[0].id)
    .onChange(of: selection) { _, value in context.emit("change", value) }
  }

  private var searchPage: some View {
    let all = config.extra("results", or: ["Daft Punk", "Dua Lipa", "Coldplay", "Arijit Singh", "Billie Eilish", "Radiohead", "Taylor Swift"])
    let results = query.isEmpty ? all : all.filter { $0.localizedCaseInsensitiveContains(query) }
    return NavigationStack {
      List(results, id: \.self) { Text($0) }
        .navigationTitle(config.title ?? "Search")
        .searchable(text: $query, prompt: config.placeholder ?? "Artists, songs, podcasts")
        .onSubmit(of: .search) { context.emit("search", query) }
    }
  }
}

/// Sidebar navigation (`NavigationSplitView` + `.sidebar` list).
///
/// - `title` (default "Mailboxes"); `items`: sidebar rows; `message`: detail text
/// - Events: `change(itemId)`
struct SidebarComponent: NativeComponent {
  static let componentId = "sidebar"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @State private var selection: String?

  var body: some View {
    let rows = config.items(or: [
      .symbol("Inbox", "tray"), .symbol("Drafts", "doc"), .symbol("Sent", "paperplane"),
      .symbol("Archive", "archivebox"), .symbol("Trash", "trash"),
    ])
    NavigationSplitView {
      List(rows, selection: $selection) { NativeItemLabel($0).badge($0.badge.map { Text($0) }) }
        .listStyle(.sidebar)
        .navigationTitle(config.title ?? "Mailboxes")
    } detail: {
      let title = rows.first { $0.id == selection }?.title ?? "None"
      DetailPage(title: title, message: config.message ?? "Selected from the sidebar.").navigationTitle(title)
    }
    .onAppear { if selection == nil { selection = rows.first?.id } }
    .onChange(of: selection) { _, value in context.emit("change", value ?? "") }
  }
}

/// Programmatic `NavigationStack(path:)` with push and pop to root.
///
/// - `title`: root title; `extra.pushLabel` / `extra.popLabel`
/// - Commands: `trigger` pushes, `reset` pops to root
/// - Events: `change(String path)`
struct NavigationStackComponent: NativeComponent {
  static let componentId = "navigation-stack"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @State private var path: [Int] = []

  var body: some View {
    NavigationStack(path: $path) {
      level(0).navigationDestination(for: Int.self) { level($0) }
    }
    .onChange(of: path) { _, value in context.emit("change", value.map { "L\($0)" }.joined(separator: " › ")) }
    .onNativeCommand { command in
      if command.name == "reset" { path = [] } else { path.append(path.count + 1) }
    }
  }

  private func level(_ depth: Int) -> some View {
    ComponentScaffold {
      GlassCard(depth == 0 ? (config.title ?? "Root") : "Level \(depth)") {
        Text("Stack depth: \(path.count)").foregroundStyle(.secondary)
        NavigationLink("\(config.extra("pushLabel", or: "Push level")) \(depth + 1)", value: depth + 1)
          .nativeButtonStyle(prominent: true)
        if !path.isEmpty {
          Button(config.extra("popLabel", or: "Pop to root")) { path.removeAll() }
            .nativeButtonStyle()
        }
      }
    }
    .navigationTitle(depth == 0 ? (config.title ?? "Root") : "Level \(depth)")
  }
}

/// Three-column split view: categories → items → detail.
///
/// - `items`: categories whose `children` are the items
/// - Events: `category(itemId)`, `item(itemId)`
struct SplitViewComponent: NativeComponent {
  static let componentId = "split-view"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @State private var category: String?
  @State private var item: String?
  @State private var visibility = NavigationSplitViewVisibility.all

  private var categories: [NativeItem] {
    config.items(or: [
      NativeItem(title: "Fruits", children: ["Apple", "Banana", "Mango"].map { NativeItem(title: $0) }),
      NativeItem(title: "Vegetables", children: ["Carrot", "Potato", "Spinach"].map { NativeItem(title: $0) }),
      NativeItem(title: "Nuts", children: ["Almond", "Cashew"].map { NativeItem(title: $0) }),
    ])
  }

  var body: some View {
    let current = categories.first { $0.id == category }
    NavigationSplitView(columnVisibility: $visibility) {
      List(categories, selection: $category) { NativeItemLabel($0) }
        .navigationTitle(config.title ?? "Categories")
    } content: {
      List(current?.children ?? [], selection: $item) { NativeItemLabel($0) }
        .navigationTitle(current?.title ?? "")
    } detail: {
      DetailPage(title: current?.children.first { $0.id == item }?.title ?? "Select an item", message: config.message ?? "Detail column.")
    }
    .navigationSplitViewStyle(.balanced)
    .onAppear { if category == nil { category = categories.first?.id } }
    .onChange(of: category) { _, value in context.emit("category", value ?? "") }
    .onChange(of: item) { _, value in context.emit("item", value ?? "") }
  }
}

/// Mini player shown in the floating accessory slot.
private struct MiniPlayer: View {
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @State private var playing = false

  var body: some View {
    HStack(spacing: 12) {
      NativeArtwork(config.image, index: 2)
        .frame(width: 34, height: 34)
        .clipShape(RoundedRectangle(cornerRadius: 8))
      VStack(alignment: .leading, spacing: 0) {
        Text(config.title ?? "Liquid Dreams").font(.subheadline.weight(.semibold))
        Text(config.subtitle ?? "Glass Ensemble").font(.caption).foregroundStyle(.secondary)
      }
      Spacer()
      Button {
        playing.toggle()
        context.emit("playback", playing ? "play" : "pause")
      } label: {
        Image(systemName: playing ? "pause.fill" : "play.fill").contentTransition(.symbolEffect(.replace))
      }
      Button { context.emit("playback", "next") } label: { Image(systemName: "forward.fill") }
    }
    .buttonStyle(.plain)
    .padding(.horizontal, 16)
  }
}

/// Accessory above the tab bar (`tabViewBottomAccessory` on iOS 26).
///
/// - `title` / `subtitle` / `image`: now playing info; `items`: tabs
/// - Events: `playback(String)`
struct FloatingAccessoryComponent: NativeComponent {
  static let componentId = "floating-accessory"
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style

  var body: some View {
    let tabs = config.items(or: defaultTabs)
    if #available(iOS 26.0, *) {
      TabView {
        ForEach(tabs) { tab in TabPage(title: tab.title).tabItem(tab) }
      }
      .tabBarMinimizeBehavior(.onScrollDown)
      .tabViewBottomAccessory { MiniPlayer() }
    } else {
      TabView {
        ForEach(tabs) { tab in
          TabPage(title: tab.title)
            .safeAreaInset(edge: .bottom) {
              MiniPlayer()
                .padding(.vertical, 10)
                .nativeGlass(RoundedRectangle(cornerRadius: style.radius(18), style: .continuous))
                .padding(.horizontal, 12)
                .padding(.bottom, 6)
            }
            .tabItem(tab)
        }
      }
    }
  }
}

/// Inspector panel editing a shape (`.inspector`, a sheet on iPhone).
///
/// - `title` (default "Canvas"); `style.cornerRadius`/`tintColor` seed the shape
/// - Commands: `trigger` toggles the inspector
/// - Events: `inspector(String)`, `change({color, opacity, corner})`
struct InspectorComponent: NativeComponent {
  static let componentId = "inspector"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style
  @State private var showInspector = false
  @State private var opacity = 0.8
  @State private var corner = 24.0
  @State private var color = Color.purple

  var body: some View {
    NavigationStack {
      ZStack {
        ComponentBackground()
        RoundedRectangle(cornerRadius: corner, style: .continuous)
          .fill(color.opacity(opacity))
          .frame(width: 200, height: 200)
          .shadow(radius: 20)
      }
      .navigationTitle(config.title ?? "Canvas")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        Button { showInspector.toggle() } label: { NativeIcon(config.image, fallback: "info.circle") }
      }
      .inspector(isPresented: $showInspector) {
        Form {
          Section(config.subtitle ?? "Appearance") {
            ColorPicker("Fill", selection: $color)
            LabeledContent("Opacity") { Slider(value: $opacity) { editing in if !editing { report() } } }
            LabeledContent("Corner") { Slider(value: $corner, in: 0...100) { editing in if !editing { report() } } }
          }
        }
        .presentationDetents([.medium, .large])
        .inspectorColumnWidth(min: 240, ideal: 300)
      }
    }
    .seed($corner, from: Double(style.cornerRadius ?? 24))
    .seed($color, from: style.tint ?? .purple)
    .onChange(of: showInspector) { _, value in context.emit("inspector", value ? "shown" : "hidden") }
    .onNativeCommand { _ in showInspector.toggle() }
  }

  private func report() {
    context.emit("change", ["color": color.hexString, "opacity": opacity, "corner": corner])
  }
}
