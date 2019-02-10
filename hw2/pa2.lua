local pa2 = {}


-- TODO:
-- - re-read project reqs
-- - follow coding standards


-- Pre:
-- - f is a one-parameter function that accepts any value in table t.
function pa2.mapTable(f, t)
   mtbl = {}
   for k, v in pairs(t) do
      mtbl[k] = f(v)
   end
   return mtbl
end


function pa2.concatMax(str, maxLen)
   concatStr = ""
   while #concatStr + #str <= maxLen do
      concatStr = concatStr .. str
   end
   return concatStr
end


return pa2
