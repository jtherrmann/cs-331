-- lexit.lua
-- Jake Herrmann
-- 18 Feb 2019
-- CS 331 Spring 2019
--
-- lexit module for Assignment 3.
-- The lexit module is a modified version of the lexer module by Glenn G.
-- Chappell.


-- *********************************************************************
-- Module Table Initialization
-- *********************************************************************


local lexit = {}


-- *********************************************************************
-- Public Constants
-- *********************************************************************


-- Numeric constants representing lexeme categories
lexit.KEY    = 1
lexit.ID     = 2
lexit.NUMLIT = 3
lexit.STRLIT = 4
lexit.OP     = 5
lexit.PUNCT  = 6
lexit.MAL    = 7


-- catnames
-- Array of names of lexeme categories.
-- Human-readable strings. Indices are above numeric constants.
lexit.catnames = {
   "Keyword",
   "Identifier",
   "NumericLiteral",
   "StringLiteral",
   "Operator",
   "Punctuation",
   "Malformed"
}


-- *********************************************************************
-- Kind-of-Character Functions
-- *********************************************************************

-- All functions return false when given a string whose length is not
-- exactly 1.


-- isLetter
-- Returns true if string c is a letter character, false otherwise.
local function isLetter(c)
   if c:len() ~= 1 then
      return false
   elseif c >= "A" and c <= "Z" then
      return true
   elseif c >= "a" and c <= "z" then
      return true
   else
      return false
   end
end


-- isDigit
-- Returns true if string c is a digit character, false otherwise.
local function isDigit(c)
   if c:len() ~= 1 then
      return false
   elseif c >= "0" and c <= "9" then
      return true
   else
      return false
   end
end


-- isWhitespace
-- Returns true if string c is a whitespace character, false otherwise.
local function isWhitespace(c)
   if c:len() ~= 1 then
      return false
   elseif c == " " or c == "\t" or c == "\n" or c == "\r"
   or c == "\f" then
      return true
   else
      return false
   end
end


-- isIllegal
-- Returns true if string c is an illegal character, false otherwise.
local function isIllegal(c)
   if c:len() ~= 1 then
      return false
   elseif isWhitespace(c) then
      return false
   elseif c >= " " and c <= "~" then
      return false
   else
      return true
   end
end


-- *********************************************************************
-- The Lexer
-- *********************************************************************


-- lex
-- Our lexer
-- Intended for use in a for-in loop:
--     for lexstr, cat in lexit.lex(program) do
-- Here, lexstr is the string form of a lexeme, and cat is a number
-- representing a lexeme category. (See Public Constants.)
function lexit.lex(program)
   -- ***** Variables *****

   local pos         -- Index of next character in program
                     -- INVARIANT: when getLexeme is called, pos is
                     --  EITHER the index of the first character of the
                     --  next lexeme OR program:len()+1
   local state       -- Current state for our state machine
   local ch          -- Current character
   local lexstr      -- The lexeme, so far
   local category    -- Category of lexeme, set when state set to DONE
   local handlers    -- Dispatch table; value created later
   local strQuote    -- Last quote character to begin a string literal
   local prevLexstr  -- Previous lexeme

   -- ***** States *****

   local DONE           = 0
   local START          = 1
   local LETTER         = 2
   local DIGIT          = 3
   local PLUS_MINUS     = 4
   local EXPONENT       = 5
   local STRING         = 6
   local AMPERSAND      = 7
   local PIPE           = 8
   local EQUALS         = 9

   -- ***** Character-Related Utility Functions *****

   -- currChar
   -- Return the current character, at index pos in program. Return
   -- value is a single-character string, or the empty string if pos is
   -- past the end.
   local function currChar()
      return program:sub(pos, pos)
   end

   -- nextChar
   -- Return the next character, at index pos+1 in program. Return
   -- value is a single-character string, or the empty string if pos+1
   -- is past the end.
   local function nextChar()
      return program:sub(pos+1, pos+1)
   end

   -- nextNextChar
   -- Return the character after the next character, at index pos+2 in program.
   -- Return value is a single-character string, or the empty string if pos+2
   -- is past the end.
   local function nextNextChar()
      return program:sub(pos+2, pos+2)
   end

   -- drop1
   -- Move pos to the next character.
   local function drop1()
      pos = pos+1
   end

   -- add1
   -- Add the current character to the lexeme, moving pos to the next
   -- character.
   local function add1()
      lexstr = lexstr .. currChar()
      drop1()
   end

   -- skipWhitespace
   -- Skip whitespace and comments, moving pos to the beginning of
   -- the next lexeme, or to program:len()+1.
   local function skipWhitespace()
      while isWhitespace(currChar()) do
         drop1()
      end

      if currChar() == "#" then
         drop1()
         while currChar() ~= "\n" and currChar() ~= "" do
            drop1()
         end
         skipWhitespace()
      end
   end

   -- ***** Other Utility Functions *****

   -- maximalMunchSpecialCase
   -- Return true if the previous lexeme indicates an exception to the maximal
   -- munch rule, false otherwise.
   local function maximalMunchSpecialCase()
      return category == lexit.ID or category == lexit.NUMLIT
         or prevLexstr == "]" or prevLexstr == ")" or prevLexstr == "true"
         or prevLexstr == "false"
   end

   -- ***** State-Handler Functions *****

   -- handle_DONE
   -- Handle the DONE state by crashing.
   local function handle_DONE()
      io.write("ERROR: 'DONE' state should not be handled\n")
      assert(false)
   end

   -- handle_START
   -- Handle the START state.
   local function handle_START()
      if isIllegal(ch) then
         add1()
         state = DONE
         category = lexit.MAL
      elseif isLetter(ch) or ch == "_" then
         add1()
         state = LETTER
      elseif isDigit(ch) then
         add1()
         state = DIGIT
      elseif ch == "+" or ch == "-" then
         add1()
         state = PLUS_MINUS
      elseif ch == "'" or ch == '"' then
         strQuote = ch
         add1()
         state = STRING
      elseif ch == "&" then
         add1()
         state = AMPERSAND
      elseif ch == "|" then
         add1()
         state = PIPE
      elseif ch == "=" or ch == "!" or ch == "<" or ch == ">" then
         add1()
         state = EQUALS
      elseif ch == "*" or ch == "/" or ch == "%" or ch == "[" or ch == "]" then
         add1()
         state = DONE
         category = lexit.OP
      else
         add1()
         state = DONE
         category = lexit.PUNCT
      end
   end

   -- handle_LETTER
   -- Handle the LETTER state.
   local function handle_LETTER()
      if isLetter(ch) or isDigit(ch) or ch == "_" then
         add1()
      else
         state = DONE
         if lexstr == "cr" or lexstr == "def" or lexstr == "else"
         or lexstr == "elseif" or lexstr == "end" or lexstr == "false"
         or lexstr == "if" or lexstr == "readnum" or lexstr == "return"
         or lexstr == "true" or lexstr == "while" or lexstr == "write" then
            category = lexit.KEY
         else
            category = lexit.ID
         end
      end
   end

   -- handle_DIGIT
   -- Handle the DIGIT state.
   local function handle_DIGIT()
      if isDigit(ch) then
         add1()
      elseif (ch == "e" or ch == "E") and isDigit(nextChar()) then
         add1()  -- add e/E to lexeme
         add1()  -- add digit to lexeme (optional)
         state = EXPONENT
      elseif (ch == "e" or ch == "E") and nextChar() == "+"
      and isDigit(nextNextChar()) then
         add1()  -- add e/E to lexeme
         add1()  -- add + to lexeme
         add1()  -- add digit to lexeme (optional)
         state = EXPONENT
      else
         state = DONE
         category = lexit.NUMLIT
      end
   end

   -- handle_PLUS_MINUS
   -- Handle the PLUS_MINUS state.
   local function handle_PLUS_MINUS()
      if isDigit(ch) and not maximalMunchSpecialCase() then
         add1()
         state = DIGIT
      else
         state = DONE
         category = lexit.OP
      end
   end

   -- handle_EXPONENT
   -- Handle the EXPONENT state.
   local function handle_EXPONENT()
      if isDigit(ch) then
         add1()
      else
         state = DONE
         category = lexit.NUMLIT
      end
   end

   -- handle_STRING
   -- Handle the STRING state.
   local function handle_STRING()
      if ch == strQuote then
         add1()
         state = DONE
         category = lexit.STRLIT
      elseif ch == "\n" then
         add1()
         state = DONE
         category = lexit.MAL
      elseif ch == "" then
         state = DONE
         category = lexit.MAL
      else
         add1()
      end
   end

   -- handle_AMPERSAND
   -- Handle the AMPERSAND state.
   local function handle_AMPERSAND()
      if ch == "&" then
         add1()
         state = DONE
         category = lexit.OP
      else
         state = DONE
         category = lexit.PUNCT
      end
   end

   -- handle_PIPE
   -- Handle the PIPE state.
   local function handle_PIPE()
      if ch == "|" then
         add1()
         state = DONE
         category = lexit.OP
      else
         state = DONE
         category = lexit.PUNCT
      end
   end

   -- handle_EQUALS
   -- Handle the EQUALS state.
   local function handle_EQUALS()
      if ch == "=" then
         add1()
      end
      state = DONE
      category = lexit.OP
   end

   -- ***** Table of State-Handler Functions *****

   handlers = {
      [DONE]=handle_DONE,
      [START]=handle_START,
      [LETTER]=handle_LETTER,
      [DIGIT]=handle_DIGIT,
      [PLUS_MINUS]=handle_PLUS_MINUS,
      [EXPONENT]=handle_EXPONENT,
      [STRING]=handle_STRING,
      [AMPERSAND]=handle_AMPERSAND,
      [PIPE]=handle_PIPE,
      [EQUALS]=handle_EQUALS,
   }

   -- ***** Iterator Function *****

   -- getLexeme
   -- Called each time through the for-in loop.
   -- Returns a pair: lexeme-string (string) and category (int), or
   -- nil, nil if no more lexemes.
   local function getLexeme(dummy1, dummy2)
      if pos > program:len() then
         return nil, nil
      end
      lexstr = ""
      state = START
      while state ~= DONE do
         ch = currChar()
         handlers[state]()
      end

      skipWhitespace()
      prevLexstr = lexstr
      return lexstr, category
   end

   -- ***** Body of Function lex *****

   -- Initialize & return the iterator function
   pos = 1
   skipWhitespace()
   return getLexeme, nil, nil
end


-- *********************************************************************
-- Module Table Return
-- *********************************************************************


return lexit
