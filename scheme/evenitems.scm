#lang scheme

;; evenitems.scm
;; Jake Herrmann
;; 27 April 2019
;;
;; CS 331 Spring 2019
;; Source code for Assignment 7 Exercise C.


;; Take a list and return a list of the even-indexed items of the original
;; list.
(define (evenitems xs)
  (if (or (null? xs) (null? (cdr xs)))
      xs
      (cons (car xs) (evenitems (cddr xs)))))
