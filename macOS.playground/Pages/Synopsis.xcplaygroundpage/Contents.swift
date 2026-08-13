/*:
 # Interval

 [Interval arithmetic] in Swift: a value is not a number but a closed range
 `[min, max]`, and every operation returns a range enclosing every answer the
 inputs could have meant.

 [Interval arithmetic]: https://en.wikipedia.org/wiki/Interval_arithmetic

 To run this, open the swift-interval package folder in Xcode and let it
 resolve; the playground can then `import Interval`.
 */
import Interval

//: ## Construction
let about1 = 1.0 ± 0.1          // mid ± err  (type ± as ⌥+shift+=)
about1.min
about1.max
about1.mid
about1.err
Interval(3.0, 2.0)              // two endpoints, either order
Interval(min: 2.0, max: 3.0)
Interval(1.0..<2.0)             // from a Range
Interval(1.0 as Double)         // one value, padded ± its ulp -- the honest Double
42 as Interval<Double>          // literals work too
3.14 as Interval<Double>

//: ## Arithmetic -- each result encloses every possible answer
about1 + about1
about1 - about1                 // not zero: the two occurrences are independent
about1 * about1
about1 / about1                 // not one, for the same reason

//: ## Comparison is containment
about1 == 1.05                  // `==` against a scalar means "contains"
1.05 == about1
about1.contains(1.05)
about1 == 1.2                   // outside
about1 < 1.2                    // wholly below
about1 === 1.0 ± 0.1            // `===` means identical endpoints

//: ## Functions, elementwise over the enclosure
Interval.sqrt(about1)
Interval.exp(about1)
Interval.log(Interval.exp(about1))     // round trip: back to ≈[0.9, 1.1]
Interval.pow(about1, 2)
Interval.hypot(3.0 ± 0.1, 4.0 ± 0.1)

//: ## Special values behave like FloatingPoint
Interval<Double>.pi
Interval(min: 0.0, max: 1.0).reciprocal   // dividing by a zero-touching interval
Interval(min: -1.0, max: 1.0).reciprocal  // zero inside: the whole line
Interval<Double>.nan.isNaN

//: ## Two descriptions
about1.description              // mid±err
about1.debugDescription         // (min...max)
//: [Next](@next)
