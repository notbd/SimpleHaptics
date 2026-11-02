//
//  HapticModifierTests.swift
//  SimpleHaptics
//
//  Copyright (c) 2026 TIANWEI ZHANG. All rights reserved.
//

// UIWindow needs a running UIApplication, which Mac Catalyst test bundles don't have.
#if os(iOS) && !targetEnvironment(macCatalyst)
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

@available(iOS 14.0, *)
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

// MARK: - ParityView

/// Picks the haptic type from the current value, so a stale type would show up as the wrong event.
@available(iOS 14.0, *)
private struct ParityView: View {
  @ObservedObject var counter: Counter

  var body: some View {
    Text("\(counter.value)")
      .haptic(counter.value.isMultiple(of: 2) ? .success : .error, trigger: counter.value)
  }
}

// MARK: - SwiftUI modifier

/// These tests host a SwiftUI view in a window and change its trigger value. They live in
/// ``SimpleHapticsTests`` because every test there replaces the shared backend, and the suite runs its
/// tests one at a time.
extension SimpleHapticsTests {

  // MARK: Internal

  @Test
  @available(iOS 14.0, *)
  func modifierPlaysOnlyWhenTheTriggerChanges() async throws {
    let counter = Counter()
    let window = try await show(CounterView(counter: counter, condition: nil))
    try await Task.sleep(nanoseconds: 200_000_000)
    #expect(recorder.events.isEmpty)

    counter.value = 1
    try await waitForEvents(1)
    #expect(recorder.events == [.play(.light, intensity: nil)])
    window.isHidden = true
  }

  @Test
  @available(iOS 14.0, *)
  func modifierPassesOldAndNewValuesToTheCondition() async throws {
    let counter = Counter()
    var calls: [[Int]] = []
    let window = try await show(CounterView(counter: counter) { oldValue, newValue in
      calls.append([oldValue, newValue])
      return newValue.isMultiple(of: 2)
    })

    counter.value = 1
    counter.value = 1 // Setting the same value must not call the condition.
    try await waitUntil { calls.count == 1 }
    #expect(recorder.events.isEmpty)

    counter.value = 2
    try await waitForEvents(1)
    #expect(calls == [[0, 1], [1, 2]])
    #expect(recorder.events == [.play(.light, intensity: nil)])
    window.isHidden = true
  }

  @Test
  @available(iOS 14.0, *)
  func modifierUsesTheTypeFromTheLatestUpdate() async throws {
    let counter = Counter()
    let window = try await show(ParityView(counter: counter))

    counter.value = 1
    try await waitForEvents(1)
    counter.value = 2
    try await waitForEvents(2)
    #expect(recorder.events == [.play(.error, intensity: nil), .play(.success, intensity: nil)])
    window.isHidden = true
  }

  @Test
  @available(iOS 14.0, *)
  func modifierRespectsIsEnabled() async throws {
    let counter = Counter()
    let window = try await show(CounterView(counter: counter, condition: nil))

    SimpleHaptics.isEnabled = false
    counter.value = 1
    try await Task.sleep(nanoseconds: 200_000_000)
    #expect(recorder.events.isEmpty)

    // The same view plays again once haptics are back on, so the check above isn't a false pass.
    SimpleHaptics.isEnabled = true
    counter.value = 2
    try await waitForEvents(1)
    #expect(recorder.events == [.play(.light, intensity: nil)])
    window.isHidden = true
  }

  // MARK: Private

  private func show(_ view: some View) async throws -> UIWindow {
    let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
    window.rootViewController = UIHostingController(rootView: view)
    window.makeKeyAndVisible()
    try await Task.sleep(nanoseconds: 100_000_000)
    return window
  }

  private func waitForEvents(_ count: Int) async throws {
    try await waitUntil { recorder.events.count >= count }
  }

  /// Polls until `condition` is true, so the test doesn't depend on how fast SwiftUI updates.
  private func waitUntil(timeout: Double = 3, _ condition: () -> Bool) async throws {
    let deadline = Date().addingTimeInterval(timeout)
    while !condition() {
      try #require(Date() < deadline, "Timed out waiting for SwiftUI to update")
      try await Task.sleep(nanoseconds: 20_000_000)
    }
  }
}
#endif
