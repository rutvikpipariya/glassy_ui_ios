import AVKit
import MediaPlayer
import SwiftUI

// Media, photo and camera chrome. Artwork comes from `image` (or each item's
// `image`); pass a Flutter asset or bytes to show real photos.

/// Photo grid with selection mode and a bottom glass toolbar.
///
/// - `title` (default "Library"); `items`: photos (`image` = artwork)
/// - `extra.count`: number of placeholder photos when `items` is empty (default 45)
/// - Events: `open(itemId)`, `selecting(Bool)`, `share([ids])`, `delete([ids])`
struct GalleryToolbarComponent: NativeComponent {
  static let componentId = "gallery-toolbar"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @State private var selecting = false
  @State private var selected: Set<String> = []

  var body: some View {
    let photos = config.items(or: (0..<Int(config.extra("count", or: 45.0))).map { NativeItem(id: "\($0)", title: "Photo \($0 + 1)") })
    NavigationStack {
      ScrollView {
        LazyVGrid(columns: Array(repeating: GridItem(spacing: 2), count: 3), spacing: 2) {
          ForEach(Array(photos.enumerated()), id: \.element.id) { index, photo in
            NativeArtwork(photo.image, index: index)
              .aspectRatio(1, contentMode: .fill)
              .overlay(alignment: .bottomTrailing) {
                if selecting {
                  Image(systemName: selected.contains(photo.id) ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(.white, .blue)
                    .padding(6)
                }
              }
              .onTapGesture {
                guard selecting else { context.emit("open", photo.id); return }
                if selected.contains(photo.id) { selected.remove(photo.id) } else { selected.insert(photo.id) }
              }
          }
        }
      }
      .adaptiveScrollEdge()
      .navigationTitle(config.title ?? "Library")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button(selecting ? "Done" : "Select") {
            selecting.toggle()
            selected.removeAll()
            context.emit("selecting", selecting)
          }
        }
        ToolbarItemGroup(placement: .bottomBar) {
          Button { context.emit("share", Array(selected)) } label: { Image(systemName: "square.and.arrow.up") }
            .disabled(selected.isEmpty)
          Spacer()
          Text(selecting ? "\(selected.count) Selected" : "\(photos.count) Photos").font(.subheadline.weight(.semibold))
          Spacer()
          Button { context.emit("delete", Array(selected)) } label: { Image(systemName: "trash") }
            .disabled(selected.isEmpty)
        }
      }
    }
  }
}

/// Full-screen photo with glass top and bottom chrome; tap to hide chrome.
///
/// - `image`: the photo; `title` / `subtitle`: date and time
/// - `items`: center bottom actions (default favorite, info, edit)
/// - Events: `tap(String)`, `favorite(Bool)`
struct PhotoViewerToolbarComponent: NativeComponent {
  static let componentId = "photo-viewer-toolbar"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style
  @State private var chrome = true
  @State private var favorite = false

  var body: some View {
    let actions = config.items(or: [.symbol("Info", "info.circle"), .symbol("Edit", "slider.horizontal.3")])
    ZStack {
      (style.background ?? .black).ignoresSafeArea()
      NativeArtwork(config.image, index: 1)
        .aspectRatio(3 / 4, contentMode: .fit)
        .onTapGesture { withAnimation { chrome.toggle() } }
      if chrome {
        VStack {
          HStack {
            GlassIconButton("chevron.left", size: 16) { context.emit("tap", "back") }
            Spacer()
            VStack(spacing: 0) {
              Text(config.title ?? "Today").font(.subheadline.bold())
              Text(config.subtitle ?? "9:41 AM").font(.caption2).foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16).padding(.vertical, 6)
            .nativeGlass()
            Spacer()
            GlassIconButton("ellipsis", size: 16) { context.emit("tap", "more") }
          }
          Spacer()
          AdaptiveGlassContainer(spacing: 10) {
            HStack(spacing: 10) {
              GlassIconButton("square.and.arrow.up", size: 16) { context.emit("tap", "share") }
              Spacer()
              HStack(spacing: 18) {
                Button {
                  favorite.toggle()
                  context.emit("favorite", favorite)
                } label: {
                  Image(systemName: favorite ? "heart.fill" : "heart").contentTransition(.symbolEffect(.replace))
                }
                ForEach(actions) { item in
                  Button { context.emit("tap", item.id) } label: { NativeIcon(item.image, fallback: "circle") }
                }
              }
              .font(.system(size: 18, weight: .semibold))
              .buttonStyle(.plain)
              .padding(.horizontal, 20).padding(.vertical, 12)
              .nativeGlass()
              Spacer()
              GlassIconButton("trash", size: 16) { context.emit("tap", "delete") }
            }
          }
        }
        .padding()
        .transition(.opacity)
      }
    }
    .environment(\.colorScheme, .dark)
  }
}

/// Now-playing card: artwork, scrubber, transport and volume.
///
/// - `title`, `subtitle`, `image`: track info; `value`: position 0…1
/// - `max`: track length in seconds (default 215)
/// - Commands: `trigger` play/pause
/// - Events: `play`, `pause`, `previous`, `next`, `seek(Int seconds)`, `volume(Double)`
struct MediaControlsComponent: NativeComponent {
  static let componentId = "media-controls"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style
  @State private var playing = false
  @State private var position = 0.35
  @State private var volume = 0.6

  var body: some View {
    ComponentScaffold(dark: true) {
      VStack(spacing: style.spacing ?? 22) {
        NativeArtwork(config.image, index: 2)
          .frame(width: 240, height: 240)
          .clipShape(RoundedRectangle(cornerRadius: style.radius(24), style: .continuous))
          .shadow(radius: 20)
          .scaleEffect(playing ? 1 : 0.88)
          .animation(.spring, value: playing)
        VStack(spacing: 2) {
          Text(config.title ?? "Liquid Dreams").font(style.titleFont(.title3))
          Text(config.subtitle ?? "Glass Ensemble").foregroundStyle(.secondary)
        }
        Slider(value: $position) { editing in
          if !editing { context.emit("seek", Int(position * (config.maximum ?? 215))) }
        }
        HStack(spacing: 40) {
          Button { context.emit("previous") } label: { Image(systemName: "backward.fill") }
          Button(action: toggle) {
            Image(systemName: playing ? "pause.fill" : "play.fill")
              .font(.system(size: 40))
              .contentTransition(.symbolEffect(.replace))
          }
          Button { context.emit("next") } label: { Image(systemName: "forward.fill") }
        }
        .font(.title)
        .buttonStyle(.plain)
        HStack {
          Image(systemName: "speaker.fill")
          Slider(value: $volume) { editing in if !editing { context.emit("volume", volume) } }
          Image(systemName: "speaker.wave.3.fill")
        }
        .foregroundStyle(.secondary)
      }
      .padding(24)
      .nativeGlass(RoundedRectangle(cornerRadius: style.radius(36), style: .continuous), interactive: false)
    }
    .environment(\.colorScheme, .dark)
    .seed($position, from: config.double(or: 0.35))
    .onNativeCommand { _ in toggle() }
  }

  private func toggle() {
    playing.toggle()
    context.emit(playing ? "play" : "pause")
  }
}

/// Large glass play/pause toggle with symbol replace transition.
///
/// - `value`: initial playing state; `extra.size`: diameter (default 110)
/// - Commands: `trigger` toggles; Events: `play`, `pause`
struct PlayPauseComponent: NativeComponent {
  static let componentId = "play-pause"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style
  @State private var playing = false

  var body: some View {
    let size = config.extra("size", or: 110.0)
    ComponentScaffold {
      VStack(spacing: 30) {
        Button(action: toggle) {
          Image(systemName: playing ? "pause.fill" : "play.fill")
            .font(.system(size: size * 0.4))
            .foregroundStyle(style.foreground ?? .primary)
            .contentTransition(.symbolEffect(.replace))
            .frame(width: size, height: size)
        }
        .buttonStyle(.plain)
        .nativeGlass(Circle())
        HStack(spacing: 20) {
          GlassIconButton(playing ? "pause.fill" : "play.fill", action: toggle)
          GlassIconButton(playing ? "pause.circle.fill" : "play.circle.fill", prominent: true, action: toggle)
        }
      }
    }
    .seed($playing, from: config.bool(or: false))
    .onNativeCommand { _ in toggle() }
  }

  private func toggle() {
    playing.toggle()
    context.emit(playing ? "play" : "pause")
  }
}

/// Skip backward / forward buttons with bounce effect.
///
/// - `value`: start position in seconds (default 60)
/// - `extra.back` / `extra.forward`: skip intervals (10, 15, 30, 45…; default 15 / 30)
/// - Events: `skipBackward(Int)`, `skipForward(Int)`
struct SkipButtonsComponent: NativeComponent {
  static let componentId = "skip-buttons"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style
  @State private var position = 60
  @State private var backTrigger = 0
  @State private var forwardTrigger = 0

  var body: some View {
    let back = Int(config.extra("back", or: 15.0))
    let forward = Int(config.extra("forward", or: 30.0))
    ComponentScaffold {
      VStack(spacing: 24) {
        Text(String(format: "%d:%02d", position / 60, position % 60))
          .font(style.fontSize.map { .system(size: $0, weight: .bold, design: .rounded) } ?? .system(size: 64, weight: .bold, design: .rounded))
          .monospacedDigit()
          .foregroundStyle(style.foreground ?? .white)
          .contentTransition(.numericText(value: Double(position)))
        AdaptiveGlassContainer {
          HStack(spacing: style.spacing ?? 24) {
            skipButton("gobackward.\(back)", trigger: backTrigger) {
              backTrigger += 1
              withAnimation { position = max(0, position - back) }
              context.emit("skipBackward", position)
            }
            skipButton("goforward.\(forward)", trigger: forwardTrigger) {
              forwardTrigger += 1
              withAnimation { position += forward }
              context.emit("skipForward", position)
            }
          }
        }
      }
    }
    .seed($position, from: config.int(or: 60))
  }

  private func skipButton(_ symbol: String, trigger: Int, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      Image(systemName: symbol)
        .font(.system(size: 30, weight: .semibold))
        .symbolEffect(.bounce, value: trigger)
        .frame(width: 80, height: 80)
    }
    .buttonStyle(.plain)
    .nativeGlass(Circle())
  }
}

/// App volume slider plus the system `MPVolumeView` (device only).
///
/// - `title`, `value`: 0…1 (default 0.5); `extra.showSystem` (default true)
/// - Events: `change(Double)`
struct VolumeSliderComponent: NativeComponent {
  static let componentId = "volume-slider"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @State private var volume = 0.5

  var body: some View {
    ComponentScaffold {
      GlassCard(config.title ?? "App volume") {
        HStack(spacing: 14) {
          Image(systemName: "speaker.wave.3.fill", variableValue: volume)
            .frame(width: 30)
            .contentTransition(.symbolEffect(.replace))
          Slider(value: $volume) { editing in if !editing { context.emit("change", volume) } }
        }
      }
      if config.extra("showSystem", or: true) {
        GlassCard(config.subtitle ?? "MPVolumeView (system, device only)") {
          SystemVolumeView().frame(height: 40)
        }
      }
    }
    .seed($volume, from: config.double(or: 0.5))
  }
}

private struct SystemVolumeView: UIViewRepresentable {
  func makeUIView(context: Context) -> MPVolumeView { MPVolumeView() }
  func updateUIView(_ uiView: MPVolumeView, context: Context) {}
}

/// Full-screen media with glass close and minimize buttons.
///
/// - `image`: media artwork; `extra.showMinimize` (default true)
/// - Events: `close("xmark" | "minimize")`
struct MediaCloseComponent: NativeComponent {
  static let componentId = "media-close"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config

  var body: some View {
    ZStack(alignment: .topLeading) {
      NativeArtwork(config.image, index: 5).ignoresSafeArea()
      Image(systemName: "play.circle.fill")
        .font(.system(size: 80))
        .foregroundStyle(.white.opacity(0.9))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      HStack {
        GlassIconButton("xmark", size: 16) { context.emit("close", "xmark") }
        Spacer()
        if config.extra("showMinimize", or: true) {
          GlassIconButton("chevron.down", size: 16) { context.emit("close", "minimize") }
        }
      }
      .padding()
    }
    .environment(\.colorScheme, .dark)
  }
}

/// Picture-in-picture style mini player that can be dragged to any corner.
/// Reports whether system PiP (`AVPictureInPictureController`) is supported.
///
/// - `title`: list title; `image`: video artwork
/// - Commands: `trigger` toggles PiP
/// - Events: `pip({active, systemSupported})`, `snap(String corner)`, `close`
struct PiPControlsComponent: NativeComponent {
  static let componentId = "pip-controls"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style
  @Namespace private var namespace
  @State private var pip = false
  @State private var corner = Alignment.bottomTrailing
  @State private var drag = CGSize.zero

  var body: some View {
    ZStack(alignment: pip ? corner : .top) {
      NavigationStack {
        ItemList().navigationTitle(config.title ?? "Browsing")
      }
      .opacity(pip ? 1 : 0)

      player
        .matchedGeometryEffect(id: "video", in: namespace)
        .frame(width: pip ? 200 : nil, height: pip ? 112 : 260)
        .clipShape(RoundedRectangle(cornerRadius: pip ? style.radius(16) : 0, style: .continuous))
        .shadow(radius: pip ? 12 : 0)
        .padding(pip ? 16 : 0)
        .offset(drag)
        .gesture(pip ? dragGesture : nil)
    }
    .background(Color.black)
    .onNativeCommand { _ in togglePiP() }
  }

  private var player: some View {
    NativeArtwork(config.image, index: 3)
      .overlay(alignment: .top) {
        HStack {
          GlassIconButton(pip ? "pip.exit" : "pip.enter", size: 14, action: togglePiP)
          Spacer()
          if pip {
            GlassIconButton("xmark", size: 14) { context.emit("close") }
          }
        }
        .padding(8)
      }
      .overlay {
        HStack(spacing: 24) {
          Image(systemName: "gobackward.15")
          Image(systemName: "pause.fill").font(.title)
          Image(systemName: "goforward.15")
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 18).padding(.vertical, 8)
        .nativeGlass()
        .scaleEffect(pip ? 0.6 : 1)
      }
  }

  private var dragGesture: some Gesture {
    DragGesture()
      .onChanged { drag = $0.translation }
      .onEnded { value in
        let top = value.predictedEndLocation.y < value.startLocation.y - 100
        let leading = value.predictedEndLocation.x < value.startLocation.x - 60
        withAnimation(.spring) {
          corner = top ? (leading ? .topLeading : .topTrailing) : (leading ? .bottomLeading : .bottomTrailing)
          drag = .zero
        }
        context.emit("snap", "\(top ? "top" : "bottom")\(leading ? "Leading" : "Trailing")")
      }
  }

  private func togglePiP() {
    withAnimation(.spring(duration: 0.5)) { pip.toggle() }
    context.emit("pip", ["active": pip, "systemSupported": AVPictureInPictureController.isPictureInPictureSupported()])
  }
}

/// Camera chrome: flash, live photo, mode carousel, shutter and flip.
/// UI only — no camera session is started (no permission prompt).
///
/// - `image`: viewfinder preview; `items`: modes (default iOS camera modes); `value`: initial mode id
/// - Events: `flash(Bool)`, `mode(itemId)`, `capture({mode, count})`, `flip`, `tap("live")`
struct CameraControlsComponent: NativeComponent {
  static let componentId = "camera-controls"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style
  @State private var mode = ""
  @State private var flash = false
  @State private var shots = 0

  var body: some View {
    let modes = config.items(or: ["TIME-LAPSE", "VIDEO", "PHOTO", "PORTRAIT", "PANO"].map { NativeItem(title: $0) })
    ZStack {
      Color.black.ignoresSafeArea()
      VStack(spacing: 0) {
        HStack {
          GlassIconButton(flash ? "bolt.fill" : "bolt.slash.fill", size: 16) {
            flash.toggle()
            context.emit("flash", flash)
          }
          Spacer()
          GlassIconButton("livephoto", size: 16) { context.emit("tap", "live") }
        }
        .padding()
        NativeArtwork(config.image, index: 0)
          .aspectRatio(3 / 4, contentMode: .fit)
          .overlay { ThirdsGrid() }
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 18) {
            ForEach(modes) { item in
              Button(item.title) {
                withAnimation { mode = item.id }
                context.emit("mode", item.id)
              }
              .font(.footnote.weight(.semibold))
              .foregroundStyle(item.id == mode ? (style.tint ?? .yellow) : .white)
            }
          }
          .padding(.horizontal, 40)
        }
        .padding(.vertical, 12)
        HStack {
          NativeArtwork(config.image, index: shots)
            .frame(width: 48, height: 48)
            .clipShape(RoundedRectangle(cornerRadius: 8))
          Spacer()
          Button {
            shots += 1
            context.emit("capture", ["mode": mode, "count": shots])
          } label: {
            Circle().fill(mode.uppercased() == "VIDEO" ? .red : .white).frame(width: 64, height: 64)
              .padding(5)
              .overlay(Circle().stroke(.white, lineWidth: 4))
          }
          .buttonStyle(PressScaleButtonStyle(scale: 0.9))
          Spacer()
          GlassIconButton("arrow.triangle.2.circlepath", size: 18) { context.emit("flip") }
        }
        .padding(.horizontal, 30)
      }
    }
    .environment(\.colorScheme, .dark)
    .seed($mode, from: config.value?.string ?? (modes.first { $0.title.uppercased() == "PHOTO" } ?? modes[0]).id)
  }
}

/// Rule-of-thirds grid overlay.
struct ThirdsGrid: View {
  var body: some View {
    GeometryReader { geo in
      Path { path in
        for i in 1...2 {
          let x = geo.size.width * CGFloat(i) / 3
          let y = geo.size.height * CGFloat(i) / 3
          path.move(to: CGPoint(x: x, y: 0))
          path.addLine(to: CGPoint(x: x, y: geo.size.height))
          path.move(to: CGPoint(x: 0, y: y))
          path.addLine(to: CGPoint(x: geo.size.width, y: y))
        }
      }
      .stroke(.white.opacity(0.4), lineWidth: 0.5)
    }
  }
}

/// Camera zoom pills plus pinch to zoom.
///
/// - `image`: preview; `extra.presets`: zoom levels (default [0.5, 1, 2, 5]); `value`: initial zoom
/// - `max`: max zoom (default 10)
/// - Events: `change(Double)`
struct ZoomControlsComponent: NativeComponent {
  static let componentId = "zoom-controls"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style
  @Namespace private var namespace
  @State private var zoom: CGFloat = 1
  @State private var base: CGFloat = 1

  private var presets: [CGFloat] {
    let custom = config.extra["presets"]?.list?.compactMap(\.double).map { CGFloat($0) } ?? []
    return custom.isEmpty ? [0.5, 1, 2, 5] : custom
  }

  var body: some View {
    let maxZoom = CGFloat(config.maximum ?? 10)
    ZStack(alignment: .bottom) {
      NativeArtwork(config.image, index: 3)
        .scaleEffect(max(1, zoom))
        .clipped()
        .ignoresSafeArea()
        .gesture(
          MagnifyGesture()
            .onChanged { zoom = min(maxZoom, max(presets.first ?? 0.5, base * $0.magnification)) }
            .onEnded { _ in
              base = zoom
              context.emit("change", (zoom * 10).rounded() / 10)
            }
        )
      AdaptiveGlassContainer(spacing: 6) {
        HStack(spacing: 6) {
          ForEach(presets, id: \.self) { preset in
            let active = nearest == preset
            Button {
              withAnimation(.spring) {
                zoom = preset
                base = preset
              }
              context.emit("change", preset)
            } label: {
              Text(active ? String(format: "%.1g×", zoom) : String(format: "%.1g", preset))
                .font(.system(size: active ? 14 : 12, weight: .bold))
                .foregroundStyle(active ? (style.tint ?? .yellow) : .white)
                .frame(width: active ? 46 : 36, height: active ? 46 : 36)
            }
            .buttonStyle(.plain)
            .nativeGlass(Circle())
            .adaptiveGlassID(preset, in: namespace)
          }
        }
        .padding(6)
      }
      .padding(.bottom, style.padding ?? 40)
    }
    .environment(\.colorScheme, .dark)
    .seed($zoom, from: CGFloat(config.double(or: 1)))
  }

  private var nearest: CGFloat {
    presets.min { abs($0 - zoom) < abs($1 - zoom) } ?? 1
  }
}

/// Crop editor: aspect ratios, straighten dial, rotate and flip.
///
/// - `image`: photo; `items`: aspect ratios where `id` is "w:h" or "free"
/// - Events: `aspect(itemId)`, `rotate(Int)`, `flip(Bool)`, `done({angle, aspect})`
struct CropControlsComponent: NativeComponent {
  static let componentId = "crop-controls"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style
  @State private var aspect = "free"
  @State private var angle = 0.0
  @State private var flipped = false

  private var ratios: [NativeItem] {
    config.items(or: [
      NativeItem(id: "free", title: "Free"), NativeItem(id: "1:1", title: "Square"),
      NativeItem(id: "4:3", title: "4:3"), NativeItem(id: "16:9", title: "16:9"),
    ])
  }

  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()
      VStack(spacing: 20) {
        HStack {
          GlassIconButton("arrow.left.and.right.righttriangle.left.righttriangle.right", size: 14) {
            withAnimation { flipped.toggle() }
            context.emit("flip", flipped)
          }
          GlassIconButton("rotate.left", size: 14) {
            withAnimation { angle -= 90 }
            context.emit("rotate", Int(angle))
          }
          Spacer()
          Button(config.extra("doneTitle", or: "Done")) { context.emit("done", ["angle": angle, "aspect": aspect]) }
            .tint(style.tint ?? .yellow)
            .nativeButtonStyle(prominent: true)
        }
        NativeArtwork(config.image, index: 0)
          .aspectRatio(ratio(aspect) ?? 0.75, contentMode: .fit)
          .rotationEffect(.degrees(angle))
          .scaleEffect(x: flipped ? -1 : 1)
          .overlay { CropFrame() }
          .padding(24)
          .frame(maxHeight: .infinity)
        HStack {
          Image(systemName: "dial.low")
          Slider(value: $angle, in: -45...45, step: 1)
          Text("\(Int(angle))°").monospacedDigit().frame(width: 40)
        }
        .foregroundStyle(.white)
        AdaptiveGlassContainer(spacing: 8) {
          HStack(spacing: 8) {
            ForEach(ratios) { item in
              Button(item.title) {
                withAnimation(.snappy) { aspect = item.id }
                context.emit("aspect", item.id)
              }
              .font(.footnote.weight(.semibold))
              .foregroundStyle(aspect == item.id ? (style.tint ?? .yellow) : .white)
              .padding(.horizontal, 14).padding(.vertical, 10)
              .nativeGlass()
            }
          }
        }
      }
      .padding()
    }
    .environment(\.colorScheme, .dark)
  }

  /// Parses "w:h" into a width / height ratio.
  private func ratio(_ id: String) -> CGFloat? {
    let parts = id.split(separator: ":").compactMap { Double($0) }
    guard parts.count == 2, parts[1] > 0 else { return nil }
    return CGFloat(parts[0] / parts[1])
  }
}

private struct CropFrame: View {
  var body: some View {
    ZStack {
      Rectangle().stroke(.white, lineWidth: 1)
      ThirdsGrid()
      GeometryReader { geo in
        ForEach(0..<4, id: \.self) { corner in
          let x = corner % 2 == 0 ? 0 : geo.size.width
          let y = corner < 2 ? 0 : geo.size.height
          Path { path in
            let dx: CGFloat = corner % 2 == 0 ? 22 : -22
            let dy: CGFloat = corner < 2 ? 22 : -22
            path.move(to: CGPoint(x: x + dx, y: y))
            path.addLine(to: CGPoint(x: x, y: y))
            path.addLine(to: CGPoint(x: x, y: y + dy))
          }
          .stroke(.white, lineWidth: 4)
        }
      }
    }
  }
}
