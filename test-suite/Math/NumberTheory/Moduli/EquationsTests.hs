-- |
-- Module:      Math.NumberTheory.Moduli.EquationsTests
-- Copyright:   (c) 2018 Andrew Lelechenko
-- Licence:     MIT
-- Maintainer:  Andrew Lelechenko <andrew.lelechenko@gmail.com>
-- Stability:   Provisional
-- Portability: Non-portable (GHC extensions)
--

{-# LANGUAGE ScopedTypeVariables        #-}

module Math.NumberTheory.Moduli.EquationsTests
  ( testSuite
  ) where

import Test.Tasty

import Data.Proxy
import GHC.TypeNats.Compat
import Numeric.Natural

import Math.NumberTheory.Moduli.Class
import Math.NumberTheory.Moduli.Equations
import Math.NumberTheory.TestUtils

solveLinearProp :: KnownNat m => Mod m -> Mod m -> Bool
solveLinearProp a b = solveLinear a b ==
  filter (\x -> a * x + b == 0) [minBound .. maxBound]

solveLinearProperty1 :: Positive Natural -> Integer -> Integer -> Bool
solveLinearProperty1 (Positive m) a b = case someNatVal m of
  SomeNat (_ :: Proxy t) -> solveLinearProp (fromInteger a :: Mod t) (fromInteger b)

testSuite :: TestTree
testSuite = testGroup "Equations"
  [ testSmallAndQuick "solveLinear" solveLinearProperty1
  ]
