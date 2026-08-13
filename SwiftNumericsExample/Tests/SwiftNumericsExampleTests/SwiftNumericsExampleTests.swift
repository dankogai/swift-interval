import Testing
// for free-function sqrt/log2 below: `Double.sqrt` is ambiguous in a file that
// imports both Interval and RealModule, since each declares one
import Foundation
import Interval
import RealModule
@testable import SwiftNumericsExample

@Suite struct SwiftNumericsExampleTests {

    // MARK: the demo's claims, asserted

    @Test func floatIntervalWorks() {
        let (about1, q) = floatInterval()
        #expect(about1.min == Float(0.9375))    // 15/16, exact in binary
        #expect(about1.max == Float(1.0625))    // 17/16, exact in binary
        #expect(q.contains(Float(1)))
        // division is reciprocal-then-multiply -- two roundings -- so the
        // endpoints sit within an ulp or two of the true quotients 15/17, 17/15
        #expect(abs(q.min - Float(15)/Float(17)) <= 2 * q.min.ulp)
        #expect(abs(q.max - Float(17)/Float(15)) <= 2 * q.max.ulp)
    }

    @Test func rmsCarriesUncertainty() {
        let (scalar, interval, contained) = rmsWithUncertainty()
        #expect(contained)
        #expect(scalar == (12.5 as Double).squareRoot())
        // the enclosure is finite and sane: within ±0.1-ish of the scalar
        #expect(interval.err < 0.2)
        // and the same generic function still does plain Float
        #expect(rms(Float(3), Float(4)) == Float(12.5).squareRoot())
    }

    @Test func logExpRoundTrips() {
        let (start, roundTrip) = thereAndBackAgain()
        // exp and log are monotone: enclosure in, enclosure back
        #expect(roundTrip.contains(start.mid))
        #expect(abs(roundTrip.min - start.min) <= 4 * start.min.ulp)
        #expect(abs(roundTrip.max - start.max) <= 4 * start.max.ulp)
    }

    // MARK: the conformances themselves

    @Test func floatLiteralAndOperators() {
        let x: Interval<Float> = 1.5
        #expect(x.contains(Float(1.5)))
        let y = Float(2) ± Float(0.5)
        #expect((x + y).contains(Float(3.5)))
    }

    @Test func intervalIsReal() {
        // the generic entry points of RealModule, driving Interval
        func kernel<T: Real>(_ x: T) -> T { T.exp(x) * T.exp(-x) }   // == 1
        #expect(kernel(1.0 ± 0.25).contains(1.0))
        #expect(kernel(Float(1) ± Float(0.25)).contains(Float(1)))
    }

    @Test func monotoneFunctionsElementwise() {
        let x = 4.0 ± 1.0   // [3, 5]
        let s = Interval.sqrt(x)
        #expect(s.min == sqrt(3.0))
        #expect(s.max == sqrt(5.0))
        let l = Interval.log2(2.0 ± 1.0)  // [1, 3]
        #expect(l.min == 0.0 && l.max == log2(3.0))
    }
}
