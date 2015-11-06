;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname 2015-10-27) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;; C++ concepts:
;; -- smart pointers (unique_ptr, shared_ptr)
;; -- RAII (resource acquisition is initialization)
;; -- generics (templates, basically)
;; -- abstract data types (make your own types) (C pretends to have this)
;; -- concepts (maybe?)

;; How should we write the strategy when we use multiple strategies?
;;
;; 1. Don't use multiple strategies.
;; 2. Really, don't use multiple strategies.
;; 3. Use function composition, composing the helper functions that use
;;    the different strategies.
;; 4. Write down the *main* strategy that’s in your head.

;; Example: Write a function distance<? that compares distances in multiple
;; units.

;; A Distance is one of:
;; -- (make-meters PositiveNumber)
;; -- (make-feet-and-inches PositiveNumber PositiveNumber)
;; -- (make-lightyears PositiveNumber)
(define-struct meters [m])
(define-struct feet-and-inches [ft in])
(define-struct lightyears [ly])

#;
(define (process-distance a-dist ...)
  (cond
    [(meters? a-dist)
     ... (meters-m a-dist) ...]
    [(feet-and-inches? a-dist)
     ... (feet-and-inches-ft a-dist) ...
     ... (feet-and-inches-in a-dist) ...]
    [(lightyears? a-dist)
     ... (lightyears-ly a-dist) ...]))

(define METERS/LIGHTYEAR #i9.5e15)

;; Distance Distance -> Boolean
;; Tells us whether dist1 is shorter than dist2.
;;
;; Examples:
;; -- 3m < 4m
;; -- not 4m < 3m
;; -- not 4m < 4m
;; -- 3ft 0in < 1m
;; -- 0.9 ly < 9.5 × 10^15 m
;;
;; Strategy: Function composition
(define (distance<? dist1 dist2)
  (< (distance->meters dist1) (distance->meters dist2)))

(check-expect (distance<? (make-meters 3) (make-meters 4)) #true)
(check-expect (distance<? (make-meters 4) (make-meters 3)) #false)
(check-expect (distance<? (make-meters 4) (make-meters 4)) #false)
(check-expect (distance<? (make-feet-and-inches 3 0) (make-meters 1)) #true)
(check-expect (distance<? (make-lightyears 0.9) (make-meters 9.5e15)) #true)

;; Distance -> PositiveNumber
;; Converts a distance to meters.
;;
;; Examples:
;; -- 5m -> 5m
;; -- 6ft 2in -> 1.8796
;; -- 2ly -> 1.9 × 10^16
;;
;; Strategy: Structural decomposition
(define (distance->meters a-dist)
  (cond
    [(meters? a-dist)
     (meters-m a-dist)]
    [(feet-and-inches? a-dist)
     (feet-and-inches->meters
      (feet-and-inches-ft a-dist)
      (feet-and-inches-in a-dist))]
    [(lightyears? a-dist)
     (lightyears->meters (lightyears-ly a-dist))]))

(check-expect (distance->meters (make-meters 5)) 5)
(check-expect (distance->meters (make-feet-and-inches 6 2)) 1.8796)
(check-within (distance->meters (make-lightyears 2)) 1.9e16 1)

;; PositiveNumber PositiveNumber -> PositiveNumber
;; Convert `the-feet` ft. and `the-inches` in. to meters
(define (feet-and-inches->meters the-feet the-inches)
  (* 0.0254 (+ (* 12 the-feet) the-inches)))

;; PositiveNumber -> PositiveNumber
;; Convert light years to meters.
(define (lightyears->meters the-ly)
  (* METERS/LIGHTYEAR the-ly))

#|
SUMMARY OF BOOK

PART I: Small data

Atomic data: Number, String, Image, Boolean, Char, etc.

Structures: We could have a Number AND a String

  ;; A NumberAndString is (make-nas Number String)

Enumerations: We could have a Number OR a String

  ;; A NumberOrString is one of:
  ;; -- Number
  ;; -- String

  Special weird-ass enumerations called intervals:

    ;; A WaterTemperature is one of:
    ;; -- [-273, 0)
    ;; -- [0, 100)
    ;; -- [100, ∞)

Itemizations: enumerations of structures, or ORs of ANDs

  ;; APairOfNumbersOrStringAndBoolean is one of:
  ;; -- (make-number-pair Number Number)
  ;; -- (make-string-and-bool String Boolean)

PART II: Medium data

SELF-REFERENCE YO.

  ;; A SjfdLdfh is one of:
  ;; -- Number
  ;; -- (make-fjisoe Number Number SjfdLdfh)

8
(make-fjisoe 3 5 8)
(make-fjisoe 9 -4 (make-fjisoe 3 5 8))
(make-fjisoe 0 0 (make-fjisoe 9 -4 (make-fjisoe 3 5 8)))
...and so on, as long as we like

PART III: Abstraction (functions as data)

Reuse!

  ;; A StringPredicate is [String -> Boolean]

Abstracting data definitions:

  ;; An IntBinTree is one of:
  ;; -- 'leaf
  ;; -- (make-branch Integer IntBinTree Integer)

  ;; An StringBinTree is one of:
  ;; -- 'leaf
  ;; -- (make-branch String StringBinTree String)

ABSTRACT!

  ;; A [BinTreeOf X] is one of:
  ;; -- 'leaf
  ;; -- (make-branch X [BinTree X] X)

Abstracting functions:

  ;; IntList -> N
  ;; Count the positive integers in a list.

  ;; IntList -> N
  ;; Count the even integers in a list.

ABSTRACT!

  ;; [Integer -> Boolean] IntList -> N
  ;; Count the elements in an int list satisfying a predicate

ABSTRACT FURTHER!

  ;; [T -> Boolean] [ListOf T] -> N
  ;; Count the elements of a list satisfying a predicate

PART IV: Complicated data

  ;; A ISL+λProgram is [ListOf TopLevelThing]

  ;; A TopLevelThing is one of:
  ;; -- Definition
  ;; -- Expression
  ;; -- Test

  ;; An Expression is one of:
  ;; -- Literal
  ;; -- Symbol
  ;; -- [ListOf Expression]
  ;; -- `(lambda ,[ListOf Symbol] ,Expression)
  ;; -- `(cond ,@[ListOf CondClause] ,FinalCondClause)
  ;; -- `(if ,Expression ,Expression ,Expression)
  ;; -- `(local ,[ListOf Definition] ,Expression)
  ;; -- `(begin ,[ListOf Expression])

  ;; A CondClause is one of:
  ;; -- `(,Expression ,Expression)

  ;; A FinalCondClause is one of:
  ;; -- CondClause
  ;; -- `(else ,Expression)

  ;; A Literal is one of:
  ;; -- Number
  ;; -- String
  ;; -- Char
  ;; -- `',Symbol  ;; ≡  (list 'quote Symbol)

  ;; A Definition is one of:
  ;; -- `(define ,Symbol ,Expression)
  ;; -- `(define (,Symbol ,@[ListOf Symbol]) ,Expression)
  ;; -- `(define-struct `Name ,[ListOf Symbol])

  ;; A Test is one of:
  ;; -- `(check-expect ,Expression ,Expression)
  ;; -- `(check-within ,Expression ,Expression ,Expression)
  ;; -- `(check-error ,Expression)
  ;; -- `(check-error ,Expression ,Expression)

PART V: Recursion that might not stop

1. Evaluating expressions:

To evaluate `(+ ,N ,M):
  - evaluate N (call the result n)
  - evaluate M (call the result m)
  - return n + m

To evaluate `(,F ,M):
  - evaluate F (call the result f)
  - evaluate M (call the result m)
  - check that f is a lambda (lambda (x) N) (for some x and N)
  - generate a new problem by substituting m for x in N, and evaluate *that*

type 2 termination: example that doesn't terminate:
  `(local [(define (f x) (f x))] (f 0))

2. Binary search of an array between i and j:
  - trivial problem: i = j and it's there or not
  - generate a new problem of searching between i and (/ (+ i j) 2) or
    between (/ (+ i j) 2) and j
  - type 1 termination argument: (- j i) decreases with each subproblem, and
    bottoms out at 0 or 1.

PART VI: Remembering where you've been

To evaluate a variable v in an environment E:
  - look up v in E

To evaluate `(+ ,M ,N) in an environment E:
  - evaluate M in E (call it m)
  - evaluate N in E (call it n)
  - answer is m + n

To evaluate `(local [(define ,x ,M)] ,N) in an environment E:
  - evaluate M in E (call it m)
  - evaluate N in E extended with x ↦ m (answer is this)

To evaluate `(,F ,M) in an environment E:
  - evaluate F in E (call the result f)
  - evaluate M in E (call the result m)
  - check that f is a lambda (lambda (x) N) (for some x and N)
  - generate a new problem: N, which we evaluate in x ↦ m

|#

#|
Our repertoire of strategies:

 - Domain knowledge: what we know about the problem domain
 - Function composition: combining functions, or using helpers
 - Structural decomposition: follow the shape of the data
    - use a template
 - Generative recursion: subproblems are generated, not necessarily subparts
   of original problem
    - write down trivial problem, how subproblems are generated, how results
      are combined, and why it terminates (or doesn't)
 - ... with accumulator: where have you been?
    - accumulator statement
|#

;; [ListOf Number] -> Number
;; computes the product of a list of numbers
;;
;; Examples:
;; -- product of '() is 1
;; -- product of '(2 3 4) is 24
;;
;; Strategy: Structural decomposition with accumulator
(define (product a-list0)
  (local
    ;; Accumulator invariant:
    ;;   acc is the product of the elements traversed thus far
    ;;  (product a-list0) = (* acc (product a-list))
    [(define (helper a-list acc)
       (cond
         ;; (product a-list0) = (* acc (product a-list))
         ;; if a-list is empty, then (product a-list) = 1,
         ;; so we substitute 1 for (product a-list):
         ;;   (product a-list0) = (* acc 1)
         ;;   (product a-list0) = acc
         [(empty? a-list) acc]
         
         ;; (product a-list0)
         ;;       = (* acc (product a-list))
         ;;       = (* acc (* (first a-list) (product (rest (a-list)))
         ;; [assoc. of mult: a * (b * c) = (a * b) * c]
         ;;       = (* (* acc (first a-list)) (product (rest (a-list))
         ;; [call helper with (* acc (first a-list)) for acc,
         ;;               and (rest a-list)
         [(cons? a-list)  (helper (rest a-list)
                                  (* (first a-list) acc))]))]
    ;; a-list = a-list0
    ;; acc = 1
    (helper a-list0 1)))

(check-expect (product '()) (product-spec '()))
(check-expect (product '(3)) (product-spec '(3)))
(check-expect (product '(3 4)) (product-spec '(3 4)))
(check-expect (product '(3 4 5)) (product-spec '(3 4 5)))

(define (product-spec a-list)
  (cond
    [(empty? a-list) 1]
    [(cons? a-list) (* (first a-list) (product-spec (rest a-list)))]))

(check-expect (product-spec '()) 1)
(check-expect (product-spec '(3)) 3)
(check-expect (product-spec '(3 4)) 12)
(check-expect (product-spec '(3 4 5)) 60)
