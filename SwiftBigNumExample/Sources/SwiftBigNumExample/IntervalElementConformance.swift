//
//  IntervalElementConformance.swift -- BigRat and BigFloat as IntervalElements, so
//  that `Interval<BigRat>` and `Interval<BigFloat>` work.
//
//  `IntervalElement` asks for `RealModule.Real`, `Sendable`,
//  `ExpressibleByFloatLiteral`, and `CustomDebugStringConvertible`.  BigNum's types
//  bring the last three with them, and its own `Real` declares the same requirement
//  set as swift-numerics' -- deliberately, so that the library needs no dependency.
//  Which leaves nothing to write:
//
import BigNum
import Interval
import RealModule

extension BigRat: @retroactive RealModule.Real {}
extension BigRat: @retroactive IntervalElement {}

extension BigFloat: @retroactive RealModule.Real {}
extension BigFloat: @retroactive IntervalElement {}
