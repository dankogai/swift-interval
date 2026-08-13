# SwiftNumericsExample

`Interval<Float>`, and `Interval` as a `RealModule.Real`, using
[swift-interval](..) for the intervals and [apple/swift-numerics] for everything
it deliberately no longer depends on.

```bash
cd SwiftNumericsExample && swift test
```

A package of its own, so that swift-interval's own manifest fetches nothing —
SwiftPM resolves every declared dependency whether the target using it is being
built or not.

## The whole conformance

```swift
import Interval
import RealModule

extension Float: @retroactive IntervalElement {}

extension Interval: @retroactive AlgebraicField {}
extension Interval: @retroactive ElementaryFunctions {}
extension Interval: @retroactive RealFunctions {}
extension Interval: @retroactive Real {}
```

That is it, in both directions. `IntervalElement`'s function requirements share
their names and signatures with `RealModule.Real`'s, deliberately, and declare no
defaults — so any `Real` already carries every witness and there is nothing to
break a tie with. `Float` gets its members from RealModule; `Double` needs none
of this, because its conformance lives in swift-interval itself, on libm — which
is how the parent has no dependencies.

The reverse is the same trick reflected: `Interval` declares its math as concrete
members under RealModule's names, so `Interval<F>` *is* a `Real` the moment
somebody who imports RealModule says so.

## What it buys you

**A second element type, for one line.** The parent ships `Double` only; the
empty extension above buys `Float`, and `±`, the arithmetic, and the enclosure
semantics all come with it:

```swift
let about1 = Float(1) ± Float(0.0625)    // [15/16, 17/16], both exact in binary
about1 / about1                          // ≈ [15/17, 17/15] — and contains 1
```

**Intervals riding through generic code.** Write a function once, for `Real`, and
measurement error flows through arithmetic that never heard of intervals:

```swift
func rms<T: Real>(_ x: T, _ y: T) -> T { T.sqrt((x*x + y*y)/2) }

rms(3.0, 4.0)          // 3.5355339059327378
rms(3.0 ± 0.1, 4.0 ± 0.1)   // 3.5355622…±0.0989941… — the scalar answer inside
```

What `demo()` prints, and the tests assert:

```
Interval<Float>: 1 ± 1/16 = 1.0±0.0625
                (1 ± 1/16)/(1 ± 1/16) = 0.88235295...1.1333334
rms<Real>: rms(3, 4) = 3.5355339059327378
           rms(3±0.1, 4±0.1) = 3.535562212282583±0.09899415679466683
           scalar answer inside? true
Interval as Real: log(exp(1.0±0.5)) = 1.0±0.5
```

## Three things worth knowing before you copy this

**Division endpoints are twice-rounded.** `Interval` divides by
reciprocal-then-multiply, so `(1 ± 1/16)/(1 ± 1/16)`'s bounds sit within an ulp
or two of the true `15/17` and `17/15` rather than exactly at their nearest
floats. The tests assert the honest version.

**Four of `Real`'s members are stubs.** `erf`, `erfc`, `gamma`, `logGamma` on
`Interval` currently `fatalError("yet to be implemented")`. The conformance is
real; those four corners of it are not yet.

**`Double.sqrt` becomes ambiguous here.** swift-interval declares
`Double.sqrt(_:)` (its libm-backed `IntervalElement` witness) and RealModule
declares another. A file importing both modules must use `x.squareRoot()`,
Foundation's free `sqrt`, or generic entry points like the `rms` above —
`Interval` code is unaffected, since each module resolves its own witness at its
own compile time.

## The tests

Six of them. The three demo claims above, plus: float literals and `±` over
`Float`, RealModule's generic entry points driving `Interval` for both element
types (`exp(x)·exp(−x)` encloses 1), and monotone functions mapping endpoints to
endpoints exactly.

[apple/swift-numerics]: https://github.com/apple/swift-numerics
