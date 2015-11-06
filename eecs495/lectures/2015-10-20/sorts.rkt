;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname sorts) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))

;; [ListOf X] [X X -> Boolean] -> [ListOf X]
;; sort lox so that it is increasing with respect
;; to cmp
;; Examples:
;; (using Numbers and <)
;; '() -> '()
;; '(1) -> '(1)
;; '(1 2 3) -> '(1 2 3)
;; '(3 1 2) -> '(1 2 3)
(define (ins-sort lofx cmp)
  (local
    [;; X [ListOf X] -> [ListOf X]
     ;; insert x at the right spot
     (define (ins x rlox)
       (cond
         [(empty? rlox)
          (cons x '())]
         [(cmp (first rlox) x)
          (cons (first rlox)
                (ins x (rest rlox)))]
         [else
          (cons x rlox)]))]
  (cond
    [(empty? lofx)
     '()]
    [else
     (ins (first lofx)
          (ins-sort (rest lofx) cmp))])))

(check-expect (ins-sort '() <) '())
(check-expect (ins-sort '(2) <) '(2))
(check-expect (ins-sort '(1 2 3) <) '(1 2 3))
(check-expect (ins-sort '(3 2 1) <) '(1 2 3))
(check-expect (ins-sort '(4 7 2 4 1 0 -5) <) '(-5 0 1 2 4 4 7))
(check-expect (ins-sort '("bravo" "bravo" "charlie" "zed" "alfa" "alpha") string<?)
              '("alfa" "alpha" "bravo" "bravo" "charlie" "zed"))

;; [insertion sort is  O(n^2)]



;; generative recursion template:
#;
(define (generative-recursive-fun problem)
  (cond
    [(trivially-solvable? problem)
     (determine-solution problem)]
    [else
     (combine-solutions
       ... problem ...
       (generative-recursive-fun (generate-problem-1 problem))
       ...
       (generative-recursive-fun (generate-problem-n problem)))]))

;; [ListOf X] [X X -> Boolean] -> [ListOf X]
;; sort lox so that it is increasing with respect
;; to cmp
;; Examples:
;; (using Numbers and <)
;; '() -> '()
;; '(1) -> '(1)
;; '(1 2 3) -> '(1 2 3)
;; '(3 1 2) -> '(1 2 3)
;; strategy: generative recursion
;; termination: recursive calls are always smaller
;; because the pivot will always be removed
(define (qsort lox cmp)
  (local
    [;; X [X X -> Boolean] -> [ListOf X]
     ;; select elements less than pvt
     (define (less-than pvt rlox)
       (filter (lambda (x) (cmp x pvt))
               rlox))
     ;; X [X X -> Boolean] -> [ListOf X]
     ;; select elements less than pvt
     (define (gt-or-e pvt rlox)
       (filter (lambda (x) (not (cmp x pvt)))
               rlox))]
  (cond
    [(empty? lox)
     lox]
    [(cons? lox)
     (local [(define pivot (first lox))]
       (append
        (qsort (less-than pivot (rest lox)) cmp)
        (list pivot)
        (qsort (gt-or-e pivot (rest lox)) cmp)))])))

(check-expect (qsort '() <) '())
(check-expect (qsort '(2) <) '(2))
(check-expect (qsort '(1 2 3) <) '(1 2 3))
(check-expect (qsort '(3 2 1) <) '(1 2 3))
(check-expect (qsort '(4 7 2 4 1 0 -5) <) '(-5 0 1 2 4 4 7))
(check-expect (qsort '("bravo" "bravo" "charlie" "zed" "alfa" "alpha") string<?)
              '("alfa" "alpha" "bravo" "bravo" "charlie" "zed"))

;; [quicksort is O(n^2) in the worst case, but it is O(n log n) on average]


;; [ListOf X] [ListOf X] [X X -> Boolean] -> [ListOf X]
;; merge lox-1 and lox-2 into a list nondecreasing with respect to cmp
;; (assumes lox-1 and lox-2 are already nondecreasing)
;; examples:
;; '() '() -> '()
;; '() '(1 2) -> '(1 2)
;; '(1 2) '() -> '(1 2)
;; '(1 2) '(1 2) -> '(1 1 2 2)
;; '(1 3) '(2 4) -> '(1 2 3 4)
;; strategy: structural decomposition [ListOf X] (in parallel)
(define (merge lox-1 lox-2 cmp)
  (local
    [;; X X [ListOf X] [ListOf X] -> [ListOf X]
     ;; choose the less of x-1 x-2, recur with the rest
     (define (pick-first x-1 x-2 rlox-1 rlox-2)
       (cond
         [(cmp x-1 x-2)
          (cons x-1 (merge rlox-1 (cons x-2 rlox-2) cmp))]
         [else
          (cons x-2 (merge (cons x-1 rlox-1) rlox-2 cmp))]))]
    (cond
      [(empty? lox-1) lox-2]
      [(empty? lox-2) lox-1]
      [else
       (pick-first (first lox-1)
                   (first lox-2)
                   (rest lox-1)
                   (rest lox-2))])))

(check-expect (merge '() '() <) '())
(check-expect (merge '(1 2) '() <) '(1 2))
(check-expect (merge '() '(1 2) <) '(1 2))
(check-expect (merge '(1 2) '(1 2) <) '(1 1 2 2))
(check-expect (merge '(1 3) '(2 4) <) '(1 2 3 4))

;; [ListOf X] [X X -> Boolean] -> [ListOf X]
;; sort the elements of lofx into nondecreasing order with respect to cmp
;; Examples:
;; (using Numbers and <)
;; '() -> '()
;; '(1) -> '(1)
;; '(1 2 3) -> '(1 2 3)
;; '(3 1 2) -> '(1 2 3)
;; termination: recursive calls are approximately half the
;; size of the input
(define (mergesort lofx cmp)
  (cond
    [(or (empty? lofx)
         (empty? (rest lofx)))
     lofx]
    [else
     (local
       [(define half (floor (/ (length lofx) 2)))]
       (merge (mergesort (take half lofx) cmp)
              (mergesort (drop half lofx) cmp)
              cmp))]))

(check-expect (mergesort '() <) '())
(check-expect (mergesort '(2) <) '(2))
(check-expect (mergesort '(1 2 3) <) '(1 2 3))
(check-expect (mergesort '(3 2 1) <) '(1 2 3))
(check-expect (mergesort '(4 7 2 4 1 0 -5) <) '(-5 0 1 2 4 4 7))
(check-expect (mergesort '("bravo" "bravo" "charlie" "zed" "alfa" "alpha") string<?)
              '("alfa" "alpha" "bravo" "bravo" "charlie" "zed"))

;; [merge sort is O(n log n)]

;; Number [ListOf X] -> [ListOf X]
;; return a list of the first n elements of lst
;; PRECONDITION (n < (length lst))
(define (take n lst)
  (cond
    [(= n 0) '()]
    [else (cons (first lst)
                (take (- n 1) (rest lst)))]))

(check-expect (take 0 '(a b c)) '())
(check-expect (take 3 '(a b c)) '(a b c))
(check-expect (take 2 '(a b c)) '(a b))
(check-expect (take 1 '(a b c)) '(a))

;; Number [ListOf X] -> [ListOf X]
;; return the remaining list after dropping the first n elements
;; PRECONDITION (n < (length lst))
(define (drop n lst)
  (cond
    [(= n 0) lst]
    [else (drop (- n 1)
                (rest lst))]))

(check-expect (drop 0 '(a b c)) '(a b c))
(check-expect (drop 3 '(a b c)) '())
(check-expect (drop 2 '(a b c)) '(c))
(check-expect (drop 1 '(a b c)) '(b c))