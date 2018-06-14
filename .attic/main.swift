//
//  main.swift
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
let test = TAP()
//
test.eq(interval(1.0).lo, 1-Double.EPSILON,     "interval(1.0).lo == \(1-Double.EPSILON)")
test.eq(interval(1.0).hi, 1+Double.EPSILON,     "interval(1.0).hi == \(1+Double.EPSILON)")
test.eq((-interval(1.0)).lo, -1-Double.EPSILON, "-interval(1.0).lo == \(-1-Double.EPSILON)")
test.eq((-interval(1.0)).hi, -1+Double.EPSILON, "-interval(1.0).hi == \(-1+Double.EPSILON)")
test.eq(-interval(1.0), interval(-1.0), "-interval(1.0) == interval(-1.0)")
test.eq(interval(1.0)+interval(1.0), interval(2.0), "interval(1.0)+interval(1.0) == interval(2.0)")
test.ne(interval(1.0)-interval(1.0), interval(0.0), "interval(1.0)-interval(1.0) != interval(0.0)")
test.eq(interval(1.0)-interval(1.0), interval(0.0, margin:2*Double.EPSILON),
    "interval(1.0)-interval(1.0) == \(interval(0.0, margin:2*Double.EPSILON))")
test.ne(interval(1.0)*interval(1.0), interval(0.0), "interval(1.0)*interval(1.0) != interval(0.0)")
test.eq(interval(1.0)*interval(1.0), interval(1.0, margin:2*Double.EPSILON),
    "interval(1.0)*interval(1.0) == \(interval(1.0, margin:2*Double.EPSILON))")
test.ne(interval(1.0)/interval(1.0), interval(0.0), "interval(1.0)/interval(1.0) != interval(0.0)")
test.eq(interval(1.0)/interval(1.0), interval(1.0, margin:2*Double.EPSILON),
    "interval(1.0)/interval(1.0) == \(interval(1.0, margin:2*Double.EPSILON))")
test.eq(interval(1.0)/interval(0.0), interval(lo:-Double.infinity, hi:+Double.infinity),
    "interval(1.0)/interval(0.0) == \(interval(lo:-Double.infinity, hi:+Double.infinity))")
test.ok(1.0+-0.1 =~ 1.0±0.1, "1.0+-0.1 =~ 1.0±0.1")
test.ok(1.0+-0.2 =~ 1.0±0.1, "1.0+-0.2 =~ 1.0±0.1")
test.ok(1.0+-0.1 =~ 0.95±0.04, "\(1.0+-0.1) =~ \(0.95±0.04)")
//
test.ok(cos(interval(0.0)) =~       +1.0,   "\(cos(interval(0.0)) =~ +1.0)")
test.ok(cos(interval(M_PI_2)) =~    +0.0,   "\(cos(interval(M_PI_2)) =~ 0.0)")
test.ok(cos(interval(M_PI)) =~      -1.0,   "\(cos(interval(M_PI)) =~ -1.0)")
test.ok(cos(interval(3*M_PI_2)) =~  +0.0,   "\(cos(interval(3*M_PI_2)) =~ 0.0)")
test.ok(sin(interval(0.0)) =~       +0.0,   "\(sin(interval(0.0)) =~ 0.0)")
test.ok(sin(interval(M_PI_2) ) =~   +1.0,   "\(sin(interval(M_PI_2)) =~ +1.0)")
test.ok(sin(interval(M_PI)) =~      +0.0,   "\(sin(interval(M_PI)) =~ 0.0)")
test.ok(sin(interval(3*M_PI_2)) =~  -1.0,   "\(sin(interval(3*M_PI_2)) =~ -1.0)")
//
test.ok(sqrt(interval(2.0) * interval(2.0)) =~ 2.0,     "sqrt(interval(2.0) ** 2) =~ 2.0")
test.ok(sqrt(interval(2.0))*sqrt(interval(2.0)) =~ 2.0, "sqrt(interval(2.0))**2 =~ 2.0")
test.ok(log(exp(interval(1.0))) =~ 1.0,     "log(exp(interval(1.0))) =~ 1.0")
test.ok(exp(log(interval(1.0))) =~ 1.0,     "exp(log(interval(1.0))) =~ 1.0")
test.ok(acos(cos(interval(0.5))) =~ 0.5,    "acos(cos(interval(0.5)))")
test.ok(cos(acos(interval(0.5))) =~ 0.5,    "cos(acos(interval(0.5)))")
test.ok(asin(sin(interval(0.5))) =~ 0.5,    "asin(sin(interval(0.5)))")
test.ok(sin(asin(interval(0.5))) =~ 0.5,    "sin(asin(interval(0.5)))")
test.ok(atan(tan(interval(0.5))) =~ 0.5,    "atan(tan(interval(0.5)))")
test.ok(tan(atan(interval(0.5))) =~ 0.5,    "tan(atan(interval(0.5)))")
test.ok(acos(cos(interval(0.5))) =~ 0.5,    "acos(cos(interval(0.5)))")
test.ok(cos(acos(interval(0.5))) =~ 0.5,    "cos(acos(interval(0.5)))")
test.ok(asin(sin(interval(0.5))) =~ 0.5,    "asin(sin(interval(0.5)))")
test.ok(sin(asin(interval(0.5))) =~ 0.5,    "sin(asin(interval(0.5)))")
test.ok(atan(tan(interval(0.5))) =~ 0.5,    "atan(tan(interval(0.5)))")
test.ok(tan(atan(interval(0.5))) =~ 0.5,    "tan(atan(interval(0.5)))")
test.ok(acosh(cosh(interval(1.5))) =~ 1.5,  "acosh(cosh(interval(1.5)))")
test.ok(cosh(acosh(interval(1.5))) =~ 1.5,  "cosh(acosh(interval(1.5)))")
test.ok(asinh(sinh(interval(0.5))) =~ 0.5,  "asinh(sinh(interval(0.5)))")
test.ok(sinh(asinh(interval(0.5))) =~ 0.5,  "sinh(asinh(interval(0.5)))")
test.ok(atanh(tanh(interval(0.5))) =~ 0.5,  "atanh(tanh(interval(0.5)))")
test.ok(tanh(atanh(interval(0.5))) =~ 0.5,  "tanh(atanh(interval(0.5)))")
test.done()
