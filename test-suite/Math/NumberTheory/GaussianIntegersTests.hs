{-# OPTIONS_GHC -fno-warn-type-defaults #-}

-- |
-- Module:      Math.NumberTheory.GaussianIntegersTests
-- Copyright:   (c) 2016 Chris Fredrickson, Google Inc.
-- Licence:     MIT
-- Maintainer:  Chris Fredrickson <chris.p.fredrickson@gmail.com>
-- Stability:   Provisional
--
-- Tests for Math.NumberTheory.GaussianIntegers
--

module Math.NumberTheory.GaussianIntegersTests
  ( testSuite
  ) where

import Control.Monad (zipWithM_)
import Data.List (groupBy, sort)
import Test.Tasty
import Test.Tasty.HUnit

import Math.NumberTheory.GaussianIntegers
import Math.NumberTheory.Moduli.Sqrt (sqrtModMaybe, FieldCharacteristic(..))
import Math.NumberTheory.Powers (integerSquareRoot)
import Math.NumberTheory.UniqueFactorisation (unPrime)
import Math.NumberTheory.TestUtils

lazyCases :: [(GaussianInteger, [(GaussianInteger, Int)])]
lazyCases =
  [ ( 14145130733
    * 10000000000000000000000000000000000000121
    * 100000000000000000000000000000000000000000000000447
    , [(117058 :+ 21037, 1), (21037 :+ 117058, 1)]
    )
  ]

-- | Number is zero or is equal to the product of its factors.
factoriseProperty1 :: GaussianInteger -> Bool
factoriseProperty1 g
  =  g == 0
  || abs g == abs g'
  where
    factors = factorise g
    g' = product $ map (uncurry (^)) factors

factoriseProperty2 :: GaussianInteger -> Bool
factoriseProperty2 z = z == 0 || all ((> 0) . snd) (factorise z)

factoriseProperty3 :: GaussianInteger -> Bool
factoriseProperty3 z = z == 0 || all ((> 1) . norm . fst) (factorise z)

factoriseSpecialCase1 :: Assertion
factoriseSpecialCase1 = assertEqual "should be equal"
  [(3, 2), (1 :+ 2, 1), (2 :+ 3, 1)]
  (factorise (63 :+ 36))

factoriseSpecialCase2 :: (GaussianInteger, [(GaussianInteger, Int)]) -> Assertion
factoriseSpecialCase2 (n, fs) = zipWithM_ (assertEqual (show n)) fs (factorise n)

findPrimeReference :: PrimeWrapper Integer -> GaussianInteger
findPrimeReference (PrimeWrapper p) =
    let (Just c) = sqrtModMaybe (-1) (FieldCharacteristic p 1)
        k  = integerSquareRoot (unPrime p)
        bs = [1 .. k]
        asbs = map (\b' -> ((b' * c) `mod` (unPrime p), b')) bs
        (a, b) = head [ (a', b') | (a', b') <- asbs, a' <= k]
    in a :+ b

findPrimeProperty1 :: PrimeWrapper Integer -> Bool
findPrimeProperty1 p'@(PrimeWrapper p)
  = unPrime p `mod` 4 /= (1 :: Integer)
  || p1 == p2
  || abs (p1 * p2) == fromInteger (unPrime p)
  where
    p1 = findPrimeReference p'
    p2 = findPrime (unPrime p)

-- | Number is prime iff it is non-zero
--   and has exactly one (non-unit) factor.
isPrimeProperty :: GaussianInteger -> Bool
isPrimeProperty g
  =  g == 0
  || isPrime g && n == 1
  || not (isPrime g) && n /= 1
  where
    factors = factorise g
    -- Count factors taking into account multiplicity
    n = sum $ map snd factors

primesSpecialCase1 :: Assertion
primesSpecialCase1 = assertEqual "primes"
  (f [1+ι,2+ι,1+2*ι,3,3+2*ι,2+3*ι,4+ι,1+4*ι,5+2*ι,2+5*ι,6+ι,1+6*ι,5+4*ι,4+5*ι,7,7+2*ι,2+7*ι,6+5*ι,5+6*ι,8+3*ι,3+8*ι,8+5*ι,5+8*ι,9+4*ι,4+9*ι,10+ι,1+10*ι,10+3*ι,3+10*ι,8+7*ι,7+8*ι,11,11+4*ι,4+11*ι,10+7*ι,7+10*ι,11+6*ι,6+11*ι,13+2*ι,2+13*ι,10+9*ι,9+10*ι,12+7*ι,7+12*ι,14+ι,1+14*ι,15+2*ι,2+15*ι,13+8*ι,8+13*ι,15+4*ι])
  (f $ take 51 primes)
  where
    f :: [GaussianInteger] -> [[GaussianInteger]]
    f = map sort . groupBy (\g1 g2 -> norm g1 == norm g2)

-- | The list of primes should include only primes.
primesGeneratesPrimesProperty :: NonNegative Int -> Bool
primesGeneratesPrimesProperty (NonNegative i) = isPrime (primes !! i)

-- | Check that primes generates the primes in order.
orderingPrimes :: Assertion
orderingPrimes = assertBool "primes are ordered" (and $ zipWith (<=) xs (tail xs))
  where xs = map norm $ take 1000 primes

numberOfPrimes :: Assertion
numberOfPrimes = assertEqual "counting primes: OEIS A091100"
  [16,100,668,4928,38404,313752,2658344]
  [4 * (length $ takeWhile ((<= 10^n) . norm) primes) | n <- [1..7]]

-- | signum and abs should satisfy: z == signum z * abs z
signumAbsProperty :: GaussianInteger -> Bool
signumAbsProperty z = z == signum z * abs z

-- | abs maps a Gaussian integer to its associate in first quadrant.
absProperty :: GaussianInteger -> Bool
absProperty z = isOrigin || (inFirstQuadrant && isAssociate)
  where
    z'@(x' :+ y') = abs z
    isOrigin = z' == 0 && z == 0
    inFirstQuadrant = x' > 0 && y' >= 0     -- first quadrant includes the positive real axis, but not the origin or the positive imaginary axis
    isAssociate = z' `elem` map (\e -> z * (0 :+ 1) ^ e) [0 .. 3]

gcdGProperty1 :: GaussianInteger -> GaussianInteger -> Bool
gcdGProperty1 z1 z2
  = z1 == 0 && z2 == 0
  || z1 `remG` z == 0 && z2 `remG` z == 0 && z == abs z
  where
    z = gcdG z1 z2

gcdGProperty2 :: GaussianInteger -> GaussianInteger -> GaussianInteger -> Bool
gcdGProperty2 z z1 z2
  = z == 0
  || (gcdG z1' z2') `remG` z == 0
  where
    z1' = z * z1
    z2' = z * z2

-- | a special case that tests rounding/truncating in GCD.
gcdGSpecialCase1 :: Assertion
gcdGSpecialCase1 = assertEqual "gcdG" 1 $ gcdG (12 :+ 23) (23 :+ 34)

testSuite :: TestTree
testSuite = testGroup "GaussianIntegers" $
  [ testGroup "factorise" (
    [ testSmallAndQuick "factor back"       factoriseProperty1
    , testSmallAndQuick "powers are > 0"    factoriseProperty2
    , testSmallAndQuick "factors are > 1"   factoriseProperty3
    , testCase          "factorise 63:+36"  factoriseSpecialCase1
    ]
    ++
    map (\x -> testCase ("laziness " ++ show (fst x)) (factoriseSpecialCase2 x))
      lazyCases)

  , testSmallAndQuick "findPrime'"               findPrimeProperty1
  , testSmallAndQuick "isPrime"                  isPrimeProperty
  , testCase          "primes matches reference" primesSpecialCase1
  , testSmallAndQuick "primes"                   primesGeneratesPrimesProperty
  , testCase          "primes are ordered"       orderingPrimes
  , testCase          "counting primes"          numberOfPrimes
  , testSmallAndQuick "signumAbsProperty"        signumAbsProperty
  , testSmallAndQuick "absProperty"              absProperty
  , testGroup "gcdG"
    [ testSmallAndQuick "is divisor"            gcdGProperty1
    , testSmallAndQuick "is greatest"           gcdGProperty2
    , testCase          "(12 :+ 23) (23 :+ 34)" gcdGSpecialCase1
    ]
  ]
