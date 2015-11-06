;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname hw-notes) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "image.rkt" "teachpack" "2htdp")) #f)))
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

(define 1-GRADESHEET (make-grade-sheet PERFECT-BREAKDOWN "comment"))
(define 0.7-GRADESHEET (make-grade-sheet ALL-MINUS-BREAKDOWN "comment"))
(define 0.72-GRADESHEET (make-grade-sheet FOUR-CHECKS&NOTHING "comment"))
(define 0.88-GRADESHEET (make-grade-sheet THREE-CHECKS-1PLUS-1MINUS "comment"))

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
 
(define MT-GRADELIST 'nothing)
(define ONE-MISSING-GRADELIST (make-hw-grades 'missing MT-GRADELIST))
(define 1-GRADELIST (make-hw-grades 1-GRADESHEET MT-GRADELIST))
(define 1-0.7-GRADELIST (make-hw-grades 0.7-GRADESHEET 1-GRADELIST))
(define 1-0.7-MISSING-GRADELIST (make-hw-grades 'missing 1-0.7-GRADELIST))
(define ALL-GRADELIST (make-hw-grades 0.72-GRADESHEET
                                      (make-hw-grades 0.88-GRADESHEET
                                                      1-0.7-GRADELIST)))

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

;; HomeWorkGradeList -> Number
;; produce the average grade for a non-empty list of grades
;; Examples:
;; given: 'nothing , raise an error?
;; given: [1], returns: 1
;; given: ['missing], returns: 0
;; given: [1, 0.7], returns: (1 + 0.7) / 2
;; given: [1, 0.7, 'missing], returns: (1 + 0.7 + 0) / 3
;; given: [1, 0.7, 0.72, 0.88], returns (1 + 0.7 + 0.72 + 0.88) / 4
;;
;; Strategy: function composition
(define (grade-list->grade a-hgl)
  (cond
    [(hw-grades? a-hgl)
     (/ (gl-sum a-hgl)
        (gl-count a-hgl))]
    [(symbol=? a-hgl 'nothing)
     (error 'grade-list->grade "can't calculate average for 'nothing")]))

(check-error (grade-list->grade 'nothing)
             "grade-list->grade: can't calculate average for 'nothing")
(check-expect (grade-list->grade ONE-MISSING-GRADELIST) 0)
(check-expect (grade-list->grade 1-GRADELIST) 1)
(check-expect (grade-list->grade 1-0.7-GRADELIST) (/ (+ 1 0.7) 2))
(check-expect (grade-list->grade 1-0.7-MISSING-GRADELIST) (/ (+ 1 0.7) 3))
(check-expect (grade-list->grade ALL-GRADELIST) (/ (+ 1 0.7 0.72 0.88) 4))

;; HomeGradeList -> Number
;; returns the number of gradesheets in the list
;; Examples:
;; given: 'nothing , 0
;; given: [1], returns: 1
;; given: ['missing], returns: 1
;; given: [1, 0.7], returns: 2
;; given: [1, 0.7, 'missing], returns: 3
;; given: [1, 0.7, 0.72, 0.88], returns 4
;;
;; Strategy: Template for HomeGradeList
(define (gl-count a-hgl)
  (cond
    [(hw-grades? a-hgl)
     (+ 1 (gl-count (hw-grades-rest a-hgl)))]
    [(symbol=? a-hgl 'nothing) 0]))

(check-expect (gl-count 'nothing) 0)
(check-expect (gl-count ONE-MISSING-GRADELIST) 1)
(check-expect (gl-count 1-GRADELIST) 1)
(check-expect (gl-count 1-0.7-GRADELIST) 2)
(check-expect (gl-count 1-0.7-MISSING-GRADELIST) 3)
(check-expect (gl-count ALL-GRADELIST) 4)

;; HomeGradeList -> Number
;; returns the sum of the gradesheet grades
;; Examples:
;; given: 'nothing , 0
;; given: [1], returns: 1
;; given: ['missing], returns: 0
;; given: [1, 0.7], returns: 1.7
;; given: [1, 0.7, 'missing], returns: 1.7
;; given: [1, 0.7, 0.72, 0.88], returns: 1 + 0.7 + 0.72 + 0.88
;;
;; Strategy: Template for HomeworkGradeList
(define (gl-sum a-hgl)
  (cond
    [(hw-grades? a-hgl)
     (+ (homework-grade->grade (hw-grades-first a-hgl))
        (gl-sum (hw-grades-rest a-hgl)))]
    [(symbol=? a-hgl 'nothing) 0]))

(check-expect (gl-sum 'nothing) 0)
(check-expect (gl-sum ONE-MISSING-GRADELIST) 0)
(check-expect (gl-sum 1-GRADELIST) 1)
(check-expect (gl-sum 1-0.7-GRADELIST) 1.7)
(check-expect (gl-sum 1-0.7-MISSING-GRADELIST) 1.7)
(check-expect (gl-sum ALL-GRADELIST) (+ 1 0.7 0.72 0.88))

;; HomeworkGrade -> Number
;; converts a homework grade to the appropriate grade
;; given: 'missing, returns: 0
;; given: 1-GRADESHEET, returns 1
;; given: 0.7-GRADESHEET, returns 0.7
(define (homework-grade->grade a-hwg)
  (cond
    [(grade-sheet? a-hwg)
     (breakdown->grade (grade-sheet-breakdown a-hwg))]
    [(symbol=? a-hwg 'missing) 0]))

(check-expect (homework-grade->grade 'missing) 0)
(check-expect (homework-grade->grade 1-GRADESHEET) 1)
(check-expect (homework-grade->grade 0.7-GRADESHEET) 0.7)



