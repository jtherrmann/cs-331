local pa2 = {}


-- TODO:
-- - re-read project reqs
-- - follow coding standards


-- Pre:
-- - f is a one-parameter function that accepts any value in table t.
function pa2.mapTable(f, t)
   local mtbl = {}
   for k, v in pairs(t) do
      mtbl[k] = f(v)
   end
   return mtbl
end


function pa2.concatMax(str, maxLen)
   local concatStr = ""
   while #concatStr + #str <= maxLen do
      concatStr = concatStr .. str
   end
   return concatStr
end


local function c(n)
   if n % 2 == 0 then
      return n / 2
   else
      return 3 * n + 1
   end
end


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


return pa2
