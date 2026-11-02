# ``SimpleHaptics``

Play haptic feedback with one line of code. Plays on iPhone, Apple Watch, and Mac, and builds on every Apple platform.

## Overview

SimpleHaptics wraps the system feedback generators in one call:

```swift
SimpleHaptics.play(.success)
```

- On iPhone, it uses the UIKit feedback generators and keeps one generator per kind.
- On Apple Watch, it plays the closest `WKHapticType`.
- In a native Mac app, it plays a generic haptic on a Force Touch trackpad.
- In a Mac Catalyst app, it calls the UIKit feedback generators. This hasn't been tested on a Mac.
- On Apple TV and Apple Vision Pro, every call is safe and does nothing.

Let people turn haptics off in your app's settings, and connect that setting to
``SimpleHaptics/SimpleHaptics/isEnabled``. Apple's Human Interface Guidelines ask apps to make haptics optional.

## Topics

### Playing haptics

- ``SimpleHaptics/SimpleHaptics``
- ``SimpleHaptics/SimpleHaptics/HapticType``

### Playing haptics in SwiftUI

- ``SwiftUICore/View/haptic(_:trigger:)``
- ``SwiftUICore/View/haptic(_:trigger:condition:)``
