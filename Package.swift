// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Interval",
    products: [
        .library(
          name: "Interval",
          type: .dynamic,
          targets: ["Interval"]),
    ],
    dependencies: [
      .package(url: "https://github.com/dankogai/swift-floatingpointmath.git", from: "0.0.7")
    ],
    targets: [
        .target(
            name: "Interval",
            dependencies: ["FloatingPointMath"]),
        .testTarget(
            name: "IntervalTests",
            dependencies: ["Interval"]),
    ]
)
