//
//  SimpleHaptics.swift
//  SimpleHaptics
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

/// Plays haptic feedback with one line of code.
///
/// Call ``play(_:)`` on the main actor to play a haptic right away:
///
/// ```swift
/// SimpleHaptics.play(.success)
/// ```
///
/// From an asynchronous context, `await` the same call. Swift switches to the main actor for you:
///
/// ```swift
/// await SimpleHaptics.play(.success)
/// ```
///
/// Haptics play on iPhone, Apple Watch, and Macs with a Force Touch trackpad. On other devices and
/// platforms, every call is safe and does nothing.
@available(iOS 13.0, macCatalyst 13.1, *)
public enum SimpleHaptics {
  /// Defines the types of haptic feedback that can be generated.
  ///
  /// The cases represent different types of feedback that are used in specific situations:
  ///
  /// - Selection haptic: gives feedback when a selection changes.
  /// - Notification haptics: give feedback when a task or action succeeds, produces a warning, or fails.
  /// - Impact haptics: give feedback when an impact between UI elements occurs.
  ///
  /// On Apple Watch and Mac, each case maps to the closest system haptic. See the README for the mapping.
  public enum HapticType: Sendable, Hashable, CaseIterable {
    /// A gentle tap that indicates a change in selection, such as a picker value or a segmented control.
    case selection

    /// Indicates that a task or action succeeded.
    case success
    /// Indicates that a task or action produced a warning and draws the user's attention.
    case warning
    /// Indicates that a task or action failed.
    case error

    /// A light impact, slightly stronger than ``selection``.
    case light
    /// A medium impact, stronger than ``light``.
    case medium
    /// A heavy impact, stronger than ``medium``.
    case heavy
    /// A soft impact that feels flexible, like a collision with a soft object.
    case soft
    /// A rigid impact that feels firm, like a collision with a hard object.
    case rigid
  }

  /// A Boolean value that determines whether SimpleHaptics plays haptics.
  ///
  /// The default is `true`. Set it to `false` to mute every haptic that SimpleHaptics plays, for example
  /// when the user turns off haptics in your app's settings:
  ///
  /// ```swift
  /// SimpleHaptics.isEnabled = UserDefaults.standard.bool(forKey: "hapticsEnabled")
  /// ```
  ///
  /// When this value is `false`, ``play(_:)``, ``play(_:intensity:)``, ``prepare(_:)``, and the
  /// `haptic(_:trigger:)` view modifier do nothing.
  @MainActor
  static public var isEnabled = true

  /// A Boolean value that indicates whether the current device can play haptics.
  ///
  /// - On iPhone and iPad, this value comes from Core Haptics. It is `false` on devices without a
  ///   Taptic Engine and in Simulator.
  /// - On Apple Watch, this value is always `true`.
  /// - On Mac, this value is always `true`, but haptics play only on a Force Touch trackpad.
  ///   macOS has no public API to check for one.
  /// - On Apple TV and Apple Vision Pro, this value is always `false`.
  ///
  /// You don't need to check this value before you call ``play(_:)``. Use it to hide haptic settings
  /// on devices that can't play haptics.
  static public var isSupported: Bool {
    SystemHapticBackend.isSupported
  }

  /// The object that plays haptics on the current platform. Tests replace it with a recorder.
  @MainActor
  static var backend: any HapticBackend = SystemHapticBackend()

  // MARK: Public

  /// Plays a haptic right away.
  ///
  /// Call this method from the main actor, such as a button action or a gesture handler:
  ///
  /// ```swift
  /// Button("Save") {
  ///   save()
  ///   SimpleHaptics.play(.success)
  /// }
  /// ```
  ///
  /// From an asynchronous context, `await` the call. From a synchronous context that isn't on the main
  /// actor, start a task: `Task { @MainActor in SimpleHaptics.play(.success) }`.
  ///
  /// - Parameter type: The type of haptic to play.
  @MainActor
  static public func play(_ type: HapticType) {
    guard isEnabled else { return }
    backend.play(type, intensity: nil)
  }

  /// Plays a haptic right away with the intensity that you specify.
  ///
  /// The intensity applies to the impact types: ``HapticType/light``, ``HapticType/medium``,
  /// ``HapticType/heavy``, ``HapticType/soft``, and ``HapticType/rigid``, on iPhone and iPad.
  /// Other types and other platforms ignore it.
  ///
  /// ```swift
  /// SimpleHaptics.play(.heavy, intensity: 0.5)
  /// ```
  ///
  /// - Parameters:
  ///   - type: The type of haptic to play.
  ///   - intensity: A value from `0.0` (weakest) to `1.0` (strongest). Values outside this range are
  ///     clamped to it.
  @MainActor
  static public func play(_ type: HapticType, intensity: Double) {
    guard isEnabled else { return }
    backend.play(type, intensity: min(max(intensity, 0), 1))
  }

  /// Prepares the haptic hardware to play a haptic with minimal latency.
  ///
  /// Call this method shortly before you expect to play a haptic, such as when a drag gesture begins.
  /// The hardware stays prepared for a few seconds. Calling ``play(_:)`` works without this call; it can
  /// only start a little later.
  ///
  /// ```swift
  /// .onChanged { _ in SimpleHaptics.prepare(.rigid) }
  /// .onEnded { _ in SimpleHaptics.play(.rigid) }
  /// ```
  ///
  /// This method has an effect on iPhone and iPad only.
  ///
  /// - Parameter type: The type of haptic that you expect to play.
  @MainActor
  static public func prepare(_ type: HapticType) {
    guard isEnabled else { return }
    backend.prepare(type)
  }

  // MARK: Deprecated

  /// Plays a haptic in a new task.
  ///
  /// Cancelling the returned task doesn't stop the haptic.
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
