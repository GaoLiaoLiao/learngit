;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname avl2) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;; A Balance is one of:
;; -- -1
;; -- 0
;; -- 1

;; An [AVLNode X] of one of:
;; -- (make-branch Balance X [AVLNode X] [AVLNode X])
;; -- 'leaf
(define-struct branch (balance value left right))
;;
;; Interpretation:
;; -- 'leaf is the empty tree
;; -- (make-branch b v l r) is a tree with v at the root and subtrees l and r
;;
;; Invariant:
;;   For (make-branch b v l r), then:
;;   -- all the values in l ≤ v
;;   -- all the values in r ≥ v
;;   -- (= b (- (avl-height r) (avl-height l)))

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

#;
(define (process-avl-node node ...)
  (cond
    [(branch? node) ... (branch-value node) ...
                    ... (process-avl-node (branch-left node) ...) ...
                    ... (process-avl-node (branch-right node) ...) ...]
    [(symbol=? node 'leaf) ...]))

;; An [AVLTree X] is (make-avl [AVLNode X] [X X -> Boolean])
(define-struct avl (root le?))
;; Interpretation: (make-avl t f) is tree with root t and comparison f
;; which gives the order for the BST property

;; [AVLTree String]
(define EMPTY-TREE (make-avl 'leaf string<=?))
(define MIKE-TREE (make-avl MIKE string<=?))
(define FOXTROT-TREE (make-avl FOXTROT string<=?))

;; actual balance is 0
(define BAD-BALANCE-TREE-0
  (make-avl (make-branch "mike" -1 KILO OSCAR) string<=?))

;; actual balance is 2
(define BAD-BALANCE-TREE-2
  (make-avl (make-branch "charlie" -1 ALFA HOTEL) string<=?))

(define BAD-BALANCE-TREE-2*
  (make-avl (make-branch "charlie" -2 ALFA HOTEL) string<=?))

(define BAD-BST-TREE
  (make-avl (make-branch "mike" 0 OSCAR KILO) string<=?))

;; [AVLNode X] -> Nat
;; The height of the tree rooted at `node`
;;
;; Examples:
;;  - height of ALFA is 1
;;  - height of 'leaf is 0
;;  - height of FOXTROT is 5
;;
;; Strategy: Structural decomposition
(define (avl-height node)
  (cond
    [(branch? node) (+ 1 (max (avl-height (branch-left node))
                              (avl-height (branch-right node))))]
    [(symbol=? node 'leaf) 0]))

(check-expect (avl-height 'leaf) 0)
(check-expect (avl-height ALFA) 1)
(check-expect (avl-height FOXTROT) 5)

;; An [ImproperAVLNode X] of one of:
;; -- (make-branch Balance X [ImproperAVLNode X] [ImproperAVLNode X])
;; -- 'leaf
;;
;; An [ImproperAVLTree X] is (make-avl [ImproperAVLNode X] [X X -> Boolean])

(define-struct branch (balance value left right))
;;
;; Interpretation:
;; -- 'leaf is the empty tree
;; -- (make-branch b v l r) is a tree with v at the root and subtrees l and r


;; [ImproperAVLTree X] -> Boolean
;; Recognizes valid AVL trees.
;;
;; Examples:
;; -- EMPTY-TREE, MIKE-TREE, FOXTROT-TREE => #true
;; -- BAD-BALANCE-TREE-[02], BAD-BST-TREE => #false
;;
;; Strategy: Structural decomposition
(define (avl-wf? tree)
  (avl-wf-success?
   (avl-wf-helper (avl-root tree)
                  (avl-le? tree))))
  
;; Any [ImproperAVLNode X] [X X -> Boolean] -> [AvlWfResult X]
;; Recognizes valid AVL tree nodes.
;;
;; Examples:
;; -- ALFA, BRAVO, CHARLIE, ... => #true
;; -- (make-branch "hello" 0 CHARLIE CHARLIE) => #false
;; -- (make-branch "charlie" -1 ALFA HOTEL) => #false
;;
;; Strategy: Structural decomposition
(define (avl-wf-helper node le?)
  (cond
    [(branch? node)
     (avl-wf-success?
      (branch-value node)
      (branch-balance node)
      (avl-wf-helper (branch-left node) le?)
      (avl-wf-helper (branch-right node) le?)
      le?)]
    [(symbol=? node 'leaf) #true]))

;; An [AvlWfResult X] is one of:
;; -- (make-avl-wf-success Nat [Listof X])
;; -- 'failure
(define-struct avl-wf-success (height elements))
;; Interpretation:
;; -- (make-avl-wf-success h l) means the tree has height h and elements l,
;;    and is well formed
;; -- 'failure means the tree is not well formed

;; X Balance [AvlWfResult X] [AvlWfResult] [X X -> Boolean] -> [AvlWfResult X]
;; Checks whether the AVL condition holds locally.
;;
;; Strategy: Decision tree
(define (check-local-avl-invariant value balance left right le?)
  (if (local-avl-invariant? value balance left right le?)
      (construct-avl-wf-success value left right)
      'failure))

;; X Balance [AvlWfResult X] [AvlWfResult X] [X X -> Boolean] -> Boolean
(define (local-avl-invariant? value balance left right le?)
  ...)

;; X [AvlWfResult X] [AvlWfResult X] -> [AvlWfResult]
(define (construct-avl-wf-success value left right)
  (make-avl-wf-success (+ 1 (max (avl-wf-success-height left)
                                 (avl-wf-success-height right)))
                       `(,value ,@(avl-wf-success-elements left)
                                ,@(avl-wf-success-elements right))))
  