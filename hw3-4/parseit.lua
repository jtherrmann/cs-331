local parseit = {}

local STMT_LIST = 1

function parseit.parse()
   return true, true, {STMT_LIST}
end

return parseit
