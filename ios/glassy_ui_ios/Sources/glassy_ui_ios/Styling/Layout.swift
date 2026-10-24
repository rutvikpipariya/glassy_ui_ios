import SwiftUI

// MARK: - Background

/// Background driven by the style: solid color, gradient, the decorative
/// backdrop (default) or the system background.
public struct ComponentBackground: View {
  @Environment(\.nativeStyle) private var style
  private let dark: Bool

  public init(dark: Bool = false) {
    self.dark = dark
  }

  public var body: some View {
    Group {
      if let background = style.background {
        background
      } else if let gradient = style.backgroundGradient, gradient.count > 1 {
        LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
      } else if style.showBackdrop {
        DecorativeBackdrop(dark: dark)
      } else {
        Color(.systemBackground)
      }
    }
    .ignoresSafeArea()
  }
}

/// Colorful gradient with soft blobs and symbols so glass refraction is visible.
struct DecorativeBackdrop: View {
  var dark = false
  private let symbols = ["star.fill", "heart.fill", "bolt.fill", "leaf.fill", "moon.fill", "cloud.fill", "flame.fill", "drop.fill", "sparkles"]

  var body: some View {
    LinearGradient(
      colors: dark ? [.black, .indigo.opacity(0.8), .black] : [.indigo, .purple, .pink, .orange],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
    .overlay {
      GeometryReader { geo in
        Circle().fill(.cyan.opacity(0.7))
          .frame(width: geo.size.width * 0.7)
          .blur(radius: 30)
          .offset(x: -geo.size.width * 0.2, y: geo.size.height * 0.05)
        Circle().fill(.yellow.opacity(0.6))
          .frame(width: geo.size.width * 0.55)
          .blur(radius: 40)
          .offset(x: geo.size.width * 0.55, y: geo.size.height * 0.55)
      }
    }
    .overlay {
      VStack(spacing: 30) {
        ForEach(0..<14, id: \.self) { row in
          HStack(spacing: 30) {
            ForEach(0..<8, id: \.self) { column in
              Image(systemName: symbols[(row * 8 + column) % symbols.count])
                .font(.title2)
                .foregroundStyle(.white.opacity(0.28))
            }
          }
        }
      }
    }
    .clipped()
  }
}

// MARK: - Scaffold & cards

/// Background + scrollable, centred content. Padding and spacing follow the style.
public struct ComponentScaffold<Content: View>: View {
  @Environment(\.nativeStyle) private var style
  private let dark: Bool
  private let content: Content

  public init(dark: Bool = false, @ViewBuilder content: () -> Content) {
    self.dark = dark
    self.content = content()
  }

  public var body: some View {
    ZStack {
      ComponentBackground(dark: dark)
      ScrollView {
        VStack(spacing: style.spacing ?? 20) { content }
          .padding(style.padding ?? 20)
          .frame(maxWidth: .infinity, minHeight: 500)
      }
      .scrollBounceBehavior(.basedOnSize)
    }
  }
}

/// A titled glass card. Corner radius, title font and colors follow the style.
public struct GlassCard<Content: View>: View {
  @Environment(\.nativeStyle) private var style
  private let title: String?
  private let content: Content

  public init(_ title: String? = nil, @ViewBuilder content: () -> Content) {
    self.title = title
    self.content = content()
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      if let title {
        Text(title)
          .font(style.titleFont(.headline))
          .foregroundStyle(style.foreground ?? .primary)
      }
      content
    }
    .padding(18)
    .frame(maxWidth: .infinity, alignment: .leading)
    .nativeGlass(RoundedRectangle(cornerRadius: style.radius(26), style: .continuous), interactive: false)
  }
}

// MARK: - Images

/// Renders a `NativeImageSource` as an icon. SF Symbols scale with `size`
/// (or the current font); bitmaps are fitted into a `size × size` frame.
public struct NativeIcon: View {
  private let source: NativeImageSource?
  private let fallback: String
  private let size: CGFloat?

  public init(_ source: NativeImageSource?, fallback: String = "questionmark", size: CGFloat? = nil) {
    self.source = source
    self.fallback = fallback
    self.size = size
  }

  public var body: some View {
    if let image = source?.uiImage {
      Image(uiImage: image)
        .resizable()
        .scaledToFit()
        .frame(width: size ?? 22, height: size ?? 22)
    } else {
      let name: String = if case .system(let symbol) = source { symbol } else { fallback }
      if let size {
        Image(systemName: name).font(.system(size: size, weight: .semibold))
      } else {
        Image(systemName: name)
      }
    }
  }
}

/// Large artwork: a bitmap fills the frame, a symbol is drawn on a gradient
/// tile, and `nil` falls back to a generated placeholder tile.
public struct NativeArtwork: View {
  private let source: NativeImageSource?
  private let index: Int

  public init(_ source: NativeImageSource?, index: Int = 0) {
    self.source = source
    self.index = index
  }

  public var body: some View {
    if let image = source?.uiImage {
      Color.clear.overlay {
        Image(uiImage: image).resizable().scaledToFill()
      }
      .clipped()
    } else if case .system(let symbol) = source {
      PlaceholderTile(index: index, symbol: symbol)
    } else {
      PlaceholderTile(index: index)
    }
  }
}

/// Gradient tile with a symbol, used where no image was provided.
public struct PlaceholderTile: View {
  private static let palettes: [[Color]] = [[.orange, .pink], [.blue, .teal], [.purple, .indigo], [.green, .mint], [.red, .orange], [.cyan, .blue]]
  private static let symbols = ["mountain.2.fill", "sun.max.fill", "tree.fill", "building.2.fill", "water.waves", "camera.macro"]
  private let index: Int
  private let symbol: String?

  public init(index: Int, symbol: String? = nil) {
    self.index = index
    self.symbol = symbol
  }

  public var body: some View {
    LinearGradient(colors: Self.palettes[abs(index) % Self.palettes.count], startPoint: .topLeading, endPoint: .bottomTrailing)
      .overlay {
        Image(systemName: symbol ?? Self.symbols[abs(index) % Self.symbols.count])
          .font(.system(size: 40))
          .foregroundStyle(.white.opacity(0.85))
      }
  }
}

/// `Label` for a `NativeItem`, using its image (any source) as the icon.
public struct NativeItemLabel: View {
  private let item: NativeItem

  public init(_ item: NativeItem) {
    self.item = item
  }

  public var body: some View {
    if item.image == nil {
      Text(item.title)
    } else {
      Label { Text(item.title) } icon: { NativeIcon(item.image) }
    }
  }
}

/// Menu/dialog button for a `NativeItem`, honoring its role and enabled state.
public struct NativeItemButton: View {
  private let item: NativeItem
  private let action: (NativeItem) -> Void

  public init(_ item: NativeItem, action: @escaping (NativeItem) -> Void) {
    self.item = item
    self.action = action
  }

  public var body: some View {
    Button(role: item.role.buttonRole) { action(item) } label: { NativeItemLabel(item) }
      .disabled(!item.isEnabled)
  }
}

// MARK: - Buttons

/// iOS 26 `Button(role: .close)`; an `xmark.circle.fill` button otherwise.
public struct CloseButton: View {
  private let action: () -> Void

  public init(action: @escaping () -> Void) {
    self.action = action
  }

  public var body: some View {
    if #available(iOS 26.0, *) {
      Button(role: .close, action: action)
    } else {
      Button(action: action) {
        Image(systemName: "xmark.circle.fill")
          .font(.title2)
          .symbolRenderingMode(.hierarchical)
          .foregroundStyle(.secondary)
      }
    }
  }
}

/// Circular icon button using the style-aware glass button style.
public struct GlassIconButton: View {
  private let image: NativeImageSource?
  private let prominent: Bool
  private let size: CGFloat
  private let action: () -> Void

  public init(_ systemName: String, prominent: Bool = false, size: CGFloat = 22, action: @escaping () -> Void) {
    self.init(image: .system(systemName), prominent: prominent, size: size, action: action)
  }

  public init(image: NativeImageSource?, prominent: Bool = false, size: CGFloat = 22, action: @escaping () -> Void) {
    self.image = image
    self.prominent = prominent
    self.size = size
    self.action = action
  }

  public var body: some View {
    Button(action: action) {
      NativeIcon(image, size: size).frame(width: size * 1.6, height: size * 1.6)
    }
    .buttonBorderShape(.circle)
    .nativeButtonStyle(prominent: prominent)
  }
}

/// Scales the label while pressed.
public struct PressScaleButtonStyle: ButtonStyle {
  private let scale: CGFloat

  public init(scale: CGFloat = 0.94) {
    self.scale = scale
  }

  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(configuration.isPressed ? scale : 1)
      .animation(.spring(duration: 0.25), value: configuration.isPressed)
  }
}

// MARK: - Lists

/// Row for a `NativeItem`: colored icon tile, title and subtitle.
public struct ItemRow: View {
  private static let colors: [Color] = [.blue, .orange, .pink, .green, .red, .purple, .teal, .indigo]
  private let item: NativeItem
  private let index: Int

  public init(_ item: NativeItem, index: Int) {
    self.item = item
    self.index = index
  }

  public var body: some View {
    HStack(spacing: 12) {
      NativeIcon(item.image, fallback: "circle.grid.2x2.fill", size: 16)
        .foregroundStyle(.white)
        .frame(width: 34, height: 34)
        .background(Self.colors[index % Self.colors.count].gradient, in: RoundedRectangle(cornerRadius: 9, style: .continuous))
      VStack(alignment: .leading, spacing: 2) {
        Text(item.title).foregroundStyle(.primary)
        if let subtitle = item.subtitle {
          Text(subtitle).font(.caption).foregroundStyle(.secondary)
        }
      }
      Spacer()
      if let badge = item.badge {
        Text(badge).font(.caption.bold()).foregroundStyle(.secondary)
      }
    }
    .contentShape(Rectangle())
  }
}

/// Default rows used when Dart supplies no `items`.
enum SampleItems {
  private static let symbols = ["envelope.fill", "photo.fill", "music.note", "map.fill", "bell.fill", "gamecontroller.fill", "book.fill", "cart.fill"]

  static func make(_ count: Int) -> [NativeItem] {
    (0..<count).map { index in
      NativeItem(title: "Item \(index + 1)", subtitle: "Native SwiftUI row", image: .system(symbols[index % symbols.count]))
    }
  }
}

/// Scrollable list of the configured `items` (or samples). Emits `select`.
/// With `links`, rows push a `NativeItem.title` value onto a NavigationStack.
struct ItemList: View {
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  var count = 30
  var links = false

  var body: some View {
    let items = config.items(or: SampleItems.make(count))
    List(Array(items.enumerated()), id: \.element.id) { index, item in
      if links {
        NavigationLink(value: item.title) { ItemRow(item, index: index) }
      } else {
        Button { context.emit("select", item.id) } label: { ItemRow(item, index: index) }
          .tint(.primary)
      }
    }
  }
}

/// Simple destination page for navigation components.
struct DetailPage: View {
  let title: String
  var message = "Pushed natively with NavigationStack. Use the system back button or swipe from the left edge."

  var body: some View {
    ComponentScaffold {
      GlassCard(title) {
        Text(message).foregroundStyle(.secondary)
      }
    }
  }
}
