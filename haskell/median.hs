import Data.List
import System.IO


median [] = Nothing
median xs = Just (sort xs !! div (length xs) 2)


medianStr Nothing       = "Empty list - no median"
medianStr (Just median) = "Median: " ++ show median


loop :: [Integer] -> IO()
loop xs = do
  putStr "Enter number (blank line to end): "
  hFlush stdout
  line <- getLine
  if line == ""
    then putStrLn $ medianStr $ median xs
    else loop $ read line : xs


main = do
  putStrLn "Enter a list of integers, one on each line."
  putStrLn "I will compute the median of the list.\n"

  loop []
