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
}
