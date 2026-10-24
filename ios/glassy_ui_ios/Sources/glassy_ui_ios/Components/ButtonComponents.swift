import SwiftUI

// Buttons. All buttons honor `style.tintColor`, `style.glass` and
// `style.controlSize`; text buttons emit `tap(itemId)`.

/// Glass buttons in every control size.
///
/// - `title`: button text (default "Glass"); `image`: optional icon
/// - `items`: custom buttons instead of the size showcase
struct GlassButtonComponent: NativeComponent {
  static let componentId = "glass-button"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config

  var body: some View {
    ComponentScaffold {
      GlassCard(GlassSupport.isAvailable ? ".buttonStyle(.glass)" : ".buttonStyle(.bordered)") {
        if let items = config.items, !items.isEmpty {
          ForEach(items) { item in
            Button { context.emit("tap", item.id) } label: { NativeItemLabel(item) }
              .nativeButtonStyle()
              .disabled(!item.isEnabled)
          }
        } else {
          ForEach([ControlSize.small, .regular, .large, .extraLarge], id: \.self) { size in
            Button { context.emit("tap", String(describing: size)) } label: { label }
              .controlSize(size)
              .nativeButtonStyle()
          }
        }
      }
    }
  }

  @ViewBuilder
  private var label: some View {
    let title = config.title ?? "Glass"
    if let image = config.image {
      Label { Text(title) } icon: { NativeIcon(image) }
    } else {
      Text(title)
    }
  }
}

/// Prominent (filled) glass buttons, one per tint.
///
/// - `title` (default "Continue"), `image` (default arrow.right)
/// - `extra.tints`: list of ARGB ints; defaults to blue/green/orange/pink
struct ProminentGlassButtonComponent: NativeComponent {
  static let componentId = "prominent-glass-button"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style

  private var tints: [Color] {
    if let custom = config.extra["tints"]?.list?.compactMap({ $0.double.map { Color(argb: Int($0)) } }), !custom.isEmpty {
      return custom
    }
    return style.tint.map { [$0] } ?? [.blue, .green, .orange, .pink]
  }

  var body: some View {
    ComponentScaffold {
      GlassCard(GlassSupport.isAvailable ? ".buttonStyle(.glassProminent)" : ".buttonStyle(.borderedProminent)") {
        ForEach(Array(tints.enumerated()), id: \.offset) { index, color in
          Button { context.emit("tap", index) } label: {
            Label { Text(config.title ?? "Continue") } icon: { NativeIcon(config.image, fallback: "arrow.right") }
              .frame(maxWidth: .infinity)
          }
          .controlSize(style.controlSize ?? .large)
          .tint(color)
          .nativeButtonStyle(prominent: true)
        }
      }
    }
  }
}

/// Grid of image buttons with a glass play badge.
///
/// - `items`: tiles; each item's `image` is the artwork (asset/bytes recommended)
/// - `image`: badge icon (default play.fill); `style.cornerRadius` for tiles
/// - Events: `tap(itemId)`
struct ImageButtonComponent: NativeComponent {
  static let componentId = "image-button"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style

  var body: some View {
    let tiles = config.items(or: (1...6).map { NativeItem(title: "Album \($0)") })
    ComponentScaffold {
      LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: style.spacing ?? 16) {
        ForEach(Array(tiles.enumerated()), id: \.element.id) { index, item in
          Button { context.emit("tap", item.id) } label: {
            NativeArtwork(item.image, index: index)
              .aspectRatio(1, contentMode: .fit)
              .clipShape(RoundedRectangle(cornerRadius: style.radius(22), style: .continuous))
              .overlay(alignment: .bottomTrailing) {
                NativeIcon(config.image, fallback: "play.fill")
                  .frame(width: 40, height: 40)
                  .nativeGlass(Circle())
                  .padding(10)
              }
          }
          .buttonStyle(PressScaleButtonStyle())
        }
      }
    }
  }
}

/// Circular icon buttons, both glass button style and interactive glass circles.
///
/// - `items`: icons (default communication symbols)
/// - Events: `tap(itemId)`
struct CircularIconButtonComponent: NativeComponent {
  static let componentId = "circular-icon-button"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style

  var body: some View {
    let icons = config.items(or: ["heart.fill", "message.fill", "phone.fill", "video.fill", "location.fill", "bell.fill"].map { .symbol($0, $0) })
    ComponentScaffold {
      GlassCard("Glass button style") {
        HStack(spacing: style.spacing ?? 14) {
          ForEach(icons.prefix(4)) { item in
            GlassIconButton(image: item.image, size: 18) { context.emit("tap", item.id) }
          }
        }
      }
      GlassCard("Interactive glass circles") {
        HStack(spacing: style.spacing ?? 18) {
          ForEach(icons.suffix(3)) { item in
            Button { context.emit("tap", item.id) } label: {
              NativeIcon(item.image, size: 24)
                .frame(width: 64, height: 64)
                .nativeGlass(Circle(), tint: style.glassTint ?? .blue.opacity(0.4))
            }
            .buttonStyle(.plain)
          }
        }
      }
    }
  }
}

/// SF Symbol buttons with effects: bounce, replace, variable value and palette.
///
/// - `image`: symbol used for the bounce button (default bell.badge.fill)
/// - Events: `bounce`, `liked(Bool)`, `variableValue(Double)`, `tap(String)`
struct SFSymbolsButtonComponent: NativeComponent {
  static let componentId = "sf-symbols-button"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @State private var bounce = 0
  @State private var liked = false
  @State private var level = 0.3

  var body: some View {
    ComponentScaffold {
      GlassCard(config.title ?? "Symbol effects & rendering modes") {
        HStack(spacing: 18) {
          Button {
            bounce += 1
            context.emit("bounce")
          } label: {
            NativeIcon(config.image, fallback: "bell.badge.fill")
              .symbolRenderingMode(.multicolor)
              .symbolEffect(.bounce, value: bounce)
              .font(.title)
          }
          Button {
            liked.toggle()
            context.emit("liked", liked)
          } label: {
            Image(systemName: liked ? "heart.fill" : "heart")
              .contentTransition(.symbolEffect(.replace))
              .foregroundStyle(.pink)
              .font(.title)
          }
          Button {
            level = level >= 1 ? 0 : level + 0.34
            context.emit("variableValue", level)
          } label: {
            Image(systemName: "wifi", variableValue: level).font(.title)
          }
          Button { context.emit("tap", "palette") } label: {
            Image(systemName: "cloud.sun.rain.fill")
              .symbolRenderingMode(.palette)
              .foregroundStyle(.white, .yellow, .cyan)
              .font(.title)
          }
        }
        .nativeButtonStyle()
      }
    }
  }
}

/// Counter with large glass plus/minus buttons. Shared by Plus and Minus.
///
/// - `value`: initial count (default 5); `min` / `max`: bounds; `step`: delta
/// - Commands: `trigger` applies one step, `reset` restores `value`
/// - Events: `increment(Int)`, `decrement(Int)`
struct CounterButton: View {
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style
  let primarySymbol: String
  let direction: Int
  @State private var count = 0

  var body: some View {
    let step = Int(config.step ?? 1) * direction
    ComponentScaffold {
      VStack(spacing: 30) {
        Text("\(count)")
          .font(style.fontSize.map { .system(size: $0, weight: .bold, design: .rounded) } ?? .system(size: 96, weight: .bold, design: .rounded))
          .foregroundStyle(style.foreground ?? .white)
          .contentTransition(.numericText(value: Double(count)))
        HStack(spacing: 24) {
          GlassIconButton(image: config.image ?? .system(primarySymbol), prominent: true, size: 30) { change(step) }
          GlassIconButton(direction > 0 ? "minus" : "plus", size: 22) { change(-step) }
        }
      }
    }
    .seed($count, from: config.int(or: 5))
    .onNativeCommand { command in
      if command.name == "reset" { withAnimation(.snappy) { count = config.int(or: 5) } } else { change(step) }
    }
  }

  private func change(_ delta: Int) {
    let range = config.range(or: -1_000_000...1_000_000)
    withAnimation(.snappy) { count = Int(min(max(Double(count + delta), range.lowerBound), range.upperBound)) }
    context.emit(delta > 0 ? "increment" : "decrement", count)
  }
}

struct PlusButtonComponent: NativeComponent {
  static let componentId = "plus-button"
  var body: some View { CounterButton(primarySymbol: "plus", direction: 1) }
}

struct MinusButtonComponent: NativeComponent {
  static let componentId = "minus-button"
  var body: some View { CounterButton(primarySymbol: "minus", direction: -1) }
}

/// Floating action button that morphs into a stack of actions.
///
/// - `image`: FAB icon (default plus); `items`: actions
/// - Commands: `trigger` toggles; Events: `fab(String)`, `action(itemId)`
struct FloatingActionButtonComponent: NativeComponent {
  static let componentId = "floating-action-button"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style
  @Namespace private var namespace
  @State private var expanded = false

  var body: some View {
    let actions = config.items(or: [.symbol("Photo", "camera.fill"), .symbol("Document", "doc.fill"), .symbol("Voice memo", "mic.fill")])
    ZStack(alignment: .bottomTrailing) {
      NavigationStack {
        List(Array(SampleItems.make(30).enumerated()), id: \.element.id) { index, item in ItemRow(item, index: index) }
          .navigationTitle(config.title ?? "Files")
      }
      AdaptiveGlassContainer(spacing: 16) {
        VStack(alignment: .trailing, spacing: style.spacing ?? 14) {
          if expanded {
            ForEach(actions) { item in
              Button {
                context.emit("action", item.id)
                withAnimation(.bouncy) { expanded = false }
              } label: {
                NativeItemLabel(item).padding(.horizontal, 16).padding(.vertical, 12)
              }
              .buttonStyle(.plain)
              .nativeGlass()
              .adaptiveGlassID(item.id, in: namespace)
            }
          }
          Button(action: toggle) {
            NativeIcon(config.image, fallback: "plus", size: 22)
              .rotationEffect(.degrees(expanded ? 45 : 0))
              .foregroundStyle(style.foreground ?? .white)
              .frame(width: 60, height: 60)
          }
          .buttonStyle(.plain)
          .nativeGlass(Circle(), tint: style.tint ?? .blue)
          .adaptiveGlassID("fab", in: namespace)
        }
      }
      .padding(style.padding ?? 24)
    }
    .onNativeCommand { _ in toggle() }
  }

  private func toggle() {
    withAnimation(.bouncy) { expanded.toggle() }
    context.emit("fab", expanded ? "expanded" : "collapsed")
  }
}

/// Toolbar avatar that opens an account menu.
///
/// - `title`: initials (default "RP"); `image`: avatar picture (asset/bytes)
/// - `items`: menu actions (`role: destructive` supported)
/// - Events: `menu(itemId)`
struct AvatarActionButtonComponent: NativeComponent {
  static let componentId = "avatar-action-button"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config

  var body: some View {
    let actions = config.items(or: [
      .symbol("Profile", "person"), .symbol("Settings", "gear"),
      .symbol("Sign Out", "rectangle.portrait.and.arrow.right", role: .destructive),
    ])
    NavigationStack {
      ItemList()
        .navigationTitle(config.subtitle ?? "Home")
        .toolbar {
          ToolbarItem(placement: .topBarTrailing) {
            Menu {
              ForEach(actions) { item in
                NativeItemButton(item) { context.emit("menu", $0.id) }
              }
            } label: {
              avatar
            }
          }
        }
    }
  }

  @ViewBuilder
  private var avatar: some View {
    if let image = config.image?.uiImage {
      Image(uiImage: image).resizable().scaledToFill().frame(width: 32, height: 32).clipShape(Circle())
    } else {
      Text(config.title ?? "RP")
        .font(.caption.weight(.bold))
        .foregroundStyle(.white)
        .frame(width: 32, height: 32)
        .background(LinearGradient(colors: [.purple, .pink], startPoint: .top, endPoint: .bottom), in: Circle())
    }
  }
}
