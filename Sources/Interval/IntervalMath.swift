/// The same math, lifted from elements to intervals.
///
/// Not a protocol conformance -- the module has no math protocol to conform to,
/// on purpose.  These are the members themselves, under `RealModule.Real`'s
/// names; a consumer that imports swift-numerics can point at them with an empty
/// `extension Interval: @retroactive Real {}` if it wants one.
extension Interval {
    // monotonic functions are easy
    public static func sqrt(_ x:Self)->Self {
        return Self(Element.sqrt(x.min), Element.sqrt(x.max))
    }
//    public static func cbrt(_ x:Interval)->Interval {
//        return Interval(Element.cbrt(x.min), Element.cbrt(x.max))
//    }
    public static func exp(_ x:Self)->Self {
        return Self(Element.exp(x.min), Element.exp(x.max))
    }
    public static func exp2(_ x: Interval<F>) -> Interval<F> {
        return Self(Element.exp2(x.min), Element.exp2(x.max))
    }
    public static func expMinusOne(_ x:Self)->Self {
        return Self(Element.expMinusOne(x.min), Element.expMinusOne(x.max))
    }
    public static func log(_ x:Interval)->Interval {
        return Self(Element.log(x.min), Element.log(x.max))
    }
    public static func log2(_ x:Self)->Self {
        return Self(Element.log2(x.min), Element.log2(x.max))
    }
    public static func log10(_ x:Self)->Self {
        return Self(Element.log10(x.min), Element.log10(x.max))
    }
    public static func log(onePlus x:Self)->Self {
        return Self(Element.log(onePlus:x.min), Element.log(onePlus:x.max))
    }
    public static func sinh(_ x:Self)->Self {
        return Self(Element.sinh(x.min), Element.sinh(x.max))
    }
    public static func tanh(_ x:Self)->Self {
        return Self(Element.tanh(x.min), Element.tanh(x.max))
    }
    public static func acos(_ x:Self)->Self {
        return Self(Element.acos(x.min), Element.acos(x.max))
    }
    public static func asin(_ x:Self)->Self {
        return Self(Element.asin(x.min), Element.asin(x.max))
    }
    public static func atan(_ x:Self)->Self {
        return Self(Element.atan(x.min), Element.atan(x.max))
    }
    public static func acosh(_ x:Self)->Self {
        return Self(Element.acosh(x.min), Element.acosh(x.max))
    }
    public static func asinh(_ x:Self)->Self {
        return Self(Element.asinh(x.min), Element.asinh(x.max))
    }
    public static func atanh(_ x:Self)->Self {
        return Self(Element.atanh(x.min), Element.atanh(x.max))
    }
    // cosh : critical at 0
    public static func cosh(_ x:Self)->Self {
        var values = [x.min, x.max].map{ Element.cosh($0) }
        if x.contains(0.0) { values.append(+1.0) }
        values.sort()
        return Self(min:values.first!, max:values.last!)
    }
    // for trigonometrics
    /// Shift by a whole number of periods so the midpoint lands in [-π, +π].
    /// The shift is `n` times an *enclosure* of 2π, so the result honestly
    /// carries the uncertainty of range-reducing with an inexact π; the width
    /// is otherwise preserved.  For width < 2π the result lies within (-2π, 2π),
    /// which is what the critical-value checks in sin/cos/tan below assume.
    public static func normalizeAngle(_ x:Self)->Self {
        if Self(min:-Element.pi, max:+Element.pi).contains(x) { return x }
        let n = (x.mid / (2 * Element.pi)).rounded(.toNearestOrEven)
        return x - Self(min:n, max:n) * (Self.pi + Self.pi)
    }
    // cos - within (-2π, 2π): maxima (+1) only at 0, minima (-1) at ±π
    public static func cos(_ x:Self)->Self {
        if x.isNaN { return nan }
        if 2*Element.pi <= x.max - x.min {
            return Self(min:-1, max:+1)
        }
        let nx = normalizeAngle(x)
        var values = [Element.cos(nx.min), Element.cos(nx.max)]
        if nx.contains(0)                                       { values.append(+1.0) }
        if nx.contains(+Element.pi) || nx.contains(-Element.pi) { values.append(-1.0) }
        values.sort()
        return Self(min:values.first!, max:values.last!)
    }
    // sin - within (-2π, 2π): maxima (+1) at +π/2 and -3π/2, minima (-1) at -π/2 and +3π/2
    public static func sin(_ x:Self)->Self {
        if x.isNaN { return nan }
        if 2*Element.pi <= x.max - x.min {
            return Self(min:-1, max:+1)
        }
        let nx = normalizeAngle(x)
        var values = [Element.sin(nx.min), Element.sin(nx.max)]
        if nx.contains(+Element.pi/2) || nx.contains(-3*Element.pi/2) { values.append(+1.0) }
        if nx.contains(-Element.pi/2) || nx.contains(+3*Element.pi/2) { values.append(-1.0) }
        values.sort()
        return Self(min:values.first!, max:values.last!)
    }
    // tan - unbounded across its poles at odd multiples of π/2, monotone between them
    public static func tan(_ x:Self)->Self {
        if x.isNaN { return nan }
        if Element.pi <= x.max - x.min {
            return Self(min:-Element.infinity, max:+Element.infinity)
        }
        let nx = normalizeAngle(x)
        for pole in [Element.pi/2, -Element.pi/2, 3*Element.pi/2, -3*Element.pi/2] {
            if nx.contains(pole) {
                return Self(min:-Element.infinity, max:+Element.infinity)
            }
        }
        var values = [Element.tan(nx.min), Element.tan(nx.max)]
        values.sort()
        return Self(min:values.first!, max:values.last!)
    }
    // binary functions
    /// atan2
    public static func atan2(y:Self, x:Self)->Self  {
        // cf. https://en.wikipedia.org/wiki/Atan2
        //     https://www.freebsd.org/cgi/man.cgi?query=atan2
        if x.isNaN || y.isNaN { return nan }
        let ysgn  = Self(y.sign == .minus ? -1 : +1)
        let xsgn  = Self(x.sign == .minus ? -1 : +1)
        let y_x   = x.isInfinite && y.isInfinite ? ysgn * xsgn : y/x // avoid nan for ±inf/±inf
        if 0 < x {
            return atan(y_x)
        }
        if x < 0 {
            return ysgn * (Self.pi - atan(Swift.abs(y_x)))
        }
        else {  // x.isZero
            return ysgn * (
                y.isZero ? (x.sign == .minus ? Self.pi : 0) : Self.pi/2
            )
        }
    }
    public static func hypot(_ x:Self, _ y:Self)->Self {
        let v00 = Element.hypot(x.min, y.min)
        let v01 = Element.hypot(x.min, y.max)
        let v10 = Element.hypot(x.max, y.min)
        let v11 = Element.hypot(x.max, y.max)
        return Self(min:Swift.min(v00, v01, v10, v11), max:Swift.max(v00, v01, v10, v11))
    }
    public static func pow(_ x:Self, _ y:Self)->Self {
        let v00 = Element.pow(x.min, y.min)
        let v01 = Element.pow(x.min, y.max)
        let v10 = Element.pow(x.max, y.min)
        let v11 = Element.pow(x.max, y.max)
        return Self(min:Swift.min(v00, v01, v10, v11), max:Swift.max(v00, v01, v10, v11))
    }
    public static func pow(_ x: Interval<F>, _ n: Int) -> Interval<F> {
        let v00 = Element.pow(x.min, n)
        let v10 = Element.pow(x.max, n)
        return Self(min:Swift.min(v00, v10), max:Swift.max(v00, v10))
    }
    public static func root(_ x: Interval<F>, _ n: Int) -> Interval<F> {
        return Self(Element.root(x.min, n), Element.root(x.max, n))
    }
    // erf - strictly increasing
    public static func erf(_ x: Self) -> Self {
        return Self(min:Element.erf(x.min), max:Element.erf(x.max))
    }
    // erfc - strictly decreasing
    public static func erfc(_ x: Self) -> Self {
        return Self(min:Element.erfc(x.max), max:Element.erfc(x.min))
    }
    /// Where the digamma function vanishes: gamma's one critical point on the
    /// positive axis, a minimum.  Built from integers so it exists for every
    /// Element; the last-digit error only moves the evaluation *along* the
    /// curve's flat bottom, so the critical value it yields is second-order
    /// accurate.
    private static var gammaMinimumX:Element {
        return Element(1461632144968362) / Element(1000000000000000)
    }
    // gamma - on x > 0, unimodal with its minimum at gammaMinimumX; for x <= 0,
    // computed through the reflection formula Γ(x) = π / (sin(πx)·Γ(1-x)),
    // where an interval containing a pole picks up sin ∋ 0 and widens to the
    // whole line by itself
    public static func gamma(_ x: Self) -> Self {
        if x.isNaN { return nan }
        if Element(0) < x.min {
            var values = [Element.gamma(x.min), Element.gamma(x.max)]
            if x.contains(gammaMinimumX) { values.append(Element.gamma(gammaMinimumX)) }
            values.sort()
            return Self(min:values.first!, max:values.last!)
        }
        if Element(0) < x.max {  // straddles the pole at 0: ±∞ on its two sides
            return Self(min:-Element.infinity, max:+Element.infinity)
        }
        return Self.pi / (sin(Self.pi * x) * gamma(Self(min:1, max:1) - x))
    }
    // logGamma - log(|Γ(x)|), same shape: unimodal on x > 0, reflected below,
    // log(π) - log|sin(πx)| - logΓ(1-x), with |sin| ∋ 0 turning into the +∞
    // upper bound at the poles
    public static func logGamma(_ x: Self) -> Self {
        if x.isNaN { return nan }
        if Element(0) < x.min {
            var values = [Element.logGamma(x.min), Element.logGamma(x.max)]
            if x.contains(gammaMinimumX) { values.append(Element.logGamma(gammaMinimumX)) }
            values.sort()
            return Self(min:values.first!, max:values.last!)
        }
        if Element(0) < x.max {  // straddles 0: the hull of the two sides
            let neg = logGamma(Self(min:x.min, max:0))
            let pos = logGamma(Self(min:Element.leastNonzeroMagnitude, max:x.max))
            return Self(min:Swift.min(neg.min, pos.min), max:Swift.max(neg.max, pos.max))
        }
        let s = sin(Self.pi * x)
        let absSin = Self(
            min: s.contains(0) ? Element(0) : Swift.min(Swift.abs(s.min), Swift.abs(s.max)),
            max: Swift.max(Swift.abs(s.min), Swift.abs(s.max))
        )
        return log(Self.pi) - log(absSin) - logGamma(Self(min:1, max:1) - x)
    }
}
