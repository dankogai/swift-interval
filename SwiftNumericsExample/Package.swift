// swift-tools-version: 6.0
//
// A demo of using Interval alongside apple/swift-numerics, and a package of its
// own so that swift-interval's root manifest keeps its no-dependencies property --
// SwiftPM resolves every declared dependency whether the target using it is being
// built or not.
//
//     cd SwiftNumericsExample && swift test
//
// The parent is a `path:` dependency, not a `url:` one.  A URL pointing at `..`
// makes SwiftPM clone the parent as a git working copy and resolve it to a
// *committed* revision, so uncommitted work in the checkout you are sitting in is
// invisible to the demo.  `path:` reads the directory itself, which is what a
// sibling demo wants.
//
// Its package identity is `swift-interval`, from the directory name rather than
// from the `name: "Interval"` in its manifest -- that is what `.product(package:)`
// below has to match.
//
import PackageDescription

let package = Package(
    name: "SwiftNumericsExample",
    products: [
        .library(
            name: "SwiftNumericsExample",
            targets: ["SwiftNumericsExample"]
        ),
    ],
    dependencies: [
        .package(path: ".."),
        .package(url: "https://github.com/apple/swift-numerics", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "SwiftNumericsExample",
            dependencies: [
                .product(name: "Interval", package: "swift-interval"),
                .product(name: "RealModule", package: "swift-numerics"),
            ]),
        .testTarget(
            name: "SwiftNumericsExampleTests",
            dependencies: ["SwiftNumericsExample"]),
    ]
)
