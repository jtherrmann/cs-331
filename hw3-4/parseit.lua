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
local parseStmtList
local parseStatement
local parseWriteStatement
local parseWriteArg
local parseFuncDefStatement
local parseIdStatement

local beginsStatement


local function append(t, item)
   t[#t+1] = item
end


function parseit.parse(input)
   local lexer = Lexer.new(input)
   local ast = parseStmtList(lexer)
   return ast ~= nil, lexer:isDone(), ast
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


function parseStatement(lexer)
   if lexer:str() == 'write' then
      return parseWriteStatement(lexer)
   end
   if lexer:str() == 'def' then
      return parseFuncDefStatement(lexer)
   end
   if lexer:cat() == lexit.ID then
      return parseIdStatement(lexer)
   end
   return nil
end


function parseWriteStatement(lexer)
   assert(lexer:matchStr('write'))

   if not lexer:matchStr('(') then
      return nil
   end

   local ast = {WRITE_STMT}
   local done = false
   local writeArg

   while not done do
      writeArg = parseWriteArg(lexer)
      if writeArg == nil then
         return nil
      end
      append(ast, writeArg)

      if lexer:matchStr(')') then
         done = true
      elseif not lexer:matchStr(',') then
         return nil
      end
   end
   return ast
end


function parseWriteArg(lexer)
   if lexer:matchStr('cr') then
      return {CR_OUT}
   end
   if lexer:cat() == lexit.STRLIT then
      return {STRLIT_OUT, lexer:popStr()}
   end
   return nil -- TODO: write args can be exprs
end


function parseFuncDefStatement(lexer)
   assert(lexer:matchStr('def'))

   if lexer:cat() ~= lexit.ID then
      return nil
   end
   local id = lexer:popStr()

   if not (lexer:matchStr('(') and lexer:matchStr(')')) then
      return nil
   end

   local stmtList = parseStmtList(lexer)
   if stmtList == nil then
      return nil
   end

   if not lexer:matchStr('end') then
      return nil
   end
   return {FUNC_DEF, id, stmtList}
end


-- TODO: factor out a parse func call function when get to parseFactor
function parseIdStatement(lexer)
   assert(lexer:cat() == lexit.ID)
   local id = lexer:popStr()
   if lexer:matchStr('(') then
      if not lexer:matchStr(')') then
         return nil
      end
      return {FUNC_CALL, id}
   end
   return nil -- TODO: parse other kinds of id statements
end
   

return parseit
