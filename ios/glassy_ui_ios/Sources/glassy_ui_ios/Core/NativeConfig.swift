import SwiftUI

/// Content configuration of a component (`NativeComponentConfig` in Dart).
///
/// The same small vocabulary is used by every component:
/// - `title`, `subtitle`, `message`, `placeholder`: text content
/// - `image`: main icon or artwork
/// - `items`: tabs, menu actions, segments, options…
/// - `value`, `minimum`, `maximum`, `step`: initial value and range of controls
/// - `extra`: component-specific options documented on each component
/// - `style`: visual customization, see `NativeStyle`
///
/// Every property is optional so components always render with defaults.
public struct NativeConfig: Equatable {
  public var title: String?
  public var subtitle: String?
  public var message: String?
  public var placeholder: String?
  public var image: NativeImageSource?
  public var items: [NativeItem]?
  public var value: NativeValue?
  public var minimum: Double?
  public var maximum: Double?
  public var step: Double?
  public var isEnabled = true
  public var extra: [String: NativeValue] = [:]
  public var style = NativeStyle()

  public init() {}

  /// Decodes the map produced by `NativeComponentConfig.toMap()` in Dart.
  public init(_ map: [String: Any]) {
    title = map.string("title")
    subtitle = map.string("subtitle")
    message = map.string("message")
    placeholder = map.string("placeholder")
    image = NativeImageSource(map["image"])
    items = (map["items"] as? [Any])?.compactMap(NativeItem.init)
    value = NativeValue(map["value"])
    minimum = map.double("min")
    maximum = map.double("max")
    step = map.double("step")
    isEnabled = map.bool("enabled") ?? true
    extra = (map["extra"] as? [String: Any])?.compactMapValues(NativeValue.init) ?? [:]
    style = NativeStyle(map["style"] as? [String: Any] ?? [:])
  }

  // MARK: Typed accessors with defaults

  public func items(or fallback: [NativeItem]) -> [NativeItem] {
    guard let items, !items.isEmpty else { return fallback }
    return items
  }

  public func double(or fallback: Double) -> Double { value?.double ?? fallback }
  public func int(or fallback: Int) -> Int { value?.int ?? fallback }
  public func bool(or fallback: Bool) -> Bool { value?.bool ?? fallback }
  public func string(or fallback: String) -> String { value?.string ?? fallback }

  /// `minimum...maximum` with a fallback range.
  public func range(or fallback: ClosedRange<Double>) -> ClosedRange<Double> {
    let lower = minimum ?? fallback.lowerBound
    let upper = maximum ?? fallback.upperBound
    return lower < upper ? lower...upper : fallback
  }

  public func extra(_ key: String, or fallback: Bool) -> Bool { extra[key]?.bool ?? fallback }
  public func extra(_ key: String, or fallback: Double) -> Double { extra[key]?.double ?? fallback }
  public func extra(_ key: String, or fallback: String) -> String { extra[key]?.string ?? fallback }

  public func extra(_ key: String, or fallback: [String]) -> [String] {
    extra[key]?.list?.compactMap(\.string) ?? fallback
  }
}
