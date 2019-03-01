-- TODO:
-- - TODO throughout file
-- - linter (e.g. for checking undefined vars, missing "local"s)
-- - remove prints
-- - factor out matchString/matchCat functions? (see rdparser4.lua)
-- - wrap lex iter in a lexer object (using a metatable)

local parseit = {}

local lexit = require "lexit"


-- TODO: invariants
local Lexer = {}


-- TODO: confirm Lexer functions don't need to be local


function Lexer.__index(tbl, key)
   return Lexer[key]
end


function Lexer.new(input)
   local obj = {}
   setmetatable(obj, Lexer)
   obj._iter = lexit.lex(input)
   obj:_next()
   return obj
end


function Lexer.str(self)
   return self._str
end


function Lexer.cat(self)
   return self._cat
end


function Lexer.popStr(self)
   local str = self:str()
   self:_next()
   return str
end


function Lexer.matchStr(self, str)
   if str == self:str() then
      self:_next()
      return true
   end
   return false
end


function Lexer.matchCat(self, cat)
   if cat == self:cat() then
      self:_next()
      return true
   end
   return false
end


function Lexer.isDone(self)
   if self:str() == nil then
      assert(self:cat() == nil)
      return true
   end
   return false
end


function Lexer._next(self)
   self._str, self._cat = self:_iter()
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
local parseWriteArg

local beginsStatement


local function append(t, item)
   t[#t+1] = item
end


function parseit.parse(input)
   local lexer = Lexer.new(input)
   local ast = parseProgram(lexer)
   return ast ~= nil, lexer:isDone(), ast
end


-- TODO: unnecessary?
function parseProgram(lexer)
   return parseStmtList(lexer)
end


function parseStmtList(lexer)
   local ast = {STMT_LIST}
   while beginsStatement(lexer:str(), lexer:cat()) do
      local statement = parseStatement(lexer)
      if statement == nil then
	 return nil
      end
      append(ast, statement)
   end
   return ast
end


function beginsStatement(lexStr, lexCat)
   return lexStr == 'write' or lexStr == 'def' or lexStr == 'if'
   or lexStr == 'while' or lexStr == 'return' or lexCat == lexit.ID
end


-- TODO: factor out a parse function for each kind of statement
function parseStatement(lexer)
   local ast
   if lexer:matchStr('write') then
      if not lexer:matchStr('(') then
	 return nil
      end
      ast = {WRITE_STMT}

      -- TODO: DRY if possible
      local writeArg = parseWriteArg(lexer)
      if writeArg == nil then
	 return nil
      end
      append(ast, writeArg)

      while lexer:str() ~= ')' do
	 if not lexer:matchStr(',') then
	    return nil
	 end

	 writeArg = parseWriteArg(lexer)
	 if writeArg == nil then
	    return nil
	 end
	 append(ast, writeArg)

      end
      if not lexer:matchStr(')') then
	 return nil
      end
      return ast
   end
   if lexer:matchCat(lexit.ID) then
      return nil
   end
   return nil
end


function parseWriteArg(lexer)
   local ast
   if lexer:matchStr('cr') then
      ast = {CR_OUT}
   elseif lexer:cat() == lexit.STRLIT then
      ast = {STRLIT_OUT, lexer:popStr()}
   end
   return ast -- TODO: parse more kinds of write args
end


return parseit
