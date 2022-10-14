;;;; -*- Mode: Emacs-Lisp -*- 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; 
;;;; File            : soar-ilisp-inits.el|4.12/
;;;; Author          : Frank Ritter
;;;; Created On      : November 1990
;;;; Last Modified By: Frank Ritter
;;;; Last Modified On: Wed Nov 11 18:43:23 1992
;;;; Update Count    : 30
;;;; 
;;;;
;;;;		   munges ilisp package for GNU Emacs Soar mode
;;;;

(provide 'soar-ilisp-inits)

;; Soar-mode doesn't need it!
(setq ilisp-load-no-compile-query t)

(setq ilisp-prefix soar-command-prefix)

;; this belongs in a site file...
;(setq ilisp-site-hook
;    '(lambda ()
;      ;; change prefix to our taql mode one, and rebind the keys
;      (ilisp-bindings)
; ))

;; so popper won't clobber ^Z
(setq popper-load-hook
     (function (lambda ()
       ;; Define key bindings
       (define-key global-map "\C-c1" 'popper-bury-output)
       (define-key global-map "\C-cv" 'popper-scroll-output)
       (define-key global-map "\C-cg" 'popper-grow-output)
       (define-key global-map "\C-cb" 'popper-switch))))
       ;; Make *Manual windows default to 10 lines

;; Define key bindings
(define-key global-map "\C-c1" 'popper-bury-output)
(define-key global-map "\C-cv" 'popper-scroll-output)
(define-key global-map "\C-cg" 'popper-grow-output)
(define-key global-map "\C-cb" 'popper-switch)
