-- PA5.hs  INCOMPLETE
-- Glenn G. Chappell
-- 21 Mar 2019
--
-- For CS F331 / CSCE A331 Spring 2019
-- Solutions to Assignment 5 Exercise B

-- TODO:
-- - read project reqs, coding standards, lecture slides:
--   - https://www.cs.uaf.edu/users/chappell/public_html/class/2019_spr/cs331/lect/cs331-20190322-forth_alloc.pdf
-- - how to separate public/private functions/variables?
-- - TODOs in file

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
findList = findList' 0

findList' pos xs [] = Nothing
findList' pos xs ys
  | take (length xs) ys == xs = Just pos
  | otherwise                 = findList' (pos + 1) xs (tail ys)


-- operator ##
(##) :: Eq a => [a] -> [a] -> Int
xs ## ys = length (filter (\ (x, y) -> x == y) (zip xs ys))


-- filterAB
filterAB :: (a -> Bool) -> [a] -> [b] -> [b]
filterAB pred xs ys = [y | (x, y) <- zip xs ys, pred x]


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
-- TODO: does it need to EXACTLY match above? (i.e. just "xs")
sumEvenOdd xs = foldl helper (0, 0) (zip [0..] xs)

helper (evenSum, oddSum) (index, x)
  | even index = (evenSum + x, oddSum)
  | otherwise  = (evenSum, oddSum + x)
