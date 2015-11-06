;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname avl-actual) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;; A Balance is one of:
;; -- -1
;; -- 0
;; -- 1

;; An [AVLNode X] of one of:
;; -- (make-branch X Balance [AVLNode X] [AVLNode X])
;; -- 'leaf
(define-struct branch (value balance left right))
;;
;; Interpretation:
;; -- 'leaf is the empty tree
;; -- (make-branch b v l r) is a tree with v at the root and subtrees l and r
;;
;; Invariant:
;;   For (make-branch b v l r), then:
;;   -- all the values in l < v
;;   -- all the values in r > v
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
                    ... (branch-balance node) ...
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

;(define-struct branch (balance value left right))
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

(check-expect (avl-wf? EMPTY-TREE) #true)
(check-expect (avl-wf? MIKE-TREE) #true)
(check-expect (avl-wf? FOXTROT-TREE) #true)
(check-expect (avl-wf? BAD-BALANCE-TREE-0) #false)
(check-expect (avl-wf? BAD-BALANCE-TREE-2) #false)
(check-expect (avl-wf? BAD-BALANCE-TREE-2*) #false)
(check-expect (avl-wf? BAD-BST-TREE) #false)


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
     (check-local-avl-invariant
      (branch-value node)
      (branch-balance node)
      (avl-wf-helper (branch-left node) le?)
      (avl-wf-helper (branch-right node) le?)
      le?)]
    [(symbol=? node 'leaf)
     (make-avl-wf-success '() 0)]))

;; An [AvlWfResult X] is one of:
;; -- (make-avl-wf-success Nat [Listof X])
;; -- 'failure
(define-struct avl-wf-success (elements height))
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
;; checks that value is between elements in left and right, and that
;; the balance fact is consistent heights
;; Strategy: domain knowledge of AVL trees
(define (local-avl-invariant? value balance left right le?)
  (and (avl-wf-success? left)
       (avl-wf-success? right)
       ;; check balance:
       (= balance (- (avl-wf-success-height right)
                     (avl-wf-success-height left)))
       ;; check ordering:
       (andmap (lambda (v) (not (le? value v)))
               (avl-wf-success-elements left))
       (andmap (lambda (v) (not (le? v value)))
               (avl-wf-success-elements right))))

(check-expect (local-avl-invariant? "charlie" -1
                                    (make-avl-wf-success '("alfa" "bravo") 2)
                                    (make-avl-wf-success '("delta" "golf") 1)
                                    string<=?)
              #true)
(check-expect (local-avl-invariant? "charlie" -1
                                    (make-avl-wf-success '("delta" "golf") 1)
                                    (make-avl-wf-success '("alfa" "bravo") 2)
                                    string<=?)
              #false)
(check-expect (local-avl-invariant? "charlie" 1
                                    (make-avl-wf-success '("delta" "bravo") 1)
                                    (make-avl-wf-success '("delta" "golf") 2)
                                    string<=?)
              #false)
(check-expect (local-avl-invariant? "charlie" 1
                                    (make-avl-wf-success '("alfa" "bravo") 1)
                                    #false
                                    string<=?)
              #false)

;; X [AvlWfResult X] [AvlWfResult X] -> [AvlWfResult]
(define (construct-avl-wf-success value left right)
  (make-avl-wf-success `(,value ,@(avl-wf-success-elements left)
                                ,@(avl-wf-success-elements right))
                       (+ 1 (max (avl-wf-success-height left)
                                 (avl-wf-success-height right)))))


;; X [AVLTree X] -> [AVLTree X]
;; adds a value to the tree, and returns the augmented tree
(define (avl-insert value tree)
  (make-avl
   (avl-insert-result-node
    (avl-insert-helper value (avl-root tree) (avl-le? tree)))
   (avl-le? tree)))


(check-expect (avl-wf? (make-avl 'leaf <=)) #true)
(check-expect (avl-wf? (avl-insert 1 (make-avl 'leaf <=))) #true)
(check-expect (avl-wf? (avl-insert 2 (avl-insert 1 (make-avl 'leaf <=)))) #true)
(check-expect (avl-wf? (avl-insert 3
                        (avl-insert 2 (avl-insert 1 (make-avl 'leaf <=))))) #true)
(check-expect (avl-wf? (foldl avl-insert (make-avl 'leaf <=) '(1 2 3 4 5 6 6)))
              #true)
(check-expect (avl-wf? (foldl avl-insert (make-avl 'leaf <=)
                              (reverse '(1 2 3 4 5 6 6))))
              #true)

;; an [AVLInsertResult X] is
;; (make-avl-insert-result [AVLNode X] Boolean)
(define-struct avl-insert-result [node grew?])

;; X [AVLNode X] [X X -> Boolean] -> [AVLInsertResult X]
;; insert the element and return the new node
;; Examples:
;; add "alfa" to EMPTY-TREE, get ALFA
;; add "beta" to ALFA, get (make-branch "alfa" 1 'leaf (make-branch "beta" 'leaf 'leaf))
;; decomposition on [AVLNode X]
(define (avl-insert-helper value node le?)
  (local
    [;; X Balance [AvlNode X] [AvlNode X] -> [AVLInsertResult X]
     (define (ins-branch b-val balance left right)
       (cond
         [(not (le? b-val value))
          (rebuild/left b-val balance (avl-insert-helper value left le?) right)]
         [(not (le? value b-val))
          (rebuild/right b-val balance left (avl-insert-helper value right le?))]
         [else
          (make-avl-insert-result
           (make-branch value balance left right)
           #false)]))]
    (cond
      [(branch? node)
       (ins-branch (branch-value node)
                   (branch-balance node)
                   (branch-left node) 
                   (branch-right node))]
      [(symbol=? node 'leaf)
       (make-avl-insert-result
        (make-branch value 0 'leaf 'leaf)
        #true)])))

(check-expect
 (avl-insert-helper "alfa" 'leaf string<=?)
 (make-avl-insert-result ALFA #true))
(check-expect
 (avl-insert-helper "beta" ALFA string<=?)
 (make-avl-insert-result (make-branch "alfa" 1 'leaf (make-branch "beta" 0 'leaf 'leaf)) #true))

;; X Balance [AvlNode X] [AvlNode X] -> [AVLInsertResult X]
;; if the balance invariant would be broken, fix it
;; strategy: decision tree
(define (rebuild/left value old-balance left right)
  (cond
    [(not (avl-insert-result-grew? left))
     (make-avl-insert-result
      (make-branch value old-balance
                   (avl-insert-result-node left)
                   right)
      #false)]
    [(not (= old-balance -1))
     (make-avl-insert-result
      (make-branch value (- old-balance 1)
                   (avl-insert-result-node left)
                   right)
      (= old-balance 0))]
    [else
     (make-avl-insert-result
      (rebalance/left value (avl-insert-result-node left) right)
      #false)]))

;; X [AVLNode X] [AVLNode X] -> [AVLNode X]
;; fix the two imbalanced cases
(define (rebalance/left value left right)
  (cond
    [(= -1 (branch-balance left))
     (make-branch (branch-value left) 0
                  (branch-left left)
                  (make-branch value 0
                               (branch-right left)
                               right))]
    [(= 1 (branch-balance left))
     (make-branch (branch-value (branch-right left))
                  0
                  (make-branch (branch-value left)
                               (min 0 (- (branch-balance (branch-right left))))
                               (branch-left left)
                               (branch-left (branch-right left)))
                  (make-branch value
                               (max 0 (- (branch-balance (branch-right left))))
                               (branch-right (branch-right left))
                               right))]))

(check-expect (rebalance/left 6
                              (make-branch 4 -1
                                           (make-branch 2 0
                                                        (make-branch 1 0 'leaf 'leaf)
                                                        (make-branch 3 0 'leaf 'leaf))
                                           (make-branch 5 0 'leaf 'leaf))
                              (make-branch 7 0 'leaf 'leaf))
              (make-branch 4 0
                           (make-branch 2 0
                                        (make-branch 1 0 'leaf 'leaf)
                                        (make-branch 3 0 'leaf 'leaf))
                           (make-branch 6 0
                                        (make-branch 5 0 'leaf 'leaf)
                                        (make-branch 7 0 'leaf 'leaf))))


(check-expect (rebalance/left 5
                              (make-branch 2 1
                                           (make-branch 1 0 'leaf 'leaf)
                                           (make-branch 4 -1
                                                        (make-branch 3 0 'leaf 'leaf)
                                                        'leaf))
                              (make-branch 6 0 'leaf 'leaf))
              (make-branch 4 0
                           (make-branch 2 0
                                        (make-branch 1 0 'leaf 'leaf)
                                        (make-branch 3 0 'leaf 'leaf))
                           (make-branch 5 1
                                        'leaf
                                        (make-branch 6 0 'leaf 'leaf))))

(check-expect (rebalance/left 5
                              (make-branch 2 1
                                           (make-branch 1 0 'leaf 'leaf)
                                           (make-branch 3 1
                                                        'leaf
                                                        (make-branch 4 0 'leaf 'leaf)))
                              (make-branch 6 0 'leaf 'leaf))
              (make-branch 3 0
                           (make-branch 2 -1
                                        (make-branch 1 0 'leaf 'leaf)
                                        'leaf)
                           (make-branch 5 0
                                        (make-branch 4 0 'leaf 'leaf)
                                        (make-branch 6 0 'leaf 'leaf))))

;; X Balance [AVLNode X] [AVLInsertResult X]
;; combine parts of a current node and an insert result into a new result
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
      (= old-balance 0))]
    [else
     (make-avl-insert-result
      (rebalance/right value left (avl-insert-result-node right-result))
      #false)]))

;; X [AVLNode X] [AVLNode X] -> [AVLNode X]
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
                  (make-branch value 
                               (min 0 (- (branch-balance (branch-left right))))
                               left
                               (branch-left (branch-left right)))
                  (make-branch (branch-value right) 
                               (max 0 (- (branch-balance (branch-left right))))
                               (branch-right (branch-left right))
                               (branch-right right)))]))











