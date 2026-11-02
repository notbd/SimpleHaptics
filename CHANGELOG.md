# Changelog

All notable changes to SimpleHaptics are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- The example app no longer sets a development team. Select your own team before you run it on a device.

### Fixed

- The README says that its settings example uses the `onChange` from iOS 17, and lists Mac Catalyst 14 and
  visionOS 1 for the SwiftUI modifier.
- The documentation of `play(_:intensity:)` and `prepare(_:)` says that they have an effect on iPhone only,
  not on iPad.

## [0.3.0] - 2026-11-02

### Added

- `play(_:)`, a synchronous main-actor call that plays a haptic right away.
- `play(_:intensity:)` to set the strength of impact haptics.
- `prepare(_:)` to reduce latency before an expected haptic.
- `isEnabled` to mute every haptic, for example from a setting in your app.
- `isSupported` to check whether the device can play haptics.
- The SwiftUI modifiers `haptic(_:trigger:)` and `haptic(_:trigger:condition:)`, available on iOS 14 and later.
- Support for macOS 10.15, tvOS 13, watchOS 6, and visionOS 1. Apple Watch and Mac play the closest system
  haptic. Apple TV and Apple Vision Pro do nothing.
- DocC documentation, tests, continuous integration, and an example app.

### Changed

- The package compiles in the Swift 6 language mode and requires Xcode 16 or later.
- `HapticType` conforms to `Sendable`, `Hashable`, and `CaseIterable`.
- Feedback generators are reused instead of being created for every haptic.

### Deprecated

- `generate(_:)` and `generateTask(_:)`. Use `play(_:)` instead. Both will be removed in 1.0.0.

### Fixed

- The privacy manifest is now bundled with the library. Version 0.2.0 didn't copy it.
- The repository no longer ships an Xcode scheme that changes global Xcode preferences when it builds.
- The documentation no longer says that cancelling the task from `generateTask(_:)` stops the haptic. It never
  did.

## [0.2.0] - 2023-09-28

### Added

- A privacy manifest. It wasn't bundled until 0.3.0.

## [0.1.0] - 2023-09-11

### Added

- The MIT license.

## [0.1.0-alpha] - 2023-08-20

### Added

- `generate(_:)` and `generateTask(_:)` with nine haptic types.

[Unreleased]: https://github.com/notbd/SimpleHaptics/compare/v0.3.0...HEAD
[0.3.0]: https://github.com/notbd/SimpleHaptics/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/notbd/SimpleHaptics/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/notbd/SimpleHaptics/compare/v0.1.0-alpha...v0.1.0
[0.1.0-alpha]: https://github.com/notbd/SimpleHaptics/releases/tag/v0.1.0-alpha
