\ collcount.fs
\ Jake Herrmann
\ 27 April 2019
\
\ CS 331 Spring 2019
\ Source code for Assignment 7 Exercise B.


\ Take an integer and return whether it's odd.
: odd? 2 mod ;


\ The Collatz function.
: collatz-function
  { n }
  n odd? if
    3 n * 1 +
  else
    n 2 /
  then
;


\ Recursive helper function for collcount.
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


\ Take a positive integer n and return the number of iterations of the Collatz
\ function required to take n to 1.
: collcount ( n -- c ) 0 collcount-rec ;
