# SimpleHaptics

Simple and easy haptic generation in iOS.

## Requirements

- iOS 13.0+ / macOS Catalyst 13.1+
- Swift 5.8+

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
  .package(url: "https://github.com/notbd/SimpleHaptics.git", from: "0.2.0")
]
```

## Usage

### Import the Package

```swift
import SimpleHaptics
```

### Basic Usage

- `generateTask(_:)` is the most common way to quickly generate haptics in a synchronous context:

```swift
// in a synchronous context
SimpleHaptics.generateTask(.heavy)
```

- The task can be cancelled if needed:

```swift
let hapticTask = SimpleHaptics.generateTask(.light)
// can be cancelled later if needed
hapticTask.cancel()
```

- Alternatively, use `generate(_:)` in an asynchronous context:

```swift
// in an async context
Task {
  await SimpleHaptics.generate(.success)
}
```

## Available Haptic Types

### Selection Haptic

- `.selection` - A gentle tap to indicate selection changes

### Notification Haptics

- `.success` - A positive confirmation feedback
- `.warning` - A warning or attention-drawing feedback
- `.error` - An error alert feedback

### Impact Haptics (self-explanatory)

- `.light`
- `.medium`
- `.heavy`
- `.soft`
- `.rigid`

## Examples

- Quickly generate Success Feedback

```swift
func saveData() {
  // ... save your data

  // generate a success feedback after saving
  SimpleHaptics.generateTask(.success)
}
```

- Generate Haptic Feedback after a delay

```swift
var body: some View {
  List {
    // ... your list items
  }
  .onChange(of: loadStatus) {
    Task {
      try? await Task.sleep(nanoseconds: UInt64(0.1 * 1_000_000_000))
      await SimpleHaptics.generate(.light)
    }
  }
}
```

## License

[MIT License](./LICENSE)
