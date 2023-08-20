// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SimpleHaptics",
  platforms: [
    .iOS("13.0"),
    .macCatalyst("13.1"),
  ],
  products: [
    .library(
      name: "SimpleHaptics",
      targets: ["SimpleHaptics"]),
  ],
  targets: [
    .target(
      name: "SimpleHaptics",
      dependencies: []),
  ],
  swiftLanguageVersions: [.v5])
