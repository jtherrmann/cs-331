-- TODO:
-- - TODO throughout file
-- - linter (e.g. for checking undefined vars, missing "local"s)

local parseit = {}

local lexit = require "lexit"

local lexIter
local lexStr
local lexCat


-- TODO: comment that lexInit must be called before this function is called
local function lexNext()
   lexStr, lexCat = lexIter()
end


-- TODO: comment that lexInit must be called before this function is called
local function lexIsDone(input)
   if lexStr == nil then
      assert(lexCat == nil)
      return true
   end
   return false
end


local function lexInit(input)
   lexIter = lexit.lex(input)
   lexNext()
end


-- AST constants
local STMT_LIST    = 1
local WRITE_STMT   = 2
local FUNC_DEF     = 3
local FUNC_CALL    = 4
local IF_STMT      = 5
local WHILE_STMT   = 6
local RETURN_STMT  = 7
local ASSN_STMT    = 8
local CR_OUT       = 9
local STRLIT_OUT   = 10
local BIN_OP       = 11
local UN_OP        = 12
local NUMLIT_VAL   = 13
local BOOLLIT_VAL  = 14
local READNUM_CALL = 15
local SIMPLE_VAR   = 16
local ARRAY_VAR    = 17

-- TODO: check that these are all here
local parseProgram
local parseStmtList
local parseStatement


function parseit.parse(input)
   lexInit(input)
   local ast = parseProgram()
   return ast ~= nil, lexIsDone(), ast
end


function parseProgram()
   return parseStmtList()
end


function parseStmtList()
   local ast = {STMT_LIST}
   while not lexIsDone() do
      local statement = parseStatement()
      if statement == nil then
	 return nil
      end
      -- TODO: factor out append function
      ast[#ast+1] = statement
   end
   return ast
end


function parseStatement()
   lexNext()
   return {}
end


return parseit
