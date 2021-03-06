;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname avl) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;; A Balance is one of:
;; -- -1
;; -- 0
;; -- 1

;; An [AVLNode X] is one of:
;; -- (make-branch X Balance [AVLNode X] [AVLNode X])
;; -- 'leaf
(define-struct branch (value balance left right))
;; Interpretation: (make-branch v b l r) is a tree branch labeled with value v,
;; where b gives the balance factor (explained as an invariant), and l and r
;; are the left and right subtrees.
;;
;; Invariants:
;; -- all values in l are ≤ v
;; -- all values in r are ≥ v
;; -- b = height(r) - height(l)

;; height 1
(define ALFA (make-branch "alfa" 0 'leaf 'leaf))
(define CHARLIE (make-branch "charlie" 0 'leaf 'leaf))
(define ECHO (make-branch "echo" 0 'leaf 'leaf))
(define GOLF (make-branch "golf" 0 'leaf 'leaf))
(define JULIETTE (make-branch "juliette" 0 'leaf 'leaf))
(define LIMA (make-branch "lima" 0 'leaf 'leaf))
(define NOVEMBER (make-branch "november" 0 'leaf 'leaf))
;; height 2
(define BRAVO (make-branch "bravo" 0 ALFA CHARLIE))
(define HOTEL (make-branch "hotel" -1 GOLF 'leaf))
(define KILO (make-branch "kilo" 0 JULIETTE LIMA))
(define OSCAR (make-branch "oscar" -1 NOVEMBER 'leaf))
;; height 3
(define DELTA (make-branch "delta" -1 BRAVO ECHO))
(define MIKE (make-branch "mike" 0 KILO OSCAR))
;; height 4
(define INDIA (make-branch "india" 1 HOTEL MIKE))
;; height 5
(define FOXTROT (make-branch "foxtrot" 1 DELTA INDIA))

;; An [AVLTree X] is (make-avl [AVLNode X] [X X -> Boolean])
;; Interpretation: (make-avl node le?) is an AVL tree whose order
;; is determined by le? (representing ≤).
(define-struct avl (root le?))

(define EMPTY-TREE (make-avl 'leaf string<=?))
(define MIKE-TREE (make-avl MIKE string<=?))
(define FOXTROT-TREE (make-avl FOXTROT string<=?))

(define BAD-BALANCE-TREE
  (make-avl (make-branch "mike" -1 KILO OSCAR) string<=?))

(define BAD-BST-TREE
  (make-avl (make-branch "mike" 0 OSCAR KILO) string<=?))

;;;;;;;;;;;;;
;; avl-wf? ;;
;;;;;;;;;;;;;

;; An [ImproperAVLNode X] of one of:
;; -- (make-branch Balance X [ImproperAVLNode X] [ImproperAVLNode X])
;; -- 'leaf
;;
;; An [ImproperAVLTree X] is (make-avl [ImproperAVLNode X] [X X -> Boolean])

;; Any -> Boolean
;; Recognizes valid AVL trees.
;;
;; Examples:
;; -- EMPTY-TREE, MIKE-TREE, FOXTROT-TREE => #true
;; -- BAD-BALANCE-TREE, BAD-BST-TREE => #false
;;
;; Strategy: Structural decomposition
(define (avl-wf? tree)
  (avl-wf-success? (avl-wf-helper (avl-root tree) (avl-le? tree))))

(check-expect (avl-wf? EMPTY-TREE) #true)
(check-expect (avl-wf? MIKE-TREE) #true)
(check-expect (avl-wf? FOXTROT-TREE) #true)
(check-expect (avl-wf? BAD-BALANCE-TREE) #false)
(check-expect (avl-wf? BAD-BST-TREE) #false)

;; An [AvlWfResult X] is one of:
;; -- (make-avl-wf-success [Listof X] Nat)
;; -- #false
(define-struct avl-wf-success (elements height))
;;
;; Interpretation:
;; -- (make-avl-wf-success xs n) means that the checked tree is valid,
;;    has elements xs, and height n
;; -- #false means it isn't balanced

;; [AVLNode X] [X X -> Boolean] -> [AVLWfResult X]
;; 
(define (avl-wf-helper node le?)
  (cond
    [(branch? node)
     (check-local-avl-invariant
      (branch-value node)
      (branch-balance node)
      (avl-wf-helper (branch-left node) le?)
      (avl-wf-helper (branch-right node) le?)
      le?)]
    [else (make-avl-wf-success '() 0)]))

;; X Balance [AVLNode X] [AVLNode X] [X X -> Boolean] -> [AVLWfResult X]
(define (check-local-avl-invariant value balance left right le?)
  (if (local-avl-invariant? value balance left right le?)
      (construct-avl-wf-result value left right)
      #false))

;; X Balance [AVLNode X] [AVLNode X] [X X -> Boolean] -> Boolean
(define (local-avl-invariant? value balance left right le?)
  (and (avl-wf-success? left)
       (avl-wf-success? right)
       (= balance (- (avl-wf-success-height right)
                     (avl-wf-success-height left)))
       (andmap (lambda (v) (le? v value)) (avl-wf-success-elements left))
       (andmap (lambda (v) (le? value v)) (avl-wf-success-elements right))))

;; X [AVLNode X] [AVLNode X] -> [AVLWfResult X]
(define (construct-avl-wf-result value left right)
  (make-avl-wf-success `(,value ,@(avl-wf-success-elements left)
                                ,@(avl-wf-success-elements right))
                       (+ 1 (max (avl-wf-success-height left)
                                 (avl-wf-success-height right)))))


;; X [AVLTree X] -> [AVLTree X]
;; Adds a value to a tree, returning the augmented tree.
(define (avl-insert value tree)
  (make-avl
   (avl-insert-result-node
    (avl-insert-helper value (avl-root tree) (avl-le? tree)))
   (avl-le? tree)))

;; An [AVLInsertResult X] is (make-avl-insert-result [AVLNode X] Boolean)
(define-struct avl-insert-result (node grew?))

(define (avl-insert-helper value node le?)
  (cond
    [(branch? node)
     (cond
       [(not (le? value (branch-value node)))
        (rebuild/right (branch-value node)
                       (branch-balance node)
                       (branch-left node)
                       (avl-insert-helper value (branch-right node) le?))]
       [(not (le? (branch-value node) value))
        (rebuild/left (branch-value node)
                      (branch-balance node)
                      (avl-insert-helper value (branch-left node) le?)
                      (branch-right node))]
       [else
        (make-avl-insert-result (make-branch value
                                             (branch-balance node)
                                             (branch-left node)
                                             (branch-right node))
                                #false)])]
    [else (make-avl-insert-result
           (make-branch value 0 'leaf 'leaf)
           #true)]))

(define (rebuild/left value old-balance left-result right)
  (cond
    [(not (avl-insert-result-grew? left-result))
     (make-avl-insert-result
      (make-branch value old-balance
                   (avl-insert-result-node left-result)
                   right)
      #false)]
    [(not (= old-balance -1))
     (make-avl-insert-result
      (make-branch value (- old-balance 1)
                   (avl-insert-result-node left-result)
                   right)
      #true)]
    [else
     (make-avl-insert-result
      (rebalance/left value (avl-insert-result-node left-result) right)
      #true)]))

(define (rebuild/right value old-balance left right-result)
  (cond
    [(not (avl-insert-result-grew? right-result))
     (make-avl-insert-result
      (make-branch value old-balance
                   left
                   (avl-insert-result-node right-result))
      #false)]
    [(not (= old-balance 1))
     (make-avl-insert-result
      (make-branch value (+ old-balance 1)
                   left
                   (avl-insert-result-node right-result))
      #true)]
    [else
     (make-avl-insert-result
      (rebalance/right value left (avl-insert-result-node right-result))
      #true)]))

;; A [LeftTree X] is (make-branch X -1 [AVLNode X] [AVLNode X])
;; A [RightTree X] is (make-branch X 1 [AVLNode X] [AVLNode X])

;; A [LeftOrRightTree X] is one of:
;; -- [LeftTree X]
;; -- [RightTree X]

(define (rebalance/left value left right)
  (cond
    [(= -1 (branch-balance left))
     (make-branch (branch-value left) 0
                  (branch-left left)
                  (make-branch value 0
                               (branch-right left)
                               right))]
    [(= 1 (branch-balance left))
     (make-branch (branch-value (branch-right left)) 0
                  (make-branch (branch-value left) 0
                               (branch-left left)
                               (branch-left (branch-right left)))
                  (make-branch value 0
                               (branch-right (branch-right left))
                               right))]
    [else
     (make-branch value -1 left right)]))

(define (rebalance/right value left right)
  (cond
    [(= 1 (branch-balance right))
     (make-branch (branch-value right) 0
                  (make-branch value 0
                               left
                               (branch-left right))
                  (branch-right right))]
    [(= -1 (branch-balance right))
     (make-branch (branch-value (branch-left right)) 0
                  (make-branch value 0
                               left
                               (branch-left (branch-left right)))
                  (make-branch (branch-value right) 0
                               (branch-right (branch-left right))
                               (branch-right right)))][else
     (make-branch value 1 left right)]))




