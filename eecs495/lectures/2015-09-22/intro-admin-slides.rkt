;; EECS 495 IPD, 2015-09-22 slides

#lang racket/gui

(require ppict-slide-grid
         slideshow
         slideshow/code
         unstable/gui/pict
         unstable/gui/ppict
         unstable/gui/pslide)

;;;;;
;;;;; Constants
;;;;;

(define main-font "Helvetica, Light")
(define title-size 72)
(define head-size 48)

(define head-color (make-color 33 99 00))
(define body-color (make-color 99 99 00))

(define camo-background (bitmap "images/camo.png"))
(define drill-sergeant (scale (bitmap "images/bootcamp.jpg") 0.84))

(define medskip (blank 1 15))

;;;;;
;;;;; Helpers
;;;;;

(define (t/font content
                [size (current-font-size)]
                [angle 0]
                #:color [color #f]
                #:extra-style [extra-style '()])
  (define text-pict
    (text content (append extra-style main-font) size angle))
  (if color
      (colorize text-pict color)
      text-pict))

(define (t/title line
                 #:color [color head-color]
                 #:shadow-color [shadow-color "white"])
  (shadow
   (t/font line title-size)
   15
   #:color color
   #:shadow-color shadow-color))

(define (t/body line [space 15])
  (t/font line #:color body-color))

(define (t/head head)
  (t/font head head-size #:color head-color))

(define (pslide/title-only message)
  (pslide
   #:go (coord 0.5 0.4)
   (t/title message)))

(define-syntax pslide/title
  (syntax-rules ()
    [(_ title body ...)
     (pslide
      #:go (coord 0.5 0.075 'ct)
      (t/head title)
      #:go (coord 0.1 0.5 'lc)
      body ...)]))   

;;;;;
;;;;; PSlide setup
;;;;;

(set-margin! 0)
(set-page-numbers-visible! #f)
(pslide-base-pict (lambda () camo-background))

;;;;;
;;;;; Slides begin
;;;;;

(pslide
 drill-sergeant
 #:next
 #:go (coord 0.5 0.5)
 (t/title "Welcome to Bootcamp"
          #:color "white"
          #:shadow-color "black"))

(pslide/title-only "Why bootcamp?")
(pslide/title-only "Will it be difficult?")
(pslide/title-only "What good will it do me?")
(pslide/title-only "How can I get an A?")
(pslide/title-only "This course is different")

;; There's gotta be a way to do this with syntax.
(define (slide/recipe title s1 s2 s3 s4 s5 s6)
  (pslide/title
   title
   #:go (coord 0.3 0.5 'lc)
   #:next
   medskip
   (t/body (string-append "1. " s1))
   #:next medskip
   (t/body (string-append "2. " s2))
   #:next medskip
   (t/body (string-append "3. " s3))
   #:next medskip
   (t/body (string-append "4. " s4))
   #:next medskip
   (t/body (string-append "5. " s5))
   #:next medskip
   (t/body (string-append "6. " s6))))

(slide/recipe "A design recipe"
              "Analysis"
              "Problem statement"
              "Examples"
              "Form"
              "Composition"
              "Validation")

(slide/recipe "A design recipe (for journalists)"
              "Background research"
              "Thesis"
              "Research & examples"
              "Outline"
              "Writing"
              "Fact checking")

(slide/recipe "A design recipe (for scientists)"
              "Background research"
              "Hypothesis"
              "?"
              "Experiment design"
              "Experiment"
              "Replication")

(slide/recipe "A design recipe (for programmers)"
              "Problem analysis and data design"
              "Function header"
              "Functional examples"
              "Design strategy"
              "Coding"
              "Testing")

(pslide/title
   "Code walks"
   #:go (coord 0.3 0.5 'lc)
   #:next medskip
   (t/body "All evaluation in person")
   #:next medskip
   (t/body "Every Wednesday")
   #:next medskip
   (t/body "You only get homework credit")
   (t/body "if you can explain your program"))

(pslide/title-only "Administrivia")

(pslide/title
 "Website"
 #:go (coord 0.5 0.5 'cc)
 (t/body "http://users.eecs.northwestern.edu/~jesse/course/eecs495/"))

(pslide/title
 "Instructors"
 (t/body "Jesse Tov <jesse@eecs.northwestern.edu>")
 medskip
 (t/body "Burke Fetscher <burke.fetscher@eecs.northwestern.edu>")
 medskip
 medskip
 (t/body "Office hours TBD, and gladly by appointment"))

(pslide/title
 "Registration"
 (t/body "If you’re on 495-0-66 waitlist, we’re letting you in")
 medskip #:next
 (t/body "If not, email Jesse for a permission number"))

;; How to abstract???
(pslide/title
 "Pair programming"
 (t/body "You will be assigned a partner")
 medskip #:next
 (t/body "(You’ll change several times)")
 medskip #:next
 (t/body "You MUST do all work by pair programming")
 medskip #:next
 (t/body "This means you're in the same room")
 medskip #:next
 (t/body "One pilot and one co-pilot")
 medskip #:next
 (t/body "Switch often"))

(pslide/title
 "Cheating"
 #:next
 (t/body "Don’t even."))

(pslide drill-sergeant)

(pslide/title
 "Why not?"
 #:next
 (t/body "You will be reported to the dean")
 #:next
 (t/body "and MORE importantly")
 #:next
 (t/body "you won’t learn!"))

(pslide/title
 "What counts as cheating?"
 (t/body "Turning in code you didn’t write")
 medskip #:next
 (t/body "(Tests count as code)")
 medskip #:next
 (t/body "Turning in code that was written outside your presence")
 medskip #:next
 (t/body "Looking at another pair’s code")
 medskip #:next
 (t/body "Letting anyone else (except your partner) see your code"))

(pslide/title
 "How to avoid cheating"
 medskip #:next
 (t/body "Start early!")
 medskip #:next
 (t/body "Protect your work")
 medskip #:next
 (t/body "Better to turn in nothing than to turn in stolen work")
 medskip #:next
 (t/body "If you aren’t sure if something is okay, ask course staff"))

(pslide/title
 "Your grade"
 (t/body "70% code walks")
 medskip
 (t/body "30% midterm exam")
 medskip
 medskip
 (t/body "Still subject to change"))

(pslide/title
 "For next time"
 (t/body "Read HTDP/2e from the beginning through Part I, Section 3")
 medskip
 (t/body "This is a lot, so start today"))
