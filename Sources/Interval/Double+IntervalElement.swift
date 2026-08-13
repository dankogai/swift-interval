//
//  Double+IntervalElement.swift -- the one conformance this module ships with,
//  implemented straight on libm so that the module depends on nothing.
//
//  For other element types, conform them yourself -- see SwiftNumericsExample/
//  (Float, one empty extension via swift-numerics) and SwiftBigNumExample/
//  (BigRat and BigFloat, likewise).
//
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#elseif os(Windows)
import CRT
#endif

// Bound at file scope, where unqualified lookup still means libm's free
// functions -- inside the extension below, `exp(x)` would mean the static member
// being declared, and recurse.
private let c_exp   : @Sendable (Double) -> Double = exp
private let c_exp2  : @Sendable (Double) -> Double = exp2
private let c_expm1 : @Sendable (Double) -> Double = expm1
private let c_log   : @Sendable (Double) -> Double = log
private let c_log2  : @Sendable (Double) -> Double = log2
private let c_log10 : @Sendable (Double) -> Double = log10
private let c_log1p : @Sendable (Double) -> Double = log1p
private let c_sin   : @Sendable (Double) -> Double = sin
private let c_cos   : @Sendable (Double) -> Double = cos
private let c_tan   : @Sendable (Double) -> Double = tan
private let c_asin  : @Sendable (Double) -> Double = asin
private let c_acos  : @Sendable (Double) -> Double = acos
private let c_atan  : @Sendable (Double) -> Double = atan
private let c_sinh  : @Sendable (Double) -> Double = sinh
private let c_cosh  : @Sendable (Double) -> Double = cosh
private let c_tanh  : @Sendable (Double) -> Double = tanh
private let c_asinh : @Sendable (Double) -> Double = asinh
private let c_acosh : @Sendable (Double) -> Double = acosh
private let c_atanh : @Sendable (Double) -> Double = atanh
private let c_hypot : @Sendable (Double, Double) -> Double = hypot
private let c_pow   : @Sendable (Double, Double) -> Double = pow

extension Double: IntervalElement {
    public static func sqrt(_ x: Double) -> Double  { return x.squareRoot() }
    public static func exp(_ x: Double) -> Double   { return c_exp(x) }
    public static func exp2(_ x: Double) -> Double  { return c_exp2(x) }
    public static func expMinusOne(_ x: Double) -> Double { return c_expm1(x) }
    public static func log(_ x: Double) -> Double   { return c_log(x) }
    public static func log2(_ x: Double) -> Double  { return c_log2(x) }
    public static func log10(_ x: Double) -> Double { return c_log10(x) }
    public static func log(onePlus x: Double) -> Double { return c_log1p(x) }
    public static func sin(_ x: Double) -> Double   { return c_sin(x) }
    public static func cos(_ x: Double) -> Double   { return c_cos(x) }
    public static func tan(_ x: Double) -> Double   { return c_tan(x) }
    public static func asin(_ x: Double) -> Double  { return c_asin(x) }
    public static func acos(_ x: Double) -> Double  { return c_acos(x) }
    public static func atan(_ x: Double) -> Double  { return c_atan(x) }
    public static func sinh(_ x: Double) -> Double  { return c_sinh(x) }
    public static func cosh(_ x: Double) -> Double  { return c_cosh(x) }
    public static func tanh(_ x: Double) -> Double  { return c_tanh(x) }
    public static func asinh(_ x: Double) -> Double { return c_asinh(x) }
    public static func acosh(_ x: Double) -> Double { return c_acosh(x) }
    public static func atanh(_ x: Double) -> Double { return c_atanh(x) }
    public static func hypot(_ x: Double, _ y: Double) -> Double { return c_hypot(x, y) }
    public static func pow(_ x: Double, _ y: Double) -> Double   { return c_pow(x, y) }
    /// `x` raised to an integer power -- unlike `pow(x, Double(n))`, defined for
    /// negative `x` too, the way `RealModule` defines it.
    public static func pow(_ x: Double, _ n: Int) -> Double {
        if x < 0 {
            let mag = c_pow(-x, Double(n))
            return n % 2 == 0 ? mag : -mag
        }
        return c_pow(x, Double(n))
    }
    /// The `n`th root, again following `RealModule`: odd roots of negative
    /// numbers are the negative real root, not nan.
    public static func root(_ x: Double, _ n: Int) -> Double {
        if x < 0 {
            return n % 2 == 0 ? .nan : -c_pow(-x, 1/Double(n))
        }
        return c_pow(x, 1/Double(n))
    }
}
