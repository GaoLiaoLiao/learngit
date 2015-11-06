;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-abbr-reader.ss" "lang")((modname queues) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t quasiquote repeating-decimal #f #t none #f ((lib "image.rkt" "teachpack" "2htdp")) #f)))

;; A QoN represents a FIFO queue of numbers.
;;
;; We will write a QoN (in the world of information) between right-pointing
;; guillemets:
;;  - »» is the empty queue
;;  - »3» is a queue with one element in it
;;  - »5 4 3» is a queue with 5 added most recently and 3 added first 
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


;; A BankersQueue (implements QoN) is:
;; (make-bq ListOfNumbers ListOfNumbers)
;;
(define-struct bq [front rev])
;;
;; Interpretation:
;; -- ⟦(make-bq '() '())⟧ = »»
;; -- ⟦(make-bq (cons n lqon-f) lqon-r)⟧ = »r1 r2 ... rk m1 m2 ... mk n»
;;      where ⟦lqon-f⟧ = »m1 m2 ... mk» (cons n (cons mk (cons .... (cons m1 '())))
;;      where ⟦(reverse lqon-r)⟧ = »r1 r2 ... rk»
;;

(define mtbq (make-bq '() '()))

;; Number BankersQueue -> BankersQueue
(define (enqueue n bq)
  (make-bq (bq-front bq)
           (cons n (bq-rev bq))))

;; BankersQueue -> BankersQueue
;; have to check if the front of the queue (lqon-f) is empty when we dequeue
;; if it is, reverse the back and move it to the front
(define (dequeue bq)
  (cond
    [(empty? (bq-front bq))
     (make-bq (rest (reverse (bq-rev bq)))
              '())]
    [else
     (make-bq (rest (bq-front bq))
              (bq-rev bq))]))

;; enqueue is O(1)
;; reverse is O(n)
;; dequeue is O(n) if front is empty
;;         otherwise O(1) but...

;; amortized analysis:
;; a(i) = cost of step i
;; t(i) = actual cost (time)
;; φ(i) = potential (savings)
;; Δφ(i) = change of φ at step i = φ(i) - φ(i - 1)
;; a(i) = t(i) + Δφ(i)
;; define:
;; φ(i) = length of lqon-b at step i
;; a(i) =
;; -- enqueue: 1 + 1 = 2 
;; -- dequeue: 1 + (length lqon-b) - (length lqon-b) = 1
;; [ we get tosave a unit of work at enqueue, spend it at dequeue ]
;; [ expresses a relationship between the number of enqueue and cost of dequeues ]
;; [ so, amortized over many calls, it is constant time ]

;; BankersQueue -> ListOfBankersQueue
(define (deqlist bq)
  (list (dequeue bq)
        (dequeue bq)
        (dequeue bq)
        (dequeue bq)
        (dequeue bq)
        (dequeue bq)
        (dequeue bq)
        (dequeue bq)
        (dequeue bq)
        (dequeue bq)
        (dequeue bq)
        (dequeue bq)))

(make-bq '() '(1 2 3 4 5 6))

;; [ analysis assumed we only used each version of the queue once! ]
;; [ later on we will solve this problem ]



