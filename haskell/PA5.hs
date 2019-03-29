-- PA5.hs
-- Jake Herrmann
-- 28 Mar 2019
-- CS 331 Spring 2019
--
-- PA5 module for Assignment 5.
-- Based on a skeleton file by Glenn G. Chappell.

-- TODO:
-- - read project reqs, coding standards, lecture slides:
--   - https://www.cs.uaf.edu/users/chappell/public_html/class/2019_spr/cs331/lect/cs331-20190322-forth_alloc.pdf
-- - how to separate public/private functions/variables?
-- - TODOs in files

module PA5 where


-- collatzCounts
--
-- A list where item k is the number of iterations of the Collatz function
-- required to take the number k+1 to 1.
collatzCounts :: [Integer]
collatzCounts = map (collatzCount 0) [1..]

-- collatzCount
--
-- Given a starting count and a number, count the number of iterations of the
-- Collatz function required to take the number to 1.
collatzCount count 1 = count
collatzCount count n = collatzCount (count + 1) (collatzFunction n)

-- collatzFunction
--
-- The Collatz function.
collatzFunction n
  | odd n     = 3 * n + 1
  | otherwise = div n 2


-- findList
--
-- If the first list is a sublist of the second list, return the earliest index
-- of the second list at which a copy of the first list begins. Otherwise
-- return Nothing.
findList :: Eq a => [a] -> [a] -> Maybe Int
findList = loop 0 where
  loop pos xs [] = Nothing
  loop pos xs ys
    | take (length xs) ys == xs = Just pos
    | otherwise                 = loop (pos + 1) xs (tail ys)


-- operator ##
--
-- Return the number of indices at which the two lists contain equal values.
(##) :: Eq a => [a] -> [a] -> Int
xs ## ys = length (filter (\ (x, y) -> x == y) (zip xs ys))


-- filterAB
--
-- Return a list of every item in the second list for which the corresponding
-- item in the first list satisfies the predicate.
filterAB :: (a -> Bool) -> [a] -> [b] -> [b]
filterAB pred xs ys = [y | (x, y) <- zip xs ys, pred x]


-- sumEvenOdd
--
-- Return the sum of the even-index items and the sum of the odd-index items.
sumEvenOdd :: Num a => [a] -> (a, a)
sumEvenOdd xs = foldl addToSum (0, 0) (zip [0..] xs)

-- addToSum
--
-- Add the given number to the appropriate sum based on its index.
addToSum (evenSum, oddSum) (index, x)
  | even index = (evenSum + x, oddSum)
  | otherwise  = (evenSum, oddSum + x)
