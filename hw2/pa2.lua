-- pa2.lua
-- Jake Herrmann
-- 9 Feb 2019
-- CS 331 Spring 2019
--
-- pa2 module for Assignment 2.


local pa2 = {}


-- pa2.mapTable
--
-- Return the table that results from mapping the given function over the
-- values in the given table.
--
-- Pre:
-- - f is a one-parameter function that accepts any value in table t.
function pa2.mapTable(f, t)
   local mtbl = {}
   for k, v in pairs(t) do
      mtbl[k] = f(v)
   end
   return mtbl
end


-- pa2.concatMax
--
-- Return the string that is the concatenation of as many copies of the given
-- string as possible, without the length exceeding the given integer.
--
-- Pre:
-- - str is a string.
-- - maxLen is an integer.
function pa2.concatMax(str, maxLen)
   return string.rep(str, math.floor(maxLen / #str))
end


-- The Collatz function.
local function c(n)
   if n % 2 == 0 then
      return n / 2
   else
      return 3 * n + 1
   end
end


-- pa2.collatz
--
-- Return an iterator that produces the Collatz sequence starting at the given
-- integer.
--
-- Pre:
-- - k is a positive integer.
function pa2.collatz(k)
   local last = nil

   function iter(dummy1, dummy2)
      if last == 1 then
	 return nil
      end
      if last == nil then
	 last = k
      else
	 last = c(last)
      end
      return last
   end

   return iter, nil, nil
end


-- pa2.backSubs
--
-- Yield all substrings of the reverse of the given string.
--
-- Pre:
-- - s is a string.
function pa2.backSubs(s)
   local revStr = string.reverse(s)
   coroutine.yield("")
   for offset = 0, #revStr - 1 do
      for index = 1, #revStr - offset do
	 coroutine.yield(string.sub(revStr, index, index + offset))
      end
   end
end


return pa2
