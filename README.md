# SimpleHaptics

[![CI](https://github.com/notbd/SimpleHaptics/actions/workflows/ci.yml/badge.svg)](https://github.com/notbd/SimpleHaptics/actions/workflows/ci.yml)
![Swift 6](https://img.shields.io/badge/Swift-6-orange)
![Platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS%20%7C%20visionOS-blue)
[![License: MIT](https://img.shields.io/badge/license-MIT-lightgrey)](./LICENSE)

Play haptic feedback with one line of code, on every Apple platform.

```swift
SimpleHaptics.play(.success)
```

## Features

- One call for the nine standard haptics: selection, success, warning, error, and five impact styles.
- Plays right away on the main actor. From other code, `await` the same call.
- `isEnabled` mutes every haptic, so you can respect a haptics setting in your app.
- `prepare(_:)` reduces latency, and `play(_:intensity:)` sets the strength of impact haptics.
- The SwiftUI modifier `.haptic(_:trigger:)` plays a haptic when a value changes, on iOS 14 and later.
- Builds on iOS, Mac Catalyst, macOS, tvOS, watchOS, and visionOS, with no dependencies.

## Requirements

| Platform     | Minimum | What plays                                        |
| ------------ | ------- | ------------------------------------------------- |
| iOS, iPadOS  | 13.0    | UIKit feedback generators                         |
| Mac Catalyst | 13.1    | UIKit feedback generators                         |
| macOS        | 10.15   | A generic haptic on a Force Touch trackpad        |
| watchOS      | 6.0     | The closest `WKHapticType`                        |
| tvOS         | 13.0    | Nothing. Calls are safe and do nothing.           |
| visionOS     | 1.0     | Nothing. Calls are safe and do nothing.           |

- Xcode 16 or later.
- The SwiftUI modifier needs iOS 14, macOS 11, tvOS 14, or watchOS 7.

## Installation

### Swift Package Manager

Add SimpleHaptics to your project using Swift Package Manager:

1. In Xcode, select **File** → **Add Package Dependencies...**
2. Enter the repository URL:

   ```plaintext
   https://github.com/notbd/SimpleHaptics.git
   ```

3. Choose the version or branch you want to use
4. Click **Add Package**

Alternatively, add it to your `Package.swift` file:

```swift
dependencies: [
  .package(url: "https://github.com/notbd/SimpleHaptics.git", from: "0.3.0")
]
```

## Usage

### Play a haptic

Call `play(_:)` from the main actor, such as a button action or a gesture handler:

```swift
import SimpleHaptics

Button("Save") {
  save()
  SimpleHaptics.play(.success)
}
```

From asynchronous code, `await` the same call. Swift switches to the main actor for you:

```swift
func sync() async throws {
  try await api.sync()
  await SimpleHaptics.play(.success)
}
```

From a synchronous callback that isn't on the main actor, start a task:

```swift
Task { @MainActor in
  SimpleHaptics.play(.success)
}
```

### Set the intensity

Impact haptics accept an intensity from `0.0` to `1.0`. Other types ignore it.

```swift
SimpleHaptics.play(.heavy, intensity: 0.4)
```

### Prepare before a gesture

`prepare(_:)` wakes the haptic hardware for a few seconds, so the next haptic plays with minimal latency:

```swift
DragGesture()
  .onChanged { _ in SimpleHaptics.prepare(.rigid) }
  .onEnded { _ in SimpleHaptics.play(.rigid) }
```

### Let people turn haptics off

Apple's [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/playing-haptics)
ask apps to make haptics optional. Connect a setting to `isEnabled`:

```swift
struct SettingsView: View {
  @AppStorage("hapticsEnabled") private var hapticsEnabled = true

  var body: some View {
    Toggle("Haptics", isOn: $hapticsEnabled)
      .onChange(of: hapticsEnabled) { _, isOn in
        SimpleHaptics.isEnabled = isOn
      }
  }
}
```

Set `isEnabled` again when the app launches, because the value isn't saved. Use `SimpleHaptics.isSupported` to
hide the setting on devices that can't play haptics.

### Play a haptic when a value changes in SwiftUI

```swift
Picker("Mode", selection: $mode) { ... }
  .haptic(.selection, trigger: mode)

List(items) { item in ... }
  .haptic(.success, trigger: loadState) { _, newValue in
    newValue == .loaded
  }
```

SwiftUI's own `.sensoryFeedback(_:trigger:)` does the same on iOS 17 and later. Use `.haptic(_:trigger:)` when you
support iOS 14 to 16, or when the haptic must respect `isEnabled`.

## Haptic Types

| Type         | iPhone                                         | Apple Watch | Mac        |
| ------------ | ---------------------------------------------- | ----------- | ---------- |
| `.selection` | `UISelectionFeedbackGenerator`                 | `.click`    | `.generic` |
| `.success`   | `UINotificationFeedbackGenerator`, `.success`  | `.success`  | `.generic` |
| `.warning`   | `UINotificationFeedbackGenerator`, `.warning`  | `.retry`    | `.generic` |
| `.error`     | `UINotificationFeedbackGenerator`, `.error`    | `.failure`  | `.generic` |
| `.light`     | `UIImpactFeedbackGenerator`, `.light`          | `.click`    | `.generic` |
| `.medium`    | `UIImpactFeedbackGenerator`, `.medium`         | `.click`    | `.generic` |
| `.heavy`     | `UIImpactFeedbackGenerator`, `.heavy`          | `.click`    | `.generic` |
| `.soft`      | `UIImpactFeedbackGenerator`, `.soft`           | `.click`    | `.generic` |
| `.rigid`     | `UIImpactFeedbackGenerator`, `.rigid`          | `.click`    | `.generic` |

## Migrating from 0.2

`generateTask(_:)` and `generate(_:)` are deprecated and will be removed in 1.0.0.

| 0.2                                       | 0.3                                                        |
| ----------------------------------------- | ---------------------------------------------------------- |
| `SimpleHaptics.generateTask(.success)`    | `SimpleHaptics.play(.success)`                             |
| `await SimpleHaptics.generate(.success)`  | `await SimpleHaptics.play(.success)`, or no `await` on the main actor |

Cancelling the task that `generateTask(_:)` returned never stopped the haptic, so no behavior is lost.

## Example App

[`Examples/SimpleHapticsDemo`](./Examples/SimpleHapticsDemo) plays every haptic type and shows each feature.

1. Open `Examples/SimpleHapticsDemo/SimpleHapticsDemo.xcodeproj`.
2. In **Signing & Capabilities**, select your team.
3. Run the app on an iPhone. Simulator doesn't play haptics.

## Documentation

The API reference is written in DocC. In Xcode, select **Product** → **Build Documentation**.

## License

[MIT License](./LICENSE)
