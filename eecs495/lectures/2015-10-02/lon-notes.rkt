;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname lon-notes) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "image.rkt" "teachpack" "2htdp")) #f)))
;; lists of numbers

;; a ListOfNumbers is one of:
;;
;; -- (cons Number ListOfNumbers)
;;
;; -- '()

(define 1-lon (cons 1 '()))
(define 12-lon (cons 1 (cons 2 '())))
(define 5-lon (list 1 2 3 4 5))
(define 10-lon (list 1 2 3 4 5 6 7 8 9 10))

;; ListOfNumbers -> ...
;; ListOfNumbers template
#;
(define (process-lon lon ...)
  (cond
    [(cons? lon) ...
     ... (first lon) ...
     ... (process-lon (rest lon)) ...]
    [(empty? lon) ...]))

;; a NEListOfNumbers is one of:
;;
;; -- (cons Number '())
;;
;; -- (cons Number NEListOfNumbers)

;; NEListOfNumbers -> ...
;; NEListOfNumbers template
#;
(define (process-nelon nelon ...)
  (cond
    [(and (cons? nelon)
          (empty? (rest nelon)))
     ... (first nelon) ...]
    [(cons? nelon) ...
     ... (first nelon) ...
     ... (process-nelon (rest nelon)) ...]))

;; ListOfNumbers -> Number
;; returns the maximum number in the list
;; examples:
;;
;; given: (cons 1 '()), return: 1
;; given: (cons -4 '()), return: -4
;; given: 5-lon, return: 5
;; given: 10, return: 10
;;
;; Strategy: template for NEListOfNumbers
(define (lon-max nelon)
  (cond
    [(and (cons? nelon)
          (empty? (rest nelon)))
     (first nelon)]
    [(cons? nelon)
     (max (first nelon)
          (lon-max (rest nelon)))]))

(check-expect (lon-max (cons 1 '())) 1)
(check-expect (lon-max (cons -4 '())) -4)
(check-expect (lon-max 5-lon) 5)
(check-expect (lon-max 10-lon) 10)

;; ListOfNumbers -> ListOfNumbers
;; returns a list in the reverse order
;; Examples:
;; given: '(), returns: '()
;; given: (cons 1 '()), (cons 1 '())
;; given: (cons 1 (cons 2 '())), returns: (cons 2 (cons 1 '())
;; given: (list 1 2 3 4), returns: (list 4 3 2 1)
;;
;; Strategy: template for ListofNumbers
(define (reverse-lon lon)
  (cond
    [(cons? lon)
     (add-before-empty (first lon)
                       (reverse-lon (rest lon)))]
    [(empty? lon) '()]))

(check-expect (reverse-lon '()) '())
(check-expect (reverse-lon (cons 1 '())) (cons 1 '()))
(check-expect (reverse-lon (cons 1 (cons 2 '()))) (cons 2 (cons 1 '())))
(check-expect (reverse-lon (list 1 2 3 4)) (list 4 3 2 1))

;; Number ListOfNumbers -> ListOfNumbers
;; adds num to the end of lon
;; given 1 '(), returns: (cons 1 '())
;; given 1, (cons 2 '()), returns: (cons 2 (cons 1 '()))
;; given 1, (list 4 3 2), returns: (list 4 3 2 1)
;;
;; Strategy: template for ListofNumbers
(define (add-before-empty num lon)
  (cond
    [(cons? lon)
     (cons (first lon)
           (add-before-empty num (rest lon)))]
    [(empty? lon)
     (cons num '())]))

(check-expect (add-before-empty 1 '()) (cons 1 '()))
(check-expect (add-before-empty 1 (cons 2 '())) (cons 2 (cons 1 '())))
(check-expect (add-before-empty 1 (list 4 3 2)) (list 4 3 2 1))










