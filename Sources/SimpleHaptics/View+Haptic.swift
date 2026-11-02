//
//  View+Haptic.swift
//  SimpleHaptics
//
//  Copyright (c) 2026 TIANWEI ZHANG. All rights reserved.
//

#if canImport(SwiftUI)
import SwiftUI

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension View {
  /// Plays a haptic when a value changes.
  ///
  /// ```swift
  /// Toggle("Wi-Fi", isOn: $isOn)
  ///   .haptic(.selection, trigger: isOn)
  /// ```
  ///
  /// Unlike SwiftUI's `sensoryFeedback(_:trigger:)`, this modifier works on iOS 14 and later and
  /// respects ``SimpleHaptics/SimpleHaptics/isEnabled``.
  ///
  /// - Parameters:
  ///   - type: The type of haptic to play.
  ///   - trigger: A value to watch. The haptic plays each time the value changes.
  public func haptic(
    _ type: SimpleHaptics.HapticType,
    trigger: some Equatable)
    -> some View
  {
    modifier(HapticModifier(type: type, trigger: trigger, condition: nil))
  }

  /// Plays a haptic when a value changes and a condition is true.
  ///
  /// ```swift
  /// List(items) { item in
  ///   Text(item.name)
  /// }
  /// .haptic(.success, trigger: loadState) { _, newValue in
  ///   newValue == .loaded
  /// }
  /// ```
  ///
  /// - Parameters:
  ///   - type: The type of haptic to play.
  ///   - trigger: A value to watch.
  ///   - condition: A closure that receives the old and the new value of `trigger`. The haptic plays only
  ///     when the closure returns `true`.
  public func haptic<T: Equatable>(
    _ type: SimpleHaptics.HapticType,
    trigger: T,
    condition: @escaping (_ oldValue: T, _ newValue: T) -> Bool)
    -> some View
  {
    modifier(HapticModifier(type: type, trigger: trigger, condition: condition))
  }
}

// MARK: - HapticModifier

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private struct HapticModifier<T: Equatable>: ViewModifier {
  let type: SimpleHaptics.HapticType
  let trigger: T
  let condition: ((T, T) -> Bool)?

  /// Before iOS 17, `onChange` can run the closure from the previous update, which captured the previous
  /// `type` and `condition`. Both closures read them from this shared object instead.
  @State private var latest = LatestHaptic<T>()

  // MARK: Internal

  func body(content: Content) -> some View {
    latest.update(type: type, condition: condition)
    return observeTrigger(of: content)
  }

  // MARK: Private

  @ViewBuilder
  private func observeTrigger(of content: Content) -> some View {
    if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
      content.onChange(of: trigger) { [latest] oldValue, newValue in
        latest.playIfNeeded(oldValue: oldValue, newValue: newValue)
      }
    }
    else {
      #if os(visionOS)
      content
      #else
      // Before iOS 17, the capture list keeps the old value of `trigger`.
      content.onChange(of: trigger) { [latest, trigger] newValue in
        latest.playIfNeeded(oldValue: trigger, newValue: newValue)
      }
      #endif
    }
  }
}

// MARK: - LatestHaptic

/// The haptic type and condition from the latest update of a `HapticModifier`.
@MainActor
final private class LatestHaptic<T> {
  private var type = SimpleHaptics.HapticType.selection
  private var condition: ((T, T) -> Bool)?

  // MARK: Internal

  func update(type: SimpleHaptics.HapticType, condition: ((T, T) -> Bool)?) {
    self.type = type
    self.condition = condition
  }

  func playIfNeeded(oldValue: T, newValue: T) {
    guard condition?(oldValue, newValue) ?? true else { return }
    SimpleHaptics.play(type)
  }
}
#endif
