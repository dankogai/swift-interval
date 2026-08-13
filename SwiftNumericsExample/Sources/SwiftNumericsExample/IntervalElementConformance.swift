//
//  IntervalElementConformance.swift -- Float as an IntervalElement, and Interval
//  as a RealModule.Real, in three empty extensions.
//
//  `IntervalElement`'s function requirements share their names and signatures
//  with `RealModule.Real`'s, deliberately, and declare no defaults -- so any
//  `Real` already carries every witness and there is nothing to break a tie
//  with.  `Float` gets its members from RealModule; the conformance is the empty
//  extension below.  (`Double`'s lives in swift-interval itself, on libm, which
//  is how the parent needs no dependency.)
//
//  The reverse direction is also one line: `Interval` declares its math under
//  RealModule's names too, so `Interval<F>` *is* a `Real` the moment somebody
//  who imports RealModule says so.
//
import Interval
import RealModule

extension Float: @retroactive IntervalElement {}

extension Interval: @retroactive AlgebraicField {}
extension Interval: @retroactive ElementaryFunctions {}
extension Interval: @retroactive RealFunctions {}
extension Interval: @retroactive Real {}
