;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname incorrect) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))

#|
THE DESIGN RECIPE

1. Problem analysis (and data definitions)
2. Header (signature, purpose statement, header)
3. Functional examples
4. Strategy choice
5. Code
6. Testing
|#

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Number Number Number Number -> Number
;; sums, in dollars, the given numbers of U.S. coins
;;
;; Examples:
;;   4 quarters is $1
;;   3 quarters, a dime, and 2 pennies is $0.87
;;   40 nickels and 15 pennies is $2.15
;;
;; Strategy: domain knowledge (U.S. currency)
(define (total-change quarters dimes nickels pennies)
  (+ (* 0.25 quarters) (* 0.1 dimes)
     (* 0.05 nickels) (* 0.01 nickels)))

(check-expect (total-change 4 0 0 0) 1)
(check-expect (total-change 3 1 0 2) 0.87)
(check-expect (total-change 0 0 40 15) 2.15)
(check-expect (total-change 0 0 0 0) 0)    ; all zeros
(check-expect (total-change 1 2 3 4) 0.64) ; all kinds

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Number Number Number Number -> Number
;; converts from inches to centimeters
;;
;; Examples:
;;   0 in = 0 cm
;;   1 in = 2.54 cm
;;   2 in = 5.08 cm
;;
;; Strategy: domain knowledge (units of measure)
(define (inches->centimeters in)
  (* 2.54 in))

(check-expect (inches->centimeters 0) 0)
(check-expect (inches->centimeters 0.5) 1.27)
(check-expect (inches->centimeters 1) 2.54)
(check-expect (inches->centimeters 2) 5.08)
(check-expect (inches->centimeters 10) 25.4)




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Feet -> Inches
;; converts from feet to inches
;;
;; Examples:
;;   (check-expect (feet->inches 0) 0)
;;   (check-expect (feet->inches 1) 12)
;;   (check-expect (feet->inches 2) 24)
;;
;; Strategy: domain knowledge (units of measure)
(define (feet->inches ft)
  (* 12 ft))

(check-expect (feet->inches 0) 0)
(check-expect (feet->inches 0.5) 6)
(check-expect (feet->inches 1) 12)
(check-expect (feet->inches 2) 24)
(check-expect (feet->inches 10) 120)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Number -> Number
;; converts from centimeters to meters
;;
;; Examples:
;;   0 cm = 0 m
;;   1 cm = 0.01 m
;;   150 cm = 1.5 m
(define (conversion-function cm)
  (/ cm 100))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Number -> Number
;; converts from meters to feet
;;
;; Examples:
;;   0 ft = 0 m
;;   1 ft = 1 ft * 12 in/ft * 2.54 cm/in * 0.01 m/c = 0.3048
;;   8 ft = 8 ft * 12 in/ft * 2.54 cm/in * 0.01 m/c = 2.4384
;;
;; Strategy: function composition
(define (feet->meters ft)
  (conversion-function (inches->centimeters (feet->inches ft))))

(check-expect (feet->meters 0) 0)
(check-expect (feet->meters 0.5) 0.1524)
(check-expect (feet->meters 1) 0.3048)
(check-expect (feet->meters 8) 2.4384)