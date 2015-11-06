#lang slideshow

(require slideshow/code)

(slide #:title "World Programs"
       (code (big-bang world-state
                       [to-draw renderer]
                       [on-tick take-a-step]
                       [on-key on-key-event]))
       (t "to-draw : world-state -> image")
       (t "take-a-step : world-state -> world-state")
       (t "on-key-event : world-state key-event -> world-state")
       'next
       (t "what is \"world-state\"?")
       'next
       (t "any type of data you want"))

(slide #:title "Designing for Itemizations"
       (item "Data definition has distinct clauses for subclasses of data")
       (item "Examples: at least one for each sublass")
       (item "Template: mirror the organization of subclasses with a cond")
       (item "Tests: make sure all cases are covered"))

(slide #:title "Designing with Structures"
       (item "Data definition combines pieces of information")
       (item "The definition says which structure instances are legitimate")
       (item "The definition should include examples")
       (item "Template: write a template containing a selector for each field"))