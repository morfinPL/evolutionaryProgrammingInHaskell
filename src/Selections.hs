module Selections where

import qualified Data.List                      ( length
                                                , elemIndices
                                                , find
                                                )
import qualified System.Random                  ( RandomGen
                                                , randoms
                                                )


computeProbabilities :: Double -> [Double] -> [Double]
computeProbabilities sum = map (divide sum) where divide sum elem = elem / sum


computeRouletteArray :: [[Double]] -> [Double]
computeRouletteArray points = do
  let values = map take3rdElement points where take3rdElement list = list !! 2
  let max          = maximum values
  let increasedMax = max + abs (0.1 * max)
  let differences = computeDifferences increasedMax values
        where computeDifferences max = map (subtract max)
  let sumOfDifferences = sum differences
  computeSumOfProbabilities (computeProbabilities sumOfDifferences differences)
  where computeSumOfProbabilities list = scanl1 (+) (init list) ++ [1.0]


choicesToIndexes :: [Double] -> [Double] -> [Int]
choicesToIndexes choices rouletteArray = map (choiceToIndex rouletteArray)
                                             choices
 where
  choiceToIndex rouletteArray a = head
    (Data.List.elemIndices (Data.List.find (>= a) rouletteArray)
                           (map Just rouletteArray)
    )


roulette
  :: System.Random.RandomGen g => g -> [[[Bool]]] -> [[Double]] -> [[[Bool]]]
roulette generator oldPopulation oldPoints = do
  let rouletteArray = computeRouletteArray oldPoints
  let choices = take (length oldPopulation)
                     (System.Random.randoms generator :: [Double])
  map (indexToIndividual oldPopulation) (choicesToIndexes choices rouletteArray)
  where indexToIndividual oldPopulation index = oldPopulation !! index
