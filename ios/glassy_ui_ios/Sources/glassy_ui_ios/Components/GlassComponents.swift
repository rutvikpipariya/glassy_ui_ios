import SwiftUI

// Liquid Glass showcases. On iOS 17–18 each falls back to materials.

/// Scroll content under the bar with a soft/hard scroll-edge effect.
///
/// - `title`; `value`: "soft" | "hard"; `items`: cards (`image` = artwork)
/// - Events: `change(String)`
struct ScrollEdgeComponent: NativeComponent {
  static let componentId = "scroll-edge"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style
  @State private var hard = false

  var body: some View {
    let cards = config.items(or: (0..<30).map { NativeItem(id: "\($0)", title: "Card \($0 + 1)") })
    NavigationStack {
      ScrollView {
        LazyVStack(spacing: style.spacing ?? 12) {
          ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
            NativeArtwork(card.image, index: index)
              .frame(height: 120)
              .clipShape(RoundedRectangle(cornerRadius: style.radius(20), style: .continuous))
          }
        }
        .padding(style.padding ?? 16)
      }
      .adaptiveScrollEdge(hard: hard)
      .navigationTitle(config.title ?? "Scroll Edge")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Picker("Style", selection: $hard) {
            Text("Soft").tag(false)
            Text("Hard").tag(true)
          }
          .pickerStyle(.segmented)
          .frame(width: 160)
        }
      }
    }
    .seed($hard, from: config.string(or: "soft") == "hard")
    .onChange(of: hard) { _, value in context.emit("change", value ? "hard" : "soft") }
  }
}

/// Regular, clear and tinted glass panels.
///
/// - `items`: panels — `title`, `subtitle`; `id` "clear…" uses clear glass
/// - `style.glassTint` tints the tinted samples
struct GlassBackgroundComponent: NativeComponent {
  static let componentId = "glass-background"
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style

  var body: some View {
    let panels = config.items(or: [
      NativeItem(id: "regular", title: "Regular", subtitle: "Glass.regular — adapts to content"),
      NativeItem(id: "clear", title: "Clear", subtitle: "Glass.clear — for media-rich backgrounds"),
      NativeItem(id: "regular-tint", title: "Tinted", subtitle: "Glass.regular.tint(…)"),
      NativeItem(id: "clear-tint", title: "Tinted clear", subtitle: "Glass.clear.tint(…)"),
    ])
    ComponentScaffold {
      ForEach(panels) { panel in
        VStack(alignment: .leading, spacing: 4) {
          Text(panel.title).font(style.titleFont(.title3)).foregroundStyle(style.foreground ?? .primary)
          if let subtitle = panel.subtitle { Text(subtitle).font(.caption) }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .adaptiveGlass(
          RoundedRectangle(cornerRadius: style.radius(24), style: .continuous),
          variant: panel.id.hasPrefix("clear") ? .clear : .regular,
          tint: panel.id.hasSuffix("tint") ? (style.glassTint ?? (panel.id.hasPrefix("clear") ? .orange : .blue)) : nil
        )
      }
    }
  }
}

/// Five-pointed star.
public struct StarShape: Shape {
  private let points: Int
  private let innerRatio: CGFloat

  public init(points: Int = 5, innerRatio: CGFloat = 0.45) {
    self.points = max(points, 3)
    self.innerRatio = innerRatio
  }

  public func path(in rect: CGRect) -> Path {
    let center = CGPoint(x: rect.midX, y: rect.midY)
    let outer = min(rect.width, rect.height) / 2
    var path = Path()
    for index in 0..<(points * 2) {
      let radius = index.isMultiple(of: 2) ? outer : outer * innerRatio
      let angle = Double(index) * .pi / Double(points) - .pi / 2
      let point = CGPoint(x: center.x + CGFloat(cos(angle)) * radius, y: center.y + CGFloat(sin(angle)) * radius)
      if index == 0 { path.move(to: point) } else { path.addLine(to: point) }
    }
    path.closeSubpath()
    return path
  }
}

/// Organic blob shape.
public struct BlobShape: Shape {
  public init() {}

  public func path(in rect: CGRect) -> Path {
    var path = Path()
    path.move(to: CGPoint(x: rect.minX + rect.width * 0.5, y: rect.minY))
    path.addCurve(to: CGPoint(x: rect.maxX, y: rect.midY), control1: CGPoint(x: rect.maxX * 0.95, y: rect.minY), control2: CGPoint(x: rect.maxX, y: rect.height * 0.2))
    path.addCurve(to: CGPoint(x: rect.midX, y: rect.maxY), control1: CGPoint(x: rect.maxX, y: rect.maxY * 0.9), control2: CGPoint(x: rect.width * 0.8, y: rect.maxY))
    path.addCurve(to: CGPoint(x: rect.minX, y: rect.midY), control1: CGPoint(x: rect.width * 0.1, y: rect.maxY), control2: CGPoint(x: rect.minX, y: rect.height * 0.8))
    path.addCurve(to: CGPoint(x: rect.midX, y: rect.minY), control1: CGPoint(x: rect.minX, y: rect.height * 0.1), control2: CGPoint(x: rect.width * 0.2, y: rect.minY))
    return path
  }
}

/// A shape picked by name from Dart: circle, capsule, rounded, ellipse, star, blob.
public struct NamedShape: Shape {
  private let name: String
  private let cornerRadius: CGFloat

  public init(_ name: String, cornerRadius: CGFloat = 30) {
    self.name = name
    self.cornerRadius = cornerRadius
  }

  public func path(in rect: CGRect) -> Path {
    switch name {
    case "circle": Circle().path(in: rect)
    case "capsule": Capsule().path(in: rect)
    case "ellipse": Ellipse().path(in: rect)
    case "star": StarShape().path(in: rect)
    case "blob": BlobShape().path(in: rect)
    default: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous).path(in: rect)
    }
  }
}

/// Glass applied to built-in and custom shapes.
///
/// - `items`: shapes; `id` is the shape name (circle, capsule, rounded, ellipse, star, blob)
/// - `extra.size`: tile size (default 130); Events: `tap(itemId)`
struct CustomGlassShapeComponent: NativeComponent {
  static let componentId = "custom-glass-shape"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style

  var body: some View {
    let shapes = config.items(or: ["circle", "capsule", "rounded", "ellipse", "star", "blob"].map { NativeItem(id: $0, title: $0.capitalized) })
    let size = config.extra("size", or: 130.0)
    ComponentScaffold {
      LazyVGrid(columns: [GridItem(), GridItem()], spacing: style.spacing ?? 24) {
        ForEach(shapes) { shape in
          VStack {
            NativeIcon(shape.image, fallback: "sparkles", size: 28)
              .frame(width: size, height: shape.id == "capsule" ? size * 0.55 : size)
              .nativeGlass(NamedShape(shape.id, cornerRadius: style.radius(30)))
              .frame(height: size)
            Text(shape.title).font(.caption.bold()).foregroundStyle(style.foreground ?? .white)
          }
          .onTapGesture { context.emit("tap", shape.id) }
        }
      }
    }
  }
}

/// Segmented-looking group of glass buttons merged with `glassEffectUnion`.
///
/// - `items`: grouped buttons (default text alignment); `value`: selected id
/// - Events: `change(itemId)`, `tap(String)`
struct GlassButtonGroupComponent: NativeComponent {
  static let componentId = "glass-button-group"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style
  @Namespace private var namespace
  @State private var selection = ""

  var body: some View {
    let buttons = config.items(or: ["text.alignleft", "text.aligncenter", "text.alignright", "text.justify"].map { .symbol($0, $0) })
    ComponentScaffold {
      VStack(spacing: 30) {
        AdaptiveGlassContainer(spacing: 20) {
          HStack(spacing: 0) {
            ForEach(buttons) { item in
              Button {
                selection = item.id
                context.emit("change", item.id)
              } label: {
                NativeIcon(item.image, size: 18)
                  .foregroundStyle(selection == item.id ? AnyShapeStyle(.tint) : AnyShapeStyle(style.foreground ?? .primary))
                  .frame(width: 56, height: 50)
              }
              .buttonStyle(.plain)
              .nativeGlass(Rectangle())
              .adaptiveGlassUnion("group", in: namespace)
            }
          }
          .modifier(ClassicCapsuleGroup())
        }
        AdaptiveGlassContainer(spacing: 12) {
          HStack(spacing: 12) {
            GlassIconButton("arrow.uturn.backward", size: 16) { context.emit("tap", "undo") }
            GlassIconButton("arrow.uturn.forward", size: 16) { context.emit("tap", "redo") }
          }
        }
      }
    }
    .seed($selection, from: config.value?.string ?? buttons[0].id)
  }
}

/// Without glass union (iOS 17–18), clip the row into one capsule.
private struct ClassicCapsuleGroup: ViewModifier {
  func body(content: Content) -> some View {
    if GlassSupport.isAvailable {
      content
    } else {
      content.clipShape(Capsule())
    }
  }
}

/// Glass circles in one `GlassEffectContainer` that blend as they approach.
///
/// - `items`: circles (`image` = icon); `value`: spacing (default 40); `min`/`max` slider range
/// - Events: `change(Int spacing)`
struct GlassContainerComponent: NativeComponent {
  static let componentId = "glass-container"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @State private var distance = 40.0

  var body: some View {
    let circles = config.items(or: ["sun.max.fill", "moon.fill", "cloud.fill"].map { .symbol($0, $0) })
    ComponentScaffold {
      VStack(spacing: 40) {
        AdaptiveGlassContainer(spacing: 40) {
          HStack(spacing: distance) {
            ForEach(circles) { item in
              NativeIcon(item.image, size: 26)
                .frame(width: 80, height: 80)
                .nativeGlass(Circle())
            }
          }
        }
        .frame(height: 140)
        GlassCard("\(config.title ?? "Element spacing"): \(Int(distance))pt") {
          Slider(value: $distance, in: config.range(or: -30...60)) { editing in
            if !editing { context.emit("change", Int(distance)) }
          }
          Text(GlassSupport.isAvailable
            ? "Shapes inside one GlassEffectContainer blend together as they approach."
            : "Liquid blending requires iOS 26 — classic materials shown.")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      }
    }
    .seed($distance, from: config.double(or: 40))
  }
}

/// A button that morphs into a column of tool buttons (`glassEffectID`).
///
/// - `image`: toggle icon; `items`: tools; `value`: start expanded
/// - Commands: `trigger` toggles; Events: `expanded`, `collapsed`, `select(itemId)`
struct GlassMorphingComponent: NativeComponent {
  static let componentId = "glass-morphing"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style
  @Namespace private var namespace
  @State private var expanded = false

  var body: some View {
    let tools = config.items(or: ["pencil", "eraser", "lasso", "ruler"].map { .symbol($0, $0) })
    ComponentScaffold {
      AdaptiveGlassContainer(spacing: 24) {
        VStack(spacing: style.spacing ?? 14) {
          if expanded {
            ForEach(tools) { tool in
              Button { context.emit("select", tool.id) } label: {
                NativeIcon(tool.image, size: 22).frame(width: 64, height: 64)
              }
              .buttonStyle(.plain)
              .nativeGlass(Circle())
              .adaptiveGlassID(tool.id, in: namespace)
            }
          }
          Button(action: toggle) {
            Group {
              if expanded {
                Image(systemName: "xmark").font(.system(size: 22, weight: .semibold))
              } else {
                NativeIcon(config.image, fallback: "paintbrush.pointed.fill", size: 22)
              }
            }
            .frame(width: 72, height: 72)
          }
          .buttonStyle(.plain)
          .nativeGlass(Circle(), tint: style.glassTint ?? .purple.opacity(0.5))
          .adaptiveGlassID("toggle", in: namespace)
        }
      }
    }
    .seed($expanded, from: config.bool(or: false))
    .onNativeCommand { _ in toggle() }
  }

  private func toggle() {
    withAnimation(.bouncy(duration: 0.45)) { expanded.toggle() }
    context.emit(expanded ? "expanded" : "collapsed")
  }
}

/// Show/hide glass elements with `.materialize` or `.matchedGeometry` transitions.
///
/// - `items`: badges (`image` = icon); `value`: "materialize" | "matchedGeometry"
/// - Commands: `trigger` toggles; Events: `shown(String)`, `hidden(String)`
struct GlassTransitionComponent: NativeComponent {
  static let componentId = "glass-transition"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @State private var visible = true
  @State private var materialize = true

  var body: some View {
    let badges = config.items(or: ["bell.fill", "heart.fill", "star.fill"].map { .symbol($0, $0) })
    ComponentScaffold {
      VStack(spacing: 30) {
        AdaptiveGlassContainer(spacing: 20) {
          HStack(spacing: 20) {
            if visible {
              ForEach(badges) { badge($0) }
            }
          }
        }
        .frame(height: 90)
        GlassCard(config.title ?? "Transition") {
          Picker("Transition", selection: $materialize) {
            Text("Materialize").tag(true)
            Text("Matched").tag(false)
          }
          .pickerStyle(.segmented)
          Button(visible ? "Hide" : "Show", action: toggle)
            .nativeButtonStyle(prominent: true)
        }
      }
    }
    .seed($materialize, from: config.string(or: "materialize") == "materialize")
    .onNativeCommand { _ in toggle() }
  }

  @ViewBuilder
  private func badge(_ item: NativeItem) -> some View {
    let view = NativeIcon(item.image, size: 26)
      .frame(width: 72, height: 72)
      .nativeGlass(Circle())
    if #available(iOS 26.0, *) {
      view.glassEffectTransition(materialize ? .materialize : .matchedGeometry)
    } else {
      view.transition(.scale.combined(with: .opacity))
    }
  }

  private func toggle() {
    withAnimation(.smooth(duration: 0.5)) { visible.toggle() }
    context.emit(visible ? "shown" : "hidden", materialize ? "materialize" : "matchedGeometry")
  }
}

/// Icon appearances matching iOS 26 home screen modes.
public enum IconAppearance: String, CaseIterable {
  case `default` = "Default"
  case dark = "Dark"
  case clear = "Clear"
  case tinted = "Tinted"
}

/// App icon with layered glass styling across Default / Dark / Clear / Tinted.
///
/// - `image`: foreground symbol or bitmap; `items`: home-screen icons
/// - `value`: initial appearance name; `style.backgroundGradient`: icon background
/// - `style.glassTint`: tinted mode color
/// - Events: `change(String)`
struct AppIconComponent: NativeComponent {
  static let componentId = "app-icon"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @State private var appearance = IconAppearance.default

  var body: some View {
    let icons = config.items(or: ["camera.fill", "message.fill", "music.note", "map.fill", "heart.fill", "gamecontroller.fill", "cloud.sun.fill", "bolt.fill"].map { .symbol($0, $0) })
    ComponentScaffold {
      VStack(spacing: 30) {
        LayeredIcon(image: config.image ?? .system("drop.fill"), appearance: appearance, size: 180)
        LazyVGrid(columns: Array(repeating: GridItem(), count: 4), spacing: 18) {
          ForEach(icons) { LayeredIcon(image: $0.image ?? .system("app"), appearance: appearance, size: 62) }
        }
        Picker("Appearance", selection: $appearance) {
          ForEach(IconAppearance.allCases, id: \.self) { Text($0.rawValue) }
        }
        .pickerStyle(.segmented)
        .padding(6)
        .nativeGlass()
      }
    }
    .seed($appearance, from: config.value?.string.flatMap(IconAppearance.init(rawValue:)) ?? .default)
    .onChange(of: appearance) { _, value in context.emit("change", value.rawValue) }
  }
}

/// Icon built from three layers: background, back shape and foreground glyph,
/// plus a specular edge highlight.
public struct LayeredIcon: View {
  @Environment(\.nativeStyle) private var style
  private let image: NativeImageSource
  private let appearance: IconAppearance
  private let size: CGFloat

  public init(image: NativeImageSource, appearance: IconAppearance, size: CGFloat) {
    self.image = image
    self.appearance = appearance
    self.size = size
  }

  public var body: some View {
    let shape = RoundedRectangle(cornerRadius: size * 0.225, style: .continuous)
    let gradient = style.backgroundGradient ?? [.cyan, .blue]
    ZStack {
      switch appearance {
      case .dark: shape.fill(Color(white: 0.12))
      case .clear: Color.clear.adaptiveGlass(shape, variant: .clear)
      case .tinted: Color.clear.adaptiveGlass(shape, tint: (style.glassTint ?? .teal).opacity(0.5))
      case .default: shape.fill(LinearGradient(colors: gradient, startPoint: .top, endPoint: .bottom))
      }
      Circle()
        .fill(Color.white.opacity(appearance == .default ? 0.35 : 0.15))
        .frame(width: size * 0.62)
        .offset(x: size * 0.08, y: size * 0.06)
      NativeIcon(image, size: size * 0.42)
        .foregroundStyle(foreground(gradient))
        .shadow(color: .black.opacity(0.25), radius: size * 0.03, y: size * 0.02)
      shape.stroke(
        LinearGradient(colors: [.white.opacity(0.7), .clear, .white.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing),
        lineWidth: max(1, size * 0.012)
      )
    }
    .frame(width: size, height: size)
    .shadow(color: .black.opacity(0.2), radius: size * 0.08, y: size * 0.04)
    .animation(.smooth, value: appearance)
  }

  private func foreground(_ gradient: [Color]) -> AnyShapeStyle {
    switch appearance {
    case .dark: AnyShapeStyle(LinearGradient(colors: gradient, startPoint: .top, endPoint: .bottom))
    case .tinted: AnyShapeStyle((style.glassTint ?? .teal).opacity(0.9))
    default: AnyShapeStyle(Color.white)
    }
  }
}

/// Widget rendering modes, mirroring WidgetKit's full color / clear / tinted.
public enum WidgetAppearance: String, CaseIterable {
  case fullColor = "Full Color"
  case clear = "Clear"
  case tinted = "Tinted"
}

/// Small and medium widgets previewed in each rendering mode.
///
/// - `title` / `subtitle` / `message`: medium widget texts; `value`: appearance name
/// - `extra.city`, `extra.temperature`, `extra.battery` (0…1)
/// - Events: `change(String)`
struct WidgetAppearanceComponent: NativeComponent {
  static let componentId = "widget-appearance"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style
  @State private var mode = WidgetAppearance.fullColor

  var body: some View {
    let battery = config.extra("battery", or: 0.72)
    ComponentScaffold {
      VStack(spacing: 20) {
        HStack(spacing: 16) {
          widget(small: true) {
            VStack(alignment: .leading) {
              Text(config.extra("city", or: "Cupertino")).font(.caption.bold())
              Text(config.extra("temperature", or: "21°")).font(.system(size: 40, weight: .light))
              Spacer()
              Image(systemName: "cloud.sun.fill").symbolRenderingMode(mode == .fullColor ? .multicolor : .monochrome)
            }
          }
          widget(small: true) {
            VStack {
              Gauge(value: battery) { Image(systemName: "battery.75percent") }
                .gaugeStyle(.accessoryCircularCapacity)
                .tint(mode == .fullColor ? (style.tint ?? .green) : .primary)
              Text("\(Int(battery * 100))%").font(.headline)
            }
          }
        }
        widget(small: false) {
          HStack {
            VStack(alignment: .leading, spacing: 6) {
              Text(config.subtitle ?? "Up Next").font(.caption.bold()).foregroundStyle(mode == .fullColor ? (style.tint ?? .red) : .primary)
              Text(config.title ?? "Design review").font(style.titleFont(.headline))
              Text(config.message ?? "10:30 – 11:15 AM").font(.caption)
            }
            Spacer()
            NativeIcon(config.image, fallback: "calendar", size: 34)
          }
        }
        Picker("Mode", selection: $mode) {
          ForEach(WidgetAppearance.allCases, id: \.self) { Text($0.rawValue) }
        }
        .pickerStyle(.segmented)
        .padding(6)
        .nativeGlass()
      }
    }
    .seed($mode, from: config.value?.string.flatMap(WidgetAppearance.init(rawValue:)) ?? .fullColor)
    .onChange(of: mode) { _, value in context.emit("change", value.rawValue) }
  }

  @ViewBuilder
  private func widget<Content: View>(small: Bool, @ViewBuilder content: () -> Content) -> some View {
    let shape = RoundedRectangle(cornerRadius: style.radius(24), style: .continuous)
    let body = content()
      .padding(16)
      .frame(maxWidth: small ? 160 : .infinity, minHeight: 160, maxHeight: 160, alignment: .topLeading)
    switch mode {
    case .clear:
      body.foregroundStyle(.white).adaptiveGlass(shape, variant: .clear)
    case .tinted:
      body.foregroundStyle(.white.opacity(0.9)).adaptiveGlass(shape, tint: (style.glassTint ?? .indigo).opacity(0.55))
    case .fullColor:
      body.background(style.surface ?? Color(.systemBackground), in: shape)
    }
  }
}
