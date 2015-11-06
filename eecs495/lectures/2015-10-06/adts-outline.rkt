;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-abbr-reader.ss" "lang")((modname adts-outline) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t quasiquote repeating-decimal #f #t none #f ((lib "image.rkt" "teachpack" "2htdp")) #f)))
(require "bench.rkt")

;; ADTs

;; An ADT defines a type in terms of information (not data!) and operations
;; that operate on the information. Example:

;; A SetOfNumber represents a mathematical set.
;;
;; Examples:
;;  - the empty set: {}
;;  - a singleton set: {3}
;;  - a larger set: {3, 5, 7}
;;
;; It has these operations and values:
;;
;; son-empty: SetOfNumber
;; The empty set.
;;
;; son-singleton: Number -> SetOfNumber
;; Makes a singleton set containing the given number.
;;
;; son-member?: Number SetOfNumber -> Boolean
;; Determines whether a number is a member of the set.
;;
;; son-union: SetOfNumber SetOfNumber -> SetOfNumber
;; Unions two sets.
;;
;; son-intersection: SetOfNumber SetOfNumber -> SetOfNumber
;; Intersects two sets.
;;
;; son->list: SetOfNumber -> ListOfNumber
;; Returns a list containing the elements of the set.

;; We can write examples using the language of information, even if though
;; we haven't chosen a representation:

;; son-union: SetOfNumber SetOfNumber -> SetOfNumber
;; Unions two sets.
;;
;; Examples:
;;
;;  - (son-union {} {}) => {}
;;  - (son-union {} {5}) => {5}
;;  - (son-union {1, 2} {}) => {1, 2}
;;  - (son-union {1, 2} {2, 4}) => {1, 2, 4}

;; We might even be able to write tests:

#;
(check-expect (son-member? 4 (son-singleton 5)) #false)

;; A StackOfNumber represents a stack of numbers.
;;
;; We will write a StackOfNumber in a “ket” with the top of the
;; stack on the right:
;;
;;  - the empty stack: |>
;;  - a stack with one element: |6>
;;  - a stack with 5 on top and 3 on the bottom: |3 4 5>
;;
;; Operations:
;;
;; stack-empty: StackOfNumber
;; The empty stack |>.
;;
;; stack-empty?: StackOfNumber -> Boolean
;; Is the given stack empty?
;;
;; stack-push: Number StackOfNumber -> StackOfNumber
;; Adds a number to the top of the stack.
;;
;; Examples:
;;  - (stack-push 5 |>) => |5>
;;  - (stack-push 3 |6 8>) => |6 8 3>
;;
;; stack-top: StackOfNumber -> Number
;; Returns the top of a stack, or errors if the stack is empty.
;;
;; Examples:
;;  - (stack-top |3 5 9>) => 9
;;  - (stack-top |3>) => 3
;;  - (stack-top |>) errors
;;
;; stack-pop: StackOfNumber -> StackOfNumber
;; Returns the rest of a stack with the top removed, or errors if the stack
;; is empty.
;;
;; Examples:
;;  - (stack-pop |3 5 9>) => |3 5>
;;  - (stack-pop |3>) => |>
;;  - (stack-pop |>) errors


;;
;; How can we represent a StackOfNumber?
;;


;; A QoN represents a FIFO queue of numbers.
;;
;; We will write a Qon in right-pointing guillemets:
;;
;;  - the empty queue: »»
;;  - a queue with one element: »6»
;;  - a queue with 3 added first, 4 added second, and 5 added most recently:
;;    »5 4 3»
;;
;; Operations:
;;
;; qon-empty: QoN
;; The empty queue »».
;;
;; qon-empty?: QoN -> Boolean
;; Is the given queue empty?
;;
;; qon-enqueue: Number QoN -> QoN
;; Adds a number to the back of the queue.
;;
;; Examples:
;;  - (qon-enqueue 5 »») => »5»
;;  - (qon-enqueue 3 »6 8») => »3 6 8»
;;
;; qon-front: QoN -> Number
;; Returns the front number in the queue, or errors if the queue is empty.
;;
;; Examples:
;;  - (qon-front »3 5 9») => 9
;;  - (qon-front »3») => 3
;;  - (qon-front »») errors
;;
;; qon-dequeue: QoN -> QoN
;; Returns the rest of a queue with the front dequeued, or errors if the queue
;; is empty.
;;
;; Examples:
;;  - (qon-dequeue »3 5 9») => »3 5»
;;  - (qon-dequeue »3») => »»
;;  - (qon-dequeue »») errors

;;
;; How can we represent QoN?
;;

;; Representation options:
;;
;;  - list with front at head: O(n) enqueue and O(1) front/dequeue
;;  - list with front at tail: O(1) enqueue and O(n) front/dequeue
;;  - pair of lists: O(1) enqueue and O(1)-amortized front/dequeue