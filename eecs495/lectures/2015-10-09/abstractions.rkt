;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname abstractions) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;; A [ListOf X] is one of:
;; - '()
;; - (cons X [ListOf X])
#;
;; template for [ListOf X]
(define (process-list lst)
  (cond
    [(empty? lst) ...]
    [(cons? lst) ... (first lst) ...
                 ... (process-list (rest lst)) ...]))

;; A Posn is
;; (make-posn Number Number)
;; interpretation: a coordinate in the plane


;; [ListOf Number] -> [ListOf Number]
;; Adds 7 to each number
;; [ examples ... ]
(define (add7-lon lon)
  (map-2 lon add7))

;; [ tests below ]

;; [ListOf Posn] -> [ListOf Number]
;; extract x coordinates
;; [ examples ... ]
(define (get-xs lop)
  (map-2 lop posn-x))

;; [ListOf X] [X -> Y] -> [ListOf Y]
;; apply the function to each element in the list
;; [ this is map ]
(define (map-2 lst f)
  (cond
    [(empty? lst) '()]
    [(cons? lst)
     (cons (f (first lst))
           (map-2 (rest lst) f))]))

;; [ tests below ]

;; Number -> Number
;; adds 7
(define (add7 num)
  (+ num 7))

(check-expect (add7-lon '()) '())
(check-expect (add7-lon '(1 2 3)) '(8 9 10))
(check-expect (add7-lon '(-1 -2 -3)) '(6 5 4))
(check-expect (add7-lon '(1 0 1 0 1)) '(8 7 8 7 8))

(check-expect (get-xs '()) '())
(check-expect (get-xs (list (make-posn 0 3)
                            (make-posn 3 4)))
              (list 0 3))
(check-expect (get-xs (list (make-posn 0 0)
                            (make-posn -1 -1)
                            (make-posn 1 1)
                            (make-posn -2 2)))
              (list 0 -1 1 -2))

;; write a function that adds n to each element in a list of numbers
;; [ListOf Number] Number -> [ListOf Number]
;; examples:
;; 5 '() --> '()
;; 0 '(1 2 3) --> '(1 2 3]
;; -1 '(-1 0 1) --> '(-2 -1 0)
;; strategy: function composition
(define (addn-lon lon n)
  (local [;; Number -> Number
          ;; adds n to m
          (define (addn m)
            (+ n m))]
    (map addn lon)))

(check-expect (addn-lon '() 5) '())
(check-expect (addn-lon '(1 2 3) 0) '(1 2 3))
(check-expect (addn-lon '(-1 0 1) -1) '(-2 -1 0))

;; abstracting over the template:
;; [ListOf X] Y [X Y -> Y] -> Y
(define (reduce lst base combine)
  (cond
    [(empty? lst) base]
    [(cons? lst)
     (combine (first lst)
              (reduce (rest lst) base combine))]))

;; [Listof Number] --> Number
;; sums a list of numbers
;; [examples ...]
;; examples:
;; '() --> 0
;; '(1 2 3)) --> 6
;; strategy: function composition
(define (sumlon lon)
  (reduce lon 0 +))

(check-expect (sumlon '()) 0)
(check-expect (sumlon '(1 2 3)) 6)

;; now define map in terms of reduce:
;; [ListOf X] [X -> Y] -> [ListOf Y]
;; '() f -> '()
;; (list (make-posn 1 2)) posn-x -> '(1)
;; strategy: function composition
(define (map-3 lst f)
  (local [;; X [ListOf Y] -> [ListOf Y]
          ;; apply f to x and add it to the result list
          (define (combine thing lst-2)
            (cons (f thing) lst-2))]
  (reduce lst '() combine)))

(check-expect (map-3 '() sumlon) '())
(check-expect (map-3 (list (make-posn 1 2)) posn-x) '(1))








