-- TODO:
-- - TODO throughout file
-- - can just do "return" w/o nil?
-- - confirm we're allowed extra parsing funcs (not just 1 per nonterminal)
-- - use elseif even when return in if bodies?
-- - DRY up left-associativity funcs
-- - linter (e.g. for checking undefined vars, missing "local"s)
-- - coding standards, reread assignment reqs
-- - comments, incl. sections (Lexer, parse funcs, etc.)
-- - review code for general cleanness/quality

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
local parseIfStatement
local parseWhileStatement
local parseReturnStatement
local parseIdStatement
local parseExpr
local parseCompExpr
local parseArithExpr
local parseTerm
local parseFactor
local parseParenExpr
local parseUnaryOpFactor
local parseReadnumFactor
local parseVar


local function append(t, item)
   t[#t+1] = item
end


local function inArray(item, t)
   for _, val in ipairs(t) do
      if val == item then
         return true
      end
   end
   return false
end


function parseit.parse(input)
   local lexer = Lexer.new(input)
   local ast = parseStmtList(lexer)
   return ast ~= nil, lexer:isDone(), ast
end


function parseStmtList(lexer)
   local ast = {STMT_LIST}
   local statement

   while inArray(lexer:str(), {'write', 'def', 'if', 'while', 'return'})
   or lexer:cat() == lexit.ID do
      statement = parseStatement(lexer)
      if statement == nil then
         return nil
      end
      append(ast, statement)
   end
   return ast
end


function parseStatement(lexer)
   if lexer:str() == 'write' then
      return parseWriteStatement(lexer)
   end
   if lexer:str() == 'def' then
      return parseFuncDefStatement(lexer)
   end
   if lexer:str() == 'if' then
      return parseIfStatement(lexer)
   end
   if lexer:str() == 'while' then
      return parseWhileStatement(lexer)
   end
   if lexer:str() == 'return' then
      return parseReturnStatement(lexer)
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
   local writeArg

   repeat
      writeArg = parseWriteArg(lexer)
      if writeArg == nil then
         return nil
      end
      append(ast, writeArg)
   until not lexer:matchStr(',')

   if not lexer:matchStr(')') then
      return nil
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
   return parseExpr(lexer)
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
   if stmtList == nil or not lexer:matchStr('end') then
      return nil
   end
   return {FUNC_DEF, id, stmtList}
end


function parseIfStatement(lexer)
   assert(lexer:matchStr('if'))

   local ast = {IF_STMT}
   local expr, stmtList

   repeat
      expr = parseExpr(lexer)
      if expr == nil then
         return nil
      end
      append(ast, expr)

      stmtList = parseStmtList(lexer)
      if stmtList == nil then
         return nil
      end
      append(ast, stmtList)
   until not lexer:matchStr('elseif')

   if lexer:matchStr('else') then
      stmtList = parseStmtList(lexer)
      if stmtList == nil then
         return nil
      end
      append(ast, stmtList)
   end

   if not lexer:matchStr('end') then
      return nil
   end
   return ast
end


function parseWhileStatement(lexer)
   assert(lexer:matchStr('while'))

   local expr = parseExpr(lexer)
   if expr == nil then
      return nil
   end

   local stmtList = parseStmtList(lexer)
   if stmtList == nil or not lexer:matchStr('end') then
      return nil
   end
   return {WHILE_STMT, expr, stmtList}
end


function parseReturnStatement(lexer)
   assert(lexer:matchStr('return'))
   local expr = parseExpr(lexer)
   if expr == nil then
      return nil
   end
   return {RETURN_STMT, expr}
end


function parseIdStatement(lexer)
   assert(lexer:cat() == lexit.ID)

   local var = parseVar(lexer)
   if var == nil or var[1] == FUNC_CALL then
      return var
   end

   if not lexer:matchStr('=') then
      return nil
   end

   local expr = parseExpr(lexer)
   if expr == nil then
      return nil
   end

   return {ASSN_STMT, var, expr}
end


function parseExpr(lexer)
   local compExpr = parseCompExpr(lexer)
   if compExpr == nil then
      return nil
   end

   local binop, compExpr2
   while lexer:str() == '&&' or lexer:str() == '||' do
      binop = lexer:popStr()
      compExpr2 = parseCompExpr(lexer)
      if compExpr2 == nil then
         return nil
      end
      compExpr = {{BIN_OP, binop}, compExpr, compExpr2}
   end

   return compExpr
end


function parseCompExpr(lexer)
   if lexer:matchStr('!') then
      local compExpr = parseCompExpr(lexer)
      if compExpr == nil then
         return nil
      end
      return {{UN_OP, '!'}, compExpr}
   end

   local arithExpr = parseArithExpr(lexer)
   if arithExpr == nil then
      return nil
   end

   local binop, arithExpr2
   while inArray(lexer:str(), {'==', '!=', '<', '<=', '>', '>='}) do
      binop = lexer:popStr()
      arithExpr2 = parseArithExpr(lexer)
      if arithExpr2 == nil then
         return nil
      end
      arithExpr = {{BIN_OP, binop}, arithExpr, arithExpr2}
   end

   return arithExpr
end


function parseArithExpr(lexer)
   local term = parseTerm(lexer)
   if term == nil then
      return nil
   end

   local binop, term2
   while lexer:str() == '+' or lexer:str() == '-' do
      binop = lexer:popStr()
      term2 = parseTerm(lexer)
      if term2 == nil then
         return nil
      end
      term = {{BIN_OP, binop}, term, term2}
   end

   return term
end


function parseTerm(lexer)
   local factor = parseFactor(lexer)
   if factor == nil then
      return nil
   end

   local binop, factor2
   while inArray(lexer:str(), {'*', '/', '%'}) do
      binop = lexer:popStr()
      factor2 = parseFactor(lexer)
      if factor2 == nil then
         return nil
      end
      factor = {{BIN_OP, binop}, factor, factor2}
   end

   return factor
end


function parseFactor(lexer)
   if lexer:str() == '(' then
      return parseParenExpr(lexer)
   end
   if lexer:str() == '+' or lexer:str() == '-' then
      return parseUnaryOpFactor(lexer)
   end
   if lexer:cat() == lexit.NUMLIT then
      return {NUMLIT_VAL, lexer:popStr()}
   end
   if lexer:str() == 'true' or lexer:str() == 'false' then
      return {BOOLLIT_VAL, lexer:popStr()}
   end
   if lexer:str() == 'readnum' then
      return parseReadnumFactor(lexer)
   end
   if lexer:cat() == lexit.ID then
      return parseVar(lexer)
   end
   return nil
end


function parseParenExpr(lexer)
   assert(lexer:matchStr('('))
   local expr = parseExpr(lexer)
   if expr == nil or not lexer:matchStr(')') then
      return nil
   end
   return expr
end


function parseUnaryOpFactor(lexer)
   assert(lexer:str() == '+' or lexer:str() == '-')
   local unaryOp = lexer:popStr()
   local factor = parseFactor(lexer)
   if factor == nil then
      return nil
   end
   return {{UN_OP, unaryOp}, factor}
end


function parseReadnumFactor(lexer)
   assert(lexer:matchStr('readnum'))
   if not (lexer:matchStr('(') and lexer:matchStr(')')) then
      return nil
   end
   return {READNUM_CALL}
end


function parseVar(lexer)
   assert(lexer:cat() == lexit.ID)
   local id = lexer:popStr()

   if lexer:matchStr('(') then
      if not lexer:matchStr(')') then
         return nil
      end
      return {FUNC_CALL, id}
   end

   if lexer:matchStr('[') then
      local expr = parseExpr(lexer)
      if expr == nil or not lexer:matchStr(']') then
         return nil
      end
      return {ARRAY_VAR, id, expr}
   end

   return {SIMPLE_VAR, id}
end


return parseit
