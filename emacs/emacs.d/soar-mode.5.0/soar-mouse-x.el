;;;; -*- Mode: Emacs-Lisp -*- 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; 
;;;; File            : soar-mouse-x.el
;;;; Author          : Michael Hucka
;;;; Created On      : Fri Mar 23 17:26:26 1990
;;;; Last Modified By: Frank Ritter
;;;; Last Modified On: Sat Nov 21 23:43:43 1992
;;;; Update Count    : 30
;;;; 
;;;; PURPOSE
;;;; 	Support for X Windows in Soar mode.
;;;; 
;;;; Copyright 1990, Mike Hucka.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; $Locker: hucka $
;;;; $Log:	soar-x.el,v $
;;;; Revision 1.1  90/06/08  12:42:29  hucka
;;;; Initial revision
;;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(require 'x-mouse)

(defun soar-x-find-tag (arg)
  (x-mouse-set-point arg)
  (find-tag-other-window (soar-extract-production-name
                                        ;soar-symbol-under-cursor
                          )))


(defun soar-x-spr-item (arg)
  "Run spr on object whose name is under the cursor.  Object can be a production
name or an identifier."
  (x-mouse-set-point arg)
  ;(setq aa 'spr-item)
  (soar-do-to-production (soar-extract-production-name
                          ;soar-symbol-under-cursor
                          ) "spr" t))


(defun soar-x-full-matches-item (arg)
  "Run full-matches on the production whose name is under the cursor."
  (x-mouse-set-point arg)
  ;(setq aa 'fm)
  (soar-do-to-production (soar-extract-production-name
                          ;soar-symbol-under-cursor
                          ) "full-matches" t))


(defun soar-x-ptrace-item (arg)
  "Run spr on object whose name is under the cursor.  Object can be a 
production name or an identifier."
  (x-mouse-set-point arg)
  ;(setq aa 'pt)
  (soar-do-to-production (soar-extract-production-name
                          ;soar-symbol-under-cursor
                          ) "ptrace"))


(defun soar-x-lisp-eval-defun (arg)
  (x-mouse-set-point arg)
  ;(setq aa 'ed)
  (cond ((memq major-mode '(lisp-mode ilisp-mode soar-mode))
	 (eval-defun-lisp nil))
	((eq major-mode 'emacs-lisp-mode)
	 (eval-defun nil))))


;; Erase down map events.  Otherwise may get interference with
;; existing bindings, and may get problem that a button press'
;; `up' event will cause the minibuffer output to disappear

;; this if lets us always load this file....
(if (eq window-system 'x)
    (progn

(define-key mouse-map x-button-s-left 'x-mouse-ignore)
(define-key mouse-map x-button-s-middle 'x-mouse-ignore)
(define-key mouse-map x-button-s-right 'x-mouse-ignore)

(define-key mouse-map x-button-c-s-left 'x-mouse-ignore)
(define-key mouse-map x-button-c-s-middle 'x-mouse-ignore)
(define-key mouse-map x-button-c-s-right 'x-mouse-ignore)

(define-key mouse-map x-button-c-left 'x-mouse-ignore)
(define-key mouse-map x-button-c-middle 'x-mouse-ignore)

;; Bind buttons:

(define-key mouse-map x-button-s-left-up 'soar-x-spr-item)
(define-key mouse-map x-button-s-middle-up 'soar-x-full-matches-item)
(define-key mouse-map x-button-s-right-up 'soar-x-find-tag)

(define-key mouse-map x-button-c-left-up 'soar-x-lisp-eval-defun)
(define-key mouse-map x-button-c-middle-up 'soar-x-ptrace-item)
))
