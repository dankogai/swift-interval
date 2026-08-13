//
//  SwiftBigNumExample.swift -- Interval and swift-bignum together.
//
//  What this package is for: `Interval<BigRat>` and `Interval<BigFloat>`.
//  IntervalElementConformance.swift is the part that makes them compile; this file
//  is what they are good for.
//
//  Everything printed here is asserted in the test suite, so the comments are
//  checked rather than claimed.
//
import BigNum
import Interval

/// A point stays a point.
///
/// `Interval(x)` pads a single value by `x.ulp` on both sides -- the honest thing
/// to do for a binary float, which probably could not represent the number you
/// meant.  `BigRat` is exact, its `ulp` is zero, and so `Interval<BigRat>` of one
/// value is one value: `[1/10, 1/10]`, width zero.  Over `Double` the same
/// construction is two ulps wide before any arithmetic has happened.
public func pointInterval() -> (tenth: Interval<BigRat>, isPoint: Bool) {
    let tenth = Interval(BigRat(1, 10))
    return (tenth, tenth.min == tenth.max && tenth.err.isZero)
}

/// 1/10 + 1/5 == 3/10, with nothing to forgive.
///
/// The textbook float embarrassment: `0.1 + 0.2 != 0.3` over `Double`, so an
/// `Interval<Double>` has to widen to stay truthful.  Over `BigRat` the sum of two
/// point intervals is the point interval of the sum, exactly.
public func exactSum() -> (sum: Interval<BigRat>, isExactlyThreeTenths: Bool) {
    let sum = Interval(BigRat(1, 10)) + Interval(BigRat(1, 5))
    return (sum, sum.isIdentical(to: Interval(BigRat(3, 10))))
}

/// Interval division with endpoints you can name.
///
/// `about1 = 1 ± 1/10` is `[9/10, 11/10]`, and `about1/about1` is *not* 1 -- the
/// two occurrences are independent, which is interval arithmetic's famous
/// dependency problem.  The correct answer is `[9/11, 11/9]`, and over `BigRat`
/// that is what comes out: the rationals themselves, not their nearest floats.
public func exactDivision() -> (quotient: Interval<BigRat>, isExact: Bool) {
    let about1 = BigRat(1) ± BigRat(1, 10)
    let q = about1 / about1
    return (q, q.isIdentical(to: Interval(min: BigRat(9, 11), max: BigRat(11, 9))))
}

/// A `Double`'s error bars, checked at 128 bits.
///
/// `Double.pi` is a lie of at most one ulp; `BigFloat.pi` is the same lie told at
/// BigNum's default 128 bits, about 1e-39 from the truth.  Bracket the former and
/// the latter must fall inside -- an `Interval<BigFloat>` whose endpoints came
/// from `Double` contains the much better approximation.
public func doublePiBracketsBigFloatPi() -> (bracket: Interval<BigFloat>, contains: Bool) {
    let bracket = Interval(BigFloat(Double.pi.nextDown), BigFloat(Double.pi.nextUp))
    return (bracket, bracket.contains(BigFloat.pi))
}

/// Prints the four above.  Not a test -- `swift test` is where the checking is.
public func demo() {
    let (tenth, isPoint) = pointInterval()
    print("Interval<BigRat>: Interval(1/10) = \(tenth.min)...\(tenth.max)")
    print("                 width zero? \(isPoint)")

    let (sum, exact) = exactSum()
    print("Interval<BigRat>: 1/10 + 1/5 = \(sum.min)...\(sum.max)")
    print("                 exactly 3/10? \(exact)")

    let (q, qExact) = exactDivision()
    print("Interval<BigRat>: (1 ± 1/10)/(1 ± 1/10) = \(q.min)...\(q.max)")
    print("                 exactly [9/11, 11/9]? \(qExact)")

    let (bracket, contains) = doublePiBracketsBigFloatPi()
    print("Interval<BigFloat>: Double.pi ± 1ulp = \(bracket.min.toDouble())...\(bracket.max.toDouble())")
    print("                   contains 128-bit pi? \(contains)")
}
