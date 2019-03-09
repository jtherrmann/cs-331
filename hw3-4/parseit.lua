-- TODO:
-- - TODO throughout file
-- - coding standards, reread assignment reqs
-- - review code for general cleanness/quality
-- - reread comments one more time

-- Parser module.
local parseit = {}

local lexit = require "lexit"


-- ============================================================================
-- class Lexer
-- ============================================================================

-- Invariants:
-- - self._str and self._cat are the string and category for the current
--   lexeme, or both nil if there are no more lexemes.

-- Metatable for Lexer objects.
local Lexer = {}


-- ----------------------------------------------------------------------------
-- Constructor
-- ----------------------------------------------------------------------------

-- Construct and return a new Lexer object for the given input string.
function Lexer.new(input)
   local obj = {}
   setmetatable(obj, Lexer)
   obj._iter = lexit.lex(input)
   obj:_next()
   return obj
end


-- ----------------------------------------------------------------------------
-- Metamethods
-- ----------------------------------------------------------------------------

-- Allow accessing the Lexer metatable's methods via Lexer objects.
function Lexer.__index(_, key)
   return Lexer[key]
end


-- ----------------------------------------------------------------------------
-- Public methods
-- ----------------------------------------------------------------------------

-- Return the current lexeme's string.
function Lexer.str(self)
   return self._str
end


-- Return the current lexeme's category.
function Lexer.cat(self)
   return self._cat
end


-- Return the current lexeme's string and advance to the next lexeme.
function Lexer.popStr(self)
   local str = self:str()
   self:_next()
   return str
end


-- If the current lexeme's string matches the given string, advance to the next
-- lexeme and return true. Otherwise return false.
function Lexer.matchStr(self, str)
   if str == self:str() then
      self:_next()
      return true
   end
   return false
end


-- If the current lexeme's category matches the given category, advance to the
-- next lexeme and return true. Otherwise return false.
function Lexer.matchCat(self, cat)
   if cat == self:cat() then
      self:_next()
      return true
   end
   return false
end


-- Return true if there are no more lexemes, false otherwise.
function Lexer.isDone(self)
   if self:str() == nil then
      assert(self:cat() == nil)
      return true
   end
   return false
end


-- ----------------------------------------------------------------------------
-- Private methods
-- ----------------------------------------------------------------------------

-- Advance to the next lexeme.
function Lexer._next(self)
   self._str, self._cat = self:_iter()
end


-- ============================================================================
-- Parser
-- ============================================================================

-- ----------------------------------------------------------------------------
-- AST constants
-- ----------------------------------------------------------------------------

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


-- ----------------------------------------------------------------------------
-- Local declarations for parse functions
-- ----------------------------------------------------------------------------

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
local parseLeftAssoc
local parseFactor
local parseParenExpr
local parseUnaryOpFactor
local parseReadnumFactor
local parseCallOrVar


-- ----------------------------------------------------------------------------
-- Helper functions
-- ----------------------------------------------------------------------------

-- Append the given item to the given array-like table.
local function append(t, item)
   t[#t+1] = item
end


-- Return true if the given value occurs in the given array-like table, false
-- otherwise.
local function inArray(val, t)
   for _, item in ipairs(t) do
      if item == val then
         return true
      end
   end
   return false
end


-- ----------------------------------------------------------------------------
-- Parse functions
-- ----------------------------------------------------------------------------

-- Parse the given input string and return three values: a boolean indicating
-- whether the input is syntactically correct, a boolean indicating whether the
-- end of the input was reached, and an AST representing the structure of the
-- parsed input (or nil if the input is syntactically incorrect).
function parseit.parse(input)
   local lexer = Lexer.new(input)
   local ast = parseStmtList(lexer)
   return ast ~= nil, lexer:isDone(), ast
end


-- Each of the following parse functions takes a Lexer object as its first
-- argument and returns an AST, or nil if there is a syntax error.


-- Parse a statement list.
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


-- Parse a statement.
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
   assert(false)
end


-- Parse a write statement.
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


-- Parse a write argument.
function parseWriteArg(lexer)
   if lexer:matchStr('cr') then
      return {CR_OUT}
   end
   if lexer:cat() == lexit.STRLIT then
      return {STRLIT_OUT, lexer:popStr()}
   end
   return parseExpr(lexer)
end


-- Parse a function definition.
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


-- Parse an if statement.
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


-- Parse a while statement.
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


-- Parse a return statement.
function parseReturnStatement(lexer)
   assert(lexer:matchStr('return'))
   local expr = parseExpr(lexer)
   if expr == nil then
      return nil
   end
   return {RETURN_STMT, expr}
end


-- Parse a statement beginning with an identifier, which may be a function call
-- or an assignment statement.
function parseIdStatement(lexer)
   assert(lexer:cat() == lexit.ID)

   local callOrVar = parseCallOrVar(lexer)
   if callOrVar == nil or callOrVar[1] == FUNC_CALL then
      return callOrVar
   end

   if not lexer:matchStr('=') then
      return nil
   end

   local expr = parseExpr(lexer)
   if expr == nil then
      return nil
   end

   return {ASSN_STMT, callOrVar, expr}
end


-- Parse an expression.
function parseExpr(lexer)
   return parseLeftAssoc(lexer, parseCompExpr, {'&&', '||'})
end


-- Parse a comparison expression.
function parseCompExpr(lexer)
   if lexer:matchStr('!') then
      local compExpr = parseCompExpr(lexer)
      if compExpr == nil then
         return nil
      end
      return {{UN_OP, '!'}, compExpr}
   end
   return parseLeftAssoc(
      lexer, parseArithExpr, {'==', '!=', '<', '<=', '>', '>='}
   )
end


-- Parse an arithmetic expression.
function parseArithExpr(lexer)
   return parseLeftAssoc(lexer, parseTerm, {'+', '-'})
end


-- Parse a term.
function parseTerm(lexer)
   return parseLeftAssoc(lexer, parseFactor, {'*', '/', '%'})
end


-- Given a function that parses some expression <expr>, and an array of strings
-- representing binary operators, parse an <expr> followed by zero or more
-- occurrences of a binary operator followed by an <expr>. Binary operators are
-- treated as left-associative.
--
-- exprParser must be a parse function that takes a Lexer object as its only
-- argument and binops must be an array-like table of strings.
function parseLeftAssoc(lexer, exprParser, binops)
   local ast = exprParser(lexer)
   if ast == nil then
      return nil
   end

   local binop, operand
   while inArray(lexer:str(), binops) do
      binop = lexer:popStr()
      operand = exprParser(lexer)
      if operand == nil then
         return nil
      end
      ast = {{BIN_OP, binop}, ast, operand}
   end

   return ast
end


-- Parse a factor.
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
      return parseCallOrVar(lexer)
   end
   return nil
end


-- Parse a parenthesized expression.
function parseParenExpr(lexer)
   assert(lexer:matchStr('('))
   local expr = parseExpr(lexer)
   if expr == nil or not lexer:matchStr(')') then
      return nil
   end
   return expr
end


-- Parse a factor prefixed with a unary operator.
function parseUnaryOpFactor(lexer)
   assert(lexer:str() == '+' or lexer:str() == '-')
   local unaryOp = lexer:popStr()
   local factor = parseFactor(lexer)
   if factor == nil then
      return nil
   end
   return {{UN_OP, unaryOp}, factor}
end


-- Parse a readnum call.
function parseReadnumFactor(lexer)
   assert(lexer:matchStr('readnum'))
   if not (lexer:matchStr('(') and lexer:matchStr(')')) then
      return nil
   end
   return {READNUM_CALL}
end


-- Parse a function call or variable.
function parseCallOrVar(lexer)
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


-- Export parser module.
return parseit
