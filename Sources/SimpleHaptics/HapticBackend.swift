//
//  HapticBackend.swift
//  SimpleHaptics
//
//  Copyright (c) 2026 TIANWEI ZHANG. All rights reserved.
//

#if os(iOS)
import CoreHaptics
import UIKit
#elseif os(watchOS)
import WatchKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - HapticBackend

/// Plays haptics. ``SimpleHaptics`` checks `isEnabled` and clamps the intensity before it calls a backend.
@MainActor
protocol HapticBackend {
  func play(_ type: SimpleHaptics.HapticType, intensity: Double?)
  func prepare(_ type: SimpleHaptics.HapticType)
}

// MARK: - SystemHapticBackend

/// Plays haptics with the system API of the current platform.
///
/// On iPhone and iPad, it keeps one feedback generator per kind, so that ``prepare(_:)`` and
/// ``play(_:intensity:)`` use the same generator.
@MainActor
final class SystemHapticBackend: HapticBackend {
  nonisolated static var isSupported: Bool {
    #if os(iOS)
    CHHapticEngine.capabilitiesForHardware().supportsHaptics
    #elseif os(watchOS) || os(macOS)
    true
    #else
    false
    #endif
  }

  #if os(iOS)
  private typealias ImpactStyle = UIImpactFeedbackGenerator.FeedbackStyle

  lazy private var selectionGenerator = UISelectionFeedbackGenerator()
  lazy private var notificationGenerator = UINotificationFeedbackGenerator()
  private var impactGenerators: [ImpactStyle: UIImpactFeedbackGenerator] = [:]

  private func impactGenerator(_ style: ImpactStyle) -> UIImpactFeedbackGenerator {
    if let generator = impactGenerators[style] {
      return generator
    }
    let generator = UIImpactFeedbackGenerator(style: style)
    impactGenerators[style] = generator
    return generator
  }
  #endif

  // MARK: Internal

  func play(_ type: SimpleHaptics.HapticType, intensity: Double?) {
    #if os(iOS)
    switch type.uiKitFeedback {
    case .selection:
      selectionGenerator.selectionChanged()
    case .notification(let notificationType):
      notificationGenerator.notificationOccurred(notificationType)
    case .impact(let style):
      if let intensity {
        impactGenerator(style).impactOccurred(intensity: CGFloat(intensity))
      }
      else {
        impactGenerator(style).impactOccurred()
      }
    }
    #elseif os(watchOS)
    WKInterfaceDevice.current().play(type.watchHaptic)
    #elseif os(macOS)
    NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .default)
    #endif
  }

  func prepare(_ type: SimpleHaptics.HapticType) {
    #if os(iOS)
    switch type.uiKitFeedback {
    case .selection:
      selectionGenerator.prepare()
    case .notification:
      notificationGenerator.prepare()
    case .impact(let style):
      impactGenerator(style).prepare()
    }
    #endif
  }
}

// MARK: - Platform mapping

#if os(iOS)
/// The UIKit feedback generator and parameter that play a haptic type.
enum UIKitFeedback: Equatable {
  case selection
  case notification(UINotificationFeedbackGenerator.FeedbackType)
  case impact(UIImpactFeedbackGenerator.FeedbackStyle)
}

extension SimpleHaptics.HapticType {
  var uiKitFeedback: UIKitFeedback {
    switch self {
    case .selection: .selection
    case .success: .notification(.success)
    case .warning: .notification(.warning)
    case .error: .notification(.error)
    case .light: .impact(.light)
    case .medium: .impact(.medium)
    case .heavy: .impact(.heavy)
    case .soft: .impact(.soft)
    case .rigid: .impact(.rigid)
    }
  }
}
#endif

#if os(watchOS)
extension SimpleHaptics.HapticType {
  /// The closest watchOS haptic. watchOS has no impact styles, so every impact type plays a click.
  var watchHaptic: WKHapticType {
    switch self {
    case .success: .success
    case .warning: .retry
    case .error: .failure
    case .selection,
         .light,
         .medium,
         .heavy,
         .soft,
         .rigid: .click
    }
  }
}
#endif
