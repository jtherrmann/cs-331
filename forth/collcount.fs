: odd? 2 mod ;

: collatz-function
  { n }
  n odd? if
    3 n * 1 +
  else
    n 2 /
  then
;

: collcount-rec
  { n count }
  n 1 = if
    count
  else
    n collatz-function
    count 1 +
    recurse
  then
;

: collcount ( n -- c ) 0 collcount-rec ;
