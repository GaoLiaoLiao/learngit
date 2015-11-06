;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname rev-acc) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))

;; [ListOf X] -> [ListOf X]
;; return the reversed list
(define (rev l)
  (cond
    [(empty? l) '()]
    [(cons? l)
     (add-at-end (first l)
                 (rev (rest l)))]))

(check-expect (rev '()) '())
(check-expect (rev '(a)) '(a))
(check-expect (rev '(a b)) '(b a))
(check-expect (rev '(a b c)) '(c b a))

;; X [ListOf X] -> [ListOf X]
;; add e to the end of l
(define (add-at-end e l)
  (cond
    [(empty? l)
     (cons e '())]
    [(cons? l)
     (cons (first l) (add-at-end e (rest l)))]))

(check-expect (add-at-end 'z '()) '(z))
(check-expect (add-at-end 'z '(a)) '(a z))
(check-expect (add-at-end 'z '(a b)) '(a b z))
(check-expect (add-at-end '(z) '((a) (b))) '((a) (b) (z)))


;; [ListOf X] -> [ListOf X]
;; returns l in reverse order
(define (rev2 l)
  (local
    [;; [ListOf X] [ListOf X] -> [ListOf X]
     ;; given a list and previous elements in reverse order, returns the
     ;; full reversed list
     (define (rev/a l p-rev)
       (cond
         [(empty? l) p-rev]
         [(cons? l)
          (rev/a (rest l) (cons (first l) p-rev))]))]
  (rev/a l '())))


(check-expect (rev2 '()) '())
(check-expect (rev2 '(a)) '(a))
(check-expect (rev2 '(a b)) '(b a))
(check-expect (rev2 '(a b c)) '(c b a))

;; [where an accumulator might be needed:]
;; [1. processing results of recursion with other recursive functions]
;; [2. a generative algorithm that might fail to produce a result for some inputs]

;; Accumulator template
;; Domain -> Range
#;
(define (function d0)
  (local (; Domain AccumulatorDomain -> Range
          ; accumulator statement ...
          (define (function/a d a)
            ...))
    (function/a d0 a0)))

;; 1) create accumulator template (above)
;; 2) accumulator statement: explain the value of a in terms of d and d0
;; 3) use (2) to determine d0
;; 4) use (2) to compute value of a in recursive calls


;; A SymTree is one of
;; - (make-node Symbol SymTree SymTree)
;; - (make-leaf Symbol)
(define-struct node [s l r])
(define-struct leaf [s])

(define t1
  (make-node 'd
           (make-node 'b
                      (make-leaf 'a)
                      (make-leaf 'c))
           (make-node 'f
                      (make-leaf 'e)
                      (make-leaf 'g))))
(define t2
  (make-node 'b
             (make-leaf 'a)
             (make-node 'd
                        (make-leaf 'c)
                        (make-leaf 'e))))

;; SymTree -> [ListOf Symbol]
;; in order traversal
(define (in-order t)
  (cond
    [(node? t)
     (append
      (in-order (node-l t))
      (list (node-s t))
      (in-order (node-r t)))]
    [(leaf? t)
     (list (leaf-s t))]))

(check-expect (in-order t1)
              '(a b c d e f g))
(check-expect (in-order t2)
              '(a b c d e))

;; SymTree -> [ListOf Symbol]
;; in order traversal
(define (in-order2 t)
  (local (;; SymTree [ListOf Symbol] -> [ListOf Symbol]
          ;; a is the reverse of the traversal from the previous nodes
          (define (traverse/a t a)
            (cond
              [(node? t)
               (traverse/a (node-r t)
                           (cons (node-s t)
                                 (traverse/a (node-l t) a)))]
              [(leaf? t)
               (cons (leaf-s t) a)])))
    (reverse (traverse/a t '()))))

(check-expect (in-order2 t1)
              '(a b c d e f g))
(check-expect (in-order2 t2)
              '(a b c d e))


