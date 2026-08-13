//: [Previous](@previous)
/*:
 # The Quadratic Formula, with the error bars visible

 Solve x² + 10¹⁵x + 10¹⁴ = 0.  The two textbook formulas below are algebraically
 identical -- and numerically they are not even close, because `-b + √(b²−4ac)`
 subtracts two nearly equal numbers and cancels away most of the significant
 digits.  A `Double` fails silently here; an `Interval` fails *visibly*: the
 enclosure keeps every rounding it suffered, and its width is the honest error
 bar.

 cf. <http://verifiedby.me/adiary/070>
 */
import Interval

func discriminantRoot<T: IntervalElement>(_ a: Interval<T>, _ b: Interval<T>, _ c: Interval<T>) -> Interval<T> {
    return Interval.sqrt(b*b - T(4)*a*c)
}
//: The naive root: `(-b + √(b²−4ac)) / 2a` -- catastrophic when `4ac ≪ b²`
func naiveRoot<T: IntervalElement>(_ a: Interval<T>, _ b: Interval<T>, _ c: Interval<T>) -> Interval<T> {
    return (-b + discriminantRoot(a, b, c)) / (T(2) * a)
}
//: The stable root: the same thing times its conjugate -- `2c / (-b − √(b²−4ac))`
func stableRoot<T: IntervalElement>(_ a: Interval<T>, _ b: Interval<T>, _ c: Interval<T>) -> Interval<T> {
    return (T(2) * c) / (-b - discriminantRoot(a, b, c))
}

let a: Interval<Double> = 1.0
let b: Interval<Double> = 1e15
let c: Interval<Double> = 1e14

let x = naiveRoot(a, b, c)
let y = stableRoot(a, b, c)
//: The same root, with very different error bars:
x
y
x.err               // the cancellation, measured
y.err
x.err / y.err       // how many digits went missing, as a ratio
//: The wide one still encloses the tight one -- both are truthful, one is useful:
x.contains(y)
//: [Next](@next)
