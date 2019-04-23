#lang scheme

(define (evenitems xs)
  (if (or (null? xs) (null? (cdr xs)))
      xs
      (cons (car xs) (evenitems (cddr xs)))))

;; TODO remove

(println '())
(println (evenitems '()))
(newline)

(println '(1))
(println (evenitems '(1)))
(newline)

(println '(1))
(println (evenitems '(1 2)))
(newline)

(println '(1 3))
(println (evenitems '(1 2 3)))
(newline)

(println '(1 3))
(println (evenitems '(1 2 3 4)))
(newline)

(println '(1 3 5))
(println (evenitems '(1 2 3 4 5)))
(newline)

(println '(1 3 5))
(println (evenitems '(1 2 3 4 5 6)))
(newline)

(println '(1 3 5 7))
(println (evenitems '(1 2 3 4 5 6 7)))
(newline)

(println '(1 3 5 7))
(println (evenitems '(1 2 3 4 5 6 7 8)))
(newline)

(println '(1 3 5 7 9))
(println (evenitems '(1 2 3 4 5 6 7 8 9)))
(newline)

(println '(1 3 5 7 9))
(println (evenitems '(1 2 3 4 5 6 7 8 9 10)))
(newline)

(println '(8 1))
(println (evenitems '(8 3 1 9)))
(newline)

(println '(8 1 6))
(println (evenitems '(8 3 1 9 6)))
(newline)

(println '("dog" #f))
(println (evenitems '("dog" 3.2 #f)))
(newline)

(println '(1 3 5 7 9 11 13 15))
(println (evenitems '(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16)))
(newline)
