;;;; -*- Mode: Emacs-Lisp -*- 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; 
;;;; File            : soar-indent.el
;;;; Author          : Michael Hucka
;;;; Created On      : Sun Jun 10 23:12:09 1990
;;;; Last Modified By: Frank Ritter
;;;; Last Modified On: Fri Jul 31 17:50:59 1992
;;;; Update Count    : 15
;;;; 
;;;; PURPOSE
;;;; 	Soar mode indentation code.
;;;;
;;;; Table of contents
;;;; 	I.	Fixes to common indentation
;;;;	II.	soar-reindent-sp
;;;;
;;;; Copyright 1990, University of Michigan.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(provide 'soar-indent)

;;; 
;;; 	I.	Fixes to common indentation
;;;-------------------------------------------------------------------------

(put 'sp 'lisp-indent-hook 1)

;;; Fix the indentation of FOR macro and other forms that are not normally
;;; well indented by GNU.

(put 'for 'common-lisp-indent-hook 'lisp-indent-for)
(put 'bind 'common-lisp-indent-hook 'lisp-indent-for)
(put 'repeatwhile 'common-lisp-indent-hook 'lisp-indent-for)
(put 'repeatuntil 'common-lisp-indent-hook 'lisp-indent-for)

(put 'merge 'common-lisp-indent-hook 1)
(put 'while 'common-lisp-indent-hook 1)
(put 'until 'common-lisp-indent-hook 1)

;;;
;;;	II.	soar-reindent-sp
;;;

(defvar soar-reindent-end-marker (make-marker))

(defun soar-reindent-sp ()
  "Cleanup and reindent a Soar production."
  (interactive)
  (setq real-start (point))
  (save-excursion
    ;; set up
    (if (not (re-search-backward "(sp " (point-min) t))
        (error "Not in an SP."))
    (setq start (point))
    (forward-sexp 1)
    (forward-char -1)
    ;; use a marker because we will see stuff added and removed
    (set-marker soar-reindent-end-marker (point))
    (if (not (and (<= start real-start) 
                  (<= real-start soar-reindent-end-marker)))
        (error "Not in an SP (but near one)."))
    ;; cleanup front bits
    (goto-char start)
    (forward-line 1)
    (while (< (point) soar-reindent-end-marker)
        (if (not (re-search-forward "\"" 
                     (save-excursion (end-of-line) (point)) t))
            (insert " "))
        (forward-line 1))
    (re-search-backward "(sp " (point-min) t)
    (reindent-lisp)
    ;; Cleanup innards
    (goto-char start)
    (while (< (point) soar-reindent-end-marker)
      (forward-word 1)
      (setq local-start (point))
      (end-of-line)
      (while (re-search-backward " " local-start t)
        (just-one-space)
        (forward-char -1))
      (forward-line 1))
    (if soar-pull-closing-paren-up
        (progn
          (goto-char soar-reindent-end-marker)
          (cond ( (= 0 (current-column)) ;just paren and you
                  (forward-char -1)
                  (delete-char 1) ))))
    (set-marker soar-reindent-end-marker nil)
    (message "SP reindented.")
  ))
