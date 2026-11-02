//
//  HapticModifierTests.swift
//  SimpleHaptics
//
//  Copyright (c) 2026 TIANWEI ZHANG. All rights reserved.
//

#if os(iOS)
import SwiftUI
import Testing
import UIKit
@testable import SimpleHaptics

// MARK: - Counter

@MainActor
final class Counter: ObservableObject {
  @Published var value = 0
}

// MARK: - CounterView

private struct CounterView: View {
  @ObservedObject var counter: Counter
  let condition: ((Int, Int) -> Bool)?

  var body: some View {
    if let condition {
      Text("\(counter.value)")
        .haptic(.light, trigger: counter.value, condition: condition)
    }
    else {
      Text("\(counter.value)")
        .haptic(.light, trigger: counter.value)
    }
  }
}

// MARK: - SwiftUI modifier

/// These tests host a SwiftUI view in a window and change its trigger value. They live in
/// ``SimpleHapticsTests`` because every test there replaces the shared backend, and the suite runs its
/// tests one at a time.
extension SimpleHapticsTests {

  // MARK: Internal

  @Test
  func modifierPlaysOnlyWhenTheTriggerChanges() async throws {
    let counter = Counter()
    let window = try await show(CounterView(counter: counter, condition: nil))
    #expect(recorder.events.isEmpty)

    counter.value = 1
    try await settle()
    #expect(recorder.events == [.play(.light, intensity: nil)])
    window.isHidden = true
  }

  @Test
  func modifierPlaysOnlyWhenTheConditionIsTrue() async throws {
    let counter = Counter()
    let window = try await show(CounterView(counter: counter) { _, newValue in newValue.isMultiple(of: 2) })

    counter.value = 1
    try await settle()
    #expect(recorder.events.isEmpty)

    counter.value = 2
    try await settle()
    #expect(recorder.events == [.play(.light, intensity: nil)])
    window.isHidden = true
  }

  @Test
  func modifierRespectsIsEnabled() async throws {
    let counter = Counter()
    let window = try await show(CounterView(counter: counter, condition: nil))
    SimpleHaptics.isEnabled = false

    counter.value = 1
    try await settle()
    #expect(recorder.events.isEmpty)
    window.isHidden = true
  }

  // MARK: Private

  private func show(_ view: some View) async throws -> UIWindow {
    let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
    window.rootViewController = UIHostingController(rootView: view)
    window.makeKeyAndVisible()
    try await settle()
    return window
  }

  /// Gives SwiftUI time to render and to run `onChange`.
  private func settle() async throws {
    try await Task.sleep(nanoseconds: 100_000_000)
  }
}
#endif
