import SwiftUI

/// Native segmented control.
///
/// - `items`: segments; `value`: selected id
/// - Events: `change(itemId)`
struct GlassySegmentedControl: NativeComponent {
  static let componentId = "glassy-segmented-control"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @State private var selection = ""

  var body: some View {
    let segments = config.items ?? []
    Picker(config.title ?? "", selection: context.binding($selection)) {
      ForEach(segments) { NativeItemLabel($0).tag($0.id) }
    }
    .pickerStyle(.segmented)
    .labelsHidden()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .seed($selection, from: config.value?.string ?? segments.first?.id ?? "")
  }
}

/// Native switch, optionally with a label.
///
/// - `value`: on/off; `title`: label
/// - Events: `change(Bool)`
struct GlassySwitch: NativeComponent {
  static let componentId = "glassy-switch"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style
  @State private var isOn = false

  var body: some View {
    Toggle(config.title ?? "", isOn: context.binding($isOn))
      .labelsHidden(config.title == nil)
      .foregroundStyle(style.foreground ?? .primary)
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
      .seed($isOn, from: config.bool(or: false))
  }
}

/// Glass minus / value / plus stepper.
///
/// - `value`, `min`, `max`, `step` (default 0…100 by 1); `title`: label
/// - Events: `change(Double)`
struct GlassyStepper: NativeComponent {
  static let componentId = "glassy-stepper"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style
  @State private var value = 0.0

  var body: some View {
    let range = config.range(or: 0...100)
    let step = config.step ?? 1
    HStack(spacing: 12) {
      if let title = config.title {
        Text(title).foregroundStyle(style.foreground ?? .primary)
        Spacer()
      }
      GlassIconButton("minus", size: 14) { set(value - step, in: range) }
        .disabled(value <= range.lowerBound)
        .accessibilityLabel("Decrement")
      Text(value.formatted())
        .font(.title3.monospacedDigit().weight(.semibold))
        .foregroundStyle(style.foreground ?? .primary)
        .contentTransition(.numericText(value: value))
        .frame(minWidth: 40)
      GlassIconButton("plus", size: 14) { set(value + step, in: range) }
        .disabled(value >= range.upperBound)
        .accessibilityLabel("Increment")
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .accessibilityElement(children: .contain)
    .accessibilityValue(value.formatted())
    .seed($value, from: config.double(or: range.lowerBound))
  }

  private func set(_ newValue: Double, in range: ClosedRange<Double>) {
    let clamped = min(max(newValue, range.lowerBound), range.upperBound)
    withAnimation(.snappy) { value = clamped }
    context.emit("change", clamped)
  }
}

/// Native slider with optional end icons.
///
/// - `value`, `min`, `max` (default 0…1), `step`: snap interval
/// - `extra.minImage` / `extra.maxImage`: SF Symbols at the ends
/// - Events: `change(Double)` while dragging, `changeEnd(Double)` on release
struct GlassySlider: NativeComponent {
  static let componentId = "glassy-slider"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style
  @State private var value = 0.0

  var body: some View {
    let range = config.range(or: 0...1)
    HStack(spacing: 10) {
      if let symbol = config.extra["minImage"]?.string {
        Image(systemName: symbol).foregroundStyle(.secondary)
      }
      slider(range)
      if let symbol = config.extra["maxImage"]?.string {
        Image(systemName: symbol).foregroundStyle(.secondary)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .seed($value, from: config.double(or: range.lowerBound))
  }

  @ViewBuilder
  private func slider(_ range: ClosedRange<Double>) -> some View {
    let binding = context.binding($value)
    if let step = config.step, step > 0 {
      Slider(value: binding, in: range, step: step) { editing in
        if !editing { context.emit("changeEnd", value) }
      }
    } else {
      Slider(value: binding, in: range) { editing in
        if !editing { context.emit("changeEnd", value) }
      }
    }
  }
}

/// Page dots in a glass capsule; the current page stretches into a pill.
///
/// - `value`: current page; `extra.count`: number of pages
/// - Events: `change(Int)` when a dot is tapped
struct GlassyPageIndicator: NativeComponent {
  static let componentId = "glassy-page-indicator"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @State private var current = 0

  var body: some View {
    let count = max(Int(config.extra("count", or: 3.0)), 1)
    HStack(spacing: 8) {
      ForEach(0..<count, id: \.self) { index in
        Capsule()
          .fill(index == current ? AnyShapeStyle(.tint) : AnyShapeStyle(Color.secondary.opacity(0.4)))
          .frame(width: index == current ? 22 : 8, height: 8)
          .contentShape(Rectangle().inset(by: -6))
          .onTapGesture {
            withAnimation(.snappy) { current = index }
            context.emit("change", index)
          }
      }
    }
    .padding(.horizontal, 14)
    .padding(.vertical, 10)
    .nativeGlass()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("Page \(current + 1) of \(count)")
    .animation(.snappy, value: current)
    .seed($current, from: config.int(or: 0))
  }
}

/// Round checkbox with an animated checkmark.
///
/// - `value`: checked; `title`: label
/// - Events: `change(Bool)`
struct GlassyCheckbox: NativeComponent {
  static let componentId = "glassy-checkbox"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style
  @State private var checked = false

  var body: some View {
    Button {
      checked.toggle()
      context.emit("change", checked)
    } label: {
      HStack(spacing: 10) {
        Image(systemName: checked ? "checkmark.circle.fill" : "circle")
          .font(.title2)
          .foregroundStyle(checked ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
          .contentTransition(.symbolEffect(.replace))
        if let title = config.title {
          Text(title).foregroundStyle(style.foreground ?? .primary)
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .accessibilityAddTraits(checked ? .isSelected : [])
    .seed($checked, from: config.bool(or: false))
  }
}
