;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname date-in-summer) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "image.rkt" "teachpack" "2htdp")) #f)))
;; Problem statement: determine whether a date is in the summer

;; A Date is (make-date Number Number)
;;
;; Interpretation: (make-date d m) is the dth day of month m
(define-struct date (day month))

(define SPRING-EQUINOX (make-date 20 3))
(define SUMMER-SOLSTICE (make-date 21 6))
(define AUTUMN-EQUINOX (make-date 23 9))
(define WINTER-SOLSTICE (make-date 21 12))

;; [ Creates four functions:
;;  - make-date: Number Number -> Date
;;  - date?: Any -> Boolean
;;  - date-day: Date -> Number
;;  - date-month: Date -> Number
;; ]

;; Date ... -> ...
;; template for Date
#;
(define (process-date a-date ...)
  ... (date-day a-date) ...
  ... (date-month a-date) ...)

;; Date Date ... -> ...
;; template for two Dates
#;
(define (process-two-dates a-date another-date ...)
  ... (date-day a-date) ...
  ... (date-month a-date) ...
  ... (date-day another-date) ...
  ... (date-month another-date) ...)

;; Date -> Boolean
;; determines whether the date is in the summer
;;
;; Examples:
;;  - April 2 is not in the summer
;;  - July 4 is in the summer
;;  - September 23 is not in the summer
;;  - September 22 is in the summer
;;
;; Strategy: function composition
(define (date-in-summer? a-date)
  (and (date<=? SUMMER-SOLSTICE a-date)
       (not (date<=? AUTUMN-EQUINOX a-date))))

;; a date before the summer:
(check-expect (date-in-summer? (make-date 2 4)) #false)
;; a mid-summer date:
(check-expect (date-in-summer? (make-date 4 7)) #true)
;; a date after the summer:
(check-expect (date-in-summer? (make-date 2 12)) #false)
;; a date right after the end boundary:
(check-expect (date-in-summer? (make-date 23 9)) #false)
;; a date right within the end boundary:
(check-expect (date-in-summer? (make-date 22 9)) #true)
;; a date right before the start boundary:
(check-expect (date-in-summer? (make-date 20 6)) #false)
;; a date right within the start boundary:
(check-expect (date-in-summer? (make-date 21 6)) #true)

;; Wishlist:

;; date<=?: Date Date -> Boolean
;; determines whether date1 is before or equal to date2
;;
;; Examples:
;;  - June 3 is before or equal to June 3
;;  - June 3 is before or equal to June 4
;;  - June 3 is not before or equal to June 2
;;  - June 3 is not before or equal to May 31
;;
;; Strategy: struct decomp (two Dates)
(define (date<=? date1 date2)
  (or (< (date-month date1) (date-month date2))
      (and (= (date-month date1) (date-month date2))
           (<= (date-day date1) (date-day date2)))))

(check-expect
 (date<=? (make-date 3 6) (make-date 3 6))
 #true)
(check-expect
 (date<=? (make-date 3 6) (make-date 4 6))
 #true)
(check-expect
 (date<=? (make-date 3 6) (make-date 2 6))
 #false)
(check-expect
 (date<=? (make-date 3 6) (make-date 31 5))
 #false)
(check-expect
 (date<=? (make-date 3 6) (make-date 5 9))
 #true)
