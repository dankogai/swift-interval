//
//  interval.swift
//  interval
//
//  Created by Dan Kogai on 1/26/16.
//  Copyright © 2016 Dan Kogai. All rights reserved.
//
#if os(Linux)
    import Glibc
#else
    import Foundation
#endif

public protocol ArithmeticBound : Equatable, Comparable, AbsoluteValuable, FloatingPointType {
    // Initializers (predefined)
    init(_: Double)
    init(_: Float)
    init(_: Self)
    // Operators (predefined)
    prefix func + (_: Self)->Self
    prefix func - (_: Self)->Self
    func + (_: Self, _: Self)->Self
    func - (_: Self, _: Self)->Self
    func * (_: Self, _: Self)->Self
    func / (_: Self, _: Self)->Self
    func % (_: Self, _: Self)->Self
    // used by init() with default epsilon
    static var EPSILON:Self { get }
}

extension Double : ArithmeticBound {
    public static var EPSILON:Double = 0x1p-52
}

extension Float : ArithmeticBound {
    public static var EPSILON:Float = 0x1p-23
}

public extension ClosedInterval where Bound:ArithmeticBound {
    public var lo:Bound { return start }
    public var hi:Bound { return end   }
    public var mid:Bound {
        return (start + end) / Bound(2)
    }
    public var margin:Bound {
        return Bound.abs(start - end) / Bound(2)
    }
    public var epsilon:Bound {
        return Bound.abs(margin/mid)
    }
}
public func interval<T:ArithmeticBound>(lo lo:T, hi:T)->ClosedInterval<T> {
    return lo < hi ? ClosedInterval(lo, hi) : ClosedInterval(hi, lo)
}
public func interval<T:ArithmeticBound>(mid:T, margin:T)->ClosedInterval<T> {
    return ClosedInterval(mid-margin, mid+margin)
}
public func interval<T:ArithmeticBound>(x:T, epsilon:T)->ClosedInterval<T> {
    if x == T(0) {
        return ClosedInterval(x-epsilon,x+epsilon)
    } else {
        let margin = epsilon * x
        return ClosedInterval(
            x.isSignMinus ? x + margin : x - margin,
            x.isSignMinus ? x - margin : x + margin
        )
    }
}
public func interval<T:ArithmeticBound>(x:T)->ClosedInterval<T> {
    return interval(x, epsilon:T.EPSILON)
}
public prefix func + <T:ArithmeticBound>(x:ClosedInterval<T>)->ClosedInterval<T> {
    return x
}
public prefix func - <T:ArithmeticBound>(x:ClosedInterval<T>)->ClosedInterval<T> {
    return interval(lo:-x.hi, hi:-x.lo)
}
public func + <T:ArithmeticBound>(lhs:ClosedInterval<T>, rhs:ClosedInterval<T>)->ClosedInterval<T> {
    return interval(lo:lhs.lo + rhs.lo, hi:lhs.hi + rhs.hi)
}
public func - <T:ArithmeticBound>(lhs:ClosedInterval<T>, rhs:ClosedInterval<T>)->ClosedInterval<T> {
    return interval(lo:lhs.lo - rhs.hi, hi:lhs.hi - rhs.lo)
}
public func * <T:ArithmeticBound>(lhs:ClosedInterval<T>, rhs:ClosedInterval<T>)->ClosedInterval<T> {
    let ll = lhs.lo * rhs.lo
    let lh = lhs.lo * rhs.hi
    let hl = lhs.hi * rhs.lo
    let hh = lhs.hi * rhs.hi
    return interval(lo:min(ll, lh, hl, hh), hi:max(ll, lh, hl, hh))
}
public func * <T:ArithmeticBound>(lhs:ClosedInterval<T>, rhs:T)->ClosedInterval<T> {
    let ll = lhs.lo * rhs
    let lh = lhs.lo * rhs
    let hl = lhs.hi * rhs
    let hh = lhs.hi * rhs
    return interval(lo:min(ll, lh, hl, hh), hi:max(ll, lh, hl, hh))
}
public func * <T:ArithmeticBound>(lhs:T, rhs:ClosedInterval<T>)->ClosedInterval<T> {
    return rhs * lhs
}
public func / <T:ArithmeticBound>(lhs:ClosedInterval<T>, rhs:ClosedInterval<T>)->ClosedInterval<T> {
    guard rhs.lo.isSignMinus == rhs.hi.isSignMinus else {
        return interval(lo:-(T.infinity), hi:+(T.infinity))
    }
    return lhs * interval(lo:T(1)/rhs.hi, hi:T(1)/rhs.lo)
}
public func / <T:ArithmeticBound>(lhs:ClosedInterval<T>, rhs:T)->ClosedInterval<T> {
    return interval(lo:lhs.lo/rhs, hi:lhs.hi/rhs)
}
public func / <T:ArithmeticBound>(lhs:T, rhs:ClosedInterval<T>)->ClosedInterval<T> {
    return interval(lhs, margin:0) / rhs
}
infix operator +- { associativity none precedence 145 }
infix operator ± { associativity none precedence 145 }
public func +- <T:ArithmeticBound>(lhs:T, rhs:T)->ClosedInterval<T> {
    return interval(lhs, margin:rhs)
}
public func ± <T:ArithmeticBound>(lhs:T, rhs:T)->ClosedInterval<T> {
    return interval(lhs, margin:rhs)
}
infix operator =~ { associativity none precedence 130 }
public func =~ <T:ArithmeticBound>(lhs:ClosedInterval<T>, rhs:ClosedInterval<T>)->Bool {
    return (lhs.contains(rhs.lo) && lhs.contains(rhs.hi)) || (rhs.contains(lhs.lo) && rhs.contains(lhs.hi))
}
public func =~ <T:ArithmeticBound>(lhs:ClosedInterval<T>, rhs:T)->Bool {
    return lhs.contains(rhs)
}
public func =~ <T:ArithmeticBound>(lhs:T, rhs:ClosedInterval<T>)->Bool {
    return rhs.contains(lhs)
}
infix operator !~ { associativity none precedence 130 }
public func !~ <T:ArithmeticBound>(lhs:ClosedInterval<T>, rhs:ClosedInterval<T>)->Bool {
    return  !(lhs =~ rhs)
}
public func !~ <T:ArithmeticBound>(lhs:ClosedInterval<T>, rhs:T)->Bool {
    return  !(lhs =~ rhs)
}
public func !~ <T:ArithmeticBound>(lhs:T, rhs:ClosedInterval<T>)->Bool {
    return  !(lhs =~ rhs)
}

extension ArithmeticBound {
    /// Default type to store Intervaluable
    public typealias DefaultType = Double
    public init<U:ArithmeticBound>(_ x:U) {
        switch x {
        case let s as Self:     self.init(s)
        case let d as Double:   self.init(d)
        case let f as Float:    self.init(f)
        default:
            fatalError("init(\(x)) failed")
        }
    }
    //typealias PKG = Foundation
    // math functions - needs extension for each struct
    #if os(Linux)
    public static func exp(x:Self)->    Self { return Self(Glibc.exp(DefaultType(x))) }
    public static func log(x:Self)->    Self { return Self(Glibc.log(DefaultType(x))) }
    public static func sqrt(x:Self)->   Self { return Self(Glibc.sqrt(DefaultType(x))) }
    public static func atan2(y:Self, _ x:Self)->Self { return Self(Glibc.atan2(DefaultType(y), DefaultType(x))) }
    public static func pow(y:Self, _ x:Self)->Self { return Self(Glibc.pow(DefaultType(y), DefaultType(x))) }
    public static func cos(x:Self)->    Self { return Self(Glibc.cos(DefaultType(x))) }
    public static func sin(x:Self)->    Self { return Self(Glibc.sin(DefaultType(x))) }
    public static func tan(x:Self)->    Self { return Self(Glibc.tan(DefaultType(x))) }
    public static func acos(x:Self)->   Self { return Self(Glibc.acos(DefaultType(x))) }
    public static func asin(x:Self)->   Self { return Self(Glibc.asin(DefaultType(x))) }
    public static func atan(x:Self)->   Self { return Self(Glibc.atan(DefaultType(x))) }
    public static func cosh(x:Self)->   Self { return Self(Glibc.cosh(DefaultType(x))) }
    public static func sinh(x:Self)->   Self { return Self(Glibc.sinh(DefaultType(x))) }
    public static func tanh(x:Self)->   Self { return Self(Glibc.tanh(DefaultType(x))) }
    public static func acosh(x:Self)->  Self { return Self(Glibc.acosh(DefaultType(x))) }
    public static func asinh(x:Self)->  Self { return Self(Glibc.asinh(DefaultType(x))) }
    public static func atanh(x:Self)->  Self { return Self(Glibc.atanh(DefaultType(x))) }
    #else
    public static func exp(x:Self)->    Self { return Self(Foundation.exp(DefaultType(x))) }
    public static func log(x:Self)->    Self { return Self(Foundation.log(DefaultType(x))) }
    public static func sqrt(x:Self)->   Self { return Self(Foundation.sqrt(DefaultType(x))) }
    public static func atan2(y:Self, _ x:Self)->Self { return Self(Foundation.atan2(DefaultType(y), DefaultType(x))) }
    public static func pow(y:Self, _ x:Self)->Self { return Self(Foundation.pow(DefaultType(y), DefaultType(x))) }
    public static func cos(x:Self)->    Self { return Self(Foundation.cos(DefaultType(x))) }
    public static func sin(x:Self)->    Self { return Self(Foundation.sin(DefaultType(x))) }
    public static func tan(x:Self)->    Self { return Self(Foundation.tan(DefaultType(x))) }
    public static func acos(x:Self)->   Self { return Self(Foundation.acos(DefaultType(x))) }
    public static func asin(x:Self)->   Self { return Self(Foundation.asin(DefaultType(x))) }
    public static func atan(x:Self)->   Self { return Self(Foundation.atan(DefaultType(x))) }
    public static func cosh(x:Self)->   Self { return Self(Foundation.cosh(DefaultType(x))) }
    public static func sinh(x:Self)->   Self { return Self(Foundation.sinh(DefaultType(x))) }
    public static func tanh(x:Self)->   Self { return Self(Foundation.tanh(DefaultType(x))) }
    public static func acosh(x:Self)->  Self { return Self(Foundation.acosh(DefaultType(x))) }
    public static func asinh(x:Self)->  Self { return Self(Foundation.asinh(DefaultType(x))) }
    public static func atanh(x:Self)->  Self { return Self(Foundation.atanh(DefaultType(x))) }
    #endif
}
/// Converts a [monotonic function] and returns an interval arithmetic version thereof
///
/// [monotonic function]: [monotonic function]
///
/// - parameter f: monotonic function that takes T and returns T
/// - returns: a function that takes Interval<T> and returns Interval<T>
public func convertMonotonicFunc<T:ArithmeticBound>(f:T->T)->(ClosedInterval<T>->ClosedInterval<T>) {
    return { x in
        let l = f(x.lo)
        let h = f(x.hi)
        return interval(lo:min(l, h), hi:max(l, h))
    }
}
/// sqrt is monotonic
public func sqrt<T:ArithmeticBound>(x:ClosedInterval<T>)->ClosedInterval<T> {
    return interval(lo:T.sqrt(x.lo), hi:T.sqrt(x.hi))
}
public func exp<T:ArithmeticBound>(x:ClosedInterval<T>)->ClosedInterval<T> {
    return interval(lo:T.exp(x.lo), hi:T.exp(x.hi))
}
public func log<T:ArithmeticBound>(x:ClosedInterval<T>)->ClosedInterval<T> {
    return interval(lo:T.log(x.lo), hi:T.log(x.hi))
}
// cos - critical at ±π
public func cos<T:ArithmeticBound>(x:ClosedInterval<T>)->ClosedInterval<T> {
    guard x.margin < T(M_PI) else {
        return interval(lo:T(-1.0), hi:T(+1.0))
    }
    let cl = T.cos(x.lo)
    let ch = T.cos(x.hi)
    let t = interval(T.atan2(T.cos(x.mid), T.sin(x.mid)), margin:x.margin) // normalize
    if t =~ T(0.0) {
        return interval(lo:min(cl, ch), hi:T(+1.0))
    }
    else if t =~ T(-M_PI) {
        return interval(lo:T(-1.0), hi:max(cl, ch))
    }
    return interval(lo:cl, hi:ch)
}
// sin - critical at ±π/2
public func sin<T:ArithmeticBound>(x:ClosedInterval<T>)->ClosedInterval<T> {
    guard x.margin < T(M_PI) else {
        return interval(lo:T(-1.0), hi:T(+1.0))
    }
    let sl = T.sin(x.lo)
    let sh = T.sin(x.hi)
    let t = interval(T.atan2(T.cos(x.mid), T.sin(x.mid)), margin:x.margin) // normalize
    if t =~ T(+M_PI_2) {
        return interval(lo:min(sl, sh), hi:T(+1.0))
    }
    else if t =~ T(-M_PI_2) {
        return interval(lo:T(-1.0), hi:max(sl, sh))
    }
    return interval(lo:sl, hi:sh)
}
public func tan<T:ArithmeticBound>(x:ClosedInterval<T>)->ClosedInterval<T> {
    return sin(x) / cos(x)
}
// acos - monotonic
public func acos<T:ArithmeticBound>(x:ClosedInterval<T>)->ClosedInterval<T> {
    return interval(lo:T.acos(x.hi), hi:T.acos(x.lo))
}
// asin - monotonic
public func asin<T:ArithmeticBound>(x:ClosedInterval<T>)->ClosedInterval<T> {
    return interval(lo:T.asin(x.lo), hi:T.asin(x.hi))
}
// atan - monotonic
public func atan<T:ArithmeticBound>(x:ClosedInterval<T>)->ClosedInterval<T> {
    return interval(lo:T.atan(x.lo), hi:T.atan(x.hi))
}
// cosh
public func cosh<T:ArithmeticBound>(x:ClosedInterval<T>)->ClosedInterval<T> {
    return (exp(x) + exp(-x))/2
}
// sinh - monotonic
public func sinh<T:ArithmeticBound>(x:ClosedInterval<T>)->ClosedInterval<T> {
    return interval(lo:T.sinh(x.lo), hi:T.sinh(x.hi))
}
// tanh - monotonic
public func tanh<T:ArithmeticBound>(x:ClosedInterval<T>)->ClosedInterval<T> {
    return interval(lo:T.tanh(x.lo), hi:T.tanh(x.hi))
}
// acosh - monotonic
public func acosh<T:ArithmeticBound>(x:ClosedInterval<T>)->ClosedInterval<T> {
    return interval(lo:T.acosh(x.hi), hi:T.acosh(x.lo))
}
// asinh - monotonic
public func asinh<T:ArithmeticBound>(x:ClosedInterval<T>)->ClosedInterval<T> {
    return interval(lo:T.asinh(x.lo), hi:T.asinh(x.hi))
}
// atanh - monotonic
public func atanh<T:ArithmeticBound>(x:ClosedInterval<T>)->ClosedInterval<T> {
    return interval(lo:T.atanh(x.lo), hi:T.atanh(x.hi))
}


