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

Swift 6.0 or better, macOS or Linux.  This package depends on nothing: `Double`
conforms to `IntervalElement` out of the box, via libm.  Other element types are
one empty extension away — see the example subpackages below.

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
.package(url: "https://github.com/dankogai/swift-interval.git", from: "6.0.0")
```

and add `"Interval"` to the dependencies of your target.

### with playground

Have fun with [macOS.playground] that is a part of this git repo: open the
package folder in Xcode, let it resolve, and the playground pages can
`import Interval`.  Four pages: a synopsis of the API, the quadratic formula
with its cancellation made visible, error propagation without the calculus,
and a scratch pad.

[macOS.playground]: ./macOS.playground

### with swift-numerics

`IntervalElement`'s function requirements deliberately share their names and
signatures with [apple/swift-numerics]' `Real`, so any `Real` type is one empty
extension away from being an element.
[SwiftNumericsExample](./SwiftNumericsExample/) conforms `Float` that way — and
goes the other direction too, making `Interval` itself a `RealModule.Real`, so
intervals flow through code written generically for scalars:

```swift
extension Float: @retroactive IntervalElement {}

func rms<T: Real>(_ x: T, _ y: T) -> T { T.sqrt((x*x + y*y)/2) }
rms(3.0 ± 0.1, 4.0 ± 0.1)   // 3.5355622…±0.0989941…
```

[apple/swift-numerics]: https://github.com/apple/swift-numerics

### with swift-bignum

The same one-liner works for [dankogai/swift-bignum].
[SwiftBigNumExample](./SwiftBigNumExample/) shows `Interval<BigRat>` and
`Interval<BigFloat>`, where interval arithmetic becomes *exact*:

```swift
let about1 = BigRat(1) ± BigRat(1, 10)   // [9/10, 11/10]
about1 / about1                          // [9/11, 11/9] — the fractions, exactly
```

[dankogai/swift-bignum]: https://github.com/dankogai/swift-bignum

## Test

```sh
swift test
```
