;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname sssp) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #t #t none #f ((lib "image.rkt" "teachpack" "2htdp")) #f)))
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
;; Finds the minimum path weight from node src to each node.
;;
;; Examples:
;;  - given graph G-LINE (0 -2> 1 -4> 2 -6> 3 -8> 4), the minimum distances
;;    from 0 the nodes, in order, are 0, 2, 6, 12, and 20
;;  - given graph G-LONGCUT (like G-line with an additional edge 0 -40> 4),
;;    the result is the same
;;  - given graph G-SHORTCUT (like G-line with an additional edge 1 -1> 3),
;;    the result is 0, 2, 6, 3, 11
;;
;; The resulting vector has the same length as the graph has nodes, and the
;; weight of each node is in the corresponding position in the vector.
(define (sssp/dijkstra g src)
  (local
    [;; [VectorOf Weight]
     ;; The result vector, initially all ∞ except 0 for src.
     (define weights
       (build-vector (graph-node-count g)
                     (lambda (n) (if (= n src) 0 ∞))))

     ;; N -> Weight
     ;; The least weight to node v found thus far.
     (define (get-weight v)
       (vector-ref weights v))
     
     ;; [ListOf N] -> [VectorOf Weight]
     ;; Considers each element of todo and relaxes the weight for its
     ;; successors.
     ;;
     ;; Strategy: Generative recursion
     ;; Termination: We know that v returned by argminf is an element of todo,
     ;; so (remove v todo) is shorter than todo, getting us closer to the
     ;; (empty? todo) base case.
     (define (loop todo)
       (if (empty? todo)
           weights
           (local [(define v (argminf get-weight weight<? todo))]
             (if (∞? (get-weight v))
                 weights
                 (begin
                   (for-each (lambda (u) (relax v u))
                             (build-list (graph-node-count g) identity))
                   (loop (remove v todo)))))))
     
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
           #true)))]
    ;;
    (loop (build-list (graph-node-count g) (lambda (i) i)))))

(check-expect (sssp/dijkstra G-DISCRETE 0)
              (vector 0 ∞ ∞ ∞ ∞))
(check-expect (sssp/dijkstra G-DISCRETE 2)
              (vector ∞ ∞ 0 ∞ ∞))
(check-expect (sssp/dijkstra G-LINE 0)
              (vector 0 2 6 12 20))
(check-expect (sssp/dijkstra G-LINE 2)
              (vector ∞ ∞ 0 6 14))
(check-expect (sssp/dijkstra G-LONGCUT 0)
              (vector 0 2 6 12 20))
(check-expect (sssp/dijkstra G-SHORTCUT 0)
              (vector 0 2 6 3 11))
(check-expect (sssp/dijkstra G6 0)
              (vector 0 7 9 20 20 11))

;; [A -> R] [R R -> Boolean] [NEListOf A] -> A
;; Finds the element x of xs that minimizes (f x) subject to the
;; total order given by <?. Ties go to the earlier element in the
;; list.
;;
;; Examples:
;;  - given first, <, and '((5 4) (2 3) (7 8) (2 1)), returns '(2 3)
;;  - given first, >, and same list, returns '(7 8)
;;  - given length, >, and a list of lists, returns the longest sublist
;;
;; Strategy: structural decomposition (xs)
(define (argminf f <? xs)
  (local
    [;; A [MinFound A R] is (make-min-found A R)
     ;; Interp. (make-min-found x y) means that argument x minimizes (f x),
     ;; and y = (f x).
     (define-struct min-found [arg val])
     
     ;; A -> [MinFound A R]
     ;; Builds a MinFound for the given argument.
     (define (min-found-at arg)
       (make-min-found arg (f arg)))

     ;; [MinFound A R] [MinFound A R] -> [MinFound A R]
     ;; Returns the MinFound with the lesser value; ties go to first argument
     (define (choose-min preferred dispreferred)
       (if (<? (min-found-val dispreferred)
               (min-found-val preferred))
           dispreferred
           preferred))
     
     ;; [ListOf A] -> [MinFound A R]
     ;; Finds the MinFound among the arguments in list todo.
     (define (loop todo)
       (cond
         [(empty? (rest todo))
          (min-found-at (first todo))]
         [(cons? (rest todo))
          (choose-min (min-found-at (first todo))
                      (loop (rest todo)))]))]
    
    (min-found-arg (loop xs))))

(check-expect (argminf first < '((4 5))) '(4 5))
(check-expect (argminf first < '((4 5) (2 8) (7 9) (2 6))) '(2 8))
(check-expect (argminf first > '((4 5) (2 8) (7 9) (2 6))) '(7 9))
(check-expect (argminf length > '(() (1 3) (3) (8 4 6 2) (2 5 9))) '(8 4 6 2))
(check-error (argminf length > '()))
