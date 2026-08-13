import Testing
import BigNum
import Interval
import RealModule
@testable import SwiftBigNumExample

@Suite struct SwiftBigNumExampleTests {

    // MARK: the demo's claims, asserted

    @Test func pointIntervalIsAPoint() {
        let (tenth, isPoint) = pointInterval()
        #expect(isPoint)
        #expect(tenth.min == BigRat(1, 10))
        #expect(tenth.max == BigRat(1, 10))
        // the same construction over Double is two ulps wide
        let dTenth = Interval<Double>(0.1)
        #expect(dTenth.min < dTenth.max)
    }

    @Test func sumIsExact() {
        let (sum, exact) = exactSum()
        #expect(exact)
        #expect(sum.err.isZero)
        // whereas Double famously misses: 0.1 + 0.2 != 0.3
        #expect(0.1 + 0.2 != 0.3)
        #expect(BigRat(1, 10) + BigRat(1, 5) == BigRat(3, 10))
    }

    @Test func divisionIsExact() {
        let (q, exact) = exactDivision()
        #expect(exact)
        #expect(q.min == BigRat(9, 11))
        #expect(q.max == BigRat(11, 9))
        // the dependency problem: x/x over an interval is not 1, but contains it
        #expect(q.contains(BigRat(1)))
    }

    @Test func bracketContainsBetterPi() {
        let (bracket, contains) = doublePiBracketsBigFloatPi()
        #expect(contains)
        #expect(bracket.contains(BigFloat(Double.pi)))
        // and the bracket is honest: strictly wider than a point
        #expect(bracket.min < bracket.max)
    }

    // MARK: the conformance itself

    @Test func ulpOfExactTypesIsZero() {
        // this is why point intervals stay points
        #expect(BigRat(1, 10).ulp.isZero)
        #expect(BigFloat(1).ulp.isZero)
    }

    @Test func plusMinusOperator() {
        let about1 = BigRat(1) ± BigRat(1, 10)
        #expect(about1.min == BigRat(9, 10))
        #expect(about1.max == BigRat(11, 10))
        #expect(about1.mid == BigRat(1))
        #expect(about1.err == BigRat(1, 10))
    }

    @Test func arithmeticStaysRational() {
        let a = BigRat(1, 3) ± BigRat(1, 100)
        let b = BigRat(2, 3) ± BigRat(1, 100)
        let sum = a + b
        #expect(sum.min == BigRat(1) - BigRat(2, 100))
        #expect(sum.max == BigRat(1) + BigRat(2, 100))
        let prod = a * b
        #expect(prod.min == (BigRat(1, 3) - BigRat(1, 100)) * (BigRat(2, 3) - BigRat(1, 100)))
        #expect(prod.max == (BigRat(1, 3) + BigRat(1, 100)) * (BigRat(2, 3) + BigRat(1, 100)))
    }

    @Test func sendableAcrossTasks() async {
        // Interval<BigRat> is Sendable -- this compiling is most of the test
        let about1 = BigRat(1) ± BigRat(1, 10)
        let doubled = await Task.detached { about1 + about1 }.value
        #expect(doubled.isIdentical(to: BigRat(2) ± BigRat(2, 10)))
    }
}
