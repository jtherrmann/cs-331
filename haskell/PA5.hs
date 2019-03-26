-- PA5.hs  INCOMPLETE
-- Glenn G. Chappell
-- 21 Mar 2019
--
-- For CS F331 / CSCE A331 Spring 2019
-- Solutions to Assignment 5 Exercise B

-- TODO:
-- - read project reqs, coding standards
-- - how to separate public/private functions/variables?

module PA5 where


-- collatzCounts
collatzCounts :: [Integer]
collatzCounts = map (collatzCount 0) [1..]

collatzCount count 1 = count
collatzCount count n = collatzCount (count + 1) (collatzFunction n)

collatzFunction n
  | odd n     = 3 * n + 1
  | otherwise = div n 2


-- findList
findList :: Eq a => [a] -> [a] -> Maybe Int
findList _ _ = Just 42  -- DUMMY; REWRITE THIS!!!


-- operator ##
(##) :: Eq a => [a] -> [a] -> Int
_ ## _ = 42  -- DUMMY; REWRITE THIS!!!


-- filterAB
filterAB :: (a -> Bool) -> [a] -> [b] -> [b]
filterAB _ _ bs = bs  -- DUMMY; REWRITE THIS!!!


-- sumEvenOdd
sumEvenOdd :: Num a => [a] -> (a, a)
{-
  The assignment requires sumEvenOdd to be written using a fold.
  Something like this:

    sumEvenOdd xs = fold* ... xs where
        ...

  Above, "..." should be replaced by other code. The "fold*" must be
  one of the following: foldl, foldr, foldl1, foldr1.
-}
sumEvenOdd _ = (0, 0)  -- DUMMY; REWRITE THIS!!!

