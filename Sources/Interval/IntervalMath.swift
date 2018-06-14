extension Interval {
    // monotonic functions are easy
    public static func sqrt(_ x:Interval)->Interval {
        return Interval(Element.sqrt(x.min), Element.sqrt(x.max))
    }
    public static func cbrt(_ x:Interval)->Interval {
        return Interval(Element.cbrt(x.min), Element.cbrt(x.max))
    }
    public static func exp(_ x:Interval)->Interval {
        return Interval(Element.exp(x.min), Element.exp(x.max))
    }
    public static func expm1(_ x:Interval)->Interval {
        return Interval(Element.expm1(x.min), Element.expm1(x.max))
    }
    public static func log(_ x:Interval)->Interval {
        return Interval(Element.log(x.min), Element.log(x.max))
    }
    public static func log2(_ x:Interval)->Interval {
        return Interval(Element.log2(x.min), Element.log2(x.max))
    }
    public static func log10(_ x:Interval)->Interval {
        return Interval(Element.log10(x.min), Element.log10(x.max))
    }
    public static func log1p(_ x:Interval)->Interval {
        return Interval(Element.log1p(x.min), Element.log1p(x.max))
    }
    public static func sinh(_ x:Interval)->Interval {
        return Interval(Element.sinh(x.min), Element.sinh(x.max))
    }
    public static func tanh(_ x:Interval)->Interval {
        return Interval(Element.tanh(x.min), Element.tanh(x.max))
    }
    public static func acos(_ x:Interval)->Interval {
        return Interval(Element.acos(x.min), Element.acos(x.max))
    }
    public static func asin(_ x:Interval)->Interval {
        return Interval(Element.asin(x.min), Element.asin(x.max))
    }
    public static func atan(_ x:Interval)->Interval {
        return Interval(Element.atan(x.min), Element.atan(x.max))
    }
    public static func acosh(_ x:Interval)->Interval {
        return Interval(Element.acosh(x.min), Element.acosh(x.max))
    }
    public static func asinh(_ x:Interval)->Interval {
        return Interval(Element.asinh(x.min), Element.asinh(x.max))
    }
    public static func atanh(_ x:Interval)->Interval {
        return Interval(Element.atanh(x.min), Element.atanh(x.max))
    }
    public static func hypot(_ x:Interval, _ y:Interval)->Interval {
        let v00 = Element.hypot(x.min, y.min)
        let v01 = Element.hypot(x.min, y.max)
        let v10 = Element.hypot(x.max, y.min)
        let v11 = Element.hypot(x.max, y.max)
        return Interval(min:Swift.min(v00, v01, v10, v11), max:Swift.max(v00, v01, v10, v11))
    }
    public static func pow(_ x:Interval, _ y:Interval)->Interval {
        let v00 = Element.pow(x.min, y.min)
        let v01 = Element.pow(x.min, y.max)
        let v10 = Element.pow(x.max, y.min)
        let v11 = Element.pow(x.max, y.max)
        return Interval(min:Swift.min(v00, v01, v10, v11), max:Swift.max(v00, v01, v10, v11))
    }
    // cosh : critical at 0
    public static func cosh(_ x:Interval)->Interval {
        var values = [x.min, x.max].map{ Element.cosh($0) }
        if x.contains(0.0) { values.append(+1.0) }
        values.sort()
        return Interval(min:values.first!, max:values.last!)
    }
    // for cos and sin
    public static func normalizeAngle(_ x:Interval)->Interval {
        if -Interval.pi <= x && x <= +Interval.pi { return x }
        let r = x.remainder(dividingBy: 2*Interval.pi)
        return r + (r < -Interval.pi ? +2 : +Interval.pi < r ? -2 : 0)*Element.pi
    }
    // cos - critical at 0, ±π
    public static func cos(_ x:Interval)->Interval {
        if 2*Element.pi <= x.max - x.min {
            return Interval(min:-1, max:+1)
        }
        let nx = normalizeAngle(x)
        var values = [nx.min, nx.max]
        if x.contains(0)     { values.append(+1.0) }
        if x.contains(+Element.pi) { values.append(+1.0) }
        if x.contains(-Element.pi) { values.append(-1.0) }
        return Interval(min:values.first!, max:values.last!)
    }
    // sin - critical at ±π/2
    public static func sin(_ x:Interval)->Interval {
        if 2*Element.pi <= x.max - x.min {
            return Interval(min:-1, max:+1)
        }
        let nx = normalizeAngle(x)
        var values = [nx.min, nx.max]
        if x.contains(+Element.pi/2) { values.append(+1.0) }
        if x.contains(-Element.pi/2) { values.append(-1.0) }
        return Interval(min:values.first!, max:values.last!)
    }
    //    public static func atan2(_ x:Interval, _ y:Interval)->Interval {
    //        let v00 = Element.atan2(x.min, y.min)
    //        let v01 = Element.atan2(x.min, y.max)
    //        let v10 = Element.atan2(x.max, y.min)
    //        let v11 = Element.atan2(x.max, y.max)
    //        return Interval(min:Swift.min(v00, v01, v10, v11), max:Swift.max(v00, v01, v10, v11))
    //    }

}
