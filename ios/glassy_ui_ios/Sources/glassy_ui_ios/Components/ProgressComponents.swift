import Combine
import SwiftUI
import UIKit

// Progress indicators.
//
// Determinate indicators accept a fixed `value` (0…1). When `value` is not
// set they run a simulated progress (`extra.speed` per tick, default 0.005)
// so the component is alive in demos. Commands: `trigger` / `reset` restart.

private let tick = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

/// Drives either a fixed progress from Dart or a simulated one.
private struct ProgressDriver: ViewModifier {
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Binding var progress: Double

  func body(content: Content) -> some View {
    content
      .seed($progress, from: config.value?.double ?? 0)
      .onReceive(tick) { _ in
        guard config.value == nil, progress < 1 else { return }
        progress = min(1, progress + config.extra("speed", or: 0.005))
        if progress >= 1 { context.emit("complete") }
      }
      .onNativeCommand { _ in progress = config.value?.double ?? 0 }
  }
}

/// Capacity gauge and gradient ring.
///
/// - `title`, `value`: 0…1 (simulated if unset); `style.tintColor`
/// - `extra.lineWidth`: ring width (default 12)
/// - Events: `complete`
struct CircularProgressComponent: NativeComponent {
  static let componentId = "circular-progress"
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style
  @State private var progress = 0.0

  var body: some View {
    let lineWidth = config.extra("lineWidth", or: 12.0)
    ComponentScaffold {
      GlassCard(config.title ?? "Gauge + custom ring") {
        HStack(spacing: 30) {
          Gauge(value: progress) { Text("") } currentValueLabel: { Text("\(Int(progress * 100))") }
            .gaugeStyle(.accessoryCircularCapacity)
            .tint(style.tint ?? .green)
            .scaleEffect(1.4)
          ZStack {
            Circle().stroke(.quaternary, lineWidth: lineWidth)
            Circle()
              .trim(from: 0, to: progress)
              .stroke(
                style.tint.map { AnyShapeStyle($0) } ?? AnyShapeStyle(AngularGradient(colors: [.blue, .purple, .pink], center: .center)),
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
              )
              .rotationEffect(.degrees(-90))
            Text("\(Int(progress * 100))%").font(style.titleFont(.title3)).monospacedDigit()
          }
          .frame(width: 110, height: 110)
        }
        .frame(maxWidth: .infinity)
      }
    }
    .modifier(ProgressDriver(progress: $progress))
  }
}

/// Linear progress bars.
///
/// - `title`, `value`: 0…1 (simulated if unset); `extra.height`: bar thickness scale
/// - Events: `complete`
struct LinearProgressComponent: NativeComponent {
  static let componentId = "linear-progress"
  @Environment(\.nativeConfig) private var config
  @State private var progress = 0.0

  var body: some View {
    ComponentScaffold {
      GlassCard(config.subtitle ?? "ProgressView(.linear)") {
        ProgressView(value: progress) {
          Text(config.title ?? "Syncing photos")
        } currentValueLabel: {
          Text(config.message ?? "\(Int(progress * 100))%")
        }
        ProgressView(value: progress).scaleEffect(x: 1, y: config.extra("height", or: 3.0))
      }
    }
    .modifier(ProgressDriver(progress: $progress))
  }
}

/// Step-based progress with Back / Next.
///
/// - `title`, `value`: current step (default 2), `max`: total steps (default 5)
/// - Commands: `trigger` next, `reset` to zero; Events: `change(Int)`
struct DeterminateProgressComponent: NativeComponent {
  static let componentId = "determinate-progress"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @State private var step = 0

  var body: some View {
    let total = Int(config.maximum ?? 5)
    ComponentScaffold {
      GlassCard("\(config.title ?? "Step") \(step) of \(total)") {
        ProgressView(value: Double(step), total: Double(total))
        Gauge(value: Double(step), in: 0...Double(total)) {
          Text(config.subtitle ?? "Setup")
        } currentValueLabel: {
          Text("\(step * 100 / max(total, 1))%")
        } minimumValueLabel: {
          Text("0")
        } maximumValueLabel: {
          Text("\(total)")
        }
        .gaugeStyle(.linearCapacity)
        HStack {
          Button(config.extra("backTitle", or: "Back")) { change(-1, total) }.nativeButtonStyle().disabled(step == 0)
          Spacer()
          Button(config.extra("nextTitle", or: "Next")) { change(1, total) }.nativeButtonStyle(prominent: true).disabled(step == total)
        }
      }
    }
    .seed($step, from: config.int(or: 2))
    .onNativeCommand { command in change(command.name == "reset" ? -step : 1, total) }
  }

  private func change(_ delta: Int, _ total: Int) {
    withAnimation { step = max(0, min(total, step + delta)) }
    context.emit("change", step)
  }
}

/// Spinners plus an animated indeterminate bar.
///
/// - `title`: spinner label (default "Loading…")
struct IndeterminateLoadingComponent: NativeComponent {
  static let componentId = "indeterminate-loading"
  @Environment(\.nativeConfig) private var config
  @State private var phase = false

  var body: some View {
    ComponentScaffold {
      GlassCard(config.subtitle ?? "Indeterminate") {
        HStack(spacing: 30) {
          ProgressView()
          ProgressView().controlSize(.large)
          ProgressView(config.title ?? "Loading…")
        }
        .frame(maxWidth: .infinity)
        GeometryReader { geo in
          Capsule().fill(.quaternary)
            .overlay(alignment: .leading) {
              Capsule().fill(.tint)
                .frame(width: geo.size.width * 0.35)
                .offset(x: phase ? geo.size.width * 0.65 : 0)
            }
            .clipShape(Capsule())
        }
        .frame(height: 6)
        .onAppear {
          withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) { phase = true }
        }
      }
    }
  }
}

/// App Store-style download button: ring with stop/resume, then "OPEN".
///
/// - `title`: app name, `subtitle`: size text, `image`: app icon
/// - `extra.openTitle` (default "OPEN"), `extra.speed`
/// - Commands: `trigger` start/pause, `reset`
/// - Events: `start(Int)`, `pause(Int)`, `progress(25|50|75|100)`, `complete`, `open`
struct DownloadProgressComponent: NativeComponent {
  static let componentId = "download-progress"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style
  @State private var progress = 0.0
  @State private var downloading = false
  @State private var milestone = 0

  var body: some View {
    ComponentScaffold {
      GlassCard(config.extra("cardTitle", or: "App Store-style download")) {
        HStack(spacing: 16) {
          NativeArtwork(config.image, index: 4)
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
          VStack(alignment: .leading) {
            Text(config.title ?? "Glass Studio").font(style.titleFont(.headline))
            Text(progress >= 1 ? "Installed" : downloading ? "Downloading…" : config.subtitle ?? "128 MB")
              .font(.caption).foregroundStyle(.secondary)
          }
          Spacer()
          Button(action: toggle) {
            ZStack {
              if progress >= 1 {
                Text(config.extra("openTitle", or: "OPEN")).font(.subheadline.bold()).padding(.horizontal, 14).padding(.vertical, 6)
              } else if downloading || progress > 0 {
                Circle().stroke(.quaternary, lineWidth: 3)
                Circle().trim(from: 0, to: progress).stroke(.tint, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                  .rotationEffect(.degrees(-90))
                Image(systemName: downloading ? "stop.fill" : "arrow.down").font(.system(size: 10, weight: .bold))
              } else {
                Image(systemName: "icloud.and.arrow.down").font(.title3)
              }
            }
            .frame(minWidth: 30, minHeight: 30)
          }
          .nativeButtonStyle()
          .buttonBorderShape(.capsule)
        }
      }
    }
    .onReceive(tick) { _ in
      guard downloading else { return }
      progress = min(1, progress + config.extra("speed", or: 0.006))
      let reached = Int(progress * 4)
      if reached > milestone {
        milestone = reached
        context.emit("progress", reached * 25)
      }
      if progress >= 1 {
        downloading = false
        context.emit("complete")
      }
    }
    .onNativeCommand { command in
      if command.name == "reset" {
        progress = 0
        milestone = 0
        downloading = false
      } else {
        toggle()
      }
    }
  }

  private func toggle() {
    guard progress < 1 else { context.emit("open"); return }
    downloading.toggle()
    context.emit(downloading ? "start" : "pause", Int(progress * 100))
  }
}

/// Multiple uploads, each with its own progress bar.
///
/// - `title`; `items`: files (title = file name); `extra.speed`
/// - Commands: `trigger` / `reset` restart; Events: `uploaded(itemId)`, `complete`
struct UploadProgressComponent: NativeComponent {
  static let componentId = "upload-progress"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @State private var progress: [String: Double] = [:]

  private var files: [NativeItem] {
    config.items(or: [NativeItem(title: "IMG_2041.HEIC"), NativeItem(title: "Trip.mov"), NativeItem(title: "Notes.pdf")])
  }

  var body: some View {
    let remaining = files.filter { (progress[$0.id] ?? 0) < 1 }.count
    ComponentScaffold {
      GlassCard(config.title ?? (remaining > 0 ? "Uploading \(remaining) files" : "All uploaded")) {
        ForEach(files) { file in
          let value = progress[file.id] ?? 0
          HStack {
            Image(systemName: value >= 1 ? "checkmark.icloud.fill" : "icloud.and.arrow.up")
              .foregroundStyle(value >= 1 ? AnyShapeStyle(.green) : AnyShapeStyle(.tint))
              .contentTransition(.symbolEffect(.replace))
            VStack(alignment: .leading, spacing: 4) {
              Text(file.title).font(.subheadline)
              ProgressView(value: value)
            }
          }
        }
      }
    }
    .onReceive(tick) { _ in advance() }
    .onNativeCommand { _ in progress = [:] }
  }

  private func advance() {
    let base = config.extra("speed", or: 0.01)
    for (index, file) in files.enumerated() where (progress[file.id] ?? 0) < 1 {
      let next = min(1, (progress[file.id] ?? 0) + base * [1.2, 0.4, 2.0][index % 3])
      progress[file.id] = next
      if next >= 1 {
        context.emit("uploaded", file.id)
        if files.allSatisfy({ (progress[$0.id] ?? 0) >= 1 }) { context.emit("complete") }
      }
    }
  }
}

/// UIKit `UIActivityIndicatorView` in medium, large and tinted styles.
///
/// - `title`, `value`: animating (default true); `style.tintColor` colors the third spinner
/// - Commands: `trigger` toggles; Events: `change(Bool)`
struct ActivityIndicatorComponent: NativeComponent {
  static let componentId = "activity-indicator"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style
  @State private var animating = true

  var body: some View {
    ComponentScaffold {
      GlassCard(config.title ?? "UIActivityIndicatorView") {
        HStack(spacing: 36) {
          ActivityIndicator(style: .medium, animating: animating)
          ActivityIndicator(style: .large, animating: animating)
          ActivityIndicator(style: .large, color: UIColor(style.tint ?? .pink), animating: animating)
        }
        .frame(maxWidth: .infinity)
        Toggle(config.extra("toggleTitle", or: "Animating"), isOn: $animating)
      }
    }
    .seed($animating, from: config.bool(or: true))
    .onChange(of: animating) { _, value in context.emit("change", value) }
    .onNativeCommand { _ in animating.toggle() }
  }
}

/// SwiftUI wrapper for `UIActivityIndicatorView`.
public struct ActivityIndicator: UIViewRepresentable {
  private let style: UIActivityIndicatorView.Style
  private let color: UIColor?
  private let animating: Bool

  public init(style: UIActivityIndicatorView.Style, color: UIColor? = nil, animating: Bool) {
    self.style = style
    self.color = color
    self.animating = animating
  }

  public func makeUIView(context: Context) -> UIActivityIndicatorView {
    let view = UIActivityIndicatorView(style: style)
    view.hidesWhenStopped = false
    return view
  }

  public func updateUIView(_ view: UIActivityIndicatorView, context: Context) {
    view.color = color
    if animating { view.startAnimating() } else { view.stopAnimating() }
  }
}
