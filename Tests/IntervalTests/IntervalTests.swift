import Testing
@testable import Interval

@Suite struct IntervalTests {
    typealias D = Double
    typealias I = Interval

    @Test func basic() {
        #expect(I(1.0).min == 1.0 - Double.ulpOfOne)
        #expect(I(1.0).max == 1.0 + Double.ulpOfOne)
        #expect(I(1.0) + I(1.0) == I(D(2.0)))
        #expect(I(1.0) - I(1.0) == I(D(0.0)))
        #expect(I(1.0) * I(1.0) == I(D(1.0)))
        #expect(I(1.0) / I(1.0) == I(D(1.0)))
    }

    @Test func signalingNaN() {
        #expect(I<D>.signalingNaN.isSignalingNaN)
        #expect(!I<D>.nan.isSignalingNaN)
        #expect(I<D>.nan.isNaN)
    }

    @Test func nextUp() {
        let i = I(min:D(1.0), max:D(2.0))
        #expect(i.nextUp.min == D(1.0).nextUp)
        #expect(i.nextUp.max == D(2.0).nextUp)
    }

    // MARK: trigonometry

    @Test func cosAtCriticalPoints() {
        // cos(0) = 1, and a point interval stays a sliver around it
        let atZero = I<D>.cos(I(D(0)))
        #expect(atZero.contains(1.0))
        #expect(atZero.min > 0.999_999)
        // cos(±π) = -1
        for x in [D.pi, -D.pi] {
            let atPi = I<D>.cos(I(x))
            #expect(atPi.contains(-1.0))
            #expect(atPi.max < -0.999_999)
        }
        // an interval straddling π dips to exactly -1, and stays negative
        // (the upper endpoint is evaluated after range reduction, so compare
        // with tolerance, not equality)
        let spanning = I<D>.cos(I(D(3), D(4)))
        #expect(spanning.min == -1.0)
        #expect(Swift.abs(spanning.max - D.cos(4)) < 1e-12)
        // one straddling 0 peaks at exactly +1
        let aroundZero = I<D>.cos(I(D(-0.5), D(0.25)))
        #expect(aroundZero.max == 1.0)
        #expect(aroundZero.min == D.cos(-0.5))
        // monotone stretch: endpoints map to endpoints
        let monotone = I<D>.cos(I(D(0.5), D(1.5)))
        #expect(monotone.min == D.cos(1.5) && monotone.max == D.cos(0.5))
    }

    @Test func sinAtCriticalPoints() {
        // sin(±π/2) = ±1
        let atHalfPi = I<D>.sin(I(D.pi/2))
        #expect(atHalfPi.contains(1.0))
        #expect(atHalfPi.min > 0.999_999)
        let atMinusHalfPi = I<D>.sin(I(-D.pi/2))
        #expect(atMinusHalfPi.contains(-1.0))
        #expect(atMinusHalfPi.max < -0.999_999)
        // sin(0) = 0, straddled: endpoints, properly ordered
        let aroundZero = I<D>.sin(I(D(-0.1), D(0.1)))
        #expect(aroundZero.min == D.sin(-0.1) && aroundZero.max == D.sin(0.1))
        #expect(aroundZero.contains(0.0))
        // decreasing stretch past π/2: sorting matters -- min must not exceed max
        let decreasing = I<D>.sin(I(D(2), D(3)))
        #expect(decreasing.min == D.sin(3) && decreasing.max == D.sin(2))
        #expect(decreasing.min <= decreasing.max)
        // straddling +π/2 peaks at exactly +1
        let peak = I<D>.sin(I(D(1), D(2)))
        #expect(peak.max == 1.0 && peak.min == D.sin(1))
    }

    @Test func tanAtCriticalPoints() {
        // tan(0) = 0, monotone: endpoints in, endpoints out
        let aroundZero = I<D>.tan(I(D(-0.5), D(0.5)))
        #expect(aroundZero.min == D.tan(-0.5) && aroundZero.max == D.tan(0.5))
        #expect(aroundZero.contains(0.0))
        // tan(π/4) = 1
        #expect(I<D>.tan(I(D.pi/4)).contains(1.0))
        // a pole inside means the whole line
        let overPole = I<D>.tan(I(D(1), D(2)))          // π/2 ≈ 1.5708 inside
        #expect(overPole.min == -D.infinity && overPole.max == +D.infinity)
        // width ≥ π also means the whole line, never [-1, 1]
        let wide = I<D>.tan(I(D(0), D(4)))
        #expect(wide.min == -D.infinity && wide.max == +D.infinity)
    }

    @Test func wideAnglesSaturate() {
        // any interval at least one period wide covers the full range exactly
        for wide in [I(D(0), D(7)), I(D(-100), D(100)), I(min:D(0), max:2*D.pi)] {
            #expect(I<D>.cos(wide) === I(min:D(-1), max:D(1)))
            #expect(I<D>.sin(wide) === I(min:D(-1), max:D(1)))
        }
    }

    @Test func largeArgumentRangeReduction() {
        // cos(100): range reduction shifts by 16 periods and stays tight
        let c = I<D>.cos(I(D(100)))
        #expect(c.contains(D.cos(100)))
        #expect(c.err < 1e-10)
        let s = I<D>.sin(I(D(100)))
        #expect(s.contains(D.sin(100)))
        #expect(s.err < 1e-10)
    }

    // MARK: special functions

    @Test func erfIsMonotone() {
        // increasing: endpoints map to endpoints, in order
        let m = I<D>.erf(I(D(-1), D(2)))
        #expect(m.min == D.erf(-1) && m.max == D.erf(2))
        #expect(I<D>.erf(I(D(0))).contains(0.0))
        // decreasing twin, endpoints swapped
        let c = I<D>.erfc(I(D(-1), D(2)))
        #expect(c.min == D.erfc(2) && c.max == D.erfc(-1))
        // erf + erfc = 1, as intervals
        let x = 0.5 ± 0.125
        #expect((I.erf(x) + I.erfc(x)).contains(1.0))
    }

    @Test func gammaOnThePositiveAxis() {
        // Γ(n+1) = n!, exactly representable
        #expect(I<D>.gamma(I(D(5))).contains(24.0))
        #expect(I<D>.gamma(I(D(1))).contains(1.0))
        // monotone stretch: endpoints in, endpoints out
        let m = I<D>.gamma(I(D(3), D(4)))
        #expect(m.min == D.gamma(3) && m.max == D.gamma(4))
        // [1, 2] dips to the minimum Γ(x₀) ≈ 0.8856, below both endpoints
        let dip = I<D>.gamma(I(D(1), D(2)))
        #expect(dip.min < 0.8857 && dip.min > 0.8855)
        #expect(dip.max == 1.0)
    }

    @Test func gammaBelowZero() {
        // Γ(-0.5) = -2√π, via the reflection formula, tightly
        let g = I<D>.gamma(I(D(-0.5)))
        #expect(g.contains(D.gamma(-0.5)))
        #expect(g.err < 1e-10)
        // a pole inside (here -1) means the whole line
        let pole = I<D>.gamma(I(D(-1.5), D(-0.5)))
        #expect(pole.min == -D.infinity && pole.max == +D.infinity)
        // straddling the pole at 0 likewise
        let mixed = I<D>.gamma(I(D(-0.5), D(0.5)))
        #expect(mixed.min == -D.infinity && mixed.max == +D.infinity)
    }

    @Test func logGammaEverywhere() {
        // logΓ(5) = log(4!) on the positive axis
        #expect(I<D>.logGamma(I(D(5))).contains(D.log(24)))
        // logΓ(1) = logΓ(2) = 0 at the endpoints, the minimum in between
        let dip = I<D>.logGamma(I(D(1), D(2)))
        #expect(dip.max == 0.0)
        #expect(dip.min < -0.1214 && dip.min > -0.1215)
        // log|Γ(-0.5)| = log(2√π), via reflection
        let neg = I<D>.logGamma(I(D(-0.5)))
        #expect(neg.contains(D.logGamma(-0.5)))
        #expect(neg.err < 1e-10)
        // a pole inside sends the upper bound to +∞ -- and only the upper one
        let pole = I<D>.logGamma(I(D(-1.5), D(-0.5)))
        #expect(pole.max == +D.infinity)
        #expect(pole.min.isFinite)
        // straddling 0: hull of both sides, lower bound from the positive side
        let mixed = I<D>.logGamma(I(D(-0.5), D(0.5)))
        #expect(mixed.max == +D.infinity)
        #expect(mixed.contains(D.logGamma(0.5)))
    }

    // MARK: remainders

    @Test func remaindersMatchDouble() {
        for (a, b) in [(5.0, 3.0), (-5.0, 3.0), (5.0, -3.0), (-5.0, -3.0),
                       (7.25, 2.0), (-7.25, 2.0), (100.0, 2*D.pi), (1.0, 3.0)] {
            let t = I(a).truncatingRemainder(dividingBy: I(b))
            #expect(t.contains(a.truncatingRemainder(dividingBy: b)),
                    "truncatingRemainder(\(a), \(b))")
            let r = I(a).remainder(dividingBy: I(b))
            #expect(r.contains(a.remainder(dividingBy: b)),
                    "remainder(\(a), \(b))")
        }
    }

    @Test func remainderAcrossDiscontinuity() {
        // [4.4, 4.6] / 3 rounds to 1 on one side and 2 on the other:
        // the remainder set wraps, and the fallback must still enclose it
        let r = I(D(4.4), D(4.6)).remainder(dividingBy: I(D(3)))
        #expect(r.contains(D(4.4).remainder(dividingBy: 3)))    //  1.4
        #expect(r.contains(D(4.6).remainder(dividingBy: 3)))    // -1.4
        #expect(Swift.max(Swift.abs(r.min), Swift.abs(r.max)) <= 1.5 + 0.001)
        // same for truncation: [2.9, 3.1] % 3 wraps through 0
        let t = I(D(2.9), D(3.1)).truncatingRemainder(dividingBy: I(D(3)))
        #expect(t.contains(D(2.9)))     // 2.9 % 3 == 2.9
        #expect(t.contains(D(0.1)))     // 3.1 % 3 == 0.1
        // and a negative dividend keeps the dividend's sign
        let n = I(D(-2.9), D(-3.1)).truncatingRemainder(dividingBy: I(D(3)))
        #expect(n.max <= 0)
    }
}
