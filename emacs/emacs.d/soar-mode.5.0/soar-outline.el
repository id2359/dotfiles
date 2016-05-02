;;;; -*- Mode: Emacs-Lisp -*- 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; 
;;;; File            : soar-outline.el
;;;; Author          : Frank Ritter
;;;; Created On      : Thu Oct 22 02:04:37 1992
;;;; Last Modified By: Frank Ritter
;;;; Last Modified On: Wed Nov  4 23:23:31 1992
;;;; Update Count    : 21
;;;; 
;;;; PURPOSE
;;;; 	Outlines for Soar!
;;;; TABLE OF CONTENTS
;;;; 	|>Contents of this module<|
;;;; 
;;;; Copyright 1992, Frank E. Ritter
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Status          : Unknown, Use with caution!
;;;; HISTORY
;;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(provide 'soar-outline)

(make-variable-buffer-local 'outline-prefix-char)
(setq-default outline-prefix-char "\C-z")

(make-variable-buffer-local 'outline-regexp)

(make-variable-buffer-local 'outline-level-function)
(setq-default outline-level-function 'outline-level-default)

;; (autoload 'outline-minor-mode "outline-m"
;;          "outline-minor-mode" t)

;; Autoload outline-m.el if you do anything.
(mapcar '(lambda (x) (autoload x "outline-m" "outline-minor-mode" t))
        '(outline-next-visible-heading
          outline-previous-visible-heading
          outline-forward-same-level
          outline-backward-same-level
          outline-up-heading
          show-all
          hide-subtree
          hide-body
          hide-entry
          hide-leaves
          soar-insert-ps-header
          soar-insert-op-header
          show-subtree
          show-children
          show-entry
          show-branches))

(if (boundp 'outline-minor-keymap)
    ()
  (setq outline-minor-keymap (make-keymap))	; allocate outline keymap table

  (define-key outline-minor-keymap "\C-a" 'show-all)
  (define-key outline-minor-keymap "\C-b" 'outline-backward-same-level)
  (define-key outline-minor-keymap "\C-c" 'hide-entry)
  (define-key outline-minor-keymap "\C-e" 'show-entry)
  (define-key outline-minor-keymap "\C-f" 'outline-forward-same-level)
  (define-key outline-minor-keymap "\C-h" 'hide-subtree)
  (define-key outline-minor-keymap "\C-i" 'show-children)
  (define-key outline-minor-keymap "\C-l" 'hide-leaves)
  (define-key outline-minor-keymap "\C-n" 'outline-next-visible-heading)
  (define-key outline-minor-keymap "\C-o" 'outline-mode)
  (define-key outline-minor-keymap "\C-p" 'outline-previous-visible-heading)
  (define-key outline-minor-keymap "\C-s" 'show-subtree)
  (define-key outline-minor-keymap "\C-t" 'hide-body)
  (define-key outline-minor-keymap "\C-u" 'outline-up-heading)
  (define-key outline-minor-keymap "\C-x" 'show-branches))

;;;; ;;;;;;;;;;;; Experimental Soar mode hooks ;;;;;;;;;;;;;;;;
;;; R. J. Chassell, 21 January 1990
;;; modified for Scribe 31-Jul-92 -FER
;;; modified for Soar 22-Oct-92 -FER

;; The levels that are available go like this:
;; Problem-space  (top level, level 1)
;; Problem space
;; Problemspace
;; Operator       (sublevel, level 2)

;;  Every two spaces indented, drops down another level
;;   Operator       (sublevel 3)

;; change to defvar later

(setq soar-outline-regexp
  "\\([ ;]*@\\(problem\\|\
begin(comment\\|begin(table\\|begin(figure\
\\|operator\
\\|heading \\|appendix\\)\\)\
\\|\\([ ]+\\(\\+\\|\\-\\|\\*\\|\\.\\|\\.\\.\\|\\.\\.\\.\\)[ ]+\\)")
;; we allow some other heading levels, and allow spaces in the front

;; we allow some other heading levels, and allow spaces in the front

(defvar soar-outline-level-indent 2
  "Number of spaces per level of indention.")

;;  "Regular expression matching all the chapter, section, subsection,
;; and similar type headings."
;; (re-search-forward (concat "[\n\^M]\\(" outline-regexp "\\)") nil 'move)
;; (soar-outline-level)
(defun soar-outline-level ()
  "Find the level of current outline heading in a Texinfo mode buffer."
  (save-excursion 
    (skip-chars-forward "@; ")
    (let ((case-fold-search t))
    (cond ((looking-at "Problem") (soar-count-indent 1))
          ((looking-at "Operator") (soar-count-indent 2))
          (t 1)))))

(defun soar-count-indent (n)
  (+ n (/ (current-column) soar-outline-level-indent)))

(defun outline-hide-current-branch ()
  "Hide the branch you are on."
  (interactive)
  (outline-up-heading 1)
  (hide-subtree))

; (soar-setup-outline)
(defun soar-setup-outline ()
  ;; set other keys?
  (define-key outline-minor-keymap "\M-h" 'outline-hide-current-branch)
  (setq outline-regexp soar-outline-regexp)
  (setq outline-level-function 'soar-outline-level)
  ;; Do all that outline-minor-mode otherwise does for us, but avoid its 
  ;; keybindings.   
  (setq selective-display t)		;Turn it on
  ;;(minor-set-key outline-prefix-char 
  ;;               outline-minor-keymap 'outline-minor-mode)
  )

;(setq scribe-mode-hook                 ;Use of Outline
; '(lambda ()
;    (auto-fill-mode 1)
;    (outline-minor-mode)
;    (set-fill-column 78)
;    (define-key outline-minor-keymap "\M-h" 'outline-hide-current-branch)
;    (setq outline-regexp scribe-outline-regexp)
;    (setq outline-level-function 'scribe-outline-level)))


(defun soar-insert-ps-header ()
  (interactive)
  (insert "\n;;;  @Problem space"))

(defun soar-insert-op-header ()
  (interactive)
  (insert "\n;;;  @Operator"))

