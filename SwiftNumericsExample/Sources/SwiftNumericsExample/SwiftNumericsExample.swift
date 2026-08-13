//
//  SwiftNumericsExample.swift -- Interval and apple/swift-numerics together.
//
//  What this package is for: `Interval<Float>`, and `Interval` as a
//  `RealModule.Real`.  IntervalElementConformance.swift is the part that makes
//  them compile; this file is what they are good for.
//
//  Everything printed here is asserted in the test suite, so the comments are
//  checked rather than claimed.
//
import Interval
import RealModule

/// `Interval<Float>`, exactly as usable as `Interval<Double>`.
///
/// The parent ships only `Double: IntervalElement`; one empty extension buys
/// `Float`, and everything comes with it -- `±`, the arithmetic, the enclosure
/// semantics.  `1 ± 1/16` is chosen so both endpoints are representable; the
/// quotient's bounds land within an ulp or two of `15/17` and `17/15`.
public func floatInterval() -> (about1: Interval<Float>, quotient: Interval<Float>) {
    let about1 = Float(1) ± Float(0.0625)
    return (about1, about1 / about1)
}

/// One generic function, three number types -- and one of them is an interval.
///
/// The root-mean-square written once, for `Real`.  Handing it `Interval<Float>`
/// instead of `Float` is how measurement error rides through code that never
/// heard of intervals: rms(3±0.1, 4±0.1) computes rms(3,4) = √(25/2) with the
/// uncertainty carried along, and the scalar answer lands inside.
public func rms<T: Real>(_ x: T, _ y: T) -> T {
    return T.sqrt((x*x + y*y)/2)
}

public func rmsWithUncertainty() -> (scalar: Double, interval: Interval<Double>, contained: Bool) {
    let scalar = rms(3.0, 4.0)
    let interval = rms(3.0 ± 0.1, 4.0 ± 0.1)
    return (scalar, interval, interval.contains(scalar))
}

/// The interval that log and exp agree on.
///
/// `exp` then `log`, elementwise over the enclosure: monotone functions map
/// intervals to intervals with no width to spare, and coming back returns to
/// within a few ulps of where you started.
public func thereAndBackAgain() -> (start: Interval<Double>, roundTrip: Interval<Double>) {
    let start = 1.0 ± 0.5
    return (start, Interval.log(Interval.exp(start)))
}

/// Prints the three above.  Not a test -- `swift test` is where the checking is.
public func demo() {
    let (about1, q) = floatInterval()
    print("Interval<Float>: 1 ± 1/16 = \(about1)")
    print("                (1 ± 1/16)/(1 ± 1/16) = \(q.min)...\(q.max)")

    let (scalar, interval, contained) = rmsWithUncertainty()
    print("rms<Real>: rms(3, 4) = \(scalar)")
    print("           rms(3±0.1, 4±0.1) = \(interval)")
    print("           scalar answer inside? \(contained)")

    let (start, roundTrip) = thereAndBackAgain()
    print("Interval as Real: log(exp(\(start))) = \(roundTrip)")
}
