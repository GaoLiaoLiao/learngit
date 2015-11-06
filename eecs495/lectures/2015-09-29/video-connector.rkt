;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname video-connector) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "image.rkt" "teachpack" "2htdp")) #f)))
;; Video Connectors
;; computing with video interfaces: VGA, DVI, Mini Display Port, HDMI

;; [an alias data definition (not good for our problem)]
;; A VideoConnector is Number

;; [a struct data definition (not good for our problem)]
;; A VideoConnector is (make-video-connector String Number Number)

;; [an itemization data definition (yes)]
;; A VideoConnector is one of:
;; -- 'vga
;; -- 'dvi
;; -- 'mini-display-port
;; -- 'hdmi
;;
;; Interpretation:
;; -- 'vga means a VGA connector
;; -- 'dvi means a DVI connector
;; -- 'mini-display-port means a Mini Display Port connector
;; -- 'hdmi means an HDMI connector

;; VideoConnector ... -> ...
;; A template for VideoConnector:
#;
(define (process-video-connector a-vc ...)
  (cond
    [(symbol=? a-vc 'vga) ...]
    [(symbol=? a-vc 'dvi) ...]
    [(symbol=? a-vc 'mini-display-port) ...]
    [(symbol=? a-vc 'hdmi) ...]))

;; Problem statement: Write a function that determines whether a video
;; connector is digital.

;; [Step 1: Use our existing data definition for VideoConnector]

;; [Step 2:]

;; VideoConnector -> Boolean
;; determines whether a video connector is digital
;;
;; [Step 3:]
;; Examples:
;;
;;  - a VGA connector is not digital
;;  - an HDMI connector is digital
;;
;; [Step 4:]
;; Strategy: structural decomposition
#;
(define (video-connector-digital? a-vc)
  (cond
    [(symbol=? a-vc 'vga) ...]
    [(symbol=? a-vc 'dvi) ...]
    [(symbol=? a-vc 'mini-display-port) ...]
    [(symbol=? a-vc 'hdmi) ...]))

;; [Step 5:]
(define (video-connector-digital? a-vc)
  (cond
    [(symbol=? a-vc 'vga) #false]
    [(symbol=? a-vc 'dvi) #true]
    [(symbol=? a-vc 'mini-display-port) #true]
    [(symbol=? a-vc 'hdmi) #true]))

;; [Step 6:]
(check-expect (video-connector-digital? 'vga) #false)
(check-expect (video-connector-digital? 'hdmi) #true)
(check-expect (video-connector-digital? 'dvi) #true)
(check-expect (video-connector-digital? 'mini-display-port) #true)

;; Problem statement: Write a function to determine whether converting between
;; two connectors requires a digital-to-analog conversion.

;; VideoConnector VideoConnector -> Boolean
;; determines whether converting in-vc to out-vc requires a DAC.
;;
;; Examples:
;;  - HDMI to VGA requires a DAC
;;  - HDMI to DVI does not
;;  - VGA to MDP does not
;;  - VGA to VGA does not
;;
;; Strategy: function composition
(define (requires-dac? in-vc out-vc)
  (and (video-connector-digital? in-vc)
       (not (video-connector-digital? out-vc))))
       
(check-expect (requires-dac? 'hdmi 'vga) #true)
(check-expect (requires-dac? 'hdmi 'dvi) #false)
(check-expect (requires-dac? 'vga 'mini-display-port) #false)
(check-expect (requires-dac? 'vga 'vga) #false)
