;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname ft-notes) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp") (lib "batch-io.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp") (lib "batch-io.rkt" "teachpack" "2htdp")) #f)))
;; FamilyTree is one of
;;
;; -- (make-family-tree String FamilyTree FamilyTree)
;;
;; -- (make-empty-ft)
;; interpretation: the string is a name, and
;; the two trees are mother and father (in order)
(define-struct family-tree [name mother father])
(define-struct empty-ft [])

;; FamilyTree ... -> ...
;; FamilyTree template
#;
(define (process-ft a-ft ...)
  (cond
    [(family-tree? a-ft)
     ... (family-tree-name a-ft) ...
     ... (process-ft (family-tree-mother a-ft)) ...
     ... (process-ft (family-tree-father a-ft)) ...]
    [(empty-ft? a-ft)
     ...]))

;; examples:
(define MTFT (make-empty-ft))
(define ALICE (make-family-tree "Alice" MTFT MTFT))
(define ANDY (make-family-tree "Andy" MTFT MTFT))
(define BARB (make-family-tree "Barb" ALICE ANDY))
(define ALEX (make-family-tree "Alex" MTFT MTFT))
(define ALF (make-family-tree "Alf" MTFT MTFT))
(define BOB (make-family-tree "Bob" ALEX ALF))
(define CARMEN (make-family-tree "Carmen" BARB BOB))
  
(define AVA (make-family-tree "Ava" MTFT MTFT))
(define ARTHUR (make-family-tree "Arthur" MTFT MTFT))
(define BEA (make-family-tree "Bea" AVA ARTHUR))
(define ASTRID (make-family-tree "Astrid" MTFT MTFT))
(define AXEL (make-family-tree "Axel" MTFT MTFT))
(define BEN (make-family-tree "Ben" ASTRID AXEL))
(define CARL (make-family-tree "Carl" BEA BEN))

(define DAN (make-family-tree "Dan" CARMEN CARL))

;; ListOfString is one of
;; -- (cons String ListOfString
;; -- '()

;; FamilyTree -> ListOfString
;; returns a list containing all the names in FamilyTree
;;
;; Examples:
;; MTFT --> '()
;; ALICE --> (list "Alice")
;; ALICE --> (list "Andy")
;; BARB --> (list "Alice" "Barb" "Andy")
;; BOB --> (list "Alex" "Bob" "Alf")
;; CARMEN --> (list "Alice" "Barb" "Andy" "Carmen" "Alex" "Bob" "Alf")
;;
;; Strategy: template for FamilyTree
(define (all-names-ft a-ft)
  (cond
    [(family-tree? a-ft)
     (append (all-names-ft (family-tree-mother a-ft))
             (list (family-tree-name a-ft))
             (all-names-ft (family-tree-father a-ft)))]
    [(empty-ft? a-ft)
     '()]))

(check-expect (all-names-ft MTFT) '())
(check-expect (all-names-ft ALICE) (list "Alice"))
(check-expect (all-names-ft BARB) (list "Alice" "Barb" "Andy"))
(check-expect (all-names-ft BOB) (list "Alex" "Bob" "Alf"))
(check-expect (all-names-ft CARMEN) (list "Alice" "Barb" "Andy" "Carmen" "Alex" "Bob" "Alf"))


;; FamilyTree String String-> Boolean
;; returns true if, anywhere in ft, person
;; is descended from ancestor
;; examples:
;; given MTFT "Dan" "Carl", returns #false
;; given DAN "Dan" "Carl", returns #true
;; given DAN "Carl" "Dan", returns #false
;; given CARMEN "Dan" "Barb", returns #false
;; given DAN "Carmen" "Alex", returns #true
;;
;; Strategy: template for FamilyTree
(define (has-ancestor? a-ft person ancestor)
  (cond
    [(family-tree? a-ft)
     (or (and (string=? (family-tree-name a-ft) person)
              (or (family-tree-contains? (family-tree-mother a-ft) ancestor)
                  (family-tree-contains? (family-tree-father a-ft) ancestor)))
         (has-ancestor? (family-tree-mother a-ft) person ancestor)
         (has-ancestor? (family-tree-father a-ft) person ancestor))]
    [(empty-ft? a-ft)
     #false]))

(check-expect (has-ancestor? MTFT "Dan" "Carl") #false)
(check-expect (has-ancestor? DAN "Dan" "Carl") #true)
(check-expect (has-ancestor? DAN "Carl" "Dan") #false)
(check-expect (has-ancestor? CARMEN "Dan" "Barb") #false)
(check-expect (has-ancestor? DAN "Carmen" "Alex") #true)

;; FamilyTree String -> Boolean
;; returns true if the tree contains this person
;; given MTFT "Dan", returns #false
;; given DAN "Carl", returns #true
;; given CARL "Dan", returns #false
;; given CARMEN "Dan", returns #false
;; given DAN "Alex", returns #true
;;
;; Strategy: template for FamilyTree
(define (family-tree-contains? a-ft person)
  (cond
    [(family-tree? a-ft)
     (or (string=? (family-tree-name a-ft) person) 
         (family-tree-contains? (family-tree-mother a-ft) person) 
         (family-tree-contains? (family-tree-father a-ft) person))]
     [(empty-ft? a-ft)
      #false]))


(check-expect (family-tree-contains? MTFT "Dan") #false)
(check-expect (family-tree-contains? DAN "Carl") #true)
(check-expect (family-tree-contains? CARL "Dan") #false)
(check-expect (family-tree-contains? CARL "Dan") #false)
(check-expect (family-tree-contains? CARMEN "Dan") #false)
(check-expect (family-tree-contains? DAN "Alex") #true)


