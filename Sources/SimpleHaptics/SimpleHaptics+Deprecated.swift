//
//  SimpleHaptics+Deprecated.swift
//  SimpleHaptics
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

// Deprecated API, kept for source compatibility until SimpleHaptics 1.0.0. To remove it, follow
// "Deprecate API" in CONTRIBUTING.md.

extension SimpleHaptics {
  /// Plays a haptic in a new task.
  ///
  /// Use ``play(_:)`` on the main actor instead. Elsewhere, start the task yourself:
  /// `Task { @MainActor in SimpleHaptics.play(.success) }`. Cancelling the returned task doesn't stop the haptic,
  /// so the replacement loses no behavior.
  ///
  /// - Parameter hapticType: The type of haptic to play.
  /// - Returns: The task that plays the haptic.
  @available(
    *,
    deprecated,
    message: """
      Use play(_:) on the main actor, or `Task { @MainActor in SimpleHaptics.play(_:) }` elsewhere. \
      generateTask(_:) will be removed in SimpleHaptics 1.0.0.
      """)
  @discardableResult
  static public func generateTask(_ hapticType: HapticType)
    -> Task<Void, Never>
  {
    Task { @MainActor in
      play(hapticType)
    }
  }

  /// Plays a haptic on the main actor.
  ///
  /// Use ``play(_:)`` instead. It does the same, and needs no `await` on the main actor.
  ///
  /// - Parameter hapticType: The type of haptic to play.
  @available(
    *,
    deprecated,
    renamed: "play(_:)",
    message: """
      Use play(_:) instead, with `await` outside the main actor. \
      generate(_:) will be removed in SimpleHaptics 1.0.0.
      """)
  static public func generate(_ hapticType: HapticType)
    async
  {
    await play(hapticType)
  }
}
