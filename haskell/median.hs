import Data.List
import System.IO


median xs = sort xs !! div (length xs) 2


loop :: [Integer] -> IO()
loop xs = do
  putStr "Enter number (blank line to end): "
  hFlush stdout
  line <- getLine
  if line == ""
    then putStrLn $ "Median: " ++ (show $ median xs)
    else loop $ read line : xs


main = do
  putStrLn "Enter a list of integers, one on each line."
  putStrLn "I will compute the median of the list.\n"

  loop []
