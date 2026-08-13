# SwiftBigNumExample

`Interval<BigRat>` and `Interval<BigFloat>`, using
[swift-interval](..) for the interval part and [dankogai/swift-bignum] for the
numbers inside.

```bash
cd SwiftBigNumExample && swift test
```

A package of its own, so that swift-interval's own manifest fetches nothing —
SwiftPM resolves every declared dependency whether the target using it is being
built or not.

## The whole conformance

```swift
import BigNum
import Interval

extension BigRat: @retroactive IntervalElement {}
extension BigFloat: @retroactive IntervalElement {}
```

That is it. `IntervalElement`'s function requirements share their names and
signatures with swift-numerics' `RealModule.Real`, and BigNum's own `Real`
declares that same requirement set too — three libraries agreeing on a vocabulary
so that none of them has to depend on another. BigNum's types already carry every
witness, plus the `Sendable`, `ExpressibleByFloatLiteral`, and
`CustomDebugStringConvertible` that `IntervalElement` also asks for. The
`@retroactive` is Swift 6 asking you to say out loud that you, not BigNum, own
these conformances.

## What it buys you

**Points stay points.** `Interval(x)` pads a single value by `x.ulp` on both
sides — the honest thing to do for a binary float, which probably could not
represent the number you meant. `BigRat` is exact, its `ulp` is zero, and so:

```swift
Interval(BigRat(1, 10))          // [1/10, 1/10] — width zero
Interval<Double>(0.1)            // two ulps wide before any arithmetic happened
```

**Arithmetic that owes nothing.** `0.1 + 0.2 != 0.3` over `Double`, so an
`Interval<Double>` has to widen to stay truthful. Over `BigRat` the sum of two
point intervals is the point interval of the sum:

```swift
Interval(BigRat(1, 10)) + Interval(BigRat(1, 5))   // [3/10, 3/10], exactly
```

**Endpoints you can name.** `about1 = 1 ± 1/10` divided by itself is *not* 1 — the
two occurrences are independent, which is interval arithmetic's famous dependency
problem. The correct answer has rational endpoints, and over `BigRat` you get the
rationals themselves, not their nearest floats:

```swift
let about1 = BigRat(1) ± BigRat(1, 10)   // [9/10, 11/10]
about1 / about1                          // [9/11, 11/9] — the fractions, exactly
```

**Error bars checked at 128 bits.** Bracket `Double.pi` by one ulp each way and
`BigFloat.pi` — the same constant at BigNum's default 128 bits, about 1e-39 from
the truth — must land inside:

```swift
let bracket = Interval(BigFloat(Double.pi.nextDown), BigFloat(Double.pi.nextUp))
bracket.contains(BigFloat.pi)            // true
```

What `demo()` prints, and the tests assert:

```
Interval<BigRat>: Interval(1/10) = (1/10)...(1/10)
                 width zero? true
Interval<BigRat>: 1/10 + 1/5 = (3/10)...(3/10)
                 exactly 3/10? true
Interval<BigRat>: (1 ± 1/10)/(1 ± 1/10) = (9/11)...(11/9)
                 exactly [9/11, 11/9]? true
Interval<BigFloat>: Double.pi ± 1ulp = 3.1415926535897927...3.1415926535897936
                   contains 128-bit pi? true
```

## Two things worth knowing before you copy this

**`ulp == 0` cuts both ways.** It is what makes point intervals possible, but
`Interval`'s containment guarantee leans on outward padding that exact types no
longer provide for *inexact* operations. `BigRat`'s field arithmetic
(`+ - * /`) is exact, so there is nothing to pad. `BigFloat`'s transcendentals
(`sqrt`, `sin`, `pi`…) are rounded to `BigFloat.precision` bits, and a point
interval through them stays a point — a very good approximation wearing an
exactness it does not have. Treat `Interval<BigFloat>` bounds as ~128-bit
accurate, not as guarantees.

**Precision is stuck at whatever `BigFloat.precision` says.** It is a mutable
`static var`, which under Swift 6 language mode cannot even be read from your
code, let alone set. This example runs at the default 128 bits and is content.

## The tests

Eight of them. The four demo claims above, plus the ones that earn their keep:
that `ulp` really is zero for both types (the whole point-interval story rests on
it), that `±` builds the interval it names, that products of rational intervals
have the exact rational endpoints the multiplication formula says, and that
`Interval<BigRat>` crosses a `Task` boundary — `Sendable` became part of
`IntervalElement` in the Swift 6 modernization, and this is that requirement
observed in the wild.

[dankogai/swift-bignum]: https://github.com/dankogai/swift-bignum
