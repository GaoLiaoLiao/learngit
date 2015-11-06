#lang slideshow

(require pict
         slideshow/code)

(define numbered-item
  (let ([num 1]
        [memo (make-hash)])
    (lambda (string #:color? [color? #f])
      ((if color?
          (λ (p) (colorize p "red"))
          identity)
       (hash-ref! memo string
                  (begin0
                    (item #:bullet (t (string-append (number->string num) "."))
                          string)
                    (set! num (add1 num))))))))

(define spacing 10)

(slide #:title "Computation in BSL"
 (t "We can replace")
 (code (+ n_1 n_2))
 (t "with")
 (hbl-append spacing (code n_1) (t "+") (code n_2))
 (hbl-append spacing (t "if") (code n_1) (t "and") (code n_2) (t "are both numbers")))

(slide #:title "Computation in BSL"
 (t "We can replace")
 (code (f a_1 a_2))
 (t "with")
 (hbl-append spacing (t "the result of calling") (code f) (t "with") (code a_1) (t "and") (code a_2))
 (hbl-append spacing (t "if") (code a_1) (t "and") (code a_2) (t "are atomic data"))
 'next
 (t "This generalizes to n-ary functions with n arguments"))
  
(slide #:title "The Design Recipe"
       (numbered-item "Analyze the problem, describe the data")
       (numbered-item "Write a signature, header, and purpose statement")
       (numbered-item "Create examples")
       (numbered-item "Inventory and strategize")
       (numbered-item "Apply the strategy")
       (numbered-item "Write tests"))
#|
(slide #:title "The Design Recipe"
       (numbered-item "Analyze the problem, describe the data" #:color? #t)
       (numbered-item "Write a signature, header, and purpose statement")
       (numbered-item "Create examples")
       (numbered-item "Inventory and strategize")
       (numbered-item "Apply the strategy")
       (numbered-item "Write tests"))

(slide #:title "The Design Recipe"
       (numbered-item "Analyze the problem, describe the data")
       (numbered-item "Write a signature, header, and purpose statement" #:color? #t)
       (numbered-item "Create examples")
       (numbered-item "Inventory and strategize")
       (numbered-item "Apply the strategy")
       (numbered-item "Write tests"))

(slide #:title "The Design Recipe"
       (numbered-item "Analyze the problem, describe the data")
       (numbered-item "Write a signature, header, and purpose statement")
       (numbered-item "Create examples" #:color? #t)
       (numbered-item "Inventory and strategize")
       (numbered-item "Apply the strategy")
       (numbered-item "Write tests"))

(slide #:title "The Design Recipe"
       (numbered-item "Analyze the problem, describe the data")
       (numbered-item "Write a signature, header, and purpose statement")
       (numbered-item "Create examples")
       (numbered-item "Inventory and strategize" #:color? #t)
       (numbered-item "Apply the strategy")
       (numbered-item "Write tests"))

(slide #:title "The Design Recipe"
       (numbered-item "Analyze the problem, describe the data")
       (numbered-item "Write a signature, header, and purpose statement")
       (numbered-item "Create examples")
       (numbered-item "Inventory and strategize")
       (numbered-item "Apply the strategy" #:color? #t)
       (numbered-item "Write tests"))

(slide #:title "The Design Recipe"
       (numbered-item "Analyze the problem, describe the data")
       (numbered-item "Write a signature, header, and purpose statement")
       (numbered-item "Create examples")
       (numbered-item "Inventory and strategize")
       (numbered-item "Apply the strategy")
       (numbered-item "Write tests" #:color? #t))
|#
(slide #:title "The Design Recipe"
 (scale-to-fit (bitmap "images/recipe-table.png")
               titleless-page))

(slide #:title "The Design Recipe"
 (scale-to-fit (let* ([p (bitmap "images/recipe-table.png")]
                      [w (pict-width p)]
                      [h (pict-height p)])
                 (pin-over p (/ w 1.81)
                             (/ h 1.7)
                             (colorize
                              (linewidth
                               15
                               (ellipse (/ w 12) (/ w 2.6)))
                              "red")))
               titleless-page))
