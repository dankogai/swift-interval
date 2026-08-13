// swift-tools-version: 6.0
//
// A demo of using Interval together with dankogai/swift-bignum, and a package of
// its own so that swift-interval's root manifest depends on nothing but
// swift-numerics -- SwiftPM resolves every declared dependency whether the target
// using it is being built or not.
//
//     cd SwiftBigNumExample && swift test
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
    name: "SwiftBigNumExample",
    products: [
        .library(
            name: "SwiftBigNumExample",
            targets: ["SwiftBigNumExample"]
        ),
    ],
    dependencies: [
        .package(path: ".."),
        .package(url: "https://github.com/dankogai/swift-bignum.git", from: "6.3.1"),
        .package(url: "https://github.com/apple/swift-numerics", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "SwiftBigNumExample",
            dependencies: [
                .product(name: "Interval", package: "swift-interval"),
                .product(name: "BigNum", package: "swift-bignum"),
                .product(name: "RealModule", package: "swift-numerics"),
            ]),
        .testTarget(
            name: "SwiftBigNumExampleTests",
            dependencies: ["SwiftBigNumExample"]),
    ]
)
