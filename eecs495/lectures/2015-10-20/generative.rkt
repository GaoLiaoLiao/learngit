;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname generative) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
#|
  Problems:

    - bisection method

    - merge sort 

    - Graph problems/algorithms:
        - BFS
        - DFS
        - generic graph search

|#

#|
In numerical analysis, the bisection method finds a zero of a function by
performing binary search on some span of it in which a zero is guaranteed
to exist. If we have a continuous function f that is negative at some point x0
and positive at some point x1, then there is a zero somewhere in between.

Without loss of generality, let x0 < x1, f(x0) < 0, and f(x1) > 0. Then the
let the halfway point p = (x0 + x1)/2. Then one of:

  - p = 0, so p is the zero
  - p < 0, so there's a zero in interval (p, x1)
  - p > 0, so there's a zero in interval (x0, p)

That is, given an interval with a zero, we can transform it into a smaller
problem--an interval half the size. Thus we can make the interval arbitrarily
small via generative recursion.
|#

;; [Number -> Number] Number Number PositiveNumber -> Number
;; Approximates the zero of a function by finding a result x such that
;; |f(x)| ≤ delta.
;;
;; PRECONDITION: f(x0) < 0 and f(x1) > 0.
;;
;; Examples:
;;
;;  - if f(x) = x, interval (-1, 1), any delta, result should be 0
;;  - if f(x) = x, interval (-1, 3), any delta, result should be 0
;;  - if f(x) = x, interval (-1, 2), delta = 0.2, result should be 0.125
;;  - if f(x) = x, interval (-1, 2), delta = 0.1, result should be -0.0625
;;  - if f(x) = 2x, interval (-1, 2), delta = 0.2, result should be -0.0625
;;
;; Strategy: generative recursion
;; Termination argument: Assuming f is not pathological (?), as p approaches
;; the actual zero, f(p) approaches 0. Each subproblem moves one bound or the
;; other closer to the actual zero, which means that the bounds close in on it,
;; which means that p closes in on it, which means that f(p) approaches 0,
;; which means it will be less than delta at some point.
(define (find-zero/bisection f x0 x1 delta)
  (local
   [(define p (/ (+ x0 x1) 2))
    (define fp (f p))]
   (cond
     [(<= (- delta) fp delta) p]
     [(< fp 0)
      (find-zero/bisection f p x1 delta)]
     [else ;; (< 0 fp)
      (find-zero/bisection f x0 p delta)])))

(check-expect (find-zero/bisection (lambda (x) x) -1 1 0.01) 0)
(check-expect (find-zero/bisection (lambda (x) x) -1 3 0.01) 0)
(check-expect (find-zero/bisection (lambda (x) x) -1 2 0.2) 0.125)
(check-expect (find-zero/bisection (lambda (x) x) -1 2 0.1) -0.0625)
(check-expect (find-zero/bisection (lambda (x) (* 2 x)) -1 2 0.2) -0.0625)

;; calculate (sqrt 7)
;; x = (sqrt 7)
;; x^2 = 7
;; x^2 - 7 = 0
(check-within (find-zero/bisection (lambda (x) (- (sqr x) 7)) #i0 #i7 #i0.0001)
              (sqrt 7) 0.0001)


;;
;; GRAPH ALGORITHMS
;;

;; A [DiGraph X] is [ListOf [NodeInfo X]]
;; A [NodeInfo X] is (make-node-info X [ListOf X]]
(define-struct node-info (node succs))

;; Interpretation:
;; If g is a [DiGraph X] then,
;;   - (map node-info-node g) is a list of the vertices of g
;;   - (foldl append '()
;;           (map (lambda (ni) (map (lambda (s) (list (node-info-node ni) s))
;;                                  (node-info-succs ni)))
;;                g))
;;     is a list of the edges of g

;; Invariant: every node that appears in a node-info-succs list also appears
;; as a node-info-node.

;; Examples:

;; The empty graph
(define G0 '())

;; A one-element graph:
(define G1 (list (make-node-info 'a '())))

;; A one-element graph with self-loop:
(define G1* (list (make-node-info 'a '(a))))

;; A linear graph of size 5:
(define G-LINE (list (make-node-info 'a '(b))
                     (make-node-info 'b '(c))
                     (make-node-info 'c '(d))
                     (make-node-info 'd '(e))
                     (make-node-info 'e '())))

;; A cycle of size 5:
(define G-CYCLE (list (make-node-info 'a '(b))
                      (make-node-info 'b '(c))
                      (make-node-info 'c '(d))
                      (make-node-info 'd '(e))
                      (make-node-info 'e '(a))))

;; A binary tree:
(define G-TREE (list (make-node-info 'a '(b c))
                     (make-node-info 'b '(d e))
                     (make-node-info 'c '(f g))
                     (make-node-info 'd '())
                     (make-node-info 'e '())
                     (make-node-info 'f '(h))
                     (make-node-info 'g '())
                     (make-node-info 'h '())))
                                     
;; An upward binary tree:
(define G-UP-TREE (list (make-node-info 'a '())
                        (make-node-info 'b '(a))
                        (make-node-info 'c '(a))
                        (make-node-info 'd '(b))
                        (make-node-info 'e '(b))
                        (make-node-info 'f '(c))
                        (make-node-info 'g '(c))))

;; A non-trival graph
(define G7 (list (make-node-info 'a '(b e))
                 (make-node-info 'b '(c))
                 (make-node-info 'c '(d))
                 (make-node-info 'd '(a g))
                 (make-node-info 'e '(c))
                 (make-node-info 'f '(b c d))
                 (make-node-info 'g '())))

;; [Graph X] X -> [ListOf X]
;; Finds the successors of node n in graph g.
;;
;; Examples:
;;   - Given G1 'a, returns '()
;;   - Given G1* 'a, returns '(a)
;;   - Given G7 'g, returns '()
;;   - Given G7 'f, returns '(b c d)
;;
;; Strategy: structural decomposition
(define (graph-successors g n)
  (cond
    [(empty? g) '()]
    [(cons? g)  (if (equal? n (node-info-node (first g)))
                    (node-info-succs (first g))
                    (graph-successors (rest g) n))]))

(check-expect (graph-successors G1 'a) '())
(check-expect (graph-successors G1* 'a) '(a))
(check-expect (graph-successors G7 'g) '())
(check-expect (graph-successors G7 'f) '(b c d))


;; [Graph X] X -> [ListOf X]
;; Finds all the nodes in graph g reachable from starting node n.
;;
;; PRECONDITION: n is a node of g
;;
;; Examples:
;;
;;   - given a single element graph, returns list of that element
;;   - given graph a -> b -> c -> d -> e, starting at a, returns '(a b c d e)
;;   - given graph a -> b -> c -> d -> e, starting at c, returns '(c d e)
;;   - given graph G7, starting at f, returns '(f b c d a e g)
;;   - given graph G-TREE, starting at the root (a), returns '(a b d e c f h g)
;;
;; Strategy: generative recursion
;; Termination: see helper
(define (find-reachable/dfs g n)
  (local
    ;; A problem is a list of nodes we've visited and a list of nodes to visit.
    ;;
    ;; The trivial problem is when there are no nodes left to visit.
    ;;
    ;; We simplify a problem to a subproblem by visiting a node in to-visit,
    ;; and then one of:
    ;;
    ;;   - If we've seen it before, the subproblem has the same `visited` and
    ;;     shorter `to-visit`. This gets us closer to the trivial problem
    ;;     directly.
    ;;
    ;;   - If we haven't seen the node before, then the node is added to
    ;;     `visited`, and potentially zero or more added to `to-visit`. This
    ;;     does not obviously get us closer to the trivial problem, but consider
    ;;     that only a finite number of nodes may be added to `visited`, since
    ;;     the graph has a finite number of nodes. Thus, we can generate a new
    ;;     subproblem in this way only a finite number of times, and all other
    ;;     generated subproblems must shrink as in the previous case.
    ;;
    ;; Thus, helper terminates.
    [(define (helper visited to-visit)
       (if (empty? to-visit)
           (reverse visited)
           (local [(define current (first to-visit))]
             (if (member current visited)
                 (helper visited (rest to-visit))
                 (helper (cons current visited)
                         (append (graph-successors g current)
                                 (rest to-visit)))))))]
    (helper '() (list n))))

(check-expect (find-reachable/dfs G1 'a) '(a))
(check-expect (find-reachable/dfs G1* 'a) '(a))
(check-expect (find-reachable/dfs G-LINE 'a) '(a b c d e))
(check-expect (find-reachable/dfs G-LINE 'c) '(c d e))
(check-expect (find-reachable/dfs G-CYCLE 'c) '(c d e a b))
(check-expect (find-reachable/dfs G7 'f) '(f b c d a e g))
(check-expect (find-reachable/dfs G7 'g) '(g))
(check-expect (find-reachable/dfs G-UP-TREE 'e) '(e b a))
(check-expect (find-reachable/dfs G-TREE 'a) '(a b d e c f h g))


;; [Graph X] X -> [ListOf X]
;; Finds all the nodes in graph g reachable from starting node n, and return
;; them in non-decreasing order by minimum distance from n.
;;
;; PRECONDITION: n is a node of g
;;
;; Examples:
;;
;;   - given a single element graph, returns list of that element
;;   - given graph a -> b -> c -> d -> e, starting at a, returns '(a b c d e)
;;   - given graph a -> b -> c -> d -> e, starting at c, returns '(c d e)
;;   - given graph G7, starting at f, returns '(f b c d a g e)
;;   - given graph G-TREE, starting at the root (a), returns '(a b c d e f g h)
;;
;; Strategy: generative recursion
;; Termination: same as find-reachable/dfs
(define (find-reachable/bfs g n)
  (local
    [(define (helper visited to-visit)
       (if (empty? to-visit)
           (reverse visited)
           (local [(define current (first to-visit))]
             (if (member current visited)
                 (helper visited (rest to-visit))
                 (helper (cons current visited)
                         (append (rest to-visit)
                                 (graph-successors g current)))))))]
    (helper '() (list n))))

(check-expect (find-reachable/bfs G1 'a) '(a))
(check-expect (find-reachable/bfs G1* 'a) '(a))
(check-expect (find-reachable/bfs G-LINE 'a) '(a b c d e))
(check-expect (find-reachable/bfs G-LINE 'c) '(c d e))
(check-expect (find-reachable/bfs G-CYCLE 'c) '(c d e a b))
(check-expect (find-reachable/bfs G7 'f) '(f b c d a g e))
(check-expect (find-reachable/bfs G7 'g) '(g))
(check-expect (find-reachable/bfs G-UP-TREE 'e) '(e b a))
(check-expect (find-reachable/bfs G-TREE 'a) '(a b c d e f g h))

;; [RemoveResult C E] is one of:
;; -- 'empty
;; -- (make-remove-result E C)
(define-struct remove-result (element collection))
;;
;; Interpretation: A [RemoveResult C E] represents the result of removing an
;; element of type E from a collection of type C. If 'empty, that indicates
;; that no element could be removed because the collection was empty. If
;; (make-remove-result e c), that means that e is the element removed and
;; c is the remaining collection with e removed.

;; A [BagImpl C E] is (make-bag-impl C [E C -> C] [C -> [RemoveResult C E]])
(define-struct bag-impl (empty insert remove))
;; Interpretation: A [BagImpl C E] is an implementation of a bag data structure,
;; where C is the type of the bag and E is the type of its elements. Given a
;; [BagImpl X] a-bi,
;;   - (bag-impl-empty a-bi) represents the empty set
;;   - (bag-impl-insert a-bi) is the function for adding elements to a bag
;;   - (bag-impl-remove a-bi) is the function for removing an element from the
;;     bag, where the choice of element depends on the bag's implementation.

;; Helpers for examples:

;; [ListOf X] -> [RemoveResult X]
;; Splits a list into the first and the rest as a RemoveResult.
(define (uncons lst)
  (cond
    [(empty? lst) 'empty]
    [(cons? lst)  (make-remove-result (first lst) (rest lst))]))

;; Examples:

(define STACK-BAG
  (make-bag-impl '()
                 cons
                 uncons))

(define LIST-QUEUE-BAG
  (make-bag-impl '()
                 (lambda (new queue) (append queue (list new)))
                 uncons))

;; A [BankersQueue X] is (make-bankers-q [ListOf X] [ListOf X])
(define-struct bankers-q (front back))
;; Interpretation: Given a banker's queue (make-bankers-q f b), the queue in
;; oldest-first order is (append f (reverse b)).

;; X [BankersQueue X] -> [BankersQueue X]
;; Enqueues an element.
(define (bq-enqueue new bq)
  (make-bankers-q (bankers-q-front bq)
                  (cons new (bankers-q-back bq))))

;; [BankersQueue X] -> [RemoveResult X]
;; Dequeues an element.
(define (bq-dequeue bq)
  (local [(define front (bankers-q-front bq))
          (define back (bankers-q-back bq))]
    (cond
      [(cons? front)
       (make-remove-result (first front)
                           (make-bankers-q (rest front) back))]
      [(cons? back)
       (local [(define new-front (reverse back))]
         (make-remove-result (first new-front)
                             (make-bankers-q (rest new-front) '())))]
      [else 'empty])))

(define mt-bq (make-bankers-q '() '()))

(check-expect (remove-result-element (bq-dequeue (bq-enqueue 1 mt-bq))) 1)
(check-expect (remove-result-collection (bq-dequeue (bq-enqueue 1 mt-bq))) mt-bq)
(check-expect (remove-result-element (bq-dequeue (bq-enqueue 2 (bq-enqueue 1 mt-bq)))) 1)
(check-expect (remove-result-element (bq-dequeue (remove-result-collection
                                                  (bq-dequeue (bq-enqueue 2 (bq-enqueue 1 mt-bq))))))
                                     2)
(check-expect (remove-result-collection (bq-dequeue (bq-enqueue 1 mt-bq))) mt-bq)
(check-expect (remove-result-collection (bq-dequeue (remove-result-collection
                                                     (bq-dequeue (bq-enqueue 2 (bq-enqueue 1 mt-bq))))))
              mt-bq)

(define BANKERS-QUEUE-BAG
  (make-bag-impl mt-bq
                 bq-enqueue
                 bq-dequeue))

;; [Graph X] X [BagImpl B X] -> [ListOf X]
;; Finds all the nodes in graph g reachable from starting node n, using the
;; given BagImpl to determine the search order.
;;
;; PRECONDITION: n is a node of g
;;
;; Examples:
;;
;;   - given graph G7, starting at f, using LIST-QUEUE-BAG or BANKERS-QUEUE-BAG,
;;     returns '(f b c d a g e)
;;   - given graph G7, starting at f, using STACK-BAG returns '(f d g a e c b)
;;   - given graph G-TREE, starting at the root (a), using LIST-QUEUE-BAG or
;;     BANKERS-QUEUE-BAG, returns '(a b c d e f g h)
;;   - given graph G-TREE, starting at the root (a), using STACK-BAG, returns
;;     '(a b d e c f h g)
;;
;; Strategy: generative recursion
;; Termination: same as find-reachable/dfs
(define (find-reachable/generic g n bag-impl)
  (local
    [(define (helper visited to-visit)
       (local [(define to-visit* ((bag-impl-remove bag-impl) to-visit))]
         (cond
           [(symbol? to-visit*)
            (reverse visited)]
           [else
            (local
              [(define current (remove-result-element to-visit*))
               (define remaining (remove-result-collection to-visit*))]
              (if (member current visited)
                  (helper visited remaining)
                  (helper (cons current visited)
                          (foldl (bag-impl-insert bag-impl) remaining
                                 (graph-successors g current)))))])))]
    (helper '() ((bag-impl-insert bag-impl) n (bag-impl-empty bag-impl)))))

(check-expect (find-reachable/generic G-LINE 'a STACK-BAG)
              '(a b c d e))
(check-expect (find-reachable/generic G-LINE 'a LIST-QUEUE-BAG)
              '(a b c d e))
(check-expect (find-reachable/generic G-LINE 'a BANKERS-QUEUE-BAG)
              '(a b c d e))

(check-expect (find-reachable/generic G7 'f STACK-BAG)
              '(f d g a e c b))
(check-expect (find-reachable/generic G7 'f LIST-QUEUE-BAG)
              '(f b c d a g e))
(check-expect (find-reachable/generic G7 'f BANKERS-QUEUE-BAG)
              '(f b c d a g e))
(check-expect (find-reachable/generic G-TREE 'a STACK-BAG)
              '(a c g f h b e d))
(check-expect (find-reachable/generic G-TREE 'a LIST-QUEUE-BAG)
              '(a b c d e f g h))
(check-expect (find-reachable/generic G-TREE 'a BANKERS-QUEUE-BAG)
              '(a b c d e f g h))