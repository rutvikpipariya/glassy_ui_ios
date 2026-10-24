import SwiftUI

// Value controls. Each one seeds its state from `value` and reports changes
// with a `change` event so Dart can stay in sync.

/// Segmented picker driving a small bar chart.
///
/// - `items`: segments (default Day/Week/Month/Year); `value`: selected item id
/// - Events: `change(itemId)`
struct SegmentedControlComponent: NativeComponent {
  static let componentId = "segmented-control"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @State private var selection = ""

  var body: some View {
    let segments = config.items(or: ["Day", "Week", "Month", "Year"].map { NativeItem(title: $0) })
    let index = segments.firstIndex { $0.id == selection } ?? 0
    ComponentScaffold {
      GlassCard(config.title ?? "Picker(.segmented)") {
        Picker(config.title ?? "Segments", selection: $selection) {
          ForEach(segments) { NativeItemLabel($0).tag($0.id) }
        }
        .pickerStyle(.segmented)
        HStack(alignment: .bottom, spacing: 8) {
          ForEach(0..<(6 + index * 2), id: \.self) { bar in
            RoundedRectangle(cornerRadius: 4)
              .fill(.tint)
              .frame(height: CGFloat(30 + (bar * 37 % 90)))
          }
        }
        .frame(height: 130, alignment: .bottom)
        .animation(.snappy, value: selection)
      }
    }
    .seed($selection, from: config.value?.string ?? segments.first(where: \.isSelected)?.id ?? segments[min(1, segments.count - 1)].id)
    .onChange(of: selection) { _, value in context.emit("change", value) }
  }
}

/// List of switches.
///
/// - `items`: switches; `selected` sets the initial state
/// - Commands: `trigger` toggles the first switch
/// - Events: `change({id, on})`
struct ToggleComponent: NativeComponent {
  static let componentId = "toggle"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @State private var states: [String: Bool] = [:]

  private var items: [NativeItem] {
    config.items(or: [
      NativeItem(title: "Airplane Mode", image: .system("airplane")),
      NativeItem(title: "Wi-Fi", image: .system("wifi"), isSelected: true),
      NativeItem(title: "Bluetooth", image: .system("wave.3.right")),
    ])
  }

  var body: some View {
    ComponentScaffold {
      GlassCard(config.title ?? "Toggle(.switch)") {
        ForEach(items) { item in
          Toggle(isOn: binding(item.id)) { NativeItemLabel(item) }
            .disabled(!item.isEnabled)
        }
      }
    }
    .seed($states, from: Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0.isSelected) }))
    .onNativeCommand { _ in
      if let first = items.first { binding(first.id).wrappedValue.toggle() }
    }
  }

  private func binding(_ id: String) -> Binding<Bool> {
    Binding(
      get: { states[id] ?? false },
      set: { value in
        states[id] = value
        context.emit("change", ["id": id, "on": value])
      }
    )
  }
}

/// Stepper.
///
/// - `title`: label prefix (default "Quantity"); `value`, `min`, `max`, `step`
/// - Events: `change(Double)`
struct StepperComponent: NativeComponent {
  static let componentId = "stepper"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @State private var value = 0.0

  var body: some View {
    let step = config.step ?? 1
    ComponentScaffold {
      GlassCard(config.subtitle ?? "Stepper") {
        Stepper(value: $value, in: config.range(or: 0...10), step: step) {
          Label {
            Text("\(config.title ?? "Quantity"): \(value.formatted(.number.precision(.fractionLength(step < 1 ? 1 : 0))))")
          } icon: {
            NativeIcon(config.image, fallback: "number")
          }
        }
      }
    }
    .seed($value, from: config.double(or: 2))
    .onChange(of: value) { _, newValue in context.emit("change", newValue) }
  }
}

/// Slider with min/max icons.
///
/// - `title`, `value` (0.6), `min`/`max` (0…1), `step`
/// - `extra.minImage` / `extra.maxImage`: SF Symbol names
/// - Commands: `trigger` sets a random value
/// - Events: `change(Double)` when dragging ends
struct SliderComponent: NativeComponent {
  static let componentId = "slider"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @State private var value = 0.0

  var body: some View {
    let range = config.range(or: 0...1)
    ComponentScaffold {
      GlassCard(config.title ?? "Slider") {
        Slider(value: $value, in: range) {
          Text(config.title ?? "Value")
        } minimumValueLabel: {
          Image(systemName: config.extra("minImage", or: "sun.min"))
        } maximumValueLabel: {
          Image(systemName: config.extra("maxImage", or: "sun.max.fill"))
        } onEditingChanged: { editing in
          if !editing { context.emit("change", value) }
        }
        Text(value.formatted(.number.precision(.fractionLength(2)))).monospacedDigit().foregroundStyle(.secondary)
      }
    }
    .seed($value, from: config.double(or: range.lowerBound + (range.upperBound - range.lowerBound) * 0.6))
    .onNativeCommand { _ in
      withAnimation { value = .random(in: range) }
      context.emit("change", value)
    }
  }
}

/// Stepped slider with tick marks (native ticks on iOS 26, drawn before).
///
/// - `title`, `value` (1), `min`/`max` (0.5…2), `step` (0.25)
/// - `extra.labels`: captions under the track
/// - Events: `change(Double)`
struct SliderTicksComponent: NativeComponent {
  static let componentId = "slider-ticks"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @State private var value = 1.0

  var body: some View {
    let labels = config.extra("labels", or: ["0.5×", "1×", "1.5×", "2×"])
    ComponentScaffold {
      GlassCard("\(config.title ?? "Playback speed")  \(value.formatted())") {
        slider
        HStack {
          ForEach(Array(labels.enumerated()), id: \.offset) { index, label in
            Text(label).font(.caption2)
            if index < labels.count - 1 { Spacer() }
          }
        }
        .foregroundStyle(.secondary)
      }
    }
    .seed($value, from: config.double(or: 1))
  }

  @ViewBuilder
  private var slider: some View {
    let range = config.range(or: 0.5...2)
    let step = config.step ?? 0.25
    if #available(iOS 26.0, *) {
      Slider(
        value: $value, in: range, step: step,
        label: { Text(config.title ?? "Value") },
        tick: { SliderTick($0) },
        onEditingChanged: { editing in if !editing { context.emit("change", value) } }
      )
    } else {
      let ticks = max(1, Int(((range.upperBound - range.lowerBound) / step).rounded()))
      VStack(spacing: 2) {
        Slider(value: $value, in: range, step: step) { editing in
          if !editing { context.emit("change", value) }
        }
        HStack {
          ForEach(0...ticks, id: \.self) { index in
            Capsule().fill(.secondary).frame(width: 2, height: 8)
            if index < ticks { Spacer() }
          }
        }
        .padding(.horizontal, 12)
      }
    }
  }
}

/// Paged carousel with a page indicator.
///
/// - `items`: pages (each item's `image` is the artwork); `value`: initial page
/// - Commands: `trigger` goes to the next page
/// - Events: `change(Int)`
struct PageIndicatorComponent: NativeComponent {
  static let componentId = "page-indicator"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style
  @State private var page = 0

  var body: some View {
    let pages = config.items(or: (1...5).map { NativeItem(title: "Page \($0)") })
    ZStack {
      ComponentBackground()
      TabView(selection: $page) {
        ForEach(Array(pages.enumerated()), id: \.offset) { index, item in
          NativeArtwork(item.image, index: index)
            .clipShape(RoundedRectangle(cornerRadius: style.radius(30), style: .continuous))
            .overlay(alignment: .bottomLeading) {
              if config.items != nil {
                Text(item.title).font(style.titleFont(.title2)).foregroundStyle(.white).padding(20)
              }
            }
            .padding(style.padding ?? 30)
            .padding(.bottom, 30)
            .tag(index)
        }
      }
      .tabViewStyle(.page(indexDisplayMode: .always))
      .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
    .seed($page, from: config.int(or: 0))
    .onChange(of: page) { _, value in context.emit("change", value) }
    .onNativeCommand { _ in withAnimation { page = (page + 1) % max(pages.count, 1) } }
  }
}

/// Checklist using a circular checkbox `ToggleStyle`.
///
/// - `title` (default "Reminders"); `items` with `selected` as checked state
/// - Events: `change({id, checked})`
struct CheckboxComponent: NativeComponent {
  static let componentId = "checkbox"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @State private var checked: Set<String> = []

  private var items: [NativeItem] {
    config.items(or: [
      NativeItem(title: "Buy milk", isSelected: true), NativeItem(title: "Ship Flutter demo"),
      NativeItem(title: "Try Liquid Glass"), NativeItem(title: "Call mom"),
    ])
  }

  var body: some View {
    ComponentScaffold {
      GlassCard(config.title ?? "Reminders") {
        ForEach(items) { item in
          Toggle(item.title, isOn: Binding(
            get: { checked.contains(item.id) },
            set: { value in
              if value { checked.insert(item.id) } else { checked.remove(item.id) }
              context.emit("change", ["id": item.id, "checked": value])
            }
          ))
          .toggleStyle(CheckboxToggleStyle())
        }
      }
    }
    .seed($checked, from: Set(items.filter(\.isSelected).map(\.id)))
  }
}

/// Circle / checkmark toggle style usable anywhere.
public struct CheckboxToggleStyle: ToggleStyle {
  public init() {}

  public func makeBody(configuration: Configuration) -> some View {
    Button {
      configuration.isOn.toggle()
    } label: {
      HStack(spacing: 12) {
        Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
          .font(.title2)
          .foregroundStyle(configuration.isOn ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
          .contentTransition(.symbolEffect(.replace))
        configuration.label
          .strikethrough(configuration.isOn)
          .foregroundStyle(configuration.isOn ? .secondary : .primary)
        Spacer()
      }
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
  }
}
