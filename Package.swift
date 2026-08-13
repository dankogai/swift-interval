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
    dependencies: [],
    targets: [
        .target(
           name: "Interval"),
        .executableTarget(
            name: "IntervalRun",
            dependencies: ["Interval"]),
        .testTarget(
            name: "IntervalTests",
            dependencies: ["Interval"]),
    ]
)
