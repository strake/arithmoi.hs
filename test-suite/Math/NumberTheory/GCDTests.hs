-- |
-- Module:      Math.NumberTheory.GCDTests
-- Copyright:   (c) 2016 Andrew Lelechenko
-- Licence:     MIT
-- Maintainer:  Andrew Lelechenko <andrew.lelechenko@gmail.com>
-- Stability:   Provisional
--
-- Tests for Math.NumberTheory.GCD
--

{-# LANGUAGE CPP                 #-}
{-# LANGUAGE ScopedTypeVariables #-}

{-# OPTIONS_GHC -fno-warn-type-defaults  #-}
{-# OPTIONS_GHC -fno-warn-unused-imports #-}
{-# OPTIONS_GHC -fno-warn-deprecations   #-}

module Math.NumberTheory.GCDTests
  ( testSuite
  ) where

import Test.Tasty
import Test.Tasty.HUnit

import Control.Arrow
import Data.Bits
import Data.Semigroup
import Data.List (tails)
import Numeric.Natural

import Math.NumberTheory.GCD
import Math.NumberTheory.TestUtils

-- | Check that 'binaryGCD' matches 'gcd'.
binaryGCDProperty :: (Integral a, Bits a) => AnySign a -> AnySign a -> Bool
binaryGCDProperty (AnySign a) (AnySign b) = binaryGCD a b == gcd a b

-- | Check that 'extendedGCD' is consistent with documentation.
extendedGCDProperty :: forall a. Integral a => AnySign a -> AnySign a -> Bool
extendedGCDProperty (AnySign a) (AnySign b) =
  u * a + v * b == d
  && d == gcd a b
  -- (-1) >= 0 is true for unsigned types
  && (abs u < abs b || abs b <= 1 || (-1 :: a) >= 0)
  && (abs v < abs a || abs a <= 1 || (-1 :: a) >= 0)
  where
    (d, u, v) = extendedGCD a b

-- | Check that numbers are coprime iff their gcd equals to 1.
coprimeProperty :: (Integral a, Bits a) => AnySign a -> AnySign a -> Bool
coprimeProperty (AnySign a) (AnySign b) = coprime a b == (gcd a b == 1)

splitIntoCoprimesProperty1 :: [(Positive Natural, Power Word)] -> Bool
splitIntoCoprimesProperty1 fs' = factorback fs == factorback (toList $ splitIntoCoprimes fs)
  where
    fs = map (getPositive *** getPower) fs'
    factorback = product . map (uncurry (^))

splitIntoCoprimesProperty2 :: [(Positive Natural, Power Word)] -> Bool
splitIntoCoprimesProperty2 fs' = multiplicities fs <= multiplicities (toList $ splitIntoCoprimes fs)
  where
    fs = map (getPositive *** getPower) fs'
    multiplicities = sum . map snd . filter ((/= 1) . fst)

splitIntoCoprimesProperty3 :: [(Positive Natural, Power Word)] -> Bool
splitIntoCoprimesProperty3 fs' = and [ coprime x y | (x : xs) <- tails fs, y <- xs ]
  where
    fs = map fst $ toList $ splitIntoCoprimes $ map (getPositive *** getPower) fs'

-- | Check that evaluation never freezes.
splitIntoCoprimesProperty4 :: [(Integer, Word)] -> Bool
splitIntoCoprimesProperty4 fs' = fs == fs
  where
    fs = splitIntoCoprimes fs'

-- | This is an undefined behaviour, but at least it should not
-- throw exceptions or loop forever.
splitIntoCoprimesSpecialCase1 :: Assertion
splitIntoCoprimesSpecialCase1 =
  assertBool "should not fail" $ splitIntoCoprimesProperty4 [(0, 0), (0, 0)]

-- | This is an undefined behaviour, but at least it should not
-- throw exceptions or loop forever.
splitIntoCoprimesSpecialCase2 :: Assertion
splitIntoCoprimesSpecialCase2 =
  assertBool "should not fail" $ splitIntoCoprimesProperty4 [(0, 1), (-2, 0)]

toListReturnsCorrectValues :: Assertion
toListReturnsCorrectValues =
  assertEqual "should be equal" (toList $ splitIntoCoprimes [(140, 1), (165, 1)]) [(5,2),(28,1),(33,1)]

unionReturnsCorrectValues :: Assertion
unionReturnsCorrectValues =
  let a = splitIntoCoprimes [(700, 1), (165, 1)] -- [(5,3),(28,1),(33,1)]
      b = splitIntoCoprimes [(360, 1), (210, 1)] -- [(2,4),(3,3),(5,2),(7,1)]
      expected = [(2,6),(3,4),(5,5),(7,2),(11,1)]
      actual = toList (a <> b)
  in assertEqual "should be equal" expected actual

insertReturnsCorrectValuesWhenCoprimeBase :: Assertion
insertReturnsCorrectValuesWhenCoprimeBase =
  let a = insert 5 2 (singleton 4 3)
      expected = [(4,3), (5,2)]
      actual = toList a :: [(Int, Int)]
  in assertEqual "should be equal" expected actual

insertReturnsCorrectValuesWhenNotCoprimeBase :: Assertion
insertReturnsCorrectValuesWhenNotCoprimeBase =
  let a = insert 2 4 (insert 7 1 (insert 5 2 (singleton 4 3)))
      actual = toList a :: [(Int, Int)]
      expected = [(2,10), (5,2), (7,1)]
  in assertEqual "should be equal" expected actual


testSuite :: TestTree
testSuite = testGroup "GCD"
  [ testSameIntegralProperty "binaryGCD"   binaryGCDProperty
  , testSameIntegralProperty "extendedGCD" extendedGCDProperty
  , testSameIntegralProperty "coprime"     coprimeProperty
  , testGroup "splitIntoCoprimes"
    [ testSmallAndQuick "preserves product of factors"        splitIntoCoprimesProperty1
    , testSmallAndQuick "number of factors is non-decreasing" splitIntoCoprimesProperty2
    , testSmallAndQuick "output factors are coprime"          splitIntoCoprimesProperty3

    , testCase          "does not freeze 1"                   splitIntoCoprimesSpecialCase1
    , testCase          "does not freeze 2"                   splitIntoCoprimesSpecialCase2
    , testSmallAndQuick "does not freeze random"              splitIntoCoprimesProperty4
    ]
  , testGroup "Coprimes"
    [  testCase         "test equality"                       toListReturnsCorrectValues
    ,  testCase         "test union"                          unionReturnsCorrectValues
    ,  testCase         "test insert with coprime base"       insertReturnsCorrectValuesWhenCoprimeBase
    ,  testCase         "test insert with non-coprime base"   insertReturnsCorrectValuesWhenNotCoprimeBase
    ]
  ]
