// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Interval",
    products: [
        .library(
          name: "Interval",
          targets: ["Interval"]),
    ],
    dependencies: [
      .package(url: "https://github.com/apple/swift-numerics", from: "1.0.0"),
    ],
    targets: [
        .target(
           name: "Interval",
           dependencies: [
               .product(name: "Numerics", package: "swift-numerics")
           ]),
        .executableTarget(
            name: "IntervalRun",
            dependencies: ["Interval"]),
        .testTarget(
            name: "IntervalTests",
            dependencies: ["Interval"]),
    ]
)
