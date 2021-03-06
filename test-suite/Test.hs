import Test.Tasty

import qualified Math.NumberTheory.GCDTests as GCD

import qualified Math.NumberTheory.Recurrencies.PentagonalTests as RecurrenciesPentagonal
import qualified Math.NumberTheory.Recurrencies.BilinearTests as RecurrenciesBilinear
import qualified Math.NumberTheory.Recurrencies.LinearTests as RecurrenciesLinear

import qualified Math.NumberTheory.Moduli.ChineseTests as ModuliChinese
import qualified Math.NumberTheory.Moduli.ClassTests as ModuliClass
import qualified Math.NumberTheory.Moduli.EquationsTests as ModuliEquations
import qualified Math.NumberTheory.Moduli.JacobiTests as ModuliJacobi
import qualified Math.NumberTheory.Moduli.PrimitiveRootTests as ModuliPrimitiveRoot
import qualified Math.NumberTheory.Moduli.SqrtTests as ModuliSqrt

import qualified Math.NumberTheory.MoebiusInversionTests as MoebiusInversion
import qualified Math.NumberTheory.MoebiusInversion.IntTests as MoebiusInversionInt

import qualified Math.NumberTheory.Powers.CubesTests as Cubes
import qualified Math.NumberTheory.Powers.FourthTests as Fourth
import qualified Math.NumberTheory.Powers.GeneralTests as General
import qualified Math.NumberTheory.Powers.ModularTests as Modular
import qualified Math.NumberTheory.Powers.SquaresTests as Squares

import qualified Math.NumberTheory.PrefactoredTests as Prefactored

import qualified Math.NumberTheory.PrimesTests as Primes
import qualified Math.NumberTheory.Primes.CountingTests as Counting
import qualified Math.NumberTheory.Primes.FactorisationTests as Factorisation
import qualified Math.NumberTheory.Primes.SieveTests as Sieve
import qualified Math.NumberTheory.Primes.TestingTests as Testing

import qualified Math.NumberTheory.GaussianIntegersTests as Gaussian

import qualified Math.NumberTheory.ArithmeticFunctionsTests as ArithmeticFunctions
import qualified Math.NumberTheory.ArithmeticFunctions.MertensTests as Mertens
import qualified Math.NumberTheory.ArithmeticFunctions.SieveBlockTests as SieveBlock
import qualified Math.NumberTheory.UniqueFactorisationTests as UniqueFactorisation
import qualified Math.NumberTheory.CurvesTests as Curves
import qualified Math.NumberTheory.SmoothNumbersTests as SmoothNumbers

import qualified Math.NumberTheory.Zeta.RiemannTests as Riemann
import qualified Math.NumberTheory.Zeta.DirichletTests as Dirichlet

main :: IO ()
main = defaultMain tests

tests :: TestTree
tests = testGroup "All"
  [ testGroup "Powers"
    [ Cubes.testSuite
    , Fourth.testSuite
    , General.testSuite
    , Modular.testSuite
    , Squares.testSuite
    ]
  , GCD.testSuite
  , testGroup "Recurrencies"
    [ RecurrenciesPentagonal.testSuite
    , RecurrenciesLinear.testSuite
    , RecurrenciesBilinear.testSuite
    ]
  , testGroup "Moduli"
    [ ModuliChinese.testSuite
    , ModuliClass.testSuite
    , ModuliEquations.testSuite
    , ModuliJacobi.testSuite
    , ModuliPrimitiveRoot.testSuite
    , ModuliSqrt.testSuite
    ]
  , testGroup "MoebiusInversion"
    [ MoebiusInversion.testSuite
    , MoebiusInversionInt.testSuite
    ]
  , Prefactored.testSuite
  , testGroup "Primes"
    [ Primes.testSuite
    , Counting.testSuite
    , Factorisation.testSuite
    , Sieve.testSuite
    , Testing.testSuite
    ]
  , Gaussian.testSuite
  , testGroup "ArithmeticFunctions"
    [ ArithmeticFunctions.testSuite
    , Mertens.testSuite
    , SieveBlock.testSuite
    ]
  , UniqueFactorisation.testSuite
  , Curves.testSuite
  , SmoothNumbers.testSuite

  , testGroup "Zeta"
    [ Riemann.testSuite
    , Dirichlet.testSuite
    ]
  ]
