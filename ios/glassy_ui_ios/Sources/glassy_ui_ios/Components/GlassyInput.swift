import SwiftUI

/// Glass text field: single line, secure or multiline.
///
/// - `placeholder`, `value`: initial text
/// - `extra.secure`, `extra.multiline`, `extra.keyboard`: "text" | "email" | "number" | "phone" | "url"
/// - Commands: `clear`, `focus`, `unfocus`
/// - Events: `change(String)`, `submit(String)`
struct GlassyTextField: NativeComponent {
  static let componentId = "glassy-text-field"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style
  @State private var text = ""
  @FocusState private var focused: Bool

  var body: some View {
    field
      .focused($focused)
      .keyboardType(keyboard)
      .textInputAutocapitalization(keyboard == .default ? .sentences : .never)
      .onSubmit { context.emit("submit", text) }
      .foregroundStyle(style.foreground ?? .primary)
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .frame(maxHeight: .infinity, alignment: config.extra("multiline", or: false) ? .top : .center)
      .nativeGlass(RoundedRectangle(cornerRadius: style.cornerRadius ?? 16, style: .continuous))
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .seed($text, from: config.value?.string)
      .onNativeCommand { command in
        switch command.name {
        case "clear":
          text = ""
          context.emit("change", "")
        case "focus": focused = true
        case "unfocus": focused = false
        default: break
        }
      }
  }

  @ViewBuilder
  private var field: some View {
    let binding = context.binding($text)
    let placeholder = config.placeholder ?? ""
    if config.extra("secure", or: false) {
      SecureField(placeholder, text: binding)
    } else if config.extra("multiline", or: false) {
      TextField(placeholder, text: binding, axis: .vertical)
    } else {
      TextField(placeholder, text: binding)
    }
  }

  private var keyboard: UIKeyboardType {
    switch config.extra("keyboard", or: "text") {
    case "email": .emailAddress
    case "number": .decimalPad
    case "phone": .phonePad
    case "url": .URL
    default: .default
    }
  }
}

/// Glass search capsule with a clear button.
///
/// - `placeholder`, `value`: initial text
/// - Commands: `clear`, `focus`, `unfocus`
/// - Events: `change(String)`, `submit(String)`
struct GlassySearchBar: NativeComponent {
  static let componentId = "glassy-search-bar"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style
  @State private var text = ""
  @FocusState private var focused: Bool

  var body: some View {
    HStack(spacing: 8) {
      Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
      TextField(config.placeholder ?? "Search", text: context.binding($text))
        .focused($focused)
        .submitLabel(.search)
        .onSubmit { context.emit("submit", text) }
        .foregroundStyle(style.foreground ?? .primary)
      if !text.isEmpty {
        Button(action: clear) {
          Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Clear")
      }
    }
    .padding(.horizontal, 16)
    .frame(maxHeight: .infinity)
    .nativeGlass(interactive: true)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .seed($text, from: config.value?.string)
    .onNativeCommand { command in
      switch command.name {
      case "clear": clear()
      case "focus": focused = true
      case "unfocus": focused = false
      default: break
      }
    }
  }

  private func clear() {
    text = ""
    context.emit("change", "")
  }
}

/// Native date / time picker.
///
/// - `value`: ISO-8601 date; `title`: label (hidden when absent)
/// - `extra.mode`: "date" | "time" | "dateAndTime"; `extra.style`: "compact" | "wheel" | "graphical"
/// - `extra.minDate` / `extra.maxDate`: ISO-8601 bounds
/// - Events: `change(ISO-8601 String)`
struct GlassyDatePicker: NativeComponent {
  static let componentId = "glassy-date-picker"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @State private var date = Date()

  var body: some View {
    styled
      .labelsHidden(config.title == nil)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .seed($date, from: NativeDate.parse(config.value))
  }

  private var picker: DatePicker<Text> {
    let lower = NativeDate.parse(config.extra["minDate"]) ?? .distantPast
    let upper = NativeDate.parse(config.extra["maxDate"]) ?? .distantFuture
    return DatePicker(
      config.title ?? "",
      selection: context.binding($date) { NativeDate.format($0) },
      in: lower...max(lower, upper),
      displayedComponents: components
    )
  }

  @ViewBuilder
  private var styled: some View {
    switch config.extra("style", or: "compact") {
    case "wheel": picker.datePickerStyle(.wheel)
    case "graphical": picker.datePickerStyle(.graphical)
    default: picker.datePickerStyle(.compact)
    }
  }

  private var components: DatePickerComponents {
    switch config.extra("mode", or: "date") {
    case "time": .hourAndMinute
    case "dateAndTime": [.date, .hourAndMinute]
    default: .date
    }
  }
}

/// Native wheel picker.
///
/// - `items`: options; `value`: selected id
/// - Events: `change(itemId)`
struct GlassyWheelPicker: NativeComponent {
  static let componentId = "glassy-wheel-picker"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @State private var selection = ""

  var body: some View {
    let options = config.items ?? []
    Picker(config.title ?? "", selection: context.binding($selection)) {
      ForEach(options) { Text($0.title).tag($0.id) }
    }
    .pickerStyle(.wheel)
    .labelsHidden()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .seed($selection, from: config.value?.string ?? options.first?.id ?? "")
  }
}

/// Native color well that opens the system color picker.
///
/// - `value`: ARGB color; `title`: label; `extra.supportsOpacity` (default true)
/// - Events: `change(Int ARGB)`
struct GlassyColorPicker: NativeComponent {
  static let componentId = "glassy-color-picker"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style
  @State private var color = Color.blue

  var body: some View {
    ColorPicker(
      config.title ?? "",
      selection: context.binding($color) { $0.argbValue },
      supportsOpacity: config.extra("supportsOpacity", or: true)
    )
    .labelsHidden(config.title == nil)
    .foregroundStyle(style.foreground ?? .primary)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
    .seed($color, from: config.value?.double.map { Color(argb: Int($0)) } ?? .blue)
  }
}
