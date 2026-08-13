//: [Previous](@previous)
/*:
 # Error Propagation, without the calculus

 Measure gravity with a pendulum: time the period `T`, measure the length `L`,
 and `g = 4π²L/T²`.  The classical treatment propagates the measurement
 uncertainties by partial derivatives; intervals just compute -- put the error
 bars *in* the numbers and do the arithmetic.
 */
import Interval

let L = 0.2484 ± 0.0005     // metres, read off a ruler
let T = 1.000 ± 0.005       // seconds, a stopwatch and shaky thumbs

let piSquared = Interval<Double>.pi * Interval<Double>.pi
let g = 4.0 * piSquared * L / (T * T)
g
g.mid
g.err                       // ±: about 1.2% -- dominated by T, which enters squared
//: Standard gravity is inside the bars, so the experiment is honest:
g == 9.80665
/*:
 Buy a better stopwatch and the bars tighten fourfold; the ruler, hardly worth
 upgrading:
 */
let betterT = 1.0000 ± 0.0005
let betterG = 4.0 * piSquared * L / (betterT * betterT)
betterG.err
betterG == 9.80665
/*:
 One caveat worth knowing: `T * T` treats the two occurrences as independent --
 the *dependency problem*, the price interval arithmetic pays for its
 guarantee.  Here the interval is narrow and the widening is negligible;
 `Interval.pow(T, 2)` computes the same bounds either way.
 */
Interval.pow(T, 2) === T * T
//: [Next](@next)
