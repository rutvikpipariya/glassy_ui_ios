import SwiftUI

/// Glass button with a title and/or icon.
///
/// - `title`, `image`; `extra.prominent`: filled glass
/// - Events: `tap`
struct GlassyButton: NativeComponent {
  static let componentId = "glassy-button"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config

  var body: some View {
    Button { context.emit("tap") } label: { label }
      .nativeButtonStyle(prominent: config.extra("prominent", or: false))
      .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  @ViewBuilder
  private var label: some View {
    if let title = config.title, let image = config.image {
      Label { Text(title) } icon: { NativeIcon(image) }
    } else if let title = config.title {
      Text(title)
    } else {
      NativeIcon(config.image, fallback: "circle")
    }
  }
}

/// Single circular glass icon button.
///
/// - `image`: icon (default circle); `extra.prominent`: filled glass; `extra.iconSize`
/// - `extra.label`: VoiceOver label
/// - Events: `tap`
struct GlassyIconButton: NativeComponent {
  static let componentId = "glassy-icon-button"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config

  var body: some View {
    GlassIconButton(
      image: config.image ?? .system("circle"),
      prominent: config.extra("prominent", or: false),
      size: config.extra("iconSize", or: 18.0)
    ) { context.emit("tap") }
      .accessibilityLabel(config.extra("label", or: ""))
      .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

/// Tinted glass floating action button. With `items` it expands into a
/// column of labelled actions above it.
///
/// - `image` (default plus); `items`: actions
/// - Events: `tap` (no items), `select(itemId)`, `expanded(Bool)`
struct GlassyFloatingActionButton: NativeComponent {
  static let componentId = "glassy-fab"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style
  @State private var expanded = false

  var body: some View {
    let actions = config.items ?? []
    VStack(alignment: .trailing, spacing: 12) {
      if expanded {
        ForEach(actions) { item in
          Button {
            context.emit("select", item.id)
            setExpanded(false)
          } label: {
            HStack(spacing: 8) {
              Text(item.title).font(.subheadline.weight(.semibold))
              NativeIcon(item.image, fallback: "circle", size: 16)
            }
            .foregroundStyle(item.role == .destructive ? Color.red : (style.foreground ?? Color.primary))
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
          }
          .buttonStyle(.plain)
          .nativeGlass(interactive: true)
          .transition(.scale(scale: 0.6, anchor: .bottomTrailing).combined(with: .opacity))
        }
      }
      Button {
        if actions.isEmpty { context.emit("tap") } else { setExpanded(!expanded) }
      } label: {
        NativeIcon(config.image, fallback: "plus", size: 22)
          .rotationEffect(.degrees(expanded ? 45 : 0))
          .foregroundStyle(.white)
          .frame(width: 56, height: 56)
          .contentShape(Circle())
      }
      .buttonStyle(.plain)
      .nativeGlass(Circle(), tint: style.tint ?? .accentColor, interactive: true)
      .accessibilityLabel(config.title ?? "Add")
    }
    .padding(4)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
  }

  private func setExpanded(_ value: Bool) {
    if value {
      // Dart grows the view first so the actions have room to appear.
      context.emit("expanded", true)
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
        withAnimation(.bouncy) { expanded = true }
      }
    } else {
      withAnimation(.bouncy) { expanded = false }
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { context.emit("expanded", false) }
    }
  }
}

/// Circular avatar (initials or photo) that opens a menu.
///
/// - `title`: initials; `image`: photo; `items`: menu entries
/// - Events: `select(itemId)`
struct GlassyAvatarButton: NativeComponent {
  static let componentId = "glassy-avatar-button"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style

  var body: some View {
    GeometryReader { proxy in
      let side = min(proxy.size.width, proxy.size.height)
      Menu {
        NativeMenuContent(items: config.items ?? []) { context.emit("select", $0.id) }
      } label: {
        avatar
          .frame(width: side, height: side)
          .clipShape(Circle())
          .overlay(Circle().stroke(.white.opacity(0.6), lineWidth: 1))
      }
      .frame(width: proxy.size.width, height: proxy.size.height)
    }
    .accessibilityLabel(config.title ?? "Account")
  }

  @ViewBuilder
  private var avatar: some View {
    if let image = config.image?.uiImage {
      Image(uiImage: image).resizable().scaledToFill()
    } else {
      Text(config.title ?? "")
        .font(.callout.weight(.bold))
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background((style.tint ?? .purple).gradient)
    }
  }
}

/// Artwork tile with a glass badge, e.g. a video or album cover.
///
/// - `image`: artwork (asset/bytes; a symbol draws a gradient tile)
/// - `extra.badge`: SF Symbol of the badge (default play.fill; "" hides it)
/// - `style.cornerRadius`; Events: `tap`
struct GlassyImageButton: NativeComponent {
  static let componentId = "glassy-image-button"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style

  var body: some View {
    let badge = config.extra("badge", or: "play.fill")
    Button { context.emit("tap") } label: {
      NativeArtwork(config.image)
        .overlay(alignment: .bottomTrailing) {
          if !badge.isEmpty {
            Image(systemName: badge)
              .font(.system(size: 14, weight: .bold))
              .foregroundStyle(.white)
              .frame(width: 36, height: 36)
              .nativeGlass(Circle())
              .padding(10)
          }
        }
        .clipShape(RoundedRectangle(cornerRadius: style.cornerRadius ?? 18, style: .continuous))
    }
    .buttonStyle(PressScaleButtonStyle())
    .accessibilityLabel(config.title ?? "")
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
