;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname dirs) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require htdp/dir)

;; a Directory is:
;; (make-dir Symbol [ListOf Directory] [ListOf File])
;;
;; interpretation: symbol is the name of the directory,
;; a list of subdirectories and a list of files

;; a File is:
;; (make-file Symbol Number [ListOf Char])
;;
;; interpretation: the name, size, and contents of the file

;; Directory [String -> Boolean] -> Number
;; the number of files in a directory where the predicate
;; returns #true when applied to the name of the file
(define (how-many-files dir this-file?)
  (+ (how-many/dirs (dir-dirs dir) this-file?)
     (how-many/files (dir-files dir) this-file?)))

;; [ListOf Files] [String -> Boolean] -> Number
(define (how-many/files files this-file?)
  (length (filter (lambda (file)
                    (this-file? (symbol->string (file-name file))))
                  files)))

;; [ListOf Directory] [String -> Boolean]-> Number
(define (how-many/dirs lofd this-file?)
  (foldl + 0 (map (lambda (d)
                    (how-many-files d this-file?))
                  lofd)))






