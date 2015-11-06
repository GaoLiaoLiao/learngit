;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname djik-notes) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #t #t none #f ((lib "image.rkt" "teachpack" "2htdp")) #f)))
;; A Weight is one of:
;; -- ∞
;; -- NonNegativeNumber
(define ∞ '∞)
(define (∞? x) (and (symbol? x) (symbol=? x ∞)))
;;
;; Interpretation: A Weight is the weight on an edge in a weighted, directed
;; graph, where
;; -- ∞ stands for infinity, meaning there is no edge, and
;; -- a number means that number is the weight of the edge.

;; A WDG (weighted directed graph) is [VectorOf [VectorOf Weight]]
;;
;; Invariant: Given a WDG g, for all naturals i < (vector-length g),
;; -- (= (vector-length g) (vector-length (vector-ref g i))), and
;; -- (= 0 (vector-ref (vector-ref g i) i))
;; That is, a WDG is a square, 2-D matrix, and the diagonal is all 0s.
;;
;; Interpretation: Nodes are labeled from 0 to (- (vector-length g) 1).
;; Given two nodes i and j, (vector-ref (vector-ref g i) j) is the weight
;; of the edge between i and j.

;; Interpretation helpers:

;; WDG -> N
;; The number of nodes in graph g
(define (graph-node-count g)
  (vector-length g))

;; WDG N N -> Weight
;; The weight of the edge from i to j in graph g
(define (graph-weight-between g i j)
  (vector-ref (vector-ref g i) j))

;; Examples:

(define G-DISCRETE
  (vector (vector 0 ∞ ∞ ∞ ∞)
          (vector ∞ 0 ∞ ∞ ∞)
          (vector ∞ ∞ 0 ∞ ∞)
          (vector ∞ ∞ ∞ 0 ∞)
          (vector ∞ ∞ ∞ ∞ 0)))

(define G-LINE
  (vector (vector 0 2 ∞ ∞ ∞)
          (vector ∞ 0 4 ∞ ∞)
          (vector ∞ ∞ 0 6 ∞)
          (vector ∞ ∞ ∞ 0 8)
          (vector ∞ ∞ ∞ ∞ 0)))

(define G-LONGCUT
  (vector (vector 0 2 ∞ ∞ 40)
          (vector ∞ 0 4 ∞  ∞)
          (vector ∞ ∞ 0 6  ∞)
          (vector ∞ ∞ ∞ 0  8)
          (vector ∞ ∞ ∞ ∞  0)))

(define G-SHORTCUT
  (vector (vector 0 2 ∞ ∞ ∞)
          (vector ∞ 0 4 1 ∞)
          (vector ∞ ∞ 0 6 ∞)
          (vector ∞ ∞ ∞ 0 8)
          (vector ∞ ∞ ∞ ∞ 0)))

;; Example from https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm#Algorithm
(define G6
  (vector (vector  0  7  9  ∞  ∞ 14)
          (vector  7  0 10 15  ∞  ∞)
          (vector  9 10  0 11  ∞  2)
          (vector  ∞ 15 11  0  6  ∞)
          (vector  ∞  ∞  ∞  6  0  9)
          (vector 14  ∞  2  ∞  9  0)))

;; Weight Weight -> Boolean
;; Determines whether w1 is less than l2
;;
;; Examples:
;;  - 3 < 4
;;  - 4 not < 3
;;  - 3 not < 3
;;  - 3 < ∞
;;  - ∞ not < 3
;;  - ∞ not < ∞
;;
;; Strategy: structural decomposition, pairwise:
(define (weight<? w1 w2)
  (cond
    [(∞? w1) #false]
    [(∞? w2) #true]
    [else (< w1 w2)]))

(check-expect (weight<? 3 4) #true)
(check-expect (weight<? 3 3) #false)
(check-expect (weight<? 3 2) #false)
(check-expect (weight<? 3 ∞) #true)
(check-expect (weight<? ∞ 3) #false)
(check-expect (weight<? ∞ ∞) #false)

;; Weight Weight -> Weight
;; Adds two weights.
;;
;; Examples:
;;  - n + ∞ = ∞
;;  - ∞ + n = ∞
;;  - 3 + 4 = 7
;;
;; Strategy: structural decomposition
(define (weight+ w1 w2)
  (cond
    [(∞? w1) ∞]
    [(∞? w2) ∞]
    [else (+ w1 w2)]))

(check-expect (weight+ ∞ 6) ∞)
(check-expect (weight+ 5 ∞) ∞)
(check-expect (weight+ 5 6) 11)
(check-expect (weight+ ∞ ∞) ∞)


;; WDG N -> [VectorOf Weight]
;; find weight of minimum path to all nodes from src in g
;; examples:
;; given G-SHORTCUT 0 -> [0 2 6 3 11]
;; given G-LINE 0 -> [0 2 6 12 20]
;;
;; strategy: generative recursion
(define (djikstra g src)
  (local [(define todo0 (build-list (graph-node-count g)
                                    (lambda (x) x)))
          (define weights (build-vector (graph-node-count g)
                                        (lambda (n)
                                          (if (= n src) 0 ∞))))
          (define (get-weight n)
            (vector-ref weights n))
          ;; N N -> #true
          ;; Reduces the weight of the path to u if getting there via v is less than
          ;; what we have so far.
          (define (relax v u)
            (local
              [(define old-weight (get-weight u))
               (define new-weight (weight+ (get-weight v)
                                           (graph-weight-between g v u)))]
              (if (weight<? new-weight old-weight)
                  (vector-set! weights u new-weight)
                  #true)))
          ;; [ListOf N] -> [VectorOf Weight]
          ;; termination: we remove one element from todo on each recursive call
          (define (loop todo)
            (cond
              [(empty? todo) weights]
              [else
               (local [(define v (argminf get-weight weight<? todo))]
                 (begin
                   (for-each (lambda (u) (relax v u))
                             (build-list (graph-node-count g)
                                         (lambda (x) x)))
                   (loop (remove v todo))))]))]
    
    (loop todo0)))


(check-expect (djikstra G-SHORTCUT 0)
              (vector 0 2 6 3 11))
(check-expect (djikstra G-DISCRETE 0)
              (vector 0 ∞ ∞ ∞ ∞))
(check-expect (djikstra G-DISCRETE 2)
              (vector ∞ ∞ 0 ∞ ∞))
(check-expect (djikstra G-LINE 0)
              (vector 0 2 6 12 20))
(check-expect (djikstra G-LINE 2)
              (vector ∞ ∞ 0 6 14))
(check-expect (djikstra G-LONGCUT 0)
              (vector 0 2 6 12 20))
(check-expect (djikstra G-SHORTCUT 0)
              (vector 0 2 6 3 11))
(check-expect (djikstra G6 0)
              (vector 0 7 9 20 20 11))



;; [N -> W] [W W -> Boolean] [NEListOf N] -> N
;; finds element of xs that minimizes (f x) with
;; respect to <?
;; first < '((5 4) (2 3) (7 8) (2 1)) -> '(2 3)
;; first > '((5 4) (2 3) (7 8) (2 1)) -> '(7 8)
;; second < '((5 4) (2 3) (7 8) (2 1)) -> '(2 1)
;;
;; strategy: structural decomposition of [ListOf N]
(define (argminf f <? xs)
  (local
    [(define (find cur-el cur-val rem)
       (cond
         [(empty? rem)
          cur-el]
         [(cons? rem)
          (local [(define el (first rem))
                  (define f-val (f el))]
            (if (<? f-val cur-val)
                (find el f-val (rest rem))
                (find cur-el cur-val (rest rem))))]))]
    (find (first xs) (f (first xs)) (rest xs))))

(check-expect (argminf first < '((5 4) (2 3) (7 8) (2 1))) '(2 3))
(check-expect (argminf first > '((5 4) (2 3) (7 8) (2 1))) '(7 8))
(check-expect (argminf (lambda (p)
                         (first (rest p)))
                       < '((5 4) (2 3) (7 8) (2 1))) '(2 1))









