;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname all-defined) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t quasiquote repeating-decimal #t #t none #f ((lib "image.rkt" "teachpack" "2htdp")) #f)))
; An ISL-loc-expr is one of:
; -- Symbol
; -- Number
; -- (make-add ISL-loc-expr ISL-loc-expr)
; -- (make-mul ISL-loc-expr ISL-loc-expr)
; -- (make-loc Symbol ISL-loc-expr ISL-loc-expr)

(define-struct add [left right])
(define-struct mul [left right])
(define-struct loc [var def body])

; ISL-loc-expr -> Boolean
; Determines whether `ile` can be evaluated starting
; in the empty environment.
;
; Strategy: structural decomposition w/accumulator
(define (all-defined? ile)
  (local
    [; ISL-loc-expr [List-of Symbol] -> Boolean
     ; Accumulator: def keeps track of the context of make-loc
     ; forms by accumulating a list of variables that they define.
     (define (helper ile def)
       (cond
         [(symbol? ile) (member? ile def)]
         [(number? ile) #true]
         [(add? ile)    (and (helper (add-left ile) def)
                             (helper (add-right ile) def))]
         [(mul? ile)    (and (helper (mul-left ile) def)
                             (helper (mul-right ile) def))]
         [(loc? ile)    (and
                         (helper (loc-def ile) def)
                         (helper (loc-body ile)
                                 (cons (loc-var ile) def)))]))]
    (helper ile '())))

(check-expect (all-defined? (make-add 'x 8))
              #false)

(check-expect (all-defined? (make-add 3 4))
              #true)

(check-expect (all-defined? (make-loc 'x 7 (make-add 'x 8)))
              #true)

(check-expect (all-defined? (make-loc 'x 'y (make-add 'x 8)))
              #false)
