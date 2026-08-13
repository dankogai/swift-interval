//
//  IntervalElementConformance.swift -- BigRat and BigFloat as IntervalElements,
//  so that `Interval<BigRat>` and `Interval<BigFloat>` work.
//
//  `IntervalElement`'s function requirements share their names and signatures
//  with swift-numerics' `RealModule.Real`, and BigNum's own `Real` declares that
//  same requirement set too -- three libraries agreeing on a vocabulary so that
//  none of them has to depend on another.  BigNum's types already carry every
//  witness, plus the `Sendable`, `ExpressibleByFloatLiteral`, and
//  `CustomDebugStringConvertible` that `IntervalElement` also asks for.  Which
//  leaves nothing to write:
//
import BigNum
import Interval

extension BigRat: @retroactive IntervalElement {}
extension BigFloat: @retroactive IntervalElement {}
