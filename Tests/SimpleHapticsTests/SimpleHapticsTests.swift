//
//  SimpleHapticsTests.swift
//  SimpleHaptics
//
//  Copyright (c) 2026 TIANWEI ZHANG. All rights reserved.
//

import Testing
@testable import SimpleHaptics
#if os(watchOS)
import WatchKit
#endif

// MARK: - RecordingBackend

/// Records the calls that SimpleHaptics makes, instead of playing haptics.
@MainActor
final class RecordingBackend: HapticBackend {
  enum Event: Equatable {
    case play(SimpleHaptics.HapticType, intensity: Double?)
    case prepare(SimpleHaptics.HapticType)
  }

  private(set) var events: [Event] = []

  // MARK: Internal

  func play(_ type: SimpleHaptics.HapticType, intensity: Double?) {
    events.append(.play(type, intensity: intensity))
  }

  func prepare(_ type: SimpleHaptics.HapticType) {
    events.append(.prepare(type))
  }
}

// MARK: - SimpleHapticsTests

@MainActor
@Suite(.serialized)
struct SimpleHapticsTests {
  let recorder = RecordingBackend()

  // MARK: Lifecycle

  init() {
    SimpleHaptics.backend = recorder
    SimpleHaptics.isEnabled = true
  }

  // MARK: Internal

  @Test
  func playSendsTheTypeWithoutIntensity() {
    SimpleHaptics.play(.success)

    #expect(recorder.events == [.play(.success, intensity: nil)])
  }

  @Test(arguments: [(0.4, 0.4), (1.5, 1.0), (-0.2, 0.0), (.nan, 1.0)])
  func playClampsTheIntensity(input: Double, expected: Double) {
    SimpleHaptics.play(.heavy, intensity: input)

    #expect(recorder.events == [.play(.heavy, intensity: expected)])
  }

  @Test
  func prepareSendsTheType() {
    SimpleHaptics.prepare(.rigid)

    #expect(recorder.events == [.prepare(.rigid)])
  }

  @Test
  func disablingMutesEveryCall() {
    SimpleHaptics.isEnabled = false

    SimpleHaptics.play(.error)
    SimpleHaptics.play(.light, intensity: 0.5)
    SimpleHaptics.prepare(.light)

    #expect(recorder.events.isEmpty)
  }

  @Test
  func playWorksFromNonisolatedAsyncCode() async {
    await playOffTheMainActor(.warning)

    #expect(recorder.events == [.play(.warning, intensity: nil)])
  }

  @Test
  @available(*, deprecated)
  func deprecatedGenerateTaskStillPlays() async {
    await SimpleHaptics.generateTask(.selection).value

    #expect(recorder.events == [.play(.selection, intensity: nil)])
  }

  @Test
  @available(*, deprecated)
  func deprecatedGenerateStillPlays() async {
    await SimpleHaptics.generate(.medium)

    #expect(recorder.events == [.play(.medium, intensity: nil)])
  }

  /// Runs the real backend of the current platform. Simulator plays nothing, so this checks only that no
  /// call crashes.
  @Test
  func systemBackendAcceptsEveryType() {
    SimpleHaptics.backend = SystemHapticBackend()

    for type in SimpleHaptics.HapticType.allCases {
      SimpleHaptics.prepare(type)
      SimpleHaptics.play(type)
      SimpleHaptics.play(type, intensity: 0.5)
    }
  }

  #if os(iOS)
  @Test(arguments: [
    (SimpleHaptics.HapticType.selection, UIKitFeedback.selection),
    (.success, .notification(.success)),
    (.warning, .notification(.warning)),
    (.error, .notification(.error)),
    (.light, .impact(.light)),
    (.medium, .impact(.medium)),
    (.heavy, .impact(.heavy)),
    (.soft, .impact(.soft)),
    (.rigid, .impact(.rigid)),
  ])
  func uiKitMapping(type: SimpleHaptics.HapticType, expected: UIKitFeedback) {
    #expect(type.uiKitFeedback == expected)
  }
  #endif

  #if os(watchOS)
  @Test(arguments: [
    (SimpleHaptics.HapticType.selection, WKHapticType.click),
    (.success, .success),
    (.warning, .retry),
    (.error, .failure),
    (.light, .click),
    (.medium, .click),
    (.heavy, .click),
    (.soft, .click),
    (.rigid, .click),
  ])
  func watchMapping(type: SimpleHaptics.HapticType, expected: WKHapticType) {
    #expect(type.watchHaptic == expected)
  }
  #endif
}

/// Calls `play(_:)` from code that isn't isolated to the main actor.
nonisolated func playOffTheMainActor(_ type: SimpleHaptics.HapticType) async {
  await SimpleHaptics.play(type)
}
