;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname intro) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "image.rkt" "teachpack" "2htdp")) #f)))
;; set to Beginning Student Language

;; numbers:

0

-25

2.25

1/2

;; expressions that use numbers:

(+ 1 2) ;; prefix notation! same as 1 + 2

(+ 2 1)

(+ 1 2 3 4 5) ;; prefix notation is useful: same as 1 + 2 + 3 + 4 + 5

(+ 5 4 3 2 1)

;; nesting and equality

(+ 1 (+ 2 (+ 1 3)) (+ 2 (+ 1 2)))
;; ==
(+ 1 (+ 2 4) (+ 2 3))
;; ==
(+ 1 6 5)
;; ==
12

;; rule: you can apply an operation when its arguments are all numbers
;; doesn't matter which order you pick them in

(* 3 5)

(* 2 3 4)

(* (+ 1 1) (+ 1 2) (* (+ 1 1) 2)) ;; no "order of operations", everything is always parenthesized

(define x 3)

(define y 4)

(sqrt (+ (* x x) (* y y)))

; Strings

"Hello there"

(string-append "Hello there " "EECS 495")

(string-append "The " (string-append "Design " "Recipe"))

; Images

(circle 30 "solid" "blue")
(triangle 60 "solid" "red")

(above (triangle 60 "solid" "red")
       (circle 30 "solid" "blue"))


;;----------------------------------------


; 1. Data description
; 2. Signature and purpose statement
; 3. Work through examples
; 4. Choose a strategy
; 5. Execute the strategy
; 6. Turn examples into a test suite
