//
//  DeprecatedTests.swift
//  SimpleHaptics
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Testing
@testable import SimpleHaptics

/// Checks that the deprecated API still plays until SimpleHaptics 1.0.0 removes it.
extension SimpleHapticsTests {
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
}
