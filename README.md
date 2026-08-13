[![Swift 6](https://img.shields.io/badge/swift-6-blue.svg)](https://swift.org)
[![MIT LiCENSE](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![build status](https://github.com/dankogai/swift-interval/actions/workflows/swift.yml/badge.svg)](https://github.com/dankogai/swift-interval/actions/workflows/swift.yml)

# swift-interval

[Interval Arithmetic] in Swift with Interval Type

[Interval Arithmetic]: https://en.wikipedia.org/wiki/Interval_arithmetic

## Synopsis

````swift
import Interval
let about1 = 1.0 ± 0.1  // 0.9...1.1
about1+about1           // 1.8...2.2
about1-about1           // -0.2...0.2
about1*about1           // 0.81...1.21
about1/about1           // 0.818181818181818...1.22222222222222
````
## Prerequisite

Swift 6.0 or better, macOS or Linux.

## Usage

### build

```sh
git clone https://github.com/dankogai/swift-interval.git
cd swift-interval
swift build
```

### REPL

```sh
swift run --repl
```

```swift
import Interval
let about1 = 1.0 ± 0.1
```

### in your project

Add the following to the `dependencies` of your `Package.swift`:

```swift
.package(url: "https://github.com/dankogai/swift-interval.git", from: "1.0.0")
```

and add `"Interval"` to the dependencies of your target.

### with playground

Have fun with [macOS.playground] that is a part of this git repo.

[macOS.playground]: ./macOS.playground

## Test

```sh
swift test
```
