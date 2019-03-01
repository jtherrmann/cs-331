local parseit = {}

local lexit = require "lexit"

local lexIter
local lexStr
local lexCat


local function lexNext()
   lexStr, lexCat = lexIter()
end


local function lexInit(input)
   lexIter = lexit.lex(input)
   lexNext()
end


-- AST constants
local STMT_LIST = 1

local parseProgram


function parseit.parse(input)
   lexInit(input)
   return parseProgram()
end


function parseProgram()
   return true, true, {STMT_LIST}
end
   

return parseit
