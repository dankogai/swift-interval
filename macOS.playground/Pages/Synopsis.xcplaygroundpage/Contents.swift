//: Playground - noun: a place where people can play

import Interval

let i1 = Interval(1.0)
i1 + i1
i1 - i1
i1 * i1
i1 / i1

Interval(min:0.0, max:1.0).reciprocal
Interval.exp(Interval(1.0))

1.0±0.125

func det<T:IntervalElement>(a:Interval<T>, b:Interval<T>, c:Interval<T>)->Interval<T> {
    return Interval<T>.sqrt(b*b - T(4)*a*c)
}

//: cf http://verifiedby.me/adiary/070

let a = Interval(1.0)
let b = Interval(1e15)
let c = Interval(1e14)
let x = (-b + det(a:a,b:b,c:c)) / (2.0 * a)
let y = (2.0 * c) / (-b - det(a:a,b:b,c:c))

//: [Previous](@previous)
