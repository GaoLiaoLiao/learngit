;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname notes) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "image.rkt" "teachpack" "2htdp")) #f)))
;; Computing with homework grades

;; A Mark is one of:
;; -- 'check-plus
;; -- 'check
;; -- 'check-minus
;; -- 'nothing
;;
;; Interpretation: in order: excellent work, adequate work, nearly adequate
;; work, or inadequate work

;; A Grade is [0, 1]
;; Interpretation: 1 is full credit, 0 is no credit, in between is partial

;; Mark -> Grade
;; converts a symbolic mark into a numeric grade
;;
;; Examples:
;;  - a check-plus is full credit, 1
;;  - nothing is no credit, 0
;;  - a check is worth 0.9
;;  - a check-minus is worth 0.7
;;
;; Strategy: struct decomp
(define (mark->grade a-mark)
  (cond
    [(symbol=? a-mark 'check-plus) 1]
    [(symbol=? a-mark 'check) 0.9]
    [(symbol=? a-mark 'check-minus) 0.7]
    [(symbol=? a-mark 'nothing) 0]))

(check-expect (mark->grade 'check-plus) 1)
(check-expect (mark->grade 'check) 0.9)
(check-expect (mark->grade 'check-minus) 0.7)
(check-expect (mark->grade 'nothing) 0)

;; A Breakdown is (make-breakdown Mark Mark Mark Mark Mark)
;;
;; Interpretation:
;;  - presentation: design is explained clearly
;;  - understanding: you understand the code, based on Q&A
;;  - design: correct design process (recipe) is evident in code
;;  - correctness: code appears to work
;;  - conformance: assignment follow the specification carefully
(define-struct breakdown (presentation
                          understanding
                          design
                          correctness
                          conformance))

;; Examples:
(define PERFECT-BREAKDOWN (make-breakdown 'check-plus 'check-plus 'check-plus
                                          'check-plus 'check-plus))
(define ALL-MINUS-BREAKDOWN (make-breakdown 'check-minus 'check-minus
                                            'check-minus 'check-minus
                                            'check-minus))
(define FOUR-CHECKS&NOTHING
  (make-breakdown 'check 'check 'check 'nothing 'check))
(define THREE-CHECKS-1PLUS-1MINUS
  (make-breakdown 'check-minus 'check 'check 'check-plus 'check))

;; Breakdown -> Grade
;; averages the marks in a grade breakdown into a single numeric grade
;;
;; Examples:
;;  - if breakdown is five check-pluses, grade is 1
;;  - if breakdown is five check-minuses, grade is 0.7
;;  - if breakdown is four checks and one nothing, grade is 0.72
;;  - if breakdown is one check-plus, one check-minus, and three checks,
;;    grade is 0.88
;;
;; Strategy: struct decomp
(define (breakdown->grade a-breakdown)
  (/ (+ (mark->grade (breakdown-presentation a-breakdown))
        (mark->grade (breakdown-understanding a-breakdown))
        (mark->grade (breakdown-design a-breakdown))
        (mark->grade (breakdown-correctness a-breakdown))
        (mark->grade (breakdown-conformance a-breakdown)))
     5))

(check-expect (breakdown->grade PERFECT-BREAKDOWN) 1)
(check-expect (breakdown->grade ALL-MINUS-BREAKDOWN) 0.7)
(check-expect (breakdown->grade FOUR-CHECKS&NOTHING) 0.72)
(check-expect (breakdown->grade THREE-CHECKS-1PLUS-1MINUS) 0.88)

;; A HomeworkGrade is one of:
;; -- (make-grade-sheet Breakdown String)
;; -- 'missing
;;
;; Interpretation:
;;  - a grade breakdown and comments, or
;;  - assignment is missing.
(define-struct grade-sheet (breakdown comment))

;; HomeworkGrade ... -> ...
;; template for HomeworkGrade
#;
(define (process-homework-grade a-hwg ...)
  (cond
    [(grade-sheet? a-hwg)
     ... (grade-sheet-breakdown a-hwg) ...
     ... (grade-sheet-comment a-hwg) ...]
    [(symbol=? a-hwg 'missing) ...]))

;; A HomeworkGradeList is one of:
;; -- (make-hw-grades HomeworkGrade HomeworkGradeList)
;; -- 'nothing
;;
;; Interpretation: collection of homework grades
(define-struct hw-grades (first rest))

;; HomeworkGradeList ... -> ...
;; template for HomeworkGradeList
#;
(define (process-homework-grade-list a-hgl ...)
  (cond
    [(hw-grades? a-hgl)
     ... (hw-grades-first a-hgl) ...
     ... (process-homework-grade-list (hw-grades-rest a-hgl) ...)
     ...]
    [(symbol=? a-hgl 'nothing) ...]))

;;;;;;;;;;
;; READING FOR FRIDAY: Chapters 10, 11, and 22
;;;;;;;;;;
