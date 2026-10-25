import SwiftUI

/// Single controls meant to sit inside a Flutter layout (app bars, bottom bars,
/// page bodies): no backdrop, no demo content, transparent background.
/// Used by the `GlassTabBar`, `GlassIconButton` and `GlassMenuButton` widgets.
enum EmbeddableComponents {
  static let all: [any NativeComponent.Type] = [
    EmbeddedTabBarComponent.self,
    EmbeddedIconButtonComponent.self,
    EmbeddedMenuButtonComponent.self,
  ]
}

/// Floating glass tab bar without page content; Flutter renders the pages.
///
/// - `items`: tabs; `value`: selected tab id
/// - Commands: `trigger` selects the next tab; Events: `change(itemId)`
struct EmbeddedTabBarComponent: NativeComponent {
  static let componentId = "glassy-tab-bar"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style
  @Namespace private var namespace
  @State private var selection = ""

  var body: some View {
    let tabs = config.items ?? []
    HStack(spacing: 0) {
      ForEach(tabs) { tab in
        Button { select(tab.id) } label: {
          EmbeddedTabItem(tab: tab, isSelected: tab.id == selection, namespace: namespace)
        }
        .buttonStyle(.plain)
      }
    }
    .padding(4)
    .nativeGlass(interactive: true)
    .padding(.horizontal, style.padding ?? 16)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .ignoresSafeArea()
    .seed($selection, from: config.value?.string ?? tabs.first?.id ?? "")
    .onNativeCommand { command in
      guard command.name == "trigger", !tabs.isEmpty else { return }
      let index = tabs.firstIndex { $0.id == selection } ?? 0
      select(tabs[(index + 1) % tabs.count].id)
    }
  }

  private func select(_ id: String) {
    withAnimation(.bouncy) { selection = id }
    context.emit("change", id)
  }
}

/// One tab: icon, title, optional badge and the sliding selection capsule.
private struct EmbeddedTabItem: View {
  @Environment(\.nativeStyle) private var style
  let tab: NativeItem
  let isSelected: Bool
  let namespace: Namespace.ID

  var body: some View {
    VStack(spacing: 2) {
      NativeIcon(tab.image, size: 20)
      Text(tab.title).font(.caption2.weight(.medium)).lineLimit(1)
    }
    .foregroundStyle(foreground)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background { selectionCapsule }
    .overlay(alignment: .topTrailing) { badge }
    .contentShape(Capsule())
  }

  private var foreground: AnyShapeStyle {
    isSelected ? AnyShapeStyle(.tint) : AnyShapeStyle(style.foreground ?? .primary)
  }

  @ViewBuilder
  private var selectionCapsule: some View {
    if isSelected {
      Capsule()
        .fill(.tint.opacity(0.15))
        .matchedGeometryEffect(id: "selection", in: namespace)
    }
  }

  @ViewBuilder
  private var badge: some View {
    if let badge = tab.badge {
      Text(badge)
        .font(.caption2.weight(.bold))
        .foregroundStyle(.white)
        .padding(.horizontal, 5)
        .background(.red, in: Capsule())
        .padding(.top, 4)
        .padding(.trailing, 12)
    }
  }
}

/// Single circular glass icon button.
///
/// - `image`: icon (default circle); `extra.prominent`: filled glass; `extra.iconSize`
/// - Events: `tap`
struct EmbeddedIconButtonComponent: NativeComponent {
  static let componentId = "glassy-icon-button"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config

  var body: some View {
    GlassIconButton(
      image: config.image ?? .system("circle"),
      prominent: config.extra("prominent", or: false),
      size: config.extra("iconSize", or: 18.0)
    ) { context.emit("tap") }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

/// Glass button that opens a native menu.
///
/// - `title`: button text; `image`: optional leading icon; `items`: menu entries
///   (roles and nested `children` supported); `extra.prominent` (default true)
/// - Events: `select(itemId)`
struct EmbeddedMenuButtonComponent: NativeComponent {
  static let componentId = "glassy-menu-button"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config

  var body: some View {
    Menu {
      NativeMenuContent(items: config.items ?? []) { context.emit("select", $0.id) }
    } label: {
      HStack(spacing: 6) {
        if let image = config.image { NativeIcon(image) }
        if let title = config.title { Text(title) }
        Image(systemName: "chevron.down").font(.footnote.weight(.semibold))
      }
    }
    .nativeButtonStyle(prominent: config.extra("prominent", or: true))
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
