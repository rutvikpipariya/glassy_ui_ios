import SwiftUI

/// Linear bar or circular ring; without a value it is a spinner.
///
/// - `value`: 0…1 (omit for indeterminate); `extra.style`: "linear" | "circular"
/// - `title`: label above a linear bar
struct GlassyProgress: NativeComponent {
  static let componentId = "glassy-progress"
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style

  var body: some View {
    content
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .animation(.easeInOut, value: config.value?.double)
  }

  @ViewBuilder
  private var content: some View {
    if let value = config.value?.double {
      if config.extra("style", or: "linear") == "circular" {
        ring(min(max(value, 0), 1))
      } else {
        ProgressView(value: min(max(value, 0), 1)) {
          if let title = config.title { Text(title).foregroundStyle(style.foreground ?? .primary) }
        }
      }
    } else {
      ProgressView()
    }
  }

  private func ring(_ value: Double) -> some View {
    GeometryReader { proxy in
      let side = min(proxy.size.width, proxy.size.height)
      let line = max(side * 0.1, 3)
      ZStack {
        Circle().stroke(Color.secondary.opacity(0.2), lineWidth: line)
        Circle()
          .trim(from: 0, to: value)
          .stroke(.tint, style: StrokeStyle(lineWidth: line, lineCap: .round))
          .rotationEffect(.degrees(-90))
        Text(value, format: .percent.precision(.fractionLength(0)))
          .font(.system(size: side * 0.24, weight: .semibold).monospacedDigit())
          .foregroundStyle(style.foreground ?? .primary)
      }
      .padding(line / 2)
      .frame(width: side, height: side)
      .frame(width: proxy.size.width, height: proxy.size.height)
    }
  }
}

/// Glass play / pause button with an animated symbol swap.
///
/// - `value`: playing
/// - Events: `change(Bool)`
struct GlassyPlayPause: NativeComponent {
  static let componentId = "glassy-play-pause"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style
  @State private var playing = false

  var body: some View {
    GeometryReader { proxy in
      let side = min(proxy.size.width, proxy.size.height)
      Button {
        playing.toggle()
        context.emit("change", playing)
      } label: {
        Image(systemName: playing ? "pause.fill" : "play.fill")
          .font(.system(size: side * 0.38, weight: .bold))
          .foregroundStyle(style.foreground ?? .primary)
          .contentTransition(.symbolEffect(.replace))
          .frame(width: side, height: side)
          .contentShape(Circle())
      }
      .buttonStyle(.plain)
      .nativeGlass(Circle(), interactive: true)
      .frame(width: proxy.size.width, height: proxy.size.height)
    }
    .accessibilityLabel(playing ? "Pause" : "Play")
    .seed($playing, from: config.bool(or: false))
  }
}

/// Previous / play-pause / next controls in a glass capsule.
///
/// - `value`: playing
/// - Events: `change(Bool)` (play/pause), `previous`, `next`
struct GlassyMediaControls: NativeComponent {
  static let componentId = "glassy-media-controls"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style
  @State private var playing = false

  var body: some View {
    HStack(spacing: 32) {
      control("backward.fill", label: "Previous") { context.emit("previous") }
      control(playing ? "pause.fill" : "play.fill", size: 30, label: playing ? "Pause" : "Play") {
        playing.toggle()
        context.emit("change", playing)
      }
      control("forward.fill", label: "Next") { context.emit("next") }
    }
    .padding(.horizontal, 28)
    .padding(.vertical, 12)
    .nativeGlass(interactive: true)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .seed($playing, from: config.bool(or: false))
  }

  private func control(_ symbol: String, size: CGFloat = 22, label: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      Image(systemName: symbol)
        .font(.system(size: size, weight: .bold))
        .foregroundStyle(style.foreground ?? .primary)
        .contentTransition(.symbolEffect(.replace))
        .frame(width: 44, height: 44)
        .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .accessibilityLabel(label)
  }
}
