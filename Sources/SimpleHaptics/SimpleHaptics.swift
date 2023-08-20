//
//  SimpleHaptics.swift
//  SimpleHaptics
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import UIKit

/// Generates haptic feedback on devices running iOS 13 or later.
///
/// This utility is designed to trigger various types of haptic feedback.
@available(iOS 13.0, macCatalyst 13.1, *)
public enum SimpleHaptics {
  /// Defines the types of haptic feedback that can be generated.
  ///
  /// The cases represent different types of feedback that are used in specific situations:
  ///
  /// Selection Haptic - is used to give user feedback when a selection changes.
  ///
  /// - `selection`: Provides a gentle tap, useful for indicating changes in selection status.
  ///
  /// Notification Haptic - is used to give user feedback when an notification is displayed.
  ///
  /// - `success`: Denotes the successful completion of an action, allowing users to receive positive
  ///              confirmation.
  ///
  /// - `warning`: Signals a warning or impending event, helping to draw the user's attention.
  ///
  /// - `error`: Communicates that an error has occurred, providing an immediate and noticeable alert.
  ///
  /// Impact Haptic is used to give user feedback when an impact between UI elements occurs.
  ///
  /// - `light`: Produces a light impact feedback, slightly stronger than `selection`, useful for enhancing UI
  ///            interactions.
  ///
  /// - `medium`: Generates a medium impact feedback, stronger than `light`.
  ///
  /// - `heavy`: Triggers a heavy impact feedback, stronger than `medium`.
  ///
  /// - `soft`: Initiates a soft impact feedback.
  ///
  /// - `rigid`: Elicits a rigid impact feedback.
  ///
  public enum HapticType {
    case selection

    case success
    case warning
    case error

    case light
    case medium
    case heavy
    case soft
    case rigid
  }

  // MARK: Public

  /// Asynchronously generates haptic feedback using a new Task.
  ///
  /// This function creates a new Task to call the `generate(_:)` function asynchronously. This function is
  /// particularly valuable when you need to trigger haptic feedback within a synchronous
  /// context, as it allows the haptic feedback to be generated without blocking the current execution flow.
  ///
  /// The function returns the created Task, but the result can be safely discarded if not needed.
  ///
  /// - Parameter hapticType: The type of haptics to generate.
  /// - Returns: A Task that, when awaited, will generate the specified haptic feedback. The return value can
  /// be
  /// ignored without a warning due to the `@discardableResult` attribute, but please note that it won't be
  /// possible to cancel the Task without keeping a reference to it, should there be any reason to do so.
  ///
  /// ```swift
  /// let task = Haptics.generateTask(.success)
  /// // The task can be discarded without warning, but it also can be cancelled if necessary
  /// task.cancel()
  /// ```
  ///
  /// - SeeAlso: `generate(_:)`
  @discardableResult
  static public func generateTask(_ hapticType: HapticType)
    -> Task<Void, Never>
  {
    Task {
      await SimpleHaptics.generate(hapticType)
    }
  }

  // swiftlint:disable:next cyclomatic_complexity
  /// Asynchronously generates haptic feedback.
  ///
  /// This function allows you to generate different types of haptic feedback in an asynchronous context,
  /// ensuring the main thread remains responsive.
  ///
  /// - Parameter hapticType: The type of haptics to generate, specified by the `HapticType` enumeration.
  ///
  /// Example of usage:
  /// ```swift
  /// Task {
  ///   await Haptics.generate(.success)
  /// }
  /// ```
  ///
  /// In case of the main task being cancelled while the haptic feedback is being generated, the feedback
  /// generation will be interrupted and no error will be thrown.
  ///
  /// - SeeAlso: `generateTask(_:)` for a cancellable version of this function.
  static public func generate(_ hapticType: HapticType)
    async
  {
    await MainActor.run {
      switch hapticType {
      case .selection:
        UISelectionFeedbackGenerator().selectionChanged()

      case .success:
        UINotificationFeedbackGenerator().notificationOccurred(.success)

      case .warning:
        UINotificationFeedbackGenerator().notificationOccurred(.warning)

      case .error:
        UINotificationFeedbackGenerator().notificationOccurred(.error)

      case .light:
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

      case .medium:
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

      case .heavy:
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()

      case .soft:
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()

      case .rigid:
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
      }
    }
  }
}
