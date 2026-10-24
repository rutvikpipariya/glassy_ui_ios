import SwiftUI
import UIKit

// MARK: - NativeValue

/// A type-safe representation of an arbitrary value decoded from the Flutter
/// standard message codec (`bool`, `num`, `String`, `List`, `Map`).
///
/// Used for `NativeConfig.value` and `NativeConfig.extra`, so components can
/// read loosely-typed Dart values without force casting.
public enum NativeValue: Equatable {
  case bool(Bool)
  case number(Double)
  case string(String)
  case list([NativeValue])
  case map([String: NativeValue])

  /// Decodes a raw codec value. Returns `nil` for `null` or unsupported types.
  public init?(_ raw: Any?) {
    switch raw {
    case let number as NSNumber:
      // The codec delivers booleans as NSNumber; distinguish them by CF type.
      if CFGetTypeID(number) == CFBooleanGetTypeID() {
        self = .bool(number.boolValue)
      } else {
        self = .number(number.doubleValue)
      }
    case let string as String:
      self = .string(string)
    case let array as [Any]:
      self = .list(array.compactMap(NativeValue.init))
    case let dictionary as [String: Any]:
      self = .map(dictionary.compactMapValues(NativeValue.init))
    default:
      return nil
    }
  }

  public var bool: Bool? {
    switch self {
    case .bool(let value): value
    case .number(let value): value != 0
    default: nil
    }
  }

  public var double: Double? {
    if case .number(let value) = self { return value }
    return nil
  }

  public var int: Int? { double.map { Int($0) } }

  public var string: String? {
    switch self {
    case .string(let value): value
    case .number(let value): value.formatted()
    case .bool(let value): String(value)
    default: nil
    }
  }

  public var list: [NativeValue]? {
    if case .list(let value) = self { return value }
    return nil
  }

  /// Converts back into a codec-friendly value (for echoing to Dart).
  public var raw: Any {
    switch self {
    case .bool(let value): value
    case .number(let value): value
    case .string(let value): value
    case .list(let value): value.map(\.raw)
    case .map(let value): value.mapValues(\.raw)
    }
  }
}

// MARK: - NativeImageSource

/// An image described from Dart: an SF Symbol, a Flutter asset or raw bytes.
///
/// Dart encodes it as `{"type": "symbol" | "asset" | "bytes", "value": …}`.
public enum NativeImageSource: Equatable {
  /// SF Symbol name, e.g. `"heart.fill"`.
  case system(String)
  /// Absolute file path of a Flutter asset inside the app bundle.
  case file(String)
  /// Encoded image bytes (PNG, JPEG, HEIC…).
  case data(Data)

  private static let cache = NSCache<NSString, UIImage>()

  init?(_ raw: Any?) {
    guard let map = raw as? [String: Any], let type = map["type"] as? String else { return nil }
    switch type {
    case "symbol":
      guard let name = map["value"] as? String else { return nil }
      self = .system(name)
    case "asset":
      guard let key = map["value"] as? String, let path = NativeAssets.path(forAsset: key) else { return nil }
      self = .file(path)
    case "bytes":
      guard let bytes = map["value"] as? FlutterStandardTypedDataProtocol else { return nil }
      self = .data(bytes.payload)
    default:
      return nil
    }
  }

  /// `true` for SF Symbols, which size with the font rather than a frame.
  public var isSymbol: Bool {
    if case .system = self { return true }
    return false
  }

  /// Bitmap for asset and byte sources (cached). `nil` for SF Symbols.
  public var uiImage: UIImage? {
    switch self {
    case .system:
      return nil
    case .file(let path):
      if let cached = Self.cache.object(forKey: path as NSString) { return cached }
      guard let image = UIImage(contentsOfFile: path) else { return nil }
      Self.cache.setObject(image, forKey: path as NSString)
      return image
    case .data(let data):
      return UIImage(data: data)
    }
  }
}

/// Lets the image decoder read `FlutterStandardTypedData` without importing
/// Flutter into every file.
protocol FlutterStandardTypedDataProtocol {
  var payload: Data { get }
}

/// Resolves Flutter asset keys to bundle paths. Configured by the plugin.
enum NativeAssets {
  static var lookupKey: ((String) -> String)?

  static func path(forAsset asset: String) -> String? {
    guard let key = lookupKey?(asset) else { return nil }
    return Bundle.main.path(forResource: key, ofType: nil)
  }
}

// MARK: - NativeItem

/// A generic entry used for tabs, menu actions, segments, toolbar buttons,
/// picker options and list rows. Nested `children` build submenus.
public struct NativeItem: Identifiable, Equatable {
  public enum Role: String {
    case normal
    case destructive
    case cancel

    public var buttonRole: ButtonRole? {
      switch self {
      case .normal: nil
      case .destructive: .destructive
      case .cancel: .cancel
      }
    }
  }

  public var id: String
  public var title: String
  public var subtitle: String?
  public var image: NativeImageSource?
  public var role: Role
  public var badge: String?
  public var isSelected: Bool
  public var isEnabled: Bool
  public var children: [NativeItem]

  public init(
    id: String? = nil,
    title: String,
    subtitle: String? = nil,
    image: NativeImageSource? = nil,
    role: Role = .normal,
    badge: String? = nil,
    isSelected: Bool = false,
    isEnabled: Bool = true,
    children: [NativeItem] = []
  ) {
    self.id = id ?? title
    self.title = title
    self.subtitle = subtitle
    self.image = image
    self.role = role
    self.badge = badge
    self.isSelected = isSelected
    self.isEnabled = isEnabled
    self.children = children
  }

  /// Shorthand for the built-in defaults: `.symbol("Home", "house")`.
  public static func symbol(_ title: String, _ systemName: String? = nil, role: Role = .normal) -> NativeItem {
    NativeItem(title: title, image: systemName.map(NativeImageSource.system), role: role)
  }

  init?(_ raw: Any?) {
    guard let map = raw as? [String: Any], let title = map["title"] as? String else { return nil }
    self.init(
      id: map["id"] as? String,
      title: title,
      subtitle: map["subtitle"] as? String,
      image: NativeImageSource(map["image"]),
      role: (map["role"] as? String).flatMap(Role.init(rawValue:)) ?? .normal,
      badge: map["badge"] as? String,
      isSelected: (map["selected"] as? NSNumber)?.boolValue ?? false,
      isEnabled: (map["enabled"] as? NSNumber)?.boolValue ?? true,
      children: (map["children"] as? [Any])?.compactMap(NativeItem.init) ?? []
    )
  }
}

// MARK: - Color helpers

extension Color {
  /// Creates a color from a Dart `Color.toARGB32()` value.
  init(argb: Int) {
    self.init(
      .sRGB,
      red: Double((argb >> 16) & 0xFF) / 255,
      green: Double((argb >> 8) & 0xFF) / 255,
      blue: Double(argb & 0xFF) / 255,
      opacity: Double((argb >> 24) & 0xFF) / 255
    )
  }

  /// `#RRGGBB` string, convenient for sending colors back to Dart.
  public var hexString: String {
    var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
    UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    return String(format: "#%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255))
  }

  /// ARGB integer understood by Dart's `Color(int)`.
  public var argbValue: Int {
    var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
    UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    func byte(_ value: CGFloat) -> Int { Int((min(max(value, 0), 1) * 255).rounded()) }
    return byte(alpha) << 24 | byte(red) << 16 | byte(green) << 8 | byte(blue)
  }
}

// MARK: - Raw dictionary helpers

extension Dictionary where Key == String, Value == Any {
  func string(_ key: String) -> String? { self[key] as? String }
  func double(_ key: String) -> Double? { (self[key] as? NSNumber)?.doubleValue }
  func cgFloat(_ key: String) -> CGFloat? { double(key).map { CGFloat($0) } }
  func bool(_ key: String) -> Bool? { (self[key] as? NSNumber)?.boolValue }
  func color(_ key: String) -> Color? { (self[key] as? NSNumber).map { Color(argb: $0.intValue) } }
  func colors(_ key: String) -> [Color]? {
    (self[key] as? [Any])?.compactMap { ($0 as? NSNumber).map { Color(argb: $0.intValue) } }
  }
}
