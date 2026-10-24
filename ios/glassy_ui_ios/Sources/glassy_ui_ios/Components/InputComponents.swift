import SwiftUI

// Text input and pickers. Text fields seed from `value` and use
// `placeholder`; pickers emit `change` with the new value.

/// Rounded, glass and chat-style text fields.
///
/// - `placeholder`, `value`: initial text; `extra.keyboard`: "email" | "number" | "url" | "default"
/// - Events: `submit(String)`, `send(String)`
struct TextFieldComponent: NativeComponent {
  static let componentId = "text-field"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style
  @State private var text = ""
  @State private var message = ""

  var body: some View {
    ComponentScaffold {
      GlassCard(config.title ?? "TextField") {
        TextField(config.placeholder ?? "Full name", text: $text)
          .textFieldStyle(.roundedBorder)
          .keyboardType(keyboard)
          .onSubmit { context.emit("submit", text) }
        TextField(config.subtitle ?? "Glass field", text: $text)
          .keyboardType(keyboard)
          .textInputAutocapitalization(.never)
          .padding(.horizontal, 16)
          .padding(.vertical, 12)
          .nativeGlass(RoundedRectangle(cornerRadius: style.radius(24), style: .continuous))
          .onSubmit { context.emit("submit", text) }
        HStack {
          TextField(config.message ?? "Message", text: $message).onSubmit(send)
          GlassIconButton(image: config.image ?? .system("arrow.up"), prominent: true, size: 14, action: send)
            .disabled(message.isEmpty)
        }
        .padding(.leading, 16)
        .padding(4)
        .nativeGlass()
      }
    }
    .seed($text, from: config.string(or: ""))
  }

  private var keyboard: UIKeyboardType {
    switch config.extra("keyboard", or: "default") {
    case "email": .emailAddress
    case "number": .decimalPad
    case "url": .URL
    case "phone": .phonePad
    default: .default
    }
  }

  private func send() {
    context.emit("send", message)
    message = ""
  }
}

/// Password field with reveal toggle and strength meter. Only the length and
/// strength are sent to Dart, never the password itself, unless `extra.emitText`.
///
/// - `placeholder`; `extra.emitText`: include the text in `submit`
/// - Events: `submit({length, strength, text?})`, `strength(String)`
struct SecureFieldComponent: NativeComponent {
  static let componentId = "secure-field"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style
  @State private var password = ""
  @State private var reveal = false

  var body: some View {
    ComponentScaffold {
      GlassCard(config.title ?? "SecureField") {
        HStack {
          Group {
            if reveal {
              TextField(config.placeholder ?? "Password", text: $password)
            } else {
              SecureField(config.placeholder ?? "Password", text: $password)
            }
          }
          .textContentType(.newPassword)
          .textInputAutocapitalization(.never)
          .onSubmit(submit)
          Button { reveal.toggle() } label: {
            Image(systemName: reveal ? "eye.slash" : "eye").contentTransition(.symbolEffect(.replace))
          }
          .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .nativeGlass(RoundedRectangle(cornerRadius: style.radius(24), style: .continuous))
        ProgressView(value: Double(strengthLevel), total: 3)
          .tint([Color.red, .orange, .yellow, .green][strengthLevel])
        Text("Strength: \(strength)").font(.caption).foregroundStyle(.secondary)
      }
    }
    .onChange(of: strengthLevel) { _, _ in context.emit("strength", strength) }
  }

  private var strengthLevel: Int {
    var score = 0
    if password.count >= Int(config.extra("minLength", or: 8.0)) { score += 1 }
    if password.rangeOfCharacter(from: .decimalDigits) != nil { score += 1 }
    if password.rangeOfCharacter(from: .punctuationCharacters.union(.symbols)) != nil { score += 1 }
    return score
  }

  private var strength: String { ["Weak", "Fair", "Good", "Strong"][strengthLevel] }

  private func submit() {
    var payload: [String: Any] = ["length": password.count, "strength": strength]
    if config.extra("emitText", or: false) { payload["text"] = password }
    context.emit("submit", payload)
  }
}

/// Navigation-bar search field with suggestions and filtering.
///
/// - `title`, `placeholder`, `items`: searchable rows, `extra.suggestions`
/// - Events: `search(String)`, `select(itemId)`
struct SearchFieldComponent: NativeComponent {
  static let componentId = "search-field"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @State private var query = ""

  var body: some View {
    let all = config.items(or: ["Ahmedabad", "Bengaluru", "Cupertino", "Delhi", "London", "Mumbai", "New York", "Paris", "San Francisco", "Tokyo"].map { NativeItem(title: $0) })
    let results = query.isEmpty ? all : all.filter { $0.title.localizedCaseInsensitiveContains(query) }
    NavigationStack {
      List(results) { item in
        Button { context.emit("select", item.id) } label: { NativeItemLabel(item) }.tint(.primary)
      }
      .navigationTitle(config.title ?? "Cities")
      .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: config.placeholder ?? "Search")
      .searchSuggestions {
        if query.isEmpty {
          ForEach(config.extra("suggestions", or: ["Tokyo", "Paris"]), id: \.self) { Text($0).searchCompletion($0) }
        }
      }
      .onSubmit(of: .search) { context.emit("search", query) }
    }
  }
}

/// Multiline `TextEditor` in a glass card with a character counter.
///
/// - `title`, `value`: initial text; `max`: character limit
/// - Events: `done({characters, text})`
struct TextEditorComponent: NativeComponent {
  static let componentId = "text-editor"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style
  @State private var text = ""
  @FocusState private var focused: Bool

  var body: some View {
    ComponentScaffold {
      GlassCard(config.title ?? "TextEditor") {
        TextEditor(text: $text)
          .focused($focused)
          .font(style.fontSize.map { .system(size: $0) } ?? .body)
          .scrollContentBackground(.hidden)
          .frame(height: 220)
          .padding(8)
          .background(.background.opacity(0.5), in: RoundedRectangle(cornerRadius: style.radius(14)))
        HStack {
          Text(config.maximum.map { "\(text.count) / \(Int($0))" } ?? "\(text.count) characters")
            .font(.caption).foregroundStyle(.secondary)
          Spacer()
          Button(config.extra("doneTitle", or: "Done")) {
            focused = false
            context.emit("done", ["characters": text.count, "text": text])
          }
          .nativeButtonStyle(prominent: true)
        }
      }
    }
    .seed($text, from: config.string(or: "Write something long here…\n\nTextEditor grows and scrolls natively."))
    .onChange(of: text) { _, value in
      if let limit = config.maximum, value.count > Int(limit) { text = String(value.prefix(Int(limit))) }
    }
  }
}

/// ISO-8601 helpers for exchanging dates with Dart.
enum NativeDate {
  static func parse(_ value: NativeValue?) -> Date? {
    guard let string = value?.string else { return nil }
    return ISO8601DateFormatter().date(from: string)
  }

  static func format(_ date: Date) -> String { ISO8601DateFormatter().string(from: date) }
}

/// Graphical and compact date pickers.
///
/// - `title`, `value`: ISO-8601 date; `extra.style`: "graphical" | "compact" | "wheel"
/// - Events: `change(ISO-8601 String)`
struct DatePickerComponent: NativeComponent {
  static let componentId = "date-picker"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @State private var date = Date()

  var body: some View {
    ComponentScaffold {
      GlassCard(config.subtitle ?? "DatePicker") {
        picker
        DatePicker(config.title ?? "Date", selection: $date, displayedComponents: .date)
      }
    }
    .seed($date, from: NativeDate.parse(config.value))
    .onChange(of: date) { _, value in context.emit("change", NativeDate.format(value)) }
  }

  @ViewBuilder
  private var picker: some View {
    switch config.extra("style", or: "graphical") {
    case "wheel":
      DatePicker(config.title ?? "Date", selection: $date, displayedComponents: .date).datePickerStyle(.wheel).labelsHidden()
    case "compact":
      EmptyView()
    default:
      DatePicker(config.title ?? "Date", selection: $date, displayedComponents: .date).datePickerStyle(.graphical)
    }
  }
}

/// Wheel and compact time pickers.
///
/// - `title`, `value`: ISO-8601 date-time
/// - Events: `change({hour, minute, iso})`
struct TimePickerComponent: NativeComponent {
  static let componentId = "time-picker"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @State private var time = Date()

  var body: some View {
    ComponentScaffold {
      GlassCard(config.subtitle ?? "DatePicker(.hourAndMinute)") {
        DatePicker(config.title ?? "Time", selection: $time, displayedComponents: .hourAndMinute)
          .datePickerStyle(.wheel)
          .labelsHidden()
          .frame(maxWidth: .infinity)
        DatePicker(config.title ?? "Time", selection: $time, displayedComponents: .hourAndMinute)
      }
    }
    .seed($time, from: NativeDate.parse(config.value))
    .onChange(of: time) { _, value in
      let parts = Calendar.current.dateComponents([.hour, .minute], from: value)
      context.emit("change", ["hour": parts.hour ?? 0, "minute": parts.minute ?? 0, "iso": NativeDate.format(value)])
    }
  }
}

/// Multi-column wheel picker. Columns are `items`, each with `children` as rows.
///
/// - `items`: columns (default hours/minutes); `value`: list of selected row ids
/// - Events: `change([String])`
struct WheelPickerComponent: NativeComponent {
  static let componentId = "wheel-picker"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @State private var selections: [String] = []

  private var columns: [NativeItem] {
    config.items(or: [
      NativeItem(title: "Hours", children: (0..<24).map { NativeItem(id: "\($0)", title: "\($0) h") }),
      NativeItem(title: "Minutes", children: (0..<60).map { NativeItem(id: "\($0)", title: "\($0) min") }),
    ])
  }

  var body: some View {
    ComponentScaffold {
      GlassCard(config.title ?? "Picker(.wheel)") {
        HStack(spacing: 0) {
          ForEach(Array(columns.enumerated()), id: \.element.id) { index, column in
            Picker(column.title, selection: binding(index)) {
              ForEach(column.children) { Text($0.title).tag($0.id) }
            }
          }
        }
        .pickerStyle(.wheel)
        .frame(height: 200)
      }
    }
    .seed($selections, from: initialSelections)
  }

  private var initialSelections: [String] {
    let configured = config.value?.list?.compactMap(\.string) ?? []
    return columns.enumerated().map { index, column in
      index < configured.count ? configured[index] : (column.children.first { $0.isSelected } ?? column.children.first)?.id ?? ""
    }
  }

  private func binding(_ index: Int) -> Binding<String> {
    Binding(
      get: { index < selections.count ? selections[index] : "" },
      set: { value in
        guard index < selections.count else { return }
        selections[index] = value
        context.emit("change", selections)
      }
    )
  }
}

/// Menu-style picker, standalone and inside a Form.
///
/// - `title`, `items`: options, `value`: selected id; Events: `change(itemId)`
struct MenuPickerComponent: NativeComponent {
  static let componentId = "menu-picker"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @State private var selection = ""

  var body: some View {
    let options = config.items(or: ["Swift", "Dart", "Kotlin", "Rust"].map { NativeItem(title: $0) })
    ComponentScaffold {
      GlassCard(config.subtitle ?? "Picker(.menu)") {
        Picker(config.title ?? "Language", selection: $selection) {
          ForEach(options) { NativeItemLabel($0).tag($0.id) }
        }
        .pickerStyle(.menu)
        Form {
          Picker(config.title ?? "Language", selection: $selection) {
            ForEach(options) { NativeItemLabel($0).tag($0.id) }
          }
        }
        .scrollContentBackground(.hidden)
        .frame(height: 110)
      }
    }
    .seed($selection, from: config.value?.string ?? options[0].id)
    .onChange(of: selection) { _, value in context.emit("change", value) }
  }
}

/// System color picker with a live swatch.
///
/// - `title`, `value`: initial ARGB int; `extra.supportsOpacity` (default true)
/// - Events: `change({hex, argb})`
struct ColorPickerComponent: NativeComponent {
  static let componentId = "color-picker"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style
  @State private var color = Color.blue

  var body: some View {
    ComponentScaffold {
      GlassCard(config.subtitle ?? "ColorPicker") {
        ColorPicker(config.title ?? "Accent colour", selection: $color, supportsOpacity: config.extra("supportsOpacity", or: true))
        RoundedRectangle(cornerRadius: style.radius(22), style: .continuous)
          .fill(color.gradient)
          .frame(height: 140)
          .overlay { Text(color.hexString).font(.title2.monospaced().bold()).foregroundStyle(.white) }
      }
    }
    .seed($color, from: config.value?.double.map { Color(argb: Int($0)) } ?? style.tint ?? .blue)
    .onChange(of: color) { _, value in context.emit("change", ["hex": value.hexString, "argb": value.argbValue]) }
  }
}

/// Floating glass search capsule with a trailing button that hides while typing.
///
/// - `title`: page title; `placeholder`; `image`: trailing button icon (default mic.fill)
/// - Commands: `trigger` focuses the field
/// - Events: `search(String)`, `tap("accessory")`
struct FloatingSearchBarComponent: NativeComponent {
  static let componentId = "floating-search-bar"
  @EnvironmentObject private var context: ComponentContext
  @Environment(\.nativeConfig) private var config
  @Environment(\.nativeStyle) private var style
  @State private var query = ""
  @FocusState private var focused: Bool

  var body: some View {
    ZStack(alignment: .bottom) {
      NavigationStack {
        ItemList(count: 40).navigationTitle(config.title ?? "Explore")
      }
      AdaptiveGlassContainer(spacing: 10) {
        HStack(spacing: 10) {
          HStack {
            Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
            TextField(config.placeholder ?? "Search", text: $query)
              .focused($focused)
              .submitLabel(.search)
              .onSubmit { context.emit("search", query) }
            if !query.isEmpty {
              Button { query = "" } label: { Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary) }
                .buttonStyle(.plain)
            }
          }
          .padding(.horizontal, 16)
          .frame(height: 50)
          .nativeGlass()

          if !focused {
            Button { context.emit("tap", "accessory") } label: {
              NativeIcon(config.image, fallback: "mic.fill").frame(width: 50, height: 50)
            }
            .buttonStyle(.plain)
            .nativeGlass(Circle())
            .transition(.scale.combined(with: .opacity))
          }
        }
      }
      .padding(.horizontal, style.padding ?? 16)
      .padding(.bottom, 12)
      .animation(.bouncy, value: focused)
    }
    .onNativeCommand { _ in focused = true }
  }
}
