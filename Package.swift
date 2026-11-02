// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SimpleHaptics",
  platforms: [
    .iOS("13.0"),
    .macCatalyst("13.1"),
    .macOS("10.15"),
    .tvOS("13.0"),
    .watchOS("6.0"),
    .visionOS("1.0"),
  ],
  products: [
    .library(
      name: "SimpleHaptics",
      targets: ["SimpleHaptics"]),
  ],
  targets: [
    .target(
      name: "SimpleHaptics",
      dependencies: [],
      resources: [.copy("PrivacyInfo.xcprivacy")]),
    .testTarget(
      name: "SimpleHapticsTests",
      dependencies: ["SimpleHaptics"]),
  ],
  swiftLanguageModes: [.v6])
