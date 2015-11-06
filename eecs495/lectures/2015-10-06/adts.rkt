;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-abbr-reader.ss" "lang")((modname adts-outline) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t quasiquote repeating-decimal #f #t none #f ((lib "image.rkt" "teachpack" "2htdp")) #f)))

;; ADT: abstract data type
;;  - defines a type in terms of information (not data!) and abstract
;;    operations

;;
;; AN EXAMPLE ADT
;;

;; A SetOfNumbers represents a set like you’d see in math class.
;;
;; Examples:
;;  - empty: ∅
;;  - singleton: {5}
;;  - larger sets: {1, 3, 5, 7}
;;
;; It has these abstract operations (and values):
;;
;; son-empty: SetOfNumbers
;; The empty set ∅.
;;
;; son-singleton: Number -> SetOfNumbers
;; A singleton set {n}.
;;
;; [Exercise: come up with more operations and their signatures.]
;;
;; son-member?: Number SetOfNumbers -> Boolean
;; Determines whether a number is an element of a set.
;;
;;   Examples:
;;    - (son-member? 5 ⌈{4, 5, 6}⌉) => #true
;;    - (son-member? 9 ⌈{4, 5, 6}⌉) => #false
;;
;; son-union: SetOfNumbers SetOfNumbers -> SetOfNumbers
;; Returns the union of two sets, A ∪ B.
;;
;;   Examples:
;;     - ∅ ∪ {2, 3} = {2, 3}
;;     - (son-union {1, 2} {2, 4}) => {1, 2, 4}
;;
;; son-intersection SetOfNumbers SetOfNumbers -> SetOfNumbers
;; Returns the intersection of two sets, A ∩ B.
;;
;;   Examples:
;;     - ∅ ∩ {2, 3} = ∅
;;     - (son-intersection {1, 2} {2, 4}) => {2}
;;
;; son-difference: SetOfNumbers SetOfNumbers -> SetOfNumbers
;;
;; son-count: SetOfNumbers -> Number
;; Returns the cardinality of a set, |A|.
;;
;; son-subset?: SetOfNumbers SetOfNumbers -> Boolean
;; Determines whether the first set is a subset of the second.
;;
;; son-equal?: SetOfNumbers SetOfNumbers -> Boolean
;; Determes whether two sets are equal.

;; [We can write tests in terms of abstract operations:]
#;
(check-expect (son-member? 5 (son-union (son-singleton 5)
                                        (son-singleton 6)))
              #true)

;; [We can define some abstract operations in terms of others (if we so
;; desire):]
#;
(define (son-member? a-number a-son)
  (son-subset? (son-singleton a-number) a-son))

#;
(define (son-equal? son1 son2)
  (and (son-subset? son1 son2)
       (son-subset? son2 son1)))

;; [We implement an ADT by choosing a particular representation, which
;; may include *representation invariants*, by defining how to interpret
;; the representation as information, and by defining the operations so
;; that they are faithful to the interpretation. A representation
;; invariant is a property of the representation that must always hold,
;; which lets us not have to reason about other possible
;; representations. The interpretation is a function ⟦·⟧ from data to
;; information.]

;; A ListSetOfNumbers (implementing SetOfNumbers) is one of:
;; -- '()
;; -- (cons Number ListSetOfNumbers)
;; where all elements are unique [representation invariant]
;;
;; Interpretation:
;; -- ⟦'()⟧ = ∅
;; -- ⟦(cons n lson)⟧ = n ∪ ⟦lson⟧    when n ∉ ⟦lson⟧
;;
;; Example:
;; -- ⟦'(1 2 4)⟧ = {1, 2, 3} = ⟦'(4 1 2)⟧
;; [Note that there are multiple (data) representations of the same
;; (information) set.]
;;
;; Counterexample:
;; -- '(1 2 4 4) is not a ListSetOfNumbers because it violates the
;;    representation invariant.

;; [How we use a representation invariant:
;;   - If every ListSetOfNumbers we create follows the invariant,
;;   - and if every function that takes and returns ListSetOfNumbers
;;     preserves the invariant,
;;   - then every function that takes ListSetOfNumbers can rely on the
;;     invariant.]

;; [Now we implement the operations...]

;; son-empty: SetOfNumbers
;; The empty set ∅.
(define son-empty '())

;; lson-singleton: Number -> SetOfNumbers
;; A singleton set {n}.
;;
;; Examples:
;;  - (lson-singleton 4) => {4}
;;  - (lson-singleton 8) => {8}
;;
;; Strategy: domain knowledge (ListSetOfNumbers representation)
(define (lson-singleton n)
  (cons n '()))

(check-expect (lson-singleton 4) '(4))
(check-expect (lson-singleton 8) '(8))

;; lson-member?: Number SetOfNumbers -> Boolean
;; Determines whether a number is an element of a set.
;;
;;   Examples:
;;    - (lson-member? 5 ⌈{4, 5, 6}⌉) => #true
;;    - (lson-member? 9 ⌈{4, 5, 6}⌉) => #false
;;
;; Strategy: Structural decomposition
(define (lson-member? n lson)
  (cond
    [(empty? lson) #false]
    [(cons? lson)
     (or (= n (first lson))
         (lson-member? n (rest lson)))]))

(check-expect (lson-member? 5 '(4 5 6)) #true)
(check-expect (lson-member? 9 '(4 5 6)) #false)

;; lson-subset?: ListSetOfNumbers ListSetOfNumbers -> Boolean
;; Determines whether the first parameter is a subset of the second.
;;
;;   Examples:
;;    - (lson-subset? ∅ {4, 5, 6}) => #true
;;    - (lson-subset? {2, 3} {1, 2, 3, 4}) => #true
;;    - (lson-subset? {2, 5} {1, 2, 3, 4}) => #false
;;
;; Strategy: Structural decomposition
(define (lson-subset? lson1 lson2)
  (cond
    [(empty? lson1) #true]
    [(cons? lson1)
     (and (lson-member? (first lson1) lson2)
          (lson-subset? (rest lson1) lson2))]))

(check-expect (lson-subset? '() '(4 5 6)) #true)
(check-expect (lson-subset? '(2 3) '(1 2 3 4)) #true)
(check-expect (lson-subset? '(2 5) '(1 2 3 4)) #false)

;; lson-equal?: ListSetOfNumbers ListSetOfNumbers -> Boolean
;; Determines whether two sets are equal.
;;
;; Examples:
;;  - (lson-equal? ∅ ∅) => #true
;;  - (lson-equal? ∅ {2}) => #false
;;  - (lson-equal? {2} ∅) => #false
;;  - (lson-equal? {2, 3} {3, 4}) => #false
;;  - (lson-equal? {2, 3} {3, 2}) => #true
;;
;; Strategy: Function composition
(define (lson-equal? son1 son2)
  (and (lson-subset? son1 son2)
       (lson-subset? son2 son1)))

(check-expect (lson-equal? '() '()) #true)
(check-expect (lson-equal? '() '(2)) #false)
(check-expect (lson-equal? '(2) '()) #false)
(check-expect (lson-equal? '(2 3) '(3 4)) #false)
(check-expect (lson-equal? '(2 3) '(3 2)) #true)

;; lson-union: ListSetOfNumbers ListSetOfNumbers -> ListSetOfNumbers
;; Returns the union of two sets, A ∪ B.
;;
;;   Examples:
;;     - ∅ ∪ {2, 3} = {2, 3}
;;     - (lson-union {1, 2} {2, 4}) => {1, 2, 4}
;;
;; Strategy: structural decomposition (lson1)
(define (lson-union lson1 lson2)
  (cond
    [(empty? lson1) lson2]
    [(cons? lson1)
     (insert-if-not-member
       (first lson1)
       (lson-union (rest lson1) lson2))]))

;; [lson-union preserves the representation invariant as follows.
;; Because lson1 and lson2 are ListSetOfNumbers, we know that neither
;; contains duplicates. Thus, in the empty case, lson2 is a valid result
;; because it contains no duplicates. In the non-empty case, we know
;; that (rest lson1) contains no duplicates, since `rest` cannot add a
;; duplicate; thus, it is valid to pass (rest lson1) and lson2 to
;; lson-union, and we know that we get a valid (no duplicates)
;; ListSetOfNumbers back. Then we need to add (first lson1) to that
;; recursive result only if it's not already a member, which ensures
;; that it's a member of the result but is not duplicated.]

;; [Here is a bad definition of union that does not preserve the
;; invariant, since it may include duplicates in its result:
(define (lson-union-BAD! lson1 lson2)
  (append lson1 lson2))
;; This bad definition would cause lson-count to stop working.]

(check-expect (lson-equal? (lson-union '(2 3) '()) '(2 3)) #true)
(check-expect (lson-equal? (lson-union '(1 2) '(4 2)) '(1 2 4)) #true)

;; Number ListSetOfNumbers -> ListSetOfNumbers
;; Inserts an element to a set if it's not already a member.
;;
;; Strategy: structural decomposition (Boolean)
#;
(define (template-for-boolean b)
  (if b ... ...))
(define (insert-if-not-member n lson)
  (if (lson-member? n lson)
    lson
    (cons n lson)))

;; lson-count: ListSetOfNumbers -> Number
;; Returns the cardinality of a set, |A|.
;;
;; Examples:
;;  - (lson-count ∅) => 0
;;  - (lson-count {2, 3, 4, 5}) => 4
;;
;; Strategy: function composition
(define (lson-count lson)
  (length lson))

;; [Note that lson-count *relies* on the representation invariant that
;; ListSetOfNumbers doesn't repeat elements--otherwise it could
;; over-count.]

(check-expect (lson-count '()) 0)
(check-expect (lson-count '(2 3 4 5)) 4)

(check-expect (lson-count (lson-union '(1 2) '(2 4)))
              3)

;;
;; ANOTHER EXAMPLE ADT
;;

;; A StackOfNumbers represents a LIFO stack of numbers.
;;
;; We'll write a StackOfNumbers in a “ket” with the top of the stack
;; on the right:
;;
;;  - the empty stack: |>
;;  - a stack with one element: |5>
;;  - a stack with 5 on top and 3 on the bottom: |3 4 5>
;;
;; Operations:
;;
;; stack-empty: StackOfNumbers
;; The empty stack |>
;;
;; stack-empty?: StackOfNumbers -> Boolean
;; Is the given stack empty?
;;
;; stack-push: Number StackOfNumbers -> StackOfNumbers
;; Pushes a number onto the stack.
;;
;;   Examples:
;;    - (stack-push 4 |>) => |4>
;;    - (stack-push 4 |3 7 9>) => |3 7 9 4>
;;
;; stack-top: StackOfNumbers -> Number
;; Returns the number on top of the stack, or error if empty.
;;
;;   Examples:
;;    - (stack-top |3 7 9 4>) => 4
;;    - (stack-top |3>) => 3
;;    - (stack-top |>) ERROR
;;
;; stack-pop: StackOfNumbers -> StackOfNumbers
;; Returns remaining stack after popping the top, or error if empty.
;;
;;   Examples:
;;    - (stack-pop |3 7 9 4>) => |3 7 9>
;;    - (stack-pop |3>) => |>
;;    - (stack-pop |>) ERROR

;; [Now an implementation:]

;; A ListStackOfNumbers (implementing StackOfNumbers) is one of:
;; -- '()
;; -- (cons Number ListStackOfNumbers)
;;
;; Interpretation:
;;  - ⟦'()⟧ = |>
;;  - ⟦(cons n lson)⟧ = |m1 m2 ... mk n>
;;      where ⟦lson⟧ = |m1 m2 ... mk>

;; [Here is an alternative interpretation that is less good:
;;  - ⟦'()⟧ = |>
;;  - ⟦(cons n lson)⟧ = |n m1 m2 ... mk>
;;      where ⟦lson⟧ = |m1 m2 ... mk>
;; What is wrong with this alternative? Try implementing it...]

;; Implementations using the good interpretation:
(define (lson-push n stk)
  (cons n stk))

(define (lson-pop stk)
  (rest stk))

(define (lson-top stk)
  (first stk))

;;
;; A THIRD EXAMPLE ADT
;;

;; A QoN represents a FIFO queue of numbers.
;;
;; We will write a QoN (in the world of information) between right-pointing
;; guillemets:
;;  - »» is the empty queue
;;  - »3» is a queue with one element in it
;;  - »5 4 3» is a queue with 5 added first and 3 added most recently
;;
;; Operations:
;;
;; qon-empty: QoN
;; The empty queue »».
;;
;; qon-empty?: QoN -> Boolean
;; Determines whether a queue is empty.
;;
;; qon-enqueue: Number QoN -> QoN
;; Adds a number to the back of the queue.
;;
;;   Examples:
;;   -- (qon-enqueue 5 »»)    => »5»
;;   -- (qon-enqueue 5 »2 4») => »5 2 4»
;;
;; qon-front: QoN -> Number
;; Returns the number at the front of the queue.
;;
;;   Examples:
;;   -- (qon-front »»)      ERROR!
;;   -- (qon-front »9»)     => 9
;;   -- (qon-front »5 2 4») => 4
;;
;; qon-dequeue: QoN -> QoN
;; Returns the remaining queue after the front (oldest) number is
;; removed.
;;
;;   Examples:
;;   -- (qon-dequeue »»)      ERROR!
;;   -- (qon-dequeue »9»)     => »»
;;   -- (qon-dequeue »5 2 4») => »5 2»

;; [Exercise: Design a representation for QoN and write down the
;; interpretation function.]

;; [Class will probably use lists, but with two different
;; interpretations:]

;; A LQoN-A (implements QoN) is one of:
;; -- '()
;; -- (cons Number LQoN)
;;
;; Interpretation:
;; -- ⟦'()⟧ = »»
;; -- ⟦(cons n lqon)⟧ = »m1 m2 ... mk n»
;;      where ⟦lqon⟧ = »m1 m2 ... mk»

;; A LQoN-B (implements QoN) is one of:
;; -- '()
;; -- (cons Number LQoN)
;;
;; Interpretation:
;; -- ⟦'()⟧ = »»
;; -- ⟦(cons n lqon)⟧ = »n m1 m2 ... mk»
;;      where ⟦lqon⟧ = »m1 m2 ... mk»

;; [Is one of these better? How can we compare them? Let’s see what
;; enqueue and dequeue looks like for each:
;;
;; (enqueue n lqon)
;;  - A: (snoc lqon n)           — O(N) where N is (length lqon)
;;  - B: (cons n lqon)           — O(1)
;;
;; (dequeue lqon)
;;  - A: (rest lqon)             — O(1)
;;  - B: (all-but-last lqon)     — O(N) where N is (length lqon)

;; [snoc is O((length lst1)) because it traverses lst1.]
(define (snoc lst1 n)
  (cond
    [(empty? lst1) (list n)]
    [(cons? lst1) (cons (first lst1)
                        (snoc (rest lst1) n))]))

;; [all-but-last is O((length lst)) because it traverses lst.]
(define (all-but-last lst)
  (cond
    [(empty? (rest lst)) '()]
    [(cons? (rest lst)) (cons (first lst)
                              (all-but-last (rest lst)))]))
