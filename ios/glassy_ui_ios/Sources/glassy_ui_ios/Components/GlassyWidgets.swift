import SwiftUI

/// Single native controls for your own Flutter layouts (app bars, bottom bars,
/// page bodies): no backdrop, no demo content, transparent background.
/// Each one backs a typed `Glass…` widget in Dart (`lib/src/widgets/`).
enum GlassyWidgets {
  static let all: [any NativeComponent.Type] = [
    // Navigation & menus
    GlassyTabBar.self, GlassyToolbar.self,
    GlassyMenuButton.self, GlassyPopupButton.self,
    // Buttons
    GlassyButton.self, GlassyIconButton.self, GlassyFloatingActionButton.self,
    GlassyAvatarButton.self, GlassyImageButton.self,
    // Controls
    GlassySegmentedControl.self, GlassySwitch.self, GlassyStepper.self,
    GlassySlider.self, GlassyPageIndicator.self, GlassyCheckbox.self,
    // Input
    GlassyTextField.self, GlassySearchBar.self, GlassyDatePicker.self,
    GlassyWheelPicker.self, GlassyColorPicker.self,
    // Progress & media
    GlassyProgress.self, GlassyPlayPause.self, GlassyMediaControls.self,
  ]
}

// MARK: - Helpers

extension ComponentContext {
  /// A binding that updates `state` and reports user changes to Dart as
  /// `event`. Values seeded from Dart bypass it, so they are not echoed back.
  func binding<Value>(_ state: Binding<Value>, event: String = "change", encode: @escaping (Value) -> Any? = { $0 }) -> Binding<Value> {
    Binding(
      get: { state.wrappedValue },
      set: { newValue in
        state.wrappedValue = newValue
        self.emit(event, encode(newValue))
      }
    )
  }
}

extension View {
  /// `labelsHidden()` when `hidden` is true.
  @ViewBuilder
  func labelsHidden(_ hidden: Bool) -> some View {
    if hidden { labelsHidden() } else { self }
  }
}

// MARK: - Navigation

/// Floating glass tab bar without page content; Flutter renders the pages.
///
/// - `items`: tabs (use `badge`); `value`: selected tab id
/// - `extra.expandable`: only the selected tab shows its title
/// - Commands: `trigger` selects the next tab; Events: `change(itemId)`
struct GlassyTabBar: NativeComponent {
  static let componentId = "glassy-tab-bar"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style
  @Namespace private var namespace
  @State private var selection = ""

  var body: some View {
    let tabs = config.items ?? []
    let expandable = config.extra("expandable", or: false)
    HStack(spacing: 0) {
      ForEach(tabs) { tab in
        Button { select(tab.id) } label: {
          GlassyTabItem(
            tab: tab,
            isSelected: tab.id == selection,
            showsTitle: !expandable || tab.id == selection,
            namespace: namespace
          )
        }
        .buttonStyle(.plain)
        .frame(maxWidth: expandable && tab.id != selection ? 64 : .infinity)
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
private struct GlassyTabItem: View {
  @Environment(\.nativeStyle) private var style
  let tab: NativeItem
  let isSelected: Bool
  let showsTitle: Bool
  let namespace: Namespace.ID

  var body: some View {
    VStack(spacing: 2) {
      NativeIcon(tab.image, size: 20)
      if showsTitle {
        Text(tab.title).font(.caption2.weight(.medium)).lineLimit(1)
      }
    }
    .foregroundStyle(foreground)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background { selectionCapsule }
    .overlay(alignment: .topTrailing) { badge }
    .contentShape(Capsule())
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(tab.title)
    .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
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

/// Floating glass capsule of buttons: toolbars, button groups, photo actions.
///
/// - `items`: buttons (icon, or title when no icon; `destructive` role is red)
/// - Events: `tap(itemId)`
struct GlassyToolbar: NativeComponent {
  static let componentId = "glassy-toolbar"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style

  var body: some View {
    HStack(spacing: style.spacing ?? 4) {
      ForEach(config.items ?? []) { item in
        Button { context.emit("tap", item.id) } label: {
          Group {
            if item.image != nil {
              NativeIcon(item.image, size: 18).frame(width: 44, height: 44)
            } else {
              Text(item.title).font(.body.weight(.semibold)).padding(.horizontal, 12).frame(height: 44)
            }
          }
          .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(item.role == .destructive ? Color.red : (style.foreground ?? Color.primary))
        .disabled(!item.isEnabled)
        .accessibilityLabel(item.title)
      }
    }
    .padding(.horizontal, 6)
    .padding(.vertical, 2)
    .nativeGlass(interactive: true)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

// MARK: - Menus

/// Glass button that opens a native menu.
///
/// - `title`: button text; `image`: optional leading icon; `items`: menu entries
///   (roles and nested `children` supported); `extra.prominent` (default true);
///   `extra.chevron` (default true). Without title and chevron it is a circle.
/// - Events: `select(itemId)`
struct GlassyMenuButton: NativeComponent {
  static let componentId = "glassy-menu-button"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config

  var body: some View {
    let chevron = config.extra("chevron", or: true)
    let iconOnly = config.title == nil && !chevron
    Menu {
      NativeMenuContent(items: config.items ?? []) { context.emit("select", $0.id) }
    } label: {
      HStack(spacing: 6) {
        if let image = config.image { NativeIcon(image) }
        if let title = config.title { Text(title) }
        if chevron { Image(systemName: "chevron.down").font(.footnote.weight(.semibold)) }
      }
      .frame(minWidth: iconOnly ? 28 : nil, minHeight: iconOnly ? 28 : nil)
    }
    .buttonBorderShape(iconOnly ? .circle : .capsule)
    .nativeButtonStyle(prominent: config.extra("prominent", or: true))
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

/// Pop-up button showing the current choice (`Menu` + `Picker`).
///
/// - `items`: options; `value`: selected id; `title`: optional label in front
/// - Events: `change(itemId)`
struct GlassyPopupButton: NativeComponent {
  static let componentId = "glassy-popup-button"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style
  @State private var selection = ""

  var body: some View {
    let options = config.items ?? []
    HStack {
      if let title = config.title {
        Text(title).foregroundStyle(style.foreground ?? .primary)
        Spacer()
      }
      Menu {
        Picker(config.title ?? "", selection: context.binding($selection)) {
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
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .seed($selection, from: config.value?.string ?? options.first?.id ?? "")
  }
}
