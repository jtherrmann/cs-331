-- median.hs
-- Jake Herrmann
-- 28 Mar 2019
-- CS 331 Spring 2019
--
-- Median calculator for Assignment 5.


-- WARNING: This program does not validate user input. When prompted for a
-- number, the user should enter a valid integer (can be positive or negative).
-- When prompted for a yes or no response, the user should enter y or n.


module Main where


import Data.List
import System.IO


-- median
--
-- Return the median of the given list of numbers, or Nothing if the list is
-- empty.
median [] = Nothing
median xs = Just (sort xs !! div (length xs) 2)


-- medianStr
--
-- Return a string that displays the given median.
medianStr Nothing       = "Empty list - no median"
medianStr (Just median) = "Median: " ++ show median


-- medianLoop
--
-- Given the current list of numbers, prompt the user to enter another number
-- or a blank line. If they enter a blank line, print the median of the given
-- list. Otherwise add the input number to the list and continue the loop.
medianLoop :: [Integer] -> IO()
medianLoop xs = do
  putStr "Enter number (blank line to end): "
  hFlush stdout
  line <- getLine
  if line == ""
    then putStrLn $ medianStr $ median xs
    else medianLoop $ read line : xs


-- main
--
-- Allow the user to compute medians of lists of numbers.
main = do
  putStrLn "Enter a list of integers, one on each line."
  putStrLn "I will compute the median of the list.\n"
  medianLoop []

  putStr "\nCompute another median? [y/n] "
  hFlush stdout
  line <- getLine
  if line == "n"
    then putStrLn "Bye!"
    else do
      putStrLn ""
      main
