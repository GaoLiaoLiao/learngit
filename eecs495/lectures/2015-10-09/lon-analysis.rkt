;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-abbr-reader.ss" "lang")((modname lon-analysis) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t quasiquote repeating-decimal #f #t none #f ((lib "image.rkt" "teachpack" "2htdp")) #f)))

(define (snoc e l)
  (cond
    [(empty? l) (cons e '())]
    [else
     (cons (first l) (snoc e (rest l)))]))
;; size of input: length of the list (n)
;; T(0) = 1
;; T(n) = 1 + T(n - 1)
;; T(n) = 1 + (1 + T(n - 2))
;; T(n) = 1 + (1 + ... + T(0)) ...)
;; T(n) = 1 + (1 + ... + 1) ...)
;; T(n) = n + 1

;; snoc is O(n)

(define (my-rev l)
  (cond
    [(empty? l) '()]
    [else
     (snoc (first l) (my-rev (rest l)))]))

;; size of input: length of the list (n)
;; T(0) = 0
;; T(n) = n + T(n - 1)
;; T(n) = n + ((n - 1) + T(n - 2))
;; T(n) = n + ((n - 1) + ((n - 2) + ... + 0) ... )
;; T(n) = n + (n - 1) + (n - 2) + ... + 1
;; T(n) = (n(n+1))/2 = (n^2 + n)/2

;; my-rev is O(n^2)


(define (slooow l)
  (cond
    [(empty? l) '()]
    [else
     (cons (first l)
           (my-rev (slooow (rest l))))]))

;; slooow is O(n^3)
